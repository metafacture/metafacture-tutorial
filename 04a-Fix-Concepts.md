We already learned about simple Fixes (or Fix Functions) but there are three additional concepts in Fix selector, conditionals and binds. 
These Fix concepts were introduced by Catmandu (see [functions](https://librecat.org/Catmandu/#functions), [selector](https://librecat.org/Catmandu/#selectors), [conditionals](https://librecat.org/Catmandu/#conditionals) and [binds](https://librecat.org/Catmandu/#binds)).

The following code snippet shows examples of eachs of these concepts:

```
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



*Functions* are used to add, change, remove or otherwise manipulate elements.

*Conditionals* are used to control the processing of fix functions. The included fix functions are not process with every workflow but only under certain conditions.

*Selectors* can be used to filter the records you want.

*Binds* are wrappers for one or more fixes. They give extra control functionality for fixes such as loops. All binds have the same syntax:

```
do Bind(params,…)
   fix(..)
   fix(..)
end
```

Find here [a list of all functions, selectors, binds and conditionals](https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md)https://github.com/metafacture/metafacture-documentation/blob/master/Fix-function-and-Cookbook.md.


