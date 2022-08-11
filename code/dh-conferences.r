# this script generates and saves term-frequency lists from the DH conferences corpus
library(tidyverse)
library(here)
library(DataExplorer) # for quick exploration
library(lubridate)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

# load data
# 1. DH conferences
setwd(here("data", "dh-conferences"))
load("dh-conferences_works.rda")

# titles
df.dhconfs.titles <- df.dhconfs.works %>%
  dplyr::select(id, title, year) %>%
  dplyr::rename(text = title) %>%
  tidyr::drop_na(text) %>% 
  dplyr::arrange(year)
# abstracts
#df.dhconfs.abstracts <- df.dhconfs.works %>%
#  dplyr::select(id, text, year) %>%
#  tidyr::drop_na(text) %>%
#  dplyr::arrange(year)

# there is a problem with the abstracts: they are mostly full TEI XML files. I therefore load a folder of text files
df.dhconfs.abstracts <- f.read.txt.files.from.folder(here("data/dh-conferences/12987959/txt")) 

# some join to get years
df.dhconfs.abstracts <- df.dhconfs.abstracts %>%
  dplyr::left_join(df.dhconfs.works, by = c('id' = 'id')) %>%
  dplyr::rename(text = text.x) %>%
  dplyr::select(id, text, year) %>% # this can include more columns if needed
  dplyr::arrange(year)

df.dh2022.abstracts <- f.read.txt.files.from.folder(here("data/dh-conferences/DH2022/txt")) %>% 
  dplyr::mutate(year = parse_date_time("2022", orders = "Y")) %>%
  dplyr::select(id, text, year)
df.dhconfs.abstracts <- df.dhconfs.abstracts %>%
  add_row(df.dh2022.abstracts)
save(df.dhconfs.abstracts, file = here("data", "dh-conferences", "dh-conferences_abstracts.rda"))
#load(file = here("data", "dh-conferences", "dh-conferences_abstracts.rda"))


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

# quick exploration
summary(df.dhconfs.titles)
summary(df.dhconfs.abstracts)
plot_histogram(df.dhconfs.titles)
plot_histogram(df.dhconfs.abstracts)


# actual analysis: use the external stringmatch function
df.dhconfs.titles.tools <- f.stringmatch.frequency(df.dhconfs.titles, df.tools$variant)
df.dhconfs.abstracts.tools <- f.stringmatch.frequency(df.dhconfs.abstracts, df.tools$variant)

# control for correct case of matches: match all the variants and then group by term
df.dhconfs.titles.tools <- f.clean.variants(df.dhconfs.titles.tools, nrow(df.dhconfs.titles))
df.dhconfs.abstracts.tools <- f.clean.variants(df.dhconfs.abstracts.tools, nrow(df.dhconfs.abstracts))

setwd(here("data", "dh-conferences"))
write.table(df.dhconfs.titles.tools, file = "dh-conferences-frequencies_tools-titles.csv", row.names = F, quote = T, sep = ",")
write.table(df.dhconfs.abstracts.tools, file = "dh-conferences-frequencies_tools-abstracts.csv", row.names = F, quote = T, sep = ",")

# results for pretty printing
df.dhconfs.abstracts.tools.print <- df.dhconfs.abstracts.tools %>%
  dplyr::select(term, freq, freq.rel) %>%
  dplyr::mutate(freq.rel = round(freq.rel, 2)) %>%
  write.table(file = 'dh-conferences-frequencies_tools-abstracts_print.csv', row.names = F, quote = F, sep = ',')

# analysis: slice data into years

# wordclouds with ggplot: external function
v.label.source = "Data: Weingart et al., 'Index of Digital Humanities Conferences Data', https://doi.org/10.1184/R1/12987959.v4" # source information
v.label.abstracts.summary = paste("in ", nrow(df.dhconfs.abstracts), " DH conference paper abstracts (", min(df.dhconfs.abstracts$year), "-", max(df.dhconfs.abstracts$year), ")", sep = "")
v.label.titles.summary = paste("in ", nrow(df.dhconfs.titles), " DH conference paper titles (", min(df.dhconfs.titles$year), "-", max(df.dhconfs.titles$year), ")", sep = "")
f.wordcloud.frequency(df.dhconfs.titles.tools, 100, paste("tools", v.label.titles.summary, sep = " "), "png")
f.wordcloud.frequency(df.dhconfs.abstracts.tools, 100, paste("tools", v.label.abstracts.summary, sep = " "), "png")
f.wordcloud.frequency(df.dhconfs.abstracts.tools, 100, paste("tools", v.label.abstracts.summary, sep = " "), "svg")
f.wordcloud.frequency(df.concepts.abstracts, 100, paste("concepts", v.label.abstracts.summary, sep = " "), "svg")
f.wordcloud.frequency(df.concepts.abstracts, 100, paste("concepts", v.label.abstracts.summary, sep = " "), "png")

.label.source = "Data: Henny-Kramer et al., 'Softwarezitation in Den Digital Humanities', https://doi.org/10.5281/zenodo.5106391" # source information
f.wordcloud.frequency(df.dhd.tools, 100, "tools in DHd conference abstracts", "png")



# playground

df.test <- df.dhconfs.titles.tools %>%
  mutate(label = glue::glue("<span style='display: block; width: {sqrt(freq)}; height'>{term}</span>"))
ggplot(df.test) +
  geom_label_repel(aes(x = 1, y = 1, label = term, color = freq),
                   segment.size = 0, force = 10, max.overlaps = 500, family = font.words)
  scale_size(range = c(1.5, 40), guide = "none")
  

# playground: KWIC
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
