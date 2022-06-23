This README.txt file was generated on 20210917 by Matthew D. Lincoln

-------------------
GENERAL INFORMATION
-------------------

1. Title of Dataset: The Index of Digital Humanities Conferences Database


2. Author Information
<create a new entry for each additional author>

Corresponding Author Contact Information
    Name: Scott B. Weingart
    Institution: University of Notre Dame
    Address: 284 Hesburgh Library, Notre Dame, IN 46556
    Email: weingart.scott@nd.edu

---------------------
CHANGELOG
---------------------

v4 2022-02-04
	4th semi-annual update of data
	Changes:
	- Full text for works that have been licensed for republication are now included in the tables. See the documentation for works.csv and  dh_conferences_works.csv.

v3 2021-09-17
	3rd semi-annual update of data
	Changes:
	- Additional observations added to most tables, some entries merged.
	- Although works_keywords.csv, works_languages.csv, works_topics.csv had been included in prior exports, they were not properly documented in the README. This version adds documentation for those tables.

v2 2021-03-19
	2nd semi-annual update of data
	Changes:
	- Additional observations added to most tables,
	- Further data cleaning resulted in merging several closely-matching records, and thus a reduction in total number of observations to: Affiliations, Keywords, Topics, and Work Types
	- license.csv was documented, but not included in the previous deposit version. This has been rectified.
	- The description of the `topic` field in dh_conferences_works.csv and topics.csv has been updated to reflect the widened scope of that field.

v1 2020-09-22
	First deposit of data.

---------------------
DATA & FILE OVERVIEW
---------------------


Directory of Files:
   A. Filename: dh_conferences_tables.zip
      Short description: This zip contains one CSV for each of the core tables in our database, and can be used to do more complex analyses such as tracking institutional affiliations across many different years of conferences.



   B. Filename: dh_conferences_works.zip
      Short description: This file contains a simplified version of our database arranged with one row per "work" (be it a keynote, a paper, a panel session, etc.). Associated conference information such as name, location, and date, as well as author names and keyword/topic tags are included in each row as well. This CSV does not contain more complex related information such as changing author names or detailed affiliation information. For that, you will want to look at the full relational database available below.


Additional Notes on File Relationships, Context, or Content
(for example, if a user wants to reuse and/or cite your data,
what information would you want them to know?):  N/A


File Naming Convention: Each file is named for the table it represents.


-----------------------------------------
DATA DESCRIPTION FOR: dh_conferences_tables.zip
-----------------------------------------

For all fields, required fields marked with an asterisk (*)

works.csv
	Description: A record for a single work such as a paper, keynote, or session.

	Number of variables: 9

	Number of cases/rows: 7296

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*conference	ForeignKey	The conference where this abstract was submitted/published. (Related model: Conference)
		*title	CharField	Abstract title
		work_type	ForeignKey	Abstracts may belong to one type that has been defined by editors based on a survey of all the abstracts in this collection, e.g. "poster", "workshop", "long paper". (Related model: WorkType)
		full_text	TextField	The full text of the work, when indexed and licensed for republication. If the full text of the work has not yet been indexed into this system, OR if the text is not licensed for republication, this field will be blank.
		full_text_type	CharField	Work full text will either be available as plain text (txt) or as TEI (xml). When full text is not available to be shared, this field will be blank.
		full_text_license	ForeignKey	License of this full text, when known (Related model: License)
		url	CharField	URL where the full text of this specific abstract can be freely accessed
		parent_session	ForeignKey	If this work was part of a multi-paper organized session, this is the entry for the parent session (Related model: Work)

authors.csv
	Description: A person who has authored at least one abstract in this database. All attributes of the author are established in the context of a given work, so authors have no inherent/immutable attributes beyond this unique identifier.

	Number of variables: 1

	Number of cases/rows: 8651

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField

