library(DT)
library(dplyr)
library(ggplot2)
library(forcats)
library(plotly)
library(janitor)
library(scales)
library(tidyr)
library(stringr)

data <- readxl::read_excel("data/progress_report.xlsx", sheet = "collected") %>% clean_names() %>% 
  mutate(across(contains("pct"), ~ . * 100)) 

county_by_state <- read.csv("data/county_by_state.csv") %>% clean_names() %>% 
  select(-1)
municipality_by_state <- read.csv("data/municipality_by_state.csv")%>% clean_names() %>% 
  select(-1)
school_by_state <- read.csv("data/school_by_state.csv")%>% clean_names() %>% 
  select(-1)

county_by_state %>% colnames()
municipality_by_state %>% colnames()
school_by_state %>% colnames()
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

test2 <- read.csv("data/test2.csv")
##### coverage by state####

create_coverage_chart <- function(df, metric = c("pop", "count")) {
  metric <- match.arg(metric)
  
  df <- df %>% 
    mutate(
      coverage = ifelse(metric == "pop", pop_pct_accounted, count_pct_accounted),
      State = state.abb
    )
  
  ggplot(df, aes(x = fct_reorder(State, coverage), y = coverage)) +
    geom_col(fill = "#05407F") +
    coord_flip() +
    labs(
      y = ifelse(metric == "pop", "% Population Covered", "% Entities Covered"),
      x = "State",
      title = "ACFR Coverage by State"
    ) +
    theme_minimal()
}





####View all entities by state####


state_data <- readRDS("data/state_data.rds") %>% 
  mutate(entity_type = "state",
         flg_muni = NA, 
         flg_backfilled = NA, 
         flg_county = NA)

county_data <- readRDS("data/county_data.rds") %>% 
  mutate(entity_type = "county", 
         flg_county = NA)

municipal_data <- readRDS("data/municipal_data.rds") %>% 
  select(-c(latitude, longitude)) %>% 
  mutate(entity_type = "municipality", 
         flg_muni = NA, 
         flg_backfilled = NA,
         urban_population = NA,
         pct_urban_population = NA)

school_district_data <- readRDS("data/school_district_data.rds") %>% 
  select(-c(latitude, longitude, student_enrollment)) %>% 
  mutate(entity_type = "school_district",
         flg_muni = NA, 
         flg_backfilled = NA, 
         flg_county = NA,
         urban_population = NA,
         pct_urban_population = NA, 
         geo_id = NA)

all_entity <- rbind(state_data, county_data, municipal_data,
                    school_district_data) %>% 
  mutate(
    entity_level = case_when(
      grepl("school", entity_type, ignore.case = TRUE) ~ "School District",
      flg_county == 1 ~ "County",
      flg_muni == 1 ~ "Municipality",
      TRUE ~ "State Government"
    )
  ) %>% 
  select(-c(entity_id, document_url, entity_type, geo_id, state_abbr)) %>% 
  mutate(entity_name = tools::toTitleCase(entity_name)) %>% 
  select(state_name, entity_name, entity_level, everything())
