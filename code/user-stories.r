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
# build data frame from files
df.furesh.de <- map_df(v.files.furesh.de, ~ tibble(
  text = read_file(.x)) %>%
    mutate(filename = basename(.x))
)

# NFDI4Memory: csv file
setwd(here("data/nfdi4memory"))
df.4memory <- read_delim("problem-stories_nfdi_anonym.csv", delim = ";") %>%
  dplyr::mutate(id = Nr.,
                title = Titel,
                text = Story) %>%
  dplyr::select(id, title, text) %>%
  tidyr::drop_na(text)

# load tool list
load(file = here("data/furesh-tools.rda"))

# run frequency analysis
df.4memory.tools <- f.stringmatch.frequency(df.4memory, df.tools$variant)
df.4memory.tools <- f.clean.variants(df.4memory.tools)

# wordcloud
v.label.source = "Data: NFDI4Memory"
f.wordcloud.frequency(df.4memory.tools, 100, "tools in NFDI4Memory user stories", "png")
