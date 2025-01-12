# Retail Sales Analysis SQL Project

## Project Overview

**Project Title**: Retail Sales Analysis  
**Level**: Beginner  
**Database**: `SQL - Retail Sales Analysis_utf .csv`

This project is designed to demonstrate SQL skills and techniques typically used by data analysts to explore, clean, and analyze retail sales data. The project involves setting up a retail sales database, performing exploratory data analysis (EDA), and answering specific business questions through SQL queries. This project is ideal for those who are starting their journey in data analysis and want to build a solid foundation in SQL.

## Objectives

1. **Set up a retail sales database**: Create and populate a retail sales database with the provided sales data.
2. **Data Cleaning**: Identify and remove any records with missing or null values.
3. **Exploratory Data Analysis (EDA)**: Perform basic exploratory data analysis to understand the dataset.
4. **Business Analysis**: Use SQL to answer specific business questions and derive insights from the sales data.

## Project Structure

### 1. Database Setup

- **Database Creation**: The project starts by creating a database named `SQL - Retail Sales Analysis_utf .csv`.
- **Table Creation**: A table named `retail_sales` is created to store the sales data. The table structure includes columns for transaction ID, sale date, sale time, customer ID, gender, age, product category, quantity sold, price per unit, cost of goods sold (COGS), and total sale amount.

```sql
CREATE DATABASE sql_project_p1;

DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales (
	transactions_id	 INT PRIMARY KEY,
	sale_date DATE,
	sale_time	TIME,
	customer_id	INT,
	gender	VARCHAR(15),
	age	INT,
	category	VARCHAR(25),
	quantity	INT,
	price_per_unit FLOAT,	
	cogs	FLOAT, -- purchasing cost
	total_sale FLOAT
);
```

### 2. Data Exploration & Cleaning

- **Record Count**: Determine the total number of records in the dataset.
- **Customer Count**: Find out how many unique customers are in the dataset.
- **Category Count**: Identify all unique product categories in the dataset.
- **Null Value Check**: Check for any null values in the dataset and delete records with missing data.

```sql
SELECT * FROM retail_sales
LIMIT 10;

SELECT COUNT(*) 
FROM retail_sales;

-- There are totally 2000 rows in the dataset.
-- checking for rows with null values

SELECT * FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

-- Found that 13 rows having atleast one NULL value

DELETE FROM retail_sales
WHERE transactions_id IS NULL
OR sale_date IS NULL
OR sale_time IS NULL
OR customer_id IS NULL
OR gender IS NULL
OR age IS NULL
OR category IS NULL
OR quantity IS NULL
OR price_per_unit IS NULL
OR cogs IS NULL
OR total_sale IS NULL;

SELECT COUNT(*) 
FROM retail_sales;

-- Now there are 1987 rows, after cleaning.

-- How many sales we have?
SELECT COUNT(*) AS table_count FROM retail_sales; -- 1987

-- How many customers we have?
SELECT COUNT(customer_id) AS customer_count FROM retail_sales; -- 1987

-- How many unique customers we have?
SELECT COUNT(DISTINCT customer_id) AS customer_count FROM retail_sales; -- 155
-- To List all 155
-- SELECT DISTINCT customer_id FROM retail_sales ORDER BY customer_id ASC;

-- How many categories we have?
SELECT COUNT(DISTINCT category) AS category_count FROM retail_sales; -- 3
-- To List all categories
SELECT DISTINCT category AS category_name FROM retail_sales;
-- Electronics
-- Clothing
-- Beauty
```

### 3. Data Analysis & Findings

The following SQL queries were developed to answer specific business questions:

1. **Write a SQL Query to retrieve all the sales made on '2022-11-05'?**:
```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

2. **Write a SQL Query to retrieve all the transactions where category is 'Clothing' and the quantity sold is more than 4 in the month of Nov 2022?**:
```sql
SELECT * 
    FROM retail_sales
WHERE 
category = 'Clothing' AND
quantity >= 4 AND
TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';
```

3. **Write a SQL Query to calculate the total sale for each category?**:
```sql
SELECT 
	category, COUNT(quantity) AS order_count, SUM(quantity) AS total_quantity_per_cat, SUM(total_sale) AS net_sale
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;
```

4. **Write a SQL Query to find the average age of the customer who purchased from the category 'Beauty'?**:
```sql
SELECT 
	ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';
```

5. **Write a SQL Query to find all the transactions where the total sale is greater than 1000?**:
```sql
SELECT * 
FROM retail_sales
WHERE total_sale > 1000;
```

6. **Write a SQL Query to find the total number of transactions made by each gender in each category?**:
```sql
SELECT 
	gender, category, COUNT(transactions_id) AS tot_num_of_trans 
