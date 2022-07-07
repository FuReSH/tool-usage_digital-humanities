library(tidyverse)
library(tidytext)
library(RWeka) # tokenizer
library(tm)
library(ngram)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

# load data
# 1. DH conferences
setwd(here("data", "dh-conferences"))
load("dh-conferences_abstracts.rda")

# ngrams with various packages
# tidytext
# wrapper function: the input must have a column named "text"
f.ngram.tidytext <- function(df.input, n) (
  tidytext::unnest_tokens(df.dhconfs.abstracts, bigram, text,
                          token = "ngrams", n = n)
)
df.tidytext <- f.ngram.tidytext(df.dhconfs.abstracts, 3)

f.ngram.frequency <- function(df.input, n){
  df.freq <- df.input %>% 
    tidytext::unnest_ngrams(output = ngram, input = text, format = "text",
      n = n, to_lower = TRUE, # converting everything to lower might not an option due to the use of camel case 
      drop = TRUE) %>%
    # step 1: group by text and term: get frequency of number of hits per term per text
    dplyr::group_by(id, ngram) %>%
    dplyr::summarise(freq = n()) %>%
    # step 2: group by term: get frequency of number of texts per term
    dplyr::group_by(ngram) %>%
    dplyr::summarise(freq = n()) %>%
    dplyr::arrange(desc(freq))
  # note: for absolute frequencies `dplyr::count(id, ngram, sort = TRUE)` is much simpler
  # remove stopwords: based on "Text Mining with R"
  df.clean <- df.freq %>%
    {if(n == 2) tidyr::separate(., ngram, c("word1", "word2"), sep = " ") else .} %>%
    {if(n == 3) tidyr::separate(., ngram, c("word1", "word2", "word3"), sep = " ") else .} %>% 
    dplyr::filter(!word1 %in% stop_words$word) %>%
    dplyr::filter(!word2 %in% stop_words$word) %>%
    {if(n == 3) dplyr::filter(., !word3 %in% stop_words$word) else .} %>%
    tidyr::drop_na() %>%
    {if(n == 2) tidyr::unite(., ngram, word1, word2, sep = " ") else . } %>%
    {if(n == 3) tidyr::unite(., ngram, word1, word2, word3, sep = " ") else .} %>%
    tidyr::drop_na() # this line is nonsensical, but needed for the conditions above to work
  df.clean
}
df.dhconfs.abstracts.bigram <- f.ngram.frequency(df.dhconfs.abstracts, 2)
df.dhconfs.abstracts.trigram <- f.ngram.frequency(df.dhconfs.abstracts, 3)

#  ngram library (written in C)
# wrapper function: input is a tibble column. 
# Note that the function will throw an error if an input row is shorter than n
f.ngram.ngram <- function(input, n) {
  ngram <- ngram(input, n = n, sep = " ,.:;-?!")
  df.output <- tibble(get.phrasetable(ngram))
  df.output
}
df.dhconfs.abstracts.ngram.2 <- f.ngram.ngram(df.dhconfs.abstracts$text, n = 2)

# tm and RWeka
# the RWeka tokenizer is quite slow compared to the ngram library
f.tokenizer.bigram <- function(input) {
  corpus <- Corpus(VectorSource(input))
  NGramTokenizer(corpus, Weka_control(min = 2, max = 3))
}

list.test <- f.tokenizer.bigram(df.dhq$text)
tdm <- TermDocumentMatrix(df.dhq.tools, control = list(tokenize = f.tokenizer.bigram()))


