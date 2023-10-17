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