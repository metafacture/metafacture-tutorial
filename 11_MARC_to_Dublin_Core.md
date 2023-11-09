# TODO : Lesson 11 : From MARC to Dublin Core as loud JSON-LD

Today we will look a bit further into MARC processing with Metafacture. We already saw a bit of MARC processing in and today we will show you how to transform MARC records into Dublin Core and providing the data as linked open usable data.

To transform this MARC file into Dublin Core we need to create a fix file. You can use any texteditor for this and create a file dublin.fix (or use the transformationFile window in the playground):

And type into this textfile the following fixes:

```PEARL
copy_field("245??.a","title")
set_array("creator[]")
copy_field("100??.a","creator[].$append")
copy_field("700??.a","creator[].$append")
copy_field("260??.c","date")
copy_field("260??.b","publisher")

set_array("isbn[]")
do list(path:"020??","var":"$i")
    copy_field("$i.a","isbn[].$append")
end
set_array("isbn[]")
do list(path:"022??","var":"$i")
    copy_field("$i.a","issn[].$append")
end

set_array("subject[]")
do list(path:"650??","var":"$i")
    copy_field("$i.a","subject[].$append")
end

retain("title","creator[]","date","publisher","isbn[]","issn[]","subject[]")
```

Every MARC record contains in the 245-field the title of a record. In the first line we map the MARC-245 field to new field in the record called title:
`copy_field("245??.a","title")``

In the line 2-4 we map authors to a field creator. In the the marc records the authors are stored in the MARC-100 and MARC-700 field. Because there is usually more than one author in a record, we need to $append them to create an array (a list) of one or more creator-s.

In line 5 and line 6 we read the MARC-260 field which contains publisher and date information. Here we don’t need the $append trick because there is usually only one 260-field in a MARC record.

In line 7 to line 15 we do the same trick to filter out the ISBN and ISSN number out of the record which we store in separate fields isbn and issn (indeed these are not Dublin Core fields, we will process them later). But because these elements can be repeated we iterate over them with a list bind and copy the values in an array.

In line 16-19 the subjects are to extracted from the 260-field using the same $append trick as above. Notice that we only extracted the $a subfields?

We end the fix and retain only those elements that we want to keep.

Given the dublin.txt file above we can execute the filtering command like this:

TODO: Explain how to run the function with CLI.


```
"https://raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21"
| open-http
| as-lines
| decode-marc21
| fix(transformationFile)
| encode-yaml
| print
;
```

The results should look like this:

_id: '000000002'
creator:
- Katz, Jerrold J.
date: '1977.'
isbn:
- '0855275103 :'
publisher: Harvester press,
subject:
- Semantics.
- Proposition (Logic)
- Speech acts (Linguistics)
- Generative grammar.
- Competence and performance (Linguistics)
title: Propositional structure and illocutionary force :a study of the contribution of sentence meaning to speech acts /Jerrold J. Katz.
...

Congratulations, you’ve created your first mapping file to transform library data from MARC to Dublin Core! We need to add a bit more cleaning to delete some periods and commas here and there but as is we already have our first mapping.

Below you’ll find a complete example. You can read more about our Fix language online.

```PEARL
set_array("title")
copy_field("245??.?","title.$append")
join_field("title", " ")
set_array("creator[]")
copy_field("100??.a","creator[].$append")
copy_field("700??.a","creator[].$append")
copy_field("260??.c","date")
replace_all("date","\D+","")
copy_field("260??.b","publisher")
replace_all("publisher",",$","")

add_field("type","BibliographicResource")

set_array("isbn[]")
do list(path:"020??","var":"$i")
    copy_field("$i.a","isbn[].$append")
end
replace_all("isbn.*"," .","")

set_array("isbn[]")
do list(path:"022??","var":"$i")
    copy_field("$i.a","issn[].$append")
end
replace_all("issn.*"," .","")

set_array("subject[]")
do list(path:"650??","var":"$i")
    copy_field("$i.a","subject[].$append")
end

