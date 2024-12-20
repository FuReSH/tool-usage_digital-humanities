This [R Markdown](http://rmarkdown.rstudio.com) Notebook presents our
approach to the following scenario:

> We are a [*Scholarly Makerspace*](https://makerspace.hypotheses.org)
> and want to curate a **list of tools** for DH work based on their
> **importance** in the **field**.

The question contains a number of terms (highlighted above) that need
further elaboration, if we want to operationalise this scenario for
computational (or any) analysis (as we obviously do):

-   The **field** of DH is represented by its written output, through
    conference abstracts, journal articles etc. This means that we need
    to find or build a **corpus** of openly available material to run
    any analysis on.
-   There are, of course, multiple approaches to measuring the relative
    **importance** of anything. For the sake of our analysis, we will
    opt for the number of mentions of a specific tool within a corpus as
    a measure of its importance to the field.
-   As we do not, currently, have a sophisticated way of extracting
    tools through *natural language processing* (NLP), we will need to
    find or produce a **list of tools** known to be relevant to the
    field. As tool registries have some importance in DH, we assume to
    be able to compile such a list with relative ease. Each entry in the
    list will then be assigned numerical values correlating to their
    relative frequency within our corpus.

Even though our approach was developed independently in spring 2022, it
appeared that other scholars were posing similar questions, following
comparable approaches. Thus, we have benefited from earlier work by
Ulrike Henny-Kramer, Frank Fischer, and many others
\[@BarbotEtAl2019ToolsMentioned; @BarbotEtAl2019WhichDHTools;
@FischerMoranville2020ToolsMentioned;
@HennyJettka2021SoftwarezitationPaper\]. We also look forward to the
results of Manuel Burghardt’s ventures into the more general question of
scholarly applications of methods and tools, which he and his team
investigate with machine-learning approaches to natural language
processing \[@Cebral2022InteractiveExploratoryAnalysis;
@GutierrezDeLaTorreEtAl2022ManyFacesTheory;
@ManuelEtAl2022ToolsEpistemologiesDH\].

# Prepare the environment

As is good practice, we load all necessary packages/libraries at the
beginning of our R script. We also make sure that everything is set to
use unicode encodings (might be necessary for some Apple systems).

    # load libraries
    library(tidyverse)   # load the core of the tidyverse packages, including ggplot

    ## ── Attaching packages ─────────────────────────────────────── tidyverse 1.3.2 ──
    ## ✔ ggplot2 3.3.6      ✔ purrr   0.3.4 
    ## ✔ tibble  3.1.8      ✔ dplyr   1.0.10
    ## ✔ tidyr   1.2.0      ✔ stringr 1.4.1 
    ## ✔ readr   2.1.2      ✔ forcats 0.5.2 
    ## ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
    ## ✖ dplyr::filter() masks stats::filter()
    ## ✖ dplyr::lag()    masks stats::lag()

    library(ggrepel)     # repel labels in ggplot
    library(ggwordcloud) # wordclouds with ggplot
    library(paletteer)   # for better colour palettes
    library(here)        # for easy navigation within an R project

    ## here() starts at /BachUni/BachBibliothek/GitHub/FuReSH/user-stories

    library(lubridate)   # for working with dates

    ## 
    ## Attaching package: 'lubridate'
    ## 
    ## The following objects are masked from 'package:base':
    ## 
    ##     date, intersect, setdiff, union

    # set a general theme for all ggplots
    theme_set(theme_bw())
    # enable unicode
    Sys.setlocale("LC_ALL", "en_US.UTF-8")

# corpus building

## Corpora

We use a number of openly available corpora for our investigation.

1.  **DH conferences**. Full-text abstracts for some of ADHO’s DH
    conferences are available as part of
    \[@LincolnEtAl2021IndexDigitalHumanities;
    @Weingart2020IndexDHData\]. The abstracts for the DH2023 conference
    in Tokyo are available on
    [GitHub](https://github.com/747/tei-to-pdf-dh2022).
2.  **DHd conferences**. Abstracts for the annual DHd conferences is
    available from the [DHd GitHub](https://github.com/DHd-Verband)
    repositories.
3.  **Digital Humanities Quarterly**. Articles from DHQ are openly
    published with CC licences and are generally available for
    computational analysis. A corpus of 429 articles published until
    2019 is available as zipped folder at
    <http://digitalhumanities.org/dhq/data/dhq-xml.zip>.
4.  **DFG**. The [GEPRIS - Geförderte Projekte der Deutschen
    Forschungsgemeinschaft](https://gepris.dfg.de/gepris/OCTOPUS)
    database provides data on all funded projects. Unfortunately, and
    despite its commitment to Open Access and Open Science, DFG does not
    provide an API or machine-actionable data for reuse.

## Preprocessing

For our analysis we need plain-text files of conference abstracts and
journal articles. The pre-processing steps for our corpora, therefore,
involve two distinct approaches: 1) converting TEI XML to plain-text and
2) scraping structured data from websites, which we save as `.csv`.

### TEI XML

ADHO, DHd, and DHQ all provide TEI XML files, which we can convert to
plain-text using XSLT transformations, such as the one provided by my
[GitHub repository to convert TEI to
Markdown](https://github.com/OpenArabicPE/convert_tei-to-markdown). Note
that one could have parsed the XML with R and then extracted the
necessary nodes for analysis, but re-using available XSLT was the much
quicker solution.

    <?xml version="1.0" encoding="UTF-8"?>
    <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <teiHeader>
            <fileDesc>
                <titleStmt>
                    <title>Establishing parameters for stylometric authorship attribution of 19th-century Arabic books and periodicals</title>
                    <author>
                        <persName>
                            <surname>Romanov</surname>
                            <forename>Maxim</forename>
                        </persName>
                        <affiliation>Universität Hamburg, Germany</affiliation>
                    </author>
                    <author>
                        <persName>
                            <surname>Grallert</surname>
                            <forename>Till</forename>
                        </persName>
                        <affiliation>Humboldt-Universität zu Berlin, Germany</affiliation>
                    </author>
                </titleStmt>
                <editionStmt>
                    <edition>
                        <date>2022-04-27T10:36:00Z</date>
                    </edition>
                </editionStmt>
            </fileDesc>
            <!-- ... -->
        </teiHeader>
        <text>
            <body>
                <p style="text-align: left; ">The vast majority of articles in Arabic periodicals from the late Ottoman Eastern Mediterranean (c.1850–1918) carried no explicit authorship information (Grallert 2021, Khayat 2019). Yet, the question of authorship has not received much attention in existing scholarship and is strikingly absent from Ayalon (1995), the standard work in the field. The common implicit hypothesis considers editors-cum-owners listed in mastheads and imprints as the sole authors of all the anonymous texts. This results in the conflation of periodicals with the intellectual output of a single person. Such a synonymous use of, for example, “Muḥammad Kurd ʿAlī” (1876–1953) and the monthly “<hi rend="italic">al-Muqtabas</hi>” (published in Cairo and Damascus, 1906–1918) can be observed across the board (e.g. Seikaly 1981, Ezzerelli 2017). However, the hypothesis a) remains empirically untested, b) negates the known realities of periodical production and individual biographies, and c) ignores specific contexts of individual periodicals.
                </p>
                <!-- ... -->
            </body>
        </text>
    </TEI>

    The vast majority of articles in Arabic periodicals from the late Ottoman Eastern Mediterranean (c.1850–1918) carried no explicit authorship information (Grallert 2021, Khayat 2019). Yet, the question of authorship has not received much attention in existing scholarship and is strikingly absent from Ayalon (1995), the standard work in the field. The common implicit hypothesis considers editors-cum-owners listed in mastheads and imprints as the sole authors of all the anonymous texts. This results in the conflation of periodicals with the intellectual output of a single person. Such a synonymous use of, for example, “Muḥammad Kurd ʿAlī” (1876–1953) and the monthly “ al-Muqtabas ” (published in Cairo and Damascus, 1906–1918) can be observed across the board (e.g. Seikaly 1981, Ezzerelli 2017). However, the hypothesis a) remains empirically untested, b) negates the known realities of periodical production and individual biographies, and c) ignores specific contexts of individual periodicals. 

