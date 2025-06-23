DATE EXPLORATION
--FIND THE DATE OF THE FIRST AND LAST ORDER
--HOW MANY YEARS OF SALES ARE AVAILABLE
SELECT MIN(order_date) first_order_date,
MAX(order_date) AS last_order_date, -- this is call boundary
DATEDIFF(year, MIN(order_date),MAX(order_date)) AS order_range_years
FROM gold.fact_sales


--check for the month

SELECT MIN(order_date) first_order_date,
MAX(order_date) AS last_order_date, -- this is call boundary
DATEDIFF(month, MIN(order_date),MAX(order_date)) AS order_range_months
FROM gold.fact_sales


--FIND THE YOUNGEST AND THE OLDEST CUSTOMERS

SELECT 
MIN(birthday) AS oldest_birthdate,
MAX(birthday) AS youngest_birthdate
FROM gold.dim_customers

SELECT TOP 5 * FROM gold.dim_customers;
EXEC sp_rename 'gold.dim_customers.birthday', 'birthdate', 'COLUMN'; --changing the birthday to birthdate
SELECT 
    MIN(birthdate) AS oldest_birthdate,
	DATEDIFF(year,MIN(birthdate), GETDATE()) AS oldest_age,
    MAX(birthdate) AS youngest_birthdate,
	DATEDIFF(year,MAX(birthdate), GETDATE()) AS youngast_age
FROM gold.dim_customers;
