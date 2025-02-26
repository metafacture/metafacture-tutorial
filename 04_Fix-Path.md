# Lesson 4: Fix Path and more complex transfromations in Fix

Last sessions we learned the how to construct a metafacture workflow, how to use the Playground and how and how Metafacture Flux and Fix can be used to parse structured information. Today we will go deeper into Metafacture Fix and describe how to pluck data out of structured information.

Today will we fetch of a new book with the Metafacture Playground:

```
"https://openlibrary.org/books/OL27333998M.json"
| open-http
| as-lines
| decode-json
| encode-yaml
| print
;
```

We also saw in the previous post how you can use Metafacture to transform the JSON format into the YAML format which is easier to read and contains the same information.

We also learned some fixes e.g. to retrieve information out of the JSON file like `retain("title", "publish_date", "type.key")`.

In this post we delve a bit deeper into ways how to point to fields in a JSON or a YAML file:

```YAML
---
publishers:
- "Simon & Schuster"
number_of_pages: "368"
subtitle: "A Theory"
covers:
- "8798647"
physical_format: "paperback"
full_title: "Bullshit Jobs A Theory"
key: "/books/OL27333998M"
authors:
- key: "/authors/OL1395062A"
source_records:
- "amazon:1501143336"
- "bwb:9781501143335"
- "marc:marc_columbia/Columbia-extract-20221130-034.mrc:71583959:3725"
- "promise:bwb_daily_pallets_2023-05-10:W8-BRV-242"
title: "Bullshit Jobs"
notes: "Source title: Bullshit Jobs: A Theory"
identifiers:
  amazon:
  - "1501143336"
publish_date: "May 07, 2019"
works:
- key: "/works/OL20153626W"
type:
  key: "/type/edition"
local_id:
- "urn:bwbsku:W8-BRV-242"
isbn_10:
- "1501143336"
isbn_13:
- "9781501143335"
lccn:
- "2021276048"
oclc_numbers:
- "1056738022"
classifications: {}
lc_classifications:
- "HF5549.5.J63 G73 2019"
languages:
- key: "/languages/eng"
latest_revision: "6"
revision: "6"
created:
  type: "/type/datetime"
  value: "2019-10-04T04:03:07.194846"
last_modified:
  type: "/type/datetime"
  value: "2023-08-05T12:37:41.711036"
```

`type.key` is called a *Path* that is JSON Path-like and points to a part of the data set - here our Yaml record - you are interested in. The data, as shown above, is structured like a tree. 

There are top level simple fields like: `title`, `publish_date`, `notes` and `latest_revision` which contain only text values or numbers. Depending on the context simple fields can also be named: elemente, properties, attribute or key.

There are also fields like `created` that contain a deeper structure like `type` and `value`.Nested elements that contain one or more subfields or subelements are also called objects or hash.

And there are lists like `source_records[]` to which I come back later.

Metafacture Fix is using Fix Path, a path-syntax that is JSON Path like but not identical. It also uses the dot notation but there are some differences with the path structure of arrays and repeated fields. Especially when working with JSON or YAML.

Using a JSON path you can point to every part of the JSON file using a dot-notation. For simple top level fields the path is just the name of the field:

* `title`
* `publish_date`
* `notes`
* `latest_revision`

For the nested objects with deeper structure you add a dot `.` to point to the subfields:

* `type.key`
* `created.type`
* `last_modified.value`

So for example. If you would have a deeply nested structure like this object:

```YAML
x:
  y:
    z:
      a:
        b:
          c: Hello :-)
```

Then you would point to the c field with the path to reference the element would be `x.y.z.a.b.c`.

So lets do some simple excercises:

[Try and complete the fix functions. Transform the element `a` into `title` and combine the subfields of `b` and `c` to the element `author`.](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=move_field%28%22a%22%22%2C+%22title%22%29%0Apaste%28%22author%22%2C+%22...%22%2C+...%2C+%22~from%22%2C+...%29%0Aretain%28%22title%22%2C+%22author%22%29&data=---%0Aa%3A+Faust%0Ab+%3A%0A++ln%3A+Goethe%0A++fn%3A+JW%0Ac%3A+Weimar%0A%0A---%0Aa%3A+R%C3%A4uber%0Ab+%3A%0A++++ln%3A+Schiller%0A++++fn%3A+F%0Ac%3A+Weimar)

