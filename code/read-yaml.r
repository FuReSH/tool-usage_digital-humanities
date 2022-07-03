# short script to demonstrate how to read and write YAML
# load libraries
library(tidyverse)
library(here)
library(yaml)

setwd(here("data"))
test.yaml.1 <- read_yaml(file = "tools.yml") # this returns a list of lists
test.yaml.2 <- read_yaml(file = "tools.yml", handlers = list(map = function(x) { as.data.frame(x) })) # this returns a list of dataframes

test.yaml.2[[2]]
test.yaml.1[[2]]

# convert list of lists into tibble of lists
# knowing the key names from the input yaml, one can use the following
test.yaml.3 <- tibble(
  name = purrr::map(test.yaml.1, "name"),
  expansion = purrr::map(test.yaml.1, "expansion")
)

# write everything to a function
f.read.yaml.furesh <- function(filename) {
  list.input <- read_yaml(file = filename, readLines.warn = FALSE)
  df.input <- tibble(
    name = purrr::map(list.input, "name"),
    expansion = purrr::map(list.input, "expansion"),
    category = purrr::map(list.input, "category")
  ) %>%
    unnest(cols = c(name, expansion, category))
  df.input
}

test.yaml.4 <- f.read.yaml.furesh("tools.yml")

# convert lists in columns to single values:
# mapping, hoisting etc. works only if the input is already a tibble/ dataframe
test.yaml.3 %>%
  tidyr::unnest(cols = c(name, expansion))
test.yaml.3 %>% 
  tidyr::unnest_wider("name") %>%
  tidyr::unnest_wider("expansion")
test.yaml.3 %>% purrr::pluck("name")
test.yaml.3 %>% 
  dplyr::mutate(name = purrr::pluck("name"))

                