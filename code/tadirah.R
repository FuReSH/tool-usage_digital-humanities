library(tidyverse)
library(here)
library(jsonlite)
library(tidyjson)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

setwd(here("data", "tadirah"))
# load the original JSON data from the undocumented TaPOR API
data.tadirah <- f.read.json()
# we end up with a large list of lists and data frames and need the small helper to figure out its structure
f.json.types(data.tadirah[[1]])

# read CSV of Open Refine export
data.tadirah.wd <- read_csv("tadirah-wikidata.csv")
# quickly fix values in the wd.deleted column
data.tadirah.wd %>%
  dplyr::mutate(wd.deleted = ifelse(!is.na(wd.item), # check if an item has a QId
                                    ifelse(is.na(wd.deleted), # check if the item was deleted
                                           FALSE, TRUE),
                                    NA)
                ) -> data.tadirah.wd
write.csv(data.tadirah.wd, file = "tadirah-wikidata.csv", row.names = F)
