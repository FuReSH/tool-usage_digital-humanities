library(tidyverse)
library(here)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

# load data
# FuReSH: load folders with text files
setwd(here("data/txt"))
# read file names
v.files.furesh.de <- list.files(path = "de", pattern = "*.txt",  ignore.case = T, full.names = T)
df.furesh.de <- f.read.txt.files(v.files.furesh.de)

# NFDI4Memory: csv file
setwd(here("data/nfdi4memory"))
df.4memory <- read_delim("problem-stories_nfdi_anonym.csv", delim = ";") %>%
  dplyr::mutate(id = Nr.,
                title = Titel,
                text = Story) %>%
  dplyr::select(id, title, text) %>%
  tidyr::drop_na(text)

# DHQ articles
setwd(here("data/dhq"))
v.files.dhq <- list.files(path = "txt", pattern = "*.txt",  ignore.case = T, full.names = T)
df.dhq <- f.read.txt.files(v.files.dhq)

# DFG GEPRIS
setwd(here("data/dfg"))
load("dfg_projects.rda")
df.dfg <- df.dfg.projects %>%
  dplyr::rename(text = projektText) %>%
  dplyr::select(id, text)

# load tool list
load(file = here("data/furesh-tools.rda"))
df.tools <- df.tools %>%
  dplyr::filter(term != 'Internet')
df.tools.yml <- f.read.yaml.furesh(here("data/tools.yml")) 


# run frequency analysis
df.4memory.tools <- f.stringmatch.frequency(df.4memory, df.tools$variant)
df.4memory.tools <- f.clean.variants(df.4memory.tools, nrow(df.4memory))
write.table(df.4memory.tools, file = here("data/nfdi4memory/4memory-frequencies_tools.csv"), row.names = F, quote = T, sep = ",")

df.dhq.tools <- f.stringmatch.frequency(df.dhq, df.tools$variant)
df.dhq.tools <- f.clean.variants(df.dhq.tools, nrow(df.dhq))
write.table(df.dhq.tools, file = here("data/dhq/dhq-frequencies_tools.csv"), row.names = F, quote = T, sep = ",")

df.dfg.tools <- f.stringmatch.frequency(df.dfg, df.tools$variant)
df.dfg.tools <- f.clean.variants(df.dfg.tools, nrow(df.dfg))
write.table(df.dfg.tools, file = here("data/dfg/dfg-frequencies_tools.csv"), row.names = F, quote = T, sep = ",")

# wordcloud
v.label.source = "Data: NFDI4Memory"
f.wordcloud.frequency(df.4memory.tools, 100, "tools in NFDI4Memory user stories", "png")
v.label.source = "Data: Digital Humanities Quarterly, http://digitalhumanities.org/dhq/"
f.wordcloud.frequency(df.dhq.tools, 100, paste("tools in", nrow(df.dhq),  "articles from Digital Humanities Quarterly"), "png")
f.wordcloud.frequency(df.dhq.tools, 100, paste("tools in", nrow(df.dhq),  "articles from Digital Humanities Quarterly"), "svg")

v.label.source = "Data: DFG GEPRIS"
v.label.title = paste("tools in ", nrow(df.dfg),  " project descriptions from DFG GEPRIS (", min(df.dfg.projects$onset, na.rm = T), "-", max(df.dfg.projects$terminus, na.rm = T), ")", sep = '')
f.wordcloud.frequency(df.dfg.tools, 100, v.label.title, "png")
f.wordcloud.frequency(df.dfg.tools, 100, v.label.title, "svg")
