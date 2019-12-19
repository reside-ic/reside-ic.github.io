---
author: "Wes Hinsley"
date: 2019-05-01
title: Debugging at the edge of reason
best: false
tags:
 - R
 - compilers
---

What do you do if this code...
```
printf("Before loop\n");
while ((a>0) && (b>0)) {
  printf("Inside loop\n");
  // Other loop code
}
if (a>0) printf("a>0\n");
if (b>0) printf("b>0\n");
if ((a>0) && (b>0)) printf("Both a>0 and b>0!");

```
...produces this output?
```
Before loop
a>0
b>0
Both a>0 and b>0!
```

If `a` and `b` are both above zero, then why didn't the while-loop do any
iteration; why didn't we see `Inside loop` in the output?

This was a situation we were in with
[DDE](https://github.com/mrc-ide/dde) 0.9.0, but only on Windows,
and only when compiled with 32-bit gcc. With 64-bits, or linux, the loop
behaved itself perfectly.

But this is almost the end of the story. The issue was first caught by
a test that failed in [Appveyor](https://www.appveyor.com/), which we use
for continuous integration tests in Windows. [DDE](https://github.com/mrc-ide/dde) 
is a package that *solves ordinary differential equations (ODEs), 
delay differential equations (DDEs) and discrete-time difference (or recursion) 
equations, perhaps involving delays* - and all its tests were passing
except one: about the simplest case possible, a function that always returns `1`.

```R
  deriv <- function(t, y, p) { 1 }
  dde::dopri(0, c(0, 1), deriv, 0)
```

On 64-bit, it correctly returned `(1,1)`; on 32-bit, it returned `(1,0)`.

## Primary Approaches

At first, we wondered if it was a memory issue specific to 32-bit. 
We confirmed that `sizeof(size_t)` is `4` on 32-bit, but `8` on 
64-bit, as are all pointers. Other types were the same across platforms. 
But there were no obvious violations; [Valgrind](www.valgrind.org) on linux 
picked up nothing.

Resorting to random black-box-bashing: `dde:dopri(0, c(0, 1.121), deriv, 0)`
and smaller numbers failed the test. `dde:dopri(0, c(0, 1.122), deriv, 0)` and
larger numbers all passed. Eureka? Nope - a mysterious red herring, alas.

In the real-life code, the `(a>0)` and `(b>0)` were a bit more complicated -
but not much; no functions involved, just comparisons between members of a
struct, so no sensible way they could exit the loop, and then appear
to have met the criteria for looping in retrospect, as we were seeing. 

## Secondary Flailings

The next level of desperation involved dumping every member of the object at
intervals with `Rprintf`. This revealed some apparent corruption -
surely evidence of some bad memory writes! Wrong again. This time it was
a bug in my debugging, as the object had been freed by then so could rightly
return undefined values.

However, printing everything at regular points eventually did expose a genuine
difference between platforms in one index variable; its value seemed to differ
across platforms immediately after the `while` loop above, which must have 
terminated early (or didn't get entered at all), under certain 32-bit 
circumstances. Printing things within the loop - or before it - somtimes changed
the behaviour and made things work, but it would be poor form to submit a PR 
that claims to fix a functional problem by printing a ton of waffle before-hand.

My [github commit](https://github.com/mrc-ide/dde/commits/i14_win32) titles around this 
time are telling. **Total Confusion Reigns** towards **Wits' End** and later 
a  **Deeper Confusion** that's somehow worse than the previous *total* one. Eventually, 
as hope ebbed away, the crucial summit arrived at a commit aptly named **Another bizarre effort**.

The question now moves from "why *doesn't* it work" to, "why *does* it":-

```
bool cond = (a>0) && (b>0);
while (((a>0) && (b>0)) || cond) {
  // a and b may get changed
  cond = (a>0) && (b>0);
}

```
The syntax is surely equivalent to the code at the top, if 
more wordy with some redundancy. A good PR might recommend
cleaning it up back into the code at the top. Nevertheless,
looking at `a` and `b` twice for each decision caused correct entry and exit
of the loop, and the appveyor tests passed fully.

## The Final Insult

Good programmers should be cautious to blame their compiler, as in almost every
case where suspicion falls on gcc, or Intel's or Microsoft's
compiler, eventually analysis hunts down a memory leak or bad array write, or
uninitialised variable; the compiler is shown to be correct and sane;
the programmer a bit less so (probably on both points by that time).

In this case though, gcc was to blame, and the optimised code even with `-O1` 
changed the behaviour of the loop, breaking the simple test. It didn't optimise
the loop away entirely, since all the many
other tests worked consistently throughout the saga; it caused a subtle and rare
change in behaviour - and only for 32-bits. If I had edited `%USERPROFILE%\Documents\.R\Makevars`
and set the Rtools-specific [flags for gcc](https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html) like this:
```
CFLAGS=-O0 -g -std=gnu99 -Wall
```

a bit earlier (which produces the right answer), I might have doubted gcc 
sooner. Or would I? Faulty compiler optimisations and memory usage bugs can
have similar side effects; both can do strange things when the code is tickled 
by an innocuous print command. Both can disappear when you turn optimisation off. 
(User memory bugs can also seemingly disappear when you turn optimisation on...)

We briefly looked at the assembler code produced by the compiler, (`-S` on the 
gcc command line. It helps if the fragments of code you're comparing have
exactly matching line numbers, since assembler code is made of gotos.) But 
while we could tell the code was different with `-O1`, it would take a
special kind of assembler programmer to show us why exactly the behaviour
changed as it did.

In the end, we cleaned up my bizarre effort slightly, using a variable some
distance away in terms of scope to decide loop iterations, which produced both
better-looking code, and coaxed the compiler away from its more outlandish
optimisations.

## Conclusion

So what to say about all this? Firstly, where there is platform-dependent 
code, running CI tests on multiple platforms and architectures is essential.
Without that, we might have been chasing this issue blindly from a user
report after release. 

Secondly, debugging this sort of code is hard anyway, and the tools for 
debugging the R/C combination on Windows are limited. And thirdly, Rtools
could consider using a more recent gcc compiler (4.9.3 comes from June 2015).

But until then; on the bright side it's solid character-building stuff, and
common sense and simple debugging tests do eventually prevail, along with
patience and occasional prayer. On the other hand, since the gcc used in Rtools
3.5 is necessarily the same as the toolchain used for building R itself on
windows, perhaps we're all doomed. But only in 32-bits. Probably.
