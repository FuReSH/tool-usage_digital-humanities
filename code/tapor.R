library(tidyverse)
library(here)
library(jsonlite)
library(tidyjson)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

setwd(here("data", "tapor"))
# load the original JSON data from the undocumented TaPOR API
data.tapor <- f.read.json()
# we end up with a large list of lists and data frames and need the small helper to figure out its structure
f.json.types(data.tapor)
# we can now enter into the JSON
data.tools.tapor <- data.tapor %>%
  enter_object(tools) %>%
  gather_array() %>%
  spread_all() %>%
  tibble::tibble() %>%  # remove all JSON artefacts
  dplyr::rename(label = name,
                description = detail,
                id.tapor = tool_id) %>%
  dplyr::select(id.tapor, label, description, image_url, star_average) %>%
  f.clean.labels() %>%
  dplyr::arrange(label.clean)
# save data
save(data.tools.tapor, file = "tapor_tools.rda")
write.table(data.tools.tapor, file = "tapor_tools.csv", row.names = F, col.names = T, quote = T, sep = ",")

# load the same data as reconciled with Wikidata
data.tapor.wikidata <- readr::read_csv("TaPOR-Wikidata.csv") %>%
  dplyr::rename(id.tapor = tool_id,
                label = name,
                description = detail,
                wd.item = QId) %>%
  dplyr::select(id.tapor, label, description, wd.item) %>%
  tidyr::drop_na(id.tapor) %>%
  f.clean.labels() %>%
  dplyr::arrange(label.clean)
save(data.tapor.wikidata, file = "tapor_tools-wikidata.rda")
write.table(data.tapor.wikidata, file = "tapor_tools-wikidata.csv", row.names = F, col.names = T, quote = T, sep = ",")

# short names
wd.1 <- f.wikidata.properties("Q7184", "P1813")
# programmed in 
wd.2 <- f.wikidata.properties("Q106323236", "P277")
# reads file format
wd.3 <- f.wikidata.properties("Q7115951", "P1072")

f.wikidata.label("Q251", 'en')



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
