Lesson 8: Harvest data with OAI-PMH

The Open Archives Initiative Protocol for Metadata Harvesting (OAI-PMH) is a protocol to harvest metadata records from OAI compliant repositories. It was developed by the Open Archives Initiative as a low-barrier mechanism for repository interoperability. The Open Archives Initiative maintains a registry of OAI data providers.

Metafacture provides an opener flux module for harvesting metadata from OAI-PMH: `open-oaipmh`

Lets have a look at the documentation of open-oaipmh:

![open-oaipmh Documentation](./images/OAI-PMH-Docu.png)

There you see the specific options that can be used to configure your OAI PMH Harvesting.

Every OAI server must provide metadata records in Dublin Core, other (bibliographic) formats like MARC may be supported additionally. Available metadata formats can be detected with the OAI verb `ListMetadataFormats`:  https://lib.ugent.be/oai?verb=ListMetadataFormats

This OAI-PMH API provides MODS and Dublin Core. For specifying the metadataformat you use the `metadataprefix:` Option. 

The OAI server may support selective harvesting, so OAI clients can get only subsets of records from a repository. 
The client requests could be limited via datestamps (`datefrom`, `dateuntil`) or set membership (`setSpec`).

To get some Dublin Core records from the collection of Ghent University Library and convert it to JSON (default) run the following Metafacture worklow via Playground or CLI:

```
"https://lib.ugent.be/oai"
| open-oaipmh(metadataPrefix="oai_dc", setSpec="flandrica")
| decode-xml
| handle-generic-xml
| encode-json(prettyPrinting="true")
| print
;
```

But if you just want to use the specific metadata records and not the oai-pmh specific metadata wrappers then specify the xml handler like this: `| handle-generic-xml(recordtagname="dc")`

You can also harvest MARC data and store it in a file:

```JAVA
"https://lib.ugent.be/oai"
| open-oaipmh(metadataPrefix="marcxml", setSpec="flandrica")
| decode-xml
| handle-marcxml
| encode-json(prettyPrinting="true")
| print
;
```

> TODO: Revisit this example when https://github.com/metafacture/metafacture-core/issues/454 is fixed.

You can also transform incoming data and immediately store/index it with MongoDB or Elasticsearch. For the transformation you need to create a fix (see Lesson 3) in the playground or in a text editor:

Add the following fixes to the file:

```PEARL
copy_field("001","_id")
copy_field("245??.a","title")
set_array("creator[]")
copy_field("100??.a","creator[].$append")
copy_field("260??.c","date")
retain("_id","title","creator[]","date")
```

Now you can run an ETL process (extract, transform, load) with this worklflow:

"https://lib.ugent.be/oai"
| open-oaipmh(metadataPrefix="marcxml", setSpec="flandrica")
| decode-xml
| handle-marcxml
| fix(transformationFile)
| encode-json(prettyPrinting="true")
| json-to-elasticsearch-bulk(idkey="_id", type="resource", index="resources-alma-fix-staging")
| print
;


Next lesson: 
[09 Working with CSV and TSV](./09_Working_with_CSV.md)
