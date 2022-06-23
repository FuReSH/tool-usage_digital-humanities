# this script generates and saves term-frequency lists from the DH conferences corpus
library(tidyverse)
library(here)
library(ggrepel)
library(ggwordcloud)
library(paletteer) # for better palettes
# enable unicode
Sys.setlocale("LC_ALL", "en_US.UTF-8")
# set a general theme for all ggplots
theme_set(theme_bw())

# load data
# 1. DH conferences
setwd(here("data", "dh-conferences"))
load("dh-conferences-frequencies_titles.rda")
load("dh-conferences-frequencies_abstracts.rda")
load("dh-conferences-frequencies_keywords.rda")
# 2. FuReSH tool list
df.tools <- read_csv(here("data","tools.csv"))
df.tools <- df.tools %>%
  rename(word = tool) %>%
  dplyr::distinct(word) %>%
  # add lower case for easier joining of data frames
  dplyr::mutate(word.lc = stringr::str_to_lower(word))
save(df.tools, file = "furesh-tools.rda")
df.concepts <- read_csv(here("data", "concepts.csv"))
df.concepts <- df.concepts %>%
  rename(word = concept) %>%
  dplyr::distinct(word) %>%
  # add lower case for easier joining of data frames
  dplyr::mutate(word.lc = stringr::str_to_lower(word))
save(df.concepts, file = "furesh-concepts.rda")

# pre-process data
# get all three and four letter words from the data set
df.test <- df.freq.titles %>%
  dplyr::filter(str_length(word) >= 3, str_length(word) <= 4)

# get frequencies of the controlled tool list from the DH conference data
df.tools.titles <- dplyr::left_join(df.tools, df.freq.titles, by = c("word.lc" = "word")) %>%
  dplyr::arrange(desc(freq))
df.tools.abstracts <- dplyr::left_join(df.tools, df.freq.abstracts, by = c("word.lc" = "word"))%>%
  dplyr::arrange(desc(freq))
df.concepts.abstracts <- dplyr::left_join(df.concepts, df.freq.abstracts, by = c("word.lc" = "word"))%>%
  dplyr::arrange(desc(freq))
df.tools.keywords <- dplyr::left_join(df.tools, df.freq.keywords, by = c("word.lc" = "word"))%>%
  dplyr::arrange(desc(freq))

write.table(df.tools.titles, file = "dh-conferences-frequencies_tools-titles.csv", row.names = F, quote = T, sep = ",")
write.table(df.tools.abstracts, file = "dh-conferences-frequencies_tools-abstracts.csv", row.names = F, quote = T, sep = ",")
write.table(df.concepts.abstracts, file = "dh-conferences-frequencies_concepts-abstracts.csv", row.names = F, quote = T, sep = ",")

