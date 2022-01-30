  rm(list = ls())
  
  # Set working directory  
  setwd("C:/Users/Anna V/Documents/GitHub/opm_ops_status")
  
  # Load Libraries
  library(ggplot2)
  library(scales)
  library(gganimate)
  library(magick)
  theme_set(theme_bw())
  
  winter <- read.csv("data/final_dataset.csv", stringsAsFactors = FALSE)
  winter$d <- as.POSIXct(winter$appl_date, format = "%Y-%m-%d")
  
  # Boxplot of Snow Fall by Year
  # "2003, 2010, and 2016 had days were there was more than 10 inches of snow"
  boxplot(snow~year,data = winter, main = "Snow by Year ", 
          xlab = "Year", ylab = "Snow Fall")
  
  # summary statistics of snow fall for each year
  for(y in 1998:2018){
    print(paste0("Year ", y), digits = 1)
    print(summary(winter[winter$year == y, "snow"]))
  }
  
  # -----------------------------------------------------------------#
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
  
  ggplot(winter, aes(d, snow, color = status)) + 
    theme_bw() + 
    geom_point(size = 2) +
    scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
    scale_x_datetime(breaks = date_breaks("year")) + 
    theme(text = element_text(size = 10), 
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_color_manual(values = color) + 
    labs(title = "Snow Fall and Government Operating Status", 
         x = "Days (December-March)",
         y = "Snowfall in inches",
         subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
         caption = "data sources: https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/ and \nhttps://www.ncdc.noaa.gov/cdo-web/") 
  
  # ANIMATED Scatterplot of Snow Fall and Government Operating Status
  animated <- ggplot(winter, aes(d, snow, color = status)) + 
    theme_bw() + 
    geom_point(size = 2) +
    scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
    scale_x_datetime(breaks = date_breaks("year")) + 
    scale_x_discrete(drop = F) +
    theme(text = element_text(size = 10), 
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_color_manual(values = color) + 
    labs(title = "Snow Fall and Government Operating Status", 
         x = "Days (December-March)",
         y = "Snowfall in inches",
         subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
         caption = "data sources: https://www.ncdc.noaa.gov/cdo-web/ and https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/") +
    transition_states(year, 
                      #transition_length = 5, 
                      state_length = c(rep(0.25, 21), 20), wrap = TRUE) + 
    ease_aes('quartic-in-out')
  
  animate(animated, fps = 0.5, width = 800, height = 495) 
  anim_save(filename = "images/opm_operating_status_snow.gif")
  
  # Loop through the static images by each winter season and generate a PNG
  seasons <- unique(winter$season)
  for(y in seasons){
    print(y)
    ggplot(winter[winter$season == y, ], aes(d, snow, color = status)) + 
      theme_bw() + 
      geom_point(size = 2) +
      scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
      scale_x_datetime(breaks = date_breaks("month")) + 
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
  
  # put images together to create a gif, based on code from: 
  #https://stackoverflow.com/questions/53401370/very-confused-about-how-to-merge-two-images-to-create-a-gif
  
  list.files(path = paste0(getwd(), "/images"), pattern = "*.png", full.names = T) %>% 
    image_read %>% # reads each image file
    image_join() %>% # joins image
    image_animate(fps=0.05) %>% # animates, can opt for number of loops
    image_write("merged_pngs.gif")
  
  # -----------------------------------------------------------------#
  # # Barchart of Snow Fall and Government Operating Status
  # # av.note: doesn't look great hard to see data
  # ggplot(winter, aes(d, snow)) + 
  #   theme_bw() + 
  #   #geom_point(size = 3) +
  #   geom_bar(stat="identity", aes(fill = status)) +
  #   scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
  #   scale_x_datetime(breaks = date_breaks("year")) + 
  #   theme(text = element_text(size = 10), 
  #         axis.text.x = element_text(angle = 45, hjust = 1)) +
  #   scale_fill_manual(values = color) + 
  #   labs(title = "Snow Fall and Government Operating Status", 
  #        x = "Days (December-March)",
  #        y = "Snowfall in inches",
  #        subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
  #        caption = "data sources: https://www.ncdc.noaa.gov/cdo-web/ and https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/")
