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
## this function returns the id of a text and all the terms it found therein with one row per term found and a frequency of how often this term was found in each text
f.freq.term.per.text <- function(df.input, list.strings, ignore.case) {
  df.output <- df.input %>%
    dplyr::mutate(
      term = str_extract_all(text, 
             regex(paste0("\\b", list.strings, "\\b", collapse = '|'),
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
  df.output
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

f.stringmatch.frequency <- function(df.input, list.strings) {
  f.freq.term.per.text(df.input, list.strings, F) %>%
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
    dplyr::mutate(label.clean = str_replace_all(label,"(\\.\\*|\\+|\\/|\\(|\\)|\\&|\\|)", "\\\\\\1"),
                  label.clean = str_replace(label.clean, "^\\s+", ""))
}

# load parameters
source(here("code", "parameters.r"))