It would also make sense to extract structured metadata from the TEI
files but this step has been left to a later step.

#### DH conferences

One thing to note, however, is that the TEI XML of the ADHO abstracts
from the \[@LincolnEtAl2021IndexDigitalHumanities;
@Weingart2020IndexDHData\] dataset is wrapped inside `.csv` files. In
addition, some of the abstracts are TEI XML fragments while others are
complete TEI XML files. We have, therefore, extracted the abstracts with
the following code.

Note that we prefixed functions with a namespace identifying the package
they come from.

    # 1. read the original CSV
    setwd(here("data/dh-conferences/12987959"))
    df.dhconfs <- readr::read_csv("dh-conferences_works.csv")

    ## Rows: 7296 Columns: 23
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (20): conference_label, conference_short_title, conference_theme_title, ...
    ## dbl  (3): work_id, conference_year, parent_work_id
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

    # 2. select only some columns and rename them
    df.dhconfs.works <- df.dhconfs %>%
      dplyr::select(work_id, work_title, work_authors, full_text, conference_year, conference_label, conference_organizers, keywords, topics, languages) %>%
      dplyr::rename(id = work_id,
                    title = work_title,
                    text = full_text,
                    authors = work_authors,
                    year = conference_year,
                    conference = conference_label,
                    organizers = conference_organizers) %>%
      dplyr::mutate(year = lubridate::parse_date_time(year, orders = "Y"),
                    id = as.character(id))

