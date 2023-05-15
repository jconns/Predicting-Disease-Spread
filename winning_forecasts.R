###winning models
###iq=arima 2,1,1
###sj = nne 10,1,6

###forecast the whole set 5 & 3 years

###sj final forecast nne
library(fpp3)
library(fpp2)

sj_nne <- nnetar(sj$total_cases)

###sj final nne forecast
nne_forecast <- forecast(sj_nne, h=260)

autoplot(nne_forecast) +
  labs(title="SJ Dengue Fever Forecast",
       subtitle="Neural Net Model",
       y="Total Cases") +
  theme_bw()

###csv
install.packages("sweep")
sj_nne_fore <- nne_forecast %>% 
  sweep::sw_sweep(.) %>% 
  filter(key == "forecast") %>% 
  select(-key)
library(xlsx)
###iq final write csv
write.csv(sj_nne_fore, "sj_nne_fore.csv")


###iq final forecast
iq_final <- auto.arima(iq$total_cases)

###forecast iq final arima
iq_arima_forecast <- forecast(iq_final, h=156)

###plot forecast
autoplot(iq_arima_forecast) +
  labs(title="Iq Dengue Fever Forecast",
       subtitle="Arima Model",
       y="Total Cases") +
  theme_bw()

library(dplyr)

###iq flip the forecast output to a table
install.packages("sweep")
iq_arima4 <- iq_arima_forecast4 %>% 
  sweep::sw_sweep(.) %>% 
  filter(key == "forecast") %>% 
  select(-key)
library(xlsx)
###iq final write csv
write.csv(iq_arima4, "iq_arima4.csv")
###final forecast value
tail(iq$week)
###submission
file1 <- read.csv(file.choose())
myagg=aggregate(total_cases ~ city, FUN=mean, data=file1)
colnames(mymerge)

mymerge=merge(sub, myagg, by="city", all.x=TRUE)
mymerge$total_cases.x=NULL
mymerge$total_cases=mymerge$total_cases.y
mymerge$total_cases.y=NULL

write.csv(mymerge, "mymerge.csv", row.names=FALSE)
