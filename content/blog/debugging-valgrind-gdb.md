---
title: "Debugging memory errors with valgrind and gdb"
author: Rich FitzJohn
date: 2021-06-10
tags:
 - dust
 - R
 - debugging
---

Many R packages use C or C++ code to power performance-critical sections of code. These langauges are easy to shoot yourself in the foot with, as seemingly innocuous code may cause crashes (or just junk output) by reading from memory that is uninitialised or out of range.  There are a couple of tools for helping diagnose this sort of issue:

* "valgrind" is great for tracking down is sort of error as it highlights invalid memory accesses
* "gdb" can be used to step through a program, or inspect the internal state after a crash

We've already written about debugging R packages with valgrind and gdb separately [here](https://reside-ic.github.io/blog/debugging-and-fixing-crans-additional-checks-errors/). This post shows how to use them together so that you can use gdb to inspect the state of a program at the point where valgrind has noticed that there's an error.  The process is a bit weird, but does work!  NB: this will likely only work on Linux (not Windows or macOS).

## The problem

We noticed that as of 0.9.3 of `dust` we had a `std::bad_alloc` error when running models with the `float` type (rather than `double`). After a bit of narrowing it down we managed to reduce the problem to this bit of code[^1]:

```r
sirs <- dust::dust_example("sirs")
pars <- list(beta = 0.2, gamma = 0.1, alpha = 0.1, freq = 4)
end <- 150 * 4
steps <- seq(0, end, by = 4)
ans <- sirs$new(pars, 0, 1, seed = 1L)$simulate(steps)
dat <- data.frame(step = steps[-1],
                  date = steps[-1] / 4,
                  incidence = ans[4, 1, -1])
dat_dust <- dust::dust_data(dat, "step")

path_sirs <- system.file("examples/sirs.cpp", package = "dust")
sirs_gpu <- dust::dust(path_sirs, gpu = FALSE, real_t = "float")

set.seed(1)

mod <- sirs_gpu$new(list(), 0, 100, seed = 42L)
mod$set_data(dat_dust)
for (i in 1:20) {
  message(i)
  mod$reset(list(), 0)
  mod$filter()
}
```

This will crash deterministically on the 18th iteration through the loop.  Once we could reliably reproduce the error, we could see from valgrind where the error was coming from (running the script above with `R -d valgrind -f script.R`):

```
==70753==    at 0x14387DAB: void dust::filter::resample_weight<float>(std::vector<float, std::allocator<float> >::const_iterator, unsigned long, float, unsigned long, __gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >) (filter_tools.hpp:20)
==70753==    by 0x1437D28A: dust::Dust<sirs>::resample(std::vector<float, std::allocator<float> > const&, std::vector<unsigned long, std::allocator<unsigned long> >&) (dust.hpp:420)
==70753==    by 0x143802A3: std::vector<sirs::real_t, std::allocator<sirs::real_t> > dust::filter::filter<sirs>(dust::Dust<sirs>*, dust::filter::filter_state_host<sirs::real_t>&, bool, std::vector<unsigned long, std::allocator<unsigned long> >) (filter.hpp:59)
==70753==    by 0x14376629: cpp11::writable::r_vector<double> dust::r::run_filter<sirs, dust::filter::filter_state_host<float> >(dust::Dust<sirs>*, cpp11::sexp&, cpp11::sexp&, std::vector<unsigned long, std::allocator<unsigned long> >&, bool) (interface.hpp:442)
==70753==    by 0x1436C04C: cpp11::sexp dust::r::dust_filter<sirs, 0>(SEXPREC*, bool, cpp11::sexp, bool) (interface.hpp:475)
==70753==    by 0x14360D0B: dust_sirs_filter(SEXPREC*, bool, cpp11::sexp, bool) (dust.cpp:262)
==70753==    by 0x1435CAF6: _sirsbe1444bc_dust_sirs_filter (cpp11.cpp:117)
```

The top-left function there (`dust::filter::resample_weight`) looks like this:

```cpp
template <typename real_t>
void resample_weight(typename std::vector<real_t>::const_iterator w,
                     size_t n, real_t u, size_t offset,
                     typename std::vector<size_t>::iterator idx) {
  const real_t tot = std::accumulate(w, w + n, static_cast<real_t>(0));
  real_t ww = 0.0, uu = tot * u / n, du = tot / n;

  size_t j = offset;
  for (size_t i = 0; i < n; ++i) {
    while (ww < uu) {
      ww += *w;
      ++w;
      ++j;
    }
    uu += du;
    *idx = j == 0 ? 0 : j - 1;
    ++idx;
  }
}
```

