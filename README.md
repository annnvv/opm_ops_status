# OPM Operating Status

**Status**: In progress of being updated

I scraped the OPM federal government operating status archive page to get the operating status between January 15, 1998 and January 27, 2022 (website found [here]( https://www.opm.gov/policy-data-oversight/snow-dismissal-procedures/status-archives/)). 

Then, I got Ronald Reagan National Airport snow totals from NOAA (data can be obtained [here](https://www.ncdc.noaa.gov/cdo-web/webservices/v2#gettingStarted)). 

I combined the two datasets and plotted the snow fall totals by date and federal government operating status.

## 2024 Update

I decided to refactor the code here a bit. For one reason, I read a WaPo article about the ['DC Snow Hole'](https://www.washingtonpost.com/weather/2023/12/27/dc-snow-hole/) (paywall) and realized that DCA might not be the best weather station to use for this analysis. Instead, I decided to aggregate snow data from three weather stations (BWI, IAD, and the National Arobretum). Another reason was that `httr` was deprecated and superseded by `httr2` and I wanted to learn more about `httr2`. 

When I ran the fourth visualization script, I discovered a weird pattern that for a lot of years, there is no data for December. I worked backwards and found that this data was not in my csv's. Eventually, I worked all the way back to the API call. Requesting 365 days of data per year for three weather stations means 1095 observations. The API has a max limit of 1000 observations. I have several options to solve this issue: requesting 1) fewer days or 2)fewer stations or 3) split the request in half (i.e. request half a year per API call) then append the data or 4)split the request by station then merge the data or 5) combination of some of those. 
