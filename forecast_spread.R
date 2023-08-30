## Build & Train predictive models
library(caTools)
### train and test from training set
set.seed(123)
split <- sample.split(training_clean, SplitRatio=0.8)

train <- subset(training_clean, split==T)
test <- subset(training_clean, split==F)

train_indices <- which(split == TRUE)  # Get the indices of the training set
test_indices <- which(split == FALSE)

unlist(lapply(test, function(x)sum(is.na(x))))
### build models 
### randomforest

library(randomForest)

rf <- randomForest(total_cases ~ station_max_temp_c + 
                     station_diur_temp_rng_c + 
                     reanalysis_specific_humidity_g_per_kg, data=train)

train_predict <- predict(rf, test)
glimpse(train_predict)

### 22 MAE
mae <- mean(abs(train_predict - test$total_cases))

### tree model
library(tree)
tree <- tree(total_cases ~ station_max_temp_c + 
               station_diur_temp_rng_c + 
               reanalysis_specific_humidity_g_per_kg, 
             data = training_clean, 
             subset = train_bart)

summary(tree)

### tree final submission MAE = 37
tree_predict <- round(predict(tree, test))

yhat <- round(predict(tree, training_clean[-train_bart, ]))
head(dengue.test)

dengue_test <- as.numeric(dengue.test$total_cases)

tree_sub <- round(predict(tree, test))

tree_final <- sub %>% 
  cbind(tree_sub) %>% 
  select(-total_cases)

tree_final <- tree_final %>% 
  rename(total_cases = tree_sub)

write_csv(tree_final, "tree_final.csv")

# Scatter plot
plot(dengue_test, yhat, main = "Actual vs. Predicted Total Cases",
     xlab = "Actual Total Cases", ylab = "Predicted Total Cases")
abline(0, 1, col = "red")  # Add a diagonal line

# Calculate MAE
mae <- mean(abs(yhat - dengue_test))
print(paste("Mean Absolute Error:", mae))

### bayesian training MAE = 20.9
install.packages("BART")
library(BART)

set.seed(123)
train_bart <- sample(1:nrow(training_clean), 
                     nrow(training_clean) / 2)

x <- training_clean[, 6:25]
y <- training_clean[, "total_cases"]

xtrain <- x[train_bart, ]
ytrain <- y[train_bart]

xtest <- x[-train_bart, ]
ytest <- y[-train_bart]

xtrain <- as.data.frame(xtrain)
ytrain <- as.numeric(ytrain)
xtest <- as.data.frame(xtest)

set.seed(123)
bartfit <- gbart(xtrain, ytrain, x.test=xtest)

yhat.bart <- bartfit$yhat.test.mean

mean(abs(ytest-yhat.bart))

ord <- order(bartfit$varcount.mean, decreasing = T) 
bartfit$varcount.mean[ord]

#### END BAYESIAN MODELING ####

### bayesian ftw--not MAE = 41 ###
### sj

xtest <- as.data.frame(test[, 6:25])

head(xtest)
bay_pred <- predict(bartfit, xtest)

bay_pred_vector <- as.vector(bay_pred)

# Round the values to the nearest integer
bay_pred_rounded <- round(bay_pred_vector)

# If the predictions should be non-negative, ensure all values are >= 0
bay_pred_rounded[bay_pred_rounded < 0] <- 0

bay_sub <- sub %>% 
  cbind(bay_pred_rounded) %>% 
  select(-total_cases)

bay_sub <- bay_sub %>% 
  rename(total_score = bay_pred_rounded)

write_csv(bay_sub, "bay_sub.csv")


#### point forecast predictions ####

na_dates <- is.na(training_clean$date)

# Subset the data frame to show rows with NAs in the "date" column
rows_with_na_dates <- training_clean[na_dates, ]

# Print the rows with NAs in the "date" column
print(rows_with_na_dates)

test <- kNN(test, k=6)

test <- subset(test[, 1:25])

test <- test %>% 
  mutate(date=ymd(week_start_date)) %>% 
  as_tsibble(index=date, key=city) 


training_clean <- training_clean %>% 
  mutate(date=ymd(week_start_date)) %>% 
  as_tsibble(index=date, key=city)

training_filled <- training_clean %>% 
  fill_gaps(total_cases = mean(total_cases))


forecast_start_date <- ymd("2005-04-22")

new_data <- training_clean %>% 
  filter(city == "sj", date >= forecast_start_date)


# Merge the forecasted values with the actual data
merged_data <- new_data %>%
  filter(city == "sj") %>%
  left_join(forecast_values, by = "date")
