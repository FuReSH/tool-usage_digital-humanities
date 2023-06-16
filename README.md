---
title: "Readme: User Stories"
subtitle: ""
author: 
    - Till Grallert
    - Sophie Eckenstaler
affiliation: Future e-Research Support in the Humanities, Humboldt-Universität zu Berlin
date: 2022-03-23 
lang: de
bibliography: https://furesh.github.io/slides/assets/bibliography/FuReSH.csl.json
reference-section-title: "Literatur"
suppress-bibliography: true
licence: https://creativecommons.org/licenses/by/4.0/
markdown: pandoc
---

Dieses Repository enthält Daten und Code zu Tools, User Stories und weitere Corpora, die wir für die Kuratierung der Werkzeugliste auswerten. Die User Story für dieses Repo lautet:

>Wir bauen einen *Scholarly Makerspace* auf und wollen eine **Liste von Werkzeugen** kuratieren, die auf der **Häufigkeit** ihrer **Benutzung in der Forschung** beruht.

Dieses Repository und die Operationalisierung unseres Ansatzes enstand im Frühjahr 2022 aus den Bedürfnissen des Scholarly Makerspaces an der UB der HU und unabhängig von anderen Forschungsgruppen, wie um Ulrike Henny-Krahmer [@HennyJettka2021SoftwarezitationPaper], Frank Fischer [@AlirezaEtAl2022MeasuringUseTools; @BarbotEtAl2019ToolsMentioned; @BarbotEtAl2019WhichDHTools; @FischerMoranville2020ToolsMentioned], und Manuel Burghardt [@Cebral2022InteractiveExploratoryAnalysis; @GutierrezDeLaTorreEtAl2022ManyFacesTheory; @ManuelEtAl2022ToolsEpistemologiesDH], von denen wir im Lauf des Sommers erfahren haben. Einige arbeiten mit ähnlichen Subcorpora, vor allem DH conference abstracts und DHQ.

# Ordnerstruktur

Die Daten liegen in folgenden Unterordnern:

- `code/`
- `data/`
    + `dh-conferences/`: 
        * `12987959/`: data on mainly English DH conferences from [LincolnEtAl2021IndexDigitalHumanities; @Weingart2020IndexDHData]
        * `DH2023`: abstracts from the DH2022 conference in Tokyo available on [GitHub](https://github.com/747/tei-to-pdf-dh2022)
    * `DHd/`: data on DHd conferences from the [DHd GitHub](https://github.com/DHd-Verband) repositories
        - `software-names-counts-total.csv`: [@HennyJettka2021SoftwarezitationData]
    - `dhq/`: TEI XML files from "[Digital Humanities Quarterly](http://digitalhumanities.org/)". A corpus of 429 articles published until 2019 is available as zipped folder at <http://digitalhumanities.org/dhq/data/dhq-xml.zip>.
    - `nfdi4history/`: a CSV/TSV dump of their user stories
    - `ssh-open-marketplace/`
    - `tadirah/`
    - `tapor/`
    - `txt/`: Plaintextdateien unserer eigenen User Stories. Unterordner für Sprachen
        - `de/`: deutsche Texte
        - `en/`: englische Texte
    - `csv/`


Es gibt eine simple Dateinamenkonvention für Plaintextdatein mit einzelnen Userstories: `user-story_{lang}_\d.md` Dieser Name ist gleichzeitig die ID der Userstory in anderen Kontexten.

## tool lists

Wir haben Listen an Werkzeugen (mehrheitlich Software und Tutorials) von folgenden Quellen heruntergeladen

- TaPOR: `data/tapor.json`
- SSH Open Marketplace
- [U of Toronto](https://find.digital.utsc.utoronto.ca/search-results): `data/utoronto-tools.csv`



# to do

- results
    + `R` is strikingly prominent
        * [ ] add column with KWIC to the intermediate data output 
- data
    + [x] add data from the undocumented (?) API of TAPoR at <https://tapor.ca/api/tools/by_analysis>, which returns JSON. We found the API through an analysis of [ToolXtractor](https://github.com/lehkost/ToolXtractor) by Barbot et al.
        * [@BarbotEtAl2019ToolsMentioned]
        * [@BarbotEtAl2019WhichDHTools]
    + [ ] add DHd abstracts from the GitHub repositories
    + [ ] add metadata for all conference presentations and all journal articles in our corpus to Wikidata in order to link them to the mentioned tools
        * this will require significant work to translate bibliographic data to data models in Wikidata
    + [x] add all 
- analysis
    + [ ] use expanded TaPOR, SSH Open Marketplace tool list
    + [x] write output in form of edges table, which can then be used to link certain papers to certain tools on Wikidata
        * source: paper
        * target: tool
    - [ ] use TaDiRAH classification in SSH Open Marketplace to group tools into methodologic approaches
        + TaDiRAH has 3 levels and each tool should get a level attribute as well as a parent attribute
- R notebook
    + [ ] explain the origin of and the rationale behind the tool list
    

## done

- [x] case matching
    + Currently we use lower-case string matching, which will produce false positives for some tools, whose name is a commonly used word and only distinguished by case, such as "MAX", "eLaborate"
    + The opposite will also cause false negatives as "Topic modelling" won't match "topic modelling"
    + Solution
        * [x] add second column to tools.csv with variant spelling
- [x] TEI processing
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
            - [x] convert TEI XML to `.txt` using XSLT from [convert_tei-to-markdown](https://github.com/OpenArabicPE/convert_tei-to-markdown)
- [x] Add data from DFG's GEPRIS
    +  [x] add descriptions from DFG [GEPRIS - Geförderte Projekte der Deutschen Forschungsgemeinschaft](https://gepris.dfg.de/gepris/OCTOPUS) database on funded projects
    * Unfortunately, DFG does not provide an API or machine-actionable data for reuse
    * Scraping:
        - the URLs are easy to scrape as they include a simple nummerical ID: `https://gepris.dfg.de/gepris/projekt/5358364`
            + for the project results add `/ergebnisse` to this URL
        - one can iterate over these IDs, scrape every result and write it into a structured format
        - **PROBLEM**: IDs are not strictly sequential and have at least up to 9 digits, which would mean a total of 1 billion potential IDs to find the 135273 actual projects listed in GEPRIS. With a 1 second delay between calls, this will take 9259 days or more than 25 years
            + [x] idea: iterate over the 2706 katalog pages to find the 50 projekt IDs per page
                * URLs
                    - <https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&index=0&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false>
                    - <https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&index=50&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false>
                * [x] iterate 318 pages for humanities (https://gepris.dfg.de/gepris/OCTOPUS?task=doKatalog&context=projekt&oldfachgebiet=11&fachgebiet=11&fachkollegium=%23&nurProjekteMitAB=false&bundesland=DEU%23&pemu=%23&zk_transferprojekt=false&teilprojekte=false&teilprojekte=true&bewilligungsStatus=&beginOfFunding=&gefoerdertIn=&oldGgsHunderter=0&ggsHunderter=0&einrichtungsart=-1&findButton=Finden)
    - [x] scraper functions
- [x] download all DHQ articles
    + DHQ provides a zipped corpus of 431 articles as TEI/XML files, which includes articles published until 2019
    + to quickly scrape the remaining articles one can use this curl script: `curl -O 'http://digitalhumanities.org/dhq/vol/1/1/000[431-690].xml'`
        * not that one does not need to iterate the volume and issue numbers, something that should be declared on the DHQ website