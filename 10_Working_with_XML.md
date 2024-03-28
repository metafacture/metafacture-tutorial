# Lesson 10: Working with XML

While CSV are one type of file format that are used for data exchange. The other one which is most famous is XML.

XML files are used as internal data format and exchange format.
Also a lot of metadata profils and data formats in the cultural heritage sector are serialized in XML:
e.g. LIDO, MODS, METS, PREMIS, MARCXML, PICAXML, DC, ONIX and so on.

XML is decoded a little bit differently than other data formats since on the one hand
the decoder follows straight after the opening of a file, a website or an OAI-PMH.

Lets start with this simple record

```XML
<?xml version="1.0" encoding="utf-8"?>
<record>
  <title>GRM</title>
  <author>Sibille Berg</author>
  <datePublished>2019</datePublished>
</record>
```


Lets open it:

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+as-records%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E


Next lets decode the file and encode it as Yaml.

But to decode it as xml we have to use the `decode-xml` command. But using only the decoder does not help. We additionally need a handler for xml.
Handlers a specific helpers that decode xml in a certain way, based on the metadata standard that this xml is based on.

For now we need the `handle-generic-xml` function.

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E


You see this as result:

```YAML
---
title:
  value: "GRM"
author:
  value: "Sibille Berg"
datePublished:
  value: "2019"
```

What is special about the handling, it that the values of the different xml-elements are not decoded straigt as the value of the element but as a subfield called value.
This is due to the fact that xml element cant have a value and additional attributes and to catch both MF introduces subfields for the value and potential attributes:

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E

See:

```XML
<title attribute="test">Test value</title>
```

=>

```YAML
title:
  attribute: "test"
  value: "Test value"
```

For our example above to get rid of the value subfields in the yaml we need to change the hirachy:

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+fix%28transformationFile%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&transformation=move_field%28%22title.value%22%2C%22@title%22%29%0Amove_field%28%22@title%22%2C%22title%22%29%0Amove_field%28%22author.value%22%2C%22@author%22%29%0Amove_field%28%22@author%22%2C%22author%22%29%0Amove_field%28%22datePublished.value%22%2C%22@datePublished%22%29%0Amove_field%28%22@datePublished%22%2C%22datePublished%22%29&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E


But when you encode it to XML

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%0A%7C+encode-xml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle%3EGRM%3C/title%3E%0A++%3Cauthor%3ESibille+Berg%3C/author%3E%0A++%3CdatePublished%3E2019%3C/datePublished%3E%0A%3C/record%3E

The value subfields are also kept. Keep in mind that xml elements can have attributes and a value. But also the encoder enable simple flat xml records too.

You have to add a specific option when encoding xml: `(valueTag="value")`

If you want to create the other elements as attributes. You have to tell MF which elements are attributes by adding a attributeMarker with the option `attributemarker` in handle generic xml.
Here I use `@` as attribute marker:


https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%28attributeMarker%3D%22@%22%29%0A%7C+encode-xml%28attributeMarker%3D%22@%22%2CvalueTag%3D%22value%22%29%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E

When you encode it as yaml you see the magic behind it:

https://metafacture.org/playground/?flux=inputFile%0A%7C+open-file%0A%7C+decode-xml%0A%7C+handle-generic-xml%28attributeMarker%3D%22@%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B&data=%3C%3Fxml+version%3D%221.0%22+encoding%3D%22utf-8%22%3F%3E%0A%3Crecord%3E%0A++%3Ctitle+attribute%3D%22test%22%3ETest+value%3C/title%3E%0A%3C/record%3E


Another important thing, when working with xml data sets is to specify the record tag. Default is the tag record. But other data sets have other tags that devide between records:

https://metafacture.org/playground/?flux=%22http%3A//www.lido-schema.org/documents/examples/LIDO-v1.1-Example_FMobj00154983-LaPrimavera.xml%22%0A%7C+open-http%0A%7C+decode-xml%0A%7C+handle-generic-xml%28recordtagname%3D%22lido%22%29%0A%7C+encode-yaml%0A%7C+print%0A%3B

> TODO: Add namespace handling.
> Add excercises.

Next lesson: [11 Mapping Marc to Dublin Core](./11_MARC_to_Dublin_Core.md)
