---
author: "Alex Hill"
date: 2020-02-27
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

## Why use a framework?
This StackOverflow blog is an excellent overview of the advantages and disadvantages of using a framework:
[Is it time for a front end framework?](https://stackoverflow.blog/2020/02/03/is-it-time-for-a-front-end-framework/)

Front-end apps of a certain size and complexity have to handle:

* keeping track of changing state
* organising a complex system of code components reflecting and updating that state
* dynamically updating HTML
* comprehensive testing

A Javascript framework provides some ready-made structure you can use to
 organise your application, including:
 
* state management and data binding
* re-usable component based architecture
* HTML templating
* testing utilities that make Selenium tests a thing of the past

## Key concepts 
If you've just gotten started with the world of front-end frameworks, you've probably heard of 
**components** and **directives**. These are the key building blocks for modern JS frameworks.

A component in usage looks like a custom HTML element:

```
<error-list errors="myErrorArray"></error-list>
```

while a directive looks like a custom data attribute on a regular HTML element:

```
<span v-if="hasError" v-text="message"></span>
```

A component is a combination of a **template** that defines the presentation, and a script that defines 
behaviour.

Here's an example of an HTML template in [Vue.js](https://vuejs.org/). It uses the v-for directive to loop over an array:

```
<ul class="list">
    <li v-for="e in errors">
        {{e}}
    </li>
</ul>
```

And here's how you'd achieve the same thing in [React](https://reactjs.org/). React doesn't support HTML templates but instead 
uses **JSX**, a syntax extension to Javascript that resembles HTML:

```
<ul className="list">
    {errors.map(e => <li>{e}</li>)}
</ul>
```

## Application architecture
You might have heard of [Flux](https://facebook.github.io/flux/) - it's a code architecture pattern pioneered by Facebook, the creators of React,
 and now widely adopted for organising complex front-end applications. React by itself is just a lightweight library for writing components, but it is commonly 
used in conjunction with [Redux](https://react-redux.js.org/) which is a Flux implementation. And Flux is simply a pattern, so
it can be used in conjunction with any library at all, not just React.

The best way to understand Flux is probably to read the [docs](https://facebook.github.io/flux/docs/overview) over at Facebook. 
But in a nutshell, it's a uni-directional data flow pattern inspired by functional programming:

<img style="width:auto; display: block; margin: 0 auto;" src="/img/flux.png" alt="Diagram explaining the Flux data flow pattern"/> 

It can add a lot of boilerplate code to your app, so it's not always the right solution. If you're just writing a handful 
of mostly independent components, you almost certainly don't need it. If you have a complex, dynamic app with many components
 that need to share state, then it can be really useful.

The Redux homepage [suggests](https://redux.js.org/faq/general#when-should-i-use-redux):

> In general, use Redux when you have reasonable amounts of data changing over time, you need a single source of truth, and you find
> that approaches like keeping everything in a top-level React component's state are no longer sufficient.

Vue, like React, is a lightweight library with no strong opinions about application architecture. 
But it too has a complementary Flux library, called [Vuex](https://vuex.vuejs.org/).

Angular, by contrast, is quite opinionated about application architecture - the pattern it uses is reminiscent of the 
Model View Controller pattern. If you're more familiar with Object Oriented patterns like 
dependency injection than you are with Functional programming styles, Angular may seem more intuitive. Having said that, you 
absolutely can use Flux with Angular as well.

## Choosing a framework

Here's how the "Big 3" frameworks of [Vue.js](https://vuejs.org/), [React](https://reactjs.org/) and [Angular](https://angular.io/) (aka Angular 2)
compare in terms of their features:

<img style="width:auto" src="/img/jstable.png" alt="Comparison between features of Js frameworks" />

Picking a framework partly comes down to personal preferences - for example, most people find Vue's syntax a little 
easier to pick up, and I personally prefer writing HTML to JSX. But then I find React's "Redux" package more 
elegant and slightly less boilerplate-y than Vue's equivalent "Vuex" package. For this reason, if I were writing a
 complex single page app, I would prefer React + Redux, but if I just wanted to add a small amount of front-end code
  to a full-stack monolithic app, I'd pick Vue.

One important consideration is just how popular the different frameworks are. The Javascript ecosystem 
moves pretty fast, and you don't want to back the wrong horse and end up using a framework that gets discontinued or 
just falls behind. At the moment React seems like a solid bet in that it has a large, enthusiastic user base. 
Angular is still very widely used but it seems like it's less popular with developers than the other two.
 Vue has fewer downloads than React, but developers are very enthusiastic about it.
 
<img style="width:auto" src="/img/githubpopularity.png" alt="Comparison between GitHub popularity of Js frameworks"/>
<img style="width:auto" src="/img/npm.png" alt="Comparison between npm popularity of Js frameworks"/>
<img style="width:auto" src="/img/devs.png" alt="Comparison between developer popularity of Js frameworks"/>

If you're already using a front-end framework, let us know how you made your choice!

[^1]: https://www.npmjs.com/
[^2]: https://github.com/
[^3]: https://insights.stackoverflow.com/survey/2019

