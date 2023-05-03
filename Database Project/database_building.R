# install.packages(c("DBI", "RPostgres"))
library(DBI)
library(RPostgres)
library(tidyverse)
library(reshape2)
library(countrycode)
library(openxlsx)

# connect to postgres database
con <- dbConnect(RPostgres::Postgres(),
                 dbname = 'int_relations',
                 host = '127.0.0.1', 
                 port = 5432, 
                 user = 'postgres',
                 password = 'COM3T123')

# # Create SQL query object
# query <- "SELECT * FROM department"
# 
# dbGetQuery(con, postgres_sql)
# 
# department_df <- dbGetQuery(con, postgres_sql)
# class(department_df)

events <- readRDS("data/countries.rds")
events <- readRDS("data/dyads.rds")
events <- readRDS("data/events.rds")

# if (dbExistsTable(con, "country"))
#   dbRemoveTable(con, "country")
dbWriteTable(con, name = "country", value = countries, row.names = FALSE, append = TRUE)

# if (dbExistsTable(con, "dyad"))
#   dbRemoveTable(con, "dyad")
dbWriteTable(con, name = "dyad", value = dyads, row.names = FALSE, append = TRUE)

# if (dbExistsTable(con, "event"))
#     dbRemoveTable(con, "event")
dbWriteTable(con, name = "event", value = events, row.names = FALSE, append = TRUE)



# Loading, wrangling, and merging coded event data, creating events dataframe----

# slightly different formats between yearly data
# coercing variables to correct class
# saving as .rds
# load("data/events.2015.20180710092545.RData")
# x15 <- x
# x15$Event.Date <- as.Date(as.character(x15$Event.Date))
# saveRDS(x15,"data/events_2015.rds")
# load("data/events.2016.20180710092843.RData")
# x16 <- x
# x16$Event.Date <- as.Date(as.character(x16$Event.Date))
# saveRDS(x16,"data/events_2016.rds")
# rm(x)
# x17 <- read_delim("data/Events.2017.20201119.tab")
# saveRDS(x17,"data/events_2017.rds")
# x18 <- read_delim("data/events.2018.20200427084805.tab")
# saveRDS(x18,"data/events_2018.rds")
# x19 <- read_delim("data/events.2019.20200427085336.tab")
# saveRDS(x19,"data/events_2019.rds")
# colnames(x15) <- gsub(".", " ", colnames(x15), fixed = TRUE)
# colnames(x16) <- gsub(".", " ", colnames(x15), fixed = TRUE)
# events <- rbind(x15, x16, x17, x18, x19)
# colnames(events) <- gsub(" ", "_", colnames(events), fixed = TRUE)
# events <- events %>% select(-c("Story_ID", "Sentence_Number", "Publisher"))
# events$Event_Date <- format(events$Event_Date, "%Y")
# events$Event_Date <- as.numeric(events$Event_Date)
# events$source_country_code <- countrycode(events$Source_Country, 
#                                     origin = "country.name", destination = "iso3c")
# events$target_country_code <- countrycode(events$Target_Country, 
#                                           origin = "country.name", destination = "iso3c")
# events <- events %>% relocate(source_country_code, .after = Source_Country)
# events <- events %>% relocate(target_country_code, .after = Target_Country)
# names(events) <- tolower(names(events))
# colnames(events)[c(1, 2, 7)] <- c("id", "year", "text")
# events <- events[!is.na(events$source_country),]
# events <- events[!is.na(events$target_country),]
# events <- events %>% subset(target_country == "United States")
# events <- events %>% subset(source_country %in% countries$name)
# saveRDS(events,"data/events.rds")




# Loading, wrangling World Bank/freedom variables, merging, creating countries df----

# loading, renaming, and saving as .rds
# vars <- read.xlsx("data/P_Affinity Data.xlsx", sheet = 1, colNames = TRUE)
# vars <- vars[c(-2, -5)]
# colnames(vars) <- c("year","name", "code", "gdp_growth_annual", "gdp_cap_growth",
#                     "health_exp_cap", "health_exp_gdp", "gdp_cap_ppp", "gdp_ppp",
#                     "edu_exp", "nat_resc_rent", "women_seats", "women_bus_law_score",
#                     "life_exp", "inf_mort", "rd_exp", "hi_tech_export",
#                     "internet", "ict_good_exp", "ict_good_imp", "ict_ser_exp",
#                     "gini", "ease_bus_score", "milt_exp")
# saveRDS(vars, "data/variables.rds")
vars <- readRDS("data/variables.rds")

# loading, wrangling freedom data
freedom <- read_csv("data/freedom_scores.csv")
freedom <- freedom[, -1]
freedom$`Country  Sort descending` <- gsub("*", "", freedom$`Country  Sort descending`, fixed = TRUE)
# removing categorical description from total score variable, coercing to numeric
freedom$`Total Score and Status` <- gsub("[^0-9]", "", freedom$`Total Score and Status`)
freedom$`Total Score and Status` <- as.numeric(freedom$`Total Score and Status`)
colnames(freedom) <- c("source_country", "total_score", "pol_rights", "civil_lib")

# merging freedom scores with rest of variables
vars <- left_join(vars, freedom, by = join_by(name == source_country))

vars <- vars %>% relocate(year, .after = name)
vars <- vars[-(1086:1087),]
vars$year <- as.numeric(vars$year)
countries <- vars
saveRDS(countries, "data/countries.rds")



# Calculating affinity, wrangling trade data, merging, creating dyad dataframe----

events <- readRDS("data/events.rds")
affinity <- events %>% group_by(source_country, year) %>% 
  summarise(affinity = mean(intensity))
affinity <- na.omit(affinity)
affinity$target_country <- "United States"
affinity$source_country_code <- countrycode(affinity$source_country,
                                    origin = "country.name", destination = "iso3c")
affinity$target_country_code <- countrycode(affinity$target_country,
                                          origin = "country.name", destination = "iso3c")
affinity <- affinity %>% relocate(target_country, .after = source_country)

# loading and wrangling trade data
trade <- readRDS("data/trade_2015-2019.rds")

# keep trade balance variable with U.S. as counterpart country
trade <- trade[, c(-(8:74), -(80:82))]
trade <- trade %>% subset(`Counterpart Country Name` == "United States")
trade <- trade[grep("Trade", trade$`Indicator Name`), ]

# transform existing IMF country code to country name to merge with rest of data
trade$source_country <- countrycode(trade$`Country Code`, 
                                    origin = "imf", destination = "country.name")

# cleaning data, transforming to long format
trade <- trade[, c(13, 1:12)]
trade <- trade[!is.na(trade$source_country),]
trade <- trade[, c(-(2:3), -(5:8))]
trade <- melt(trade, id.vars = 1:2)
trade <- trade[, -2]
names(trade)[2] <- "year"
trade$year <- as.numeric(as.character(trade$year))
affinity <- left_join(affinity, trade, by = c("source_country", "year"))
colnames(affinity)[which(names(affinity) == "value")] <- "trade_balance_usd"
affinity$trade_balance_usd <- as.numeric(affinity$trade_balance_usd)

dyads <- affinity %>% subset(source_country %in% countries$name)
saveRDS(dyads, "data/dyads.rds")
