---
title: "Experiments in transforming Excel into R"
date: 2019-11-19
tags:
 - R
 - Excel
---

Last week was the [Health Economics in R Hackathon](https://n8thangreen.wixsite.com/hermes-hack-london), bringing together health economists, epidemiologists and research software engineers.

We learned that complex spreadsheet models are common in health economics, and that the users of these models feel constrained by what they can achieve with them - having constructed a [decision tree model](https://en.wikipedia.org/wiki/Decision_tree) in Excel, the analyst might want to carry out a [sensitivity analysis](https://en.wikipedia.org/wiki/Sensitivity_analysis), varying the models' parameters to see how the model outcomes vary.  Doing this requires knowledge of [Visual Basic](https://en.wikipedia.org/wiki/Visual_Basic_for_Applications) and reportedly is quite slow to run.  We wanted to create a proof-of-concept package that would take an Excel model like this and convert it into an R function, where it could be more easily manipulable, *accelerating* the researchers' ability to do their work.

This does not present a complete solution by any means (it _was_ a hackathon)!  But it's a proof-of-concept for an idea that might be worth pursuing.

First, it's worth thinking about what it *means* to "compute a spreadsheet".  In our brainstorming session we tried to home in on the problem - what is the analyst actually trying to do, and how would they do it?  The basic idea is that they would modify some cells that represent parameters and then the spreadsheet recomputes ([spreadsheets fundamentally representing a form of reactive programming](https://stenci.la/blog/introducing-sheets/)) to change other cells that represent outputs.  So we have a mapping of inputs to outputs, which seems an awful lot like a function.

While clever approaches could be developed to automatically determine inputs and outputs, we allowed specifying of inputs and outputs as a set of Excel cell references (using [`cellranger`](https://github.com/rsheets/cellranger)) on a particular sheet, with a hint as to where to find a label as a row/column offset:

```
inputs <- xlerate::xlerate_ref(
  c("D3:D13", "D15:D16", "D18:D21"),
  sheet = 1,
  label = list(col = -1))
outputs <- xlerate::xlerate_ref(
  c("C40", "E34", "E50", "G29", "G38", "G45", "G54"),
  sheet = 2,
  label = list(row = 2))
```

Then, the package's main function starts from the outputs and works backwards from each dependency.  Supposing the output cell `C40` contains the formula

```
=E34*E37+E53*E50
```

we can parse this formula[^1] and add the cells `E37` and `E53` to our list of cells to consider (`E34` and `E50` already being included in the list), applying this recursively until we find cells that contain only values and not formulae. This produces a graph of dependencies, to which we can apply a [topological sort](https://en.wikipedia.org/wiki/Topological_sorting) so that we know a route through the graph so that equations are always computed before anything that depends on them.

```
tree <- xlerate::xlerate(path, inputs, outputs)
```

This calculation is performed on creation of the object, which is itself just a special R function.  It takes as arguments

```
tree(c("pTST_pos" = 0.01), verbose = TRUE)
```

which also prints the trace as it computes the outputs

```
s2.E37: s1.D3 => 0.01
s2.E38: s1.D20 => 500
s2.G41: 1 - s2.G32 => 1
[...]
s1.D6: 1 - (s1.D11 * (1 - s1.E13)/((1 - s1.D10) * s1.E13 + s1.D11 * (1 - s1.E13))) => 0.0503597122302158
s1.D6: 1 - (s1.D11 * (1 - s1.E13)/((1 - s1.D10) * s1.E13 + s1.D11 * (1 - s1.E13))) => 0.0503597122302158
s2.E34: s2.E38 + s2.G32 * s2.G29 + s2.G41 * s2.G38 => 500
s2.E34: s2.E38 + s2.G32 * s2.G29 + s2.G41 * s2.G38 => 500
s2.G48: s1.D6 => 0.0503597122302158
s2.G48: s1.D6 => 0.0503597122302158
s2.G57: 1 - s2.G48 => 0.949640287769784
s2.G57: 1 - s2.G48 => 0.949640287769784
s2.E50: +s2.G48 * s2.G45 + s2.G57 * s2.G54 => 67.5827338129497
s2.E50: +s2.G48 * s2.G45 + s2.G57 * s2.G54 => 67.5827338129497
s2.C40: s2.E34 * s2.E37 + +s2.E53 * s2.E50 => 71.9069064748202

       TST        pos        neg       LTBI  LTBI free       LTBI  LTBI free
  71.90691  500.00000   67.58273 1342.00000    0.00000 1342.00000    0.00000
```

This is just a proof of concept, but this could enable a sensitivity analysis for an existing Excel workbook in a few lines of code.

There are a few more details in the [package README](https://github.com/HealthEconomicsHackathon/xlerate#xlerate), though there remains a lot of implementation remaining to make this do anything really useful (such as work with more than just basic arithmetic operations and `SUM`). If you find this *exhilarating* let us know :)

[^1]: Curious readers may wonder _how_ one can get formulae from Excel workbooks.  A couple of years ago, [Jenny Bryan](https://jennybryan.org) and I had a go at some tools for [reading all the gory details out of Excel spreadsheets](https://github.com/rsheets/rexcel) - I resurrected that project for this experiment. In the meantime it transpires that someone else has done a nice job with [`tidyxl`](https://nacnudus.github.io/tidyxl/) which will be used instead if `xlerate` is developed any further.
