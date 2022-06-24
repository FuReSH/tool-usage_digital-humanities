# this script generates and saves term-frequency lists from the DH conferences corpus
library(tidyverse)
library(tm)
library(here)
library(hunspell)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")
# set a general theme for all ggplots
theme_set(theme_bw())

# load data: DH conference abstracts 
setwd(here("data/dh-conferences/12987959"))
df.dhconfs <- readr::read_csv("dh_conferences_works.csv")
df.dhconfs.works <- df.dhconfs %>%
  dplyr::select(work_title, work_authors, full_text, conference_year, keywords, topics, languages) %>%
  dplyr::rename(title = work_title,
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
## keywords and topics need to be split along ";"
df.test <- df.dhconfs.works %>%
  tidyr::separate(keywords.lc, into = c("k1", "k2", "k3", "k4", "k5", "k6", "k7", "k8"), sep = ";")

# save data
setwd("../")
save(df.dhconfs.works, file = "dh_conferences_works.rda")


# generate frequency lists: generic term-document-matrix
f.frequency.list <- function(input) {
  docs <- Corpus(VectorSource(input))
  # build a term-document matrix to get a frequency list
  dtm <- TermDocumentMatrix(docs, control = list(removePunctuation = TRUE, 
                                                 stopwords = FALSE,
                                                 stemming = FALSE) # stemming is too aggressive for what we want to achieve
                            )
  m <- as.matrix(dtm)
  v <- sort(rowSums(m), decreasing = TRUE)
  output <- data.frame(word = names(v),freq=v)
  output
}

df.freq.titles <- f.frequency.list(df.dhconfs.works$title.lc)
df.freq.keywords <- f.frequency.list(df.dhconfs.works$keywords.lc)
df.freq.abstracts <- f.frequency.list(df.dhconfs.works$text.lc)
save(df.freq.titles, file = "dh-conferences-frequencies_titles.rda")
save(df.freq.abstracts, file = "dh-conferences-frequencies_abstracts.rda")
save(df.freq.keywords, file = "dh-conferences-frequencies_keywords.rda")
write.table(df.freq.titles, file = "dh-conferences-frequencies_titles.csv", row.names = F, quote = T, sep = ",")
write.table(df.freq.keywords, file = "dh-conferences-frequencies_keywords.csv", row.names = F, quote = T, sep = ",")
write.table(df.freq.abstracts, file = "dh-conferences-frequencies_abstracts.csv", row.names = F, quote = T, sep = ",")

# frequency list with stemming
# PROBLEM: hunspell will not work with most accronyms
# PROBLEM: hunspell is quite slow
#df.allwords <- hunspell_parse(df.dhconfs.works$text)
#v.stems <- unlist(hunspell_stem(unlist(df.allwords)))
#df.freq.abstracts.stems <- as_tibble(table(v.stems))

f.frequency.list.2 <- function(input) {
  allwords <- hunspell_parse(input)
  stems <- unlist(hunspell_stem(unlist(allwords)))
  output <- as_tibble(table(stems)) %>%
    dplyr::rename(stem = stems,
                  freq = n) %>%
    dplyr::arrange(desc(freq))
  output
}

a1 <- f.frequency.list(df.dhconfs.works$title.lc)
a2 <- f.frequency.list.2(df.dhconfs.works$title.lc)
head(a1)
head(a2)
