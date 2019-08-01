library(tidycensus)
library(data.table)
library(leaflet)
library(dplyr)
library(sf)
library(tigris)
library(ggplot2)

# we are exploring the acs data: seniors and snap benefits in nyc 6/10/19
# if someone doesn't have a kitchen in their house and they are eligible for snap - 

# register api key 
# census_api_key("8cdccf85df4c4c7cf6fadaca4006860333f8e592", install = TRUE, overwrite = TRUE)

# let's find the variables that we need 
v17 <- load_variables(2017, "acs5", cache = TRUE)
View(v17)
senior <- v17[grep("60 Years", concept, ignore.case = TRUE), ]
snap <- senior[grep("snap", concept, ignore.case = TRUE), name]

# Get snap data at the census tract
# Estimate!!Total
tot_pop <- get_acs(geography = "tract", 
                variables = "B22001_001", 
                state = "NY", 
                geometry = TRUE)

# Estimate!!Total!!Household received Food Stamps/SNAP in the past 12 months
snap2 <- get_acs(geography = "tract", 
                 variables = "B22001_002", 
                 state = "NY", 
                 geometry = TRUE)

#  Estimate!!Total!!Household received Food Stamps/SNAP in the past 12 months!!At least one person in household 60 years or over
snap3 <- get_acs(geography = "tract", 
                 variables = "B22001_003", 
                 state = "NY", 
                 geometry = TRUE)


# Seniors total 
sr <- get_acs(geography = "tract", 
              variables = "B11006_001", 
              state = "NY", 
              geometry = TRUE)

# clean up 
setDT(sr)
setDT(snap3)
setDT(tot_pop)
tot_pop[, c("NAME", "variable", "geometry") := NULL]

# do we want to look at total snap recipients?
sr[, county := tstrsplit(NAME, ",", keep = 2)]
sr[, county := trimws(county)]

snap3[, county := tstrsplit(NAME, ",", keep = 2)]
snap3[, county := trimws(county)]

# subset the acs senior info down to nyc only 
nyc <- snap3[grep("New York|Bronx|Queens|Richmond|Kings", county, ignore.case = TRUE), ]
nyc_sr <- sr[grep("New York|Bronx|Queens|Richmond|Kings", county, ignore.case = TRUE), ]

setnames(nyc_sr, "estimate", "total")
setnames(nyc_sr, "moe", "total_moe")

full_dt <- merge(nyc_sr, snap3, by = "GEOID")
# full_dt <- merge(full_dt, tot_pop, by = "GEOID")

full_dt[, prop_sr_snap := estimate/total] # what do we do about margins of error 
full_dt[,"geometry.y"] <- NULL
full_dt[prop_sr_snap %in% NaN, prop_sr_snap := 0]

pal = colorNumeric(
  palette = "RdYlBu",
  domain = full_dt$prop_sr_snap, 
  na.color = "Black", 
  reverse = TRUE
)

full_dt_sf <- full_dt %>% st_as_sf() 
full_dt_sf <- st_transform(full_dt_sf, '+proj=longlat +datum=WGS84')

leaflet(data = full_dt_sf) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(weight = .5, 
              fillColor = ~pal(full_dt$prop_sr_snap), 
              color = "white", 
              stroke = TRUE, 
              fillOpacity = .5, 
              popup = ~paste(`prop_sr_snap`, `estimate`)) %>% 
  addLegend(position ="bottomright", 
            pal = pal, 
            values = full_dt_sf$prop_sr_snap
  )

# let's plot the number of seniors in a community district 
ggplot(full_dt, aes(x=total, y=prop_sr_snap)) + geom_point()

# let's look at the proportion of seniors 



