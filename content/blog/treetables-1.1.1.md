---
author: "Alex Hill"
date: 2019-06-11
title: jQuery TreeTables 1.1.1
best: false
tags: 
 - Javascript
---

![Gif of plugin in use](/img/treetables.gif)

We just released a new npm package [TreeTables](https://www.npmjs.com/package/treetables)
 for displaying tree data when using jQuery
[DataTables](https://datatables.net/).

DataTables is a powerful and extremely well established plugin for
displaying tabular data, but has no native support for 
[tree (nested) data](https://en.wikipedia.org/wiki/Tree_(data_structure)).
Examples of tree data include family trees, phylogenetic trees, 
and organisational hierarchies.

The TreeTables plugin adds that support with an interface that is almost
identical to that of DataTables. 

Features include:

* toggling individual rows open and closed
* expanding or collapsing all rows
* arbitrarily deeply nested data

Basic usage:

```
        const organisationData = [
            {tt_key: 1, tt_parent: 0, name: "CEO"},
            {tt_key: 2, tt_parent: 1, name: "CTO"},
            {tt_key: 3, tt_parent: 2, name: "developer"},
            {tt_key: 4, tt_parent: 1, name: "CFO"}
        ];

        $('#my-table').treeTable({
            "data": myData,
            "collapsed": true,
            "columns": [
                {
                    "data": "name"
                }
            ]
        });
```


Read the full documentation and download instructions on [npm](https://www.npmjs.com/package/treetables)
or [GitHub](https://github.com/reside-ic/TreeTables)