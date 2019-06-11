# let's look at greenthumb gardens 
# maybe also vacant lots for potential gardens?

library(data.table)
library(leaflet)
library(ggplot2)
library(councildown)

# load data 
gt_gards <- fread("https://data.cityofnewyork.us/resource/yes4-7zbb.csv")

# let's map 

gt <- leaflet(gt_gards) %>% 
  addCouncilStyle() %>%
  addCircles(lng = ~longitude, 
             lat = ~latitude, 
             popup = ~garden_name)
  
