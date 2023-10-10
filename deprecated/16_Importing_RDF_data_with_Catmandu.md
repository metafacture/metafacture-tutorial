# TODO: Day 16: Importing RDF data with Catmandu

16_librecatA common problem of data processing is the large number of data formats, dialects, and conceptions. For instance the author field in one record format may differ from a similar field another format in its meaning or name. As shown in the previous articles, Catmandu can help to bridge such differences, but it can also help to map from and to data structured in a completely different paradigm. This article will show how to process data expressed in RDF, the language of Semantic Web and Linked Open Data.

RDF differs from previous formats, such as JSON and YAML, MARC, or CSV in two important aspects:

    There are no records and fields: RDF data instead is a graph structure, build of nodes (“resources” or “values”) and directed links.
    Link types (“properties”) are identified by URI and defined in “ontologies”. In theory this removes the introductory common problem of data processing.

Because graph structures are fundamentally different to record structures, there is no obvious mapping between RDF and records in Catmandu. For this reason you better use dedicated RDF technology as long as your data is RDF. Catmandu, however, can help to process from RDF and to RDF, as shown today and tomorrow, respectively. Let’s first install the Catmandu module Catmandu::RDF for RDF processing:

$ cpanm –sudo Catmandu::RDF

If you happen to use this on a virtual machine from the Catmandu USB stick, you may first have to update another module to remove a nasty bug (the password is “catmandu”):

$ cpanm –sudo List::Util

You can now retrieve RDF data from any Linked Open Data URI like this:

$ catmandu convert RDF –url http://dx.doi.org/10.2474/trol.7.147 to YAML

We could also download RDF data into a file and parse the file with Catmandu afterwards:

$ curl -L -H 'Accept: application/rdf+xml' http://dx.doi.org/10.2474/trol.7.147 > rdf.xml
$ catmandu convert RDF --type rdfxml to YAML < rdf.xml
$ catmandu convert RDF --file rdf.xml to YAML # alternatively

Downloading RDF with Catmandu::RDF option --url, however, is shorter and adds an _url field that contains the original source. The RDF data converted to YAML with Catmandu looks like this (I removed some parts to keep it shorter). The format is called another RDF Encoding Form (aREF) because it can be transformed from and to other RDF encodings:

---
_url: http://dx.doi.org/10.2474/trol.7.147
http://dx.doi.org/10.2474/trol.7.147:
  dct_title: Frictional Coefficient under Banana Skin@
  dct_creator:
  - <http://id.crossref.org/contributor/daichi-uchijima-y2ol1uygjx72>
  - <http://id.crossref.org/contributor/kensei-tanaka-y2ol1uygjx72>
  - <http://id.crossref.org/contributor/kiyoshi-mabuchi-y2ol1uygjx72>
  - <http://id.crossref.org/contributor/rina-sakai-y2ol1uygjx72>
  dct_date:- 2012^xs_gYear
  dct_isPartOf: <http://id.crossref.org/issn/1881-2198>
http://id.crossref.org/issn/1881-2198:
  a: bibo_Journal
  bibo_issn: 1881-2198@
  dct_title: Tribology Online@
http://id.crossref.org/contributor/daichi-uchijima-y2ol1uygjx72:
  a: foaf_Person
  foaf_name:Daichi Uchijima@
http://id.crossref.org/contributor/kensei-tanaka-y2ol1uygjx72:
  foaf_name: Kensei Tanaka@
http://id.crossref.org/contributor/kiyoshi-mabuchi-y2ol1uygjx72:
  foaf_name: Kiyoshi Mabuchi@
http://id.crossref.org/contributor/rina-sakai-y2ol1uygjx72:
  foaf_name: Rina Sakai@
...

The sample record contains a special field _url with the original source URL and six fields with URLs (or URIs), each corresponding to an RDF resource. The field with the original source URL (http://dx.doi.org/10.2474/trol.7.147) can be used as starting point. Each subfield (dct_title, dct_creator, dct_date, dct_isPartOf) corresponds to an RDF property, abbreviated with namespace prefix. To fetch data from these fields, we could use normal fix functions and JSON path expressions, as shown at day 7 but there is a better way:

Catmandu::RDF provides the fix function aref_query to map selected parts of the RDF graph to another field. Try to get the the title field with this command:

$ catmandu convert RDF –url http://dx.doi.org/10.2474/trol.7.147 –fix ‘aref_query(dct_title,title)’ to YAML

More complex transformations should better be put into a fix file, so create file rdf.fix with the following content:

aref_query(dct_title,title)
aref_query(dct_date,date);
aref_query(dct_creator.foaf_name,author)
aref_query(dct_isPartOf.dct_title,journal)

If you apply the fix, there are four additional fields with data extracted from the RDF graph:

$ catmandu convert RDF –url http://dx.doi.org/10.2474/trol.7.147 –fix rdf.fix to YAML

The aref_query function also accepts a language, similar to JSON path, but the path is applied to an RDF graph instead of a simple hierarchy. Moreover one can limit results to plain strings or to URIs. For instance the author URIs can be accessed with aref_query(dct_creator.,author). This feature is useful especially if RDF data contains a property with multiple types of objects, literal strings, and other resources. We can aggregate both with the following fixes:

aref_query(dct_creator@, authors)
aref_query(dct_creator.foaf_name@, authors)

Before proceeding you should add the following option to config file catmandu.yaml:

importer:
  RDF:
    package: RDF
    options:
      ns: 2014091

This makes sure that RDF properties are always abbreviated with the same prefixes, for instance dct for http://purl.org/dc/terms/.