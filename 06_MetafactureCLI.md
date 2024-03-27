## Lesson 7: Using Metafacture as Command Line Tool

While we had fun with our Metafacture Playground another way to use Metafacture is
the command line. For running a Metafacture flux process we need a terminal and installed JAVA.
For creating and editing FLUX and FLIX we need an texteditor like Codium/VS Code or others.

> TODO: Check if JAVA is installed and if not a short manual for installing the needed JAVA.
> Also specify the needed JAVA version.

For this we can download the latest runner of Metafacture Fix:

https://github.com/metafacture/metafacture-fix/releases

Unzip the downloaded metafix-runner distribution to your choosen folder and you can run your workflows:

Unix: `./bin/metafix-runner path/to/your.flux` or Windows: `./bin/metafix-runner.bat path/to/your.flux`.

To get quick started let's revisit a Flux we toyed around with in the playground.
The playground has a nice feature to export and import Metafacture Workflows.

`https://metafacture.org/playground/?flux=%22https%3A//weather-proxy.freecodecamp.rocks/api/current%3Flat%3D50.93414%26lon%3D6.93147%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-json%0A%7C+encode-yaml%0A%7C+print%0A%3B&active-editor=fix`

Export the workflow and lets run the flux.

`./bin/metafix-runner downloas/playground.flux` 
The result should be the same.

The Metafacture ClI Tool expects a flux file for every workflow.
Our runned workflow only has a flux and no additional files since it i querring data from the web and it has no fix transformations.

If we want to querry local data you have to adjust your workflow:

```
"https://weather-proxy.freecodecamp.rocks/api/current?lat=50.93414&lon=6.93147"
| open-http
| as-lines
| decode-json
| encode-yaml
| print
;
```

If you want to load a local file instead of fetching it from the web. We need to change the flux a little bit.

```
"path/to/your/file.json"
| open-file
| as-lines
| decode-json
| encode-yaml
| print
;

If we want to use fix we need to refrence the fix file that in the playground we only refrenced via `|fix`

"path/to/your/file.json"
| open-file
| as-lines
| decode-json
| fix("path/to/your/fixFile.json")
| encode-yaml
| print
;
```

(Hint: You can use the varliable FLUX_DIR to shorten the file path if the file is in the same folder as the flux-file.)

TODO: Give homework:
	- Provide a file or a file-folder.
	- Give a homework.
	- Give the solution.


 Next lesson: [07 Processing MARC](./07_Processing_MARC.md)
