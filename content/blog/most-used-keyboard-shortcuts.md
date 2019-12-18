---
author: "Alex Hill"
date: 2020-01-02
title: My most used keyboard shortcuts
---

Anyone who uses a computer for a significant amount of time each day should 
spend some time learning keyboard shortcuts - they can save you so much time! 

When I started working as a developer, I learnt keyboard shortcuts through pair programming, 
asking more experienced programmers what their favourite shortcuts were, and just reading
documentation for the IDE (Intelligent Development Editor) I was using 
([VisualStudio](https://docs.microsoft.com/en-us/visualstudio/ide/default-keyboard-shortcuts-in-visual-studio?view=vs-2019) 
with [Resharper](https://www.jetbrains.com/help/resharper/Reference__Keyboard_Shortcuts.html) at the time,
 now [IntelliJ](https://www.jetbrains.com/help/idea/mastering-keyboard-shortcuts.html).) 

Here are my most used keyboard shortcuts, starting with the basics:

### Global
These shortcuts are absolute essentials and work in most apps (text editors, browsers, email clients, IDEs, etc.)
 If you don't already use them, spend some time memorising and practising them. It'll save you loads of time in the long run.

* `ctrl-v` - copy
* `ctr-x` - cut
* `ctrl-v` - paste
* `ctrl-z` - undo

I'm on Linux, but these shortcuts work on Mac and Windows too (on Mac `ctrl` is replaced by `cmd`)

### Ubuntu
* `alt-tab` - toggle between open applications
    * plus use the arrow keys to toggle between instances of an app
    
<img src="/img/tabchange.gif" alt="Use alt-tab to toggle between apps" />

* `ctrl-shift-v` - paste into the Ubuntu terminal
* `ctrl-R` - reverse search commands in the Ubuntu terminal. I only learnt this one recently (thanks Rich!) and it's
been a game changer!

<img src="/img/ctrlR.gif" alt="Reverse search in the terminal" />
    
### Browsers
These work in Chrome, Firefox and IE. Again I use these many many times each day.

* `ctrl-tab` - jump between open tabs
* `ctrl-t` - open a new tab
* `ctrl-w` - close the current tab

<img src="/img/browser.gif" alt="Manage browser tabs" />

* `ctr-shift-n` - open an incognito window

### IntelliJ
I'm kind of a JetBrains fan girl, not only because I love Kotlin but also because they make incredible IDEs. These 
shortcuts work in IntelliJ and all other JetBrains IDEs (Pycharm, WebStorm, etc.) These are roughly in order of how 
often I use them, but I use them all multiple times every hour!

* `alt-enter` - see and select suggested actions to fix an error or warning, improve or optimize the code

<img src="/img/alt-enter.gif" alt="Choose an action with alt-enter in IntelliJ" />

* `ctr-alt-l` - auto-format your code
* `ctr-n`/`ctrl-shift-n` - search for classes/files respectively
    * once you have the search widget open, you can just type the first letter of each word in a class or file's name 
    to find it. E.g. to find the `ModelRunController` class I type `mrc`
* `ctrl-w` - highlight the current text with increasing scope. Note you might want to assign this one to 
a different key combo, since `ctrl-w` usually means "close window". See below for how to assign shortcuts in IntelliJ.

<img src="/img/scope.gif" alt="Highlight with increasing scopes in IntelliJ" />

* `alt-f1` followed by `enter` - jump to the location of the current file in the project menu
* `shift-f6` - rename a file

<img src="/img/rename.gif" alt="Jump to file and rename it in IntelliJ" />

### Customising shortcuts
You can customise your shortcuts on Ubuntu by going to settings -> devices -> keyboard. Similarly other OS shortcuts 
are customisable.

In IntelliJ there's even a shortcut for customising shortcuts! `ctr-shift-a` will allow you to search for an action. 
Once you find it, hit `alt-enter` to open an editing window. Then hit the keys you want to assign as a shortcut for that 
action.

For example, IntelliJ by default assigns `ctrl-y` to delete a line. This is unintuitive to me and I want 
`ctrl-y` to redo an action that was undone by `ctrl-z`.

<img src="/img/reassign.gif" alt="Assigning a keyboard shortcut in IntelliJ" />

This is a list of the shortcuts I estimate that I use the most on a daily basis. I'd love to hear which shortcuts 
other people find indispensable, maybe there are some great ones I'm missing!
