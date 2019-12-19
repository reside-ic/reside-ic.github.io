---
author: "Alex Hill"
date: 2019-12-12
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

* <kbd>ctrl-v</kbd> - copy

* <kbd>ctrl-x</kbd> - cut
* <kbd>ctrl-v</kbd> - paste
* <kbd>ctrl-z</kbd> - undo

I'm on Linux, but these shortcuts work on Mac and Windows too (on Mac <kbd>ctrl</kbd> is replaced by command <kbd>&#8984;</kbd>)

### Ubuntu
* <kbd>alt-tab</kbd> - toggle between open applications
    * plus use <kbd>↑</kbd> <kbd>↓</kbd> <kbd>→</kbd> <kbd>←</kbd>to toggle between instances of an app
    
<img src="/img/tabchange.gif" alt="Use alt-tab to toggle between apps" />

* <kbd>ctrl-shift-v</kbd> - paste into the Ubuntu terminal

* <kbd>ctrl-R</kbd> - reverse search commands in the Ubuntu terminal. I only learnt this one recently (thanks Rich!) and it's
been a game changer!

<img src="/img/ctrlR.gif" alt="Reverse search in the terminal" />
    
### Browsers
These work in Chrome, Firefox and IE. Again I use these many many times each day.

* <kbd>ctrl-tab</kbd> - jump between open tabs

* <kbd>ctrl-t</kbd> - open a new tab
* <kbd>ctrl-w</kbd> - close the current tab

<img src="/img/browser.gif" alt="Manage browser tabs" />

* <kbd>ctrl-shift-n</kbd> - open an incognito window

### IntelliJ
I'm kind of a JetBrains fan girl, not only because I love Kotlin but also because they make incredible IDEs. These 
shortcuts work in IntelliJ and all other JetBrains IDEs (Pycharm, WebStorm, etc.) These are roughly in order of how 
often I use them, but I use them all multiple times every hour!

* <kbd>alt-enter</kbd> - see and select suggested actions to fix an error or warning, improve or optimize the code

<img src="/img/alt-enter.gif" alt="Choose an action with alt-enter in IntelliJ" />

* <kbd>ctrl-alt-l</kbd> - auto-format your code

* <kbd>ctrl-n</kbd>/<kbd>ctrl-shift-n</kbd> - search for classes/files respectively
    * once you have the search widget open, you can just type the first letter of each word in a class or file's name 
    to find it. E.g. to find the `ModelRunController` class I type `mrc`
* <kbd>ctrl-w</kbd> - highlight the current text with increasing scope. Note you might want to assign this one to 
a different key combo, since <kbd>ctrl-w</kbd> usually means "close window". See below for how to assign shortcuts in IntelliJ.

<img src="/img/scope.gif" alt="Highlight with increasing scopes in IntelliJ" />

* <kbd>alt-f1</kbd> followed by <kbd>enter</kbd> - jump to the location of the current file in the project menu
* <kbd>shift-f6</kbd> - rename a file

<img src="/img/rename.gif" alt="Jump to file and rename it in IntelliJ" />

### Customising shortcuts
You can customise your shortcuts on Ubuntu by going to settings -> devices -> keyboard. Similarly other OS shortcuts 
are customisable.

In IntelliJ there's even a shortcut for customising shortcuts! <kbd>ctrl-shift-a</kbd> will allow you to search for an action. 
Once you find it, hit <kbd>alt-enter</kbd> to open an editing window. Then hit the keys you want to assign as a shortcut for that 
action.

For example, IntelliJ by default assigns <kbd>ctrl-y</kbd> to delete a line. This is unintuitive to me and I want 
<kbd>ctrl-y</kbd> to redo an action that was undone by <kbd>ctrl-z</kbd>.

<img src="/img/reassign.gif" alt="Assigning a keyboard shortcut in IntelliJ" />

This is a list of the shortcuts I estimate that I use the most on a daily basis. I'd love to hear which shortcuts 
other people find indispensable, maybe there are some great ones I'm missing!
