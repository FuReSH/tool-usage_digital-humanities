library(tidyverse)
library(here)
library(jsonlite)
library(tidyjson)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

setwd(here("data", "ssh-open-marketplace"))

data.ssh.json <- f.read.json(here("data", "ssh-open-marketplace"))
# we end up with a large list of lists and data frames and need the small helper to figure out its structure
f.json.types(data.ssh.json)
# we can now enter into the JSON
data.ssh.tools <- data.ssh.json %>%
  enter_object(tools) %>%
  gather_array() %>%
  spread_all()
remove(data.ssh.json)

data.ssh.contributors <- data.ssh.tools %>% 
  group_by(informationContributor.id , informationContributor.username) %>%
  summarise(no.tools = n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(desc(no.tools))

data.ssh.sources <- data.ssh.tools %>%
  group_by(source.id, source.label) %>%
  summarise(no.tools = n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(desc(no.tools))

data.ssh.process <- data.ssh.tools %>%
  #dplyr::select(id, lastInfoUpdate) %>%
  dplyr::mutate(date = lubridate::as_date(lastInfoUpdate)) %>%
  group_by(date, informationContributor.id, informationContributor.username,source.id, source.label) %>%
  summarise(no.tools = n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(date)


# save data
save(data.ssh.tools, file = "ssh_tools.rda")
write.table(data.ssh.contributors, file = "ssh_contributors.csv", row.names = F, col.names = T, quote = T, sep = ",")
write.table(data.ssh.sources, file = "ssh_sources.csv", row.names = F, col.names = T, quote = T, sep = ",")
write.table(data.ssh.process, file = "ssh_ingestion-process.csv", row.names = F, col.names = T, quote = T, sep = ",")
  
write.table(as_tibble(data.ssh.tools), file = "ssh_tools.csv", row.names = F, col.names = T, quote = T, sep = ",")

# TaDiRAH classification
load("ssh_tools.rda")
f.json.types(data.ssh.tools)
data.ssh.tools %>%
  # TaDiRAH classification is part of the properties array
  enter_object(properties) %>%
  gather_array() %>%
  spread_all() %>%
  # filter for TaDiRAH classifications
  dplyr::filter(concept.vocabulary.code == "tadirah2") %>%
  dplyr::select(
    id, label, persistentId, source.label, sourceItemId, source.urlTemplate, concept.vocabulary.code, concept.code, concept.uri
  ) %>%
  as_tibble() -> 
  data.ssh.tools.classification
write.table(data.ssh.tools.classification, file = "ssh_tools-classification.csv", row.names = F, col.names = T, quote = T, sep = ",")

data.ssh.classification <- data.ssh.tools.classification %>%
  group_by(concept.code)  %>%
  summarise(no.tools = n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(desc(no.tools))
write.table(data.ssh.classification, file = "ssh_classification.csv", row.names = F, col.names = T, quote = T, sep = ",")

# plot as word cloud
v.label.source = "SSH Open Marketplace API"
data.input <- data.ssh.classification %>%
  rename(term = concept.code, freq = no.tools) %>%
  mutate(freq.text.100 = freq / max(freq) * 100, freq.rel.100 = freq.text.100)
f.wordcloud.frequency(data.input, 100, 'TaDiRAH concepts in SSH Open Marketplace', 'png')
f.wordcloud.frequency(data.input, 50, 'TaDiRAH concepts in SSH Open Marketplace', 'png')

# external IDs 
data.ssh.tools %>%
  enter_object(externalIds) %>%
  gather_array() %>%
  spread_all() %>%
  dplyr::select(
    id, label, persistentId, identifierService.code, identifier, identifierService.urlTemplate
  ) %>%
  as_tibble() -> 
  data.ssh.tools.externalIds
write.table(data.ssh.tools.externalIds, file = "ssh_tools-authorities.csv", row.names = F, col.names = T, quote = T, sep = ",")

data.ssh.tools.externalIds %>%
  group_by(identifierService.code)  %>%
  summarise(no.tools = n()) %>%
  dplyr::ungroup() %>%
  dplyr::arrange(desc(no.tools)) -> 
  data.ssh.externalIds
write.table(data.ssh.externalIds, file = "ssh_authorities.csv", row.names = F, col.names = T, quote = T, sep = ",")

# 2. make API calls to `https://marketplace-api.sshopencloud.eu/api/tools-services/{persistentId}`
v.url.base = "https://marketplace-api.sshopencloud.eu/api/tools-services/"
v.url = paste0(v.url.base, data.ssh.tools.sources$persistentId[1])
tool.json <- fromJSON(v.url)
tool.json %>% spread_all()
