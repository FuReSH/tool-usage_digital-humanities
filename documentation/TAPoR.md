---
title: "TAPoR"
subtitle: "notes on data and infrastructure"
author:
    - Till Grallert
affiliation: Scholarly Makerspace, Humboldt-Universität zu Berlin
date: 2023-01-23 
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

TAPoR bietet eine undokumentierte (?) API an, die sich unter  <https://tapor.ca/api/tools/by_analysis> findet und JSON ausgibt. Wir sind über eine Analyse des [ToolXtractor](https://github.com/lehkost/ToolXtractor)  [@BarbotEtAl2019ToolsMentioned; @BarbotEtAl2019WhichDHTools] auf diese API gestoßen.

Wir möchten den TaPOR Datensatz in unser Werkzeugregal übernehmen.

# API

## gesamter Datensatz

<https://tapor.ca/api/tools/by_analysis>

Response (Ausschnitt für einzelne Werkzeuge)

```json
{
    "attribute_value_ids": [
        "85"
    ],
    "detail": "OpenRefine (formerly Google Refine) is a free, open-source tool for working with messy data. It enables users to clean data, transform it between a variety of formats, extend it with web services, and link it to databases. This tool is available for Windows, Mac and Linux.",
    "id": null,
    "image_url": "images/tools/0/296.jpg",
    "name": "OpenRefine",
    "star_average": 0.0,
    "tool_id": 296
}
```

## Einzelne Werkzeuge

Request URL: `https://tapor.ca/api/tools/ID`

### Beispiel

Wenn wir uns die Daten anschauen, die die API zu Tesseract (ID: 192) unter <https://tapor.ca/api/tools/192> ausgibt, so fällt auf, dass die Angaben  wesentlich umfangreicher sind, als in der Liste der Werkzeuge unter <https://tapor.ca/api/tools/by_analysis>. Allerdings fehlt hier z.B. die Kategorisierung nach [[TaDiRAH]].

Response

```json
{
    "code": null,
    "creators_email": "",
    "creators_name": "HP Labs, Google",
    "creators_url": "http://google.com",
    "detail": "<p>Tesseract is a free raw OCR engine originally developed by HP Labs and now maintained by Google. It works with the Leptonica Image Processing Library, and is capable of reading a variety of image formats. It can convert images to text in over 40 languages.</p>",
    "id": 192,
    "image_url": "images/tools/0/192.jpg",
    "is_approved": true,
    "language": null,
    "last_updated": "2017-01-16",
    "name": "Tesseract OCR",
    "nature": "tool",
    "rating_count": 0,
    "recipes": "",
    "repository": "",
    "star_average": 0.0,
    "thumb_url": "images/tools/0/192-thumb.jpg",
    "url": "http://code.google.com/p/tesseract-ocr/",
    "user_id": null
}
```

```json
{
    "id": 296,
    "user_id": 1,
    "name": "OpenRefine",
    "detail": "<p>OpenRefine (formerly Google Refine) is a free, open-source tool for working with messy data. It enables users to clean data, transform it between a variety of formats, extend it with web services, and link it to databases. This tool is available for Windows, Mac and Linux.</p>",
    "is_approved": true,
    "image_url": "images/tools/0/296.jpg",
    "creators_name": "OpenRefine Community",
    "creators_email": "",
    "creators_url": "http://openrefine.org/OpenRefine/community",
    "star_average": 0.0,
    "url": "http://openrefine.org/",
    "last_updated": "2013-11-06",
    "nature": "tool",
    "language": null,
    "code": null,
    "repository": "",
    "thumb_url": "images/tools/0/296-thumb.jpg",
    "rating_count": 0,
    "recipes": ""
}
```

# Reconcilation mit Wikidata

Wir haben dazu ein OpenRefine Projekt angelegt.

+ open local JSON file
+ enrich this file based on API calls
    * [GREL](https://openrefine.org/docs/manual/grelfunctions) sample for building a URL from a nummeric value: 
        - `value.replace(/(\d+)/, 'https://tapor.ca/api/tools/$1')`
        - the same but cheching for null values first `if(not(value == null), value.replace(/(\d+)/, 'https://tapor.ca/api/tools/$1'), '')`
    - GREL for joining strings:
        + `join(['https://tapor.ca/', value], '')` will prefix a partial URL 
    - GREL for parsing JSON
        + `parseJson(value).get('key')` will return a value for the selected key
        + `parseJson(value).key` will return the value of the selected key
- Select a column for reconciliation, most likely the tool name, and choose `Reconcile -> Start reconciling`. This will open additional options from Wikidata.
- Manually check all potential matches
    + done until and including names starting with: **S**