<details>
<summary>Answer</summary>
[See here](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=move_field%28%22a%22%22%2C+%22title%22%29%0Apaste%28%22author%22%2C+%22...%22%2C+...%2C+%22~from%22%2C+...%29%0Aretain%28%22title%22%2C+%22author%22%29&data=---%0Aa%3A+Faust%0Ab+%3A%0A++ln%3A+Goethe%0A++fn%3A+JW%0Ac%3A+Weimar%0A%0A---%0Aa%3A+R%C3%A4uber%0Ab+%3A%0A++++ln%3A+Schiller%0A++++fn%3A+F%0Ac%3A+Weimar)
</details>

## Repeated fields and arrays

There are two extra path structures that need to be explained:

* repeated fields
* arrays

In general: Repeated fields as well arrays are both handled as arrays. They can also call these internal arrays lists.
Both names (list and array) are reflected in some fix functions (e.g. `add_array` or the `list`-Bind.)

In an data set an element sometimes can have multiple instances. Different data models solve this possibility differently. XML-Records can have all elements multiple times, element repition is possible and in many schemas it is (partly) allowed. E.g. the subject element exists three times:

### Working with repeated fields

```XML
<subject>Metadata</subject>
<subject>Datatransformation</subject>
<subject>ETL</subject>
```


Repeatable elements also exist e.g. in JSON and YAML but are unusual:

```YAML
creator: Justus
creator: Peter
creator: Bob
```

In our two examples the `subject`- and `creator`-element exists three times. To point to one of the elements you need to use an index. The index is one-based: The first index has value 1, the second the value 2, the third the value 3. So, the path of the creator Bob would be `creator.3`. (This is a main difference between Catmandu and Metafacture because Catmandu has an zero based index.)

If you want to refer to all creators then you can use the array wildcard `*` which can replace the concrete index number: `creator.*` refers to all creator elements. You can also select the the first instance with the array wildcard `$first` and the last `$last`. This is espacially handy if you do not know how often an element is repeated. When adding an additional repeated element you usually use the `$append` wildcard.

[Prepend the correct last name to the three investigators: Justus Jonas, Peter Shaw and Bob Andrews. Also append Investigator to all of them.](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=&data=---%0Acreator%3A+Justus%0Acreator%3A+Peter%0Acreator%3A+Bob%0A)

<details>
<summary>Answer</summary>
[See here](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=append%28%22creator.1%22%2C%22+Jonas%22%29%0Aappend%28%22creator.2%22%2C%22+Shaw%22%29%0Aappend%28%22creator.3%22%2C%22+Andrews%22%29%0Aprepend%28%22creator.%2A%22%2C%22Investigator+%22%29&data=---%0Acreator%3A+Justus%0Acreator%3A+Peter%0Acreator%3A+Bob%0A)
</details>

### Working with JSON and Yaml arrays

In JSON or YAML element repetion is possible but unusual. Instead of repeating elements repetition is constructed as list so that an element can have more than one value. This is called an array and looks like this in YAML:

In our book example e.g. we have the following array:

```
source_records:
  - "amazon:1501143336"
  - "bwb:9781501143335"
  - "marc:marc_columbia/Columbia-extract-20221130-034.mrc:71583959:3725"
  - "promise:bwb_daily_pallets_2023-05-10:W8-BRV-242"
```

Our example from above would look like this if creator was a list instead of an repeated field:

```YAML
creator:
	- Justus
	- Peter
	- Bob
```

or:

```YAML
my:
  colors:
    - black
    - red
    - yellow
```

Also lists can be deeply nested, if they are not just lists of strings (array of strings) but of objects (array of objects).

```YAML
characters:
  - name: Justus
    role: Investigator
  - name: Peter
    role: Investigator
  - name: Bob
    role: Research & Archive
```

