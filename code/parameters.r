# this script contains universal parameters, mostly for plots.
# it is loaded by `functions.r`
# some variables
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

# variables for saving plots
width.Plot <- 240
height.Plot <- width.Plot
dpi.Plot <- 600

# APIs
## Wikidata
wd.api.url.base = "https://www.wikidata.org/w/rest.php/wikibase/v0/entities/items/"
wd.api.url.statements = "statements?property="
