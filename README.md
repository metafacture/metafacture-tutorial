
![Logo](https://metafacture.org/img/metafacture.png)

# metafacture-tutorial

This project is work-in-progress tutorial to Metafacture

It used to be a selective copy of the [Catmandu tutorial](https://librecatproject.wordpress.com/2014/12/01/day-1-getting-catmandu/) but adapted for [Metafacture](https://github.com/metafacture).
The Catmandu tutorial was created by [@phochste](https://github.com/phochste). It is great if you want to learn [Catmandu](https://github.com/LibreCat/Catmandu). So try it out.

Since [Metafacture Fix](https://github.com/metafacture/metafacture-fix) is introducing a catmandu-fix like transformation language to Metafacture the adaption of the Catmandu Tutorial for Metafacture purposes seem to me obvious.

It should help you to get accustomed with Metafacture Core and Metafacture Fix.
Have fun.

The content pages can be found [in `/docs/`](/docs/)

Lesson plan:

[01 Introducing metafacture](./docs/01_Introducing_Metafacture.md)

[02 Introduction into Metafacture Flux](./docs/02_Introduction_into_Metafacture-Flux.html)

[03 Introduction into Metafacture-Fix](./docs/03_Introduction_into_Metafacture-Fix.html)

[04 Fix Path](./docs/04_Fix-Path.html)

[05 More Fix Concepts](./docs/05-More-Fix-Concepts.html)

[06 Metafacture CLI](./docs/06_MetafactureCLI.html)

[07 Processing MARC](./docs/07_Processing_MARC.html)

[08 Harvest data with OAI-PMH](./docs/08_Harvest_data_with_OAI-PMH.html)

[09 Working with CSV and TSV](./docs/09_Working_with_CSV.html)

[10 Working with XML](./docs/10_Working_with_XML.html)

[11 Mapping Marc to Dublin Core](./docs/11_MARC_to_Dublin_Core.html)

## Testing

### Installation
If you are on debian derivates go install build-essentials:
```
apt install build-essential
```
Then you can use the Ruby Dependency Management to build all you need:
```
bundle install
```
Start jekyll like this:
```
bundle exec jekyll serve
```
If you experience troubles, make sure to not have jekyll installed via you
package manager. On debian derivates do:
```
apt purge jekyll
```

