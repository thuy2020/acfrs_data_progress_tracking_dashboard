library(shiny)
library(lubridate)
library(DT) 
source("charts.R")

missing_entities_data <- read.csv("data/missing_top300.csv", stringsAsFactors = FALSE) %>% 
  select(-1)

# Define test definitions
test_definitions <- list(
  "test_1" = "Test 1: Sum of (bonds_outstanding + loans_outstanding + notes_outstanding + net_pension_liability +net_opeb_liability) <= total_liabilities",
  "test_2" = "Test 2: total_liabilities > total_assets",
  "test_3" = "Test 3: Are revenues +/- 20% of expenditures"
 # "test_4" = "Test 4: Calculate percentage changes between years in all data fields and flag out big values. "
)

# Load CSV files
test_data_files <- list(
  "test_1" = read.csv("data/test1.csv", stringsAsFactors = FALSE),
  "test_2" = read.csv("data/test2.csv", stringsAsFactors = FALSE),
  "test_3" = read.csv("data/test3.csv", stringsAsFactors = FALSE)
 # "test_4" = read.csv("data/test4.csv", stringsAsFactors = FALSE)
)



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
  
  ########
  output$entity_coverage_table <- renderDT({
    req(input$entity_type_coverage)
    
    df <- switch(input$entity_type_coverage,
                 "county" = county_by_state,
                 "municipality" = municipality_by_state,
                 "school" = school_by_state)
    
    # Debugging: Print basic info to R console
    print(paste("Selected type:", input$entity_type_coverage))
    print(head(df))
    print(colnames(df))
    
    # Defensive fallback
    if (is.null(df) || nrow(df) == 0) {
      return(datatable(data.frame(Message = "No data available.")))
    }
    
    # Format and render table
    df %>%
      mutate(
        pop_pct_accounted = round(pop_pct_accounted, 1),
        count_pct_accounted = round(count_pct_accounted, 1)
      ) %>%
      rename(
        `State` = state_abb,
        `ACFR Population` = pop_acfr,
        `ACFR Count` = count_acfr,
        `Census Population` = pop_census,
        `Census Count` = count_census,
        `% Pop Covered` = pop_pct_accounted,
        `% Entities Covered` = count_pct_accounted
      ) %>%
      datatable(rownames = FALSE,
                options = list(pageLength = 10,
                               autoWidth = TRUE,
                               dom = 'tip'))
  })
  
  ######
  
  output$missingEntityTable <- renderDT({
    req(input$missing_category, input$missing_year)
    
    filtered_data <- missing_entities_data %>%
      filter(category == input$missing_category, year == input$missing_year)
    
    datatable(filtered_data, options = list(pageLength = 10), rownames = FALSE)
  })

  # Show the selected test description
  output$testDescription <- renderText({
    req(input$test_selection)
    test_definitions[[input$test_selection]]
  })
  
  # Show the selected test data table
  output$testTable <- renderDT({
    req(input$test_selection)
    datatable(test_data_files[[input$test_selection]], options = list(pageLength = 10), rownames = FALSE)
  })
  


filtered_entity <- reactive({
  
  df <- all_entity
  
  # Filter by state
  if (!is.null(input$state_filter) && length(input$state_filter) > 0) {
    df <- df %>% filter(state_name %in% input$state_filter)
  }
  
  # Filter by entity type
  if (!is.null(input$entity_filter) && length(input$entity_filter) > 0) {
    df <- df %>% filter(entity_level %in% input$entity_filter)
  }
  
  df
})

output$entity_table <- DT::renderDT({
  DT::datatable(
    filtered_entity(),
    options = list(
      pageLength = 20,
      scrollX = TRUE
    )
  )
})


output$download_entity_data <- downloadHandler(
  
  filename = function() {
    paste0(
      "acfr_entities_",
      Sys.Date(),
      ".csv"
    )
  },
  
  content = function(file) {
    
    df <- filtered_entity() 
    readr::write_csv(df, file)
  }
)
}