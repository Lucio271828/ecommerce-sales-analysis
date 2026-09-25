# E-commerce Sales Analysis

## Project Overview

This project focuses on cleaning and analyzing a messy e-commerce sales
dataset using Python, Pandas and MySQL.

The project consists of two main stages: data cleaning and preprocessing
with Python/Pandas, followed by business-oriented data analysis using
SQL in MySQL.

## Data Cleaning

The original dataset contained several data quality issues, including:

- Missing values
- Duplicate records
- Invalid numeric values
- Negative prices and quantities
- Inconsistent product categories
- Invalid date formats

The data was cleaned and transformed using Python and Pandas. Missing and invalid values were handled carefully, categories were standardized, dates were converted to the appropriate format, and the Total column was validated using Quantity and Price.

## SQL Analysis

After cleaning the dataset, the data was imported into MySQL to perform business-oriented analysis.

The analysis includes:

- Revenue and percentage of total revenue by category
- Product revenue compared with the average revenue per product
- Identification of the top 20% of customers by revenue
- Monthly revenue trends and growth compared with the previous month 
- Revenue distribution by order status
- Top 3 products by revenue within each category
- Average ticket by category compared with the overall average ticket
- Year-over-year customer spending analysis
- Identification of high-value customers based on revenue, order frequency, and delivered orders
- Customer segmentation into High, Medium, and Low Value groups

The SQL analysis uses techniques such as CTEs, subqueries, aggregate functions, CASE statements, and window functions including LAG(), NTILE(), and ROW_NUMBER().


After the cleaning process, the dataset was prepared for import into MySQL for further an
