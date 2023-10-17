---
title: "TaDiRAH"
subtitle: "notes on data and infrastructure"
author:
    - Till Grallert
affiliation: Future e-Research Support in the Humanities, Humboldt-Universität zu Berlin
date: 2023-01-18 
status: draft
lang: de
bibliography: https://furesh.github.io/slides/assets/bibliography/FuReSH.csl.json
reference-section-title: "Literatur"
suppress-bibliography: false
licence: https://creativecommons.org/licenses/by/4.0/
markdown: pandoc
tags:
    - FuReSH
---

# TaDiRAH: THE TAXONOMY OF DIGITAL RESEARCH ACTIVITIES IN THE HUMANITIES

* TaDiRAH ist eine Taxonomie zur Klassifizierung von Forschungsaktivitäten und aktuell in Version 2.x veröffentlicht
* webseite: <https://vocabs.dariah.eu/tadirah>
* Wir haben das komplette Vokabular über die API/Endpoint als Turtle heruntergeladen und dann zu JSON-LD convertiert. Beide Dateien finden sich unter <https://github.com/FuReSH/tool-usage_digital-humanities/tree/main/data>.

## v2

* Version 2.x.x ist leider online sehr schlecht dokumentiert und aufgrund des Rankings von Suchmaschinen, wird die auf Github gehostete Version 0.5.x wesentlich besser gefunden
* Die aktuell beste Dokumentation zu v2 ist \[@boreketal2021informationorganizationaccess]. Dort wird auch die Beziehung zu Wikidata beschrieben.
* v2 ist ein richtiges SKOS Vokabular und wird über einen Tripple Store von DARIAH gehostet
* Es werden "nur" noch **methods** und **techniques** modelliert, wobei diese Terminologie in der Taxonomie nicht mehr benutzt wird und sich diese nur durch ihren Rang in der Hierarchie der Konzepte identifizieren lassen.

## v1

* wahrscheinlich gab es nie eine richtige Version 1

## v0.5

* Diese Version ist auf GitHub zu finden
* > In its current version, TaDiRAH consists of several sets of terms: two closed sets of so-called Research Activities, one with eight top-level categories that represent broad research **goals**, and below that a second set of more fine-grained research **methods**. In addition, there are two open lists, one representing specific research **techniques** and one representing research **objects** to which methods and goals can be applied.  \[@boreketal2016tadirahcasestudy, §22]
* > For example, a tool such as SIGIL, which is used for creating eBooks, could be tagged with the terms “Creation” (goal), “Writing” (method), “Encoding” (technique) and “Text” (object). A tool such as QGIS could be tagged with the terms “Analysis” (goal), “Spatial Analysis” (method), “Georeferencing” (technique) and “Maps” (object). \[@boreketal2016tadirahcasestudy, §32]

## v0.5

# TaDiRAH und Wikidata

