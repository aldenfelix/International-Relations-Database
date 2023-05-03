# install.packages(c("DBI", "RPostgres"))
library(DBI)
library(RPostgres)

# connect to postgres database
con <- dbConnect(RPostgres::Postgres(),
                         dbname = 'postgres',
                         host = '127.0.0.1', 
                         port = 5432, 
                         user = 'postgres',
                         password = 'COM3T123')

# Create SQL query object
# postgres_sql <- "SELECT * FROM department"
# 
# dbGetQuery(con, postgres_sql)
# 
# department_df <- dbGetQuery(con, postgres_sql)
# class(department_df)

