---
title: "Demand Forecasting Using Time Series"
author: "Anupriya Thirumurthy"
date: "5/18/2019"
output:
  pdf_document: default
  html_document: default
---

## Import dataset

```{r}
dataPath<-"/Users/anupriyathirumurthy/Documents/AnuBackUp/University/MScA_UoC/Courses/TimeSeries/Project/New/"
dataset <-read.csv(file=paste(dataPath,"Books.csv",sep="/"))
head(dataset)
```

```{r}
str(dataset)
```

Import relevant packages
```{r}
library(forecast)
library(tseries)
library(lubridate)
library(dplyr)
```

## Step 1: Data clean-up

```{r}
#Rename ISBN column
colnames(dataset)[3] <- "ISBN"

#Separate units ordered vs. returned
dataset$Qty_Ordered <- ifelse(dataset$Quantity.Ordered >0, dataset$Quantity.Ordered, 0)
dataset$Qty_Returned <- ifelse(dataset$Quantity.Ordered <0, dataset$Quantity.Ordered, 0)

#Create timeframe identifier
Date.Ordered.Year <- year(as.Date(dataset$Date.Ordered,"%m/%d/%Y"))
Date.Ordered.Year <- as.numeric(paste("20",Date.Ordered.Year, sep = ""))
Date.Ordered.Year <- as.data.frame(Date.Ordered.Year, "%Y")
#df$Fasta.headers = paste(">",df$Fasta.headers,sep = "")
dataset<- cbind(dataset, Date.Ordered.Year)

max <- tapply(dataset$Date.Ordered.Year, dataset$ISBN, max)
min <- tapply(dataset$Date.Ordered.Year, dataset$ISBN, min)
min_max <- cbind(min, max)
min_max <- as.data.frame(min_max)
min_max <- cbind(newColName = rownames(min_max), min_max)
rownames(min_max) <- 1:nrow(min_max)
colnames(min_max)[1] <- "ISBN"
min_max$combined <- paste(min_max$min, "-", min_max$max)

merged_dataset <- merge(x = dataset, y = min_max, by = "ISBN", all.x = TRUE)
      
#Eliminate unneccessary columns
final_dataset <- merged_dataset[, -c(2,5:9,12:13,17:18)] 
head(final_dataset)
str(final_dataset)
```

## Step 2: Split test/train data

```{r}
train_data <- final_dataset[final_dataset$Date.Ordered.Year < "2018",]
test_data <- final_dataset[final_dataset$Date.Ordered.Year >= "2018",]
dim(train_data)
dim(test_data)
```

## Step 3: Auto Arima with just one title

```{r}
ISBN_8 <- final_dataset[final_dataset$ISBN == 8,]
train_data_8 <- ISBN_8[ISBN_8$Date.Ordered.Year < "2018",]
test_data_8 <- ISBN_8[ISBN_8$Date.Ordered.Year >= "2018",]

#Arima model
arima_8 <- auto.arima(ISBN_8$Quantity.Ordered)
forecast_8 <- forecast(arima_8, h = 12)
plot(forecast_8)
print(forecast_8)
forecast_8 <- as.vector(forecast_8$mean)
pred <- mean(forecast_8)
pred
test <- mean(test_data_8$Quantity.Ordered)
test
smape <- (sum(abs(test-pred)/(abs(test)+abs(pred))))/length(test)
smape
```


## Step 4: Auto-arima with all isbn's

```{r}
# Auto Arima for all the titles
isbn_list <- unique(sort(final_dataset$ISBN))
isbn_list
for (i in isbn_list){
  ISBN <- final_dataset[final_dataset$ISBN == i,]
  train_data_all <- ISBN[ISBN$Date.Ordered.Year < "2018",]
  test_data_all <- ISBN[ISBN$Date.Ordered.Year >= "2018",]
  #Arima model
  arima_all <- auto.arima(ISBN$Quantity.Ordered)
  forecast_all <- forecast(arima_all, h = 12)
  cat("Book ID: ", unique(ISBN$ISBN))
  plot(forecast_all)
  #print(forecast_all)
}
```


```{r}
# Print SMAPE Score for all the book titles
for (i in isbn_list){
  ISBN <- final_dataset[final_dataset$ISBN == i,]
  cat(i)
  train_data_all <- ISBN[ISBN$Date.Ordered.Year < "2018",]
  test_data_all <- ISBN[ISBN$Date.Ordered.Year >= "2018",]
  #Arima model
  arima_all <- auto.arima(ISBN$Quantity.Ordered)
  forecast_all <- forecast(arima_all, h = 12)
  pred <- mean(as.vector(forecast_all$mean))
  test <- mean(test_data_all$Quantity.Ordered)
  smape <- (sum(abs(test-pred)/(abs(test)+abs(pred))))/length(test)
  smape
}
```

## Step 5: Determine Dependent Vs Independent Variables in Regression Modelling for one title

#### Price as independent variable
```{r}
Quantity.model <- lm(as.formula(Quantity.Ordered~Order.Price), data = train_data_8)
Quantity.model

options(warn=-1) 
Quantity.model.predict <- predict.lm(Quantity.model, newdata = test_data_8)
options(warn=1)
Quantity.model.predict

Quantity.actual <- train_data_8[,'Quantity.Ordered']
Quantity.err.pct <- (Quantity.model.predict-Quantity.actual)/Quantity.actual
plot.ts(Quantity.err.pct)

# SSE
Quantity.lm.SSE <- sum(sapply((Quantity.model.predict-Quantity.actual), function(z) z^2))
Quantity.lm.SSE

# SSE as a percentage of mean of actual values
Quantity.lm.SSE/mean(unlist(Quantity.actual))
```

#### Quantity as independent variable
```{r}
Price.model <- lm(as.formula(Order.Price~Quantity.Ordered), data = train_data_8)
Price.model

options(warn=-1) 
Price.model.predict <- predict.lm(Price.model, newdata = test_data_8)
options(warn=1)
Price.model.predict

Price.actual <- train_data_8[,'Order.Price']
Price.err.pct <- (Price.model.predict-Price.actual)/Price.actual
plot.ts(Price.err.pct)

# SSE
Price.lm.SSE <- sum(sapply((Price.model.predict-Price.actual), function(z) z^2))
Price.lm.SSE

# SSE as a percentage of mean of actual values
Price.lm.SSE/mean(unlist(Price.actual))
```

When comparing the 2 models using the sum of squared error as a percenatge of the mean of the actual values, the SSE when Price as the dependent variable is less when compared to Quantity being the dependent variable. However, in terms of business interests, we would like to forecast the quantity and hence I believe Quantity should be the dependent variable and Price the independent variable in case of Regression Time Series Problems.