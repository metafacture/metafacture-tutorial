# TODO: Day 17: Exporting RDF data with Catmandu

Yesterday we learned how to import RDF data with Catmandu. Exporting RDF can be as easy as this:

catmandu convert RDF --url http://d-nb.info/1001703464 to RDF

By default, the RDF exporter Catmandu::Exporter::RDF emits RDF/XML, an ugly and verbose serialization format of RDF. Let’s configure catmandu to use the also verbose but less ugly NTriples. This can either by done by appending --type ntriple on command line or by adding 17_librecatthe following to config file catmandu.yml:

exporter:
  RDF:
    package: RDF
      options:
        type: ntriples

The NTriples format illustrates the “true” nature of RDF data as a set of RDF triples or statements, each consisting of three parts (subject, predicate, object).

Catmandu can be used for converting between one RDF serialization format to another, but more specialized RDF tools, such as such rapper are more performant especially for large data sets. Catmandu can better help to process RDF data to JSON, YAML, CSV etc. and vice versa.

Let’s proceed with a more complex workflow and with what we’ve learned at day 13 about OAI-PMH and another popular repository: http://arxiv.org. There is a dedicated Catmandu module Catmandu::ArXiv for searching the repository, but ArXiv also supports OAI-PMH for bulk download. We could specify all options at command line, but putting the following into catmandu.yml will simplify each call:

importer:
  arxiv-cs:
    package: OAI
    options:
      url: http://export.arxiv.org/oai2
      metadataPrefix: oai_dc
      set: cs

Now we can harvest all computer science papers (set: cs) for a selected day (e.g. 2014-12-19):

$ catmandu convert arxiv --from 2014-12-19 --to 2014-12-19 to YAML

The repository may impose a delay of 20 seconds, so be patient. For more precise data, we better use the original data format from ArXiV:

$ catmandu convert arxiv --set cs --from 2014-12-19 --to 2014-12-19 --metadataPrefix arXiv to YAML > arxiv.yaml

The resulting format is based on XML. Have a look at the original data (requires module Catmandu::XML):

$ catmandu convert YAML to XML --field _metadata --pretty 1 < arxiv.yaml
$ catmandu convert YAML --fix 'xml_simple(_metadata)' to YAML < arxiv.yaml

Now we’ll transform this XML data to RDF. This is done with the following fix script, saved in file arxiv2rdf.fix:

xml_simple(_metadata)
retain_field(_metadata)
move_field(_metadata,m)

move_field(m.id,_id)
prepend(_id,”http://arxiv.org/abs/&#8221;)

move_field(m.title,dc_title)
remove_field(m)

The following command generates one RDF triple per record, consisting of an arXiv article identifier, the property http://purl.org/dc/elements/1.1/title and the article title:

$ catmandu convert YAML to RDF --fix arxiv2rdf.fix < arxiv.yaml

To better understand what’s going on, convert to YAML instead of RDF, so the internal aREF data structure is shown:

$ catmandu convert YAML to YAML --fix arxiv2rdf.fix < arxiv.yaml

_id: http://arxiv.org/abs/1201.1733
dc_title: On Conditional Decomposability
…

This record looks similar to the records imported from RDF at day 13. The special field _id refers to the subject in RDF triples: a handy feature for small RDF graphs that share the same subject in all RDF triples. Nevertheless, the same RDF graph could have been encoded like this:

---
http://arxiv.org/abs/1201.1733:
  dc_title: On Conditional Decomposability
...

To transform more parts of the original record to RDF, we only need to map field names to prefixed RDF property names. Here is a more complete version of arxiv2rdf.fix:


xml_simple(_metadata)
retain_field(_metadata)
move_field(_metadata,m)
   
move_field(m.id,_id)
prepend(_id,"http://arxiv.org/abs/")
   
move_field(m.title,dc_title)
move_field(m.abstract,bibo_abstract)
   
move_field(m.doi,bibo_doi)
copy_field(bibo_doi,owl_sameAs)
prepend(owl_sameAs,"http://dx.doi.org/")
           
move_field(m.license,cc_license)
         
move_field(m.authors.author,dc_creator)
unless exists(dc_creator.0)
  move_field(dc_creator,dc_creator.0)
end        
           
do list(path=>dc_creator)
  add_field(a,foaf_Person)
  copy_field(forenames,foaf_name.0)
  copy_field(keyname,foaf_name.$append)
  join_field(foaf_name,' ')
  move_field(forenames,foaf_givenName)
  move_field(keyname,foaf_familyName)
  move_field(suffix,schema_honoricSuffix)
  remove_field(affiliation)
end
   
remove_field(m)

The result is one big RDF graph for all records:

$ catmandu convert YAML to RDF --fix arxiv2rdf.fix < arxiv.yaml

Have a look at the internal aREF format by using the same fix with convert to YAML and try conversion to other RDF serialization forms. The most important part of transformation to RDF is to find matching RDF properties from existing ontologies. The example above uses properties from Dublin Core, Creative Commons, Friend of a Friend, Schema.org, and Bibliographic Ontology.