---
title: "Wikidata"
author: 
    - Till Grallert
date: 2022-12-09
licence: https://creativecommons.org/licenses/by/4.0/
bibliography: ../assets/bibliography/FuReSH.csl.json
csl: /BachUni/BachBibliothek/CSL/chicago-author-date_slides.csl
suppress-bibliography: true
URI:
status: draft
tags:
    - infrastructure
	- modeling
---


Wir verwenden Wikidata als offenen Datenspeicher und Authority File für die von uns kuratierten digitalen Werkzeuge im Scholarly Makerspace. Primäres Ziel ist die Vermeidung der sogenannten "DiRT-Trap", also der geschlossene und projektbezogene Aufbau einer Tool Registry. Mit Wikidata sollen langfristige Maintainance und Nachnutzbarkeit sowie einfache Übertragbarkeit/ Erweiterbarkeit in andere Scholarly Makerspaces oder andere Kontexte sichergestellt werden.

# Ideen, to do

- [ ] Link checker: aller URLs in den von unserem Projekt gesammelten "Werkzeugen" sollten periodisch auf Link rot gecheckt werden.

# Wikidata:Wikiproject [DH Tool Registry](https://www.wikidata.org/wiki/Wikidata:WikiProject_DH_Tool_Registry)

Das Wikidata-Projekt "DH Tool Registry" bietet eine zentrale Anlaufstelle für Fragen zur Modellierung von Werkzeugen in den Digital Humanities. Außerdem können hier Sammlungen von Werkzeugen erstellt werden, die bestimmten Kategorien zugeordnet sind (z.B. TaDiRAH-Taxonomie).

Es besteht die Möglichkeit bei einzelnen Items die Property `maintained by WikiProject` dann auf dieses WikiProject zeigen zu lassen

## Infos zum Projekt

* Name
  	- Wikidata:Wikiproject DH Tool Registry
* Link
  	- <https://www.wikidata.org/wiki/Wikidata:WikiProject_DH_Tool_Registry>
* Thematische Einordnung (vorläufig)
  		- University WikiProjects
  * Science WikiProjects
