# TODO: Day 13: Harvest data with OAI-PMH

14_librecatThe Open Archives Initiative Protocol for Metadata Harvesting (OAI-PMH) is a protocol to harvest metadata records from OAI compliant repositories. It was developed by the Open Archives Initiative as a low-barrier mechanism for repository interoperability. The Open Archives Initiative maintains a registry of OAI data providers.

Every OAI server must provide metadata records in Dublin Core, other (bibliographic) formats like MARC may be supported additionally. Available metadata formats can be detected with “ListMetadataFormats“. You can set the metadata format for the Catmandu OAI client via the --metadataPrefix parameter.

The OAI server may support selective harvesting, so OAI clients can get only subsets of records from a repository. The client requests could be limited via datestamps (--from, --until) or set membership (--set).

To get some Dublin Core records from the collection of Ghent University Library and convert it to JSON (default) run the following catmandu command:

```
"https://lib.ugent.be/oai"
| open-oaipmh(metadataPrefix="oai_dc", setSpec="flandrica")
| decode-xml
| handle-generic-xml
| encode-json(prettyPrinting="true")
| print
;

```

If you just want to use the specific metadata records and not the oai-pmh specific metadata wrappers then specify the xml handler like this: `| handle-generic-xml(recordtagname="dc")`

You can also harvest MARC data and store it in a file:

$ catmandu convert OAI --url https://lib.ugent.be/oai --metadataPrefix marcxml --set flandrica --handler marcxml to MARC --type USMARC > ugent.mrc

Instead of harvesting the whole metadata you can get the record identifiers (--listIdentifiers) only:

$ catmandu convert OAI --url https://lib.ugent.be/oai --metadataPrefix marcxml --set flandrica --listIdentifiers 1 to YAML

You can also transform incoming data and immediately store/index it with MongoDB or Elasticsearch. For the transformation you need to create a fix (see Day 6):

$ nano simple.fix

Add the following fixes to the file:

marc_map(245,title)
marc_map(100,creator.$append)
marc_map(260c,date)
remove_field(record)

Now you can run an ETL process (extract, transform, load) with one command:

$ catmandu import OAI --url https://lib.ugent.be/oai --metadataPrefix marcxml --set flandrica --handler marcxml --fix simple.fix to Elasticsearch --index_name oai --bag ugent
$ catmandu import OAI ---url https://lib.ugent.be/oai --metadataPrefix marcxml --set flandrica --handler marcxml --fix simple.fix to MongoDB --database_name oai --bag ugent

The Catmandu OAI client provides special handler (--handler) for Dublin Core (oai_dc) and MARC (marcxml). For other metadata formats use the default handler (raw) or implement your own. Read our documentation for further details.