The dataset contains `nrow(df.dhconfs.works)` presentations at
`unique(df.dhconfs.works$conference)` between
`min(df.dhconfs.works$year)` and `max(df.dhconfs.works$year)`.

    # save data to file
    setwd(here("data/dh-conferences/"))
    save(df.dhconfs.works, file = "dh-conferences_works.rda")
    save(df.dhconfs, file ="dh-conferences.rda")
    # remove the original, rather large dataframe
    rm(df.dhconfs)

    # there is a problem with the abstracts: they are mostly full TEI XML files, which need to be parsed
    # small tibble with abstracts only
    df.dhconfs.abstracts <- df.dhconfs.works %>%
      dplyr::select(id, text, year) %>%
      # drop all lines that do not provide the full text of the abstract
      tidyr::drop_na(text)

The dataset provides only `nrow(df.dhconfs.abstracts)` full text
abstracts for the `nrow(df.dhconfs.works)` presentations We can now save
these abstracts in order to process them further with XSLT etc.

Note that running the next code block results in files being
overwritten.

Upon closer inspection, it turns out that not all abstracts are complete
TEI XML files. There are hundreds of TEI XML fragments and quite a few
plain-text files without any markup.

1.  The plain-text files were renamed to `.txt`
2.  Complete TEI XML files were converted to plain-text using the
    above-mentioned XSLT.
3.  TEI XML fragments were converted to full TEI XML files adding the
    necessary `<teiHeader>` using regular expressions. The complete TEI
    files were then again converted to plain-text.

## scrape DFG GEPRIS

Initially it seemed simple to scrape all entries from the database as
the URLs follow the pattern `https://gepris.dfg.de/gepris/projekt/{ID}`
with numerical IDs. However, as examples showed that these can have at
least 9 digits, a simple incrementing function would take more than 25
years with a one second delay between each call to the server in order
the 135273 actual projects listed in GEPRIS (because IDs do not form an
uninterrupted sequence of numbers this attempt would make many
unnecessary calls).

The first step, therefore, was to scrape the existent project IDs from
the catalogue pages. In total this would require to iterate over 2706
catalogue pages with 50 projects IDs each but could be further decreased
by limiting our call to a specific sub-field, namely the humanities,
encoded in the catalogue URLs as `&fachgebiet=11`. This would reduce the
number of catalogue pages to 319.

### prepare the environment

In order to scrape websites and extract information based on their
position within the parsed HTML5 / XML, we need to load the `rvest()`
library.

    library(rvest)

    ## 
    ## Attaching package: 'rvest'

    ## The following object is masked from 'package:readr':
    ## 
    ##     guess_encoding

