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
        * [ ] add column with KWIC to the intermediate data output 
- data
    + [ ] add DHd abstracts from the GitHub repositories
    + [ ] add descriptions from DFG [GEPRIS - Geförderte Projekte der Deutschen Forschungsgemeinschaft](https://gepris.dfg.de/gepris/OCTOPUS) database on funded projects
        * Unfortunately, DFG does not provide an API or machine-actionable data for reuse
        * Scraping:
            - the URLs are easy to scrape as they include a simple nummerical ID: `https://gepris.dfg.de/gepris/projekt/5358364`
                + for the project results add `/ergebnisse` to this URL
            - one can iterate over these IDs, scrape every result and write it into a structured format
            - **PROBLEM**: IDs are not strictly sequential and have at least up to 9 digits, which would mean a total of 1 billion potential IDs to find the 135273 actual projects listed in GEPRIS. With a 1 second delay between calls, this will take 9259 days or more than 25 years
                + idea: iterate over the 2706 katalog pages to find the 50 projekt IDs per page
                    * URLs
                        - <https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&index=0&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false>
                        - <https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&index=50&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false>
                    * iterate 318 pages for humanities (https://gepris.dfg.de/gepris/OCTOPUS?task=doKatalog&context=projekt&oldfachgebiet=11&fachgebiet=11&fachkollegium=%23&nurProjekteMitAB=false&bundesland=DEU%23&pemu=%23&zk_transferprojekt=false&teilprojekte=false&teilprojekte=true&bewilligungsStatus=&beginOfFunding=&gefoerdertIn=&oldGgsHunderter=0&ggsHunderter=0&einrichtungsart=-1&findButton=Finden)
        - [x] scraper function

## done

- case matching
    + Currently we use lower-case string matching, which will produce false positives for some tools, whose name is a commonly used word and only distinguished by case, such as "MAX", "eLaborate"
    + The opposite will also cause false negatives as "Topic modelling" won't match "topic modelling"
    + Solution
        * add second column to tools.csv with variant spelling
- TEI processing
    + I exported all texts from the `dh-conferences` data to individual files. The result are three types of files (all with `.xml` file ending)
        1. plain text files: 
            - all 5-digit file names
            - IDs: 3xxx, 4xxx, 7837, 7840
            - to do: rename to `.txt` and move
        2. TEI XML fragments
            - to do: make them into full TEI XML files
                + regex: 
                    - `^\A(<text.+)$` to find all files that begin with `<text`
                    - `^(.*</text>)$\n*\z` to find all files ending with `</text>`
            - problems
                + 6366, 6483: a lot of illformed endnote XML inserts
        3. full TEI XML files
            - to do: run some XSLT to convert to `.txt`