FROM retail_sales
GROUP BY gender, category
ORDER BY gender DESC, category;
```

7. **Write a SQL Query to calculate the average sales for each month, and find out best selling month in the year?**:
```sql
-- version 1
DROP VIEW IF EXISTS total_sale_view;
CREATE VIEW total_sale_view AS
SELECT
EXTRACT(YEAR FROM sale_date) AS year,
EXTRACT(MONTH FROM sale_date) AS month,
SUM(total_sale) AS total_sale
FROM retail_sales
GROUP BY year, month
ORDER BY year, month;

SELECT month, total_sale AS best_month
FROM total_sale_view
ORDER BY best_month DESC
LIMIT 1; 
-- Best Month -- DECEMBER -- By Total
-- Best Month -- JULY     -- By Average
```

```sql
-- version 2
SELECT * FROM 
(
	WITH monthly_sales AS (
	    SELECT
	        EXTRACT(YEAR FROM sale_date) AS year,
	        EXTRACT(MONTH FROM sale_date) AS month,
	        AVG(total_sale) AS avg_sale
	    FROM retail_sales
	    GROUP BY year, month
	)
	SELECT
	    year,
	    month,
	    avg_sale,
	    RANK() OVER (
			PARTITION BY year 
			ORDER BY avg_sale DESC
		) AS rank
	FROM monthly_sales
)
WHERE rank = 1;
```

8. **Write a SQL Query to find the top 5 customers based on the highest total sale?**:
```sql
WITH customer_grp AS(
	SELECT
        customer_id, SUM(total_sale) as tot_sale
	FROM retail_sales
	GROUP BY customer_id
)
SELECT * FROM customer_grp
ORDER BY tot_sale DESC
LIMIT 5;
```

9. **Write a SQL Query to find the number of unique customers who purchased items from each category?**:
```sql
SELECT 
	category, COUNT(DISTINCT customer_id) AS uniq_customers
FROM retail_sales
GROUP BY category
ORDER BY category;
```

10. **Write a SQL query to Create each shift and number Of orders (Example Morning <= 12, Afternoon Between 12 & 17, Evening > 17)**:
```sql
WITH hourly_order AS
(
	SELECT 
		EXTRACT(HOUR FROM sale_time) AS hour, 
		COUNT(transactions_id) AS order_cnt
	FROM retail_sales
	GROUP BY hour
)
SELECT 
	CASE 
		WHEN hour <= 12 THEN 'Morning'
		WHEN hour > 12 AND hour < 17 THEN 'Afternoon'
		ELSE 'Evening'
	END AS shift,
	SUM(order_cnt) AS tot_order
FROM hourly_order
GROUP BY shift
ORDER BY shift;
```

## Findings

- **Customer Demographics**: The dataset includes customers from various age groups, with sales distributed across different categories such as Clothing and Beauty.
- **High-Value Transactions**: Several transactions had a total sale amount greater than 1000, indicating premium purchases.
- **Sales Trends**: Monthly analysis shows variations in sales, helping identify peak seasons.
- **Customer Insights**: The analysis identifies the top-spending customers and the most popular product categories.

## Reports

- **Sales Summary**: A detailed report summarizing total sales, customer demographics, and category performance.
- **Trend Analysis**: Insights into sales trends across different months and shifts.
- **Customer Insights**: Reports on top customers and unique customer counts per category.

## Conclusion

This project serves as a comprehensive introduction to SQL for data analysts, covering database setup, data cleaning, exploratory data analysis, and business-driven SQL queries. The findings from this project can help drive business decisions by understanding sales patterns, customer behavior, and product performance.

## How to Use

1. **Clone the Repository**: Clone this project repository from GitHub.
2. **Set Up the Database**: Run the SQL scripts provided in the `SQL - Retail Sales Analysis_utf .csv` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries provided in the `sql_project1` file to perform your analysis.
4. **Explore and Modify**: Feel free to modify the queries to explore different aspects of the dataset or answer additional business questions.

## Author - Vaishak Balachandra

This project is part of my portfolio, showcasing the SQL skills essential for data analyst roles. If you have any questions, feedback, or would like to collaborate, feel free to get in touch!

### Stay Updated and Join the Community

For more content on SQL, data analysis, and other data-related topics, make sure to follow me on social media:
- **LinkedIn**: [Connect with me professionally](https://www.linkedin.com/in/vaishakb251)

Thank you for your support, and I look forward to connecting with you!
