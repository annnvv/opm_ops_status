  rm(list = ls())
  
  # Set working directory  
  setwd("C:/Users/Anna V/Documents/GitHub/opm_ops_status")
  
  # Load Libraries
  library(glmnet)
  # library(ggplot2)
  # library(scales)
  # library(gganimate)
  # library(magick)
  # theme_set(theme_bw())
  
  df_all <- read.csv("data/final_dataset.csv", stringsAsFactors = FALSE)
  df_all$d <- as.POSIXct(winter$appl_date, format = "%Y-%m-%d")

  df <- df_all[ , c('d', 'status', 'snow')]

  df$status[is.na(df$status)] <- 'Open'  
  df <- df[complete.cases(df), ]
  table(df$status, useNA = 'ifany')  

  df$closed <- 'Open'
  df$closed[df$status != 'Closed'] <- 'Not Open'
  df$closed <- as.factor(df$closed)
  
  table(df$closed, useNA = 'ifany')  
  
  df$snow_lag <- stats::lag(df$snow, k = 1)

  lm_fit <- lm(as.formula('closed ~ snow + snow_lag'), data = df)
  summary(lm_fit)
  