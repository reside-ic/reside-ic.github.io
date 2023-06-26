---
author: "Wes Hinsley"
date: 2023-06-22
title: MPI from R - Part One - The Basics
best: false
tags:
 - R
 - MPI
 - HPC
---

[MPI](https://en.wikipedia.org/wiki/Message_Passing_Interface) is a 
standard for allowing a team of processes to solve a problem together. Various
implementations of that standard exist; [MPICH](https://www.mpich.org/) is
perhaps the most well known. [Microsoft MPI](https://github.com/Microsoft/Microsoft-MPI)
mimics MPICH on Windows, as does [Intel MPI](https://www.intel.com/content/www/us/en/developer/tools/oneapi/mpi-library.html#gs.1crzpx)
on various platforms. Typically you'd then include these libraries in projects 
written in C, C++, or Fortran.

Furthermore, recent releases of [Rtools](https://cran.r-project.org/bin/windows/Rtools/)
have included support for Microsoft MPI. My plan is a couple of blogs on how to get this
working, some exploration of performance, and some testing / CI. I'll include 
nodes on how to for what's needed on Windows, linux or Mac to write and build the package, 
but when describing running on multi-nodes, I'll be limited to our departmental Microsoft
cluster. Hopefully not many changes should be needed to the launch scripts for running 
with other cluster platforms.

# First steps.

First we need an MPI library. On Windows, installing
the latest [Rtools](https://cran.r-project.org/bin/windows/Rtools/) and
[MS-MPI](https://learn.microsoft.com/en-us/message-passing-interface/microsoft-mpi)
will do it. Test by running `mpiexec` in a terminal, and on Windows check that it really is
Microsoft's `mpiexec`. Intel's has the same name, and comes with the Intel C++ compiler, but
Microsoft's must come first in your path, as we need the `mpiexec` executable we use
to match the library in Rtools.

On linux, `sudo apt-get install mpich.` is enough; on Mac, [download MPICH](http://www.mpich.org/downloads/) 
and it will install with homebrew. 

# What defines an MPI program

An MPI program involves a number of processes, all running the same single executable code.
The processes would traditionally have been on different computers - one process on each - 
but they can also be stacked on the same compute node, or spread with some number of 
processes across some number of nodes. 

The program must have exactly one call to `MPI_Init`, during which all the processes handshake, 
and by consensus they decide their ids - integers starting at zero - for each process in the 
family. The id is known as the _rank_, and the number of processes is the _size_. After that
initialise step, each process knows its own rank, and can use it to decide a 
subset of the total work to be done for example.

Finally, exactly one `MPI_Finalize` call needs to happen (on every process) when all the MPI 
work is finished, if you want a neat and successful exit.

# Parallel Hello World

I'm going to make an R package called `mpitest`. It's 
going to use the cpp11 package, so in the `DESCRIPTION` file, I am including
```
LinkingTo:
    cpp11
```

and conventionally, `R/zzz.R` contains:

```
##' @useDynLib mpitest, .registration = TRUE
NULL
```

Here come the bits of C++ code, which are wrappers around some MPI functions, so we can call them from R.
We'll firstly define a header, `src/rmpi.h` for the MPI functions we'll wrap.
```
#pragma once

#include <mpi.h>

void start_mpi();
int get_mpi_size();
int get_mpi_rank();
void end_mpi();
```

The implementations of these, using the cpp11 package annotations go in `src/rmpi.cpp`.
See the [MPI library](https://www.mpich.org/static/docs/v3.3/www3/)
for the functions we are wrapping.

```
#include "rmpi.h"

[[cpp11::register]]
void start_mpi() {
  MPI_Init(NULL, NULL);
}

[[cpp11::register]]
int get_mpi_size() {
  int size;
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  return size;
}

[[cpp11::register]]
int get_mpi_rank() {
  int rank;
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  return rank;
}

[[cpp11::register]]
void end_mpi() {
  MPI_Finalize();
}
```

Now in `R/source.R`, we'll write a quick test:

```
hello <- function() {
  start_mpi()
  rank <- get_mpi_rank()
  size <- get_mpi_size()
  name <- Sys.info()[["nodename"]]
  message(sprintf("Hello! I am %s (%s/%s)", name, rank, size))
  end_mpi()
}
```

Lastly, we need to tell the compiler to include MPI in `src/Makevars.win` :
```
PKG_CXXFLAGS = -lmsmpi
PKG_LIBS = -lmsmpi
```

For linux or MAC, we need slightly tweaked versions of `src/Makevars`, so 
this hack as `/configure` will work for both:

```
#!/bin/bash

#make the Makevars file
if [ ! -e "./src/Makevars" ]; then
touch ./src/Makevars
fi

#if mac
if [[ `uname` -eq Darwin ]] ; then

echo "PKG_CXXFLAGS = -I/usr/include/x86_64-linux-gnu/mpich" > ./src/Makevars
echo "PKG_LIBS = -lmpich" >> ./src/Makevars

#if linux
elif [[ `uname` -eq Linux ]] ;then

echo "PKG_CXXFLAGS = -I/usr/include/x86_64-linux-gnu/mpich -lmpich" > ./src/Makevars
echo "PKG_LIBS = -lmpich" >> ./src/Makevars

fi
```

Now if we document, build and install the package, we can test it 
from the command-line or a terminal:

```
> mpiexec -n 4 Rscript -e mpitest:::hello()
Hello! I am WES-COMPUTER (0/4)
Hello! I am WES-COMPUTER (1/4)
Hello! I am WES-COMPUTER (3/4)
Hello! I am WES-COMPUTER (2/4)
```

Here, we are running the four processes on the same local machine, and we 
get text printed in a random order, as we'd expect. 

# With Multiple Nodes

If we want to spread the execution across different nodes, then we need a 
cluster that is MPI-aware, that can launch the jobs on multiple nodes, and
tell the nodes about each other's existence somehow. Our MS-HPC cluster
will do this for us; here's the script we'll ask the cluster nodes to run,
which I'll call `mpiwes.bat`, and I'll save in a network folder called 
`\\homes\wes\test` which the cluster nodes can see.

``` 
set R_LIBS=\\homes\wes\R
set R_LIBS_USER=\\homes\wes\R
call setr64_4_3_0
Rscript -e "mpitest:::hello()"

```

First I am setting environment variables to point to the repo where my
`mpitest` package is installed. The third line is then a helper on our cluster
to add the R version of our choice to the path. Lastly in this tiny example, 
we're calling the function we want inline as a parameter to Rscript.

To submit the job, with for example 8 processes across 2 nodes, I'd use the 
MS-HPC job submitter tool along these lines:-

```
job submit /scheduler:headnode /jobtemplate:template /numnodes:2 /singlenode:false 
           /stdout:mpiout.txt /stderr:mpierr.txt /workdir:\\homes\wes\test mpiexec -n 8 mpiwes.bat
```

The output of Rscript ends up (non-intuitively) sent to `stderr` (mpierr.txt), which after the job has run contains:

```
Hello! I am HPC-093 (2/8)
Hello! I am HPC-093 (4/8)
Hello! I am HPC-093 (0/8)
Hello! I am HPC-093 (6/8)
Hello! I am HPC-095 (1/8)
Hello! I am HPC-095 (3/8)
Hello! I am HPC-095 (7/8)
Hello! I am HPC-095 (5/8)
```

So, the `8` processes we asked for were spread evenly over `2` nodes which the cluster
assigned to our job. As it happens, the two nodes actually had 32-cores, but the cluster
can only give us units of whole nodes. So we made pretty poor use of those nodes, reserving
32 all cores but only using 4 of them. Perhaps we could have utilised them better by using 
`mpiexec -n 64` - if we knew in advance that the nodes each would have 32 cores.

# End of Part One

Like all MPI work, it feels a little clunky to get started, but it works well enough 
to be useful. We can call MPI functions in both the cpp files, and R files pretty
simply, which is a good start.

Also note in the examples above, the processes are all dumping their output
to one file. It works for now because the amount of text is small, but for larger jobs, we
should output separate files for each process, otherwise the text will eventually get
interleaved in an untidy, unordered way. For now, file buffering on write is saving us.

In part two, I'll explore how data can be shared between processes, local or remote, and 
some of the performance considerations of that.
