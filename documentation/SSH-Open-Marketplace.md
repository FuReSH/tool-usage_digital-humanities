---
title: "SSH Open Marketplace"
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

Der [SSH Open Marketplace](https://marketplace.sshopencloud.eu) ist eine EU-finanzierte Tool Registry. Projektende zumindest für den Aufbau der Infrastruktur war 2022.

# Quellen

- Stand 2 May 2023 ist bei 1237 von 1687 Tools TAPoR als die Datenquelle aufgeführt.
    + es gibt 28 Beiträger
    + 1017 der TAPoR Einträge wurden vom "System moderator" am 2022-11-03 eingespielt
    + 19 Einträge sind mit Wikidata reconciliiert worden

| source.id |          source.label          | no.tools |
|-----------|--------------------------------|----------|
| 1         | TAPoR                          |     1237 |
| NA        | NA                             |      200 |
| 3         | SSK Zotero Resources           |      154 |
| 52        | Language Resource Switchboard  |       49 |
| 202       | EOSC Catalogue                 |       25 |
| 104       | SSHopencloud Service Catalogue |       16 |
| 302       | DARIAH contribution tool       |        6 |


| informationContributor.id |                           informationContributor.username                           | no.tools |
|---------------------------|-------------------------------------------------------------------------------------|----------|
|                         5 | System moderator                                                                    |     1066 |
|                         4 | System importer                                                                     |      340 |
|                         1 | Administrator                                                                       |      105 |
|                        65 | 4ea88b26c3275dbb81ef7ec4f4c5869ce4c0e751268125e9361f0f36e542fb18@dariah.eu          |       69 |
|                       107 | 4d77afff84b8b447593e38aa3c59c02edf456f0bbb68cb0e3a163831bf550563@dariah.eu          |       35 |
|                       207 | 09da271bfff10ccaabbadcb52fca13fe7c75125b25e03adf8544aaa4635364f2@dariah.eu          |       13 |
|                       779 | f4548688d9aa2fe06889a756be4732a46fb2e64960bfc1dc03868c120faa290c@aai.eosc-portal.eu |       12 |
|                       909 | 76b020ea2b33d969eae993ed22413bdc5ff81f1a532d50fc902fd84382fcc382@aai.eosc-portal.eu |       11 |
|                       777 | 78fe9bfe194c35e4066f2122c84131d2829242374b2884efd50d9153c72ca710@aai.eosc-portal.eu |        6 |
|                       786 | 3b1da5a074ae4be84a2b95e3710e63f33e18e2df@eduteams.org                               |        4 |
|                       264 | 375705ce1b4f3e660ff1981587d410f3e9475f6be05e7a8f5a0032c054348748@dariah.eu          |        3 |
|                       762 | 2831d719344621627b613bf8b39f950500dc15f9afcfb544b335632a5f5ba40a@aai.eosc-portal.eu |        3 |
|                         2 | Moderator                                                                           |        2 |
|                       860 | 7b551a7f9591f5f80296a2387556252bb30d20967d3c0c777b880761d7a7e664@aai.eosc-portal.eu |        2 |
|                       912 | 102696928498913728364@google.com                                                    |        2 |
|                       913 | 9cbc2301d28e1573172f25597577b56cb86fff78141712e611e12f4678b20b33@aai.eosc-portal.eu |        2 |
|                       157 | 763b0b7d12b0ff7629e2de777dd6d10715e55c4f60d5485eb27602c77c28c997@dariah.eu          |        1 |
|                       257 | 0000-0001-9288-2888@orcid.org                                                       |        1 |
|                       260 | 268b5821aa730c9868f8d341b983c23af2a7c8272f0100fe38e6b47d837ed143@dariah.eu          |        1 |
|                       307 | 639e26d6765c4918ad41e8dbfa210d91@eudat.eu                                           |        1 |
|                       674 | 105729905308061393541@google.com                                                    |        1 |
|                       774 | 104991793678547226149@google.com                                                    |        1 |
|                       776 | 0000-0002-5851-5643@orcid.org                                                       |        1 |
|                       780 | 113575597226772854643@google.com                                                    |        1 |
|                       859 | 0000-0001-9422-1418@orcid.org                                                       |        1 |
|                       936 | adf7d07d1e09d7f53d0aacb696e85fb83099e5d74ad4d3bdbe8dd4082faf04c5@dariah.eu          |        1 |
|                      1010 | 111618135605349851906@google.com                                                    |        1 |
|                      1027 | 435fad30a426313c28802b4b1584eb205e99dd9ac04ca065f37809ef1f8dfe4d@aai.eosc-portal.eu |        1 |


# Ontologie / TaDiRAH

Sie benutzen für die Klassifizierung der Werkzeuge eine leicht angepasste [TaDiRAH](TaDiRAH.md) Ontologie. Um diese über das Webinterface zu benutzen wird folgendes URL-Muster benutzt

`https://marketplace.sshopencloud.eu/search?order=score&f.activity=CONCEPT`

Dabei steht `CONCEPT` für eines der TaDiRAH-Konzepte. Es ist allerdings zu beachten, dass Konzeptlables bei SSH alle dem englischen TaDiRAH Label folgen, case-sensitive sind und einzelne Komponenten mit `+` getrennt werden. Aus dem Label "Optical Character Recognition" für "https://vocabs.dariah.eu/tadirah/opticalCharacterRecognition" wird dadurch "Optical+Character+Recognition", e.g. <https://marketplace.sshopencloud.eu/search?order=score&f.activity=Optical+Character+Recognition>

Die Zuordnung von Labels zu Tools kann über die API abgefragt werden.

# API

Es gibt eine API und sie ist [hier](https://marketplace-api.sshopencloud.eu/swagger-ui/index.html?url=/v3/api-docs) dokumentiert, allerdings ist die Dokumentation nicht selbsterklärend. So, wird z.B. nicht erklärt, dass es das beste ist, die Felder für "draft", "approved", "redirect" einfach freizulassen.

Während die API genutzt werden kann um die [[TaDiRAH]] abzufragen,  ist es anscheinend nicht möglich alle Werkzeuge auszugeben, die mit einem bestimmten TaDiRAH Konzept getagged sind.

## 1. Einzelne Tools

Beispiel: Tesseract OCR

```bash
curl -X GET "https://marketplace-api.sshopencloud.eu/api/tools-services/2twSeF" -H "accept: application/json"
```

Request URL: `https://marketplace-api.sshopencloud.eu/api/tools-services/2twSeF`

Response

```json
{
    "accessibleAt": [
        "https://tesseract-ocr.github.io/"
    ],
    "category": "tool-or-service",
    "contributors": [
        {
            "actor": {
                "affiliations": [],
                "externalIds": [
                    {
                        "identifier": "1-30afc65fe2427bc06b6127c1da58b22b8759af5e4eb503fe0e9f906e79a16a98",
                        "identifierService": {
                            "code": "SourceActorId",
                            "label": "Source ActorId",
                            "ord": 7,
                            "urlTemplate": ""
                        }
                    }
                ],
                "id": 2378,
                "name": "HP Labs, Google"
            },
            "role": {
                "code": "creator",
                "label": "Creator",
                "ord": 3
            }
        }
    ],
    "description": "Tesseract is a free raw OCR engine originally developed by HP Labs and maintained by Google. It works with the Leptonica Image Processing Library, and is capable of reading a variety of image formats. It can convert images to text in over 100 languages.\n",
    "externalIds": [
        {
            "identifier": "Q945242",
            "identifierService": {
                "code": "Wikidata",
                "label": "Wikidata",
                "ord": 1,
                "urlTemplate": "https://www.wikidata.org/wiki/{source-item-id}"
            }
        },
        {
            "identifier": "tesseract-ocr/tesseract",
            "identifierService": {
                "code": "GitHub",
                "label": "GitHub",
                "ord": 2,
                "urlTemplate": "https://github.com/{source-item-id}"
            }
        }
    ],
    "id": 46845,
    "informationContributor": {
        "config": true,
        "displayName": "System Moderator",
        "id": 5,
        "registrationDate": "2021-09-03T13:37:00+0000",
        "role": "system-moderator",
        "status": "enabled",
        "username": "System moderator"
    },
    "label": "Tesseract OCR",
    "lastInfoUpdate": "2022-11-03T15:17:37+0000",
    "media": [
        {
            "caption": "",
            "info": {
                "category": "image",
                "hasThumbnail": true,
                "location": {
                    "sourceUrl": "https://tapor.ca/images/tools/0/192.jpg"
                },
                "mediaId": "9487ad40-0bfd-4e53-bbae-345e52d7ef32",
                "mimeType": "image/jpeg"
            }
        }
    ],
    "persistentId": "2twSeF",
    "properties": [
        {
            "concept": {
                "candidate": false,
                "code": "eng",
                "label": "English",
                "notation": "",
                "uri": "https://vocabs.acdh.oeaw.ac.at/iso6393/eng",
                "vocabulary": {
                    "closed": true,
                    "code": "iso-639-3",
                    "label": "ISO 639-3 Language Codes",
                    "namespace": "https://vocabs.acdh.oeaw.ac.at/iso6393/",
                    "scheme": "https://vocabs.acdh.oeaw.ac.at/iso6393/Schema"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": true,
                        "code": "iso-639-3",
                        "label": "ISO 639-3 Language Codes",
                        "namespace": "https://vocabs.acdh.oeaw.ac.at/iso6393/",
                        "scheme": "https://vocabs.acdh.oeaw.ac.at/iso6393/Schema"
                    }
                ],
                "code": "language",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Language",
                "ord": 20,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": false,
                "code": "6010",
                "label": "History, Archaeology",
                "notation": "6010",
                "uri": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/6010",
                "vocabulary": {
                    "closed": true,
                    "code": "discipline",
                    "label": "Ã–FOS 2012. Austrian Fields of Science and Technology Classification 2012",
                    "namespace": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/",
                    "scheme": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/Schema"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": true,
                        "code": "discipline",
                        "label": "Ã–FOS 2012. Austrian Fields of Science and Technology Classification 2012",
                        "namespace": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/",
                        "scheme": "https://vocabs.acdh.oeaw.ac.at/oefosdisciplines/Schema"
                    }
                ],
                "code": "discipline",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Discipline",
                "ord": 19,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": true,
                "code": "american",
                "label": "american",
                "notation": "american",
                "uri": "https://vocabs.dariah.eu/sshoc-keyword/american",
                "vocabulary": {
                    "closed": false,
                    "code": "sshoc-keyword",
                    "label": "Keywords from SSHOC MP",
                    "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                    "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": false,
                        "code": "sshoc-keyword",
                        "label": "Keywords from SSHOC MP",
                        "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                        "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                    }
                ],
                "code": "keyword",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Keyword",
                "ord": 18,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": true,
                "code": "1980s",
                "label": "1980s",
                "notation": "1980s",
                "uri": "https://vocabs.dariah.eu/sshoc-keyword/1980s",
                "vocabulary": {
                    "closed": false,
                    "code": "sshoc-keyword",
                    "label": "Keywords from SSHOC MP",
                    "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                    "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": false,
                        "code": "sshoc-keyword",
                        "label": "Keywords from SSHOC MP",
                        "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                        "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                    }
                ],
                "code": "keyword",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Keyword",
                "ord": 18,
                "type": "concept"
            }
        },
        {
            "type": {
                "allowedVocabularies": [],
                "code": "terms-of-use",
                "groupName": "Access",
                "hidden": false,
                "label": "Terms Of Use",
                "ord": 3,
                "type": "string"
            },
            "value": "Free"
        },
        {
            "concept": {
                "candidate": false,
                "code": "localApplication",
                "label": "Local application",
                "notation": "",
                "uri": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/localApplication",
                "vocabulary": {
                    "closed": true,
                    "code": "invocation-type",
                    "label": "Invocation type",
                    "namespace": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/",
                    "scheme": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/invocationTypeScheme"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": true,
                        "code": "invocation-type",
                        "label": "Invocation type",
                        "namespace": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/",
                        "scheme": "https://vocabs.sshopencloud.eu/vocabularies/invocation-type/invocationTypeScheme"
                    }
                ],
                "code": "mode-of-use",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Mode of use",
                "ord": 22,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": false,
                "code": "character",
                "label": "character",
                "notation": "",
                "uri": "https://vocabs.dariah.eu/sshoc-keyword/character",
                "vocabulary": {
                    "closed": false,
                    "code": "sshoc-keyword",
                    "label": "Keywords from SSHOC MP",
                    "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                    "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": false,
                        "code": "sshoc-keyword",
                        "label": "Keywords from SSHOC MP",
                        "namespace": "https://vocabs.dariah.eu/sshoc-keyword/",
                        "scheme": "https://vocabs.dariah.eu/sshoc-keyword/Schema"
                    }
                ],
                "code": "keyword",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Keyword",
                "ord": 18,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": false,
                "code": "opticalCharacterRecognition",
                "definition": "Wikidata contributors, \"Q167555,\" Wikidata, https://www.wikidata.org/w/index.php?title=Q167555&oldid=1257963956 (accessed September 4, 2020).",
                "label": "Optical Character Recognition",
                "notation": "",
                "uri": "https://vocabs.dariah.eu/tadirah/opticalCharacterRecognition",
                "vocabulary": {
                    "closed": true,
                    "code": "tadirah2",
                    "label": "TaDiRAH 2",
                    "namespace": "https://vocabs.dariah.eu/tadirah/",
                    "scheme": "https://vocabs.dariah.eu/tadirah/"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": true,
                        "code": "tadirah2",
                        "label": "TaDiRAH 2",
                        "namespace": "https://vocabs.dariah.eu/tadirah/",
                        "scheme": "https://vocabs.dariah.eu/tadirah/"
                    }
                ],
                "code": "activity",
                "groupName": "Categorisation",
                "hidden": false,
                "label": "Activity",
                "ord": 17,
                "type": "concept"
            }
        },
        {
            "concept": {
                "candidate": false,
                "code": "Apache-2.0",
                "label": "Apache License 2.0",
                "notation": "",
                "uri": "http://spdx.org/licenses/Apache-2.0",
                "vocabulary": {
                    "closed": true,
                    "code": "software-license",
                    "label": "Software License",
                    "namespace": "http://spdx.org/licenses/",
                    "scheme": "https://sshoc.poolparty.biz/Vocabularies/f8e37d35-c5fe-48d5-a9e1-2f8116726980"
                }
            },
            "type": {
                "allowedVocabularies": [
                    {
                        "closed": true,
                        "code": "software-license",
                        "label": "Software License",
                        "namespace": "http://spdx.org/licenses/",
                        "scheme": "https://sshoc.poolparty.biz/Vocabularies/f8e37d35-c5fe-48d5-a9e1-2f8116726980"
                    }
                ],
                "code": "license",
                "groupName": "Access",
                "hidden": false,
                "label": "License",
                "ord": 1,
                "type": "concept"
            }
        },
        {
            "type": {
                "allowedVocabularies": [],
                "code": "curation-flag-merged",
                "groupName": "Curation",
                "hidden": true,
                "label": "Curate merged items",
                "ord": 39,
                "type": "boolean"
            },
            "value": "TRUE"
        }
    ],
    "relatedItems": [
        {
            "category": "step",
            "description": "Using well materialized Ground Control Points (GCPs) and using the same set in all the performed flights will require the use of topographic instruments only for the first acquisition, as once measured, the GCPs will be re-used for the subsequents flights. It is important to underline the importance of acquiring a trustworthy set of GCPs to be used for all the surveys, instead of measuring new GCPs every time. It is more important, in fact, not to acquire the most accurate GNSS data, but to use the most precise set of GCPs, assuming for (at least locally) the validity of the first data acquired, cause repeating measures over time may lead to non extremely precise co-registration of the generated models. Instruments required: Total station D-GNSS antenna Action to perform: Defining and measuring a topographic network Materialization of the topographical vertices Materialization of the control points Ground control points displacement around and inside the site Natural points selection and digitization for future surveys Control points measurement and recording (via Total station or GNSS receiver) Softwares to use: Topographic network compensation (e.g. MicroSurvey StarNet)",
            "id": 41133,
            "label": "Georeferencing the surveyed data: Using a GNSS            receiver for precise positioning of Ground Control Points",
            "persistentId": "Vb1dhh",
            "relation": {
                "code": "is-mentioned-in",
                "inverseOf": "mentions",
                "label": "Is mentioned in"
            },
            "workflowId": "wqeZGu"
        },
        {
            "category": "step",
            "description": "No description provided.",
            "id": 41135,
            "label": "Training the model",
            "persistentId": "gyV1tc",
            "relation": {
                "code": "is-mentioned-in",
                "inverseOf": "mentions",
                "label": "Is mentioned in"
            },
            "workflowId": "qYzKVU"
        },
        {
            "category": "step",
            "description": "The important characteristics of the image are the following: Layout elements (tables, graphics, ...) Script type (handwritten, Gothic script, Roman script, non-European) Mixed content (pre-printed documents with handwriting) These characteristics determine the method: If it's a clean printed text, a classic OCR engine would be enough In other cases, i.e. handwritten, old printed texts with blackletter (gothic) scripts, or low quality scans, using a model is necessary. If a model exists, or it works out of the box, or it needs to be retrained or adapted. Otherwise, you have to train a model from scratch.",
            "id": 41136,
            "label": "Define the characteristics of the image",
            "persistentId": "4QI32L",
            "relation": {
                "code": "is-mentioned-in",
                "inverseOf": "mentions",
                "label": "Is mentioned in"
            },
            "workflowId": "qYzKVU"
        }
    ],
    "status": "approved"
}
```