merged_data %>% 
  select(date, forecast, total_cases.y) %>% 
  head()

# Calculate the Mean Absolute Error (MAE)
mae <- mean(abs(merged_data$total_cases.y - merged_data$forecast))
merged_data %>% 
  select(total_cases.y, forecast, date)

print(mae)
colnames(merged_data)


#### regression model mae 27.7 = my current score
### arima model mase = 26.1
lm_forecast <- training_clean %>% 
  model(
    lm=TSLM(total_cases ~ reanalysis_dew_point_temp_k +
              reanalysis_max_air_temp_k)) %>% 
  fabletools::forecast(new_data=test)  


lm_final <- sub %>% 
  cbind(lm_forecast$.mean) %>% 
  select(-total_cases)

lm_final <- lm_final%>% 
  mutate(mean = round(lm_forecast$.mean)) %>% 
  rename(total_cases = mean) 

lm_final <- lm_final %>% 
  select(-`lm_forecast$.mean`)

write_csv(lm_final, "lm_final.csv")

#### Predict Cities Seperately
###predict sj 5 years
###predct iq for 3 years

###sj models
library(fpp2)

###sj test set single 
###sj master file
sj <- newdata %>%
  filter(city=="sj")

###sj ts
sj_ts <- ts(sj$total_cases, start=1990, end=2008, frequency=52)

###sj train and set
sj_train <- window(sj_ts, end=2006)

sj_test <- window(sj_ts, start=2006)

###sj arima model
arima <- auto.arima(sj_train)

###sj arima forecast
arima_forecast <- forecast(arima, h=156)
print(arima_forecast)

###sj arima check residuals
checkresiduals(arima_forecast)

###sj arima accuracy test
###mase = 0.334
accuracy(arima_forecast, sj_test)

###sj arima graph forecast
autoplot(arima_forecast) +
  autolayer(sj_test) +
  labs(title="San Juan Dengue Forecast",
       subtitle="1,0,1 Arima Model",
       y="Total Cases",
       x="Year") +
  theme_bw()

####sj neural net model #2
set.seed(1)
nne <- nnetar(sj_train, p=2, P=1)

###sj neural net forecast
nne_forecast <- forecast(nne, h=104, level = 50, 95)
print(arima_forecast)
summary(nne_forecast)

###sj nne check residuals
checkresiduals(nne_forecast)

###sj nne accuracy test
###mase = 0.334
accuracy(nne_forecast, sj_test)

###sj neural net graph forecast
autoplot(nne_forecast) +
  autolayer(sj_test) +
  labs(title="San Juan Dengue Forecast",
       subtitle="Neural Net 10,1,6",
       y="Total Cases",
       x="Year") +
  theme_bw()

###sj naive forecast last model
naive <- naive(sj_train, h=104)

###sj naive forecast
autoplot(naive) +
  autolayer(sj_test) +
  labs(title="San Juan Dengue Forecast",
       subtitle="Naive Model",
       y="Total Cases",
       x="Year") +
  theme_bw()

###sj naive accuracy
###mase=0.343
checkresiduals(naive)
accuracy(naive, sj_test)


###2000 W26 - 2008 W09

###iq master data set

iq <- newdata %>%
  filter(city=="iq")

###iq ts
iq_ts <- ts(iq$total_cases, start=2000, end=2010, frequency=52)

###train and set
iq_train <- window(iq_ts, end=2007)

iq_test <- window(iq_ts, start=2007)

###iq arima model
iq_arima <- auto.arima(iq_train)

###iq arima forecast
iq_arima_forecast <- forecast(iq_arima, h=156)

###iq arima forecast accuracy
###mase = 0.4839
checkresiduals(iq_arima_forecast)
accuracy(iq_arima_forecast, iq_test)

##iq plot arima forecast
autoplot(iq_arima_forecast) +
  autolayer(iq_test) +
  labs(title="IQ Dengue Forecast",
       subtitle="Arima 2,1,1",
       y="Total Cases",
       x="Year") +
  theme_bw()


####iq nne model
iq_nne <- nnetar(iq_train)

###iq nne forecast
iq_nne_forecast <- forecast(iq_nne, h=156)

###iq nne forecast plot
autoplot(iq_nne_forecast) +
  autolayer(iq_train)

###accuracy
###mase = 0.5114
accuracy(iq_nne_forecast, iq_test)

###last iq model
iq_naive <- naive(iq_train, h=156)

###iq naive forecast plot
autoplot(iq_naive) +
  autolayer(iq_test)

###iq naive accuracy
###mase = 0.53
accuracy(iq_naive, iq_test)
