In the last session we learned about FLUX-Moduls.
Flux-Moduls can do a lot of things but the main transformation of incoming data at record-, elemenet- and value-level are done by the transformation moduls: `fix` or `morph`

What do we mean when we talk about transformation:
e.g.
 * Manipulating elementnames and elementvalues
 * Change hierachies and structures of records
 * Lookup values in concordance list. 

But not changing serialization that is part of encoding and decoding.

In this tutorial I focus on Fix. If you want to learn about Morph have a look at https://slides.lobid.org/metafacture-2020/#/

So dive into Metafacture Fix. Lets get back to the Playground. Clear it if needed and paste the following Flux in the Flux window.

```
"https://fcc-weather-api.glitch.me/api/current?lat=50.93414&lon=6.93147"
| open-http
| as-lines
| decode-json
| fix ("retain('name')")
| encode-yaml
| print;
```

You should end up with something like:

---
name: Cologne
...

The `fix` module in Metafacture is used to manipulate the input data filtering fields we would like to see. Only one fix-function was used: `retain`, which throws away all the data from the input except the ‘name’ field.

TODO: This should be changed when subfields can be retained.

Also add the info that is written in `main`


```
"https://fcc-weather-api.glitch.me/api/current?lat=50.93414&lon=6.93147"
| open-http
| as-lines
| decode-json
| fix ("retain('name', 'main')")
| encode-yaml
| print;
```

You should now see something like this:

---
main:
  temp: "15.99"
  feels_like: "15.21"
  temp_min: "14.55"
  temp_max: "16.99"
  pressure: "1017"
  humidity: "60"
name: "Cologne"

When manupilating data you often need to create many fixes to process a data file in the format you need. With a text editor you can write all fix functions in a singe separate fix-file.

In your playground move the fix-function to the separate fix window. Like this

Fix:
```
retain("name", "main")
```

images/2022-06-01_20-14.png

With this separate fix-file it will be a bit easier to write many fix-functions and it does not overcrowd the flux-workflow.

To add more fixes we can again edit fix file. 
And add these lines in front of the retain function:

```
move_field("main.temp", "temp")
```

Also change the retain funcation, that you only keep `"name"` and `"temp"` and not `"main.temp"` any more.

```
move_field("main.temp","temp")
retain("name", "temp")
```

The output should be something like this:

```
---
name: "Cologne"
temp: "16.29"
```

So with `move_field` we moved and renamed an existing element.
As next step add the following function before the `retain` function.

```
prepend("temp","The temperature is ")
append("temp"," degrees Kelvin")
```

If you execute your last workflow again.

You should now see as ouput:

```
---
name: "Cologne"
temp: "The temperature is 16.29 degrees Kelvin"
```

Metafacture contains many fix-function to manipulate data.
Also there are many flux-commands/modules that can be used.

Check the documentation to get a complete list. This post only presented a short introduction into Metafacture. In the next posts we will go deeper into its capabilities.

Continue to Day 7: Metafacture Fix paths >>
