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

dim(sub)

###cleaning and correlation
### merging
train_master <- merge(feat, labels, by=c("city", "year", "weekofyear"), all.x = T)
##testing to see if the rows match
nrow(train_master) == nrow(feat)
colnames(train_master)

###as tsibble
train_ts <- train_master %>%
  mutate(week_start_date = yearweek(week_start_date)) %>%
  as_tsibble(index=week_start_date, key=city)

###remove NAs
train_clean <- na.omit(train_ts)

### train set as tsibble 
###2000 W26 - 2008 W09
###master file
newdata %>%
  distinct(city) %>%
  count()

##table of desc stats
library(stargazer)
stargazer(newdata,
          title="Table of Descriptive Statistics: Dengue Fever",
          iqr=T,
          digits=2,
          type="html",
          out="dengue.html")

###season plot
yearly_plot <- train_ts %>%
  fill_gaps(total_cases=mean(total_cases)) %>%
  gg_season(total_cases) +
  labs(title="Total Cases Seasonal Plot") +
  theme_bw()

###distribution
dist <- ggplot(train_ts) +
  geom_histogram(aes(total_cases,fill=1,
                     binwidth = 5)) +
  labs(title="Distribution of Case Values",
       y="Count",
       x="Total Cases") +
  theme_bw()


###correlation
library(corrplot)

corrplot(cor=cor(train_ts[20:25]),
         method="number",
         type="full",
         tl.pos="tl",
         order="original")
