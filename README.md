# OPM Operating Status

**Status**: In progress of being updated

I scraped the OPM federal government operating status archive page to get the operating status between January 15, 1998 and January 27, 2022 (website found [here]( https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/)). 

Then, I got Ronald Reagan National Airport snow totals from NOAA (data can be obtained [here](https://www.ncdc.noaa.gov/cdo-web/webservices/v2#gettingStarted)). 

I combined the two datasets and plotted the snow fall totals by date and federal government operating status.

## 2024 Update

I decided to refactor the code here a bit. For one reason, I read a WaPo article about the ('DC Snow Hole')[https://www.washingtonpost.com/weather/2023/12/27/dc-snow-hole/] (paywall) and realized that DCA might not be the best weather station to use for this analysis. Instead, I decided to aggregate snow data from three weather stations (BWI, IAD, and the National Arobretum). Another reason was that `httr` was deprecated and superseded by `httr2` and I wanted to learn more about `httr2`. 
