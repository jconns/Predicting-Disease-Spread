# Predicting Disease Spread

# Introduction

This project is based on the competition Driven Data had published about predicting disease spread in San Juan, Puerto Rico and Iquitos, Peru. The government agency, National Oceanic and Atmospheric Administration (NOAA), warned, “Accurate dengue predictions would help public health workers…and people around the world take steps to reduce the impact of these epidemics. But predicting dengue is a hefty task that calls for the consolidation of different data sets on disease incidence, weather, and the environment.”

# Objective

Our goal is to predict the total_cases label for each city, year, and weekofyear in the test set.

The result of the project was uploaded to score the predictions, which generated a response in the 66th percentile of 13,696 entries. I scored 29 while the best was 10.

# Dataset description:

Data for San Juan spans from 1990 to 2008 while Iquitos is from 2000-2010.


NOAA's GHCN daily climate data weather station measurements
•	station_max_temp_c – Maximum temperature
•	station_min_temp_c – Minimum temperature
•	station_avg_temp_c – Average temperature
•	station_precip_mm – Total precipitation
•	station_diur_temp_rng_c – Diurnal temperature range
PERSIANN satellite precipitation measurements (0.25x0.25 degree scale)
•	precipitation_amt_mm – Total precipitation
NOAA's NCEP Climate Forecast System Reanalysis measurements (0.5x0.5 degree scale)
•	reanalysis_sat_precip_amt_mm – Total precipitation
•	reanalysis_dew_point_temp_k – Mean dew point temperature
•	reanalysis_air_temp_k – Mean air temperature
•	reanalysis_relative_humidity_percent – Mean relative humidity
•	reanalysis_specific_humidity_g_per_kg – Mean specific humidity
•	reanalysis_precip_amt_kg_per_m2 – Total precipitation
•	reanalysis_max_air_temp_k – Maximum air temperature
•	reanalysis_min_air_temp_k – Minimum air temperature
•	reanalysis_avg_temp_k – Average air temperature
•	reanalysis_tdtr_k – Diurnal temperature range
Satellite vegetation - Normalized difference vegetation index (NDVI) - NOAA's CDR Normalized Difference Vegetation Index (0.5x0.5 degree scale) measurements
•	ndvi_se – Pixel southeast of city centroid
•	ndvi_sw – Pixel southwest of city centroid
•	ndvi_ne – Pixel northeast of city centroid
•	ndvi_nw – Pixel northwest of city centroid

# Exploratory Data Analysis (EDA):

There are 548 missing values spread relatively evenly across 21 of the 25 explanatory variables. I used (kNN) nearest neighbors matching to impute missing values.

Within EDA, my goal is to explore the nature of our target variable (total_cases) and its relationship with all possible explanatory variables.


For this purpose, I used regression analysis to determine appropriate variables for inclusion in our final models. Variables were also selected through inclusion in a model that proved to minimize the BIC criterion.

Show table of model results
I used a random forest classification model.

# Proof of Submission
<img width="468" alt="image" src="https://github.com/jconns/Predicting-Disease-Spread/assets/48659723/f8c688ee-b4c0-4b16-8e41-087cce210ccf">
