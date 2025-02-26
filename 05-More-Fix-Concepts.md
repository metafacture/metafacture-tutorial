# Lesson 6: More Fix concepts

We already learned about simple Fixes (or Fix Functions) but there are three additional concepts in Fix selector, conditionals and binds.
These Fix concepts were introduced by Catmandu (see [functions](https://librecat.org/Catmandu/#functions), [selector](https://librecat.org/Catmandu/#selectors), [conditionals](https://librecat.org/Catmandu/#conditionals) and [binds](https://librecat.org/Catmandu/#binds)). But be aware Metafacture Fix does not support all of the specific functions, selectors, conditionals and binds from Catmandu. Check the documentation for an full overview of the supported [fix functions](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#functions).

## Additional concepts

The following code snippet shows examples of eachs of these concepts:

```PERL
# Simple fix function

add_field("hello", "world")
remove_field("my.deep.nested.junk")
copy_field("stats", "output.$append")

# Conditionals

if exists("error")
  set_field("is_valid", "no")
  log("error")
elsif exists("warning")
  set_field("is_valid", "yes")
  log("warning")
else
  set_field("is_valid", "yes")
end

# Binds - Loops

do list(path: "foo", "var": "$i")
  add_field("$i.bar", "baz")
end

# Selector
if exists("error")
   reject()
end
```

We already got to know simple fixes aka *[Functions](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#functions)*. They are used to add, change, remove or otherwise manipulate elements. Simple fixes were introduced in [Lesson 3](./03_Introduction_into_Metafacture-Fix.md).

The other three concepts help when you intend to use more complex transformations:

*[Conditionals](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#conditionals)* are used to control the processing of fix functions. The included fix functions are not process with every workflow but only under certain conditions.

*[Selectors](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#selectors)* can be used to filter the records you want.

*[Binds](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#binds)* are wrappers for one or more fixes. They give extra control functionality for fixes such as loops. All binds have the same syntax:

```PERL
do Bind(params,…)
   fix(..)
   fix(..)
end
```

## Conditionals

Conditionals are a common concept in programming and scripting languages. They control processes, in our scenario: transformations, with regard to specific requirements.

e.g. [we have records some of them are of type book](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=add_field%28%22type%22%2C%22BibliographicResource%22%29&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22):

```YAML
---
name: "The 13 1/2 lives of Captain Bluebear"
medium: "Book"
author: "Walter Moers"
language: "eng"

---
name: "The 13 1/2 lives of Captain Bluebear"
medium: "eBook"
author: "Walter Moers"
language: "eng"

---
name: "Die 13½ Leben des Käpt’n Blaubär"
medium: "Book"
author: "Walter Moers"
language: "ger"

---
name: "The 13 1/2 lives of Captain Bluebear"
medium: "Audio Book"
author: "Walter Moers"
narrator: "Bronson Pinchot"
language: "eng"

---
name: "Käpt'n Blaubär - Der Film"
medium: "Movie"
author: "Walter Moers"
director: "Hayo Freitag"
language: "ger"
```

If we want to add an element e.g. type for every record. Then we simply use the fix function `add_field("type","BibliographicResource")`

But if you want to add more specific type depending on the type, then we use contitionals:

e.g.:

only `add_field("type","BibliographicResource")` [if the medium contains Book](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+all_contain%28%22medium%22%2C%22Book%22%29%0A++++add_field%28%22type%22%2C%22BibliographicResource%22%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22):

```PERL
if all_contain("medium","Book")
    add_field("type","BibliographicResource")
end
```

or [only if medium is exact](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+all_equal%28%22medium%22%2C%22Book%22%29%0A++++add_field%28%22type%22%2C%22BibliographicResource%22%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22):

```PERL
if all_equal("medium","Book")
    add_field("type","BibliographicResource")
end
```


Conditionals usually have the same syntax pattern:

```PERL
if conditional("Parameter1","Parameter2")
  fix-functions
end
```

[If you want to add transformations for all that do not meet the condition with `unless`:](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=unless+all_equal%28%22medium%22%2C%22Book%22%29%0A++++add_field%28%22type%22%2C%22Other%22%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22)

```PERL
unless all_equal("medium","Book")
    add_field("type","Other")
end
```

[You can also use conditionals `if` they meet the requirements and handle all others differently with `else`:](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+all_equal%28%22medium%22%2C%22Book%22%29%0A++++add_field%28%22type%22%2C%22BibliographicResource%22%29%0Aelse%0A++++add_field%28%22type%22%2C%22Other%22%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22)

```PERL
if all_equal("medium","Book")
    add_field("type","BibliographicResource")
else
    add_field("type","Other")
end
```

[You can also use conditionals `if` they meet the requirements and handle all others differently with an additionl conditionals with `elsif` and the rest with `else`:](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+all_equal%28%22medium%22%2C%22Book%22%29%0A++++add_field%28%22type%22%2C%22BibliographicResource%22%29%0Aelsif+all_contain%28%22medium%22%2C%22Audio%22%29%0A++++add_field%28%22type%22%2C%22AudioResource%22%29%0Aelsif+all_match%28%22medium%22%2C%22.%2AMovie.%2A%22%29%0A++++add_field%28%22type%22%2C%22AudioVisualResource%22%29%0Aelse%0A++++add_field%28%22type%22%2C%22Other%22%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22)

```PERL
if all_equal("medium","Book")
    add_field("type","BibliographicResource")
elsif all_contain("medium","Audio")
    add_field("type","AudioResource")
elsif all_match("medium",".*Movie.*")
    add_field("type","AudioVisualResource")
else
    add_field("type","Other")
end
```

Metafacture supports lots of conditionals, find a list of all of them [here](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#conditionals).

Hint: Some conditionals have variations with `all_`, `any_` or `none` while they behave in the same way if you process them on simple string-elements. They also can be used with arrays/lists then the conditional has different out-come depending on the fact that all (`all_`) or at least one (`any_`) value of an array matches the requierement. `none` checks if the conditionally does not match.

## Selectors

At the moment Metafacture Fix only supports one of Catmandus selectors: `reject`. With `reject` you can kick out records that you do not want to process:

```PERL
if all_contain("medium","Book")
    reject()
end
```

[This Fix used with our example above kicks out all records containing the word Book.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+all_contain%28%22medium%22%2C%22Book%22%29%0A++++reject%28%29%0Aend&data=---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22eBook%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22Die+13%C2%BD+Leben+des+K%C3%A4pt%E2%80%99n+Blaub%C3%A4r%22%0Amedium%3A+%22Book%22%0Aauthor%3A+%22Walter+Moers%22%0Alanguage%3A+%22ger%22%0A%0A---%0Aname%3A+%22The+13+1/2+lives+of+Captain+Bluebear%22%0Amedium%3A+%22Audio+Book%22%0Aauthor%3A+%22Walter+Moers%22%0Anarrator%3A+%22Bronson+Pinchot%22%0Alanguage%3A+%22eng%22%0A%0A---%0Aname%3A+%22K%C3%A4pt%27n+Blaub%C3%A4r+-+Der+Film%22%0Amedium%3A+%22Movie%22%0Aauthor%3A+%22Walter+Moers%22%0Adirector%3A+%22Hayo+Freitag%22%0Alanguage%3A+%22ger%22)

Selectors work in combination with conditionals to define the conditions that you want to kick out.

For the supported selectors see: https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#selectors

## Binds

As mentioned above [Binds](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md#binds)* are wrappers for one or more fixes. They give extra control functionality for fixes such as loops. All binds have the same syntax:

```PERL
do Bind(params,…)
   fix(..)
   fix(..)
end
```

The most commonly used is `do list`. It allows to iterate over each element of an array.

If we have a record:

```YAML
---
colours:
 - red
 - yellow
 - green
```

and you use the fix

```PERL
add_array("result") # To create a new array named result

upcase("colours[].*")
append("colours[].*"," is a nice color")
copy_field("colours[].*","result.$append")
```

It [results](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=replace_all%28%22colours%5B%5D.%2A%22%2C%22e%22%2C%22X%22%29&data=---%0Acolours%3A%0A+-+red%0A+-+yellow%0A+-+green) in:

```YAML
---
colours:
- "RED is a nice color"
- "YELLOW is a nice color"
- "GREEN is a nice color"
result: "RED is a nice color"
result: "YELLOW is a nice color"
result: "GREEN is a nice color"
```

If you want to only change it, under a certain condition:

```PERL
if any_equal("colours[]","green")
  add_array("result[]") # To create a new array named result
  upcase("colours[].*")
  append("colours[].*"," is a nice color")
  copy_field("colours[].*","result[].$append")
end
```

[This still transforms the all elements of an array because the conditional tests all elements not each individually.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=if+any_equal%28%22colours%5B%5D%22%2C%22green%22%29%0A++add_array%28%22result%22%29+%23+To+create+a+new+array+named+result%0A%0A++upcase%28%22colours%5B%5D.%2A%22%29%0A++append%28%22colours%5B%5D.%2A%22%2C%22+is+a+nice+color%22%29%0A++copy_field%28%22colours%5B%5D.%2A%22%2C%22result.%24append%22%29%0Aend&data=---%0Acolours%3A%0A+-+red%0A+-+yellow%0A+-+green)
To only tranform and copy the value `green` to an X you have to use the `do list`-Bind:

```PERL
do list(path:"colours[]","var":"$i")
    if any_equal("$i","green")
        add_array("result[]") # To create a new array named result
        upcase("$i")
        append("$i"," is a nice color")
        copy_field("$i","result[].$append")
    end
end
```

[See this example here in the playground.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+decode-yaml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=do+list%28path%3A%22colours%5B%5D%22%2C%22var%22%3A%22%24i%22%29%0A++++if+any_equal%28%22%24i%22%2C%22green%22%29%0A++++++++add_array%28%22result%5B%5D%22%29+%23+To+create+a+new+array+named+result%0A++++++++upcase%28%22%24i%22%29%0A++++++++append%28%22%24i%22%2C%22+is+a+nice+color%22%29%0A++++++++copy_field%28%22%24i%22%2C%22result%5B%5D.%24append%22%29%0A++++end%0Aend&data=---%0Acolours%3A%0A+-+red%0A+-+yellow%0A+-+green)

TO BE CONTINUED ...

TODO: Add more Excercises.

Next lesson: [06 Metafacture CLI](./06_MetafactureCLI.md)
