---
author: "Wes Hinsley"
date: 2023-06-29
title: MPI from R - Part Two - Simple Comms
best: false
tags:
 - R
 - MPI
 - HPC
---

Previously in [MPI From R](/blog/mpi-from-r-part-one-the-basics/) ... we 
made an R package that could run code in multiple processes potentially
spread across different computers (nodes), using MPI functions. Now 
let's talk about sharing data between processes. We have a bit of structural
work to do first.

# Copying data between R and C++

When R and C++ run togther, it's best to think of the two as separate
worlds. We can't make a data structure that we can read from and write to 
from both sides. Instead, we need a couple of helper functions below 
(with thanks to Rich), to interface between the two. We'll define these in 
a file `src/data.h` :-

```
#pragma once

#include <cpp11.hpp>
#include <vector>

cpp11::sexp new_data(cpp11::doubles x);
cpp11::sexp get_data(cpp11::external_pointer<std::vector<double>> ptr);
```

These two are called from R: the `new_data` function takes a
R-flavoured vector of doubles, creates a copy of that vector in C++ world, and 
gives back to R a _pointer_ to that new vector. R can do nothing with this 
pointer except give it back to C++ later. The `get_data` function will copy
the contents of the C++ vector back into an R-flavoured vector. Here's
how we implement those two functions in `src/data.cpp` :-

```
#include "data.h"

[[cpp11::register]]
cpp11::sexp new_data(cpp11::doubles x) {
  std::vector<double> *data = new std::vector<double>(x.size());
  std::copy(x.begin(), x.end(), data->begin());
  cpp11::external_pointer<std::vector<double>> ptr(data, true, false);
  return cpp11::as_sexp(ptr);
}

[[cpp11::register]]
cpp11::sexp get_data(cpp11::external_pointer<std::vector<double>> ptr) {
  std::vector<double> *data = cpp11::as_cpp<cpp11::external_pointer<std::vector<double>>>(ptr).get();
  cpp11::writable::doubles ret(data->size());
  std::copy(data->begin(), data->end(), ret.begin());
  return ret;
}
```

# Adding a precision timer

