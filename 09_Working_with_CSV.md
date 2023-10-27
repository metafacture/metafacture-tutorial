## Lesson 9: Working with CSV and TSV files

CSV and TSV files are widely-used to store and exchange simple structured data. Many open datasets are published as CSV or TSV files, e.g. datahub.io. Within the library community CSV files are used for the distribution of title lists (KBART), e.g Knowledge Base+.

Metafacture implements an decoder and encoder for both formats: decode-csv and encode-csv.

So get some CSV data to work with:

``````
"https://lib.ugent.be/download/librecat/data/goodreads.csv"
| open-http
| as-lines
| print
;
``````
It shows a CSV file with a header row at the beginnung.

Now you can convert the data to different formats, like JSON, YAML and XML by decoding the data as csv and encoding it in the desired format:

https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%0A%7C+encode-json%28prettyPrinting%3D%22true%22%29+//+or+encode-xml+or+encode-yaml%0A%7C+print%0A%3B

See that the elements have no name literal names but are only numbers.
But the csv has a header we need to add the option `(hasHeader="true")` to `decode-csv` in the flux.


You can extract specified fields while converting to another tabular format by using the fix. This is quite handy for analysis of specific fields or to generate reports.

https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasHeader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28includeHeader%3D%22true%22%29%0A%7C+print%0A%3B&transformation=retain%28%22ISBN%22%2C%22Title%22%2C%22Author%22%29

By default Metafactures `decode-csv` expects that CSV fields are separated by comma ‘,’ and strings are quoted with double qoutes ‘”‘ or single quotes `'`. You can specify other characters as separator or quotes with the option ‘separator’ and clean special quote signs with the fix:

See:

https://test.metafacture.org/playground/?flux=%2212157%3B%24The+Journal+of+Headache+and+Pain%24%3B2193-1801%22%0A%7C+read-string%0A%7C+as-lines%0A%7C+decode-csv%28separator%3D%22%3B%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28separator%3D%22\t%22%2C+includeheader%3D%22true%22%29%0A%7C+print%3B&transformation=replace_all%28%22%3F%22%2C%22%5E\\%24%7C\\%24%24%22%2C%22%22%29


(Different to Catmandu quote-chars cannot be manipulated by the decoder directly.)

In the example above we read the string as a little CSV fragment using the `read-string` command for our small test. It will read the tiny CSV string which uses “;” and “$” as separation and quotation characters.
The string is then read each line by `as-lines` and decoded as csv with the separator `,`.

With a little fix you can 

When exporting data a tabular format you can change the field names in the header or omit the header:

https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasheader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28includeHeader%3D%22true%22%29%0A%7C+print%3B&transformation=move_field%28%22ISBN%22%2C%22A%22%29%0Amove_field%28%22Title%22%2C%22B%22%29%0Amove_field%28%22Author%22%2C%22C%22%29%0A%0Aretain%28%22A%22%2C%22B%22%2C%22C%22%29

You can transform the data to an tsv file with the separator \t which has no header like this.

https://metafacture.org/playground/?flux=%22https%3A//lib.ugent.be/download/librecat/data/goodreads.csv%22%0A%7C+open-http%0A%7C+as-lines%0A%7C+decode-csv%28hasheader%3D%22true%22%29%0A%7C+fix%28transformationFile%29%0A%7C+encode-csv%28separator%3D%22\t%22%2C+noQuotes%3D%22true%22%29%0A%7C+print%3B&transformation=retain%28%22ISBN%22%2C%22Title%22%2C%22Author%22%29

If you want to export complex/nested data structures to a tabular format, you must “flatten” the datastructure. This could be done with Metafacture. But be aware that the nested structure if repeatble elements are provided have to be the same every time. Otherwise the header and the csv file do not fit:

https://test.metafacture.org/playground/?flux=%22https%3A//lobid.org/organisations/search%3Fq%3Dk%25C3%25B6ln%26size%3D10%22%0A%7C+open-http%28accept%3D%22application/json%22%29%0A%7C+as-records%0A%7C+decode-json%28recordpath%3D%22member%22%29%0A%7C+flatten%0A%7C+encode-csv%28includeheader%3D%22true%22%29%0A%7C+print%3B

> TODO: Add excercises.


Next lesson: [10 Working with XML](./10_Working_with_XML.md)
