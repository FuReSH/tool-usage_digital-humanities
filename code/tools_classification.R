# script to compile various tool lists into a single list with tools, their IDs
# and TaDiRAH classification
library(dplyr)
library(tibble)
library(readr)
library(here)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
#source(here("code", "functions.r"))
# load data
setwd(here("data"))
# TaDiRAH with wikidata links
df.tadirah.wd <- read_csv("tadirah/activities_tadirah-wikidata.csv") %>%
  tibble::as_tibble() %>%
  dplyr::rename(tadirah.uri = subject,
                wd.label = label) %>%
  # remove all QIds that have been deleted from Wikidata: this has become OBSOLETE
  # dplyr::mutate(wd.item = ifelse(wd.deleted == T, NA, wd.item)) %>%
  dplyr::select(tadirah.id, tadirah.uri, wd.item, wd.label)

# SSH Open Marketplace with TaDiRAH classification
readr::read_csv("ssh-open-marketplace/ssh_tools-classification.csv") %>%
  tibble::as_tibble() %>%
  dplyr::filter(concept.vocabulary.code == "tadirah2") %>%
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                tadirah.id = concept.code,
                tadirah.uri = concept.uri) %>%
  dplyr::select(ssh.id, ssh.label,tadirah.id, tadirah.uri) %>%
  dplyr::distinct() -> df.tools.ssh.tadirah

# Mapping between SSH and TAPoR
readr::read_csv("ssh-open-marketplace/ssh_tools-classification.csv") %>%
  tibble::as_tibble() %>%
  dplyr::filter(source.label == "TAPoR") %>%
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                tapor.id = sourceItemId) %>%
  dplyr::select(ssh.id, ssh.label,tapor.id) %>%
  dplyr::distinct() -> df.tools.ssh.tapor

# df with mapping from TAPoR to Wikidata
load("tapor/tapor_tools-wikidata.rda")
df.tools.tapor.wd <- data.tapor.wikidata %>%
  dplyr::rename(tapor.id = id.tapor,
                tapor.label = label,
                tapor.desc = description) %>%
  dplyr::select(!label.clean) %>%
  dplyr::mutate(tapor.id = as.character(tapor.id))
remove(data.tapor.wikidata)

# join tool lists
## SSH tools and TaDiRAH classification on Wikidata
df.tools.classification.wd <- full_join(df.tools.ssh.tadirah, df.tadirah.wd) %>%
  dplyr::rename(wd.tadirahid = wd.item) %>%
  # add tapor IDs
  left_join(df.tools.ssh.tapor) %>%
  # add Wikidata QIds based on tapor IDs
  left_join(df.tools.tapor.wd)

df.tools.classification.wd %>%
  dplyr::select(ssh.id, ssh.label, tapor.id, wd.item, wd.tadirahid, tadirah.uri) -> df.tools.classification.wd.basic
# save results
save(df.tools.classification.wd, file = "tools_tadirah-wd.rda")
write.table(df.tools.classification.wd, file = "tools_tadirah-wd.csv")
write.table(df.tools.classification.wd.basic, file = "tools_tadirah-wd_basic.csv")
