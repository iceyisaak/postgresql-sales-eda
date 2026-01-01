-- CREATE DATABASE
CREATE DATABASE sales_data;


-- CHECK ALL EXISTING DATABASES
SELECT datname FROM pg_database;


-- CREATE TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales(
	transaction_id INT PRIMARY KEY,
	sale_date DATE,
	sale_time TIME,
	customer_id INT,
	gender VARCHAR(15),
	age INT,
	category VARCHAR(15),
	quantity INT,
	price_per_unit FLOAT,
	cogs FLOAT,
	total_sale FLOAT
)


SELECT * FROM retail_sales;
-- DROP TABLE retail_sales;



-- Import dataset
COPY retail_sales
FROM '/data/retail-sales-2022.csv' 
DELIMITER ',' 
CSV HEADER;


-- Dataset Overview
SELECT * FROM retail_sales;



SELECT * FROM retail_sales LIMIT 10;


-- Number of Transactions
SELECT COUNT(*) FROM retail_sales;


-- Check for missing values
SELECT * 
FROM retail_sales
WHERE transaction_id IS NULL
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


-- Delete incomplete data
DELETE FROM retail_sales
WHERE transaction_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	-- OR age IS NULL
	OR category IS NULL
	OR quantity IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;


-- Impute missing data with AVG()
WITH average_age AS (
    SELECT AVG(age) as mean_age 
    FROM retail_sales
)
UPDATE retail_sales
SET age = average_age.mean_age
FROM average_age
WHERE age IS NULL;



-----------------------------------


-- EDA


-- Total Number of Sales
SELECT COUNT(*) FROM retail_sales;


-- How many unique customers are there?
SELECT COUNT(DISTINCT customer_id) FROM retail_sales;


-- How many categories are there?
SELECT DISTINCT category FROM retail_sales;



-- Data Analysis & Business Key Insights



-- Sales made on '2022-11-05'
SELECT *
FROM retail_sales
WHERE sale_date='2022-11-05';


-- Transactions where category is 'Clothing' and the quantity is more than 4 in NOV 2022
SELECT *
FROM retail_sales
WHERE category='Clothing'
AND TO_CHAR(sale_date,'YYYY-MM')='2022-11'
AND quantity >= 4;



-- Total Sale for each category
SELECT
	category, 
	SUM(total_sale) AS total_sales,
	COUNT(*) AS total_orders
FROM retail_sales
GROUP BY 1;
	


-- Average age of customers who purchased items from the 'Beauty' category
SELECT ROUND(AVG(age),2) AS avg_age
FROM retail_sales
WHERE category='Beauty';


-- Transactions where total_sale is more than 1000
SELECT *
FROM retail_sales
WHERE total_sale>1000;


-- No. of Transactions by each gender in each category
SELECT category, gender, COUNT(*) as total_transactions
FROM retail_sales
GROUP BY 1,2
ORDER BY 1;



-- Average sale for each month
SELECT 
	year,
	month,
	avg_sale
FROM
(
	SELECT 
		EXTRACT(YEAR FROM sale_date) AS year,
		EXTRACT(MONTH FROM sale_date) AS month, 
		AVG(total_sale) AS avg_sale,
		RANK() OVER(
					PARTITION BY EXTRACT(YEAR FROM sale_date) 
					ORDER BY AVG(total_sale) DESC
				)
	FROM retail_sales
	GROUP BY 1,2
	-- ORDER BY 1,3 DESC;
) AS  T1
WHERE RANK=1;




-- Top 5 Customers by highest total_sales
SELECT 
	customer_id,
	SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;



-- Number of unique customers who bought items from each category
SELECT 
	category,
	COUNT(DISTINCT customer_id) AS unique_customer_count
FROM retail_sales
GROUP BY category;


-- Number of orders between different shifts of the day
WITH hourly_sale AS (
SELECT *,
	CASE 
		WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
		WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
	END as shift
FROM retail_sales
)
SELECT 
	shift,
	COUNT(*) AS total_orders 
FROM hourly_sale
GROUP BY shift;


-- END OF PROJECT

