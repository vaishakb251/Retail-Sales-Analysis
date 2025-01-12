-- Retail Sales Project - P1

-----------------------------------------------------------------------
-- DATABASE CREATION
CREATE DATABASE sql_project_p1

----------------------------------------------------------------------
-- TABLE CREATION
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

-----------------------------------------------------------------------
-- DATA CLEANING
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

----------------------------------------------------------------------
-- DATA EXPLORATION

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

-------------------------------------------------------------------------------
-- DATA ANALYSIS/ BUSINESS PROBLEMS & ANSWERS

-- Q1) Write a SQL Query to retrieve all the sales made on '2022-11-05'?
SELECT * FROM retail_sales
WHERE sale_date = '2022-11-05';

-- Q2) Write a SQL Query to retrieve all the transactions where category is 'Clothing' and the quantity sold is more than 4 in the month of Nov 2022?
SELECT * FROM retail_sales
WHERE 
category = 'Clothing' AND
quantity >= 4 AND
TO_CHAR(sale_date, 'YYYY-MM') = '2022-11';

-- Q3) Write a SQL Query to calculate the total sale for each category?
SELECT 
category, COUNT(quantity) AS order_count, SUM(quantity) AS total_quantity_per_cat, SUM(total_sale) AS net_sale
FROM retail_sales
GROUP BY category
ORDER BY net_sale DESC;

-- Q4) Write a SQL Query to find the average age of the customer who purchased from the category 'Beauty'?
SELECT ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';

-- Q5) Write a SQL Query to find all the transactions where the total sale is greater than 1000?
SELECT * FROM retail_sales
WHERE total_sale > 1000;

-- Q6) Write a SQL Query to find the total number of transactions made by each gender in each category?
SELECT gender, category, COUNT(transactions_id) AS tot_num_of_trans 
FROM retail_sales
GROUP BY gender, category
ORDER BY gender DESC, category;

-- Q7) Write a SQL Query to calculate the average sales for each month, and find out best selling month in the year?
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

-- Q8) Write a SQL Query to find the top 5 customers based on the highest total sale?
WITH customer_grp AS(
	SELECT customer_id, SUM(total_sale) as tot_sale
	FROM retail_sales
	GROUP BY customer_id
)
SELECT * FROM customer_grp
ORDER BY tot_sale DESC
LIMIT 5;

-- Q9) Write a SQL Query to find the number of unique customers who purchased items from each category?
SELECT category, COUNT(DISTINCT customer_id) AS uniq_customers
FROM retail_sales
GROUP BY category
ORDER BY category;

-- Q10) Write a SQL query to Create each shift and number Of orders (Example Morning <= 12, Afternoon Between 12 & 17, Evening > 17)
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

-- END OF PROJECT

