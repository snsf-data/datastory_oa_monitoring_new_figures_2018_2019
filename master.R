# This script produces all the files required to deploy an SNSF data story. 
# 
# Data story template: https://github.com/snsf-data/datastory_template
# 
# By running this file, the following components of a data story are generated
# and stored in the output directory: 
# 
# 1) a HTML file (self-contained), which contains all visualizations and 
#   images in encoded form, one for every specified language.
# 2) one file "metadata.json", which contains the metadata essential for 
#   the story (including all language versions in one file).
# 
# The files are stored in output/xxx, where xxx stands for the title of the
# data story in English, how it can also be used for the vanity URL to the 
# story, that means: no special characters, only lowercase.

# Unique name of this data story in English (all lowercase, underscore as 
# white-space, no special characters etc.)
datastory_name <- "oa_monitoring_new_figures_2018_2019"

# Language-specific names, do adapt! (used for vanity URL! Format: all 
# lowercase, minus as white-space (!) and no special characters, no special 
# characters etc.)
datastory_name_de <- "neue-zahlen-oa-monitoring-2018-19"
datastory_name_en <- "new-figures-oa-monitoring-2018-19"
datastory_name_fr <- "nouveaux-chiffres-oa-monitoring-2018-19"

# English title and lead of the story (Mandatory, even if no EN version)
title_en <- "New figures: 55% of publications from 2018 and 2019 are open access" 
short_desc_en <- "In some disciplines nearly all publications based on SNSF-funded research are in open access mode, in others still only a few. Overall, the share of open access publications is growing slowly but steadily." # Mandatory, even if no lang version
# German title and lead of the story (Mandatory, even if no DE version)
title_de <- "Neue Zahlen zu Open Access: 55% der Publikationen von 2018/19 sind frei zugänglich" 
short_desc_de <- "In einigen Disziplinen sind beinahe alle Publikationen aus SNF-geförderter Forschung Open Access, in anderen erst wenige. Insgesamt nimmt der Anteil weiter zu, wenn auch langsam." # Mandatory, even if no lang version
# French title and lead of the story (Mandatory, even if no FR version)
title_fr <- "Nouveaux chiffres : 55 % des publications de 2018 et 2019 sont en libre accès" 
short_desc_fr <- "Dans certaines disciplines de recherche financées par le FNS, presque toutes les publications sont en libre accès alors que dans d’autres, très peu le sont. Dans l’ensemble, la proportion de libre accès continue à progresser lentement." # Mandatory, even if no lang version
# Contact persons, always (first name + last name)
contact_person <- c("Tobias Philipp", "Julius Mattern")
# Mail address to be displayed as contact persons, put "datastories@snf.ch" for 
# every name of a contact person listed above.
contact_person_mail <- c("datastories@snf.ch", "datastories@snf.ch")
# One of the following categories:  "standard", "briefing", "techreport", 
# "policybrief", "flagship", "figure". Category descriptions are 
datastory_category <- "briefing"
# Date, after which the story should be published. Stories not displayed if the 
# date lies in the future. 
publication_date <- "2021-05-04 06:00:00"
# Available language versions in lowercase, possible: "en", "de", "fr".
languages <- c("de", "fr", "en") 
# Whether this story should be a "Feature Story" story
feature_story <- FALSE
# DOI of the story (optional)
doi <- ""
# URL to Github page (optional)
github_url <- "https://github.com/snsf-data/datastory_oa_monitoring_new_figures_2018_2019" 
# Put Tag IDs here. Only choose already existing tags. 
tags_ids <- c(10, 40, 220)

# IMPORTANT: Put a title image (as .jpg) into the output directory. 
# example: "output/datastory-template.jpg"

# Install pacman package if needed
if (!require("pacman")) {
  install.packages("pacman")
  library(pacman)
}

# Install snf.datastory package if not available, otherwise load it
if (!require("snf.datastory")) {
  if (!require("devtools")) {
    install.packages("devtools")
    library(devtools)
  }
  install_github("snsf-data/snf.datastory")
  library(snf.datastory)
}

# Load packages
p_load(tidyverse,
       scales, 
       conflicted, 
       jsonlite, 
       here)

# Conflict preferences
conflict_prefer("filter", "dplyr")

# Function to validate a mandatory parameter value
is_valid <- function(param_value) {
  if (is.null(param_value))
    return(FALSE)
  if (is.na(param_value))
    return(FALSE)
  if (str_trim(param_value) == "")
    return(FALSE)
  return(TRUE)
}

# Validate parameters and throw error message when not correctly filled
if (any(!is_valid(datastory_name), 
        !is_valid(title_en),
        !is_valid(title_de),
        !is_valid(title_fr), 
        !is_valid(datastory_category),
        !is_valid(publication_date), 
        length(languages) < 1,
        !is_valid(short_desc_en), 
        !is_valid(short_desc_de), 
        !is_valid(short_desc_fr)))
  stop("Incorrect value for at least one of the mandatory metadata values.")

# # Throw warning when there is not file in the /thumbnail directory
# thumbnail_data <- NULL
# thumbnail_filelist <- list.files(here("thumbnail"))
# if (length(thumbnail_filelist) == 0) {
#   warning("No thumbnail yet found! Please add to /thumbnail directory")
# } else {
#   # Load the first file as raw to later include it as base64 encoded string
#   # into the metadata.json
#   thumbnail_data <- read_file_raw(here("thumbnail", thumbnail_filelist[1]))
# }

# Create output directory in main directory
if (!dir.exists(here("output")))
  dir.create(here("output"))

# Create story directory in output directory
if (!dir.exists(here("output", datastory_name)))
  dir.create(here("output", datastory_name))

# Create a JSON file with the metadata and save it in the output directory
tibble(
  title_en = title_en, 
  title_de = title_de, 
  title_fr = title_fr, 
  author = paste(contact_person, collapse = ";"), 
  datastory_category = datastory_category, 
  publication_date = publication_date, 
  languages = paste(languages, collapse = ";"),
  short_desc_en = short_desc_en, 
  short_desc_de = short_desc_de, 
  short_desc_fr = short_desc_fr, 
  tags = paste(paste0("T", tags_ids, "T"), collapse = ","), 
  author_url = paste(contact_person_mail, collapse = ";"), 
  top_story = feature_story, 
  github_url = github_url, 
  doi = doi
) %>%  
  toJSON() %>%  
  write_lines(here("output", datastory_name, "metadata.json"))

# Generate HTML output for each language version
for (idx in seq_len(length(languages))) {
  current_lang <- languages[idx]
  output_file <- here("output", datastory_name, 
                      paste0(str_replace_all(
                        get(paste0("datastory_name_", current_lang)), "_", "-"), 
                        "-", current_lang, ".html"))
  print(paste0("Generating output for ", current_lang, " version..."))
  rmarkdown::render(
    input = here(paste0(current_lang, ".Rmd")),
    output_file = output_file, 
    params = list(
      title = get(paste0("title_", current_lang)),
      publication_date = publication_date,
      doi = doi
    ),
    envir = new.env()
  )
  
  # # Generate raw text version of each story for the search feature
  # readLines(output_file)
  
  # # inputFile <- "
  # con  <- file(output_file, open = "r")
  # while (length(oneLine <- readLines(con, n = 1)) > 0) {
  #   myLine <- unlist((strsplit(oneLine, ",")))
  #   print(myLine)
  # }
  # close(con)
}