In the colour example above you see a field `my` which contains a deeper field `colors` which has 3 values. To point to one of the colors you need to use an index but also genuin arrays have a marker in Metafacture: `[]`. Also here the first index in a array has value 1, the second the value 2, the third the value 3. The array markers are generated by the [JSON-Decoder](https://github.com/metafacture/metafacture-documentation/blob/master/flux-commands.md#decode-json) and the [YAML-Decoder](https://github.com/metafacture/metafacture-documentation/blob/master/flux-commands.md#decode-yaml). Also if you want to generate an array in the target format, then you need to add `[]` at the end of an list-element like `newArray[]`. (While sofare the path handling of Catmandu and Metafacture are similar, they differ at this point.)

So, the path of the `red` would be: `my.color[].2`
And the path for `Peter` would be `characters[].2.name`

There is one array type in our JSON report from our example at the beginning above and that is the `weather` field. To point to the description of the weather you need the path `weather[].1.description`.

| elements  | objects | array/repeated field  |
|---|---|---|
| need path  | need dots to mark nested structure |  need index/array-wildcards to refer to specific position |
| `id`  | `title.subtitle` | `author.*.firstName` |
| `name`  | `very.nested.element` | `my.color.2` |

Excercise:

[Only `retain` the elements of title, the element of the series and the role of Bob Andrews. You have to identify the paths for said elements.](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-json%0A%7Cfix%28transformationFile%29%0A%7Cencode-yaml%0A%7Cprint%0A%3B&transformation=retain%28...%29&data=%7B%0A++%22title%22+%3A+%22The+Secret+of+Terror+Castle%22%2C%0A++%22isPartOf%22+%3A+%7B%0A++++%22series%22+%3A+%22The+Three+Investigators%22%2C%0A++++%22volume%22+%3A+%221%22%0A++%7D%2C%0A++%22releaseDate%22+%3A+%221964%22%2C%0A++%22author%22+%3A+%22Robert+Arthur%22%2C%0A++%22characters%22+%3A+%5B+%7B%0A++++%22name%22+%3A+%22Jupiter+Jones%22%2C%0A++++%22role%22+%3A+%22Investigator%22%0A++%7D%2C+%7B%0A++++%22name%22+%3A+%22Peter+Crenshaw%22%2C%0A++++%22role%22+%3A+%22Investigator%22%0A++%7D%2C+%7B%0A++++%22name%22+%3A+%22Bob+Andrews%22%2C%0A++++%22role%22+%3A+%22Research+%26+Archive%22%0A++%7D+%5D%0A%7D)

<details>
<summary>Answer</summary>
[See here](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-json%0A%7Cfix%28transformationFile%29%0A%7Cencode-yaml%0A%7Cprint%0A%3B&transformation=retain%28%22title%22%2C%22isPartOf.series%22%2C%22characters%5B%5D.3.name%22%29&data=%7B%0A++%22title%22+%3A+%22The+Secret+of+Terror+Castle%22%2C%0A++%22isPartOf%22+%3A+%7B%0A++++%22series%22+%3A+%22The+Three+Investigators%22%2C%0A++++%22volume%22+%3A+%221%22%0A++%7D%2C%0A++%22releaseDate%22+%3A+%221964%22%2C%0A++%22author%22+%3A+%22Robert+Arthur%22%2C%0A++%22characters%22+%3A+%5B+%7B%0A++++%22name%22+%3A+%22Jupiter+Jones%22%2C%0A++++%22role%22+%3A+%22Investigator%22%0A++%7D%2C+%7B%0A++++%22name%22+%3A+%22Peter+Crenshaw%22%2C%0A++++%22role%22+%3A+%22Investigator%22%0A++%7D%2C+%7B%0A++++%22name%22+%3A+%22Bob+Andrews%22%2C%0A++++%22role%22+%3A+%22Research+%26+Archive%22%0A++%7D+%5D%0A%7D)
</details>

[Again append the last names to the specific character Justus Jonas, Peter Shaw and Bob Andrews. Also add a field to each character "type":"Person"`](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=&data=---%0Acharacters%3A+%0A++-+name%3A+Justus%0A++++role%3A+Investigator%0A++-+name%3A+Peter%0A++++role%3A+Investigator%0A++-+name%3A+Bob%0A++++role%3A+Research+%26+Archive%0A)


<details>
<summary>Answer</summary>
[See here](https://metafacture.org/playground/?flux=inputFile%0A%7Copen-file%0A%7Cas-records%0A%7Cdecode-yaml%0A%7Cfix%28transformationFile%29%0A%7Cencode-json%28prettyPrinting%3D%22true%22%29%0A%7Cprint%0A%3B&transformation=append%28%22characters%5B%5D.1.name%22%2C%22+Jonas%22%29%0Aappend%28%22characters%5B%5D.2.name%22%2C%22+Shaw%22%29%0Aappend%28%22characters%5B%5D.3.name%22%2C%22+Andrews%22%29%0Aadd_field%28%22characters%5B%5D.%2A.type%22%2C%22+Andrews%22%29&data=---%0Acharacters%3A+%0A++-+name%3A+Justus%0A++++role%3A+Investigator%0A++-+name%3A+Peter%0A++++role%3A+Investigator%0A++-+name%3A+Bob%0A++++role%3A+Research+%26+Archive%0A)
</details>

In this post we learned the JSON Path syntax and how it can be used to point to parts of a JSON data set want to manipulate. We explained the Fix path using a YAML transformation as example, because this is easier to read.

Especially when working with complex bibliographic data one has to get to know the paths so that you do not have to guess what a path to a certain element is:

There exists multiple ways to find out the path-names of records:

e.g.:
[Here a way to show pathways in combination with values.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-lines%0A%7C+decode-pica%0A%7C+fix%28%22nothing%28%29%22%2C+repeatedFieldsToEntities+%3D+%22true%22%29%0A%7C+flatten%0A%7C+encode-literals%0A%7C+print%0A%3B&data=001@+%1Fa5%1F01-2%1E001A+%1F01100%3A15-10-94%1E001B+%1F09999%3A12-06-06%1Ft16%3A10%3A17.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aag%1E003@+%1F0482147350%1E006U+%1F094%2CP05%1E007E+%1F0U+70.16407%1E007I+%1FSo%1F074057548%1E011@+%1Fa1970%1E017A+%1Farh%1E021A+%1FaDie+@Berufsfreiheit+der+Arbeitnehmer+und+ihre+Ausgestaltung+in+vo%CC%88lkerrechtlichen+Vertra%CC%88gen%1FdEine+Grundrechtsbetrachtg%1E028A+%1F9106884905%1F7Tn3%1FAgnd%1F0106884905%1FaProjahn%1FdHorst+D.%1E033A+%1FpWu%CC%88rzburg%1E034D+%1FaXXXVIII%2C+165+S.%1E034I+%1Fa8%1E037C+%1FaWu%CC%88rzburg%2C+Jur.+F.%2C+Diss.+v.+7.+Aug.+1970%1E%0A001@+%1F01%1Fa5%1E001A+%1F01140%3A08-12-99%1E001B+%1F09999%3A05-01-08%1Ft22%3A57%3A29.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aa%1E003@+%1F0958090564%1E004A+%1Ffkart.+%3A+DM+9.70%2C+EUR+4.94%2C+sfr+8.00%2C+S+68.00%1E006U+%1F000%2CB05%2C0285%1E007I+%1FSo%1F076088278%1E011@+%1Fa1999%1E017A+%1Farb%1Fasi%1E019@+%1FaXA-AT%1E021A+%1FaZukunft+Bildung%1FhPolitische+Akademie.+%5BHrsg.+von+Gu%CC%88nther+R.+Burkert-Dottolo+und+Bernhard+Moser%5D%1E028C+%1F9130681849%1F7Tp1%1FVpiz%1FAgnd%1F0130681849%1FE1952%1FaBurkert%1FdGu%CC%88nther+R.%1FBHrsg.%1E033A+%1FpWien%1FnPolit.+Akad.%1E034D+%1Fa79+S.%1E034I+%1Fa24+cm%1E036F+%1Fx299+12%1F9551720077%1FgAdn%1F7Tb1%1FAgnd%1F01040469-7%1FaPolitische+Akademie%1FgWien%1FYPA-Information%1FhPolitische+Akademie%2C+WB%1FpWien%1FJPolitische+Akad.%2C+WB%1Fl99%2C2%1E036F/01+%1Fx12%1F9025841467%1FgAdvz%1Fi2142105-5%1FYAktuelle+Fragen+der+Politik%1FhPolitische+Akademie%1FpWien%1FJPolitische+Akad.+der+O%CC%88VP%1FlBd.+2%1E045E+%1Fa22%1Fd18%1Fm370%1E047A+%1FSFE%1Fata%1E%0A001@+%1Fa5%1F01%1E001A+%1F01140%3A19-02-03%1E001B+%1F09999%3A19-06-11%1Ft01%3A20%3A13.000%1E001D+%1F09999%3A26-04-03%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aal%1E003@+%1F0361809549%1E004A+%1FfHlw.%1E006U+%1F000%2CL01%1E006U+%1F004%2CP01-s-41%1E006U+%1F004%2CP01-f-21%1E007G+%1FaDNB%1F0361809549%1E007I+%1FSo%1F072658383%1E007M+%1F04413/0275%1E011@+%1Fa1925%1E019@+%1FaXA-DXDE%1FaXA-DE%1E021A+%1FaHundert+Jahre+Buchdrucker-Innung+Hamburg%1FdWesen+u.+Werden+d.+Vereinigungen+Hamburger+Buchdruckereibesitzer+1825-1925+%3B+Gedenkschrift+zur+100.+Wiederkehr+d.+Gru%CC%88ndungstages%2C+verf.+im+Auftr.+d.+Vorstandes+d.+Buchdrucker-Innung+%28Freie+Innung%29+zu+Hamburg%1FhFriedrich+Voeltzer%1E028A+%1F9101386281%1F7Tp1%1FVpiz%1FAgnd%1F0101386281%1FE1895%1FaVo%CC%88ltzer%1FdFriedrich%1E033A+%1FpHamburg%1FnBuchdrucker-Innung+%28Freie+Innung%29%1E033A+%1FpHamburg%1Fn%5BVerlagsbuchh.+Broschek+%26+Co.%5D%1E034D+%1Fa44+S.%1E034I+%1Fa4%1E%0A001@+%1Fa5%1F01-3%1E001A+%1F01240%3A01-08-95%1E001B+%1F09999%3A24-09-10%1Ft17%3A42%3A20.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Af%1E003@+%1F0945184085%1E004A+%1F03-89007-044-2%1FfGewebe+%3A+DM+198.00%2C+sfr+198.00%2C+S+1386.00%1E006T+%1F095%2CN35%2C0856%1E006U+%1F095%2CA48%2C1186%1E006U+%1F010%2CP01%1E007I+%1FSo%1F061975997%1E011@+%1Fa1995%1E017A+%1Fara%1E021A+%1Fx213%1F9550711899%1FYNeues+Handbuch+der+Musikwissenschaft%1Fhhrsg.+von+Carl+Dahlhaus.+Fortgef.+von+Hermann+Danuser%1FpLaaber%1FJLaaber-Verl.%1FS48%1F03-89007-030-2%1FgAc%1E021B+%1FlBd.+13.%1FaRegister%1Fhzsgest.+von+Hans-Joachim+Hinrichsen%1E028C+%1F9121445453%1F7Tp3%1FVpiz%1FAgnd%1F0121445453%1FE1952%1FaHinrichsen%1FdHans-Joachim%1E034D+%1FaVIII%2C+408+S.%1E045V+%1F9090001001%1E047A+%1FSFE%1Fagb/fm%1E%0A001@+%1F01-2%1Fa5%1E001A+%1F01239%3A18-08-11%1E001B+%1F09999%3A05-09-11%1Ft23%3A31%3A44.000%1E001D+%1F01240%3A30-08-11%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Af%1E003@+%1F01014417392%1E004A+%1Ffkart.%1E006U+%1F011%2CA37%1E007G+%1FaDNB%1F01014417392%1E007I+%1FSo%1F0752937239%1E010@+%1Fager%1E011@+%1Fa2011%1E017A+%1Fara%1Fasf%1E021A+%1Fxtr%1F91014809657%1F7Tp3%1FVpiz%1FAgnd%1F01034622773%1FE1958%1FaLu%CC%88beck%1FdMonika%1FYPersonalwirtschaft+mit+DATEV%1FhMonika+Lu%CC%88beck+%3B+Helmut+Lu%CC%88beck%1FpBodenheim%1FpWien%1FJHerdt%1FRXA-DE%1FS650%1FgAc%1E021B+%1FlTrainerbd.%1E032@+%1Fg11%1Fa1.+Ausg.%1E034D+%1Fa129+S.%1E034M+%1FaIll.%1E047A+%1FSFE%1Famar%1E047A+%1FSERW%1Fasal%1E047I+%1Fu%24%1Fc04%1FdDNB%1Fe1%1E)

[Here is a way to collect and count all paths in all records by using the `list-fix-paths`-command.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-lines%0A%7C+decode-pica%0A%7C+list-fix-paths%0A%7C+print%0A%3B&data=001@+%1Fa5%1F01-2%1E001A+%1F01100%3A15-10-94%1E001B+%1F09999%3A12-06-06%1Ft16%3A10%3A17.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aag%1E003@+%1F0482147350%1E006U+%1F094%2CP05%1E007E+%1F0U+70.16407%1E007I+%1FSo%1F074057548%1E011@+%1Fa1970%1E017A+%1Farh%1E021A+%1FaDie+@Berufsfreiheit+der+Arbeitnehmer+und+ihre+Ausgestaltung+in+vo%CC%88lkerrechtlichen+Vertra%CC%88gen%1FdEine+Grundrechtsbetrachtg%1E028A+%1F9106884905%1F7Tn3%1FAgnd%1F0106884905%1FaProjahn%1FdHorst+D.%1E033A+%1FpWu%CC%88rzburg%1E034D+%1FaXXXVIII%2C+165+S.%1E034I+%1Fa8%1E037C+%1FaWu%CC%88rzburg%2C+Jur.+F.%2C+Diss.+v.+7.+Aug.+1970%1E%0A001@+%1F01%1Fa5%1E001A+%1F01140%3A08-12-99%1E001B+%1F09999%3A05-01-08%1Ft22%3A57%3A29.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aa%1E003@+%1F0958090564%1E004A+%1Ffkart.+%3A+DM+9.70%2C+EUR+4.94%2C+sfr+8.00%2C+S+68.00%1E006U+%1F000%2CB05%2C0285%1E007I+%1FSo%1F076088278%1E011@+%1Fa1999%1E017A+%1Farb%1Fasi%1E019@+%1FaXA-AT%1E021A+%1FaZukunft+Bildung%1FhPolitische+Akademie.+%5BHrsg.+von+Gu%CC%88nther+R.+Burkert-Dottolo+und+Bernhard+Moser%5D%1E028C+%1F9130681849%1F7Tp1%1FVpiz%1FAgnd%1F0130681849%1FE1952%1FaBurkert%1FdGu%CC%88nther+R.%1FBHrsg.%1E033A+%1FpWien%1FnPolit.+Akad.%1E034D+%1Fa79+S.%1E034I+%1Fa24+cm%1E036F+%1Fx299+12%1F9551720077%1FgAdn%1F7Tb1%1FAgnd%1F01040469-7%1FaPolitische+Akademie%1FgWien%1FYPA-Information%1FhPolitische+Akademie%2C+WB%1FpWien%1FJPolitische+Akad.%2C+WB%1Fl99%2C2%1E036F/01+%1Fx12%1F9025841467%1FgAdvz%1Fi2142105-5%1FYAktuelle+Fragen+der+Politik%1FhPolitische+Akademie%1FpWien%1FJPolitische+Akad.+der+O%CC%88VP%1FlBd.+2%1E045E+%1Fa22%1Fd18%1Fm370%1E047A+%1FSFE%1Fata%1E%0A001@+%1Fa5%1F01%1E001A+%1F01140%3A19-02-03%1E001B+%1F09999%3A19-06-11%1Ft01%3A20%3A13.000%1E001D+%1F09999%3A26-04-03%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Aal%1E003@+%1F0361809549%1E004A+%1FfHlw.%1E006U+%1F000%2CL01%1E006U+%1F004%2CP01-s-41%1E006U+%1F004%2CP01-f-21%1E007G+%1FaDNB%1F0361809549%1E007I+%1FSo%1F072658383%1E007M+%1F04413/0275%1E011@+%1Fa1925%1E019@+%1FaXA-DXDE%1FaXA-DE%1E021A+%1FaHundert+Jahre+Buchdrucker-Innung+Hamburg%1FdWesen+u.+Werden+d.+Vereinigungen+Hamburger+Buchdruckereibesitzer+1825-1925+%3B+Gedenkschrift+zur+100.+Wiederkehr+d.+Gru%CC%88ndungstages%2C+verf.+im+Auftr.+d.+Vorstandes+d.+Buchdrucker-Innung+%28Freie+Innung%29+zu+Hamburg%1FhFriedrich+Voeltzer%1E028A+%1F9101386281%1F7Tp1%1FVpiz%1FAgnd%1F0101386281%1FE1895%1FaVo%CC%88ltzer%1FdFriedrich%1E033A+%1FpHamburg%1FnBuchdrucker-Innung+%28Freie+Innung%29%1E033A+%1FpHamburg%1Fn%5BVerlagsbuchh.+Broschek+%26+Co.%5D%1E034D+%1Fa44+S.%1E034I+%1Fa4%1E%0A001@+%1Fa5%1F01-3%1E001A+%1F01240%3A01-08-95%1E001B+%1F09999%3A24-09-10%1Ft17%3A42%3A20.000%1E001D+%1F09999%3A99-99-99%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Af%1E003@+%1F0945184085%1E004A+%1F03-89007-044-2%1FfGewebe+%3A+DM+198.00%2C+sfr+198.00%2C+S+1386.00%1E006T+%1F095%2CN35%2C0856%1E006U+%1F095%2CA48%2C1186%1E006U+%1F010%2CP01%1E007I+%1FSo%1F061975997%1E011@+%1Fa1995%1E017A+%1Fara%1E021A+%1Fx213%1F9550711899%1FYNeues+Handbuch+der+Musikwissenschaft%1Fhhrsg.+von+Carl+Dahlhaus.+Fortgef.+von+Hermann+Danuser%1FpLaaber%1FJLaaber-Verl.%1FS48%1F03-89007-030-2%1FgAc%1E021B+%1FlBd.+13.%1FaRegister%1Fhzsgest.+von+Hans-Joachim+Hinrichsen%1E028C+%1F9121445453%1F7Tp3%1FVpiz%1FAgnd%1F0121445453%1FE1952%1FaHinrichsen%1FdHans-Joachim%1E034D+%1FaVIII%2C+408+S.%1E045V+%1F9090001001%1E047A+%1FSFE%1Fagb/fm%1E%0A001@+%1F01-2%1Fa5%1E001A+%1F01239%3A18-08-11%1E001B+%1F09999%3A05-09-11%1Ft23%3A31%3A44.000%1E001D+%1F01240%3A30-08-11%1E001U+%1F0utf8%1E001X+%1F00%1E002@+%1F0Af%1E003@+%1F01014417392%1E004A+%1Ffkart.%1E006U+%1F011%2CA37%1E007G+%1FaDNB%1F01014417392%1E007I+%1FSo%1F0752937239%1E010@+%1Fager%1E011@+%1Fa2011%1E017A+%1Fara%1Fasf%1E021A+%1Fxtr%1F91014809657%1F7Tp3%1FVpiz%1FAgnd%1F01034622773%1FE1958%1FaLu%CC%88beck%1FdMonika%1FYPersonalwirtschaft+mit+DATEV%1FhMonika+Lu%CC%88beck+%3B+Helmut+Lu%CC%88beck%1FpBodenheim%1FpWien%1FJHerdt%1FRXA-DE%1FS650%1FgAc%1E021B+%1FlTrainerbd.%1E032@+%1Fg11%1Fa1.+Ausg.%1E034D+%1Fa129+S.%1E034M+%1FaIll.%1E047A+%1FSFE%1Famar%1E047A+%1FSERW%1Fasal%1E047I+%1Fu%24%1Fc04%1FdDNB%1Fe1%1E)

Other ways are also possible, too.

## Bonus: XML in MF and their paths

`<title>This is the title</title>`

The path for the value `This is the title` is not `title` but `title.value`

XMLs are not just simple elements with key-pair values or objects with subfields but each elemnt can have additional attributs. In Metafacture the xml decoder (`decode-xml` with `handle-generic-xml`) groups the attributes and values as subfields of an object.

`<title type="mainTitle" lang="eng">This is the title</title>`

The path for the different attributs and elements are the following:

```YAML
title.value
title.type
title.lang
```

If you want to create xml with attributes then you need to map to this structure too. We will come back to lection working with xml in lesson 10.

Next lessons: [05 More Fix Concepts](./05-More-Fix-Concepts.md)