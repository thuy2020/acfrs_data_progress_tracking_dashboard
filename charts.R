library(DT)
library(dplyr)
library(ggplot2)
library(forcats)
library(plotly)
library(janitor)
library(scales)
library(tidyr)
library(stringr)

data <- readxl::read_excel("data/progress_report.xlsx") %>% 
  filter(!category %in% c("municipalities_all_place_division", 
                          "municipalities_incorporated", "municipalities_incorporated_others", 
                          "municipalities_others")) %>% clean_names() %>% 
  mutate(across(contains("pct"), ~ . * 100)) 

#data %>% View()

#########Bullet chart################
create_bullet_chart <- function(entityType, metric) {
  # Define the columns to select based on the metric
  if (metric == "count") {
    universal_col <- "universal_count"
    collected_col <- "collected_count"
    pct_col <- "pct_count_collected"
  } else if (metric == "population") {
    universal_col <- "universal_population"
    collected_col <- "collected_population"
    pct_col <- "pct_population_collected"
  } else {
    stop("Invalid measure specified. Use 'count' or 'population'.")
  }
  
  # Filter and select relevant columns
  filtered_data <- data %>%
    filter(category == entityType) %>% 
    select(category, year, !!sym(universal_col), !!sym(collected_col), !!sym(pct_col)) 
  
  # Create the bullet chart
  ggplot(filtered_data, aes(x = year)) +
    geom_bar(aes_string(y = universal_col), stat = "identity", fill = "lightgray", width = 0.8) +
    geom_bar(aes_string(y = collected_col), stat = "identity", fill = "#05407F", width = 0.5) +
    geom_text(aes_string(y = collected_col, label = paste0("scales::comma(", collected_col, ")")), 
              vjust = -0.3, hjust = 2, color = "white") +
    geom_text(aes_string(y = universal_col, label = paste0("sprintf('%.0f%%', ", pct_col, ")")), 
               vjust = -0.3, hjust = -0.1, color = "black") +
    labs(title = paste("Total vs. Collected", metric ,"for", entityType),
         caption = paste("Total", metric, ":", filtered_data[1, 3]),
         y = "Count",
         x = "") +
    coord_flip() +
    theme_minimal()
}



#########Top 100#########