We also need a small helper function to extract the textual content of
any element or attribute within a given HTML stream.

    # input for the xpath parameter is a string
    f.get.text <- function(html, xpath) {
      rvest::html_element(html, xpath = xpath) %>% 
        rvest::html_text2()
    }

### Scrape the relevant project IDs from the catalogue

The following function scrapes all project IDs from a GEPRIS catalogue
page.

    f.scrape.gepris.ids <- function(url) {
      v.page = rvest::read_html(url)
      v.xpath.item = "/html/body//div[@class = 'listbox2']/div[@id = 'liste']/div"
      v.urls.projects <- ''
      for (item in html_elements(v.page, xpath = v.xpath.item)) {
        v.urls.projects <- append(v.urls.projects,
                                f.get.text(item, "div[@class = 'results']/h2[1]/a/@href"),
                                after = 1)
      }
      str_replace(v.urls.projects, '^.*?(\\d+)$', '\\1')
    }

We can now use this function iterate over the catalogue pages using our
knowledge of the URL patterns:

-   ‘&index=0’ needs to be incremented by 50
-   ‘&fachgebiet=11’ indicates humanities

<!-- -->

    ## parts of the URL as variables. 
    v.url.part.1 = "https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&hitsPerPage=50&index="
    v.url.part.2 = "&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false"

We also ought to be kind to the server and add some delay (unfortunately
their really rudimentary robots.txt did not provide any guidance for
crawlers).

### get individual project details

    f.scrape.gepris.entry <- function(project.id) {
      v.url.base = "https://gepris.dfg.de/gepris/projekt/"
      v.url = paste0(v.url.base, project.id)
      v.page = rvest::read_html(v.url)
      v.xpath.details = "/html/body//div[@class = 'details']"
      v.xpath.description = "/html/body//div[@id = 'projektbeschreibung']"
      # problem: the number of divs changes, depending on presence of data. Selection by index will therefore be errorprone
      df.gepris <- dplyr::tibble(
        id = as.double(project.id),
        #html.details = rvest::html_element(v.page, xpath = v.xpath.details),
        title = f.get.text(v.page, paste(v.xpath.details, "h1[1]", sep = "/")),
        antragsteller = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'value'][starts-with(a/@href, '/gepris/person')]", sep = "//")),
        antragstellerId = str_replace(f.get.text(v.page, paste(v.xpath.details, "span[@class = 'value']/a[starts-with(@href, '/gepris/person')]/@href", sep = "//")),
                                      '^.*?(\\d+)$', '\\1'),
        fachlicheZuordnung = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'name'][text() = 'Fachliche Zuordnung']/following-sibling::span[@class = 'value']", sep = "//")),
        dates = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'name'][text() = 'Förderung']/following-sibling::span[@class = 'value']", sep = "//")),
        projektText = f.get.text(v.page, paste(v.xpath.description, "div[@id = 'projekttext']", sep = "/")),
        dfgVerfahren = f.get.text(v.page, paste(v.xpath.description, "div[@id = 'projekttext']/following-sibling::div[1]/span[@class = 'value']", sep = "/"))
      )
      df.gepris
    }

Test this scraping function

    f.scrape.gepris.entry(445975300)

    ## # A tibble: 1 × 8
    ##          id title                  antra…¹ antra…² fachl…³ dates proje…⁴ dfgVe…⁵
    ##       <dbl> <chr>                  <chr>   <chr>   <chr>   <chr> <chr>   <chr>  
    ## 1 445975300 Die Entwicklung islam… Dr. Ma… 329046… Islamw… "För… "Im er… Emmy N…
    ## # … with abbreviated variable names ¹​antragsteller, ²​antragstellerId,
    ## #   ³​fachlicheZuordnung, ⁴​projektText, ⁵​dfgVerfahren

Iterate over a range of project IDs (or all of them) and scrape the
details page for each.

## load corpora

