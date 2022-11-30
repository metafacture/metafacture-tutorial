# TODO: Day 10: Working with CSV and Excel files

10_librecatCSV and Excel files are widely-used to store and exchange simple structured data. Many open datasets are published as CSV files, e.g. datahub.io. Within the library community CSV files are used for the distribution of title lists (KBART), e.g Knowledge Base+. Excel spreadsheets are often used to generate reports.

Catmandu implements importer and exporter for both formats. The CVS module is already part of the core system, the Catmandu::XLS and Catmandu::Exporter::Table modules may have to be installed separatly (note these steps are not required if you have the virtual catmandu box):

$ sudo cpanm Catmandu::XLS
$ sudo cpanm Catmandu::Exporter::Table

Get some CSV data to work with:

$ curl "https://lib.ugent.be/download/librecat/data/goodreads.csv" > goodreads.csv

Now you can convert the data to different formats, like JSON, YAML and XML.

$ catmandu convert CSV to XML < goodreads.csv
$ catmandu convert CSV to XLS --file goodreads.xls < goodreads.csv
$ catmandu convert XLS to JSON < goodreads.xls
$ catmandu convert CSV to XLSX --file goodreads.xlsx < goodreads.csv
$ catmandu convert XLSX to YAML < goodreads.xlsx

You can extract specified fields while converting to another tabular format. This is quite handy for analysis of specific fields or to generate reports.

$ catmandu convert CSV to TSV --fields ISBN,Title < goodreads.csv
$ catmandu convert CSV to XLS --fields 'ISBN,Title,Author' --file goodreads.xls < goodreads.csv

The field names are read from the header line or must be given via the ‘fields’ parameter.

By default Catmandu expects that CSV fields are separated by comma ‘,’ and strings are quoted with double qoutes ‘”‘. You can specify other characters as separator or quotes with the parameters ‘sep_char’ and ‘quote_char’:

$ echo '12157;$The Journal of Headache and Pain$;2193-1801' | catmandu convert CSV --header 0 --fields 'id,title,issn' --sep_char ';' --quote_char '$'

In the example above we create a little CSV fragment using to “echo” command for our small test. It will print a tiny CSV string which uses “;” and “$” as separation and quotation characters.

When exporting data a tabular format you can change the field names in the header or omit the header:

$ catmandu convert CSV to CSV --fields 'ISBN,Title,Author' --columns 'A,B,C' < goodreads.csv
$ catmandu convert CSV to TSV --fields 'ISBN,Title,Author' --header 0 < goodreads.csv

If you want to export complex/nested data structures to a tabular format, you must “flatten” the datastructure. This could be done with “Fixes“.

See Catmandu::Importer::CSV, Catmandu::Exporter::CSV and Catmandu::XLS for further documentation.