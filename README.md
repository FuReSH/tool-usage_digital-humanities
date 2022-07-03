---
title: "Readme: User Stories"
subtitle: ""
author: 
    Till Grallert
    Sophie Eckenstaler
date: 2022-03-23 
lang: de
---

Dieser Ordner enthält Daten und Code zu User Stories und weitere Corpora, die wir für die Kuratierung der Werkzeugliste auswerten. 

Die Daten liegen in folgenden Unterordnern:

- `code/`
- `data/`
    + `dh-conferences/`: 
        * `12987959/`: data on mainly English DH conferences from Weingart, Scott B., Eichmann-Kalwara, Nickoal, and Lincoln, Matthew. “The Index of Digital Humanities Conferences Data.” Carnegie Mellon University, September 22, 2020. <https://doi.org/10.1184/R1/12987959.v4>.
    * `DHd/`: data on DHd conferences from the [DHd GitHub](https://github.com/DHd-Verband) repositories
        - `software-names-counts-total.csv`: Henny-Krahmer, Ulrike, and Daniel Jettka. *Softwarezitation in Den Digital Humanities*. Zenodo, 2021. <https://doi.org/10.5281/zenodo.5106391>.
    - `dhq/`: TEI XML files from "[Digital Humanities Quarterly](http://digitalhumanities.org/)". A corpus of 429 articles published until 2019 is available as zipped folder at <http://digitalhumanities.org/dhq/data/dhq-xml.zip>.
    - `nfdi4history`: a CSV/TSV dump of their user stories
    - `txt/`: Plaintextdateien. Unterordner für Sprachen
        - `de/`: deutsche Texte
        - `en/`: englische Texte
    - `csv/`


Es gibt eine simple Dateinamenkonvention für Plaintextdatein mit einzelnen Userstories: `user-story_{lang}_\d.md` Dieser Name ist gleichzeitig die ID der Userstory in anderen Kontexten.


# to do

- results
    + `R` is strikingly prominent
        * add column with KWIC to the intermediate data output 
- add DHd abstracts from the GitHub repositories
- the (TEI) XML in the corpora might need some preprocessing to CSV with metadata, plain text

## done

- case matching
    + Currently we use lower-case string matching, which will produce false positives for some tools, whose name is a commonly used word and only distinguished by case, such as "MAX", "eLaborate"
    + The opposite will also cause false negatives as "Topic modelling" won't match "topic modelling"
    + Solution
        * add second column to tools.csv with variant spelling
- TEI processing
    + I exportet all texts from the `dh-conferences` data to individual files. The result are three types of files (all with `.xml` file ending)
        1. plain text files: 
            - all 5-digit file names
            - IDs: 3xxx, 4xxx
            - to do: rename to `.txt` and move
        2. TEI XML fragments
            - to do: make them into full TEI XML files
                + regex: 
                    - `^\A(<text.+)$` to find all files that begin with `<text`
                    - `^(.*</text>)$\n*\z` to find all files ending with `</text>`
        3. full TEI XML files
            - to do: run some XSLT to convert to `.txt`