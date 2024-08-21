# Lesson 7: Processing MARC with Metafacture

In the previous days we learned how we can use Metafacture to process structured data like JSON. Today we will use Metafacture to process MARC metadata records. In this process we will see that MARC can be processed using FIX paths.

[Transformation marc data with metafacture can be used for multiple things, e.g. you could transform marc binary files to marc xml.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%28emitleaderaswhole%3D%22true%22%29%0A%7C+encode-marcxml%0A%7C+print%0A%3B)

As always, we will need to set up a small metafacture flux script.

Lets inscpt a marc file: https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21

Use this flux:

```
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21"
| open-http
| as-lines
| print
;
```

[Use playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+print%0A%3B)

You should see something like this:

![Results Marc in Binary in Playground](images/ResultMarc01.png)

## Get to know your marc data

Like JSON the MARC file contains structured data but the format is different. All the data is on one line, but there isn’t at first sight a clear separation between fields and values. The field/value structure there but you need to use a MARC parser to extract this information. Metafacture contains a MARC parser which can be used to interpret this file.

Lets create a small Flux script to transform the Marc data into YAML:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| encode-yaml
| print
;
```

[Try it in the the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+encode-yaml%0A%7C+print%0A%3B)

Running it in the playground or with the commandline you will see something like this

![Results Marc as Yaml](images/ResultMarc02.png)

Metafacture has its own decoder for Marc21 data. The structure is translated as the following: The [leader](https://www.loc.gov/marc/bibliographic/bdleader.html) can either be translated in an entity or a single element. All [control field `00X`](https://www.loc.gov/marc/bibliographic/bd00x.html) are translated into simple string fields with name `00X`.
All `XXX` fields above `009` are translated in top elements with name of the field+indice numbers e.g. element 245 1. Ind 1 and 2. Ind 2 =>  `24512` . Every subfield is translated in a subfield.

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

## Transform some marc data

We can use metafacture fix to read the _id fields of the MARC record with the retain fix we learned in the Day 6 post:

Flux:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21"
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
_id: "020598225"

---
_id: "021175603"

---
_id: "021641563"

---
_id: "021645548"

---
_id: "021649356"

---
_id: "021720518"

---
_id: "022147376"

---
_id: "022497750"

---
_id: "022583208"

---
_id: "022609438"

```

[See it in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28%22retain%28%27_id%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

What is happening here? The MARC file `sample.marc21` contains more than one MARC record. For every MARC record Metafacture extracts here the `_id` field. This field is a hidden element in every record.

Extracting data out of the MARC record itself is a bit more difficult. This is a little different than in Catmandu. As I said Metafacture has a specific marc21 decoder. Fields with their indices are translated into fields and every subfield becomes a subfield. What makes it difficult is that some fields are repeatable and some are not. (Catmandu translates the record into an array of arrays MF does not.)

You need paths of the elements to extract the data. For instance the MARC leader is usually in the first field of a MARC record. In the previous posts about paths. To keep the `leader`element we need to retain the element `leader`.

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21"
| open-http
| as-lines
| decode-marc21
| fix("retain('leader')")
| encode-yaml
| print
;
```

[See it in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28%22retain%28%27leader%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

```YAML
---
---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "e"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: " "
  catalogingForm: "i"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "a"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "i"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "i"
  multipartLevel: " "

---
leader:
  status: "n"
  type: "a"
  bibliographicLevel: "m"
  typeOfControl: " "
  characterCodingScheme: "a"
  encodingLevel: "K"
  catalogingForm: "i"
  multipartLevel: " "

```

The leader value is translated into a leader element with the subfields. You also can emit the leader as a whole string if you use `decode-marc21` with a specific option: `| decode-marc21(emitLeaderAsWhole="true")`. [See it here.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%28emitLeaderAsWhole%3D%22true%22%29%0A%7C+fix%28%22retain%28%27leader%27%29%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A)

To work with MARC in Metafatcture is more easy than in CATMANDU. The difficulties are introduces with repeatable fields. This is something you usually don’t know. And you have to inspect this first.

Flux:

```default
"https://raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21"
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

[See here in the playground.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B%0A&transformation=copy_field%28%22245%3F%3F.a%22%2C+%22title%22%29%0Aretain%28%22title%22%29)


More elaborate mappings are possible. I’ll show you more complete examples in the next posts. As a warming up, here is some code to extract all the record identifiers, titles and isbn numbers in a MARC file into a CSV listing (which you can open in Excel).

Step 1, create a fix file `transformationFile.fix` containing:

```PERL
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

[See it in the Playground here.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-tutorial/main/data/sample.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=set_array%28%22title%22%29%0Ado+list%28path%3A+%22245%3F%3F.%3F%22%2C%22var%22%3A%22%24i%22%29%0A++copy_field%28%22%24i%22%2C%22title.%24append%22%29%0Aend%0Ajoin_field%28title%2C%22+%22%29%0Aset_array%28%22isbn%22%29%0Ado+list%28path%3A+%22020%3F%3F.a%22%2C%22var%22%3A%22%24i%22%29%0A++copy_field%28%22%24i%22%2Cisbn.%24append%29%0Aend%0Ajoin_field%28isbn%2C%22%2C%22%29%0Aretain%28%22_id%22%2C%22title%22%2C%22isbn%22%29)

TODO: The example has no ISBNs...

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

> TODO: Add excercise.
> First I’m going to teach you how to process different types of MARC files.
>
> There are many ways in which MARC data can be written into a file. Every vendor likes to use its own format. You can compare this with the different ways a text document can be stored: as Word, as Open Office, as PDF and plain text.
>
> If we are going to process these files with Metafacture, then we need to tell the system what the exact format is.
>
> // We will work today with the last example rug01.sample which is a small export out of the Aleph catalog from Ghent University Library. Ex Libris uses a special MARC format to structure their data which is called Aleph sequential. We need to tell catmandu not only that our input file is in MARC but also in this special Aleph format. Let’s try to create YAML to see what it gives:
> //
> // $ catmandu convert MARC --type ALEPHSEQ to YAML < Documents/rug01.sample

>

Next lesson: [08 Harvest data with OAI-PMH](./08_Harvest_data_with_OAI-PMH.md)
