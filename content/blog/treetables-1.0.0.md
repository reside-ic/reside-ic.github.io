---
author: "Alex Hill"
date: 2019-05-31
title: jQuery TreeTables 1.0.0
best: false
---

We just released a new npm package [TreeTables](https://www.npmjs.com/package/treetables)
 for displaying tree data when using jQuery
[DataTables](https://datatables.net/)

DataTables is a powerful and extremely well established plugin for
displaying tabular data, but has no native support for tree data.

The TreeTables plugin adds that support with an interface that is almost
identical to that of DataTables. 

E.g.

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

<img src="/img/treetable-screenshot.png" alt="Screenshot of plugin in use" />

Read the full documentation and download instructions on [npm](https://www.npmjs.com/package/treetables)
or [GitHub](https://github.com/reside-ic/TreeTables)