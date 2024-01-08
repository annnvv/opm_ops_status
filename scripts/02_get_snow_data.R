  library(here)
  library(config)
  library(httr2)
  library(jsonlite)
  library(lubridate)
  library(readr)
  
  config <- config::get(file = here("_auth/config.yaml"))
  
  # Fetch data from the GHCND dataset (Daily Summaries) SNOW for Station ID USW00013743 (Ronald Reagan Airport)
  get_snow_data <- function(year, station){
    weather_query <- paste0("https://www.ncdc.noaa.gov/cdo-web/api/v2/data?", 
                          "datasetid=GHCND&datatypeid=SNOW&stationid=", station, "&units=standard&startdate=", 
                          year,"-01-01&enddate=", year,"-12-31&limit=1000")
    
    req <- httr2::request(weather_query) |> 
      httr2::req_headers(Token = config$noaa_token) |>
      httr2:req_retry(max_tries = 3)
    
    resp <- httr2::req_perform(req) 
    
    # resp |> resp_content_type() ##returns JSON by default!!
    
    data <- resp |> resp_body_json(simplifyVector = TRUE)

    df <- data$results[c("date", "value")]
    
    return(df)
  }

  all_snow_data <- c()
  
  for(i in c(1998:2022)){
    print(i)
    df <- get_snow_data(i, station = 'GHCND:USW00013743')
    all_snow_data <- base::rbind(all_snow_data, df)
  }
  rm(i)
  
  all_snow_data$date <- lubridate::as_date(all_snow_data$date)
  
  readr::write_csv(all_snow_data, here("data/dc_snow_data.csv"))
  
  