# wordclouds with ggplot
# some variables
v.label.source = "Data: Weingart et al., 'Index of Digital Humanities Conferences Data', https://doi.org/10.1184/R1/12987959.v4" # source information
v.label.license = "Till Grallert, CC BY-SA 4.0"
font.words = "Helvetica Neue"
# sizes
## in themes size is measured in px
size.Base.Px = 9
## font sizes are measured in mm
size.Base.Mm = (5/14) * size.Base.Px
# specify text sizes
size.Title = 2
size.Subtitle = 1.5
size.Text = 0.8
## transformation to MM and PX
size.Title.Mm = size.Title * size.Base.Mm
size.Subtitle.Mm = size.Subtitle * size.Base.Mm
size.Text.Mm = size.Text * size.Base.Mm
size.Title.Px = size.Title * size.Base.Px
size.Subtitle.Px = size.Subtitle * size.Base.Px
size.Text.Px = size.Text * size.Base.Px
f.wordcloud.frequency <- function(input, max.values, label.text, output.device) {
  # process data: frequency list
  data.frequency <- input %>%
    dplyr::filter(freq > 1) %>% # remove unique words
    slice(1:max.values) %>% # limit the length of the data set
    # add some 90 degree angles to 20 % of all words
    dplyr::mutate(angle = 90 * sample(c(0, 1), n(), replace = TRUE, prob = c(80, 20))) 
  #dplyr::mutate(angle = 45 * sample(-2:2, n(), replace = TRUE, prob = c(1, 1, 4, 1, 1)))
  # labels, captions, other variables
  v.output.device = output.device
  font = "Baskerville"
  v.title = paste("The", nrow(data.frequency), "most frequent", label.text, sep = " ")
  v.caption = paste(v.label.source, ".\n", v.label.license, sep = "")
  # plot
  plot.base <- ggplot(data.frequency, aes(x = 1, y = 1, size = freq, label = word, colour = freq)) +
    scale_y_continuous(breaks = NULL) +
    scale_x_continuous(breaks = NULL)
  # labs
  layer.labs <- labs(x = "", y = "", 
                     title = v.title,
                     subtitle = "",
                     caption = v.caption)
  layer.text.repel <- c(
    geom_text_repel(segment.size = 0, force = 10, max.overlaps = 500, family = font.words),
    scale_size(range = c(1.5, 40), guide = FALSE))
  layer.text.wordcloud <- c(
    geom_text_wordcloud(aes(angle = angle), # use the angle information
                        family = font.words, 
                        area_corr = FALSE, # for frequency corresponding to area
                        eccentricity = 1, # to form a circle
                        rm_outside = TRUE, # if there are too many words, the smallest ones should be removed if they cannot fit onto the canvas
                        grid_margin = 0.5, seed = 43,
                        show.legend = T),
    scale_size_area(max_size = 30)
    #scale_radius(range = c(0, 30), limits = c(0, NA))
  )
  
  plot.base.final <- plot.base +
    layer.labs +
    #scale_color_gradient(low = "darkgreen", high = "red") +
    #scale_color_paletteer_c("scico::tokyo") +
    #scale_color_paletteer_c("oompaBase::jetColors") +
    #scale_colour_paletteer_c("pals::kovesi.diverging_gwv_55_95_c39") +
    scale_colour_paletteer_c("viridis::viridis") +
    guides(color = guide_colorbar("Frequency", order = 1),
           size = "none")+ #guide_legend("Frequency", order = 2)) +
    theme(
      text = element_text(family = font, face = "plain"),
      plot.title = element_text(size = size.Title.Px),
      plot.subtitle = element_text(size = size.Subtitle.Px),
      plot.caption = element_text(size = size.Text.Px),
      legend.position = c(0.84,0.01),
      legend.direction = "horizontal",
      legend.key = element_rect(fill = NULL),
      legend.margin = margin(0),
      legend.justification = "bottom",
      panel.border = element_blank()) 
  plot.repel <- plot.base.final +
    layer.text.repel
  plot.wordcloud <- plot.base.final +
    layer.text.wordcloud
  #plot.repel
  #plot.wordcloud
  # save output: with the latest update of ggplot2, ragg is not needed anymore and Arabic is correctly printed
  ggsave(plot = plot.wordcloud, filename = paste("wordcloud_", label.text, "-w_", max.values,".", v.output.device, sep = ""),
         device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
  ggsave(plot = plot.repel, filename = paste("wordcloud-repel_", label.text, "-w_", max.values,".", v.output.device, sep = ""),
         device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
}

# variables for saving plots
width.Plot <- 200
height.Plot <- 200
dpi.Plot <- 300

f.wordcloud.frequency(df.tools.abstracts, 100, "tools in DH conference abstracts", "svg")
f.wordcloud.frequency(df.tools.abstracts, 100, "tools in DH conference abstracts", "png")
f.wordcloud.frequency(df.concepts.abstracts, 100, "concepts in DH conference abstracts", "svg")
f.wordcloud.frequency(df.concepts.abstracts, 100, "concepts in DH conference abstracts", "png")
