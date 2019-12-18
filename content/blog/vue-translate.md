---
author: "Alex Hill"
date: 2019-12-17
title: A custom directive for translations in Vue.js
---

We've spent the last few months developing [Naomi](/projects/#naomi) - a web app for interfacing with
 an HIV model developed by researchers at [GIDA](https://www.imperial.ac.uk/mrc-global-infectious-disease-analysis) 
 in association with [UNAIDS](https://www.unaids.org/en). To support the West African countries who are the users of Naomi we are providing two language modes - French and English. 
 
 The front-end of the app is written in [Vue.js](https://vuejs.org/) and makes use of [Vuex](https://vuex.vuejs.org/),
 a [flux](https://facebook.github.io/flux/) library for Vue. There are two ways we could have implemented
 translations in Vue - with components or directives. We opted for the latter; I'll explain why and how!

### Components vs directives
Vue, like [React](https://reactjs.org/), is a framework for writing components. 
A component looks like a custom HTML element, but has special behaviour attached to it by Vue.
Vuex provides helper functions that allow
components to subscribe to changes in the store, so it's pretty straight-forward to define a component that will
 perform translations. Usage of such a component would look a little like this:

```
<h3><translated translation-key="welcomeMessage"></translated></h3>
```

This is a little verbose, but also will become a lot more complicated if we want to translate something 
other than text, for example the placeholder of an input element. It could certainly be done, but 
you'd end up with an interface something like:

```
<translated-input 
            translation-key="email" 
            translation-attribute="placeholder" 
            inputType="text"
            name="myEmailInput"
            value="">
</translated-input>
```

But unlike React and more like [Angular](https://angular.io/), Vue is also a framework of 
[directives](https://012.vuejs.org/guide/directives.html). A directive looks 
like a custom attribute on an HTML element and defines some behaviour on that element. 

For example, some standard Vue directives control visibility and text content:

```<span v-if="hasError" v-text="message"></span>```

Directives can also require arguments, for example the `click` argument here:

```<button v-on:click="submitHandler">Submit</button>```

Our custom translate directive could look very similar to `v-text` but also take an optional argument 
indicating which attribute of the element we want translated: 

```
<h3 v-translate="'welcomeMessage'"></h3>
<input type="text" v-translate:placeholder="'email'" name="myEmailInput" value="" />
```

This interface is both less intrusive and more flexible than the component approach, but is not as 
straight-forward to implement. This blog will describe how we did it!

### Storing and updating the user's chosen language
In Vuex all app state is held
in a central "store", which is then the ideal place to keep track of what language the user has selected.

```
const store = new Vuex.Store({
    state: {
        language: "en" 
    } 
})
```

For performing the translations we have used [i18next](https://www.i18next.com/), which is intialised
 with a language and the available translations. When the user selects a new language we fire off a Vuex
  [action](https://vuex.vuejs.org/guide/actions.html) that updates both i18next and the language in our store state.
 
 
 ```
const store = new Vuex.Store({
  state: { 
    language: "en" 
  },
  mutations: {
    updateLanguage (state, newLanguage) {
      state.language = newLanguage
    }
  },
  actions: {
    async changeLanguage (context, newLanguage) {
      await i18next.changeLanguage(newLanguage);
      context.commit('updateLanguage', newLanguage)
    }
  }
})
```

### Listening for changes

Were we to use a component, listening for changes would be easy - it's baked into the framework. A simple translation component
that just translates text and renders it in a span looks like this:

```
<template>
    <span>{{translatedText}}</span>
</template>

<script>
import {mapState} from Vuex

export default {
    props: ["translationKey"],
    data() {
        return {
            translatedText: i18next.t(this.translationKey)
        }
    },
    computed: mapState({ language -> state.language }),
    watch: {
        language() {
            this.translatedText = i18next.t(this.translationKey)
        }
    }
}

</script>
```

The computed property "language" gets updated whenever the store state language changes, the watcher fires and the 
text is updated.

A directive has a completely different structure. There are 5 lifecycle events: `bind`, `inserted`, `update`, 
`componentUpdated` and `unbind`. `bind` is fired when the component is first created, and the `update` hook allows us to listen for changes to the value of the directive. 
It will fire if for example, the prop "title" changes in value in this component:

```
<template>
    <h3 v-translate="title"></h3>
</template>
<script>
export default {
    props: ["title"]
}
</script>
```

But there is no directive hook that will fire when *store state* changes, i.e. our language. So we'll have to manage
a subscription to the store ourselves. 
Vuex exposes a method on the store for doing this: [watch](https://vuex.vuejs.org/api/#watch).
We can add our watcher on `bind`:

```
bind(el, binding) {
     el.innerHTML = i18next.t(binding.value, {lng: store.state.language});
     el.__lang_unwatch__ = store.watch(state => state.language, lng => {
          el.innerHTML = i18next.t(binding.value, {lng});
     })
}
```

The `store.watch` function returns an "unwatch" function, which removes the watcher when it is called.
We have to be careful to do so when the element is destroyed, to prevent a proliferation 
of watchers. We can do this on `unbind`:

```
unbind(el) {
    el.__lang_unwatch__();
}
```

To update the element when the directive value changes is straight-forward with the `update` hook, but we 
also have to remove and recreate the store watcher, since the previous watcher has the initial value of the binding
 cached within it:

```
update(el, binding) {
    el.__lang_unwatch__();
    bind(el, binding);
}
```

Then we register our directive and it's good to go:

```
const translate = {
    bind: bind,
    update: update,
    unbind: unbind
}

Vue.directive('translate', translate);
```

The above is the code for a directive that just translates text. The directive we created is able to 
translate arbitrary attributes of an element as per:

```<input v-translate:placeholder="'email'" />```

You can see the full (typescript) code for the final directive
 [here](https://github.com/mrc-ide/hint/blob/master/src/app/static/src/app/directives/translate.ts).
 
 I hope this is useful for anyone else trying to achieve something similar in their Vue app!