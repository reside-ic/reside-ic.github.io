---
title: "Frictionless Data Package Validation in R"
date: 2023-03-30
author: Rob Ashton
tags:
 - R
 - frictionless
 - data
 - validation
---

Our work often involves researcher-written models that we want to make available to non-technical users. To ensure that both the model will run and that it will produce a good fit, validating users' data and returning actionable error messages is essential. For the [UNAIDS Naomi project](/projects/naomi) we collaborate closely with a team that manages data storage for users. They use [Frictionless Data Packages](https://frictionlessdata.io/) for describing the resources that need to be present and validating them. When users upload their data to our application, we run separate validation code written in R. It would be ideal to validate with a common code base to avoid duplicated work and ensure consistency in messaging.

One way we could support this is by using the [Frictionless Data Package](https://frictionlessdata.io/) schema developed by our partners to validate the data from R. This blog post is an exploration of the capabilities of Frictionless for validation from R.

Our current validation workflow, which any Frictionless solution would need to support, is as follows. The user uploads files of different types including tabular data (as CSVs), geojson and more exotic types such as [PJNZ](https://mrc-ide.github.io/specio/articles/pjnz.html) (a zip with files containing hybrid xml & csv data). The checks we run on these range from very simple assertions to more complicated and bespoke ones. Simple assertions include checking that data has certain column, the values in the columns are from a set of possible values, and that a column is numeric, positive numeric or matches a regex pattern. More complicated checks include ensuring that geojson has a single parent region, that every feature in geojson has a property with a certain name, that there is a single row for each combination of some category columns. We also sometimes want to validate across two files for example to check that the values in a CSV column match one of the properties from a geojson file.
 
In this post we will look at two R packages for working with Frictionless Data Packages: `frictionless` and `datapackage.r`. Both are developed by Frictionless Data organisation. 

## Frictionless

`frictionless` is relatively new, available on CRAN, peer-reviewed by [rOpenSci](https://ropensci.org) and under active development. However, note that the [package is not designed to offer "full validation"](https://github.com/frictionlessdata/frictionless-r/issues/125#issuecomment-1477422737) which will be somewhat limiting. It does have some checking against the table schema, so let's explore what is possible. Firstly the `frictionless` R package will only work with data stored on disk like

```
package_name
├── datapackage.json
├── file1.csv
└── file2.csv
```

there is no option to supply a `datapackage.json` and load data from elsewhere.

The package json contains a [table schema](https://specs.frictionlessdata.io/table-schema/) for each resource which allows specifying the columns, their `type` and any `constraints` on the column. One of the validation checks we want is to ensure that the types in a column are correct. If we try and read a resource using `frictionless` which has an invalid type we will get a warning like

```R
Warning message:                                                                                                                                                                      
One or more parsing issues, call `problems()` on your data frame for details, e.g.:
  dat <- vroom(...)
  problems(dat) 
```

And running `vroom::problems()` we see

```R
> vroom::problems()
# A tibble: 1 × 5
     row   col expected actual file               
   <int> <int> <chr>    <chr>  <chr>
 1     1    3 a double hello  /path/to/file.csv
```

We can see the row and column with the invalid type, and we can also see the actual value and the expected type. This is useful information but it isn't a straightforward message we can surface to the end user. It will still require some work to build an error string from the returned information.

Let's try adding a `constraint` to our table schema to ensure that a column's values match a set of possible values. If we load some invalid data using this schema, again we get a warning which if when we run `vroom::problems()` we can see the details of

```R
# A tibble: 1 × 5
     row   col expected           actual   file 
   <int> <int> <chr>              <chr>    <chr>
 1     1     1 value in level set other    ""  
```

Again `frictionless` tells us the offending row and column and the value found in that column, but it doesn't tell us what possible values it could have taken, making it less actionable. The end user would need to have knowledge of the schema to be able to fix this.

This seems to be about the limit of what the `frictionless` R package can do in terms of validation. It doesn't support a `validation` function and the developers don't plan on adding it in the future. It looks like the package isn't quite intended for our use case. 

It also does not support some of our other use cases. The `frictionless` R package can only handle tabular data, not geojson. And the current implementation at the time of writing does not support `missingValues` from the [table schema spec](https://specs.frictionlessdata.io/table-schema/#missing-values) which would be essential in R for working with `NA` values.

## datapackage.r

The second package `datapackage.r` is also developed by the Frictionless Data organisation. This is an older package and looks to be out of active development in favour of new `frictionless` package. It does however offer validation by using the `tableschema.r` package.

This works in a similar way to the `frictionless` package to create and modify Frictionless data packages. Like with `frictionless`, validation against the schema is done when we read the data. If we try to read a data package containing a resource which is missing column we get an error when calling `read()` like

```a
Error: Table headers don't match schema field names
```

This also does not look very actionable — which table headers don't match? Are some missing? Are they misspelled? This combined with the fact that the package is not under active development doesn't make this a compelling option.

## Reticulate

Another possibility would be using the Python validation code directly via [reticulate](https://rstudio.github.io/reticulate/). The Python implementation does support a wide range of build in checks and has ability to specify [custom checks](https://framework.frictionlessdata.io/docs/guides/validating-data.html#custom-checks). Additionally, it supports validation for JSON files, and other file types can be supported using plugins.

While Frictionless data packages in Python offer lots of flexibility, reproducing our current suite of validation checks would require a significant amount of effort. 

## Conclusion

After investigating the available R packages for validating Frictionless Data packages, we found they lack the functionality we require. The `frictionless` package, which mainly focuses on package reading and writing, lacks a `validate` function, and its schema checking feature does not produce actionable errors. The `datapackage.r` package is no longer being actively developed and the validation it does have does not always return actionable errors. Using the Frictionless Python package directly would require a significant amount of work to create plugins for handling all file types, develop custom checks that fulfill all validation requirements and build a reticulate wrapper to enable its use from R. If our aim is to have a common code base for validation we could also explore shipping a docker container with a simple API wrapping our R checks which can be deployed anywhere it is needed. This approach would offer the reusability we want while minimising the need for building custom plugins and validation checks in Frictionless.
