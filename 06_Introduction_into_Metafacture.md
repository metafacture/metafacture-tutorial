If you know how to use the command line Metafacture can easily be used. 
Other ways to use Metafacture is as a JAVA library or with the Playground.

In this lesson we will introduce you to a UNIX command we have created for metafacture. The metafacture command is used to run a flux script and to process structured information.  To demo this command, as always, you need to startup your Virtual Catmandu (hint: see our day 1 tutorial) and start up the UNIX prompt (hint: see our day 2 tutorial).

In this tutorial we are going to process structured information. We call data structured when it organised in such a way is that it easy processable by computers. Previously we processed text documents like War and Peace which is structured only in words and sentences, but a computer doesn’t know which words are part of the title or which words contain names. We had to tell the computer that. Today we will download a weather report in a structured format called JSON and inspect it with the command catmandu.

At the UNIX prompt type in this command:

$ curl http://api.openweathermap.org/data/2.5/weather?q=Gent,be

[Update: as of end 2015 the OpenWeatherMap API requires an API key. Use this link to download a copy of the Ghent weather report :

$ curl https://gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json

]

You will see a JSON output like:

{"coord":{"lon":3.72,"lat":51.05},"sys":{"type":3,"id":4839,"message":0.0349,"country":"BE",
"sunrise":1417159365,"sunset":1417189422},"weather":[{"id":500,"main":"Rain","description":"light rain",
"icon":"10d"}],"base":"cmc stations","main":{"temp":281.15,"pressure":1006,"humidity":87,"temp_min":281.15,
"temp_max":281.15},"wind":{"speed":3.6,"deg":100},"rain":{"3h":0.5}
,"clouds":{"all":56},"dt":1417166878,"id":2797656,
"name":"Gent","cod":200}

All these fields tell something about the current weather in Gent, Belgium. You can recognise that there is a light rain and the temperature is 281.15 degrees Kelvin (about 8 degrees Celsius).  Write the output of this command to a file weather.json (using the ‘>’ sign we learned in the day 5 tutorial) so that we can use it in the next examples.

$ curl https://gist.githubusercontent.com/phochste/7673781b19690f66cada/raw/67050da98a7e04b3c56bb4a8bc8261839af57e35/weather.json > weather.json

When you type the ls command you should see the new file name weather.json appearing.

With the catmandu command you can process this file to make it a bit easier readable. For instance type:

$ catmandu convert JSON to YAML < weather.json

YAML is another format for structured information which is a bit easier to read for human eyes. Our weather report should now look like this:

Screenshot_28_11_14_11_06

Catmandu can be used to process structured information like the UNIX grep command can process unstructured information. For instance lets try to filter out the name of this report. Type in this command:

$ catmandu convert JSON --fix 'retain_field(name)' to YAML < weather.json

You should end up with something like:

---
name: Gent
...

The –fix option in Catmandu is used to ‘massage’ the input weather.json filtering fields we would like to see. Only one fix was used ‘retain_field’, which throws away all the data from the input except the ‘name’ field. By the way, the file weather.json wasn’t changed! We only read the file and displayed the output of catmandu command.

The temperature in Gent is the in ‘temp’ part of the ‘main’ section in weather.json. To filter this out we need two retain_field fixes: one for the main section, one for the temp section:

$ catmandu convert JSON --fix 'retain_field(main); retain_field(main.temp)' to YAML < weather.json

You should now see something like this:

---
main:
  temp: 281.15
...

When massaging data you often need to create many fixes to process a data file in the format you need. With the nano command you can write all the fixes in a file. Start the nano editor with the command:

$ nano weather.fix

In nano type now the two fixes above:

retain_field(main)
retain_field(main.temp)

To exit nano type Ctrl-X, press Y to confirm the changes and press Enter to confirm the file name.

With this file it will be a bit easier to create many fixes. The name of the fix file can be used to repeat the commands above:

$ catmandu convert JSON --fix weather.fix to YAML < weather.json

To add more fixes we can again edit the weather.fix file. Type:

$ nano weather.fix

And add these lines after the two previous lines:


prepend(main.temp,"The temperature is")
append(main.temp," degrees Kelvin")

Save the changes with Ctrl-X, Y, Enter and execute catmandu  again:

$ catmandu convert JSON --fix weather.fix to YAML < weather.json

You should now see as ouput:

---
main:
  temp: The weather is 281.15 degrees Kelvin
...

Catmandu contains many fixes to manipulate data. Check the documentation to get a complete list. This post only presented a short introduction into catmandu. In the next posts we will go deeper into its capabilities.

Continue to Day 7: Catmandu JSON paths >>
