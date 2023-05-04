
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
  gather_array() # tibble with one row per tool (which is yet another JSON object)

# playground

data.ssh <- data.ssh %>%
  purrr::flatten() 
data.ssh.tools <- dplyr::bind_rows(data.ssh)

data.ssh.tools <- split(data.ssh, names(data.ssh)) %>% 
  map(dplyr::bind_rows)

data.ssh.tools <- tapply(data.ssh, 
                         names(data.ssh), 
                         dplyr::bind_rows)

df <- sapply(data.ssh$tools, function(x){
  dplyr::bind_rows(x)
})

df <- unlist(data.ssh$tools) %>%
  as_tibble()
df <- data.ssh
data.ssh <- mapply(function(df, name) {
  df$Name <- rep(name, nrow(df))
  return(df)
}, df = data.ssh, name = names(data.ssh),
SIMPLIFY = FALSE)

v.names <- names(data.ssh)
df <- data.ssh %>%
  purrr::flatten()
  
  test <-  tibble(
    tools = purrr::map(data.ssh, "tools$id")
  )
  head(test)
test <-  tibble(
    id = purrr::map(data.ssh$tools, "id"),
    expansion = purrr::map(list.input, "expansion"),
    category = purrr::map(list.input, "category")
  ) %>%
    unnest(cols = c(name, expansion, category)) %>%
    dplyr::na_if("NULL")
