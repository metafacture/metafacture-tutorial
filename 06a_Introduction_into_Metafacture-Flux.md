If you know how to use the command line Metafacture can easily be used.  Other ways to use Metafacture is as a JAVA library or with the Playground.

In this lesson we start with the playground. The commandline handling will be subject to a later lesson.


The [Metafacture Playground](https://metafacture.org/playground) is a webinterface to test and share Metafacture. For this introduction we will start with the Playground since it allows a quick start without additional installing. 

In this tutorial we are going to process structured information. We call data structured when it organised in such a way is that it easy processable by computers. Literary tex t documents like War and Peace are structured only in words and sentences, but a computer doesn’t know which words are part of the title or which words contain names. We had to tell the computer that. Today we will download a weather report in a structured format called JSON and inspect it with the command catmandu.


Lets jump to the Playground to learn how to create workflows:

images/2022-06-01_15-41.png

See the window called Flux? 

```
"Hello, friend. I'am Metafacture!"
|print
;
```

Copy this short code sample [into the playground](https://metafacture.org/playground/?flux=%22Hello%2C+friend.+I%27am+Metafacture%21%22%0A%7Cprint%0A%3B&active-editor=fix). Great, you have your first Metafacture Flux Workflow. Congratulations.
Now you can press the `Process`-Button or press Ctrl+Enter to execute the workflow.

See the result below? It is `Hello, friend. I'am Metafacture!`.

But what have we done here? 
We have a short text string `"Hello, friend. I'am Metafacture"`. That is printed with the modul `print`.
A Metafacture Workflow is nothing else as a incoming text string with multiple moduls that do something with the incoming string.
But the workflow does not have to start with a text string but also can be a variable that stands for the text string and needs to be defined before the workflow. As this:

```
INPUT="Hello, friend. I'am Metafacture!";

INPUT
|print
;
```

Copy this into the FLUX window of your playground or just adjust your example.

`INPUT` as a varibale is defined in the first line of the flux. And instead of the text string, the Flux-Workflow starts just with the variable `INPUT` without `"`.

But the result is the same if you process the flux.

The Playground has a special variable called `PG_DATA`. In the Playground it can be used at the beginning
of the workflow and it refers to the input that is written in the Data-window of the playground.

images/2022-06-01_18-18.png

So lets use `PG_DATA` instead of `INPUT` and copy the value of the text string in the Data field above the Flux.

Data:
`Hello, friend. I'am Metafacture!`

Flux:
```
PG_DATA
|print
;
```

Höm... There seems to be no output. Why?
The Data window does not provide a simple text string but the content of a file. (How to open real files you will learn in one of the session when we learn how to run metafacture on your command line.)
Therefore we need to handle the incoming data differently. We need a second modul: `as-lines`

Flux:
```
PG_DATA
| as-lines
| print
;
```

The input is processed line by line.
You can see that in this [sample](https://metafacture.org/playground/?flux=PG_DATA%0A%7C+as-lines%0A%7C+print%0A%3B%0A&data=Hello%2C+friend.+I%27am+Metafacture%21%0AThanks+for+playing+around.&active-editor=fix).

We usually do not start with any random text strings but with data. So lets play around with some data. 

Let's start with a link: https://fcc-weather-api.glitch.me/api/current?lat=50.93414&lon=6.93147


You will see data that look like this:

```JSON
{"coord":{"lon":6.9315,"lat":50.9341},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"https://cdn.glitch.com/6e8889e5-7a72-48f0-a061-863548450de5%2F01d.png?1499366022009"}],"base":"stations","main":{"temp":15.82,"feels_like":15.02,"temp_min":14.55,"temp_max":18.03,"pressure":1016,"humidity":60},"visibility":10000,"wind":{"speed":4.63,"deg":340},"clouds":{"all":0},"dt":1654101245,"sys":{"type":2,"id":43069,"country":"DE","sunrise":1654053836,"sunset":1654112194},"timezone":7200,"id":2886242,"name":"Cologne","cod":200}
``` 

This is data in JSON format. But it seems not very readable.

But all these fields tell something about somedays weather in Cologne, Germany. You can recognise that there the sky is clear and the temperature is 15.82 degrees Celsius).

Let's copy the text from the input into our data field. And run it again.
The output in result is the same as the input and it is still not very readable.
So let's transform some stuff. Let us use some other serialization. How about YAML.
With the metafacture you can process this file to make it a bit easier readable by using a small workflow script.
Lets turn the one line of json data into YAML. YAML is another format for structured information which is a bit easier to read for human eyes. 
In order to change the serialization of the data we need to decode the data and then encode the data.

We have lots of decoder- and encoder-modules that can be used in an FLUX-Workflow.
Let's try this out. Add the module `decode-json` and `encode-yaml` to your Flux Workflow.

The Flux should now look like this:
Flux:
```
PG_DATA
| as-lines
| decode-json
| encode-yaml
| print
;
```

When you process the data our weather report should now look like this:

```YAML
---
coord:
  lon: "6.9315"
  lat: "50.9341"
weather:
- id: "800"
  main: "Clear"
  description: "clear sky"
  icon: "https://cdn.glitch.com/6e8889e5-7a72-48f0-a061-863548450de5%2F01d.png?1499366022009"
base: "stations"
main:
  temp: "15.82"
  feels_like: "15.02"
  temp_min: "14.55"
  temp_max: "18.03"
  pressure: "1016"
  humidity: "60"
visibility: "10000"
wind:
  speed: "4.63"
  deg: "340"
clouds:
  all: "0"
dt: "1654101245"
sys:
  type: "2"
  id: "43069"
  country: "DE"
  sunrise: "1654053836"
  sunset: "1654112194"
timezone: "7200"
id: "2886242"
name: "Cologne"
cod: "200"
```

But we cannot only open the data we have in our data field. But we also can open stuff on the web.
E.g. instead of using `PG_DATA` lets read the live info which is provided by the URL from above:

Clear your playground and copy the following Flux-Workflow:

```
"https://fcc-weather-api.glitch.me/api/current?lat=50.93414&lon=6.93147"
| open-http
| as-lines
| decode-json
| encode-yaml
| print;
```

The result should be the same as before but with `open-http` you can get the text that is provided via an url.
Congratulations you have created your first Flux-Workflow for Metafacture. But lets understand what a Flux Workflow is.
The Flux-Workflow is combination of different moduls to process incoming semi structured data. In our example we have different things that we do with these modules:
TODO: Hier anpassen.
First with `"weather.json"` we state the file name and location in relation to the folder we are in when we start the script.
Then we tell Metafacture `open-file` to open the stated file.
Then we tell Metafacture how to handle the data that is incoming: Since the report is writen in one line, we tell Metafacture to regard every new line as a new record with `as-lines`
Then we tell Metafacture to `decode-json` in order to translate the incoming data as json to the generic internal data model.
Then we tell metafacture to serialize the data as YAML with `encode-yaml`
Finally we tell MF to `print` everything.

So let's have a small recap of what we done and learnd sofar.
We played around with the Metafacture Playground.
We learnd that Metafacture Flux Workflow is a combination modules with an inital text string or an variable.
We got to know different modules like `open-http`, `as-lines`. `decode-json`, `encode-yaml`, `print`

More modules can be found in the [documentation of available flux commands](https://github.com/metafacture/metafacture-documentation/blob/master/flux-commands.md).

Now take some time and play around a little bit more and use some other modules.
1) Try to change the Flux workflow to output as formeta (a metafacture specific data format) and not as YAML.
2) Set the stile of formeta to multiline.
3) Also try not to print but to write the output and call the file that you write weather.xml.

