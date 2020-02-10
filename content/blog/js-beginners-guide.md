---
author: "Alex Hill"
date: 2020-02-02
title: Front-end Javascript Frameworks - A Beginner's Guide
tags:
 - javascript
 - vue
 - react
 - angular
---

We've put together a little resource for RSEs (or anyone else!) who are writing browser 
based apps and want to be using the latest Javascript web technologies, but aren't sure 
where to start. 

The full <a href="/resources/jsbeginnersguide.pdf" target="_blank">poster</a> was presented 
at [RSLondonSouthEast](https://rslondon.ac.uk/) on 6th February.

## Key concepts 
If you've just gotten started with the world of front-end frameworks, you've probably heard of 
**components** and **directives**. These are the key building blocks for modern JS frameworks.

A component is like a custom HTML element with special behaviour attached:

```
<error-list errors="myErrorArray"></error-list>
```

A directive is like a custom data attribute on a regular HTML element, with special behaviour attached:

```
<span v-if="hasError" v-text="message"></span>
```

A component is a combination of a **template** that defines the presentation, and a script that defines 
behaviour.

Here's an example of an HTML template in Vue.js. It uses the v-for directive to loop over an array:

```
<ul class="list">
    <li v-for="e in errors">
        {{e}}
    </li>
</ul>
```

And here's how you'd achieve the same thing in React. React doesn't support HTML templates but instead 
uses **JSX**, a syntax extension to Javascript that resembles HTML:

```
<ul className="list">
    {errors.map(e => <li>{e}</li>)}
</ul>
```

## Application architecture
Finally, you might have heard of [Flux](https://facebook.github.io/flux/) - it's a code architecture pattern pioneered by Facebook, the creators of React,
 and now widely adopted for organising complex front-end applications. React by itself is just a lightweight library for writing components, but it is commonly 
used in conjunction with [Redux](https://react-redux.js.org/) which is a Flux implementation. 

The best way to understand Flux is probably to read the [docs](https://facebook.github.io/flux/docs/overview) over at Facebook. 
But in a nutshell, it's a uni-directional data flow pattern inspired by functional programming.

It can add a lot of boilerplate code to your app, so it's not always the right solution. If you're just writing a handful 
of mostly independent components, you almost certainly don't need it. If you have a complex, dynamic app with many components
 that need to share state, then it can be really useful.

The Redux homepage suggests:

> In general, use Redux when you have reasonable amounts of data changing over time, you need a single source of truth, and you find
> that approaches like keeping everything in a top-level React component's state are no longer sufficient.

Vue, like React, is a lightweight library with no strong opinions about application architecture. But it too has a complementary Flux library, called [Vuex](https://vuex.vuejs.org/).

Angular, by contrast, is quite opinionated about application architecture - the pattern it uses is reminiscent of the 
Model View Controller pattern. If you're more familiar with Object Oriented patterns like 
dependency injection than you are with Functional programming styles, Angular may seem more intuitive. Having said that, you 
absolutely can use Flux with Angular as well.

Here's how the "Big 3" frameworks of [Vue.js](https://vuejs.org/), [React](https://reactjs.org/) and [Angular](https://angular.io/) (aka Angular 2)
compare in terms of their features:

<img src="/img/jstable.png" alt="Comparison between features of Js frameworks">

## Choosing a framework
Picking a framework partly comes down to personal preferences - for example, most people find Vue's syntax a little 
easier to pick up, and I personally prefer writing HTML to JSX. But then I find React's "Redux" package more 
elegant and slightly less boilerplate-y than Vue's equivalent "Vuex" package. For this reason, if I were writing a
 complex single page app, I would prefer React + Redux, but if I just wanted to add a small amount of front-end code
  to a full-stack monolithic app written in something like Ruby on Rails or SpringBoot, I'd pick Vue.

One important consideration is just how popular the different frameworks are. The Javascript ecosystem 
moves pretty fast, and you don't want to back the wrong horse and end up using a framework that gets discontinued or 
just falls behind. At the moment React seems like a solid bet in that it has a large, enthusiastic user base. 
Angular is still very widely used but it seems like it's less popular with developers than the other two.
 Vue has fewer downloads than React, but developers are very enthusiastic about it!
 
<img style="width:auto" src="/img/githubpopularity.png" alt="Comparison between GitHub popularity of Js frameworks"/>
<img style="width:auto" src="/img/npm.png" alt="Comparison between npm popularity of Js frameworks"/>
<img style="width:auto" src="/img/devs.png" alt="Comparison between developer popularity of Js frameworks"/>


[^1]: https://www.npmjs.com/
[^2]: https://github.com/
[^3]: https://insights.stackoverflow.com/survey/2019

