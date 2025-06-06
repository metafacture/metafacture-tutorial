---
layout: default
title: "Lesson 10: Working with XML"
nav_order: 10
parent: Tutorial
---

# Lesson 10: Working with XML

CSV is one type of file format that is used for data exchange. XML is a famous other one.

XML files are used as internal data serialization and exchange serialization.
Also a lot of metadata profils and data formats in the cultural heritage sector are serialized in XML:
e.g. LIDO, MODS, METS, PREMIS, MARCXML, PICAXML, DC, ONIX and so on.

XML is decoded a little bit differently than other data serializations since on the one hand
the XML serialization is to be decoded and then the inherent format is to be treated accordingly.

Lets start with this simple record

```xml
<?xml version="1.0" encoding="utf-8"?>
<record>
  <title>GRM</title>
  <author>Sibille Berg</author>
  <datePublished>2019</datePublished>
</record>
```


Lets open it with the following Flux:

```text
inputFile
| open-file
| as-records
| print
;
```

[See it here in the Playground.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E)

Next let's decode the file and encode it as YAML.

T decode it as XML the `decode-xml` command is used. But using only the decoder does not help. We additionally need a handler for XML.
Handlers are specific helpers that de-format XML in a certain way, based on the metadata standard that this XML is based on.

For now we need the `handle-generic-xml` function:

```text
inputFile
| open-file
| decode-xml
| handle-generic-xml
| encode-yaml
| print
;
```

[See it here in the Playground.](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E)


You see this as result:

```yaml
---
title:
  value: "GRM"
author:
  value: "Sibille Berg"
datePublished:
  value: "2019"
```

What is special about the handling is that the values of the different XML elements are not decoded straigt as the value of the element but as a subfield called `value`.
This is due to the fact that XML elementis can't have a value _and_ additional attributes and to catch both [MF introduces subfields for the value and potential attributes](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E).

See:

```XML
<title attribute="test">Test value</title>
```

with the Flux:

```text
inputFile
| open-file
| decode-xml
| handle-generic-xml
| encode-yaml
| print
;
```
results in:

```yaml
title:
  attribute: "test"
  value: "Test value"
```

[For our example above, to get rid of the value subfields in the yaml, we need to change the hirachy:](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22title.value%22%2C%22@title%22%29%0Amove_field%28%22@title%22%2C%22title%22%29%0Amove_field%28%22author.value%22%2C%22@author%22%29%0Amove_field%28%22@author%22%2C%22author%22%29%0Amove_field%28%22datePublished.value%22%2C%22@datePublished%22%29%0Amove_field%28%22@datePublished%22%2C%22datePublished%22%29&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E)


```text
inputFile
| open-file
| decode-xml
| handle-generic-xml
| fix(transformationFile)
| encode-yaml
| print
;
```

with Fix:

```perl
move_field("title.value","@title")
move_field("@title","title")
move_field("author.value","@author")
move_field("@author","author")
move_field("datePublished.value","@datePublished")
move_field("@datePublished","datePublished")
```

But when it's encoded into XML the value subfields are also kept. Like this:

```text
inputFile
| open-file
| decode-xml
| handle-generic-xml
| encode-xml
| print
;
```

results in:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records>

  <record>
    <title>
      <value>GRM</value>
    </title>
    <author>
      <value>Sibille Berg</value>
    </author>
    <datePublished>
      <value>2019</value>
    </datePublished>
  </record>

</records>
```

[Playground Link](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-xml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E)

Keep in mind that XML elements can have attributes and a value. The encoder `encode-xml` enables simple flat XML records, when specified to.

You have to add a specific option when encoding XML: `| encode-xml(valueTag="value")` . Then it results in:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<records>

  <record>
    <title>GRM</title>
    <author>Sibille Berg</author>
    <datePublished>2019</datePublished>
  </record>

</records>

```

If you want to create the other elements as attributes you have to tell MF which elements are attributes by adding an "attribute marker" with the option `attributemarker` in `handle-generic-xml`.
Here an `@` acts as the attribute marker:

```text
inputFile
| open-file
| decode-xml
| handle-generic-xml(attributeMarker="@")
| encode-xml(attributeMarker="@",valueTag="value")
| print
;
```

[Playground Link](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%28attributeMarker%3D%22@%22%29%0A%7C+encode-xml%28attributeMarker%3D%22@%22%2CvalueTag%3D%22value%22%29%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E)

When you encode it as YAML you see the magic behind it:

```text
inputFile
| open-file
| decode-xml
| handle-generic-xml(attributeMarker="@")
| encode-yaml
| print
;
```

[Playground Link](https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%28attributeMarker%3D%22@%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E)

Another important thing when working with XML data sets is to specify the record tag. The default record tag is "record". But other data sets have different tags to separate records:

```text
"http://www.lido-schema.org/documents/examples/LIDO-v1.1-Example_FMobj00154983-LaPrimavera.xml"
| open-http
| decode-xml
| handle-generic-xml(recordtagname="lido")
| encode-yaml
| print
;
```

[Playground Link](https://metafacture.org/playground/?flux=%22http%3A//www.lido-schema.org/documents/examples/LIDO-v1.1-Example_FMobj00154983-LaPrimavera.xml%22%0A%7C+open-http%0A%7C+decode-xml%0A%7C+handle-generic-xml%28recordtagname%3D%22lido%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B)


## Bonus: Working with namespaces

XML elements often come with namespaces. By default namespaces are not emitted, only the element names are provided.
When elements have the name but belong to different namespaces, or you want to emit the incoming namespaces you can use
the option `emitnamespace="true"` for the `handle-generic-xml` command.

Add this option to the previous example and see that there are elements belonging to lido as well as skos.

```text
"http://www.lido-schema.org/documents/examples/LIDO-v1.1-Example_FMobj00154983-LaPrimavera.xml"
| open-http
| decode-xml
| handle-generic-xml(recordtagname="lido", emitnamespace="true")
| encode-yaml
| print
;
```

See this in the Playground [here](https://metafacture.org/playground/?flux=%22http%3A//www.lido-schema.org/documents/examples/LIDO-v1.1-Example_FMobj00154983-LaPrimavera.xml%22%0A%7C+open-http%0A%7C+decode-xml%0A%7C+handle-generic-xml%28recordtagname%3D%22lido%22%2C+emitnamespace%3D%22true%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B).

When you want to add the namespace definition to the output Metafacture does not know that by itself. So you have to tell Metafacture
the new namespace when `encoding-xml` either by a file with the option `namespacefile` or in the Flux with the option `namespaces`, where the multiple namepaces are separated by an `\n`.

See here an example for adding namespaces in the flux:

```text
inputFile
| open-file
| as-lines
| decode-formeta
| fix(transformationFile)
| encode-xml(rootTag="collection",namespaces="__default=http://www.w3.org/TR/html4/\ndcterms=http://purl.org/dc/terms/\nschema=http://schema.org/")
| print
;
```

> TODO: Add excercises.

---------------

**Next lesson**: [11 Mapping Marc to Dublin Core](./11_MARC_to_Dublin_Core.html)
