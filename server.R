library(shiny)
library(lubridate)
source("charts.R")

missing_entities_data <- read.csv("data/missing_entities.csv", stringsAsFactors = FALSE)

# Define the server logic
server <- function(input, output) {
  target_date <- as.Date("2024-09-30")
  today <- Sys.Date()
  weeks_remaining <- ceiling(as.numeric(difftime(target_date, today, units = "weeks")))
  
  output$countdown <- renderUI({
    tags$div(weeks_remaining)
  })
  
  output$bulletChart <- renderPlot({
    req(input$category, input$metric)
    
    print(input$category)  # Debugging: check input
    print(input$metric)  # Debugging: check input
    
    create_bullet_chart(input$category, input$metric)
  })
  
  output$missingEntities <- renderUI({
    req(input$entity_type, input$year)
    
    # Filter the data based on user selections
    filtered_data <- missing_entities_data %>%
      filter(entity_type == input$entity_type & year == as.numeric(input$year))
    
    if (nrow(filtered_data) > 0) {
      missing_list <- unlist(strsplit(filtered_data$missing_entities, ";"))
      
      div(
        p(paste("Missing", input$entity_type, "in the top 200, year", input$year, ":")),
        tags$ul(
          lapply(missing_list, function(entity) tags$li(entity))
        )
      )
    } else {
      p("No data available for the selected entity type and year.")
    }
  })
}

