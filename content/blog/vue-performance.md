---
author: "Alex Hill"
date: 2020-01-23
title: Handling long arrays performantly in Vue.js
tags:
 - Vue
 - Javascript
 - performance
---


## TL;DR
Use `Object.freeze` on large objects that don't have to be reactive. If you want to know a bit more about why this works 
and how big a performance gain it is, read on.

## Context

Reactive JavaScript frameworks like [Vue.js](https://vuejs.org/) are amazing for developing Single Page Apps like the one 
in our project [Naomi](/projects/#naomi). Everything is connected as if by magic - when data changes, the UI updates. But that magic 
has overheads associated with it that need to be understood to optimise for performance where large-ish datasets are 
being handled. We found when using Vue naively that our app couldn't handle a 10MB dataset performantly, but 
understanding how reactivity works in Vue helped us to find the fix.

Naomi provides visualisations of HIV epidemic indicators 
across a country, at a fine-grained regional level. Users can filter the data by many parameters, 
e.g. age, sex, year, level of of detail (from the whole country down to individual cities.)

<img src="/img/choropeek.gif" alt="Gif of the map widget in Naomi" />

The front-end app is written in [Vue.js](https://vuejs.org/) + [Vuex](https://vuex.vuejs.org/) and for the map plots we 
are using the excellent [Leaflet](https://leafletjs.com/) library. The HIV indicator data and GeoJSON are returned from
 an API and are in the  order of 10MB in size; the fitering of data happens in the front-end and the map is redrawn each 
 time the filtered data changes.
 
 If we were using vanilla Javascript with Leaflet, it would handle rendering this order of data with no problem. 
 But our first naive implementation of this in Vuejs was having real performance struggles. Every time a filter 
 changed, the map would take several seconds to redraw. 
 
## Debugging performance
 
I used Chrome's performance tools to see what was taking so long. The first tool I used was under the Performance tab.
You press `record`, perform the operations that you want to profile, in this case selecting data filters, then hit 
`stop` to see a summary of time taken by events on the page.
 
I found the `Bottom-Up` view most instructive -  I could see that around 15% of the time was being taken 
  by a Vue function called `addDep`, and that a function that just read a single value out of the data array was taking 
  over 100ms each time. 
  
<img src="/img/performance.png" alt="Screenshot of performance profile">
 
I used another Chrome tool to see how big the data was: the heap snapshot. You can find this under the 
memory tab in Chrome dev tools. In the results it was pretty easy to find the data array; it was the largest object in the heap with a retained size
of 107MB! In this case the original data array coming back from the API was around 4MB. Looking at the items of the array, 
it became clear what was going on.

<img src="/img/memoryheap.png" alt="Screenshot of heap snapshot">
 
## Under the hood

 In Vue, everything is reactive by default. This feels like magic, but what's really going on 
is that every object (in this case, every item in the array) is having an "observer" property added to it, this is an 
 instance of the [Dep](https://github.com/vuejs/vue/blob/2.6/src/core/observer/dep.js#L13) class,
and then having reactive getter and setter functions added for every property: 
https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L135 [^1] 

The upshot being that the 4MB array was growing by an order of magnitude. 

In this case the fix was simple. There was actually no reason for the internal items of the array to be observable as 
they are never mutated. In fact this is true of every sizable bit of data in the app - it is retrieved from the API 
and effectively treated as readonly. The [Vue documentation](https://vuejs.org/v2/guide/instance.html#Data-and-Methods) 
points to the the solution -  if an object is made readonly with `Object.freeze`, then Vue can't and doesn't try to make
 the object reactive.

Once we wrapped the API responses with `Object.freeze`, the heap shrank dramatically and so did the rendering time! The 
array is back down to 4MB in the heap:

<img src="/img/heap2.png" alt="Screenshot of heap snapshot after freezing large objects">

Looking at the new performance profile, `addDep` now only take 3% of the time, and that function that looked up an 
item in the array now takes a much more reasonable 0.1ms. That's 3 orders of magnitude less time.

<img src="/img/performance2.png" alt="Screenshot of performance profile after freezing large objects">

[^1]: The `addDep` function that was taking up so much time when I profiled the app is called whenever a getter is invoked (via `dep.depend()` [here](https://github.com/vuejs/vue/blob/2.6/src/core/observer/index.js#L163)) 