and line 20 is the line with `ww += *w;` (see [the source](https://github.com/mrc-ide/dust/blob/v0.9.3/inst/include/dust/filter_tools.hpp#L20]).

The problem was, it is not really obvious what is wrong at that point, or why it might be being triggered only when run with `float` version of that template.  We wanted to be able to inspect the values of variables at the point of the error.

This is documented in [the valgrind docs](https://valgrind.org/docs/manual/manual-core-adv.html#manual-core-adv.gdbserver), and I'd done it a number of years ago.  First, start valgrind up with the argument `--vgdb-error=0` which starts some sort of server process that gdb can connect to, and sets it up to throw a signal on the first memory error:

```
R -d 'valgrind --vgdb-error=0' -f script.R
```

This prints the next instruction:

```
==72681== Memcheck, a memory error detector
==72681== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==72681== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==72681== Command: /usr/lib/R/bin/exec/R -f script.R
==72681==
==72681== (action at startup) vgdb me ...
==72681==
==72681== TO DEBUG THIS PROCESS USING GDB: start GDB like this
==72681==   /path/to/gdb /usr/lib/R/bin/exec/R
==72681== and then give GDB the following command
==72681==   target remote | /usr/lib/x86_64-linux-gnu/valgrind/../../bin/vgdb --pid=72681
==72681== --pid is optional if only one valgrind process is running
==72681==
```

which I followed by running, in a second terminal window

```
gdb /usr/lib/R/bin/exec/R
```

then at the gdb prompt

```
target remote | vgdb --pid=72681
```

(the instructions produced by valgrind gave me an incorrect path to vgdb but omitting the path fixed that).

Then at the gdb prompt run `continue`:

```
$ gdb /usr/lib/R/bin/exec/R
GNU gdb (Ubuntu 9.2-0ubuntu1~20.04) 9.2
Copyright (C) 2020 Free Software Foundation, Inc.
License GPLv3+: GNU GPL version 3 or later <http://gnu.org/licenses/gpl.html>
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.
Type "show copying" and "show warranty" for details.
This GDB was configured as "x86_64-linux-gnu".
Type "show configuration" for configuration details.
For bug reporting instructions, please see:
<http://www.gnu.org/software/gdb/bugs/>.
Find the GDB manual and other documentation resources online at:
    <http://www.gnu.org/software/gdb/documentation/>.

For help, type "help".
Type "apropos word" to search for commands related to "word"...
Reading symbols from /usr/lib/R/bin/exec/R...
(No debugging symbols found in /usr/lib/R/bin/exec/R)
(gdb) target remote | vgdb --pid=72681
Remote debugging using | vgdb --pid=72681
relaying data between gdb and process 72681
warning: remote target does not support file transfer, attempting to access files from local filesystem.
Reading symbols from /lib64/ld-linux-x86-64.so.2...
Reading symbols from /usr/lib/debug//lib/x86_64-linux-gnu/ld-2.31.so...
0x0000000004001100 in _start () from /lib64/ld-linux-x86-64.so.2
(gdb) continue
Continuing.
```

At this point, the program starts running in the first terminal window, eventually hitting the memory error from before and saying

```
==72681== Invalid read of size 4
==72681==    at 0x14387DAB: void dust::filter::resample_weight<float>(std::vector<float, std::allocator<float> >::const_iterator, unsigned long, float, unsigned long, __gnu_cxx::__normal_iterator<unsigned long*, std::vector<unsigned long, std::allocator<unsigned long> > >) (filter_tools.hpp:20)
==72681==    by 0x1437D28A: dust::Dust<sirs>::resample(std::vector<float, std::allocator<float> > const&, std::vector<unsigned long, std::allocator<unsigned long> >&) (dust.hpp:420)
==72681==    by 0x143802A3: std::vector<sirs::real_t, std::allocator<sirs::real_t> > dust::filter::filter<sirs>(dust::Dust<sirs>*, dust::filter::filter_state_host<sirs::real_t>&, bool, std::vector<unsigned long, std::allocator<unsigned long> >) (filter.hpp:59)
==72681==    by 0x14376629: cpp11::writable::r_vector<double> dust::r::run_filter<sirs, dust::filter::filter_state_host<float> >(dust::Dust<sirs>*, cpp11::sexp&, cpp11::sexp&, std::vector<unsigned long, std::allocator<unsigned long> >&, bool) (interface.hpp:442)
[...snip...]
==72681==
==72681== (action on error) vgdb me ...
```

Control was then passed back to the second window running gdb:

```
Program received signal SIGTRAP, Trace/breakpoint trap.
dust::filter::resample_weight<float> (w=1.1479437e-41, n=100, u=0.999940574, offset=0, idx=99)
    at /home/rfitzjoh/lib/R/library/dust/include/dust/filter_tools.hpp:20
20	      ww += *w;
(gdb)
```

and all the usual gdb tricks work:

```
(gdb) print u
$1 = 0.999940574
(gdb) print du
$2 = 0.602285564
(gdb) print uu
$3 = 60.2285919
(gdb) print ww
$4 = 60.2285576
```

Eventually I worked out from this (and from pulling the values into a small standalone C++ program) that we were accumulating round-off error by incrementing `uu` by `du` each time, which could be avoided if we computed `uu` as `uu0 + i * du`.  I also added a fix to prevent us ever trying to move `w` past the end of the iterator, or to return a value of `j` greater than `n` (one of which eventually caused the `bad_alloc`). The fix is [here](https://github.com/mrc-ide/dust/pull/238)

Usually with `valgrind` it's enough to see where the error occurs to find the memory issue. The approach here is useful when you need more information, and while awkward felt nice enough once I'd remembered how to do it. Hopefully next time I need to do this I'll remember this blog post exists.

[^1]: This stage is a bit mysterious but not very interesting - I noticed the problem on a larger set of code that was doing some benchmarking with models that used `float`s for the `real_t`.  With a crash that was reliable, I removed lines of code and calls to other packages until I had a small self-contained bit of code. This makes working with valgrind much easier.