```
"https://fcc-weather-api.glitch.me/api/current?lat=50.93414&lon=6.93147"
| open-http
| as-lines
| decode-json
| encode-formeta(style="multiline")
| write("test.xml")
;
```

What you see with the module `write` is that modules can have further specification in brakets.
These can eiter be a string in `"..."` or attributes that define options as with `style=`.

One last thing you should learn on an abstract level is tp grasp the general idea of Metafacture Flux workflows is that they have many different moduls  through which the data is flowing(TODO ?) the most abstract and most common process resemble the following steps:

→ read → decode → transform → encode → write →

This process is one that Transforms incoming data in a way that is changed at the end.
Each step can be done by one or an combination of multiple modules.
Modules are small tools that do parts of the complete task we want to do.

Each modul demands a certain input and give a certain output.
e.g.:

The fist modul `open-file` expects a string and provides read data (called reader).
This reader data can be passed on to a modul that accepts reader data e.g. in our case `as-lines`
`as-lines` outputs again a string, that is accepted by the `decode-json` module.

If you have a look at the flux modul/command documentation then you see under signature which data a modul expects and which data it outputs.

The combination of moduls is a Flux-Workflow.

Have a look at `decode-xml` what is different to `decode-json` what does it expect?

TODO: give answer and do a collapsing part.

As you surely already saw is that I mentioned transform as one step. We did not play around with transformations yet.
This will be the theme of the next session.