Now we want to load all the pre-processed plain-text files. To re-use
this code, we have wrapped it in functions.

    # build data frame from  list of file names
    f.read.txt.files <- function(filenames) {
      df.output <- purrr::map_df(filenames, ~ tibble(
        text = readr::read_file(.x)) %>%
          dplyr::mutate(filename = basename(.x))
      )
      df.output %>%
        dplyr::mutate(id = stringr::str_replace(filename, '^(.+)\\.txt', '\\1'))
    }

    f.read.txt.files.from.folder <- function(path) {
      v.filenames <- list.files(path = path, pattern = "*.txt",  ignore.case = T, full.names = T)
      f.read.txt.files(v.filenames)
    }

### 1. DH conferences

    df.dhconfs.abstracts <- f.read.txt.files.from.folder(here("data/dh-conferences/12987959/txt")) 
    # Quick look at the available variables
    df.dhconfs.abstracts %>% 
      glimpse(width = 80) # width is measured in characters

### 2. DHd

### 3. DHQ articles

    df.dhq <- f.read.txt.files.from.folder(here("data/dhq/txt"))
    # Quick look at the available variables
    df.dhq %>% 
      glimpse(width = 80) # width is measured in characters

### 4. DFG projects

    load(here("data/dfg/dfg_projects.rda"))
    df.dfg <- df.dfg.projects %>%
      dplyr::rename(text = projektText) %>%
      dplyr::select(id, text)

## load tool list

    df.tools <- read_csv(here("data","tools.csv")) %>%
      dplyr::filter(term != 'Internet') # it makes sense to remove this term from the tool list as it heavily skews the resulting frequencies

    ## Rows: 300 Columns: 2
    ## ── Column specification ────────────────────────────────────────────────────────
    ## Delimiter: ","
    ## chr (2): term, variant
    ## 
    ## ℹ Use `spec()` to retrieve the full column specification for this data.
    ## ℹ Specify the column types or set `show_col_types = FALSE` to quiet this message.

# analysis

To re-use this code, we have wrapped it in functions that usually take a
dataframe/tibble as input. Note that the input tibble must contain a
column named “text”.

## functions

### frequency count

The core of our analysis is a relatively blunt string match. We iterate
over every term in our tool list, search all texts in our corpus for
matches, and count the number of texts that return at least one hit.
This aggregation by text acts as a weight against inflation of
frequencies, if a specific tool is mentioned repeatedly throughout a
given text.

    f.stringmatch.frequency <- function(df.input, list.strings) {
      df.output <- df.input %>%
        dplyr::mutate(
          term = stringr::str_extract_all(text, 
             regex(paste0("\\b", list.strings, "\\b", collapse = '|'),
                   ignore_case = FALSE)) # it might make sense to add an input variable for this choice
        ) %>%
        tidyr::unnest(term) %>%
        # step 1: group by text and term: get frequency of number of hits per term per text
        dplyr::group_by(text, term) %>%
        dplyr::summarise(freq = n()) %>%
        # step 2: group by term: get frequency of number of texts per term
        dplyr::group_by(term) %>%
        dplyr::summarise(freq = n()) %>%
        # sort by frequency
        dplyr::arrange(desc(freq))
      df.output
    }

### clean spelling variants

Our tool list contains spelling variants such as acronyms and their
expansions, for which we want to aggregate the resulting frequencies.

    # note that the input needs columns named "term" and "freq"
    # control for correct case of matches
    # match all the variants and then group by term
    f.clean.variants <- function(df.input, df.tools) {
      df.grouped <- dplyr::left_join(df.tools, df.input, by = c("variant" = "term")) %>%
        tidyr::drop_na()%>%
        dplyr::group_by(term) %>%
        dplyr::summarise(freq = sum(freq))
      df.grouped
    }

### calculate relative frequencies

In order to compare corpora, we are interested in relative frequencies.
We compute two such relative frequencies

1.  Ratio of frequencies with the highest frequency set to 1. We also
    provide this relative frequency for a basis of 100 (i.e. as
    percentage)
2.  Ratio of frequencies to the number of texts in our corpus with a
    basis of 100 (i.e. percentage)

