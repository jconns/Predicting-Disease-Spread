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
