TODO: This session should be split into two sessions. One into Metafacture Flux and one into Metafacture Fix.
TODO: Use this https://api.open-meteo.com/v1/forecast?latitude=50.93&longitude=6.92&hourly=temperature_2m&current_weather=true&timezone=Europe%2FBerlin API.

If you know how to use the command line Metafacture can easily be used. 
Other ways to use Metafacture is as a JAVA library or with the Playground.

In this lesson we will introduce you to a UNIX command we have created for metafacture. The metafacture command is used to run a flux script and to process structured information.  To demo this command, as always, you need to startup your Virtual Catmandu (hint: see our day 1 tutorial) and start up the UNIX prompt (hint: see our day 2 tutorial).

In this tutorial we are going to process structured information. We call data structured when it organised in such a way is that it easy processable by computers. Literary text documents like War and Peace are structured only in words and sentences, but a computer doesn’t know which words are part of the title or which words contain names. We had to tell the computer that. Today we will download a weather report in a structured format called JSON and inspect it with the command catmandu.

At the UNIX prompt type in this command:

```
$ curl https://gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json
```


You will see a JSON output like:

{"coord":{"lon":3.72,"lat":51.05},"sys":{"type":3,"id":4839,"message":0.0349,"country":"BE",
"sunrise":1417159365,"sunset":1417189422},"weather":[{"id":500,"main":"Rain","description":"light rain",
"icon":"10d"}],"base":"cmc stations","main":{"temp":281.15,"pressure":1006,"humidity":87,"temp_min":281.15,
"temp_max":281.15},"wind":{"speed":3.6,"deg":100},"rain":{"3h":0.5}
,"clouds":{"all":56},"dt":1417166878,"id":2797656,
"name":"Gent","cod":200}

All these fields tell something about somedays weather in Gent, Belgium. You can recognise that there is a light rain and the temperature is 281.15 degrees Kelvin (about 8 degrees Celsius).  Write the output of this command to a file weather.json (using the ‘>’ sign we learned in the day 5 tutorial) so that we can use it in the next examples.

```
$ curl https://gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json > weather.json
```

When you type the `ls` command you should see the new file name weather.json appearing.

With the metafacture command you can process this file to make it a bit easier readable by using a small workflow script. For instance type:

`$ ~/metafacture/flux.sh sample1.flux`

sample1.flux:
```
"https://gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json"
| open-http(accept="application/json")
| as-lines
| decode-json
| encode-yaml(prettyprinting="True")
| print;
```

$ catmandu convert JSON to YAML < weather.json

https://metafacture.org/playground/?flux=%22https%3A//gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json%22%0A%7C+open-http%28accept%3D%22application/json%22%29%0A%7C+as-lines%0A%7C+decode-json%0A%7C+encode-yaml%28prettyprinting%3D%22True%22%29%0A%7C+print%3B&active-editor=fix

You also can process the file that you saved:
sample2.flux:
```
"weather.json"
| open-file
| as-lines
| decode-json
| encode-yaml(prettyprinting="True")
| print;
```

YAML is another format for structured information which is a bit easier to read for human eyes. Our weather report should now look like this:

Screenshot_28_11_14_11_06

Metafacture can be used to process structured information like the UNIX grep command can process unstructured information. For instance lets try to filter out the name of this report. Type in this command:

sample3.flux:
```
"weather.json"
| open-file
| as-lines
| decode-json
| fix ("retain('name')")
| encode-yaml(prettyprinting="True")
| print;
```

You should end up with something like:

---
name: Gent
...

The `fix` module in Metafacture is used to manipulate the input weather.json filtering fields we would like to see. Only one fix-function was used ‘retain’, which throws away all the data from the input except the ‘name’ field. By the way, the file `weather.json` wasn’t changed! We only read the file and displayed the output of the metafacture worklfow which is provided by the `print` command.

TODO: Is this really necessary?
The temperature in Gent is the in ‘temp’ part of the ‘main’ section in `weather.json`. To filter this out we need two `retain` fixes: one for the main section, one for the temp section:

sample3.flux:
```
"weather.json"
| open-file
| as-lines
| decode-json
| fix ("retain(main); retain(main.temp)")
| encode-yaml(prettyprinting="True")
| print;
```

You should now see something like this:

---
main:
  temp: 281.15
...

When manupilating data you often need to create many fixes to process a data file in the format you need. With a text editor you can write all fix functions in a singe separate fix-file.


In your texteditor type now the two fixes above:

```
retain(main.temp)
```

Save this as weather.fix file.

With this separate fix-file it will be a bit easier to write many fix-functions and it does not overcrowd the flux-workflow. The name of the fix file can be used to repeat the commands above:

$ catmandu convert JSON --fix weather.fix to YAML < weather.json

weather.fix
```
retain(main.temp)
```

```
"weather.json"
| open-file
| as-lines
| decode-json
| fix ("weather.fix")
| encode-yaml(prettyprinting="True")
| print;
```


To add more fixes we can again edit the weather.fix file. 
And add these lines after the previous line:


prepend(main.temp,"The temperature is")
append(main.temp," degrees Kelvin")

If you execute your last workflow again.

You should now see as ouput:

---
main:
  temp: The weather is 281.15 degrees Kelvin
...

Metafacture contains many fix-function to manipulate data.
Also there are many flux-commands/modules that can be used.

 Check the documentation to get a complete list. This post only presented a short introduction into catmandu. In the next posts we will go deeper into its capabilities.

Continue to Day 7: Catmandu JSON paths >>
