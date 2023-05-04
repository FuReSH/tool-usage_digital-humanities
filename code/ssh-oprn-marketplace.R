
library(tidyverse)
library(here)
library(jsonlite)
library(tidyjson)
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")

# load functions and variables/parameters
source(here("code", "functions.r"))

setwd(here("data", "ssh-open-marketplace"))

# read a folder of json files
f.read.json <- function(folder) {
  v.filenames <- list.files(pattern="*.json", full.names=TRUE)
  df.json <- lapply(v.filenames, function(x) {
      jsonlite::read_json(x, simplifyVector = F, flatten = F)
    })
  # output is a list of lists and data frames
  df.json
}

# we end up with a large list of lists and data frames and I cannot figure out how to bind all the relevant data frames together
data.ssh.json <- f.read.json(here("data", "ssh-open-marketplace"))

data.ssh.tools <- data.ssh.json %>%
  as.tbl_json() %>%
  gather_object() %>% 
  filter(name == "tools") %>% 
  gather_array() %>% # tibble with one row per tool (which is yet another JSON object)
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

# save data
write.table(data.ssh.contributors, file = "ssh_contributors.csv", row.names = F, col.names = T, quote = T, sep = ",")
write.table(data.ssh.sources, file = "ssh_sources.csv", row.names = F, col.names = T, quote = T, sep = ",")
save(data.ssh.tools, file = "ssh_tools.rda")
  
write.table(data.ssh.tools, file = "ssh_tools.csv", row.names = F, col.names = T, quote = T, sep = ",")