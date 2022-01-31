  library(here)
  library(readr)
  library(dplyr)
  library(ggplot2)
  library(scales)
  library(magrittr)
  # library(gganimate)
  # library(magick)
  theme_set(theme_bw())
  
  df <- readr::read_csv(here("data/opm_and_snow_data.csv"))
  
  for(y in min(year(df$date)):max(year(df$date))){
    print(paste0("Year ", y), digits = 1)
    print(summary(df[df$year == y, "value"]))
  }
  
  for(y in min(year(df$date)):max(year(df$date))){
    print(paste0("Year ", y), digits = 1)
    print(summary(df[df$year == y & df$winter == 1, "value"]))
  }

  
  # Static Scatterplot of Snow Fall and Government Operating Status
  color <- c("Shutdown" = "#9b0020", # Deep Red
             "Closed" = "#be1337", # RED
             "Early Dismissal" = "#da8707", # ORANGE
             "Delayed Arrival" = "#f5d415", # YELLOW
             "Unscheduled Leave" = "#71f23a", # GREEN 
             "Open" = "#00b050", # GREEN
             "Other" = "#a2a4a1", #Silver
             #"NA" = "#e2e2e2", # Grey
             "Weekend" = "#0e1111" # Black 
  )
  
  breaks <- c("Shutdown", "Closed", "Delayed Arrival", 
              "Early Dismissal", "Unscheduled Leave", 
              "Open", "Other",  "Weekend")#"NA",
  
  df %>% dplyr::filter(winter == 1 & !is.na(status)) %>% 
  ggplot(aes(x = date, y = value, color = status)) + 
    theme_bw() + 
    geom_point(size = 2) +
    scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
    # scale_x_datetime(breaks = scales::breaks_width("year")) + 
    theme(text = element_text(size = 10), 
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_color_manual(values = color) + 
    labs(title = "Snow Fall and Government Operating Status", 
         x = "Days (December-March)",
         y = "Snowfall in inches",
         subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
         caption = "data sources: https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/ and \nhttps://www.ncdc.noaa.gov/cdo-web/") 
  
  
  # Loop through the static images by each winter season and generate a PNG
  seasons <- unique(df$season)
  seasons <- seasons[c(1,3:26)]

  for(y in seasons){
    print(y)
    ggplot(df[df$season == y, ], aes(date, value, color = status)) + 
      theme_bw() + 
      geom_point(size = 2) +
      scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
      # scale_x_datetime(breaks = date_breaks("month")) + 
      theme(text = element_text(size = 10), 
            axis.text.x = element_text(angle = 45, hjust = 1)) +
      scale_color_manual(values = color) + 
      labs(title = paste0("Snow Fall and Government Operating Status ", y), 
           x = "Days (December-March)",
           y = "Snowfall in inches",
           subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
           caption = "data sources: https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/ and https://www.ncdc.noaa.gov/cdo-web/") 
    
    ggsave(paste0("images/", y, ".png"), plot = last_plot(),
           width = 32, height = 20, units = "cm", dpi = 320)
  }
  