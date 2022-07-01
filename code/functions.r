library(tidyverse)
library(ggrepel)
library(ggwordcloud)
library(paletteer) # for better palettes
# set a general theme for all ggplots
theme_set(theme_bw())

# use string matching to include multi-word terms: inspired by https://stackoverflow.com/questions/65182347
# df.input must have a column "text"  
f.stringmatch.frequency <- function(df.input, list.strings) {
  df.output <- df.input %>%
    dplyr::mutate(
      term = str_extract_all(text, 
                             regex(paste0("\\b", list.strings, "\\b", collapse = '|'),
                                   ignore_case = FALSE)) # it might make sense to add an input variable for this choice
    ) %>%
    unnest(term) %>%
    dplyr::group_by(term) %>%
    dplyr::summarise(freq = n()) %>%
    dplyr::arrange(desc(freq))
  df.output
}
# control for correct case of matches
# match all the variants and then group by term
f.clean.variants <- function(df.input) {
  df.output <- dplyr::left_join(df.tools, df.input, by = c("variant" = "term")) %>%
    tidyr::drop_na()%>%
    dplyr::group_by(term) %>%
    dplyr::summarise(freq = sum(freq)) %>%
    dplyr::arrange(desc(freq))
  df.output
}

# Wordcloud with ggplot2
# the input requires a column named "term"
f.wordcloud.frequency <- function(input, max.values, label.text, output.device) {
  # process data: frequency list
  data.frequency <- input %>%
    dplyr::filter(freq > 1) %>% # remove unique terms
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
  # plot
  plot.base <- ggplot(data.frequency, aes(x = 1, y = 1, size = freq, label = term, colour = freq)) +
    scale_y_continuous(breaks = NULL) +
    scale_x_continuous(breaks = NULL)
  # labs
  layer.labs <- labs(x = "", y = "", 
                     title = v.title,
                     subtitle = "by number of texts",
                     caption = v.caption)
  layer.text.repel <- c(
    geom_text_repel(segment.size = 0, force = 10, max.overlaps = 500, family = font.words),
    scale_size(range = c(1.5, 40), guide = FALSE))
  layer.text.wordcloud <- c(
    geom_text_wordcloud(aes(angle = angle), # use the angle information
                        family = font.words, 
                        area_corr = FALSE, # for frequency corresponding to area
                        eccentricity = 1, # to form a circle
                        rm_outside = TRUE, # if there are too many terms, the smallest ones should be removed if they cannot fit onto the canvas
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
  ggsave(plot = plot.wordcloud, filename = paste("wordcloud_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
  ggsave(plot = plot.repel, filename = paste("wordcloud-repel_", label.text, "-w_", v.total.values,".", v.output.device, sep = ""),
         device = v.output.device, units = "mm" , height = height.Plot, width = width.Plot, dpi = dpi.Plot)
}

# load parameters
source(here("code", "parameters.r"))