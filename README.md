---
title: "Readme: User Stories"
subtitle: ""
author: 
    Till Grallert
    Sophie Eckenstaler
date: 2022-03-23 
lang: de
---

Dieser Ordner enthält die Daten zu den User Stories. 

Die Daten liegen in folgenden Unterordnern:

- `data/`
    + `dh-conferences/`: 
        * `12987959/`: data on mainly English DH conferences from Weingart, Scott B., Eichmann-Kalwara, Nickoal, and Lincoln, Matthew. “The Index of Digital Humanities Conferences Data.” Carnegie Mellon University, September 22, 2020. <https://doi.org/10.1184/R1/12987959.v4>.
        * `DHd/`: data on DHd conferences from the [DHd GitHub](https://github.com/DHd-Verband) repositories
            - `software-names-counts-total.csv`: Henny-Krahmer, Ulrike, and Daniel Jettka. *Softwarezitation in Den Digital Humanities*. Zenodo, 2021. <https://doi.org/10.5281/zenodo.5106391>.
    - `txt/`: Plaintextdateien. Unterordner für Sprachen
        - `de/`: deutsche Texte
        - `en/`: englische Texte
    - `csv/`


Es gibt eine simple Dateinamenkonvention für Plaintextdatein mit einzelnen Userstories: `user-story_{lang}_\d.md` Dieser Name ist gleichzeitig die ID der Userstory in anderen Kontexten.


# to do

- Currently we use lower-case string matching, which will produce false positives for some tools, whose name is a commonly used word and only distinguished by case, such as "MAX", "eLaborate"
- add DHd abstracts from the GitHub repositories
- run R scripts for frequencies of our controlled vocabulary of tools and concepts on the DHd data