retain("title","creator[]","date","publisher","isbn[]","issn[]","subject[]")
```

We can turn this data also to JSON-LD by adding a context that specifies the elements with URIs.

Add the following fix to the fix above:

```PEARL
add_field("@context.title","http://purl.org/dc/terms/title")
add_field("@context.creator","http://purl.org/dc/elements/1.1/creator")
add_field("@context.date","http://purl.org/dc/elements/1.1/date")
add_field("@context.publisher","http://purl.org/dc/elements/1.1/publisher")
add_field("@context.subject","http://purl.org/dc/elements/1.1/subject")
add_field("@context.isbn","http://purl.org/ontology/bibo/isbn")
add_field("@context.issn","http://purl.org/ontology/bibo/issn")
```

The result should look like this:
https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+encode-json%28prettyPrinting%3D%22true%22%29%0A%7C+print%0A%3B&transformation=set_array%28%22title%22%29%0Acopy_field%28%22245%3F%3F.%3F%22%2C%22title.%24append%22%29%0Ajoin_field%28%22title%22%2C+%22+%22%29%0Aset_array%28%22creator%5B%5D%22%29%0Acopy_field%28%22100%3F%3F.a%22%2C%22creator%5B%5D.%24append%22%29%0Acopy_field%28%22700%3F%3F.a%22%2C%22creator%5B%5D.%24append%22%29%0Acopy_field%28%22260%3F%3F.c%22%2C%22date%22%29%0Areplace_all%28%22date%22%2C%22\\D%2B%22%2C%22%22%29%0Acopy_field%28%22260%3F%3F.b%22%2C%22publisher%22%29%0Areplace_all%28%22publisher%22%2C%22%2C%24%22%2C%22%22%29%0A%0Aadd_field%28%22type%22%2C%22BibliographicResource%22%29%0A%0Aset_array%28%22isbn%5B%5D%22%29%0Ado+list%28path%3A%22020%3F%3F%22%2C%22var%22%3A%22%24i%22%29%0A++++copy_field%28%22%24i.a%22%2C%22isbn%5B%5D.%24append%22%29%0Aend%0Areplace_all%28%22isbn.%2A%22%2C%22+.%22%2C%22%22%29%0A%0Aset_array%28%22isbn%5B%5D%22%29%0Ado+list%28path%3A%22022%3F%3F%22%2C%22var%22%3A%22%24i%22%29%0A++++copy_field%28%22%24i.a%22%2C%22issn%5B%5D.%24append%22%29%0Aend%0Areplace_all%28%22issn.%2A%22%2C%22+.%22%2C%22%22%29%0A%0Aset_array%28%22subject%5B%5D%22%29%0Ado+list%28path%3A%22650%3F%3F%22%2C%22var%22%3A%22%24i%22%29%0A++++copy_field%28%22%24i.a%22%2C%22subject%5B%5D.%24append%22%29%0Aend%0A%0Aadd_field%28%22@context.title%22%2C%22http%3A//purl.org/dc/terms/title%22%29%0Aadd_field%28%22@context.creator%22%2C%22http%3A//purl.org/dc/elements/1.1/creator%22%29%0Aadd_field%28%22@context.date%22%2C%22http%3A//purl.org/dc/elements/1.1/date%22%29%0Aadd_field%28%22@context.publisher%22%2C%22http%3A//purl.org/dc/elements/1.1/publisher%22%29%0Aadd_field%28%22@context.subject%22%2C%22http%3A//purl.org/dc/elements/1.1/subject%22%29%0Aadd_field%28%22@context.isbn%22%2C%22http%3A//purl.org/ontology/bibo/isbn%22%29%0Aadd_field%28%22@context.issn%22%2C%22http%3A//purl.org/ontology/bibo/issn%22%29%0A%0Aretain%28%22@context%22%2C%22title%22%2C%22creator%5B%5D%22%2C%22date%22%2C%22publisher%22%2C%22isbn%5B%5D%22%2C%22issn%5B%5D%22%2C%22subject%5B%5D%22%29


> TODO: 
> Create the metafacture workflow to transform Marc to JSON.
> Map the marc data to DC.
> Also add an context for creating JSON LD.
> Add excersise.
