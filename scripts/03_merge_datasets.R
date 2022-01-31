  library(here)
  library(readr)
  library(lubridate)
  
  opm_df <- readr::read_csv(here("data/opm_status_data.csv"))
  snow_df <- readr::read_csv(here("data/dc_snow_data.csv"))

  df <- base::merge(snow_df, opm_df, by = c("date"), all.x = TRUE, all.y = FALSE)
  
  ## year
  df$year <- lubridate::year(df$date)
  
  ## date of week
  df$dow <- lubridate::wday(df$date, label = TRUE, abbr = TRUE)
  
  ## weekend
  df$weekend <- ifelse(df$dow == "Sat" | df$dow == "Sun", 1, 0)
  
  ## winter months
  df$winter <- ifelse(lubridate::month(df$date) == 12 | 
                        lubridate::month(df$date) == 1| 
                        lubridate::month(df$date) == 2| 
                        lubridate::month(df$date) == 3, 1, 0)
  
  ## winter season label
  df$season <- NA
  for(y in 1997:2022){
    df$season[df$date >= paste0(y, "-12-01") & df$date < paste0(y+1, "-04-01")] <- paste0("winter ", y, "-", y+1)
  }
  rm(y)
  
  readr::write_csv(df, here("data/opm_and_snow_data.csv"))
  