conferences.csv
	Description: A scholarly event with organized presentations, such as a conference, symposium, or workshop.

	Number of variables: 19

	Number of cases/rows: 500

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*year	PositiveIntegerField	Year the conference was held
		short_title	CharField	A location-based short title for the conference
		notes	TextField	Further descriptive information
		url	CharField	Public URL for the conference and/or conference program
		theme_title	CharField	Optional thematic title (e.g. 'Big Tent Digital Humanities')
		start_date	DateField	YYYY-MM-DD
		end_date	DateField	YYYY-MM-DD
		city	CharField	City where the conference took place
		state_province_region	CharField	State, province, or region where the conference was held
		country	ForeignKey	(Related model: Country)
		references	TextField	Citations to conference proceedings
		contributors	TextField	Individuals or organizations who contributed data about this conference
		attendance	TextField	Summary information about conference attendance, with source links
		*entry_status	CharField	Have all the abstracts for this conference been entered?
		*program_available	BooleanField	Is a program for this conference available in some format for editors to input?
		*abstracts_available	BooleanField	Are the abstracts for this conference available in some format for editors to input?
		search_text	CharField	Any searchable text that should lead to this conference
		*label	CharField	General label for this object

conference_organizer.csv
	Description: Many-to-many relationships between conferences and their (potentially) multiple organizers.

	Number of variables: 3

	Number of cases/rows: 518

	Missing data codes: [empty csv cell]

	Fields
		Name	Type	Description
		*id	AutoField
		*organizer	ForeignKey	(Related model: Organizer)
		*conference	ForeignKey	(Related model: Conference)

conference_hosting_institution.csv
	Description: Many-to-many relationships between conferences and the (potentially) multiple institutions that host them.

	Number of variables: 3

	Number of cases/rows: 277

	Missing data codes: [empty csv cell]

	Fields
		Name	Type	Description
		*id	AutoField
		*conference	ForeignKey	(Related model: Conference)
		*institution	ForeignKey	(Related model: Institution)

conference_series.csv
	Description: A formalized series of multiple events, such as an annual conference or recurring symposium

	Number of variables: 4

	Number of cases/rows: 68

	Missing data codes: [empty csv cell]

	Fields
		Name	Type	Description
		*id	AutoField
		*title	CharField	Full name
		*abbreviation	CharField	Display abbreviation
		notes	TextField	Discursive notes, generally concerning the history of this series

conference_series_membership.csv
	Description: Many-to-many relationships between conferences and the (potentially) multiple series they belong to.

	Number of variables: 4

	Number of cases/rows: 502

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*series	ForeignKey	(Related model: ConferenceSeries)
		*conference	ForeignKey	(Related model: Conference)
		number	IntegerField	Order of this conference within this series.

organizers.csv
	Description: An organizer of academic events, such as a scholarly association or academic center.

	Number of variables: 5

	Number of cases/rows: 55

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*name	CharField
		*abbreviation	CharField
		notes	TextField
		url	CharField

authorships.csv
	Description: Each authorship describes the relationship of an author to a given work, establishing the authors' attributes as they gave them in the official program where the work was presented.

	Number of variables: 5

	Number of cases/rows: 16763

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*author	ForeignKey	The author (Related model: Author)
		*work	ForeignKey	The work authored. (Related model: Work)
		*authorship_order	PositiveSmallIntegerField	Authorship order (1-based indexing)
		*appellation	ForeignKey	The appellation given by the author when they submitted this particular work. (Related model: Appellation)

authorship_affiliation.csv
	Description: Many-to-many relationships between authorships and the (potentially) multiple affiliations given by authors for a given work

	Number of variables: 3

	Number of cases/rows: 16642

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*authorship	ForeignKey	(Related model: Authorship)
		*affiliation	ForeignKey	(Related model: Affiliation)

appellations.csv
	Description: A name belonging to an author

	Number of variables: 3

	Number of cases/rows: 9363

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		first_name	CharField	Surname and/or first and middle initials
		last_name	CharField	Family name

institutions.csv
	Description: Institutions such as universities or research centers, with which authors may be affiliated.

	Number of variables: 5

	Number of cases/rows: 1853

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*name	CharField	Institution name
		city	CharField	City where the institution is located
		state_province_region	CharField	State, province, or region where the institution is located
		country	ForeignKey	Country where the institution is located (Related model: Country)

affiliations.csv
	Description: A sub-unit of an Institution, such as a center, department, library, etc.

	Number of variables: 3

	Number of cases/rows: 3106

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		department	CharField	The name of a department, center, or other subdivision of a larger institution
		*institution	ForeignKey	The parent institution for this affiliation (Related model: Institution)

