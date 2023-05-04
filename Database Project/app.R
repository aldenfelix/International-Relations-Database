#install.packages(c("shiny","DBI","RPostgres","RSQLite"))
library(shiny)
library(DBI)
library(RPostgres)
library(RSQLite)
library(rsconnect)

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("International Relations Database"),

    # Slider input for number of rows
    sliderInput("nrows", "Enter the number of rows to display:",
                      min = 1,
                      max = 200000,
                      value = 15),

        # Show table output
        mainPanel(
            tabsetPanel(
              tabPanel("Countries", DT::DTOutput("country_tbl")),
              tabPanel("Dyads", DT::DTOutput("dyad_tbl")),
              tabPanel("Events", DT::DTOutput("event_tbl"))
            )
        )
    )



# Define server logic
server <- function(input, output) {
  
  # Country table
  table_country <- DT::renderDT({
    
    # sqllite
    # Be sure the data file must be in same folder
    sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname ='int_relations.db')
    
    # Create SQL commmand to join variables from tables for query
    
    sqlite_sql="SELECT * FROM country"
    
    conn=sqlite_conn
    str_sql = sqlite_sql
    
    on.exit(dbDisconnect(conn), add = TRUE)
    table_df = dbGetQuery(conn, paste0(str_sql, " LIMIT ", input$nrows, ";"))
  }, escape = FALSE,)
  
  # Dyad table
  table_dyad <- DT::renderDT({
    
    # sqllite
    # Be sure the data file must be in same folder
    sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname ='int_relations.db')
    
    # Create SQL commmand to join variables from tables for query
    
    sqlite_sql="SELECT * FROM dyad"
    
    conn=sqlite_conn
    str_sql = sqlite_sql
    
    on.exit(dbDisconnect(conn), add = TRUE)
    table_df = dbGetQuery(conn, paste0(str_sql, " LIMIT ", input$nrows, ";"))
  }, escape = FALSE,)
  
  # Event table
  table_event <- DT::renderDT({
    
    # sqllite
    # Be sure the data file must be in same folder
    sqlite_conn <- dbConnect(RSQLite::SQLite(), dbname ='int_relations.db')
    
    # Create SQL commmand to join variables from tables for query
    
    sqlite_sql="SELECT * FROM event"
    
    conn=sqlite_conn
    str_sql = sqlite_sql
    
    on.exit(dbDisconnect(conn), add = TRUE)
    table_df = dbGetQuery(conn, paste0(str_sql, " LIMIT ", input$nrows, ";"))
  }, escape = FALSE,)
  
  output$country_tbl <- table_country
  output$dyad_tbl <- table_dyad
  output$event_tbl <- table_event
}



# Run the application 
shinyApp(ui = ui, server = server)



# Deploy
#rsconnect::setAccountInfo(name='yourShinyappsaccount', token='*', secret='*')