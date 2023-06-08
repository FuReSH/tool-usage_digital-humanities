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
  dplyr::select(tadirah.id, tadirah.uri, wd.item) -> df.tools.tadirah.wd

# SSH Open Marketplace with TaDiRAH classification
read_csv("ssh-open-marketplace/ssh_tools-classification.csv") %>%
  tibble::as_tibble() %>%
  dplyr::filter(concept.vocabulary.code == "tadirah2") %>%
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                tadirah.id = concept.code,
                tadirah.uri = concept.uri) %>%
  dplyr::select(ssh.id, ssh.label,tadirah.id, tadirah.uri) %>%
  dplyr::distinct() -> df.tools.ssh.tadirah

# load the full SSH tool list
load("ssh-open-marketplace/ssh.rda") 
## df with mapping from SSH to TAPoR
df.ssh %>%
  tibble::as_tibble() %>%
  dplyr::mutate(tapor.id = ifelse(source.label == "TAPoR", sourceItemId, NA)) %>% # include TAPoR Id
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                ssh.desc = description) %>%
  dplyr::mutate(ssh.label = str_replace(ssh.label, '^\\s+', '')) %>%
  dplyr::select(ssh.id, ssh.label, ssh.desc, tapor.id)-> df.tools.ssh.description
remove(df.ssh)

# clean the labels, which contain a lot of information, such as accronyms etc.
# function to apply a regex search and replace on the ssh.label field
f.get.abbr <- function(df.input, v.regex, min.length){
  df.input %>%
    dplyr::mutate(ssh.label.abbr = ifelse(is.na(ssh.label.abbr) == T,
                                          ifelse(str_detect(ssh.label, v.regex) == T,
                                                 str_replace_all(ssh.label, v.regex, '\\1'), 
                                                 NA),
                                          ssh.label.abbr),
                  ssh.label.abbr = ifelse(str_length(ssh.label.abbr) >= min.length,
                                          ssh.label.abbr,
                                          NA)) 
}
df.ssh.labels <- df.tools.ssh.description %>%
  dplyr::mutate(ssh.label.abbr = NA) %>%
  dplyr::select(ssh.id, ssh.label, ssh.label.abbr, ssh.desc, tapor.id)
v.regex.1 = c('^.*\\((\\w{2,})\\).*$') # find all single words in parentheses
v.regex.2  = c('^.*\\b([A-Z]{3,})\\b.*$') # find all words in uppercase and min 3 letters long
v.regex.3 = c('^.*?(([A-Z]+[a-z]*){2,}).*?$') # camel case
v.regex.4 =c('^.*?([A-z]+\\d+[A-z]+).*?$') # character strings with numbers somewhere in between
df.ssh.labels %>%
  f.get.abbr(v.regex.4, 4) %>%
  f.get.abbr(v.regex.3, 3) %>%
  f.get.abbr(v.regex.2, 3) %>%
  f.get.abbr(v.regex.1, 3) -> df.ssh.labels # this is only for testing. ultimately results can be directly written back to the source
df.ssh.labels -> df.tools.ssh.description

# df with mapping from TAPoR to Wikidata
load("tapor/tapor_tools-wikidata.rda")
df.tapor.wikidata %>%
  dplyr::rename(tapor.id = id.tapor,
                tapor.label = label,
                tapor.desc = description) %>%
  dplyr::select(!label.clean) %>%
  dplyr::mutate(tapor.id = as.character(tapor.id)) -> df.tools.tapor.wd
remove(df.tapor.wikidata)

# join tool lists
full_join(df.tools.ssh.tadirah, df.tools.tadirah.wd) %>%
  dplyr::rename(wd.tadirahid = wd.item) -> df.tools.classification.wd
# all tool information without TaDiRAH
full_join(df.tools.ssh.description, df.tools.tapor.wd) -> df.tools.wd
# get short names for those tools already reconciled with Wikidata
df.tools.wd %>%
  dplyr::mutate(wd.label = ifelse(is.na(wd.item) == T,
                                  NA,
                                  f.wikidata.properties(wd.item, "P1813"))) -> df.tools.wd

# add everything together
left_join(df.tools.wd, df.tools.classification.wd) %>%
  dplyr::select(ssh.id, tapor.id, ssh.label, ssh.label.abbr, tapor.label, ssh.desc, tapor.desc, tadirah.id, tadirah.uri, wd.tadirahid) -> df.tools.everything

# save joined dfs
save(df.tools.wd, file = "tools_ssh-tapor-wd.rda")
write.table(df.tools.wd, file = "tools_ssh-tapor-wd.csv", row.names = F, sep = ",")
save(df.tools.classification.wd, file = "tools_tadirah-wd.rda")
save(df.tools.everything, file = "tools_ssh-tapor-wd-tadirah.rda")
write.table(df.tools.everything, file = "tools_ssh-tapor-wd-tadirah.csv", row.names = F, sep = ",")