We're going to do some timing below, and the 
[MPI_Wtime](https://www.mpich.org/static/docs/v3.3/www3/MPI_Wtime.html) 
function gives us a double-precision[^1] number of seconds since some
arbitrary origin.[^2] We'll wrap the MPI function as before, by inserting
a line in the header `src/rmpi.h` :-

```
double get_mpi_time();
```

and the function itself in `src/rmpi.cpp` :-

```
[[cpp11::register]]
double get_mpi_time() {
  return MPI_Wtime();
}
  
```

# MPI Communication - Worst Case

Now we're ready to write some very naive code, in which a number of
MPI processes will create some data, and all the MPI processes want to 
then have their own copy of all the data from all the processes. 

We'll do this by having each process creating a large data structure
at the start, populate their own subset of it, and then perform an
MPI call to assemble all the parts. If we set unpopulated data as
zero, we can use a _reduction_ summing over the contributions from
different proceses.

In `R/source.cpp`, my function, with a little bit of timing, 
looks like this :-

```
naive_reduce <- function() {

  start_mpi()                                      # Start up
  rank <- get_mpi_rank()                           # Who am I
  size <- get_mpi_size()                           # How big is my family?

  n <- 100000000                                   # Size of big array ~800Mb.
  each <- ceiling(n / size)                        # Each process does at most this much work.
  start <- 1 + (rank * each)                       # Start index for this process
  end <- min(start + (each - 1), n)                # End index for this process. Avoid out of bounds.

  local_time <- -(get_mpi_time())                  # Start the local stop-watch
  data <- rep(0, n)                                # Create the big array
  data[start:end] <- runif(1 + (end - start))      # Do the "work" on my part of it.
  ptr <- new_data(data)                            # Create the C++ version of my version

  mpi_time <- -(get_mpi_time())                    # Start the mpi stop-watch
  mpi_all_reduce(ptr)                              # Communicate between processes - see later
  mpi_time <- mpi_time + get_mpi_time()            # Stop the mpi stop-watch

  data <- get_data(ptr)                            # Copy the updated data back to an R vector
  local_time <- local_time + get_mpi_time()        # Stop the local stop-watch
  local_time <- local_time - mpi_time              # Remove mpi time from local.

  if (rank == 0) {
    message(sprintf("Size %s, local_time = %s, mpi_time = %s, total=%s",
                     size, local_time, mpi_time, local_time + mpi_time))
  }

  end_mpi()                                                      # All done
}
```

We need to implement the `mpi_all_reduce` function, which will wrap around
[MPI_Allreduce](https://www.mpich.org/static/docs/v3.3/www3/MPI_Allreduce.html). 
In `data/rmpi.h` we declare:-

```
#include <vector>

void mpi_all_reduce(std::vector<double>* data);
```

and we implement it in `data/rmpi.cpp` thus :-

```
[[cpp11::register]]
void mpi_all_reduce(cpp11::external_pointer<std::vector<double>> ptr) {
  std::vector<double> *d = cpp11::as_cpp<cpp11::external_pointer<std::vector<double>>>(ptr).get();
  MPI_Allreduce(MPI_IN_PLACE, d->data(), d->size(), MPI_DOUBLE, MPI_SUM, MPI_COMM_WORLD);
}
```

Here we are receiving the pointer that R has, to the data that's in C++ land. 
We convert that to a pointer to actual vector, then we can pass that to 
`MPI_Allreduce`. Normally, the first argument would be a pointer to where
the outgoing data lives. The `MPI_IN_PLACE` flag is a special alternative
that tells MPI the outgoing data is already in the receive buffer (the second
argument), and to re-use that structure for receiving the result. Without that,
we would need to double our RAM usage with an extra structure for receiving the
result.

Let's run it. After building and installing the package, I ran it
locally with (for example) 
`mpiexec -n 8 Rscript -e 'mpitest:::naive_reduce()'` - 
and on our cluster using the same script from part 1, but setting 
`/numnodes` to be the same as the number of processes - one process
per computer. Running with between 1 and 8 processes :-

![Native MPI performance](/img/mpi_2_eg1.png)

Some things we can notice here :-

* The time taken to do the MPI reduction (blue) increases linearly with
  processes when run locally. We'd expect this because each process needs
  800Mb of OS RAM. Doing the reduce as effectively a RAM operation on one
  computer takes more time as the amount of RAM goes up. The local time (green) 
  also suffers in the same way, because the OS takes longer to give all the
  processes the memory they request, as the number of processes increases.
* On the multi-node runs though, the MPI work is spread across the nodes, so
  we don't get that degradation we got when we were running everything on one
  node. The local time (green) also gets better as
  we add nodes, because we really are doing less work per node. 
* However, we don't get great _efficiency_ - doubling the number of processes
  doesn't half the time taken, even when only considering the green line. This
  is mainly because of [Amdahl's law](https://en.wikipedia.org/wiki/Amdahl%27s_law) - 
  the time taken to allocate memory is included in my local time and no amount
  of parallelisation will make that faster. Further, we're not really doing
  that much work in the loop, so the sequential part of getting the memory
  is a significant chunk of the total time. That limits how much speed-up
  we could ever achieve.

# Lightening the load

What if we relax the problem a little. Suppose instead of all processes
needing all of the results back, only process zero needs the assembled
bulk. All the other processes could then only allocate memory for the 
data they create, and contribute just that to the MPI call.

The new function looks like this :-

```
gather <- function() {
  start_mpi()                                       # Start up MPI
  rank <- get_mpi_rank()                            # Who am I
  size <- get_mpi_size()                            # How big is my family?
  local_time <- -(get_mpi_time())

  n <- (100000000 %/% size) * size                  # Ensure n % size = 0

  each <- n / size
  start <- 1 + (rank * each)
  end <- min(start + (each - 1), n)

  send_data <- runif(1 + (end - start))            # My data to send
  send_ptr <- new_data(send_data)                  # Make C++ data pointer

  recv_data <- if (rank == 0) rep(0, n) else 0     # Only make big array 
  recv_ptr <- new_data(recv_data)                  # on rank 0

  mpi_time <- -(get_mpi_time())
  mpi_gather_to_zero(send_ptr, recv_ptr)           # Gather in recv_ptr
  mpi_time <- mpi_time + get_mpi_time()
  
  recv_data <- get_data(recv_ptr)                  # Update R version of recv data

  local_time <- (local_time + get_mpi_time()) - mpi_time
  
  if (rank == 0) {
    message(sprintf("Size %s, mean = %s, local_time = %s, mpi_time = %s, total=%s",
                    size, mean(recv_data), local_time, mpi_time, local_time + mpi_time))
  }
  end_mpi()
}
```

We define our `mpi_gather_to_zero` function (which wraps [MPI_Gather](https://www.mpich.org/static/docs/v3.3/www3/MPI_Gather.html)),
in `src/rmpi.h` :-

```
void mpi_gather_to_zero(cpp11::external_pointer<std::vector<double>> send,
                        cpp11::external_pointer<std::vector<double>> recv);

```

and implement it in `src/rmpi.cpp` :-
```
[[cpp11::register]]
void mpi_gather_to_zero(cpp11::external_pointer<std::vector<double>> send,
                               cpp11::external_pointer<std::vector<double>> recv) {

  std::vector<double> *s = cpp11::as_cpp<cpp11::external_pointer<std::vector<double>>>(send).get();
  std::vector<double> *r = cpp11::as_cpp<cpp11::external_pointer<std::vector<double>>>(recv).get();

  MPI_Gather(s->data(), s->size(), MPI_DOUBLE,
             r->data(), s->size(), MPI_DOUBLE, 0, MPI_COMM_WORLD);

}
```

The `MPI_Gather` call assumes all the nodes will contribute the
same number of bytes - hence the hack earlier to ensure `n` was exactly
divisible by `size`. A purer solution would use another function
[MPI_Gatherv](https://www.mpich.org/static/docs/v3.3/www3/MPI_Gatherv.html),
that allows processes to send different amounts of data, as long as they all
agree beforehand how much each process will send.

![Native MPI performance](/img/mpi_2_eg2.png)

And this immediately has the look of something more reasonable. MPI time
is lower because we're doing less communication, and the scaling is no longer
messed up by the overheads of getting so much memory. A larger fraction of
the run-time is now parallelisable.

We still don't get much efficiency; doubling the processors doesn't half
the total time - in fact we're nowhere near that - but at least timing no longer 
gets worse as we add processors! We just need to be giving the processes more
work they can do at the same time.

# Some performance thoughts

The run on my desktop is actually faster than the job on the HPC cluster node. 
Server processors are often slower than desktops for single core jobs; 
large RAM, core-count and I/O options are the HPC core strengths. 
Ignoring MPI for a moment, we generally get the
best scalability on HPC if we run lots of independent processes on the same node - 
such as running the same job many times with different seeding - or 
a process that tries to use many cores, such as a large individual-based
model where people can be modelled somewhat simultaneously.

The jobs where MPI provides the most benefit might be those where splitting
a geographical space across different nodes is helpful, with parallel work 
in each subset. In the past, MPI enabled very large RAM jobs to spread
across nodes; larger, cheaper machines mean few problems really require that 
approach now, but even so, an individual-based spatial model split into a region
per node, with occasional communication between regions, makes a good application 
for MPI, using both multiple nodes and cores.

# What next?

Next time, we should have a look at hybrid MPI, where we're using both multiple
nodes, and multiple cores within each node. We could compare the
performance of the "within-node" MPI processes to OpenMP, and see how we
get on using threads and shared memory rather than processes.

---

[^1]: The return type is double; the actual resolution of the clock can be queried with `MPI_Wtick()`, 
       which on my computer is `1e-07` seconds.
[^2]: The arbitrary origin is also different across processes. We don't mind that here, but if we wanted that synchronised for some reason, then we could say:
       `MPI_Comm_set_attr(MPI_COMM_WORLD, MPI_WTIME_IS_GLOBAL,  (void *) 1)`