<!-- -->

    # note that the input needs a column named "freq"
    f.relative.frequencies <- function(df.input, number.of.texts) {
      df.normalised <- df.input %>%
        # normalise frequencies: 
        dplyr::mutate(
        # 1. relative to each other
          freq.rel = freq / max(df.input$freq),
          freq.rel.100 = freq.rel * 100,
        # 2. as percentage of total number of input texts
          freq.text.100 = freq / number.of.texts * 100) %>%
        dplyr::arrange(desc(freq))
      df.normalised
    }

### combine all functions

    f.compute.frequencies <- function(df.input, df.tools){
      df.output <- f.stringmatch.frequency(df.input, df.tools$variant) %>%
        f.clean.variants(df.tools) %>%
        f.relative.frequencies(nrow(df.input))
      df.output
    }

## Analyse our corpora

The actual analysis is done by running all three functions in succession
on any of our corpora. Note that this might take a while for large
corpora.

    df.dhconfs.abstracts.tools <- f.compute.frequencies(df.dhconfs.abstracts, df.tools)

    ## `summarise()` has grouped output by 'text'. You can override using the
    ## `.groups` argument.

    df.dhq.tools <- f.compute.frequencies(df.dhq, df.tools)

    ## `summarise()` has grouped output by 'text'. You can override using the
    ## `.groups` argument.

    df.dfq.tools <- f.compute.frequencies(df.dfg, df.tools)

    ## `summarise()` has grouped output by 'text'. You can override using the
    ## `.groups` argument.

Let’s again have a brief look at the results

    head(df.dhconfs.abstracts.tools, 10)

    ## # A tibble: 10 × 5
    ##    term            freq freq.rel freq.rel.100 freq.text.100
    ##    <chr>          <int>    <dbl>        <dbl>         <dbl>
    ##  1 R                259    1            100           25   
    ##  2 TEI              155    0.598         59.8         15.0 
    ##  3 NLP              118    0.456         45.6         11.4 
    ##  4 XML              117    0.452         45.2         11.3 
    ##  5 GitHub            98    0.378         37.8          9.46
    ##  6 API               88    0.340         34.0          8.49
    ##  7 OA                77    0.297         29.7          7.43
    ##  8 ML                76    0.293         29.3          7.34
    ##  9 GIS               70    0.270         27.0          6.76
    ## 10 Topic Modeling    67    0.259         25.9          6.47

    head(df.dhq.tools, 10)

    ## # A tibble: 10 × 5
    ##    term             freq freq.rel freq.rel.100 freq.text.100
    ##    <chr>           <int>    <dbl>        <dbl>         <dbl>
    ##  1 TEI               138    1            100           32.2 
    ##  2 XML               105    0.761         76.1         24.5 
    ##  3 R                  84    0.609         60.9         19.6 
    ##  4 OA                 65    0.471         47.1         15.2 
    ##  5 distant reading    53    0.384         38.4         12.4 
    ##  6 GitHub             50    0.362         36.2         11.7 
    ##  7 API                47    0.341         34.1         11.0 
    ##  8 ML                 44    0.319         31.9         10.3 
    ##  9 GIS                43    0.312         31.2         10.0 
    ## 10 NLP                40    0.290         29.0          9.32

Save everything to file

    write.table(df.dhconfs.abstracts.tools, file = here("data", "dh-conferences", "dh-conferences-frequencies_tools-abstracts.csv"), row.names = F, quote = T, sep = ",")
    write.table(df.dhq.tools, file = here("data/dhq/dhq-frequencies_tools.csv"), row.names = F, quote = T, sep = ",")
    write.table(df.dfq.tools, file = here("data/dfg/dfg-frequencies_tools.csv"), row.names = F, quote = T, sep = ",")

## Visualise the results

A popular albeit controversial method to visualise such frequencies is a
word cloud and as always there are multiple ways for doing so in R. For
aesthetically more pleasing results, we use the popular ggplot2 library,
which operationalises “A Grammar for Graphics”.

The following function does multiple things

-   it takes a data frame with a frequency list as input

