# Lesson 3: Introduction into Metafacture Fix

In the last session we learned about Flux-Moduls.
Flux-Moduls can do a lot of things. They configure the the "high-level" transformation pipeline.

But the main transformation of incoming data at record-, elemenet- and value-level is usually done by the transformation moduls: `fix` or `morph` as one step in the pipeline.

What do we mean when we talk about transformation, e.g.:

* Manipulating element-names and element-values
* Change hierachies and structures of records
* Lookup values in concordance list.

But not changing serialization that is part of encoding and decoding.

In this tutorial we focus on Fix. If you want to learn about Morph have a look at https://slides.lobid.org/metafacture-2020/#/


## Metafacture Fix and Fix Functions

So let's dive into Metafacture Fix and get back to the [Playground](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+encode-yaml%0A%7C+print%0A%3B).

Clear it if needed and paste the following Flux in the Flux-File area.

```
"https://openlibrary.org/books/OL2838758M.json"
| open-http
| as-lines
| decode-json
| fix ("retain('title')")
| encode-yaml
| print
;
```

You should end up with something like:

```YAML
---
title: "Ordinary vices"
```

The `fix` module in Metafacture is used to manipulate the input data filtering fields we would like to see. Only one fix-function was used: `retain`, which throws away all the data from the input except the stated `"title"` field. Normally all incoming data is passed through, unless it is somehow manipulated or a `retain` function is used.

HINT: As long as you embedd the fix functions in the Flux Workflow, you have to use double quotes to fence the fix functions,
and single quotes in the fix functions. As we did here: `fix ("retain('title')")`

Now let us additionally keep the info that is given in the element `"publish_date"` and in the subfield `"key"` as well as the subfield `"key"` in `'type'` by adding `'publish_date', 'type.key'` to `retain`:

```
"https://openlibrary.org/books/OL2838758M.json"
| open-http
| as-lines
| decode-json
| fix ("retain('title', 'publish_date', 'type.key')")
| encode-yaml
| print
;
```

You should now see something like this:

```YAML
---
title: "Ordinary vices"
publish_date: "1984"
type:
  key: "/type/edition"

```

When manipulating data you often need to create many fixes to process a data file in the format and structure you need. With a text editor you can write all fix functions in a singe separate fix-file.

The playground has an transformationFile-content area that can be used as if the fix is in a separate file.
In the playground we use the variable `transformationFile` to adress the fix file in the playground.

Like this.

![image](images/outsourcedFix.png)

Fix:

```PERL
retain("title", "publish_date", "type.key")
```

With this separate fix-file it will be a bit easier to write many fix-functions and it does not overcrowd the flux-workflow.

To add more fixes we can again edit the fix file. 
Lets add these lines in front of the retain function:

```
move_field("type.key", "pub_type")
```

Also change the `retain` function, so that you keep the new element  `"pub_type"` instead of the not existing nested `"key"` element.

```
move_field("type.key","pub_type")
retain("title", "publish_date", "pub_type")
```

The output should be something like this:

```YAML
---
title: "Ordinary vices"
publish_date: "1984"
pub_type: "/type/edition"
```

So with `move_field` we moved and renamed an existing element.
As next step add the following function before the `retain` function.

```
replace_all("pub_type","/type/","")
```

If you execute your last workflow with the Process-Button again, you should now see as ouput:

```YAML
---
title: "Ordinary vices"
publish_date: "1984"
pub_type: "edition"
```

We cleaned up the `"pub_type"` element, so that we can better read it.

[See the example in the playground.](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+fix+%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22type.key%22%2C%22pub_type%22%29%0Areplace_all%28%22pub_type%22%2C%22/type/%22%2C%22%22%29%0Aretain%28%22title%22%2C+%22publish_date%22%2C+%22pub_type%22%29)

Metafacture contains many fix function to manipulate data. Also there are many flux commands/modules that can be used.

Check the documentation to get a complete list of [flux command](https://github.com/metafacture/metafacture-documentation/blob/master/flux-commands.md) and [fix functions](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#functions). This post only presented a short introduction into Metafacture. In the next posts we will go deeper into its capabilities.

Besides fix functions you can also add as many comments and linebreaks as you want to a fix.

Comments are good if you want to add descriptions to you transformation. Like the following.
Comments in Fix start with a hashtag `#`, while in Flux they start with `//`

e.g.:

```
# Make type.key a top level element.
move_field("type.key","pub_type")

# Clean the value of `pub_type`
replace_all("pub_type","/type/","")

# Keep only specific elements.
retain("title", "publish_date", "pub_type")
```

## Excercise

1) [Additionally keep the `"by_statement"`. Hint: Add something to `retain`](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+fix+%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22type.key%22%2C%22pub_type%22%29%0Areplace_all%28%22pub_type%22%2C%22/type/%22%2C%22%22%29%0Aretain%28%22title%22%2C+%22publish_date%22%2C+%22pub_type%22%29)

2) [Add a field with todays date called `"map_date"`.](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+fix+%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22type.key%22%2C%22pub_type%22%29%0Areplace_all%28%22pub_type%22%2C%22/type/%22%2C%22%22%29%0A...%28%22mape_date%22%2C%22...%22%29%0Aretain%28%22title%22%2C+%22publish_date%22%2C+%22by_statement%22%2C+%22pub_type%22%29)

Have a look at the fix functions: https://metafacture.org/metafacture-documentation/docs/fix/Fix-functions.html (Hint: you could use `add_field` or `timestamp`. And don't forget to add the new element to `retain`)


<details>
<summary>Answer</summary>
[See here](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+fix+%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22type.key%22%2C%22pub_type%22%29%0Areplace_all%28%22pub_type%22%2C%22/type/%22%2C%22%22%29%0Aadd_field%28%22mape_date%22%2C%222025-11-11%22%29%0Aretain%28%22title%22%2C+%22publish_date%22%2C+%22by_statement%22%2C+%22pub_type%22%29)

or [use timestamp](https://metafacture.org/playground/?flux=%22https%3A//openlibrary.org/books/OL2838758M.json%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+fix+%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22type.key%22%2C%22pub_type%22%29%0Areplace_all%28%22pub_type%22%2C%22/type/%22%2C%22%22%29%0Atimestamp%28%22mape_date%22%2Cformat%3A%22yyyy-MM-dd%27T%27HH%3Amm%3Ass%22%2C+timezone%3A%22Europe/Berlin%22%29%0Aretain%28%22title%22%2C+%22publish_date%22%2C+%22by_statement%22%2C+%22pub_type%22%29)
</details>

Next lesson: [04 Fix Path](./04_FIX-Path.md)
