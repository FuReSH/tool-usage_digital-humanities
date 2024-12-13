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

# load the full SSH tool list
load("ssh-open-marketplace/ssh.rda") 
## df with mapping from SSH to TAPoR
df.tools.ssh.description <- data.ssh %>%
  tibble::as_tibble() %>%
  dplyr::mutate(tapor.id = ifelse(source.label == "TAPoR", sourceItemId, NA)) %>% # include TAPoR Id
  dplyr::rename(ssh.id = persistentId,
                ssh.label = label,
                ssh.desc = description) %>%
  dplyr::mutate(ssh.label = str_replace(ssh.label, '^\\s+', '')) %>%
  dplyr::select(ssh.id, ssh.label, ssh.desc, tapor.id)
remove(data.ssh)

# clean the labels, which contain a lot of information, such as acronyms etc.
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

# all tool information without TaDiRAH
full_join(df.tools.ssh.description, df.tools.tapor.wd) -> df.tools.wd
# get short names for those tools already reconciled with Wikidata
df.tools.wd %>%
  dplyr::mutate(wd.label = ifelse(is.na(wd.item) == T,
                                  NA,
                                  f.wikidata.properties(wd.item, "P1813"))) -> df.tools.wd

# add everything together
left_join(df.tools.wd, df.tools.classification.wd) %>%
  dplyr::select(ssh.id, tapor.id, wd.item, ssh.label, ssh.label.abbr, tapor.label, ssh.desc, tapor.desc, tadirah.id, tadirah.uri, wd.tadirahid) -> df.tools.everything

# data sets for reconciliation of tools on wikidata
df.wd.reconcile <- df.tools.everything %>%
  tidyr::drop_na(wd.tadirahid, wd.item) %>%
  dplyr::select(wd.item, tapor.id, ssh.id, wd.tadirahid, tadirah.id)


# save joined dfs
save(df.tools.wd, file = "tools_ssh-tapor-wd.rda")
write.table(df.tools.wd, file = "tools_ssh-tapor-wd.csv", row.names = F, sep = ",")
save(df.tools.classification.wd, file = "tools_tadirah-wd.rda")
save(df.tools.everything, file = "tools_ssh-tapor-wd-tadirah.rda")
write.table(df.tools.everything, file = "tools_ssh-tapor-wd-tadirah.csv", row.names = F, sep = ",")
save(df.wd.reconcile, file = "tools_ssh-tapor-wd-tadirah_basic.rda")
write.table(df.wd.reconcile, file = "tools_ssh-tapor-wd-tadirah_basic.csv", row.names = F, sep = ",")

# playground
setwd(here('data'))

load(file = "tools_ssh-tapor-wd-tadirah.rda")
load(file = "tools_ssh-tapor-wd.rda")

# compile a list of tool names
df.tools.everything %>%
  distinct(ssh.id, ssh.label) %>%
  drop_na() %>%
  rename(term = ssh.label) -> temp.1
df.tools.everything %>%
  distinct(ssh.id, ssh.label.abbr) %>%
  drop_na() %>%
  rename(term = ssh.label.abbr) -> temp.2
df.tools.everything %>%
  distinct(ssh.id, tapor.label) %>%
  drop_na() %>%
  rename(term = tapor.label) -> temp.3

bind_rows(temp.1, temp.2, temp.3) %>%
  distinct(ssh.id, term) %>%
  mutate(id = ssh.id)-> df.tools.ssh.names


# wikidata
# - has use P31
# - short name P1813
f.wikidata.properties('Q2115', 'P1813')
f.wikidata.properties('Q2115', 'P31')
f.wikidata.properties('Q2115', 'P2561')
f.wikidata.properties('Q2115', 'P571')
f.wikidata.properties('Q2115', 'P50')

df.test <- df.tools.wd %>%
  dplyr::mutate(wd.short.name = if (is.na(wd.item) == T) {NA} else {f.wikidata.properties(wd.item, 'P1813')}
  )  
df.test <- df.tools.wd %>%
  dplyr::mutate(wd.short.name = if_else(is.na(wd.item) == F,
                                        f.wikidata.properties(wd.item, 'P1813'),
                                        NA)
  )  

dplyr::mutate(wd.short.name = case_when(str_starts(wd.item,'Q\\d+') ~ f.wikidata.properties(wd.item, 'P1813')))

df.tools.wd.properties <- df.tools.wd %>%
  dplyr::select(wd.item) %>%
  dplyr::distinct() %>%
  drop_na() %>%
  # dplyr::filter(is.na(wd.item) == F)# %>%
  dplyr::mutate(wd.p1813 = f.wikidata.properties(wd.item, 'P1813'))

df.tools.wd.properties <- df.tools.wd.properties %>%
  dplyr::mutate(wd.p2561 = f.wikidata.properties(wd.item, 'P2561'))

f.wikidata.properties('Q1031755', 'P856')
