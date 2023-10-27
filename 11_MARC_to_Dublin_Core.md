# TODO : Day 15 : From MARC to Dublin Core as loud JSON-LD

Today we will look a bit further into MARC processing with Metafacture. We already saw a bit of MARC processing in and today we will show you how to transform MARC records into Dublin Core. 



TODO: Is this also workable with MF? This as a preparation to create RDF and Linked Data in the later posts?

First I’m going to teach you how to process different types of MARC files. On the Virtual Catmandu system we provided five  example MARC files. You can find them in your Documents folder:

    Documents/camel.mrk
    Documents/camel.usmarc
    Documents/marc.xml
    Documents/rug01.aleph
    Documents/rug01.sample

When you examine these files with the UNIX less command you will see that all the files have a bit different format:

$ less Documents/camel.mrk
$ less Documents/camel.usmarc
$ less Documents/marc.xml
$ less Documents/rug01.sample

There are many ways in which MARC data can be written into a file. Every vendor likes to use its own format. You can compare this with the different ways a text document can be stored: as Word, as Open Office, as PDF and plain text. If we are going to process these files with catmandu, then we need to tell the system what the exact format is.

We will work today with the last example rug01.sample which is a small export out of the Aleph catalog from Ghent University Library. Ex Libris uses a special MARC format to structure their data which is called Aleph sequential. We need to tell catmandu not only that our input file is in MARC but also in this special Aleph format. Let’s try to create YAML to see what it gives:

$ catmandu convert MARC --type ALEPHSEQ to YAML < Documents/rug01.sample

To transform this MARC file into Dublin Core we need to create a fix file. You can use the UNIX command nano for this (hint: see day 5 how to create files with nano). Create a file dublin.fix:

$ nano dublin.fix

And type into nano the following fixes:

marc_map(245,title)

marc_map(100,creator.$append)
marc_map(700,creator.$append)

marc_map(020a,isbn.$append)
marc_map(022a,issn.$append)

marc_map(260b,publisher)
marc_map(260c,date)

marc_map(650a,subject.$append)

remove_field(record)

Every MARC record contains in the 245-field the title of a record. In the first line we map the MARC-245 field to new field in the record called title:

marc_map(245,title)

In the second and third line we map authors to a field creator. In the rug01.sample file the authors are stored in the MARC-100 and MARC-700 field. Because there is usually more than one author in a record, we need to $append them to create an array (a list) of one or more creator-s.

In line 4 and line 5 we do the same trick to filter out the ISBN and ISSN number out of the record which we store in separate fields isbn and issn (indeed these are not Dublin Core fields, we will process them later).

In line 6 and line 7 we read the MARC-260 field which contains publisher and date information. Here we don’t need the $append trick because there is usually only one 260-field in a MARC record.

In line 8 the subjects are extracted from the 260-field using the same $append trick as above. Notice that we only extracted the $a subfields? If you want to add more subfields you can list them as in marc_map(650abcdefgh,subject.$append)

Given the dublin.txt file above we can execute the filtering command like this:

$ catmandu convert MARC --type ALEPHSEQ to YAML --fix dublin.fix < Documents/rug01.sample

As always you can type | less at the end of this command to slow down the screen output, or store the results into a file with > results.txt. Hint:

$ catmandu convert MARC --type ALEPHSEQ to YAML --fix dublin.fix < Documents/rug01.sample | less
$ catmandu convert MARC --type ALEPHSEQ to YAML --fix dublin.fix < Documents/rug01.sample > results.txt

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

marc_map(245,title, -join => " ")

marc_map(100,creator.$append)
marc_map(700,creator.$append)

marc_map(020a,isbn.$append)
marc_map(022a,issn.$append)

replace_all(isbn.," .","")
replace_all(issn.," .","")

marc_map(260b,publisher)
replace_all(publisher,",$","")

marc_map(260c,date)
replace_all(date,"\D+","")

marc_map(650a,subject.$append)
remove_field(record)

> TODO: 
> Create the metafacture workflow to transform Marc to JSON.
> Map the marc data to DC.
> Also add an context for creating JSON LD.
> Add excersise.
