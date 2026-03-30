-- Database: sql_project_p1

-- DROP DATABASE IF EXISTS sql_project_p1;

-- CREATE DATABASE sql_project_p1
--     WITH
--     OWNER = postgres
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'C'
--     LC_CTYPE = 'C'
--     LOCALE_PROVIDER = 'libc'
--     TABLESPACE = pg_default
--     CONNECTION LIMIT = -1
--     IS_TEMPLATE = False;

-- CREATE DATABASE sql_project_p2;
 
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
	(
		transactions_id INT PRIMARY KEY,
		sale_date DATE,
		sale_time TIME,
		customer_id INT,
		gender VARCHAR(15),
		age INT,
		category VARCHAR(15),
		quantiy INT,
		price_per_unit FLOAT,
		cogs FLOAT,
		total_sale FLOAT
	);


SELECT * FROM retail_sales
LIMIT 10;

SELECT 
	COUNT(*) 
FROM retail_sales

-- data cleaning
SELECT * FROM retail_sales
WHERE transactions_id IS NULL;

--

SELECT * FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	Or customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

--

DELETE FROM retail_sales
WHERE 
	transactions_id IS NULL
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR quantiy IS NULL
	OR cogs IS NULL
	OR total_sale IS NULL;

SELECT 
	COUNT(*) 
FROM retail_sales

-- data exploration
SELECT COUNT(*) as total_sale FROM retail_sales;


SELECT COUNT(DISTINCT category) as total_sale FROM retail_sales;
SELECT DISTINCT category FROM retail_sales;

-- 
-- Q1. Write a SQL query to retrieve all columns for sales made on '2022-11-05'
SELECT * FROM retail_sales WHERE sale_date = '2022-11-05';

-- Q2. Write a SQL query to retrieve all transactions where the category is 'Clothing' 
-- and the quantity sold is more than 4 in the month of Nov-2022
SELECT * FROM retail_sales 
WHERE category = 'Clothing' 
and TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
and quantiy >= 4 ;

-- Q3. Write a SQL query to calculate the total sales (total_sale) for each category.
SELECT 
	category,
	SUM(total_sale) as net_sale,
	COUNT(*) as total_orders
FROM retail_sales
group by category; -- instead of category we can write 1 also

-- Q4. Write a SQL query to find the average age of customers 
-- who purchased items from the 'Beauty' category.
SELECT 
	ROUND(AVG(age),2) as avg_age
From retail_sales
WHERE category = 'Beauty';

-- Q5. Write a SQL query to find all transactions where the total_sale is greater than 1000.
SELECT * FROM retail_sales 
WHERE total_sale>1000;

-- Q6. Write a SQL query to find the total number of transactions (transaction_id) 
-- made by each gender in each category.
SELECT
	gender,
	category,
	COUNT(*) as total_trans
FROM retail_sales
GROUP BY 
	gender,
	category
ORDER BY 1; -- ORDER BY in SQL is used to sort the result of a query

-- Q7. Write a SQL query to calculate the average sale for each month.
-- Find out best selling month in each year.
SELECT 
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    AVG(total_sale) AS avg_sale
FROM retail_sales
GROUP BY 1, 2
ORDER BY 1, 2;
-- aaaaaaaannnnnddddd
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
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date) 
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
) t
WHERE rnk = 1;

-- Q8. Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT 	
	customer_id,
	SUM(total_sale) as total_sale
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Q9. Write a SQL query to find the number of unique customers who purchased items
-- from each category.
SELECT
	category,
	COUNT(DISTINCT customer_id) as cnt_unique_cs
FROM retail_sales
GROUP BY category;

-- Q10. Write a SQL query to create each shift and number of orders 
WITH hourly_sale
AS
(
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
	COUNT(*) as total_orders
FROM hourly_sale
GROUP BY shift










