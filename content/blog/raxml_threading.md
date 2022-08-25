---
author: Wes Hinsley
date: 2022-08-23
title: The risk of over-threading
tags:
- HPC
- Parallel
- Threading
---

# Introduction

High-density compute nodes are all the rage at the moment. Our IT manager 
doesn't get out of bed for less than 32-cores in a compute node. Our current
favourite build is a pair of 
[Xeon Gold 6226R](https://ark.intel.com/content/www/us/en/ark/products/199347/intel-xeon-gold-6226r-processor-22m-cache-2-90-ghz.html)
(16 cores at 2.9GHz, turbo to 3.9GHz), in a half-width sled, packing in
64 cores per rack slot[^1], while also linear speed is respectable. A dependable
workhorse HPC (CPU) node.

Much of the parallel computation in our department is done at the process
level, rather than the core (or thread) level. Simply stacking up single-core
jobs on the node and letting the operating system decide the best use of its
resources turns out effective both in terms of performance, and in the lack of
tricky programming (or often, any programming at all) required to get that
performance.

Where there is threaded code, various R packages, or OpenMP, or Java threads
all make it possible without too much fuss if you are careful. Or sometimes
you might strike it lucky and find that the tool you want to use has a
ready-made argument for threading - a command-line argument `-T 32` for
instance, to make maximal use of all the cores on our speedy nodes. 
Because why wouldn't you?

# Why wouldn't you, indeed.

A decade or so ago, our clusters consisted mainly of 8-core machines, which
at the time felt like a triumphant performance breakthrough. The performance
graphs we were used to seeing were often something like this:

{{< figure src="/img/raxml_08.png" alt="RAxML with up to 8 cores" >}}

These are sample runs I made using our new nodes this week with a
bioinformatics tool called [RaXML](https://github.com/stamatak/standard-RAxML).
It can be compiled to target SSE3, AVX, or AVX2 processor optimisations,
and with threading enabled. It offers the convenient `-T threads` argument we
mentioned earlier. 

One of the threads (if you use more than one) acts as an
administrator, which somewhat explains the lack of gain from 1 to 2 threads;
after that, from 2 to 6 threads, we're around 90% efficient. Beyond that, the
gains of more threads are diminishing. But a few years ago, that was where
the graph ended. Now we have more cores, so let's throw them all at the
problem...

{{< figure src="/img/raxml_032.png" alt="RAxML with over 8 cores" >}}

.. and we actually start to make things slower - using 32 cores performs
comparably to using 8. There just isn't enough parallel work for all the
threads to do; they spend more time waiting for the administrator to
assign them work, than they spend executing that work.

# Stacking

So if throwing all our node's resources at a single job doesn't necessarily
make that single job faster (indeed, perhaps the opposite), then what if we try and
maximise throughput instead? Let's try filling a 32-core node with as many 16, 8, or
4 core jobs as will fit. It might be interesting to "almost fill" a node with 
three 10-core jobs, leaving a couple of cores spare too. And we'll see how they
compare with single, similar-sized jobs, to see how much you lose by stacking. For
simplicity, I am sticking on AVX2.

{{< figure src="/img/raxml_multi.png" alt="RAxML with jobs stacked on a node" >}}

Here the blue bar shows the solo job we did earlier, where the job (however many
threads) has the whole node to itself; the other bars show the jobs that we ran 
simultaneously to fill the node up, and see how it copes with the stack.

The results are a bit confusing here and there; the 10-core is a bit surprising, 
and we have more overhead of stacking up 4 and 8 core jobs than we might
expect. The headline here is that stacking 16-core jobs, or 8-core jobs gets us
an average of 4.6 hours per job. 4-cores is a bit worse at 4.8 hours per job; 10-cores
needs a deeper dig, coming out at 5.7 hours per job.

This is all rather better than throwing all 32 cores at each job, which ends
up towards 14.

# Conclusions and Limitations

Don't, by default, use all the cores you've got, just because you can. 
Always take a survey of a few different thread counts to see how performance 
looks. For example, with RAxML, read their 
[paper](http://sco.h-its.org/exelixis/pubs/Exelixis-RRDR-2010-3.pdf) which
they mention in the [readme](https://github.com/stamatak/standard-RAxML). But
also do some tests.
 
Here I've looked at just the total end-to-end time. In reality, there
are number of different stages we can get timings for, and some stages
prefer one optimisation to another. That would be a longer and more tedious
blog post to write, but for a proper profiling we'd want to see how the
different stages compare, not just the total. And also note I've only taken
one sample per run.

Different algorithms, or different parameterisations or input data 
might provoke different performance characteristics. Here I've looked at
an arbitrary dataset I was asked to work with, and ran with just 10 of
the original 500 bootstraps. RAxML jobs in the wild would take much longer
(making this sort of performance insight helpful), but may also be variable, if
our 10 are not representative of the full set.

So My graphs above might be an unfair representation of RaXML for instance.
But the key is, we could try and find that out before setting many jobs 
going that might take weeks than they need to.

Lastly, the processor optimisation for AVX increased a little
compared to SSE3 when the cores were well used, and the differences between 
AVX2 and AVX were unclear. But those gains are small compared to either (1) the 
loss of performance with over-threading, or (2) the gains you can get with
increased throughput, running more coarser-grain work. The jobs here used
one node, and many more cluster nodes might be available. For many applications,
that may be a much better angle to pursue from the outset, rather than jumping
prematurely to more technically difficult optimisations.[^2]
  
---


[^1]: A rack of HPC compute nodes contains about 40 slots, 5 of which might go on network switches, and potentially 10 on UPSes.
[^2]: An almost relevant excuse to reference [Computing Surveys, Vol 6, No 4, December 1974, p268](https://dl.acm.org/doi/10.1145/356635.356640)
