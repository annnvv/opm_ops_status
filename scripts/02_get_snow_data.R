  library(here)
  library(config)
  library(httr)
  library(jsonlite)
  library(lubridate)
  library(readr)
  
  config <- config::get(file = here("_auth/config.yaml"))
  
  # Fetch data from the GHCND dataset (Daily Summaries) SNOW for Station ID USW00013743 (Ronald Reagan Airport)
  get_snow_data <- function(year){
    weather_query <- paste0("https://www.ncdc.noaa.gov/cdo-web/api/v2/data?", 
                          "datasetid=GHCND&datatypeid=SNOW&stationid=GHCND:USW00013743&units=standard&startdate=", 
                          year,"-01-01&enddate=", year,"-12-31&limit=1000")
    
    data <- httr::GET(weather_query, add_headers(Token = config$noaa_token))
    # httr::status_code(data)
    
    data_text <- httr::content(data, "text")
    data_parsed <- jsonlite::fromJSON(data_text) 
    df <- data_parsed$results[c("date", "value")]
    
    return(df)
  }

  all_snow_data <- c()
  
  for(i in c(1998:2022)){
    print(i)
    df <- get_snow_data(i)
    all_snow_data <- base::rbind(all_snow_data, df)
  }
  rm(i)
  
  all_snow_data$date <- lubridate::as_date(all_snow_data$date)
  
  readr::write_csv(all_snow_data, here("data/dc_snow_data.csv"))
  
  