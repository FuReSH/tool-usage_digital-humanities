# script to process our various tool lists 
library(tidyverse)
library(here)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))
# load data
setwd(here("data"))
# TaDiRAH with wikidata links
read_csv("tadirah/tadirah-wikidata.csv") %>%
  tibble::as_tibble() %>%
  dplyr::rename(tadirah.uri = subject,
                tadirah.id = label) %>%
  # remove all QIds that have been deleted from the Wikidata
  dplyr::mutate(wd.item = ifelse(wd.deleted == T, NA, wd.item)) %>%
  dplyr::select(tadirah.id, tadirah.uri, wd.item) -> data.tools.tadirah.wd

# SSH Open Marketplace with TaDiRAH classification
read_csv("ssh-open-marketplace/ssh_tools-classification.csv") %>%
  tibble::as_tibble() %>%
  dplyr::filter(concept.vocabulary.code == "tadirah2") %>%
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                tadirah.id = concept.code,
                tadirah.uri = concept.uri) %>%
  dplyr::select(ssh.id, ssh.label,tadirah.id, tadirah.uri) %>%
  dplyr::distinct() -> data.tools.ssh.tadirah

# load the full SSH tool list
load("ssh-open-marketplace/ssh.rda") 
## df with mapping from SSH to TAPoR
data.ssh %>%
  dplyr::select(persistentId, description, sourceItemId, source.label) %>% # include TAPoR Id
  tibble::as_tibble() %>%
  dplyr::mutate(tapor.id = ifelse(source.label == "TAPoR", sourceItemId, NA)) %>%
  dplyr::rename(ssh.id = persistentId,
                ssh.desc = description) %>%
  dplyr::select(ssh.id, ssh.desc, tapor.id)-> data.tools.ssh.description
remove(data.ssh)

# df with mapping from TAPoR to Wikidata
load("tapor/tapor_tools-wikidata.rda")
data.tapor.wikidata %>%
  dplyr::rename(tapor.id = id.tapor,
                tapor.label = label,
                tapor.description = description) %>%
  dplyr::select(!label.clean) %>%
  dplyr::mutate(tapor.id = as.character(tapor.id)) -> data.tools.tapor.wd
remove(data.tapor.wikidata)

# join tool lists
full_join(data.tools.ssh.tadirah, data.tools.tadirah.wd) %>%
  dplyr::rename(wd.tadirahid = wd.item) -> data.tools.classification.wd

full_join(data.tools.ssh.description, data.tools.tapor.wd) -> data.tools.wd

# save joined dfs
save(data.tools.wd, file = "tools_ssh-tapor-wd.rda")
save(data.tools.classification.wd, file = "tools_tadirah-wd.rda")
