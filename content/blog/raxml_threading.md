---
author: Wes Hinsley
date: 2022-08-23
title: Ths risk of over-threading
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
64 cores per rack slot, while also linear speed is respectable. A dependable
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

{{< figure src="/img/raxml_08.png" alt="RAxML with up to 8 cores" width="360px" height="240px">}}

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

{{< figure src="/img/raxml_032.png" alt="RAxML with over 8 cores" width="360px" >}}

.. and we actually start to make things slower - using 32 cores performs
comparably to using 8. There just isn't enough parallel work for all the
threads to do; they spend more time waiting for the administrator to
assign them work, than they spend executing that work.

# Stacking

So we've seen throwing extravagant resources at the job doesn't always make
thing faster; it can even make things slower. Moreover, if we have multiple
jobs we can run on those resources, the compute node might be able to run
those separate jobs pretty much at the same time. Instead of running one 
slow 32-core job, we might be able to run, say, a pair of faster 16-core
jobs, or four 8-core jobs, on the same node, and have them all finish
faster than the original.

# Conclusions

* Don't, by default, use all the cores you've got, just because you can. 
Always take a survey of a few different thread counts to see how performance 
looks. For example, with RAxML, read their 
[paper](http://sco.h-its.org/exelixis/pubs/Exelixis-RRDR-2010-3.pdf which
they mention in the [readme](https://github.com/stamatak/standard-RAxML). But
also do some tests.

* Different algorithms, or different parameterisations or input data  
might provoke different performance characteristics. My graphs above might
be an unfair representation of RaXML for instance; perhaps different 
input data would let it use more cores more efficiently. But the key is,
we could try and find that out before setting many jobs going that might
take much longer than we need.

* In this example, the processor optimisation for AVX increased a little
over SSE3 when the cores were well used; the differences between AVX2 and 
AVX were smaller. But those gains are tiny compared to both (1) the loss 
of performance with over-threading, or (2) the gains you can get with
increased throughput, running more coarser-grain work. For many applications,
that may be a much better performance angle to pursue from the outset.