Es besteht die Möglichkeit bei einem Item die Property [`TaDiRAH ID` (P9309)](https://www.wikidata.org/wiki/Property:P9309) für 1:1 Abbildungen der TaDiRAH Ontologie hinzuzufügen. Mit diesem Mapping lassen sich dann Wikidata items direkt klassifizieren. P9309 erlaubt nicht die direkte Klassifikation eines Wikidata Items mit TaDiRAH. 

## Stand der Dinge und Vorgehen

[SPARQL für die Abfrage von Items, die eine TaDiRAH ID haben](https://query.wikidata.org/embed.html#SELECT%20DISTINCT%20?item%20?itemLabel%20WHERE%20%7B%0A%20%20SERVICE%20wikibase:label%20%7B%20bd:serviceParam%20wikibase:language%20%22%5BAUTO_LANGUAGE%5D%22.%20%7D%0A%20%20%7B%0A%20%20%20%20SELECT%20DISTINCT%20?item%20WHERE%20%7B%0A%20%20%20%20%20%20?item%20p:P9309%20?statement0.%0A%20%20%20%20%20%20?statement0%20(ps:P9309)%20_:anyValueP9309.%0A%20%20%20%20%7D%0A%20%20%7D%0A%7D)

TaDiRAH hat indirekt viele ihrer Kategorien mit Wikidata verbunden, da sie Wikidata als eine der Quellen für die Beschreibungen genutzt haben und dort auch angeben, wo diese Texte herkamen:

```json
"@id": "https://vocabs.dariah.eu/tadirah/dataVisualization",
"http://www.w3.org/2004/02/skos/core#definition": [
  {
    "@value": "creation and study of the visual representation of data (Wikidata contributors, \"Q6504956,\" Wikidata, https://www.wikidata.org/w/index.php?title=Q6504956&oldid=1258700005 (accessed September 4, 2020).",
    "@language": "en"
  }
]

```

Insgesamt verweist der TaDiRAH datensatz von 168 Konzepten auf 111 Wikidata Items. Außerdem hat jemand mit TaDiRAH assoziertes einige Items angelegt, diese allerdings noch nicht einmal mit einem Label versehen. Diese 26 Items sind von Bots wieder aus der Wikidata gelöscht worden (z.B. [Q98848358](https://www.wikidata.org/wiki/Q98848358)).

Mit OpenRefine lassen sich die Wikidata Item IDs auslesen und dann die TaDiRAH ID in die [`TaDiRAH ID` (P9309)](https://www.wikidata.org/wiki/Property:P9309) der Items in [Wikidata schreiben](https://www.wikidata.org/wiki/Wikidata:Tools/OpenRefine/Editing/Tutorials/Basic_editing). Nachdem die 26 bereits gelöschten Items identifiziert wurden, konnten wir die restlichen 85 Items über OpenRefine mit der Wikidata verknüpfen (1 June 2023).

## To do

* [ ] Validiere die bestehenden Verknüpfungen
  * Es gibt Fehler, die von TaDiRAH stammen und ich weiß noch nicht, wie wir damit umgehen! Z.B. <https://www.wikidata.org/wiki/Q2868277>
* [ ] Verknüpfe die restlichen Konzepte mit der Wikidata oder erstelle neue Items

# Linked Open Data

## SPARQL

* SPARQL endpoint: <https://vocabs-sparql.acdh.oeaw.ac.at>

```sparql
PREFIX skos: <http://www.w3.org/2004/02/skos/core#> 
PREFIX dc: <http://purl.org/dc/elements/1.1/> 
SELECT ?clabel ?external_concept WHERE { 
  ?concept a skos:Concept; 
           skos:prefLabel ?clabel; 
           skos:narrowMatch ?external_concept. 
  FILTER (LANG(?clabel)="de") 
}
LIMIT 10

```

*Update 2023-10-05:*

Der SPARQL-Endpoint scheint nicht stabil zu laufen, da immer mal ein 403 Error (Forbidden) zurückgegeben wird:

```
curl -I https://vocabs-sparql.acdh.oeaw.ac.at
HTTP/1.1 403 Forbidden
Date: Thu, 05 Oct 2023 07:15:13 GMT
Server: Apache/2.4.6 (CentOS) OpenSSL/1.0.2k-fips
Last-Modified: Thu, 16 Oct 2014 13:20:58 GMT
ETag: "1321-5058a1e728280"
Accept-Ranges: bytes
Content-Length: 4897
Content-Type: text/html; charset=UTF-8
```

Oder man benötigt inzwischen einen Zugang. Auf der Website ist dazu nichts dokumentiert. Daher ist der SPARQL-Endpoint für uns derzeit unbrauchbar.

## TaDiRAH API

Es gibt eine API, die unter <https://vocabs-api.acdh.oeaw.ac.at> documentiert ist. 

### Gesamter Datensatz

Über die API lässt sich nicht die gesamte Taxonomie als ein einziger Datensatz in JSON-LD herunterladen, aber es ist in mehreren Schritten möglich.

#### 1. Top-level Konzepte

```bash
curl -X 'GET' \
  'https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/topConcepts?lang=en' \
  -H 'accept: application/ld+json'

```

Request URL: `https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/topConcepts?lang=en`

Response

```json
{
  "@context": {
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "uri": "@id",
    "type": "@type",
    "onki": "http://schema.onki.fi/onki#",
    "topconcepts": "skos:hasTopConcept",
    "notation": "skos:notation",
    "label": "skos:prefLabel",
    "@language": "en"
  },
  "uri": "https://vocabs.dariah.eu/tadirah/",
  "topconcepts": [
    {
      "uri": "https://vocabs.dariah.eu/tadirah/analyzing",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Analyzing",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/capturing",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Capturing",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/creating",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Creating",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/disseminating",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Disseminating",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/enriching",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Enriching",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/interpreting",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Interpreting",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/storing",
      "topConceptOf": "https://vocabs.dariah.eu/tadirah/",
      "label": "Storing",
      "hasChildren": true
    }
  ]
}

```

#### 2. Children

Folgenden Codesnippets benutzen jeweils ein Beispielkonzept ("<https://vocabs.dariah.eu/tadirah/capturing">)

```bash
curl -X 'GET' \
  'https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/children?uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing&lang=en' \
  -H 'accept: application/ld+json'

```

Request URL: `https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/children?uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing&lang=en`

Response

```json
{
  "@context": {
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "uri": "@id",
    "type": "@type",
    "prefLabel": "skos:prefLabel",
    "narrower": "skos:narrower",
    "notation": "skos:notation",
    "hasChildren": "onki:hasChildren",
    "@language": "en"
  },
  "uri": "https://vocabs.dariah.eu/tadirah/capturing",
  "narrower": [
    {
      "uri": "https://vocabs.dariah.eu/tadirah/gathering",
      "prefLabel": "Gathering",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/recording",
      "prefLabel": "Recording",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/discovering",
      "prefLabel": "Discovering",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/converting",
      "prefLabel": "Converting",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/dataRecognition",
      "prefLabel": "Data Recognition",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/extracting",
      "prefLabel": "Extracting",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/imaging",
      "prefLabel": "Imaging",
      "hasChildren": true
    },
    {
      "uri": "https://vocabs.dariah.eu/tadirah/transcribing",
      "prefLabel": "Transcribing",
      "hasChildren": true
    }
  ]
}

```

#### 3. Labels in verschiedenen Sprachen

```bash
curl -X 'GET' \
  'https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/label?uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing&lang=de' \
  -H 'accept: application/ld+json'

```

Request URL: `https://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/label?uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing&lang=de`

Response

```json
{
  "@context": {
    "skos": "http://www.w3.org/2004/02/skos/core#",
    "uri": "@id",
    "type": "@type",
    "prefLabel": "skos:prefLabel",
    "altLabel": "skos:altLabel",
    "hiddenLabel": "skos:hiddenLabel",
    "@language": "de"
  },
  "uri": "https://vocabs.dariah.eu/tadirah/capturing",
  "prefLabel": "Erfassen"
}

```

#### 4. Sämtlichen Daten zu einem Konzept

Diese werden nur als Turtle ausgegeben

```bash
curl -X 'GET' \
  'http://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/data?format=text%2Fturtle&uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing' \
  -H 'accept: text/turtle'

```

Request URL: `http://vocabs.acdh.oeaw.ac.at/rest/v1/tadirah/data?format=text%2Fturtle&uri=https%3A%2F%2Fvocabs.dariah.eu%2Ftadirah%2Fcapturing`

Response

```turtle
@prefix skos: <http://www.w3.org/2004/02/skos/core#> .
@prefix owl: <http://www.w3.org/2002/07/owl#> .
@prefix tadirah: <https://vocabs.dariah.eu/tadirah/> .
@prefix rdfs: <http://www.w3.org/2000/01/rdf-schema#> .

skos:Concept a owl:Class .
tadirah:gathering
  skos:prefLabel "Sammeln"@de, "Raccolta"@it, "Прикупљање"@sr, "Recolección"@pt, "Recolección"@es, "Collecte"@fr, "Gathering"@en ;
  a owl:NamedIndividual, skos:Concept ;
  skos:broader tadirah:capturing .

tadirah:transcribing
  skos:prefLabel "Transcribing"@en, "Transcripción"@es, "Транскрипција"@sr, "Transcription"@fr, "Transcrição"@pt, "Trascrizione"@it, "Transkription"@de ;
  a owl:NamedIndividual, skos:Concept ;
  skos:broader tadirah:capturing .

tadirah:imaging
  skos:broader tadirah:capturing ;
  skos:prefLabel "Captura em formato de imagem"@pt, "Gestione delle Immagini"@it, "Усликавање"@sr, "Imagerie"@fr, "Bilderfassung"@de, "Captura en formato imagen"@es, "Imaging"@en ;
  a skos:Concept, owl:NamedIndividual .

tadirah:discovering
  skos:prefLabel "Localização"@pt, "Entdecken"@de, "Discovering"@en, "Découverte"@fr, "Localización"@es, "Scoperta"@it, "Проналажење"@sr ;
  a skos:Concept, owl:NamedIndividual ;
  skos:broader tadirah:capturing .

tadirah:dataRecognition
  skos:prefLabel "Data Recognition"@en, "Reconhecimento de dados"@pt, "Препознавање података"@sr, "Reconocimiento de datos"@es, "Reconnaissance de données"@fr, "Riconoscimento dei Dati"@it, "Datenerkennung"@de ;
  skos:broader tadirah:capturing ;
  a owl:NamedIndividual, skos:Concept .

tadirah:recording
  skos:prefLabel "Grabación"@es, "Aufzeichnen"@de, "Enregistrement"@fr, "Recording"@en, "Снимање"@sr, "Registrazione"@it, "Gravação"@pt ;
  skos:broader tadirah:capturing ;
  a skos:Concept, owl:NamedIndividual .

tadirah:capturing
  skos:closeMatch <http://tadirah.dariah.eu/vocab/index.php?tema=7> ;
  skos:narrower tadirah:extracting, tadirah:dataRecognition, tadirah:imaging, tadirah:recording, tadirah:converting, tadirah:gathering, tadirah:transcribing, tadirah:discovering ;
  skos:prefLabel "Acquisition"@fr, "Capturing"@en, "Captura"@pt, "Captura"@es, "Acquisizione"@it, "Захватање"@sr, "Erfassen"@de ;
  a owl:NamedIndividual, skos:Concept ;
  skos:note "capturing generally refers to the activity of creating digital surrogates of real world objects, or expressing existing artifacts in a digital representation. This refers basically to learning and noticing something (as in discovering) and could be enhanced by a manual process (as in transcribing) or an automated procedure (as in imaging, data recognition or recording). This also includes aggregating resources, information and data (as in gathering)."@en ;
  skos:inScheme tadirah: ;
  skos:topConceptOf tadirah: .

tadirah:converting
  skos:prefLabel "Converting"@en, "Conversion"@fr, "Conversione"@it, "Conversão"@pt, "Conversión"@es, "Конвертовање"@sr, "Konvertieren"@de ;
  skos:broader tadirah:capturing ;
  a owl:NamedIndividual, skos:Concept .

tadirah:
  rdfs:label "TaDiRAH"@en ;
  a owl:NamedIndividual, owl:Ontology, skos:ConceptScheme ;
  skos:hasTopConcept tadirah:capturing .

tadirah:extracting
  skos:prefLabel "Extracting"@en ;
  a owl:NamedIndividual, skos:Concept ;
  skos:broader tadirah:capturing .

```

## SSH Open Marketplace API

Auch die [SSH Open Marketplace API](https://marketplace-api.sshopencloud.eu/swagger-ui/index.html?url=/v3/api-docs) kann die TaDiRAH Ontologie ausgeben.

```bash
curl -X GET "https://marketplace-api.sshopencloud.eu/api/vocabularies/tadirah2/concepts/capturing" -H "accept: application/json"

```

Request URL: `https://marketplace-api.sshopencloud.eu/api/vocabularies/tadirah2/concepts/capturing`

Response

```json
{
  "code": "capturing",
  "vocabulary": {
    "code": "tadirah2",
    "scheme": "https://vocabs.dariah.eu/tadirah/",
    "namespace": "https://vocabs.dariah.eu/tadirah/",
    "label": "TaDiRAH 2",
    "closed": true
  },
  "label": "Capturing",
  "notation": "",
  "uri": "https://vocabs.dariah.eu/tadirah/capturing",
  "candidate": false,
  "relatedConcepts": [
    {
      "code": "gathering",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Gathering",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/gathering",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "recording",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Recording",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/recording",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "discovering",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Discovering",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/discovering",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "converting",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Converting",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/converting",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "dataRecognition",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Data Recognition",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/dataRecognition",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "extracting",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Extracting",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/extracting",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "imaging",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Imaging",
      "notation": "",
      "uri": "https://vocabs.dariah.eu/tadirah/imaging",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    },
    {
      "code": "transcribing",
      "vocabulary": {
        "code": "tadirah2",
        "scheme": "https://vocabs.dariah.eu/tadirah/",
        "namespace": "https://vocabs.dariah.eu/tadirah/",
        "label": "TaDiRAH 2",
        "closed": true
      },
      "label": "Transcribing",
      "notation": "",
      "definition": "transcribing describes  the activity of creating a representation of a manuscript or of audio or video recordings. The representation is generally textual for the verbal aspects of recordings and structured for example by speech turns. It can also contain multimodal information like gestures or events and multimedia information like time synchronization and relation to media files.",
      "uri": "https://vocabs.dariah.eu/tadirah/transcribing",
      "relation": {
        "code": "narrower",
        "label": "Narrower"
      },
      "candidate": false
    }
  ]
}

```


