# this script generates and saves term-frequency lists from the DH conferences corpus
library(tidyverse)
library(here)
library(DataExplorer) # for quick exploration
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

# load data
# 1. DH conferences
setwd(here("data/dh-conferences/12987959"))
df.dhconfs <- readr::read_csv("dh_conferences_works.csv")
df.dhconfs.works <- df.dhconfs %>%
  dplyr::select(work_id, work_title, work_authors, full_text, conference_year, keywords, topics, languages) %>%
  dplyr::rename(id = work_id,
                title = work_title,
                text = full_text,
                authors = work_authors,
                year = conference_year)
rm(df.dhconfs)

# processing cleaning
## lower case
df.dhconfs.works <- df.dhconfs.works %>%
  dplyr::mutate(title.lc = stringr::str_to_lower(title),
                text.lc = stringr::str_to_lower(text),
                keywords.lc = stringr::str_to_lower(keywords)
  )

# save data
setwd(here("data/dh-conferences/"))
save(df.dhconfs.works, file = "dh_conferences_works.rda")

# there is a problem with the abstracts: they are mostly full TEI XML files, which need to be parsed
# small tibble with abstracts only
df.dhconfs.abstracts <- df.dhconfs.works %>%
  dplyr::select(id, text, year) %>%
  tidyr::drop_na(text) %>%
  dplyr::arrange(year)

# write each abstract to a file for further processing with XSLT
setwd(here("data/dh-conferences/12987959/tei/"))
lapply(seq_len(nrow(df.dhconfs.abstracts)), function(i) 
  write.table(df.dhconfs.abstracts$text[i], file = paste0(df.dhconfs.abstracts$id[i], '.xml'), 
            row.names = FALSE, col.names = F, quote=FALSE))
