# Demand-Forecasting-Using-Time-Series

# Forecasting Inventory Needs: Mathematics TextBooks

## Business Case and Motivation
The Client: Chicago Distribution Center is a publishing company specializing in sourcing academic books to retailers. 
The Problem: Sub-optimal inventory stocking. 
The Solution: Define a model to accurately forecast required inventory/stock for all textbooks. 
The ability to accurately forecast inventory reduces incidences of overstocking/understocking and allows for a reduction of costs of goods sold.

## Data Overview
Time series data for 79 unique ISBNs from July 2014 - April 2019.
Variables available include a unique ISBN identifier, date ordered, format, price, quantity ordered.
Variables selected: quantity ordered (dependent); price (independent).

Noticeable Issues:
Not necessarily clear that these are all unique titles. 
Includes electronic books (license allocation vs.  physical inventory).
Differing time intervals for each ISBN.
No singular price for each book.
Data is not aggregated. 

## Data Cleaning
Step 1: Drop E-books.
Reasoning: e-books are not relevant to physical inventory.
Step 2: Aggregate (FUN = sum) observations for each ISBN by Month/Year.
Reasoning: inventory stocking orders are made on a monthly basis.
Step 3: Use a weighted average aggregated price (per ISBN monthly).
Reasoning: acknowledges the existence of special discounts/price discrimination without skewing the aggregated price. 
Step 4: Split into train/test.
Test data: 2018.

## Modelling

Auto-ARIMA Model 

## Limitations and Future Work

Limitations:
Inaccurate forecasting
Unable to account for potential duplicates
Variation in model selection by title (computationally intensive)

Future Work:
Hierarchical forecasting
Incorporate returns into the analysis
Include other independent variables


