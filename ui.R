library(shiny)
library(lubridate)
library(DT)
library(dplyr)
library(ggplot2)
library(forcats)
library(plotly)
library(janitor)
library(scales)
library(tidyr)
library(stringr)
library(readxl)
library(shinyjs)

# Define the UIrs
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css?v=1.0")
  ),
  
  div(class = "logo-container", 
      img(src = "logo.png", height = "30px", style = "margin-top: -1px; margin-right: 10px;")
  ),
  div(class = "top-bar", "ACFRS Data Progress Tracking"),
  
  
  div(style = "margin-top: 100px;",
  sidebarLayout(
    sidebarPanel(
      selectInput("category", "Select Category:", 
                  choices = c("state", "county", "municipality", "school")),
      selectInput("metric", "Select Metric:", 
                  choices = c("Count" = "count", "Population" = "population"))
    ),
    
    mainPanel(
      plotOutput("bulletChart")
      
    )
  )),
  
  # ===============================
  # NEW, SEPARATE FILTER SECTION
  # ===============================
  
  sidebarLayout(
    sidebarPanel(
      width = 3,
      
      h4("Filter by State & Entity"),
      
      selectInput(
        inputId = "state_filter",
        label = "Select State(s)",
        choices = sort(unique(all_entity$state_name)),
        multiple = TRUE
      ),
      
      checkboxGroupInput(
        inputId = "entity_filter",
        label = "Entity Type",
        choices = c(
          "State Government",
          "County",
          "Municipality",
          "School District"
        ),
        selected = c("County", "Municipality", "School District")
      )
    ),
    
    mainPanel(
      width = 9,
      DTOutput("entity_table"),
      
      downloadButton(
        outputId = "download_entity_data",
        label = "Download Selected Data"
      )
    )
  ),
  
  # ===============================
  # END NEW SECTION
  # ===============================

  div(style = "margin-top: 40px;",
      h3("Entity Coverage by State"),
      sidebarLayout(
        sidebarPanel(
          selectInput("entity_type_coverage", "Select Entity Type:",
                      choices = c("County" = "county", "Municipality" = "municipality", "School" = "school"),
                      selected = "county")
        ),
        mainPanel(
          DTOutput("entity_coverage_table"),
          div(class = "note-under-table",
            "Note: There are ten municipalities where the percentage of population covered exceeds 100%. 
     This occurs because the total municipal population only includes entities classified under codes 
     160, 162, 170, and 172. However, our system also captures entities with code 061 (Minor Civil Division), 
     leading to some overlap in population counts."
          )
        )
      )
  ),

  
  div(style = "margin-top: 40px;",
      h3("Missing Entities in Top 300"),
      sidebarLayout(
        sidebarPanel(
          selectInput("missing_category", "Select Category:", 
                      choices = c("state", "county", "municipality", "school")),
          selectInput("missing_year", "Select Year:", 
                      choices = 2020:2023)
        ),
        mainPanel(
          DTOutput("missingEntityTable")
        )
      )
  ),
  
  div(style = "margin-top: 40px;",
      h3("Test Data"),
      sidebarLayout(
        sidebarPanel(
          selectInput("test_selection", "Select Test:", 
                      choices = c("Test 1" = "test_1", 
                                  "Test 2" = "test_2", 
                                  "Test 3" = "test_3"
                                  #"Test 4" = "test_4"
                                  ))
        ),
        mainPanel(
          h4("Test Definition"),
          textOutput("testDescription"),
          h4("Test Data Table"),
          DTOutput("testTable")
        )
      )
  ),  

div(style = "margin-top: 20px;",
    uiOutput("missingEntities")
),

div(class = "bottom-space")

)
