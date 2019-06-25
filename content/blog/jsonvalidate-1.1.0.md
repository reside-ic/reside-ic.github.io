---
title: "jsonvalidate 1.1.0"
date: 2019-06-25T07:38:50+01:00
draft: true
---

[JSON](https://www.w3schools.com/js/js_json_intro.asp) is useful as a data-interchange format, due to the massive popularity of javascript.  Basically every language supports reading and writing JSON now, so it makes a nice lowest common denominator.

When generating JSON from an application, it is useful to be able to describe how the data is structured - so if we return output like

```
{
    "id": 1,
    "name": "A green door",
    "price": 12.50,
    "tags": ["home", "green"]
}

```

We might describe it in words like:

> The return value will be a dictonary with an element `id` that is a number, and an array `tags`, each element of which is a character, an element `price` whch is a number, and an element `name` which is a string

which is fine but impossible to write tools for.  So [JSON Schema](https://json-schema.org/) was created for machine-readable descriptions of json objects.  Naturally, JSON Schema is written in JSON (like [XML Schema](https://www.w3.org/standards/xml/schema) before it was written in XML).

A schema for the above structure might look like:

```
{
    "$schema": "http://json-schema.org/draft-04/schema#",
    "title": "Product",
    "description": "A product from Acme's catalog",
    "type": "object",
    "properties": {
        "id": {
            "description": "The unique identifier for a product",
            "type": "integer"
        },
        "name": {
            "description": "Name of the product",
            "type": "string"
        },
        "price": {
            "type": "number",
            "minimum": 0,
            "exclusiveMinimum": true
        },
        "tags": {
            "type": "array",
            "items": {
                "type": "string"
            },
            "minItems": 1,
            "uniqueItems": true
        }
    },
    "required": ["id", "name", "price"]
}
```

With this, we can check that our return values have the expected type in automated testing, making our software more reliable when reused.  We can also us it to validate incoming json and rely on a json schema validator to do the hard work of checking the data makes sense.

We have released to CRAN an update to the R package `jsonvalidate`, an R package for working with JSON schema.  This update adds support for the [`ajv`](https://github.com/epoberezkin/ajv) JSON Schema validator (in addition to the previously present [`is-my-json-valid`](https://github.com/mafintosh/is-my-json-valid)).

We use `jsonvalidate` for [validating responses returned by an HTTP API](https://github.com/vimc/orderly.server/blob/e4a619d2bd1f7e810e7c3ba378bb393cee0be08c/tests/testthat/helper-orderly.server.R#L56-L64) and for [validating the intermediate representation used by `odin`](https://github.com/mrc-ide/odin/blob/1bae83c4d8ccab6f82126f5270c13d3ffcbc9c19/R/ir_validate.R)

The `ajv` library includes support for draft 06 and 07 of JSON schema which includes [lots of new features](https://json-schema.org/draft-07/json-schema-release-notes.html).  Getting this into the package in a backward compatible way was possible with the help of [Kara Woo](https://karawoo.com/) and [Ian Lyttle](https://github.com/ijlyttle).
