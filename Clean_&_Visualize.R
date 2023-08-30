### libraries
library(readxl)
library(tsibble)
library(dplyr)
library(fpp3)

### data
sub <- read.csv("/Users/jackconnors/Downloads/submission_format_dengue.csv")
labels <- read.csv("/Users/jackconnors/Downloads/dengue_labels_train.csv")
feat <- read.csv("/Users/jackconnors/Downloads/dengue_features_train.csv")
test <- read.csv("/Users/jackconnors/Downloads/dengue_features_test.csv")

#### Look at NAs
unlist(lapply(training_set, function(x)sum(is.na(x))))

### how do we deal with missing values ?? 
library(mice)
library(VIM)

training_clean <- kNN(training_set, k=6)

sum(is.na(training_clean))

##table of desc stats
library(stargazer)
stargazer(training_clean,
          title="Table of Descriptive Statistics: Dengue Fever",
          iqr=T,
          digits=2,
          type="html",
          out="dengue.html")

###season plot
yearly_plot <- training_clean %>%
  fill_gaps(total_cases=mean(total_cases)) %>%
  gg_season(total_cases) +
  labs(title="Total Cases Seasonal Plot") +
  theme_bw()

###distribution
dist <- ggplot(training_clean) +
  geom_histogram(aes(total_cases,fill=1,
                     binwidth = 5)) +
  labs(title="Distribution of Case Values",
       y="Count",
       x="Total Cases") +
  theme_bw()

training_clean <- subset(training_clean, select = city:station_precip_mm)
dplyr::glimpse(training_clean)

### correlations and visualization  
### total_cases

###total_cases~ average_temp + humidity + precipitation

variables <- c("total_cases", "reanalysis_sat_precip_amt_mm",
               "station_avg_temp_c", "reanalysis_specific_humidity_g_per_kg")

subset_train <- training_clean[variables]

pairs(subset_train)

pairs.panels(subset_train)

### regsubset
library(leaps)
regsubsets <- regsubsets(total_cases ~ reanalysis_sat_precip_amt_mm +
                           station_avg_temp_c + reanalysis_specific_humidity_g_per_kg +
                           station_max_temp_c + reanalysis_air_temp_k + station_diur_temp_rng_c,
                         data=training_clean)

reg_sum <- summary(regsubsets)
which.min(reg_sum$bic)

plot(reg_sum$bic, xlab="# of Vars", ylab="BIC", type="l")
points(3,reg_sum$bic[3], col="red", cex=2, pch=20)

plot(regsubsets, scale="bic")
coef(regsubsets, 3)

### look for endogeneity within variables
vars_subset <- c("total_cases", "station_max_temp_c", "reanalysis_air_temp_k",
                 "station_diur_temp_rng_c")
corPlot(training_clean[vars_subset], labels=c("Total Cases",
                                              "Station Max Temp",
                                              "ReAnalysis", "Station"))

