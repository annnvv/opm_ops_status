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
  
  ## Fix data quality issues (on merging the datasets noticed these issues) 
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/00/1/25/Closed_35/"] <- "2000-01-26"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/06/6/26/Unscheduled-Leave_146/"] <- "2006-06-27"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/06/6/27/Unscheduled-Leave_156/"] <- "2006-06-28"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/07/2/14/Unscheduled-Leave_180/"] <- "2007-02-15"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/10/2/4/Unscheduled-LeaveEarly-Dismissal_229/"] <- "2010-02-05"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/11/2/1/Open-with-option-for-Unscheduled-Leave-or-Unscheduled-Telework_350/"] <- "2011-02-02"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/13/1/24/Open-with-Option-for-Unscheduled-Leave-or-Unscheduled-Telework_498/"] <- "2013-01-25"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/13/3/6/Open_521/"] <- "2013-03-07"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/14/1/21/Open---2-hours-Delayed-Arrival---With-Option-for-Unscheduled-Leave-or-Unscheduled-Telework_581/"] <- "2014-01-22"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/17/3/14/Open_742/"] <- "2017-03-15"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/18/3/21/Open---2-hours-Delayed-Arrival---With-Option-for-Unscheduled-Leave-or-Unscheduled-Telework_822/"] <- "2018-03-22"
  opm$date[opm$path == "https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/19/1/29/Open---3-hours-Delayed-Arrival---With-Option-for-Unscheduled-Leave-or-Unscheduled-Telework_881/"] <- "2019-01-30"
  
  ##note: not all dates are unique (five duplicates)
  length(unique(opm$date)) == length(nrow(opm))
  length(unique(opm$date))
  
  ## Write data to csv
  readr::write_csv(opm, here::here("data/opm_status_data.csv"))
  