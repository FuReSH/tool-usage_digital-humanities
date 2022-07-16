# script to scrape data from the DFG GEPRIS catalogue
library(tidyverse)
library(rvest) # for scraping
library(robotstxt)
library(here)

# set working directory
setwd(here("data/dfg"))

# helpful links
# https://towardsdatascience.com/ethics-in-web-scraping-b96b18136f01
# https://rud.is/b/2017/07/28/analyzing-wait-delay-settings-in-common-crawl-robots-txt-data-with-r/

# short wrapper function to directly get the text content of an HTML element
f.get.text <- function(html, xpath) {
  rvest::html_element(html, xpath = xpath) %>% 
    rvest::html_text2()
}
# scrape a single GEPRIS entry
f.scrape.gepris.entry <- function(project.id) {
  v.url.base = "https://gepris.dfg.de/gepris/projekt/"
  v.url = paste0(v.url.base, project.id)
  v.page = rvest::read_html(v.url)
  v.xpath.details = "/html/body//div[@class = 'details']"
  v.xpath.description = "/html/body//div[@id = 'projektbeschreibung']"
  # problem: the number of divs changes, depending on presence of data. Selection by index will therefore be errorprone
  df.gepris <- dplyr::tibble(
    id = as.double(project.id),
    #html.details = rvest::html_element(v.page, xpath = v.xpath.details),
    title = f.get.text(v.page, paste(v.xpath.details, "h1[1]", sep = "/")),
    #antragsteller = f.get.text(v.page, paste(v.xpath.details, "div[1]/span[@class = 'value']", sep = "/")),
    antragsteller = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'value'][starts-with(a/@href, '/gepris/person')]", sep = "//")),
    #antragstellerId = str_replace(f.get.text(v.page, paste(v.xpath.details, "div[1]/span[@class = 'value']/a/@href", sep = "/")),'^.*?(\\d+)$', '\\1'),
    antragstellerId = str_replace(f.get.text(v.page, paste(v.xpath.details, "span[@class = 'value']/a[starts-with(@href, '/gepris/person')]/@href", sep = "//")),
                                  '^.*?(\\d+)$', '\\1'),
    #fachlicheZuordnung = f.get.text(v.page, paste(v.xpath.details, "div[@class = 'firstUnderAntragsbeteiligte']/span[@class = 'value']", sep = "/")),
    fachlicheZuordnung = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'name'][text() = 'Fachliche Zuordnung']/following-sibling::span[@class = 'value']", sep = "//")),
    #dates = f.get.text(v.page, paste(v.xpath.details, "div[3]/span[@class = 'value']", sep = "/")),
    dates = f.get.text(v.page, paste(v.xpath.details, "span[@class = 'name'][text() = 'Förderung']/following-sibling::span[@class = 'value']", sep = "//")),
    projektText = f.get.text(v.page, paste(v.xpath.description, "div[@id = 'projekttext']", sep = "/")),
    dfgVerfahren = f.get.text(v.page, paste(v.xpath.description, "div[@id = 'projekttext']/following-sibling::div[1]/span[@class = 'value']", sep = "/"))
  )
  df.gepris
}
# test
f.scrape.gepris.entry(216751394)

# scrape project IDs from GEPRIS catalogue pages
f.scrape.gepris.ids <- function(url) {
  v.page = rvest::read_html(url)
  v.xpath.item = "/html/body//div[@class = 'listbox2']/div[@id = 'liste']/div"
  v.urls.projects <- ''
  for (item in html_elements(v.page, xpath = v.xpath.item)) {
    v.urls.projects <- append(v.urls.projects,
                            f.get.text(item, "div[@class = 'results']/h2[1]/a/@href"),
                            after = 1)
  }
  str_replace(v.urls.projects, '^.*?(\\d+)$', '\\1')
}
# test
#v.ids.project <- f.scrape.gepris.ids("https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&hitsPerPage=50&index=0&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false")


# iterate over multiple catalogue pages with 50 results each
# be polite and check the robots.txt for delay settings
robotstxt::robotstxt("https://gepris.dfg.de/")
# this is very rudimentary and doesn't provide information for crawlers. Thus we set a hard coded delay
v.delay = 2
## parts of the URL as variables. '&index=0' needs to be incremented by 50
## '&fachgebiet=11' indicates humanities
v.url.part.1 = "https://gepris.dfg.de/gepris/OCTOPUS?beginOfFunding=&bewilligungsStatus=&bundesland=DEU%23&context=projekt&einrichtungsart=-1&fachgebiet=11&fachkollegium=%23&findButton=historyCall&gefoerdertIn=&ggsHunderter=0&hitsPerPage=50&index="
v.url.part.2 = "&nurProjekteMitAB=false&oldGgsHunderter=0&oldfachgebiet=11&pemu=%23&task=doKatalog&teilprojekte=true&zk_transferprojekt=false"
# iterate over catalogue pages with 50 results each to scrape all project IDs
v.ids.project = c('')
for (i in 0:319) {
  v.url = paste0(v.url.part.1, i * 50, v.url.part.2)
  v.ids.project <- append(v.ids.project, f.scrape.gepris.ids(v.url), after = 1)
  # delay
  Sys.sleep(v.delay)
}
# convert to tibble
df.ids.project <- tibble(id = v.ids.project) %>%
  dplyr::mutate(id = na_if(id, '')) %>%
  tidyr::drop_na() %>%
  dplyr::arrange(id)
# save to disk
write.table(df.ids.project, file = "dfg_project-ids-humanities.csv", row.names = F, sep = ",")
# load if previously generated
df.ids.project <- readr::read_csv("dfg_project-ids-humanities.csv")

# iterate through a range of project IDs
df.dfg.projects = f.scrape.gepris.entry(df.ids.project[1, "id"])
for(id in df.ids.project[2:100, ]$id) {
  print(paste("Scraping DFG project no.", id, "from GEPRIS", sep = " "))
  df.dfg.projects <- df.dfg.projects %>%
    add_row(f.scrape.gepris.entry(id))
  Sys.sleep(0.5)
}

# postprocessing
df.dfg.projects <- df.dfg.projects %>%
  mutate(onset = as.double(str_replace(dates, '^.*?(\\d{4}).*$', '\\1')),
         terminus = as.double(str_replace(dates, '^.*(\\d{4})*.*(\\d{4}).*?$', '\\2')))

# save output
save(df.gepris, file = "dfg_projects.rda")
write.table(df.gepris, file = "dfg_projects.csv", row.names = F, sep = ",")
# iterate through a nummerical range of project IDs
# NOT FEASIBLE as this would need 1 billion iterations to find c.130000 existing IDs
v.id = 172886252
df.gepris = f.scrape.dfg.gepris(v.id)
for(id in (v.id + 1):(v.id + 5)) {
  df.gepris <- df.gepris %>%
    add_row(f.scrape.dfg.gepris(id)) %>%
  # either remove all empty rows directly here or in postprocessing
    tidyr::drop_na(title)
  Sys.sleep(v.delay)
}
