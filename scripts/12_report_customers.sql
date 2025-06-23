BUILDING A REPORT
/*
===============================================================
Customer Report
===============================================================
Purpose:
    - This report consolidates key customer metrics and behaviors

Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
    2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
        - total orders
        - total sales
        - total quantity purchased
        - total products
        - lifespan (in months)
    4. Calculates valuable KPIs:
        - recency (months since last order)
        - average order value
        - average monthly spend
===============================================================
*/

*/

-----chatgpt
*/

SELECT * FROM gold.report_customers
-----chatgpt
CREATE VIEW gold.report_customers AS
WITH customer_summary AS (
    SELECT 
        c.customer_key,
        c.first_name,
        c.last_name,
        DATEDIFF(YEAR, c.birthdate, GETDATE()) AS age,

        COUNT(DISTINCT f.order_date) AS total_orders,
        SUM(f.sales_amount) AS total_sales,
        SUM(f.quantity) AS total_quantity,
        COUNT(DISTINCT f.product_key) AS total_products,

        MIN(f.order_date) AS first_order_date,
        MAX(f.order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan,
        DATEDIFF(MONTH, MAX(f.order_date), GETDATE()) AS recency
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.customer_key, c.first_name, c.last_name, c.birthdate
),

customer_kpis AS (
    SELECT 
        *,
        CASE 
            WHEN lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
            WHEN lifespan >= 12 THEN 'REGULAR'
            ELSE 'NEW'
        END AS customer_segment,

        CASE 
            WHEN age < 25 THEN 'Under 25'
            WHEN age BETWEEN 25 AND 39 THEN '25-39'
            WHEN age BETWEEN 40 AND 59 THEN '40-59'
            ELSE '60+'
        END AS age_group,

        CEILING(total_sales * 1.0 / NULLIF(total_orders, 0)) AS avg_order_value,
        CEILING(total_sales * 1.0 / NULLIF(lifespan, 0)) AS avg_monthly_spend
    FROM 
        customer_summary
)
SELECT 
    customer_key,
    first_name,
    last_name,
    age,
    age_group,
    customer_segment,
    total_orders,
    total_sales,
    total_quantity,
    total_products,
    lifespan,
    recency,
    avg_order_value,
    avg_monthly_spend
FROM 
    customer_kpis;
