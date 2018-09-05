  # Set working directory  
  setwd("C:/Users/Anna V/Desktop/R_Stuff/OPM/")
  
  # Libraries
  library(ggplot2)
  library(lubridate)
  theme_set(theme_bw())
  
  # Load Data
  # this website was useful: https://statistics.berkeley.edu/computing/r-reading-webpages
  page <-  readLines("https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/")
  
  page <- page[page != ""]
  mypattern <-  "\t<a href=([^<]*)</a>"
  datalines <- grep(mypattern, page[1:length(page)], value= TRUE)
  datalines <- tolower(datalines)
  
  opm <- as.data.frame(datalines)
  colnames(opm) <- "lines"
  
  opm$lines <- gsub("<a href=", "", opm$lines)
  opm$lines <- substring(opm$lines, 9)
  
  oth <- read.csv("opm_stuff.csv", header = TRUE)
  
  # Merge Datasets
  opm <- merge(opm, oth, by = "lines", all = TRUE)
  rm(oth, mypattern)
  opm <- subset(opm, delete == FALSE, drop = TRUE)
  
  opm$appl_date <- as.Date(opm$appl_date, "%m/%d/%Y")
  opm$year <- substr(opm$appl_date, start = 1, stop = 4)
  opm$year <- as.numeric(opm$year)
  opm$path <- as.character(opm$path)
  opm$path <- paste0("https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/", opm$path)
  opm <- opm[ ,c(1:3, 5)]
  
  opm$freq <- 1  
  opm <- opm[order(as.Date(opm$appl_date, "%y/%m/%d")), ]
  
  #opm$stat_date <- " "
  #opm$stat_date <- substr(opm$lines, start = 1, stop = 8)
  #opm$stat_date <- gsub("[[:alpha:]]", "", opm$date)
  #opm$stat_date <- substr(opm$stat_date, 1, nchar(opm$date)-1)
  #opm$stat_date <- as.Date(opm$stat_date, "%y/%m/%d")

  opm$open <- grepl("open", opm$lines)
  opm$closed <- grepl("closed", opm$lines)
  opm$ul <- grepl("unscheduled-leave", opm$lines)
  opm$shut <- grepl("lapse-in-appropriations", opm$lines)
  opm$ed <- grepl("early-dismissal", opm$lines)
  opm$da <- grepl("delayed-arrival", opm$lines)
  
  opm$status <- " "
  opm$status[opm$open == TRUE] <- "Open"
  opm$status[opm$closed == TRUE] <- "Closed"
  opm$status[opm$ul == TRUE] <- "Unscheduled Leave"
  opm$status[opm$shut == TRUE] <- "Shutdown"
  opm$status[opm$ed == TRUE] <- "Early Dismissal"
  opm$status[opm$da == TRUE] <- "Delayed Arrival"
  
  opm <- opm[ , c(1:5,12)]
  
  opm$status[grepl("tuesday-june-23", opm$lines) == TRUE] <- "Open"
  opm$status[grepl("/unscheduled-leave-", opm$lines) == TRUE] <- "Unscheduled Leave"
  
  opm$status[opm$status == " "] <- "Other"
  
  opm$status <- as.factor(opm$status)

  # -----------------------------------------------------------------#
    # Show data from: https://www.ncdc.noaa.gov/cdo-web/ & https://www.ncdc.noaa.gov/cdo-web/search 
  # All snow data is from the DCA weather station, load snow data
  snow <- read.csv("snow_original.csv", header = TRUE)
  snow$DATE <- as.Date(snow$DATE, "%m/%d/%Y")
  snow$name <- paste(snow$NAME, snow$STATION, sep = " - ")
  snow <- snow[ , c(3:6)]
  snow <- snow[ , c(4, 1:3)]
  colnames(snow) <- c( "name", "appl_date", "snow", "snwd")
  snow$day <- weekdays(as.Date(snow$appl_date))
  snow <- snow[ , c(1:2,5,3:4)]
  
  # -----------------------------------------------------------------#
    # Merge OPM and Snow datasets
  both <- merge(snow, opm,  by = "appl_date", all.x = TRUE, all.y = TRUE)
  both$year <- substr(both$appl_date, start = 1, stop = 4)
  both$year <- as.numeric(both$year)
  both$freq[is.na(both$freq)] <- 0
  
  # Re-order datasets to make more sense
  both <- both[ , c(1, 3, 8, 10, 9, 4, 5, 2, 6, 7)]
  
  # Create Quarter variables with year and without year
  both$yq <- quarter(both$appl_date, with_year = TRUE)
  both$q <- quarter(both$appl_date, with_year = FALSE)
  
  # Re-order quarter variables to be nearer to the date variable
  both <- both[ , c(1:3,11,12, 4:10)]
 
  # Generating a month Variable
  both$mo <- substr(both$appl_date, start = 6, stop = 7)
  both <- both[ , c(1:2,13,3:12)]
  
  # Generating a weekend
  both$status <- as.character(both$status)
  both$status[both$day == "Saturday"] <- "Weekend"
  both$status[both$day == "Sunday"] <- "Weekend"
  both$status[is.na(both$status)] <- "NA"
  both$status <- as.factor(both$status)
  both$d <- as.POSIXlt(both$appl_date , format = "%Y-%m-%d")
  
  # -----------------------------------------------------------------#
  # Boxplot of Snow Fall by Year
  boxplot(snow~year,data = winter, main = "Snow by Year ", 
          xlab = "Year", ylab = "Snow Fall")
  
  color <- c("Shutdown" = "#9b0020", # Deep Red
             "Closed" = "#be1337", # RED
             "Early Dismissal" = "#da8707", # ORANGE
             "Delayed Arrival" = "#f5d415", # YELLOW
             "Unscheduled Leave" = "#71f23a", # GREEN 
             "Open" = "#00b050", # GREEN
             "Other" = "#a2a4a1", #Silver
             "NA" = "#e2e2e2", # Grey
             "Weekend" = "#0e1111" # Black 
            )
  breaks <- c("Shutdown", "Closed", "Delayed Arrival", 
              "Early Dismissal", "Unscheduled Leave", 
              "Open", "Other", "NA", "Weekend")

  # Scatterplot of Snow Fall and Government Operating Status
  ggplot(winter, aes(d, snow, color = status)) + 
    theme_bw() + 
    geom_point(size = 3) +
    scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
    scale_x_datetime(breaks = date_breaks("year")) + 
    theme(text = element_text(size = 10), 
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_color_manual(values = color) + 
    labs(title = "Snow Fall and Government Operating Status", 
         x = "Days (December-March)",
         y = "Snowfall in inches",
         subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
         caption = "data sources: https://www.ncdc.noaa.gov/cdo-web/ and https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/")
  
  # Barchart of Snow Fall and Government Operating Status
  ggplot(winter, aes(d, snow)) + 
    theme_bw() + 
    #geom_point(size = 3) +
    geom_bar(stat="identity", aes(fill = status)) +
    scale_y_continuous(breaks = c(0,3,6,9,12,15), limits = c(0,15)) +
    scale_x_datetime(breaks = date_breaks("year")) + 
    theme(text = element_text(size = 10), 
          axis.text.x = element_text(angle = 45, hjust = 1)) +
    scale_fill_manual(values = color) + 
    labs(title = "Snow Fall and Government Operating Status", 
         x = "Days (December-March)",
         y = "Snowfall in inches",
         subtitle = "Measured at Ronald Reagan International Airport (DCA): USW00013743",
         caption = "data sources: https://www.ncdc.noaa.gov/cdo-web/ and https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/")
