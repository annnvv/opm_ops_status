  library(here)
  library(rvest)
  library(dplyr)
  library(stringr)
  library(magrittr)
  library(lubridate)
  library(readr)
  
  ## Scrape OPM status page
  url <- "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/"
  page <-  rvest::read_html(url)
  
  ## Create dataframe
  opm <- page %>%
    rvest::html_nodes('a') %>% 
    rvest::html_attr('href') %>% 
    base::as.data.frame() %>% 
    dplyr::rename(raw_data = ".") %>% 
    dplyr::filter(base::grepl("^[0-9]", raw_data))
  
  ## Create path, date, and status columns
  opm %<>% 
    dplyr::mutate(path = base::paste0(url, raw_data),
                  date = lubridate::as_date(stringr::str_extract(opm$raw_data, "^[0-9]+/[0-9]+/[0-9]+")))

  opm$status <- base::ifelse(grepl("lapse-in-appropriations", opm$raw_data, ignore.case = TRUE), "Shut Down",
                       base::ifelse(grepl("delayed-arrival", opm$raw_data, ignore.case = TRUE), "Delayed Arrival",
                              base::ifelse(grepl("early-dismissal", opm$raw_data, ignore.case = TRUE), "Early Dismisssal",
                                     base::ifelse(grepl("early-departure", opm$raw_data, ignore.case = TRUE), "Early Dismisssal",
                                       base::ifelse(grepl("unscheduled-leave", opm$raw_data, ignore.case = TRUE), "Unscheduled Leave",
                                              base::ifelse(grepl("office-closure", opm$raw_data, ignore.case = TRUE), "Closed", 
                                                     base::ifelse(grepl("closed", opm$raw_data, ignore.case = TRUE), "Closed", 
                                                            base::ifelse(grepl("open", opm$raw_data, ignore.case = TRUE), "Open","UNKNOWN"))))))))
  
  
  table(opm$status)

  ## Statuses that were classified as UNKNOWN are not related to weather (upon manual review), 
  ## therefore can be safely dropped from the dataset
  opm %>% 
    dplyr::filter(status == "UNKNOWN") %>% 
    base::View()
  
  ## clean up dataframe
  opm %<>% 
    dplyr::select(-c(raw_data))
    dplyr::filter(status != "UNKNOWN") %>% 
    dplyr::filter(status != "Shut Down") ##dropping because also not related to weather
  
  ## write data to csv
  readr::write_csv(opm, here::here("data/opm_status_data.csv"))
  