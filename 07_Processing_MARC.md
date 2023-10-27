TODO: Use a better MARC-Example. Perhaps? https://github.com/metafacture/metafacture-examples/blob/master/Swissbib-Extensions/MARC-CSV/input.xml for marcXML 




Day 9: Processing MARC with Catmandu

In the previous days we learned how we can use Metafacture to process structured data like JSON. Today we will use Metafacture to process MARC metadata records. In this process we will see that MARC can be processed using JSON paths.

As always, we will need to set up a small metafacture flux script.

Lets inscept a marc file: https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21

https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+print%0A%3B&active-editor=fix

You should see something like this:

Screenshot_01_12_14_09_41

Like JSON the MARC file contains structured data but the format is different. All the data is on one line, but there isn’t at first sight a clear separation between fields and values. The field/value structure there but you need to use a MARC parser to extract this information. Metafacture contains a MARC parser which can be used to interpret this file.

Lets create a small Flux script to transform the Marc data into YAML:
<https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+encode-yaml%0A%7C+print%0A%3B>

```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| encode-yaml
| print
;
```

Running it in the playground or with the commandline you will see something like this


Screenshot_01_12_14_10_01

Metafacture has its own decoder for Marc21 data. The structure is translated as the following: The leader can either be translated in an entity or a single element. All `XXX` fields are translated in top elements with name of the field+indice numbers. Every subfield is translated in a subfield. 
 
We can use catmandu to read the _id fields of the MARC record with the retain fix we learned in the Day 6 post:

FLUX:

```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix("retain('_id')")
| encode-yaml
| print
;
```

You will see:

```
---
_id: "946638705"

---
_id: "94685887X"

---
_id: "947459928"

---
_id: "948469390"

---
_id: "950561274"

---
_id: "950592463"

---
_id: "950974439"

---
_id: "953176436"

---
_id: "954369300"

---
_id: "954377915"
```

What is happening here? The MARC file Documents/10.marc21 contains more than one MARC record. For every MARC record catmandu extracts the _id field. This field is a hidden element in every record.

Extracting data out of the MARC record itself is a bit more difficult. This is a little different than in Catmandu. As I said Metafacture has a decoder. Fields with their indices are translated into fields and every subfield becomes a subfield. What makes it difficult is that some fields are repeatable and some are not. (Catmandu translates the record into an array MF does not.)


MARC is an array-an-array, you need indexes to extract the data. For instance the MARC leader is usually in the first field of a MARC record. In the previous posts we learned that you need to use the 0 index to extract the first field out of an array:


```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix("retain('leader')")
| encode-yaml
| print
;
```


```
---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: " "
```

The leader value is translated into a leader element with the subfields.




To work with MARC in Metafatcture is more easy than in CATMANDU. The difficulties are introduces with repeatable fields. This is something you usually don’t know. And you have to inspect this first.

```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix
| encode-yaml
| print
;
```

```
copy_field("245??.a", "title")
retain("title")
```

More elaborate mappings are possible. I’ll show you more complete examples in the next posts. As a warming up, here is some code to extract all the record identifiers, titles and isbn numbers in a MARC file into a CSV listing (which you can open in Excel).

Step 1, create a fix file myfixes.txt containing:

```
set_array("title")
do list(path: "245??.?","var":"$i")
  copy_field("$i","title.$append")
end
join_field(title," ")
set_array("isbn")
do list(path: "020??.a","var":"$i")
  copy_field("$i",isbn.$append)
end
join_field(isbn,",")
retain("_id","title","isbn")
```

TODO: Introduce when csv is provided:
 Step 2, execute this command:

```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix(transformationFile)
| encode-csv
| print
;

```

You will see this as output:

"Colonial and post-colonial discourse in the novels of Yo§am Sang-So§ap, Chinua Achebe and Salman Rushdie Soonsik Kim","0820431125","946638705"
"Ostenfelder Bauernhaus Deutschlands a§�ltestes Freilichtmuseum in Husum Konrad Grunsky","3880426066","94685887X"
"Gesellschaftsrecht 1995 hrsg. von Hartwig Henze ...","3814550080","947459928"
"Deathlock = Todespunkt Michael Burning","3929207478","948469390"
"Die Prachtlibellen Europas Gattung Calopteryx Georg Ru§�ppell ...","3894328835","950561274"
"Insolvenzrecht 1996 hrsg. von Hanns Pru§�tting","3814550099","950592463"
"Siciliano Rainer Bigalke. [Ed. by U. J. Lu§�ders]","3895862193","950974439"
"Arbeitsrecht 1997 hrsg. von Peter Hanau ; Gu§�nter Schaub","3814550110","953176436"
"Gesellschaftsrecht 1997 hrsg. von Peter Hommelhoff ; Volker Ro§�hricht","3814550102","954369300"
"Bankrecht 1998 hrsg. von Norbert Horn ; Herbert Schimansky","3814550129","954377915"

In the fix above we mapped the 245-field to the title. The ISBN is in the 020-field. Because MARC records can contain one or more 020 fields we created an isbn array using the isbn.$append syntax. Next we turned the isbn array back into a comma separated string using the join_field fix. As last step we deleted all the fields we didn’t need in the output with the remove_field syntax.

In this post we demonstrated how to process MARC data. In the next post we will show some examples how catmandu typically can be used to process library data.

Next lesson: [08 Harvest data with OAI-PMH](./08_Harvest_data_with_OAI-PMH.md)
