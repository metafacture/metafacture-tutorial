# Lesson 7: Processing MARC with Metafacture

In the previous lessons we learned how we can use Metafacture to process structured data like JSON. Today we will use Metafacture to process MARC metadata records. In this process we will see that MARC can be processed using FIX paths.

[Transformation marc data with metafacture can be used for multiple things, e.g. you could transform marc binary files to marc xml.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%28emitleaderaswhole%3D%22true%22%29%0A%7C+encode-marcxml%0A%7C+print%0A%3B)

As always, we will need to set up a small metafacture flux script.

Lets inspect a marc file: https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc

Create the following flux in a new file e.g. name it `marc1.flux`:

```
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc"
| open-http
| as-lines
| print
;
```

Run this Flux via CLI (e.g.  '/path/to/your/metafix-runner' 'path/to/your/marc1.flux'`)

[Or use playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+print%0A%3B)

You should see something like this:

![Results Marc in Binary in Playground](images/ResultMarc01.png)

You also can try to run the examples via CLI.

## Get to know your marc data

Like JSON the MARC file contains structured data but the format is different. All the data is on one line, but there isn’t at first sight a clear separation between fields and values. The field/value structure there but you need to use a MARC parser to extract this information. Metafacture contains a MARC parser which can be used to interpret this file.

Lets create a new small Flux script to transform the Marc data into YAML, name it `marc2.flux`:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| encode-yaml
| print
;
```

Run this FLUX script with your MF Runner on the CLI.

[Or try it in the the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+encode-yaml%0A%7C+print%0A%3B)

Running it in the playground or with the commandline you will see something like this

![Results Marc as Yaml](images/ResultMarc02.png)

Metafacture has its own decoder for Marc21 data. The structure is translated as the following: The [leader](https://www.loc.gov/marc/bibliographic/bdleader.html) can either be translated in an entity or a single element. All [control fields `00X`](https://www.loc.gov/marc/bibliographic/bd00x.html) are translated into simple string fields with name `00X`.
All `XXX` fields starting with `100` are translated in top elements with name of the field+indice numbers e.g. element 245 1. Ind 1 and 2. Ind 2 =>  `24512` . Every subfield is translated in a subfield. Additionally keep in mind that repeated elements are transformed into lists.

Lets use `list-fix-paths(count="false")` to show the pathes that are used in the records. It helps to get a overview of the records:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| list-fix-paths(count="false")
| print
;
```

Lets run it.

[See in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+list-fix-paths%28count%3D%22false%22%29%0A%7C+print%0A%3B%0A)

## Transform some marc data

We can use metafacture fix to read the _id fields of the MARC record with the retain fix we learned in the Day 6 post:

Flux:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc"
| open-http
| as-lines
| decode-marc21
| fix("retain('_id')")
| encode-yaml
| print
;
```

You will see:

```YAML
---
_id: "1098313828"

---
_id: "1081168102"

---
_id: "1069434825"

---
_id: "1081636297"

---
_id: "1089079486"

---
_id: "1048482650"

---
_id: "1097290212"

---
_id: "1099987636"

---
_id: "1098451600"

---
_id: "1049752414"


```

[See it in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28%22retain%28%27_id%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

What is happening here? The MARC file `sample.mrc` contains more than one MARC record. For every MARC record Metafacture extracts here the `_id` field. This field is a hidden element in every record and for MARC Records it uses the value of the `001` element.

Extracting data out of the MARC record itself is a bit more difficult. This is a little different than in Catmandu. As I said Metafacture has a specific marc21 decoder. Fields with their indices are translated into fields and every subfield becomes a subfield. What makes it difficult is that some fields are repeatable and some are not. (Catmandu translates the record into an array of arrays MF does not.)

You need paths of the elements to extract the data. For instance the MARC leader is usually in the first field of a MARC record. In the previous posts about paths. To keep the `leader`element we need to retain the element `leader`.

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc"
| open-http
| as-lines
| decode-marc21
| fix("retain('leader')")
| encode-yaml
| print
;
```

[See it in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28%22retain%28%27leader%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

```YAML
---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: "a"

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: "c"

---
leader:
  status: "p"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "c"
  multipartLevel: "b"

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

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "s"
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
  multipartLevel: "b"

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "s"
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

```

The leader value is translated into a leader element with the subfields. You also can emit the leader as a whole string if you use `decode-marc21` with a specific option: `| decode-marc21(emitLeaderAsWhole="true")`. [See it here.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%28emitLeaderAsWhole%3D%22true%22%29%60%0A%7C+fix%28%22retain%28%27leader%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

To work with MARC and transform it in Metafatcture is more generic than in CATMANDU since no marc specific maps are needed. But some difficulties come with repeatable fields. This is something you usually don’t know. And you have to inspect this first.

Here you see, a simple mapping from the element `245 any indicators $a`  to a new field names `title`. To map any incicator we use the wildcard ? for each indicator so the path is: `245??.a`

Flux:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc"
| open-http
| as-lines
| decode-marc21
| fix(transformationFile)
| encode-yaml
| print
;
```

with transformationFile.fix:
```PERL
copy_field("245??.a", "title")
retain("title")
```

[See here in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A&transformation=copy_field%28%22245%3F%3F.a%22%2C+%22title%22%29%0Aretain%28%22title%22%29)

More elaborate mappings can be done too. I’ll show you more complete examples in the next posts. As a warming up, here is some code to extract all the record identifiers, titles and isbn numbers in a MARC file into a CSV listing (which you can open in Excel).

Step 1, create a fix file `transformationFile.fix` containing:

```PERL
copy_field("001","id")
add_arrayy("title")
do list(path: "245??.?","var":"$i")
  copy_field("$i","title.$append")
end
join_field(title," ")
add_arrayy("isbn")
do list(path: "020??","var":"$i")
  copy_field("$i.a",isbn.$append)
end
join_field(isbn,",")
retain("id","title","isbn")
```

 Step 2, create the flux workflow and execute this worklow either with CLI or the playground:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix("transformationFile.fix")
| encode-csv
| print
;

```

[See it in the Playground here.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.mrc%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28includeheader%3D%22true%22%29%0A%7C+print%0A%3B%0A%0A&transformation=copy_field%28%22001%22%2C%22id%22%29%0Aadd_arrayy%28%22title%22%29%0Ado+list%28path%3A+%22245%3F%3F.%3F%22%2C%22var%22%3A%22%24i%22%29%0A++copy_field%28%22%24i%22%2C%22title.%24append%22%29%0Aend%0Ajoin_field%28title%2C%22+%22%29%0Aadd_arrayy%28%22isbn%22%29%0Ado+list%28path%3A+%22020%3F%3F.a%22%2C%22var%22%3A%22%24i%22%29%0A++copy_field%28%22%24i%22%2Cisbn.%24append%29%0Aend%0Ajoin_field%28isbn%2C%22%2C%22%29%0Aretain%28%22id%22%2C%22title%22%2C%22isbn%22%29)


You will see this as output:

```CSV
"id","title","isbn"
"110028351X","Prüfungsvorbereitung für das Fachabitur Original-Prüfungsaufgaben inklusive Lösungen und ausführlichen Erklärungen [...] BWR ... FOS, BOS 12 Bayern",""
"1099986818","Schwerpunktheft Fachkräfte für Deutschland Zwischenbilanz und Fortschreibung Herausgeberin Bundesagentur für Arbeit",""
"1052354327","Exkursionsflora für Istrien von Walter K. Rottensteiner (Hrsg.)","9783853280676"
"107083095X","Waldbus und Limesbus ... Touren und Ausflugs-Tipps im Schwäbischen Wald : kostenlose Fahrradmitnahme Herausgeber: VVS GmbH in Zusammenarbeit mit dem Landratsamt Rems-Murr-Kreis und der Fremdenverkehrsgemeinschaft Schwäbischer Wald",""
"1099120101","Wirtschaftsstandort Landkreis Cloppenburg",""
"1003858902","Veröffentlichung des Museumsverbundes im Landkreis Celle",""
"1073620735","Das Höchster Porzellan-Museum im Kronberger Haus Dépendance des Historischen Museums Frankfurt Patricia Stahl","3892820457"
"1098164636","Arbeit in Aufsichts- und Verwaltungsräten in kommunalen Unternehmen und Einrichtungen in Nordrhein-Westfalen von Porf.Dr. Frank Bätge ; Sozialdemokratischen Gemeinschaft für Kommunalpolitik in NRW e.V.","9783937541297"
"1081732687","Numerische Verschleißberechnung für Schmiedewerkzeuge unter Berücksichtigung lokaler Härteveränderungen bei zyklisch-thermischer Beanspruchung Andreas Klassen","9783959000598,3959000596"
"1080278184","Renfro Valley Kentucky Rainer H. Schmeissner",""
```

In the fix above we mapped the 245-field to the title, and iterated over every subfield with the help of the list-bind and the `?`- wildcard.
. The ISBN is in the 020-field. Because MARC records can contain one or more 020 fields we created an isbn array with add_arrayy and added the values using the isbn.$append syntax. Next we turned the isbn array back into a comma separated string using the join_field fix. As last step we deleted all the fields we didn’t need in the output with the `retain` syntax.

In this post we demonstrated how to process MARC data. In the next post we will show some examples how catmandu typically can be used to process library data.

## Excercise.



# TODO_ Add example that transforms aleph sequential. Also open ticket, that enables the transformation.

Next lesson: [08 Harvest data with OAI-PMH](./08_Harvest_data_with_OAI-PMH.md)
