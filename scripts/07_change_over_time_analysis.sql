CHANGE OVER TIME
Analyze how measure involves over time .help track trends and identify seasonality in your data
--analyze the sale performance over time

SELECT
order_date,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY order_date
ORDER BY order_date

-- AGRREGATE BY BY YEAR

SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)

-- AGRREGATE COUNT TOTAL NUMBER OF CUSTOMERS

SELECT
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date)



-- AGRREGATE COUNT TOTAL NUMBER OF quantity by month and year

SELECT
MONTH(order_date) AS order_year,
YEAR(order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY MONTH(order_date), YEAR(order_date)
ORDER BY MONTH(order_date), YEAR(order_date)

-- or can use the truncate to get better result
SELECT
DATETRUNC(MONTH, order_date) AS order_year,
SUM(sales_amount) AS total_sales,
COUNT(DISTINCT customer_key) AS total_customers,
SUM(quantity) AS total_quantity
FROM gold.fact_sales 
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date)
ORDER BY DATETRUNC(MONTH, order_date)
