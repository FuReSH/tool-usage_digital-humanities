library(tidyverse)
library(ggrepel)
library(ggwordcloud)
library(paletteer) # for better palettes
library(yaml)
library(DataExplorer) # for quick exploration
# set a general theme for all ggplots
theme_set(theme_bw())

# use string matching to include multi-word terms: inspired by https://stackoverflow.com/questions/65182347
# df.input must have a column "text"  
# df.terms must have two columns: "term", "id"
## this function returns the id of a text and all the terms it found therein with one row per term found and a frequency of how often this term was found in each text
f.freq.term.per.text <- function(df.input, df.terms, ignore.case) {
  # make sure that terms are unique
  #df.terms <- df.terms %>%
   # distinct(term)
  # document process in console
  print(paste("searching", nrow(df.input), "input texts for the occurrence of", nrow(df.terms), "terms", sep = " "))
  df.output <- df.input %>%
    dplyr::mutate(
      term = str_extract_all(text, 
             regex(paste0("\\b", df.terms$term, "\\b", collapse = '|'),
                   ignore_case = ignore.case)) # it might make sense to add an input variable for this choice
    ) %>%
    unnest(term) %>%
    dplyr::select(id, term) %>% 
    # rename for clarity
    dplyr::rename(source = id,
                  target = term) %>%
    # step 1: group by text and term: get frequency of number of hits per term per text
    dplyr::group_by(source, target) %>%
    dplyr::summarise(weight = n())
  df.output %>% 
    dplyr::left_join(df.terms, by = c("target" = "term")) %>%
    dplyr::rename(target.id = id)
}
## this function takes the output from the previous function and returns the number of texts, a given term occurs in
f.freq.text.per.term <- function(df.input) {
  df.input %>% 
    # step 2: group by term: get frequency of number of texts per term
    dplyr::group_by(target) %>%
    dplyr::summarise(freq = n()) %>%
    dplyr::arrange(desc(freq)) %>%
    rename(term = target)
}

f.stringmatch.frequency <- function(df.input, df.terms) {
  f.freq.term.per.text(df.input, df.terms, F) %>%
    f.freq.text.per.term()
}
# control for correct case of matches
# match all the variants and then group by term
f.clean.variants <- function(df.input, number.of.texts) {
  df.grouped <- dplyr::full_join(df.tools, df.input, by = c("variant" = "term")) %>%
    #tidyr::drop_na()%>%
    dplyr::group_by(term) %>%
    dplyr::summarise(freq = sum(freq))
  # normalise frequencies: 
  f.normalise.freqs(df.grouped, total = number.of.texts)
}
f.normalise.freqs <- function(df.input, total) {
  # normalise frequencies: 
  df.normalised <- df.input %>%
    dplyr::mutate(
      # 1. relative to each other
      freq.rel = freq / max(df.input$freq),
      freq.rel.100 = freq.rel * 100,
      # 2. as percentage of total number of input texts
      freq.text.100 = freq / total * 100) %>%
    dplyr::arrange(desc(freq), term)
  df.normalised
}

# read our YAML for tools
f.read.yaml.furesh <- function(filename) {
  list.input <- read_yaml(file = filename, readLines.warn = FALSE)
  tibble(
    name = purrr::map(list.input, "name"),
    expansion = purrr::map(list.input, "expansion"),
    category = purrr::map(list.input, "category")
  ) %>%
    unnest(cols = c(name, expansion, category)) #%>%
    #dplyr::na_if("NULL")
}
# build data frame from  list of file names
f.read.txt.files <- function(filenames) {
  df.output <- purrr::map_df(filenames, ~ tibble(
    text = readr::read_file(.x)) %>%
      dplyr::mutate(filename = basename(.x))
  )
  df.output %>%
    dplyr::mutate(id = str_replace(filename, '^(.+)\\.txt', '\\1'))
}