* Bearbeitung
  	- Um das Projekt zu bearbeiten, sollte sich ein Account bei Wikidata erstellt werden, da Wikimedia sonst die IP-Adresse des Bearbeiters/der Bearbeiterin veröffentlicht (Das Wiki\*versum kennt kein "anonym")
        - Wir haben einen [FuReSH2](https://www.wikidata.org/wiki/User:FuReSH2) Account angelegt
  		- Alle aktiven Bearbeiter:innen sollten als _Participants_ um Projekt gelistet sein.

# Wikidata als data store

- Wir hatten die Idee Einträge in Wikidata mit der Property "[instance of]()" "[research tool]()" zu klassifizieren
    + Um Arbeit zu sparen wäre es möglich, die Klassifizierung von Programmbibliotheken als "research tool" von der Klassifizierung der Programmiersprache abzuleiten.
    + Müssen wir wirklich explizit alle Programmiersprachen, ihre IDEs, und Bibliotheken explizit markieren? 
- Es besteht die Möglichkeit über die [`has use` (P366)](https://www.wikidata.org/wiki/Property:P366) property auf TaDiRAH zu modellieren.
- Es besteht das Problem, dass einzelne Wikidata Items für die Bearbeitung gesperrt sind. Hier können wir Informationen nicht unmittelbar hinzufügen. 
    + Dies ist z.B. bei [JSON](https://www.wikidata.org/wiki/Q2063) und [Python]() der Fall 

# Wikidata und Klassifizierungen

## Wikidata intern

Wir können unsere basale Klassifzierung in Werkzeug, Methode mit der Property [`instance of` (P31)](https://www.wikidata.org/wiki/Property:P31) vornehmen:

* Werkzeug: [`research tool`](https://www.wikidata.org/wiki/Q110994345), das eine subclass von [`research method`](https://www.wikidata.org/wiki/Q1438073) ist
* Methode: [`research method`](https://www.wikidata.org/wiki/Q1438073)

## TaDiRAH / extern

Zu TaDiRAH gibt es eine [extra Datei](TaDiRAH.md).

Es besteht die Möglichkeit bei einem Item die Property [`TaDiRAH ID` (P9309)](https://www.wikidata.org/wiki/Property:P9309) festzulegen. Allerdings ist uns die Bedeutung dieser Property nicht ganz klar: "identifier for a concept in the Taxonomy of Digital Research Activities in the Humanities ([[TaDiRAH]])". Es gibt momentan nur 8 items, die mit dieser property versehen sind und alle sind 1:1 Abbildungen der TaDiRAH Ontologie und keine Klassifizierung mit Hilfe von TaDiRAH.

SOPHIE: Ich würde Wikidata tatsächlich nur als Backend Speicher für die inhaltlichen Daten nutzen. Alle Metadaten, die wir benötigen und zu denen die TaDiRAH Ontologie gehört, würde ich bei uns behalten. Mein Vorschlag ist, Metadaten und Daten funktional zu trennen.

# Wikidata und externe Beschreibungen

Es gibt die Möglichkeit aus Wikidata auf externe Beschreibungen mit der Property [`decribed at URL` (P973)](https://www.wikidata.org/wiki/Property:P973) zu verlinken. Das ließe sich die Verknüpfung zu [[TAPoR]] mit Open Refine relative schnell automatisieren. 

# APIs
## SPARQL queries

Wikidata betreibt einen [SPARQL query service](https://query.wikidata.org), der auch einen visuellen query builder bereitstellt.

### all TaDiRAH items

```sparql
SELECT DISTINCT ?method ?methodLabel ?tadirahID ?methodDesc WHERE {
  ?method wdt:P9309 ?tadirahID.             # select all items that have a TaDiRAH ID
  SERVICE wikibase:label { 
    bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". 
    ?method rdfs:label ?methodLabel;        # get the labels. this line is not strictly necessary
            schema:description ?methodDesc. # get the description
    }
}
ORDER BY ?tadirahID
LIMIT 200
```


### all tools that have been classified with TaDiRAH

<https://w.wiki/968g>

1. select all items that have a TaDiRAH ID and are therefore assumed to be methods
2. select all items which are linked to these methods through `has use`
3. retrieve the logos and images for those tools that have them

```sparql
#defaultView:Graph
SELECT DISTINCT ?tool ?toolLabel (COALESCE(?logo, ?pic) AS ?image) ?method ?methodLabel ?tadirahID 
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  ?tool wdt:P366 ?method;
    # limit tools to software in the broadest sense
    wdt:P31/wdt:P279* wd:Q7397.
  # retrieve the logos and images for those tools that have them
  OPTIONAL { ?tool wdt:P154 ?logo. }
  OPTIONAL { ?tool wdt:P18 ?pic. }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?toolLabel
LIMIT 5000
```

alternatively one can query for **file formats**, which we might want to consider in the context of tool usage in DH

- Q235557: file format
- Q24451526: data serialization format

```sparql
#defaultView:Graph
SELECT DISTINCT ?tool ?toolLabel (COALESCE(?logo, ?pic) AS ?image) ?method ?methodLabel ?tadirahID 
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  { ?tool wdt:P366 ?method;
        wdt:P31/wdt:P279* wd:Q235557. } # limit to file formates
  UNION
  { ?tool wdt:P366 ?method;
        wdt:P31/wdt:P279* wd:Q24451526. } # or limit to data serialization
  # retrieve the logos and images for those tools that have them
  OPTIONAL { ?tool wdt:P154 ?logo. }
  OPTIONAL { ?tool wdt:P18 ?pic. }
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?toolLabel
LIMIT 1000
```

### get all file formats

Query to gather all the file formats that can be read or written by the tools in our registry

```sparql
SELECT DISTINCT ?format ?formatLabel ?formatShortName ?formatName
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  ?tool wdt:P366 ?method;
    # limit tools to software in the broadest sense
    wdt:P31/wdt:P279* wd:Q7397.
  # get the formats these tools interact with
  { ?tool wdt:P1072 ?readFormat .} 
  UNION
  { ?tool wdt:P1073 ?writeFormat .}
  BIND(
    COALESCE(?readFormat, ?writeFormat) AS ?format)
  # get alternative labels  
  OPTIONAL { ?format skos:altLabel ?altLabel. }
  OPTIONAL { ?format wdt:P2561 ?name. }
  OPTIONAL { ?format wdt:P1813 ?formatShortName. }
  BIND(COALESCE(?altLabel, ?name) AS ?formatName)
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?methodLabel
LIMIT 5000
```

shorter query to just get relevant QIDs

```sparql
SELECT DISTINCT ?tool ?format
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  ?tool wdt:P366 ?method;
    # limit tools to software in the broadest sense
    wdt:P31/wdt:P279* wd:Q7397.
  # get the formats these tools interact with
  { ?tool wdt:P1072 ?readFormat .} 
  UNION
  { ?tool wdt:P1073 ?writeFormat .}
  BIND(
    COALESCE(?readFormat, ?writeFormat) AS ?format)
  # get alternative labels  
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?methodLabel
LIMIT 5000
```

### get also all papers using these tools

```sparql
SELECT DISTINCT *
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  ?tool wdt:P366 ?method;
    # limit tools to software in the broadest sense
    wdt:P31/wdt:P279* wd:Q7397.
  # get all papers
  ?paper wdt:P4510 ?tool;
    wdt:P31/wdt:P279* wd:Q13442814.
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?toolLabel
LIMIT 1
```

### alternative labels

This query can be combined with others to compile a list of tools with all their known labels

```sparql
SELECT *
WHERE {
  # get all labels for an example object
  wd:Q165658 skos:altLabel ?altLabel.
  # filter for language
  FILTER (lang(?altLabel) = "en")
}
```

```sparql
SELECT DISTINCT ?tool ?toolLabel ?name  ?shortName ?method ?methodLabel ?tadirahID 
WHERE {
  # select all items that have a TaDiRAH ID and are therefore assumed to be methods
  ?method wdt:P9309 ?tadirahID.
  # select all items which are linked to these methods through `has use`
  ?tool wdt:P366 ?method;
    # limit tools to software in the broadest sense
    wdt:P31/wdt:P279* wd:Q7397.
  # get all alternative labels and names
  OPTIONAL { ?tool skos:altLabel ?altLabel. }
  OPTIONAL { ?tool wdt:P2561 ?name. }
  OPTIONAL { ?tool wdt:P1813 ?shortName. }
  BIND(COALESCE(?altLabel, ?name) AS ?name)
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
ORDER BY ?toolLabel
LIMIT 5000
```

The same but with defining methods and tools as variables

```sparql
SELECT DISTINCT 
    ?tool ?toolLabel ?name  ?shortName ?method ?methodLabel ?tadirahID
# get all methods
WITH {
    SELECT ?method ?tadirahID
    WHERE {
        ?method wdt:P9309 ?tadirahID.
    } 
} as %methods
# get all tools that implement a method
WITH {
    SELECT ?tool ?toolLabel ?name  ?shortName
    WHERE {
        INCLUDE  %methods
        ?tool wdt:P366 ?method;
        # limit tools to software in the broadest sense
        wdt:P31/wdt:P279* wd:Q7397.
    }
} as %tools
# get all papers 
WITH { 
    SELECT ?usedBy 
    WHERE {
        INCLUDE %tools
        ?tool wdt:P1535 ?usedBy.
    }
} as %papers
WHERE {
  INCLUDE %tools 
  INCLUDE %methods
  INCLUDE %papers
  SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en,da,de,es,fr,jp,no,ru,sv,zh". }
}
ORDER BY ?methodLabel
ORDER BY ?toolLabel
LIMIT 10
```

The following does the same but is **much slower**

```sparql
SELECT DISTINCT ?tool ?toolLabel ?altLabel ?method ?methodLabel ?tadirahID 
WHERE {
    {
        SELECT ?tool ?method ?tadirahID WHERE {
            # select all items that have a TaDiRAH ID and are therefore assumed to be methods
            ?method wdt:P9309 ?tadirahID.
            # select all items which are linked to these methods through `has use`
            ?tool wdt:P366 ?method;
                # limit tools to software in the broadest sense
                wdt:P31/wdt:P279* wd:Q7397.
        }
        ORDER BY DESC(?tool)
        LIMIT 10
    }
    # get all alternative labels
    OPTIONAL { ?tool skos:altLabel ?altLabel. }
    SERVICE wikibase:label { bd:serviceParam wikibase:language "[AUTO_LANGUAGE],en". }
}
```

## RESTful API

Wikidata stellt auch eine RESTful API zur Verfügung. Basale Dokumentation gibt es [hier](https://www.wikidata.org/wiki/Wikidata:REST_API) außerdem gibt es eine [OpenAPI Swagger documentation](https://doc.wikimedia.org/Wikibase/master/js/rest-api/).

### Volle Items

```bash
curl -X 'GET' \
  'https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/Q110961986' \
  -H 'accept: application/json'
```

Request URL: `https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/Q110961986`

### Einzelne Statements

Request URL: `https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/Q110961986/statements?property=P277`