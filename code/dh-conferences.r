# this script generates and saves term-frequency lists from the DH conferences corpus
library(tidyverse)
library(here)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

# load data
# 1. DH conferences
setwd(here("data", "dh-conferences"))
load("dh_conferences_works.rda")

# 2. FuReSH tool list
df.tools <- read_csv(here("data","tools.csv")) %>%
  #rename(term = tool) %>%
  #dplyr::distinct(term) %>%
  # add lower case for easier joining of data frames
  dplyr::mutate(term.lc = stringr::str_to_lower(term))
save(df.tools, file = here("data/furesh-tools.rda"))
#write.table(df.tools, file = "furesh-tools.csv", row.names = F, quote = F, sep = ",")
df.concepts <- read_csv(here("data", "concepts.csv")) %>%
  rename(term = concept) %>%
  dplyr::distinct(term) %>%
  # add lower case for easier joining of data frames
  dplyr::mutate(term.lc = stringr::str_to_lower(term))
save(df.concepts, file = here("data/furesh-concepts.rda"))

# pre-process data
df.dhconfs.titles <- df.dhconfs.works %>%
  dplyr::select(title) %>%
  dplyr::rename(text = title)
df.dhconfs.abstracts <- df.dhconfs.works %>%
  dplyr::select(text)

# actual analysis: use the external stringmatch function
df.dhconfs.titles.tools <- f.stringmatch.frequency(df.dhconfs.titles, df.tools$variant)
df.dhconfs.abstracts.tools <- f.stringmatch.frequency(df.dhconfs.abstracts, df.tools$variant)

# control for correct case of matches: match all the variants and then group by term
df.dhconfs.titles.tools <- f.clean.variants(df.dhconfs.titles.tools)
df.dhconfs.abstracts.tools <- f.clean.variants(df.dhconfs.abstracts.tools)

write.table(df.dhconfs.titles.tools, file = "dh-conferences-frequencies_tools-titles.csv", row.names = F, quote = T, sep = ",")
write.table(df.dhconfs.abstracts.tools, file = "dh-conferences-frequencies_tools-abstracts.csv", row.names = F, quote = T, sep = ",")


# wordclouds with ggplot: external function
v.label.source = "Data: Weingart et al., 'Index of Digital Humanities Conferences Data', https://doi.org/10.1184/R1/12987959.v4" # source information
f.wordcloud.frequency(df.dhconfs.titles.tools, 150, "tools in DH conference paper titles", "png")
f.wordcloud.frequency(df.dhconfs.abstracts.tools, 150, "tools in DH conference abstracts", "svg")
f.wordcloud.frequency(df.dhconfs.abstracts.tools, 150, "tools in DH conference abstracts", "png")
f.wordcloud.frequency(df.concepts.abstracts, 100, "concepts in DH conference abstracts", "svg")
f.wordcloud.frequency(df.concepts.abstracts, 100, "concepts in DH conference abstracts", "png")

.label.source = "Data: Henny-Kramer et al., 'Softwarezitation in Den Digital Humanities', https://doi.org/10.5281/zenodo.5106391" # source information
f.wordcloud.frequency(df.dhd.tools, 100, "tools in DHd conference abstracts", "png")

# playground
f.stringmatch <- function(df.input, list.strings) {
  df.output <- df.input %>%
    dplyr::mutate(
      term = str_extract_all(text, 
                             regex(paste0("\\b", list.strings, "\\b", collapse = '|'),
                                   ignore_case = FALSE)), # it might make sense to add an input variable for this choice
      KWIC = str_extract_all(text, 
                             regex(paste0("\\w+\\b", list.strings, "\\b\\w+", collapse = '|'),
                                   ignore_case = FALSE))
    )%>%
      tidyr::unnest(cols = c("term"))
      df.output
}

a <- slice(df.dhconfs.abstracts)
a <- f.stringmatch(df.dhconfs.titles, df.tools$term)
b <- slice_head(a) %>%
  tidyr::unnest_longer(KWIC)
a[[1,3]]
  