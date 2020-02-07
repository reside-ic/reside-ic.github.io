---
author: "Alex Hill"
date: 2020-02-20
title: Front-end Javascript Frameworks - A Beginner's Guide
tags:
 - javascript
 - vue
 - react
 - angular
---

We've put together a little resource for RSEs (or anyone else!) who are writing browser 
based apps and want to be using the latest javascript web technologies, but aren't sure 
where to start. 

The full <a href="/resources/jsbeginnersguide.pdf" target="_blank">poster</a> was presented 
at [RSLondonSouthEast](https://rslondon.ac.uk/) on 6th February.

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

Here's how the "Big 3" frameworks of [Vue.js](https://vuejs.org/), [React](https://reactjs.org/) and [Angular](https://angular.io/) (aka Angular 2)
compare in terms of their features:

<img src="/img/jstable.png" alt="Comparison between features of Js frameworks">

Picking a framework partly comes down to personal preferences - for example, most people find Vue's syntax a little 
easier to pick up, and I personally prefer writing HTML to JSX. But then I find React's "Redux" package more 
elegant and slightly less boilerplate-y than Vue's equivalent "Vuex" package.

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

