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

As part of our work on [naomi](../../projects/naomi) we've been asked to produce reports from R which can be distributed to country teams across Sub-Saharan Africa in English, French and Portuguese. [R Markdown](https://rmarkdown.rstudio.com/docs/) has no built in support for translating documents, but there are many options available to make this possible. This post covers 3 possible approaches: code chunks, custom blocks and tabsets each of which has advantages and trade offs around scalability, ease of maintenance and complexity.

## Code chunks

The first method uses conditionally evaluated [code chunks](https://bookdown.org/yihui/rmarkdown/r-code.html). We can use R Markdown chunk options `include` and `eval` to hide output and stop a chunk from being evaluated. Combining with `results="asis"` this allows us to output text conditionally based on the `lang` parameter.

````r
---
params:
  lang: fr
---

```{r, include=FALSE}
if (params$lang == "fr") {
  print_fr <- TRUE
  print_en <- FALSE
  title <- "Titre Français"
} else {
  print_fr <- FALSE
  print_en <- TRUE
  title <- "English Title"
}
```

---
title: `r title`
---

```{r, echo=FALSE, results="asis", include=print_en, eval=print_en}
cat("Plot of random points<br/>")
plot(runif(10), runif(10), main = "Random points")
```

```{r, echo=FALSE, results="asis", include=print_fr, eval=print_fr}
cat("Tracé de points aléatoires<br/>")
plot(runif(10), runif(10), main = "Points aléatoires")
```
````

This has the advantage that the chunk will only be evaluated for the output language. This is particularly important if any of the plots we're generating take a long time to compute. The downside is the text needs to be wrapped in calls to `cat` and the formatting of the text has to be done manually. For example, we need to add the line break at the end of the text or the plot and text will appear on the same line. As everything is written as a code chunk this means RStudio syntax highlighting for the text is not available. This method requires large amounts of duplication both in the code and in the text formatting.

To translate the title we need to create `text` variable during the if statement and then reference it from a second YAML header.

## Custom blocks

We can also use [custom blocks](https://bookdown.org/yihui/rmarkdown-cookbook/custom-blocks.html#custom-blocks) denoted by `:::` combined with CSS styling to control display of particular sections.

````r
---
title: "`r
  if (params$lang == 'fr') {
     'Titre Français'
  } else {
     'English Title'
  }`"
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

Custom blocks are sections of R Markdown surrounded by `:::` which can be used to customise appearance. For HTML output they get converted into `<div>` blocks with specified id, classes or attributes. See [docs](https://bookdown.org/yihui/rmarkdown-cookbook/custom-blocks.html#custom-blocks) for detailed description. Above we use custom blocks to tag each block with `id="translate"` and `lang` attribute set to `en` or `fr`. The CSS styling will then hide all `translate` blocks except the one which matches the `lang` parameter.

This syntax enables writing R Markdown as normal, no need for calls to `cat` or to manually manage formatting. It gives an easy way to add a second language to an existing document as you just need to surround existing code with `:::` and add the second language below. The downside is this will run every block of code and hide the sections for languages not being used. Because of this it is not the best choice for documents with plots or operations which take a long time to compute. This approach will only work if the target output is HTML as it relies on CSS for styling.

To translate the title adding a YAML header within each custom block will not work. As all custom blocks are read, both titles will be read and only the last one will be displayed. We have to work around this by including some conditional to set title in a single YAML header.

## Tabset

[R Markdown tabsets](https://bookdown.org/yihui/rmarkdown-cookbook/html-tabs.html#html-tabs) can be used to make multiple translations available in one document and enable users to switch between languages.

````r
---
title: "Main title"
---

# Language {.tabset .tabset-dropdown}

## English

<h1>English Title</h1>

Plot of random points

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Random points")
```

## French

<h1>Titre Français</h1>

Tracé de points aléatoires

```{r, echo=FALSE}
plot(runif(10), runif(10), main = "Points aléatoires")
```
````

<img src="/img/translating-rmd.gif" alt="Translating R Markdown with tabset" />

Like using custom blocks, a tabset lets us write R Markdown as we would for a single language. We can still take advantage of syntax highlighting in RStudio and R Markdown managing the formatting of text. Using `.tabset .tabset-dropdown` allows users to switch between translations in the output document via a dropdown menu. This has the same disadvantage as custom blocks, it runs all code and so will be slower than using code chunks.

The main title of the document won't be translated here, but we can include a heading for each tab which will be translated. To achieve this we need to use HTML heading tags e.g. `<h1>` as if we try to use standard R Markdown `#` this will break the tabbing.

## Conclusion

When translating R Markdown in production projects we've used a mix of approaches. Custom blocks provide a good way to translate large sections of text as they enable us to take advantage of automatic formatting and syntax highlighting. Combining with code chunks for translating slow-to-produce plots enables us to keep the generation of documents performant.

The problem with all the methods above is they don't scale well. They work fine for 2 or 3 languages but if you want to provide translations for more than this then the document starts to get complicated with large amounts of duplicated code. There is a more scalable approach detailed in [StatnMap blog post](https://statnmap.com/2017-10-06-translation-rmarkdown-documents-using-data-frame/) which uses a data frame of strings which can scale by adding a new column for each new language desired. The cost of this is the R Markdown document is difficult to read and so hard to maintain. If we want to expand to support more languages we will need to investigate a different scalable approach to minimise the duplication seen in the above methods whilst keeping the markdown readable.
