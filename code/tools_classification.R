# script to compile various tool lists into a single list with tools, their IDs
# and TaDiRAH classification
library(dplyr)
library(tibble)
library(readr)
library(stringr)
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

# load the full SSH tool list
load("ssh-open-marketplace/ssh.rda") 
## df with mapping from SSH to TAPoR
data.ssh %>%
  dplyr::mutate(tapor.id = ifelse(source.label == "TAPoR", sourceItemId, NA)) %>% # include TAPoR Id
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                ssh.desc = description) %>%
  dplyr::mutate(ssh.label = str_replace(ssh.label, '^\\s+', '')) %>%
  dplyr::select(ssh.id, ssh.label, ssh.desc, tapor.id) %>%
  dplyr::distinct() -> df.tools.ssh.tapor
remove(data.ssh)

# SSH Open Marketplace with TaDiRAH classification
readr::read_csv("ssh-open-marketplace/ssh_tools-classification.csv") %>%
  tibble::as_tibble() %>%
  dplyr::filter(concept.vocabulary.code == "tadirah2") %>%
  dplyr::rename(ssh.id = persistentId,
                tadirah.id = concept.code) %>%
  dplyr::select(ssh.id, tadirah.id) %>%
  dplyr::distinct() -> df.tools.ssh.tadirah

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
## join SSH and TAPoR
full_join(df.tools.ssh.tapor, df.tools.tapor.wd) %>%
  # add TaDiRAH
  left_join(df.tools.ssh.tadirah) %>%
  # add Wikidata items for TaDiRAH
  left_join(df.tadirah.wd, by = c("tadirah.id")) %>%
  dplyr:: rename(wd.item = wd.item.x,
                 wd.item.tadirah = wd.item.y,
                 wd.label.tadirah = wd.label) -> df.tools.classification.wd

# reduced data set
df.tools.classification.wd %>%
  dplyr::select(ssh.id, ssh.label, tapor.id, wd.item, wd.item.tadirah, tadirah.uri) -> df.tools.classification.wd.basic
# save results
save(df.tools.classification.wd, file = "tools_tadirah-wd.rda")
write.table(df.tools.classification.wd, file = "tools_tadirah-wd.csv", sep = ",", quote = T)
write.table(df.tools.classification.wd.basic, file = "tools_tadirah-wd_basic.csv", sep = ",", quote = T)


