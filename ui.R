library(shiny)

# Define the UI
ui <- fluidPage(
  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "styles.css?v=1.0")
  ),
  
  div(class = "logo-container", 
      img(src = "logo.png", height = "30px", style = "margin-top: -1px; margin-right: 10px;")
  ),
  div(class = "top-bar", "ACFRS Data Progress Tracking"),
  
  # Countdown box positioned absolutely
  div(class = "countdown-box",
      p("Weeks till target date 09/30/24:"),
      div(class = "weeks", uiOutput("countdown"))
  ),
  
  div(style = "margin-top: 100px;",
  sidebarLayout(
    sidebarPanel(
      selectInput("category", "Select Category:", 
                  choices = c("state", "county", "city", "school")),
      selectInput("metric", "Select Metric:", 
                  choices = c("Count" = "count", "Population" = "population"))
    ),
    
    mainPanel(
      plotOutput("bulletChart"),
      
    )
  )
),

div(style = "margin-top: 100px;",
    fluidRow(
      column(6,
             selectInput("entity_type", "List of Missing Entity:",
                         choices = c("State", "County", "City", "School District"),
                         selected = "State")
      ),
      column(6,
             selectInput("year", "Select Year:",
                         choices = c("2020", "2021", "2022", "2023"),
                         selected = "2023")
        )
      )
    ),

div(style = "margin-top: 20px;",
    uiOutput("missingEntities")
),

div(class = "bottom-space")



)
