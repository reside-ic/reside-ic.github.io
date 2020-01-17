---
title: "Debugging and Fixing CRAN's 'Additional Checks' errors"
date: 2020-01-16
tags:
 - dde
 - R
---

R packages that are published on CRAN are tested every night on a variety of platforms and on the development version of R to ensure that they continue to work.  In addition, packages that contain compiled code (C, C++ or Fortran) are put through a raft of additional checks to ensure that the compiled code will not cause R to crash.  Once an issue is found, the package maintainer gets an email and usually a fairly short window to fix the package before it is removed from CRAN.  However, replicating the error locally can require installation of all sorts of esoteric tools (and a copy of the development version of R from source) and it's not always obvious how or where to start.

This blog post documents the process I used in clearing three issues from our [`dde`](https://mrc-ide.github.io/dde/) package (which implements a simple solver for delay differential equations - the astute blog reader may recognise it from [previous debugging efforts](https://reside-ic.github.io/blog/debugging-at-the-edge-of-reason/)).

Package authors (or at least I) typically find out about these problems when getting an email from CRAN but they may have been live for some time and are listed in an "Additional issues" section on a package's [check page](https://cran.r-project.org/web/checks/check_results_dde.html) - however, this is shown only when there is a problem!

This blog post also serves as a place for me to find this information next time I need it and is written with the hope that it helps someone else with their debugging and package repairing chores.  It was written while I debugged each problem, and is probably only of interest if you face a similar problem, in which case I hope the verbosity is useful.

There are three sections to this blog post - "Undefined behaviour", "valgrind" and "rchk" corresponding to three of the possible additional checks.  However, [there are more types still](https://cran.r-project.org/web/checks/check_issue_kinds.html), including testing with extremely new versions of gcc, alternative linear algebra implementations, and other diagnostic tools.

## Undefined behaviour

The package had an issue where a unit test was doing something that was [Undefined Behaviour](https://en.wikipedia.org/wiki/Undefined_behavior).  The information we get from CRAN to debug this error is:

```
> test_check("dde")
dopri.c:745:21: runtime error: -12.7138 is outside the range of representable values of type 'unsigned long'
    #0 0x7f030d7b378d in dopri_find_time /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri.c:745:21
    #1 0x7f030d7b387e in ylag_1 /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri.c:769:24
    #2 0x7f030d2c51e0 in ylag_1 /data/gannet/ripley/R/packages/tests-clang-SAN/dde.Rcheck/dde/include/dde/dde.c:15:10
    #3 0x7f030d2c51e0 in seir /tmp/RtmpNf9ol1/working_dir/RtmpgC6Usd/file82255939016e/seir.c:13:18
    #4 0x7f030d7afca4 in dopri_eval /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri.c:822:3
    #5 0x7f030d7b89ef in dopri5_step /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri_5.c:75:3
    #6 0x7f030d7abbfe in dopri_step /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri.c:253:5
    #7 0x7f030d7abbfe in dopri_integrate /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/dopri.c:377:5
    #8 0x7f030d7d6118 in r_dopri /data/gannet/ripley/R/packages/tests-clang-SAN/dde/src/r_dopri.c:176:3
    #9 0x6f93f9 in R_doDotCall /data/gannet/ripley/R/svn/R-devel/src/main/dotcode.c:744:17
    ...
    #276 0x52349e in do_lapply /data/gannet/ripley/R/svn/R-devel/src/main/apply.c:70:8

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior dopri.c:745:21 in
══ testthat results  ═══════════════════════════════════════════════════════════
[ OK: 507 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 0 ]
```

(eliding just the uninformative part of the stack trace).  So we know where in the C source the error comes from (`dopri.c:745`) but not the values that are passed to that code to trigger it.  And to be sure that we've eliminated it we need to be able to replicate it locally.

To trigger this, I used the [`wch1/r-debug`](https://hub.docker.com/r/wch1/r-debug) docker container as I've had success with this in the past.  There are also containers from the [rocker project](https://www.rocker-project.org/) that a similar approach will likely work with, such as [`rocker/r-devel-ubsan-clang`](https://hub.docker.com/r/rocker/r-devel-ubsan-clang).

First, I started the container with

```
docker run -v $PWD:/src:ro -it --rm --security-opt seccomp=unconfined wch1/r-debug
```

then, in that container, I prepared the R library using the R binary that was built with the undefined behaviour checkers enabled:

```
RDcsan -e 'install.packages(c("deSolve", "knitr", "ring", "microbenchmark", "rmarkdown", "testthat", "devtools", "roxygen2"))'
cp -r /src /dde
```

Running

```
RDcsan CMD INSTALL --preclean --install-tests /dde
RDcsan -e 'tools::testInstalledPackage("dde")'
cat dde-tests/testthat.Rout
```

showed the same output as CRAN reported - confirming I could replicate the error but still obscuring which test triggered it.  In the end I ran the tests with the most verbose reporter:

```
RDcsan -e 'devtools::test("dde", reporter = testthat::LocationReporter)'
```

which produces

```
Start test: failure to fetch history
dopri.c:745:21: runtime error: -12.7138 is outside the range of representable values of type 'unsigned long'
    #0 0x7f472e7aa95a in dopri_find_time /dde/src/dopri.c:745:21
    #1 0x7f472e7ab097 in ylag_1 /dde/src/dopri.c:769:24
    #2 0x7f472cded83a in ylag_1 /dde/inst/include/dde/dde.c:15:10
...
    #250 0x7f474672e010 in getvar /tmp/r-source/src/main/eval.c:5128:14

SUMMARY: UndefinedBehaviorSanitizer: undefined-behavior dopri.c:745:21 in
  test-dde.R#269:1 [success]
End test: failure to fetch history
```

so we know where the error is triggered from!  (Note that the UB checker only seems to report the error the *first time* it occurs in a session - it's quite possible this is tuneable though.)

With a little surgery, a standalone script that reproduces the error is:

```
res <- dde:::shlib(system.file("examples/seir.c", package = "dde"), "dde_")
y0 <- c(1e7 - 1, 0, 1, 0)
times <- seq(0, 30, length.out = 301)
dde::dopri(y0, times, "seir", numeric(),
           atol = 1e-7, rtol = 1e-7, n_history = 2L,
           dllname = "dde_seir", return_history = FALSE)
```

and we can trigger the error in the instrumented copy of R by running `RDcsan -f /src/bug.R` in ~12s which is a bit less tedious than running the full suite. However, most of the debugging can be done in the plain copy.  I compiled the package with optimisation turned off and debugging symbols enabled (`CFLAGS = -g -O0`), ran R with `R -d gdb` and created a breakpoint with `break dopri.c:745` after loading the package.

The relevant bit of C looks like:

```
  size_t idx0 = 0;
  if (n > 0) {
    const double
      t0 = ((double*) ring_buffer_tail(obj->history))[idx_t],
      t1 = ((double*) ring_buffer_tail_offset(obj->history, n - 1))[idx_t];
    idx0 = min_size((t - t0) / (t1 - t0) / (n - 1), n - 1);
  }
```

This is an optimisation to seed a binary search for a value close to `t` in an array of values from `t0` to `t1` - we assume that the values between `t0` and `t1` are roughly evenly spaced and linearly interpolate between them to get a likely enough index for `t`, which we store as `idx0`.

When the undefined behaviour error is triggered (the second assignment to `idx0`), we have (approximately) `t0 = 11`, `t1 = 12` and `t = 0.02` which falls outside of the range of times, so the expression `(t - t0) / (t1 - t0) / (n - 1)` is negative and that's the undefined behaviour because it falls outside of the valid values for a `size_t` (typically an `unsigned long`), which this expression is eventually cast as.

We can guard against this either by checking that `t` lies within `(t0, t1)` before doing the second assignment:

```
  size_t idx0 = 0;
  if (n > 0) {
    const double
      t0 = ((double*) ring_buffer_tail(obj->history))[idx_t],
      t1 = ((double*) ring_buffer_tail_offset(obj->history, n - 1))[idx_t];
    if ((t0 - t) * (t1 - t) < 0) {
      idx0 = (t - t0) / (t1 - t0) / (n - 1);
    }
  }
```

With this fix in place, the UBSAN checks pass without incident.  See [`8c384bb`](https://github.com/mrc-ide/dde/commit/8c384bb8bcc0f2513fa955ce4951b65cefb0dfa1) for details.

## Valgrind

[Valgrind](https://valgrind.org/) finds memory errors and is one of my favourite tools for working out why something crashes.  My (probably grossly oversimplified) understanding is that it runs a program with a layer that checks all memory accesses for correctness (alignment, bounds etc).  Unsurprisingly this makes things very slow to run.  The information on the CRAN page was:

```
==42439== Memcheck, a memory error detector
==42439== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==42439== Using Valgrind-3.15.0 and LibVEX; rerun with -h for copyright info
==42439== Command: /data/blackswan/ripley/R/R-devel-vg/bin/exec/R -f testthat.R --restore --save --no-readline --vanilla
==42439==

...

> library(testthat)
> library(dde)
>
> test_check("dde")
==42439== Invalid read of size 8
==42439==    at 0x48C5A50: dopri_data_reset (packages/tests-vg/dde/src/dopri.c:196)
==42439==    by 0x48C6906: dopri_integrate (packages/tests-vg/dde/src/dopri.c:294)
==42439==    by 0x48CB338: r_dopri (packages/tests-vg/dde/src/r_dopri.c:176)
==42439==    by 0x49B695: R_doDotCall (svn/R-devel/src/main/dotcode.c:744)
==42439==    by 0x49BFD4: do_dotcall (svn/R-devel/src/main/dotcode.c:1280)
==42439==    by 0x4D181C: bcEval (svn/R-devel/src/main/eval.c:7054)
==42439==    by 0x4E8197: Rf_eval (svn/R-devel/src/main/eval.c:688)
==42439==    by 0x4E9D56: R_execClosure (svn/R-devel/src/main/eval.c:1853)
==42439==    by 0x4EAB33: Rf_applyClosure (svn/R-devel/src/main/eval.c:1779)
==42439==    by 0x4E8363: Rf_eval (svn/R-devel/src/main/eval.c:811)
==42439==    by 0x4ECD01: do_set (svn/R-devel/src/main/eval.c:2920)
==42439==    by 0x4E85E4: Rf_eval (svn/R-devel/src/main/eval.c:763)
==42439==  Address 0x195135c0 is 1,760 bytes inside a block of size 7,960 alloc'd
==42439==    at 0x483880B: malloc (/builddir/build/BUILD/valgrind-3.15.0/coregrind/m_replacemalloc/vg_replace_malloc.c:309)
==42439==    by 0x5223E0: GetNewPage (svn/R-devel/src/main/memory.c:946)
==42439==    by 0x52418B: Rf_allocVector3 (svn/R-devel/src/main/memory.c:2784)
==42439==    by 0x4A4388: Rf_allocVector (svn/R-devel/src/include/Rinlinedfuns.h:593)
==42439==    by 0x4A4388: duplicate1 (svn/R-devel/src/main/duplicate.c:345)
==42439==    by 0x4E893F: EnsureLocal (svn/R-devel/src/main/eval.c:2048)
==42439==    by 0x4D2AE5: bcEval (svn/R-devel/src/main/eval.c:7146)
==42439==    by 0x4E8197: Rf_eval (svn/R-devel/src/main/eval.c:688)
==42439==    by 0x4E9D56: R_execClosure (svn/R-devel/src/main/eval.c:1853)
==42439==    by 0x4EAB33: Rf_applyClosure (svn/R-devel/src/main/eval.c:1779)
==42439==    by 0x4E8363: Rf_eval (svn/R-devel/src/main/eval.c:811)
==42439==    by 0x178CF77B: C_deriv_func (/tmp/RtmpTufyR0/R.INSTALLb7ae410bb7bc/deSolve/src/call_lsoda.c:127)
==42439==    by 0x179012CA: dstoda_ (/tmp/RtmpTufyR0/R.INSTALLb7ae410bb7bc/deSolve/src/opkda1.f:4200)
==42439==
══ testthat results  ═══════════════════════════════════════════════════════════
[ OK: 507 | SKIPPED: 0 | WARNINGS: 0 | FAILED: 0 ]
```

(eliding only the R startup and valgrind summary).  Again, not a great deal to work with!

A copy of R instrumented with valgrind (improving debugging a bit) is also in the same docker image as above:

```
docker run -v $PWD:/src:ro -it --rm --security-opt seccomp=unconfined wch1/r-debug
```

```
RDvalgrind -e 'install.packages(c("deSolve", "knitr", "ring", "microbenchmark", "rmarkdown", "testthat", "devtools", "roxygen2"))'
cp -r /src /dde
```

Unfortunately, and surprisingly, running:

```
RDvalgrind CMD INSTALL --preclean --install-tests /dde
RDvalgrind -d valgrind -e 'tools::testInstalledPackage("dde")'
cat dde-tests/testthat.Rout
```

did not yield the error.  But with a bit of poking based on the `Command:` line in the above valgrind output I got some success with:

```
(cd dde/tests && RDvalgrind -d valgrind -f testthat.R --no-readline --vanilla)
```

which shows the invalid read, alongside some less interesting output.  Using the `LocationReporter` again was better still:

```
RDvalgrind -d valgrind -e 'devtools::test("dde", reporter = testthat::LocationReporter)'
```

showed

```
Start test: critical times
  test-ode.R#224:1 [success]
  test-ode.R#225:1 [success]
  test-ode.R#226:1 [success]
  test-ode.R#228:1 [success]
  test-ode.R#233:1 [success]
==5262== Invalid read of size 8
==5262==    at 0x180FD558: dopri_data_reset (dopri.c:196)
==5262==    by 0x180FD8CF: dopri_integrate (dopri.c:294)
==5262==    by 0x1810481B: r_dopri (r_dopri.c:176)
==5262==    by 0x4F30D5F: R_doDotCall (dotcode.c:744)
==5262==    by 0x4F3A8E5: do_dotcall (dotcode.c:1280)
==5262==    by 0x4F8AD8C: bcEval (eval.c:7054)
==5262==    by 0x4F7670A: Rf_eval (eval.c:688)
==5262==    by 0x4F79442: R_execClosure (eval.c:1853)
==5262==    by 0x4F790F6: Rf_applyClosure (eval.c:1779)
==5262==    by 0x4F76EF5: Rf_eval (eval.c:811)
==5262==    by 0x4F7D07C: do_set (eval.c:2920)
==5262==    by 0x4F76B5B: Rf_eval (eval.c:763)
==5262==  Address 0x17cde210 is 1,520 bytes inside a block of size 7,960 alloc'd
==5262==    at 0x4C2FB0F: malloc (in /usr/lib/valgrind/vgpreload_memcheck-amd64-linux.so)
==5262==    by 0x4FCAE13: GetNewPage (memory.c:946)
==5262==    by 0x4FD9ED8: Rf_allocVector3 (memory.c:2784)
==5262==    by 0x4FBE3B9: Rf_allocVector (Rinlinedfuns.h:593)
==5262==    by 0x4EBD407: do_lapply (apply.c:46)
==5262==    by 0x4FE2024: do_internal (names.c:1379)
==5262==    by 0x4F8AFFB: bcEval (eval.c:7074)
==5262==    by 0x4F7670A: Rf_eval (eval.c:688)
==5262==    by 0x4F79442: R_execClosure (eval.c:1853)
==5262==    by 0x4F790F6: Rf_applyClosure (eval.c:1779)
==5262==    by 0x4F8A9D3: bcEval (eval.c:7022)
==5262==    by 0x4F7670A: Rf_eval (eval.c:688)
==5262==
  test-ode.R#238:1 [success]
  test-ode.R#243:1 [success]
End test: critical times
```

So we again know the location of the error and can reproduce it.

Taking the same approach as above, I boiled down the test into a minimal script that could be run easily to trigger the problems:

```
target <- function(t, y, p) {
  if (t <= 1) {
    y
  } else {
    -5 * y
  }
}
tt <- seq(0, 2, length.out = 200)
res <- dde::dopri(1, tt, target, numeric(0), tcrit = rep(tt[[1]], 3))
```

which could be run like

```
RDvalgrind -d valgrind -f /src/bug-valgrind.R
```

taking about 10s, which is fast as far as using valgrind goes.  The code causing the problem was:

```
    double t0 = obj->sign * times[0];
    while (obj->sign * tcrit[obj->tcrit_idx] <= t0 &&
           obj->tcrit_idx < n_tcrit) {
      obj->tcrit_idx++;
    }
```

which is a nasty enough bit of book-keeping.  But the problem is that the `while` condition's two clauses are in the wrong order - when `obj->tcrit_idx < n_tcrit` is `false` we *really* should not be looking up `tcrit[obj->tcrit_idx]` because it is out of range, which is precisely what the "invalid read" error valgrind reported was.  The fixed code looks like

```
    double t0 = obj->sign * times[0];
    while (obj->tcrit_idx < n_tcrit &&
           obj->sign * tcrit[obj->tcrit_idx] <= t0) {
      obj->tcrit_idx++;
    }
```

and is in [`07f876a`](https://github.com/mrc-ide/dde/commit/07f876a9d71c455c5b9ee94ef6e706adb2f830d4).

## rchk

These are the results of static analysis tools (see [details on CRAN](https://raw.githubusercontent.com/kalibera/cran-checks/master/rchk/README.txt)).  There are a lot of things checked by this tool, but one of the main ones - and the one behind all the problems below - is `PROTECT`/`UNPROTECT` errors, where the package author has failed to correctly protect memory from being reclaimed by R's garbage collector.  See [this blog post by Tomas Kalibera ](https://developer.r-project.org/Blog/public/2019/04/18/common-protect-errors) for more background.

Thankfully, the information from CRAN is helpful by itself:

```
Package dde version 1.0.0
Package built using 77519/R 4.0.0; x86_64-pc-linux-gnu; 2019-12-05 05:52:35 UTC; unix
Checked with rchk version 490627e4fb8e93244230dbbd61455730aa43c328
More information at https://github.com/kalibera/cran-checks/blob/master/rchk/PROTECT.md

Suspicious call (two or more unprotected arguments) to Rf_setAttrib at r_difeq_cleanup dde/src/r_difeq.c:227
Suspicious call (two or more unprotected arguments) to Rf_setAttrib at r_dopri_cleanup dde/src/r_dopri.c:403
Suspicious call (two or more unprotected arguments) to Rf_setAttrib at r_dopri_cleanup dde/src/r_dopri.c:422

Function r_ylag
  [UP] unprotected variable r_y while calling allocating function r_indices dde/src/r_dopri.c:315
  [UP] unprotected variable r_y while calling allocating function ylag_vec dde/src/r_dopri.c:315

Function r_yprev
  [UP] unprotected variable r_y while calling allocating function r_indices dde/src/r_difeq.c:161
```

However, it is useful to recreate the errors locally so we can be sure that they are actually fixed.

To debug this I used a container created by the amazing [r-hub](https://builder.r-hub.io/) project, [`rhub/ubuntu-rchk`](https://hub.docker.com/r/rhub/ubuntu-rchk)

```
docker run --rm -it -v $PWD:/src:ro -v ~/.Rprofile:/home/docker/.Rprofile -w /home/docker rhub/ubuntu-rchk
```

Inside the container I ran:

```
R -e 'install.packages(c("deSolve", "ring"))'
cp -r /src dde
rchk.sh dde
```

which produces the same errors as observed in the report.

These changes all turned out to be fairly straightforward and unambiguous errors.  For example the code

```
    r_y = PROTECT(allocVector(REALSXP, ni));
    if (ni == 1) {
      REAL(r_y)[0] = yprev_1(step, r_index(r_idx, n));
    } else {
      r_y = allocVector(REALSXP, ni);
      yprev_vec(step, r_indices(r_idx, n), ni, REAL(r_y));
    }
```

produced the warning

```
[UP] unprotected variable r_y while calling allocating function r_indices dde/src/r_difeq.c:161
```

It turns out the second `r_y` was vestigial and should be deleted.  It was dangerous because it was not protected and the function `r_indices` did an allocation so the memory underlying this second `r_y` could have been reclaimed.

Similarly, the call

```
    setAttrib(history, install("n"), ScalarInteger(obj->n));
```

produced the warning

```
Suspicious call (two or more unprotected arguments) to Rf_setAttrib at r_difeq_cleanup dde/src/r_difeq.c:227
```

because the `SEXP` produced by `ScalarInteger(obj->n)` could have been reclaimed when the `install` is run (and these could be evaluated in any order the compiler fancies).  This was replaced with

```
    SEXP r_n = PROTECT(ScalarInteger(obj->n));
    setAttrib(history, install("n"), r_n);
```

and an additional `UNPROTECT`.  See commit [`72b7e60`](https://github.com/mrc-ide/dde/commit/72b7e60b6f4b15262d95afdda21341d0b38ea84d) for the full details.

## Conclusions

This was all a bit tedious, but these were all errors in the package that could have resulted in crashes that would have been much more tedious to debug, especially as they would likely have turned up essentially non-determinstically as R's garbage collector was triggered.  It took longer to replicate all these errors locally than to fix them, but doing this was worthwhile because it removed the guesswork as to whether they were actually fixed.