-   slices the x most frequent terms based on an input parameter x

-   builds two visualisations each based on the different relativ
    frequencies

    -   circular wordcloud
    -   a more “cloudy” approximation of a word cloud

-   adds labels, etc. based on the input

-   saves the plots in a specified output format (png or svg) to file

As we aim generating and saving multiple plots with a single function,
it makes a lot of sense to modularise the layers in this ggplot. The
plot is then composed from various layers in multiple steps, each
creating plots or layers for re-use.

    # Wordcloud with ggplot2
    # the input requires a column named "term"
    f.wordcloud.frequency <- function(input, max.values, label.text, label.source, output.device) {
      # process data: frequency list
      data.frequency <- input %>%
        #dplyr::filter(freq > 1) %>% # remove unique terms: this needs to be commented out for relative frequencies
        slice(1:max.values) %>% # limit the length of the data set
        # add some 90 degree angles to 20 % of all terms
        dplyr::mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(80, 20))) %>%
        # add some 45 degree angles: can be removed, I suppose
        dplyr::mutate(angle = -45 * sample(c(0, 1), n(), replace = TRUE, prob = c(90,10)))
      # labels, captions, other variables
      v.output.device = output.device
      v.total.values = nrow(data.frequency)
      font = "Baskerville"
      v.title = paste("The", v.total.values, "most frequent", label.text, sep = " ")
      v.caption = paste(label.source, ".\n", v.label.license, sep = "")
      # basic plot
      plot.base <- ggplot(data.frequency, aes(x = 1, y = 1, label = term)) +
        scale_y_continuous(breaks = NULL) +
        scale_x_continuous(breaks = NULL)
      # labs
      layer.labs <- labs(x = "", y = "", 
          title = v.title,
          caption = v.caption)
      layer.labs.rel.100 <- labs(subtitle = 'Normalised relative frequencies by number of texts \nMost frequent term = 100')
      layer.labs.text.100 <- labs(subtitle = 'Normalised relative frequencies by number of texts \nNumber of texts = 100')
      layer.repel.text.100 <- c(
        geom_text_repel(aes(size = freq.text.100, colour = freq.text.100),
            segment.size = 0, force = 20, max.overlaps = 500, family = font.words),
        scale_size(range = c(1.5, 30), guide = FALSE))
      layer.wordcloud.text.100 <- c(
        geom_text_wordcloud(aes(size = freq.text.100, colour = freq.text.100, angle = angle), # use the angle information
            family = font.words,
            # frequency = area or font size. If font.size, readers will get the wrong impression
            area_corr = TRUE, eccentricity = 1, # to form a circle
            rm_outside = TRUE, # if there are too many terms, the smallest ones should be removed if they cannot fit onto the canvas
            grid_margin = 0.5, seed = 43, show.legend = T),
        scale_size_area(max_size = 50) #, scale_radius(range = c(0, 30), limits = c(0, NA))
      )
      layer.wordcloud.rel.100 <- c(
        geom_text_wordcloud(aes(size = freq.rel.100, colour = freq.rel.100, angle = angle),
          family = font.words, area_corr = TRUE, eccentricity = 1, # to form a circle
          rm_outside = TRUE, grid_margin = 0.5, seed = 43, show.legend = T),
        scale_size_area(max_size = 50)
      )
      layer.repel.rel.100 <- c(
        geom_text_repel(aes(size = freq.rel.100, colour = freq.rel.100),
            segment.size = 0, force = 20, max.overlaps = 500, family = font.words),
        scale_size(range = c(1.5, 30), guide = FALSE))
      
      
      plot.base.final <- plot.base +
        layer.labs +
        scale_colour_paletteer_c("viridis::viridis") +
        guides(color = guide_colorbar("Frequency (%)", order = 1),
               size = "none")+ #guide_legend("Frequency", order = 2)) +
        theme(
          text = element_text(family = font, face = "plain"),
          plot.title = element_text(size = size.Title.Px),
          plot.subtitle = element_text(size = size.Subtitle.Px),
          plot.caption = element_text(size = size.Text.Px),
          #legend.position = c(0.84,0.01),
          #legend.position = c(0.84,1),
          legend.position = c(0.1,0.01),
          legend.justification = "bottom",
          legend.direction = "horizontal",
          legend.key = element_rect(fill = NULL),
          legend.margin = margin(0),
          panel.border = element_blank()) 
      plot.repel.text.100 <- plot.base.final +
        layer.labs.text.100 +
        layer.repel.text.100
      plot.wordcloud.text.100 <- plot.base.final +
        layer.labs.text.100 +
        layer.wordcloud.text.100
      plot.repel.rel.100 <- plot.base.final +
        layer.labs.rel.100 +
        layer.repel.rel.100
      plot.wordcloud.rel.100 <- plot.base.final +
        layer.labs.rel.100 +
        layer.wordcloud.rel.100
      # save output to file
      ggsave(plot = plot.wordcloud.text.100, filename = paste("wordcloud-text-100_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
             path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
      ggsave(plot = plot.repel.text.100, filename = paste("wordcloud-text-100-repel_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
             path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
      ggsave(plot = plot.wordcloud.rel.100, filename = paste("wordcloud-rel-100_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
             path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
      ggsave(plot = plot.repel.rel.100, filename = paste("wordcloud-rel-100-repel_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
             path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
    }

The above plotting function depends on a number of external parameters,
which are not passed into it but need to be specified before calling the
function. These set fonts, font-sizes, colours, output dimensions and
resolution, etc.

    v.label.license = "Till Grallert, CC BY-SA 4.0"
    # fonts
    font.words = "Helvetica Neue"
    # sizes
    ## in themes size is measured in px
    size.Base.Px = 9
    ## font sizes are measured in mm
    size.Base.Mm = (5/14) * size.Base.Px
    # specify text sizes
    size.Title = 2
    size.Subtitle = 1.5
    size.Text = 0.8
    ## transformation to MM and PX
    size.Title.Mm = size.Title * size.Base.Mm
    size.Subtitle.Mm = size.Subtitle * size.Base.Mm
    size.Text.Mm = size.Text * size.Base.Mm
    size.Title.Px = size.Title * size.Base.Px
    size.Subtitle.Px = size.Subtitle * size.Base.Px
    size.Text.Px = size.Text * size.Base.Px
    # variables for saving plots
    width.Plot <- 240
    height.Plot <- width.Plot
    dpi.Plot <- 600

Depending how much of the above analysis was run in the current notebook
session, we will need to load our saved data from disk

    df.dhq.tools <- read.csv(file = here("data/dhq/dhq-frequencies_tools.csv"), sep = ",")
    df.dfg.tools <- read.csv(file = here("data/dfg/dfg-frequencies_tools.csv"), sep = ",")
    df.dhconfs.abstracts.tools <-read.csv(file = here("data/dh-conferences/dh-conferences-frequencies_tools-abstracts.csv"), sep = ",")

We can now apply this visualisation to our data and plot the 50 most
frequent tools mentioned in DHQ articles like so:

    f.wordcloud.frequency(df.dhq.tools, 50, paste("tools in", nrow(df.dhq),  "articles from Digital Humanities Quarterly"), "Data: Digital Humanities Quarterly, http://digitalhumanities.org/dhq/", "png")

    ## Some words could not fit on page. They have been removed.
    ## Some words could not fit on page. They have been removed.

![This is one of the saved
visualisations](visualization/wordcloud-rel-100_tools%20in%20429%20articles%20from%20Digital%20Humanities%20Quarterly-w_50.png)

Compare this cloud to the visualisation of the 50 most frequent tools
mentioned in DH conference articles:

    f.wordcloud.frequency(df.dhconfs.abstracts.tools, 50, paste("tools in", nrow(df.dhconfs.abstracts),  "abstracts from DH conferences"), "Data: Weingart et al., 'Index of Digital Humanities Conferences Data', https://doi.org/10.1184/R1/12987959.v4", "png")

![This is one of the saved
visualisations](visualization/wordcloud-rel-100_tools%20in%201036%20abstracts%20from%20DH%20conferences-w_50.png)
