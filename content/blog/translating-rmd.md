---
author: "Rob Ashton"
date: 2021-06-30
title: Translating R Markdown
best: false
tags:
 - R
 - rmarkdown
 - translation
---

## Translating Rmd

As part of our work on [naomi](../../projects/naomi) we've been asked to produce reports from R which can be distributed to country teams across Sub-Saharan Africa in English, French and Portuguese. R Markdown has no prescribed method for translating documents, but there are many options available to make this possible. This post covers 3 possible approaches: code chunks, custom blocks and tabsets.

## Code chunks

The first method uses conditionally evaluated [code chunks](https://bookdown.org/yihui/rmarkdown/r-code.html). We can use R Markdown chunk options `include` and `eval` to hide output and stop a chunk from being evaluated. Combining with `results="asis"` this allows us to output text conditionally based on the `lang` parameter.

````r
---
title: '&nbsp;'
params:
  lang: fr
---

```{r, include=FALSE}
if (params$lang == "fr") {
  print_fr <- TRUE
  print_en <- FALSE
} else {
  print_fr <- FALSE
  print_en <- TRUE
}
```


```{r, echo=FALSE, results="asis", include=print_en, eval=print_en}
cat("Plot of random points<br/>")
plot(runif(10), runif(10), main = "Random points")
```

```{r, echo=FALSE, results="asis", include=print_fr, eval=print_fr}
cat("Tracé de points aléatoires<br/>")
plot(runif(10), runif(10), main = "Points aléatoires")
```
````

This has the advantage that the chunk will only be evaulated for the output language. This is particularly important if any of the plots we're generating take a long time to compute. The downside is the text needs be wrapped in calls to `cat` and the formatting of the text has to be done manually. For example we need to add the line break at the end of the text or the plot and text will appear on the same line. As everything is written as a code chunk this means RStudio syntax highlighting for the text is not available.

## Custom blocks

We can also use [custom blocks](https://bookdown.org/yihui/rmarkdown-cookbook/custom-blocks.html#custom-blocks) combined with CSS styling to control display of particular sections.

````r
---
title: '&nbsp;'
params:
  lang: fr
---

<style>
#translate {
  display: none;
}
#translate[lang=`r params$lang`] {
  display: block;
}
</style>


::: {#translate lang="en"}
Plot of random points

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Random points")
```
:::


::: {#translate lang="fr"}
Tracé de points aléatoires

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Points aléatoires")
```
:::
````

This syntax enables writing R Markdown as normal, no need for calls to `cat` or to manually manage formatting. It gives an easy way to add a second language to an existing document as you just need to surround existing code with `:::` and add the second language below. The downside is this will run every block of code and hide the sections for language not being used. Because of this it is not the best choice for documents with plots or operations which take a long time to compute. This approach will only work if the target output is html as it relies on CSS for styling.

## Tabset

[R Markdown tabsets](https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html#html-tabs) can be used to make multiple translations available in one document and enable users to switch between languages.

````r
---
title: "&nbsp;"
params:
  lang: fr
---

# Language {.tabset .tabset-dropdown}

## English

Plot of random points

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Random points")
```

## French

Tracé de points aléatoires

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Points aléatoires")
```
````

<img src="/img/translating-rmd.gif" alt="Translating R Markdown with tabset" />

Like using custom blocks, a tabset lets us write R Markdown as we would for a single language. We can still take advantage of syntax highlighting in RStudio and R Markdown managing the formatting of text. Using `.tabset .tabset-dropdown` allows users to switch between translations in the output document via a dropdown menu. This has the same disadvantage as custom blocks, it runs all code and so will be slower than using code chunks.

## Conclusion

When translating R Markdown in production projects we've used a mix of approaches. Custom blocks provide a good way to translate large sections of text as they enable us to take advantage of automatic formatting and syntax highlighting. Combining with code chunks for translating slow to produce plots enables us to keep the generation of documents performant.

The problem with all of the methods above is they don't scale well. They work fine for 2 or 3 languages but if you want to provide translations for more than this then the document starts to get long and complicated. There is a more scalable approach detailed in [StatnMap blog post](https://statnmap.com/2017-10-06-translation-rmarkdown-documents-using-data-frame/) which uses a data frame of strings which can scale by adding a new column for each new language desired. The cost of this is the R Markdown document is difficult to read.

I think would be worth investigating a scalable approach via multiple R Markdown documents, one for each language. Making the name conform to some convetion `<report>_fr.Rmd`, `<report>_en.Rmd` etc. would then give a way to build input filename and pass to `rmarkdown::render` to generate the report in the correct language programatically. This would mean it would be straightforward to add a new language and each additional language would not increase the complexity.
