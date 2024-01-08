  library(here)
  library(config)
  library(httr2)
  library(lubridate)
  library(readr)
  library(dplyr)
  
  config <- config::get(file = here("_auth/config.yaml"))
  
  # Fetch data from the GHCND dataset (Daily Summaries) SNOW based on stationid
  get_snow_data <- function(year, station){
    weather_query <- paste0("https://www.ncdc.noaa.gov/cdo-web/api/v2/data?", 
                          "datasetid=GHCND&datatypeid=SNOW&stationid=", station, "&units=standard&startdate=", 
                          year,"-01-01&enddate=", year,"-12-31&limit=1000")
    
    ###Optional. Accepts a valid station id or a chain of of station ids separated by ampersands. Data returned will contain data for the station(s) specified.
    
    req <- httr2::request(weather_query) |> 
      httr2::req_headers(Token = config$noaa_token) |>
      httr2::req_retry(max_tries = 3)
    
    resp <- httr2::req_perform(req) 
    
    # resp |> resp_content_type() ##returns JSON by default!!
    
    data <- resp |> resp_body_json(simplifyVector = TRUE)

    df <- data$results[c("date", "value", "station")]
    
    return(df)
  }
  
  ### DC weather stations that have high coverage and data from 1998 to 2022!
  bwi <- 'GHCND:USW00093721' ## [1939-07-01	to 2024-01-03]
  arbo <- 'GHCND:USC00186350' ## National Arboretum  [1948-08-01	2023-11-30]
  iad <-  'GHCND:USW00093738' ## [1960-04-01	2024-01-03]
  ## DCA: GHCND:USW00013743 [1936-09-01	to 2024-01-03]
  ## Sterling, VA: GHCND:USC00448084
  ## Damascus, MD GHCND:USC00182336

  all_snow_data <- c()
  
  for(i in c(1998:2022)){
    print(i)
    df <- get_snow_data(i, station = paste(bwi, arbo, iad, sep = '&stationid='))
    all_snow_data <- base::rbind(all_snow_data, df)
  }
  rm(i)
  
  all_snow_data$date <- lubridate::as_date(all_snow_data$date)
  
  readr::write_csv(all_snow_data, here("data/dc_snow_data_3stations.csv"))
  
  all_snow_data_aggregated <- all_snow_data |> 
    dplyr::group_by(date) |>
    dplyr::summarize(mean_snow_inch = mean(value))
  
  readr::write_csv(all_snow_data_aggregated, here("data/dc_snow_data.csv"))
  