f.read.txt.files.from.folder <- function(path) {
  v.filenames <- list.files(path = path, pattern = "*.txt",  ignore.case = T, full.names = T)
  f.read.txt.files(v.filenames)
}
# Wordcloud with ggplot2
# the input requires a column named "term"
f.wordcloud.frequency <- function(input, max.values, label.text, output.device) {
  # process data: frequency list
  data.frequency <- input %>%
    #dplyr::filter(freq > 1) %>% # remove unique terms: this needs to be commented out for relative frequencies
    slice(1:max.values) %>% # limit the length of the data set
    # add some 90 degree angles to 20 % of all terms
    dplyr::mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(80, 20))) #%>%
    # add some 45 degree angles: can be removed, I suppose
    #dplyr::mutate(angle = 45 * sample(-2:2, n(), replace = TRUE, prob = c(1, 1, 4, 1, 1)))
  # labels, captions, other variables
  v.output.device = output.device
  v.total.values = nrow(data.frequency)
  font = "Baskerville"
  v.title = paste("The", v.total.values, "most frequent", label.text, sep = " ")
  v.caption = paste(v.label.source, ".\n", v.label.license, sep = "")
  # plot: use normalised relative frequencies
  plot.base <- ggplot(data.frequency, aes(x = 1, y = 1, label = term)) +
    scale_y_continuous(breaks = NULL) +
    scale_x_continuous(breaks = NULL)
  # labs
  layer.labs <- labs(x = "", y = "", 
      title = v.title,
      caption = v.caption)
  layer.labs.rel.100 <- labs(subtitle = 'Normalised relative frequencies by number of texts \nMost frequent term = 100')
  layer.labs.text.100 <- labs(subtitle = 'Normalised relative frequencies by number of texts \nNumber of texts = 100')
  layer.repel.text.100 <- c(
    geom_text_repel(aes(size = freq.text.100, colour = freq.text.100),
        segment.size = 0, force = 20, max.overlaps = 500, family = font.words),
    scale_size(range = c(1.5, 30), guide = FALSE))
  layer.wordcloud.text.100 <- c(
    geom_text_wordcloud(aes(size = freq.text.100, colour = freq.text.100, angle = angle), # use the angle information
                        family = font.words,
                        # frequency = area or font size. If font.size, readers will get the wrong impression
                        area_corr = TRUE, 
                        eccentricity = 1, # to form a circle
                        rm_outside = TRUE, # if there are too many terms, the smallest ones should be removed if they cannot fit onto the canvas
                        grid_margin = 0.5, seed = 43,
                        show.legend = T),
    scale_size_area(max_size = 50) #, scale_radius(range = c(0, 30), limits = c(0, NA))
  )
  layer.repel.rel.100 <- c(
    geom_text_repel(aes(size = freq.rel.100, colour = freq.rel.100),
        segment.size = 0, force = 20, max.overlaps = 500, family = font.words),
    scale_size(range = c(1.5, 30), guide = FALSE))
  layer.wordcloud.rel.100 <- c(
    geom_text_wordcloud(aes(size = freq.rel.100, colour = freq.rel.100, angle = angle), # use the angle information
                        family = font.words,
                        area_corr = TRUE, 
                        eccentricity = 1, # to form a circle
                        rm_outside = TRUE, # if there are too many terms, the smallest ones should be removed if they cannot fit onto the canvas
                        grid_margin = 0.5, seed = 43,
                        show.legend = T),
    scale_size_area(max_size = 50) #, scale_radius(range = c(0, 30), limits = c(0, NA))
  )
  
  plot.base.final <- plot.base +
    layer.labs +
    scale_colour_paletteer_c("viridis::viridis") +
    guides(color = guide_colorbar("Frequency (%)", order = 1),
           size = "none")+ #guide_legend("Frequency", order = 2)) +
    theme(
      text = element_text(family = font, face = "plain"),
      plot.title = element_text(size = size.Title.Px),
      plot.subtitle = element_text(size = size.Subtitle.Px),
      plot.caption = element_text(size = size.Text.Px),
      #legend.position = c(0.84,0.01),
      #legend.position = c(0.84,1),
      legend.position = c(0.1,0.01),
      legend.justification = "bottom",
      legend.direction = "horizontal",
      legend.key = element_rect(fill = NULL),
      legend.margin = margin(0),
      panel.border = element_blank()) 
  plot.repel.text.100 <- plot.base.final +
    layer.labs.text.100 +
    layer.repel.text.100
  plot.wordcloud.text.100 <- plot.base.final +
    layer.labs.text.100 +
    layer.wordcloud.text.100
  plot.repel.rel.100 <- plot.base.final +
    layer.labs.rel.100 +
    layer.repel.rel.100
  plot.wordcloud.rel.100 <- plot.base.final +
    layer.labs.rel.100 +
    layer.wordcloud.rel.100
  # print output to console
  # plot.repel.text.100
  # save output: with the latest update of ggplot2, ragg is not needed anymore and Arabic is correctly printed
  ggsave(plot = plot.wordcloud.text.100, filename = paste("wordcloud-text-100_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
  ggsave(plot = plot.repel.text.100, filename = paste("wordcloud-text-100-repel_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
  ggsave(plot = plot.wordcloud.rel.100, filename = paste("wordcloud-rel-100_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
  ggsave(plot = plot.repel.rel.100, filename = paste("wordcloud-rel-100-repel_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         path = here("visualization"), device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
}

f.prettify.df <- function(data.input, file.name){
  data.input %>%
    dplyr::select(term, freq, freq.rel) %>%
    dplyr::mutate(freq.rel = round(freq.rel, 2)) %>% 
    write.table(file = paste(file.name, 'print.csv', sep = '_'), row.names = F, quote = F, sep = ',')
}
# read a folder of json files
f.read.json <- function(folder) {
  v.filenames <- list.files(pattern="*.json", full.names=TRUE)
  df.json <- lapply(v.filenames, function(x) {
    jsonlite::read_json(x, simplifyVector = F, flatten = F)
  })
  # output is a list of lists and data frames
  df.json
}
# small helper to figure out a JSON structure
f.json.types <- function(tbl.json) {
  tbl.json %>%
    as.tbl_json() %>%
    gather_object() %>%
    json_types() %>% count(name, type)
}
f.clean.labels <- function(df.input) {
  df.input %>%
    # escape all symbols that have special meaning in regex
    dplyr::mutate(label.clean = str_replace_all(label,"(\\.|\\*|\\+|\\/|\\(|\\)|\\&|\\|)", "\\\\\\1"),
                  label.clean = str_replace(label.clean, "^\\s+", ""))
}

# short wrapper function to directly get the text content of an HTML element
f.get.text <- function(html, xpath) {
  rvest::html_element(html, xpath = xpath) %>% 
    rvest::html_text2()
}

# query Wikidata for properties using the WikidataR library
f.wikidata.properties <- function(wd.id, wd.property) {
  # get item from Wikidata
  wd.item <- WikidataR::get_item(wd.id)
  # list all available properties
  wd.properties <- WikidataR::list_properties(wd.item)
  # create empty output
  output <- tibble()
  # check if the property we are looking for is there
  if (wd.property %in% wd.properties[[1]]) {
    # get all data on the property
    wd.claim <- WikidataR::extract_claims(wd.item, wd.property)
    # properties are of various types, which will return different data types
    wd.claim.type = wd.claim[[1]][[1]]$mainsnak$datavalue$type[1]
    print(paste(wd.property, 'is of type', wd.claim.type, sep = ' '))
    if (wd.claim.type == 'wikibase-entityid') {
      wd.claim.names <- WikidataR::get_names_from_properties(wd.claim)
      # reduce output to the main tibble
      wd.claim.names[[1]] -> output
    }
    if (wd.claim.type == 'monolingualtext') {
      # returns tibble of text-language pairs
      wd.claim[[1]][[1]]$mainsnak$datavalue$value %>%
        dplyr::as_tibble() %>%
        dplyr::rename(value = text) -> output
    }
  } else {
    print(paste(wd.id, 'does not carry the property', wd.property, sep = ' '))
    print(paste('try these properties instead', wd.properties, sep = ' '))
    # return NA
    output = NA
  }
  output
}

# query wikidata for labels: https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/Q448335/labels
# short names: Property:P1813: https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/Q448335/statements?property=P1813
# output: list(s)
f.wikidata.api.properties <- function(wd.id, wd.prop) {
  v.url = paste0(wd.api.url.base, wd.id,"/", wd.api.url.statements, wd.prop)
  print(paste("Make API call to", v.url, sep = " "))
  json <- jsonlite::read_json(v.url, simplifyVector = T, flatten = F)
  # should the output be a list or tibble?
  output <- list()
  # test if the API call returned JSON
  ifelse(rlang::is_empty(json), 
         # error message
         print("the call did not return any results"),
         output <- json[[1]]$value$content %>%
           as.list()
        )
  # return solely the content of the API call
  output
  # rename the single unnamed column "."
}

f.wikidata.label <- function(wd.id, lang) {
  v.url = paste0(wd.api.url.base, wd.id,"/labels")
  print(paste("Make API call to", v.url, sep = " "))
  v.json <- jsonlite::read_json(v.url, simplifyVector = T, flatten = F)
  # create a tibble with lang-value pairs 
  df.output <- v.json %>%
    as_tibble() %>%
    tidyr::pivot_longer(everything()) %>%
    dplyr::rename(language = name)
  # select specified language > add fallback
  df.output <- df.output %>%
    dplyr::filter(language == lang)
  df.output$value
}
# load parameters
source(here("code", "parameters.r"))