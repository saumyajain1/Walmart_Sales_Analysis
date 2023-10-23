-- Creating database
CREATE DATABASE IF NOT EXISTS walmartSales;

-- Creating table, using NOT NULL to pre-clean data
CREATE TABLE IF NOT EXISTS sales(
	invoice_id VARCHAR(30) PRIMARY KEY,
    branch VARCHAR(5) NOT NULL,
    city VARCHAR(30) NOT NULL,
    customer_type VARCHAR(30) NOT NULL,
    gender VARCHAR(30) NOT NULL,
    product_line VARCHAR(100) NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    VAT FLOAT(6,4) NOT NULL,
    total DECIMAL(12, 4) NOT NULL,
    date DATETIME NOT NULL,
    time TIME NOT NULL,
    payment_method VARCHAR(15) NOT NULL,
    cogs DECIMAL(10,2) NOT NULL,
    gross_margin_percent FLOAT(11,9),
    gross_income DECIMAL(12, 4),
    rating FLOAT(2, 1)
);

-- Imported csv dataset from Kaggle

-- Feature Engineering ----------------------------------------------------------

-- Adding feature time_of_day

SELECT 
time,
	(CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END
	) AS time_of_day
FROM sales;

ALTER TABLE sales ADD COLUMN time_of_day VARCHAR(20);

UPDATE sales
SET time_of_day = 
	(CASE
		WHEN time BETWEEN "00:00:00" AND "12:00:00" THEN "Morning"
		WHEN time BETWEEN "12:01:00" AND "16:00:00" THEN "Afternoon"
        ELSE "Evening"
	END);


-- Adding feature day_name

SELECT
	date,
    DAYNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN day_name VARCHAR(20);

UPDATE sales
SET day_name = DAYNAME(date);


-- Adding feature month_name

SELECT
	date,
    MONTHNAME(date)
FROM sales;

ALTER TABLE sales ADD COLUMN month_name VARCHAR(20);

UPDATE sales
SET month_name = MONTHNAME(date);

-- --------------------------------------------------------------------

-- QUERYING TO ANSWER QUESTIONS:

-- 1. How many cities does Walmart have branches in, i.e. how many unique cities does the data have?

SELECT
DISTINCT city
FROM sales;

SELECT
COUNT(DISTINCT city)
FROM sales;

-- 2. In which city is each branch?

SELECT
DISTINCT branch,
city
FROM sales;

-- 3. What is the most common payment method?

SELECT
	payment_method,
	COUNT(payment_method) AS count
FROM sales
GROUP BY payment_method
ORDER BY count DESC;


-- 4. What are the monhtly total revenues?

-- since all data is in 2019, we can simply sum the revenue by month

SELECT
	month_name,
	SUM(total) AS Monthly_revenue
FROM sales
GROUP BY month_name
ORDER BY Monthly_revenue DESC;

-- 5. What is the most selling product line?

SELECT
	product_line,
	SUM(quantity) AS count
FROM sales
GROUP BY product_line
ORDER BY count DESC;customer_type

-- 6. What product line has the largest revenue?

SELECT
	product_line,
	SUM(total) AS revenue
FROM sales
GROUP BY product_line
ORDER BY revenue DESC;

-- 7. For product lines that sold more products than the average number of products sold per product line, add a column 'popularity' which states whether the product line is popular or not.

SELECT
    product_line,
    SUM(quantity) AS sales_count,
    CASE
        WHEN SUM(quantity) > (	SELECT AVG(sales_count) 
								FROM 
								(
									SELECT 	SUM(quantity) AS sales_count 
									FROM sales 
									GROUP BY product_line
								) AS subquery
							) 
		THEN 'Popular'
        ELSE 'Not Popular'
    END AS popularity
FROM sales
GROUP BY product_line;


-- 8. How do sales vary by time of day for each branch?


SELECT
	branch,
	time_of_day, 
	COUNT(*) AS count
FROM sales
GROUP BY time_of_day, branch
ORDER BY branch, count DESC;


-- LOOKS LIKE SALES ARE GREATEST IN THE EVENING, AND LEAST IN THE MORNING FOR EACH BRANCH!!!





