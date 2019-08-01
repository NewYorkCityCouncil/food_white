# load and combine acs snap data, creat a column that has the filename in it 
# lets try a MRF smoother 

library(sf)
library(ggplot2)

acs14 <- fread("aff_download/ACS_14_5YR_S2201_with_ann.csv")
acs15 <- fread("aff_download/ACS_15_5YR_S2201_with_ann.csv")
acs16 <- fread("aff_download/ACS_16_5YR_S2201_with_ann.csv")
acs17 <- fread("aff_download/ACS_17_5YR_S2201_with_ann.csv")

#### 
names(acs14) <- as.character(acs14[1, ])
acs14 <- acs14[-1, ]

names(acs15) <- as.character(acs15[1, ])
acs15 <- acs15[-1, ]

names(acs16) <- as.character(acs16[1, ])
acs16 <- acs16[-1, ]

names(acs17) <- as.character(acs17[1, ])
acs17 <- acs17[-1, ]

snap <- rbind(acs14, acs15, acs16, acs17, use.names = TRUE, fill = TRUE)
snap[, 1:10]

# let's map 2017 
acs17sub <- acs17[,1:10]
acs17sub$`Percent households receiving food stamps/SNAP; Estimate; Households`

sr <- get_acs(geography = "block group", 
              variables = "B11006_001", 
              state = "NY", 
              geometry = TRUE)



geom <- sr[, c(1, 2, 6)]
acs17sub[, GEOID := Id2]
acs17sub[, pcnt_snap := as.numeric(`Percent households receiving food stamps/SNAP; Estimate; Households`)]
acs17_geom <- merge(acs17sub, geom, by = "GEOID")

# let's map this data 
pal = colorNumeric(
  palette = "RdYlBu",
  domain = acs17_geom$pcnt_snap, 
  na.color = "Black", 
  reverse = TRUE
)

full_dt_sf <-acs17_geom %>% st_as_sf() 
full_dt_sf <- st_transform(full_dt_sf, '+proj=longlat +datum=WGS84')

leaflet(data = full_dt_sf) %>% 
  addProviderTiles("CartoDB.Positron") %>% 
  addPolygons(weight = .5, 
              fillColor = ~pal(pcnt_snap), 
              color = "white", 
              stroke = TRUE, 
              fillOpacity = .5) %>% 
  addLegend(position ="bottomright", 
            pal = pal, 
            values = full_dt_sf$pcnt_snap
  )