countries.csv
	Description: A controlled vocabulary of countries

	Number of variables: 3

	Number of cases/rows: 197

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*tgn_id	CharField	Canonical ID in the Getty Thesaurus of Geographic Names
		*pref_name	CharField	Preferred label for the country sourced from the Getty TGN

keywords.csv
	Description: Author-supplied keywords describing the content of a work

	Number of variables: 2

	Number of cases/rows: 6633

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*title	CharField

topics.csv
	Description: Topics from a conference-specific controlled vocabulary

	Number of variables: 2

	Number of cases/rows: 293

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*title	CharField

languages.csv
	Description: Languages in which works are written

	Number of variables: 2

	Number of cases/rows: 185

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*title	CharField

work_types.csv
	Description: Controlled vocabulary of work types, such as 'paper' or 'keynote'

	Number of variables: 3

	Number of cases/rows: 11

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*title	CharField
		*is_parent	BooleanField	Works of this type are considered multi-paper panels/sessions and may contain 'child' abstracts

licenses.csv
	Description: Licenses that may be applicable to full texts

	Number of variables: 6

	Number of cases/rows: 3

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*title	CharField	Full title of the license
		*full_text	TextField	Full text of the license
		*display_abbreviation	CharField	A short, identifiable abbreviation of the license
		url	CharField	URL with a full description of the licnese
		*default	BooleanField	Make this license the default license applied to any work whose conference has been set to show all full texts.

works_keywords.csv
	Description: Many-to-many relationships between works and keywords

	Number of variables: 3

	Number of cases/rows: 13730

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*work	ForeignKey	Related model: Work
		*keyword	ForeignKey	Related model: Keyword

works_languages.csv
	Description: Many-to-many relationships between works and languages

	Number of variables: 3

	Number of cases/rows: 7295

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*work	ForeignKey	Related model: Work
		*language	ForeignKey	Related model: Language

works_topics.csv
	Description: Many-to-many relationships between works and topics

	Number of variables: 3

	Number of cases/rows: 20518

	Missing data codes: [empty csv cell]

	Fields:
		Name	Type	Description
		*id	AutoField
		*work	ForeignKey	Related model: Work
		*topic	ForeignKey	Related model: Topic

-----------------------------------------
DATA DESCRIPTION FOR: dh_conferences_works.zip
-----------------------------------------

For all fields, required fields marked with an asterisk (*)

dh_conferences_works.csv
	Description: A record for a single work such as a paper, keynote, or session.

	Number of variables: 20

	Number of cases/rows: 7296

	Missing data codes: [empty csv cell]

	Fields:
		Name	Description
		*work_id	Unique ID number
		*conference_label	Conference label
		conference_short_title	Location-based short title of the conference
		conference_theme_title	Thematic conference title
		*conference_year
		conference_organizers	Conference organizing groups (Separated by semicolon)
		conference_series	Conference series (separated by semicolon)
		conference_hosting_institutions	Hosting institutions (separated by a semicolon)
		conference_city
		conference_state
		conference_country
		conference_url	URL for the conference program or abstracts
		work_title	Work title
		work_url	Direct URL for the work abstract if it exists
		*work_authors	Named authors (separated by a semicolon)
		*work_type	Type of work (e.g. keynote, multipaper session, poster
		parent_work_id	ID of a multipaper session or panel session that this work belongs to
		keywords	Author-submitted keywords (separated by a semicolon)
		languages	Language(s) of the abstract (separated by a semicolon)
		topics	Topics from a conference-specific controlled vocabulary (separated by a semicolon)

--------------------------
METHODOLOGICAL INFORMATION
--------------------------

1. Software-specific information:

Name: N/A
Version: N/A
System Requirements: N/A
Open Source? (Y/N): N/A

(if available and applicable)
Executable URL: N/A
Source Repository URL: N/A
Developer: N/A
Product URL: N/A
Software source components: N/A

Additional Notes(such as, will this software not run on
certain operating systems?): N/A

2. Equipment-specific information:

Manufacturer: N/A
Model: N/A

(if applicable)
Embedded Software / Firmware Name: N/A
Embedded Software / Firmware Version: N/A
Additional Notes: N/A

3. Date of data collection (single date, range, approximate date): 2012-2020

