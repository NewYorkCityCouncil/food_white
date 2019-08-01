# 5/28
# let's look at supermarkets and FRESH zones 
# let's look at inspections 
# let's consider SNI index 
# 
# data source: https://data.ny.gov/Economic-Development/Retail-Food-Stores/9a8c-vfzj
# 
library(data.table)
sup_marks <- fread("https://data.ny.gov/resource/f8pc-ikxm.csv?$limit=99999")
unique(sup_marks$county)

# grab NYC 
nyc_counts <- c("New York", "Queens", "Kings", "Richmond", "Bronx")
nyc_sups <- sup_marks[county %in% nyc_counts, ]

# let's look at the kinds of stores & how many 
unique(nyc_sups$operation_type) # only stores

# which entity has the most stores?
nyc_sups[, .N, by = "entity_name"][order(N, decreasing = TRUE)][1:100]
nyc_sups[, .N, by = "dba_name"][order(N, decreasing = TRUE)][1:100]

# let's look at where the FRESH/affordable supermarkets are
# Key Foods, Western Beef, Fine Food, C-Town, Associated

sup_marks <- fread("https://data.ny.gov/resource/f8pc-ikxm.csv")
nyc_sups <- sup_marks[grep("New York|Kings|Richmond|Queens|Bronx", county, ignore.case = TRUE), ]
nyc_sups[square_footage >= 10000, ]
nyc_sups[, .N, by = "dba_name"][order(N, decreasing = TRUE)]
