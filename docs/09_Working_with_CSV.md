---
layout: default
title: "Lesson 9: Working with CSV/TSV"
nav_order: 9
parent: Tutorial
---


# Lesson 9: Working with CSV and TSV files

CSV and TSV files are widely-used to store and exchange simple structured data. Many open datasets are published as CSV or TSV files, see e.g. datahub.io. Within the library community CSV files are used for the distribution of title lists (KBART), e.g Knowledge Base+.

Metafacture implements a decoder and an encoder which you can youse for both formats: `decode-csv` and `encode-csv`.

## Reading CSVs

Get some CSV data to work with:

```text
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| print
;
```

It shows a CSV file with a header row at the beginning.

Convert the data to different serializations, like JSON, YAML and XML by decoding the data as CSV and encoding it in the desired serialization:

```
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| decode-csv
| encode-json(prettyPrinting="true") // or encode-xml or encode-yaml
| print
;
```

[See in playground.](https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%0A%7C+encode-json%28prettyPrinting%3D%22true%22%29+//+or+encode-xml+or+encode-yaml%0A%7C+print%0A%3B)

See that the elements have no literal names but only numbers.
As the CSV has a header we need to add the option `(hasHeader="true")` to `decode-csv` in the Flux.

You can extract specified fields while converting to another tabular format by using the Fix. This is quite handy for analysis of specific fields or to generate reports. In the following example we only keep three columns (`"ISBN"`,`"Title"`,`"Author"`):

Flux:

```text
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| decode-csv(hasHeader="true")
| fix(transformationFile)
| encode-csv(includeHeader="true")
| print
;
```

With Fix:

```perl
retain("ISBN","Title","Author")
```

[See the example in the Playground](https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasHeader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28includeHeader%3D%22true%22%29%0A%7C+print%0A%3B&transformation=retain%28%22ISBN%22%2C%22Title%22%2C%22Author%22%29)

By default Metafactures `decode-csv` expects that CSV fields are separated by comma `,` and strings are quoted with double qoutes `"` or single quotes `'`. You can specify other characters as separator or quotes with the option `separator` and clean special quote signs using the Fix. (In contrast to Catmandu quote-chars cannot be manipulated by the decoder directly, yet.)

Flux:

```text
"12157;$The Journal of Headache and Pain$;2193-1801"
| read-string
| as-lines
| decode-csv(separator=";")
| fix(transformationFile)
| encode-csv(separator="\t", includeheader="true")
| print;
```

Fix:

```perl
replace_all("?","^\\$|\\$$","")
```

[See the example in the Playground.](https://metafacture.org/playground/?flux=%2212157%3B%24The+Journal+of+Headache+and+Pain%24%3B2193-1801%22%0A%7C+read-string%0A%7C+as-lines%0A%7C+decode-csv%28separator%3D%22%3B%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28separator%3D%22\t%22%2C+includeheader%3D%22true%22%29%0A%7C+print%3B&transformation=replace_all%28%22%3F%22%2C%22%5E\\%24%7C\\%24%24%22%2C%22%22%29)

In the example above we read the string as a little CSV fragment using the `read-string` command for our small test. It will read the tiny CSV string which uses `;` and `$` as separation and quotation characters.
The string is then read each line by `as-lines` and decoded as csv with the separator `,`.

## Writing CSVs

When harvesting data in tabular format you also can change the field names in the header or omit the header:

Flux:

```text
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| decode-csv(hasheader="true")
| fix(transformationFile)
| encode-csv(includeHeader="true")
| print;
```

Fix:

```perl
move_field("ISBN","A")
move_field("Title","B")
move_field("Author","C")

retain("A","B","C")
```

[See example in he playground.](https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasheader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28includeHeader%3D%22true%22%29%0A%7C+print%3B&transformation=move_field%28%22ISBN%22%2C%22A%22%29%0Amove_field%28%22Title%22%2C%22B%22%29%0Amove_field%28%22Author%22%2C%22C%22%29%0A%0Aretain%28%22A%22%2C%22B%22%2C%22C%22%29)

You can transform the data to a TSV file with the separator `\t` which has no header like this:

```text
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| decode-csv(hasheader="true")
| encode-csv(separator="\t", noQuotes="true")
| print;
```

[See example in playground.](https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasheader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28separator%3D%22\t%22%2C+noQuotes%3D%22true%22%29%0A%7C+print%3B&transformation=retain%28%22ISBN%22%2C%22Title%22%2C%22Author%22%29)

When you create a CSV from complex/nested data structures to a tabular format, you must “flatten” the datastructure. Also you have to be aware that the order and number of elements in every record is the same as the header should match the records.

So: make sure that the nested structure of repeatable elements is identical every time. Otherwise the [header and the CSV file do not fit](https://metafacture.org/playground/?flux=%22https%3A//lobid.org/organisations/search%3Fq%3Dk%25C3%25B6ln%26size%3D10%22%0A%7C+open-http%28accept%3D%22application/json%22%29%0A%7C+as-records%0A%7C+decode-json%28recordpath%3D%22member%22%29%0A%7C+flatten%0A%7C+encode-csv%28includeheader%3D%22true%22%29%0A%7C+print%3B).

Excercises:

- [Decode this CSV while keeping the header.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A...%0A...%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%22id%22%2C%22name%22%2C%22creator%22%0A%221%22%2C%22Book+1%22%2C%22Maxi+Muster%22%0A%222%22%2C%22Book+2%22%2C%22Sandy+Sample%22)
- [Create a TSV with the record idenfier (`_id`), title (`245` > `title`) and isbn (`020` > `isbn`) from a marc dump.](https://metafacture.org/playground/?flux=%22https%3A//raw.githubusercontent.com/metafacture/metafacture-core/master/metafacture-runner/src/main/dist/examples/read/marc21/10.marc21%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-marc21%0A%7C+fix%28transformationFile%29%0A%7C+flatten%0A%7C+encode-csv%28includeHeader%3D%22TRUE%22%2C+separator%3D%22\t%22%2C+noQuotes%3D%22false%22%29%0A%7C+print%0A%3B&transformation=)

---------------

**Next lesson**: [10 Working with XML](./10_Working_with_XML.html)
