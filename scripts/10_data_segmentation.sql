DATA SEGMENTATION
GROUP THE DATA ON A SPECIFIC RANGE

--SEGMENT PRODUCTS INTO COST RANGES AND 
--COUNT HOW MANY PRODUCTS FALL INTO EACH SEGMENT

 -- Segment products into cost ranges and count how many fall into each
WITH product_segments AS (
    SELECT 
        product_key,
        product_name,
        cost,
        CASE 
            WHEN cost < 100 THEN 'below 100'
            WHEN cost BETWEEN 100 AND 500 THEN '100-500'
            WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
            ELSE 'Above 1000'
        END AS cost_range
    FROM 
        gold.dim_products
)

SELECT 
    cost_range,
    COUNT(product_key) AS total_products
FROM 
    product_segments
GROUP BY 
    cost_range
ORDER BY 
    total_products DESC;



============================================================

/*
Group customers into three segments based on their spending behavior:
    - VIP: Customers with at least 12 months of history and spending more than €5,000.
    - Regular: Customers with at least 12 months of history but spending €5,000 or less.
    - New: Customers with a lifespan less than 12 months.
And find the total number of customers by each group
*/
WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        DATEDIFF(MONTH, MIN(f.order_date), MAX(f.order_date)) AS lifespan
    FROM 
        gold.fact_sales f
    LEFT JOIN 
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.customer_key
),

customer_segments AS (
    SELECT 
        customer_key,
        total_spending,
        lifespan,
        CASE 
            WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
            WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'REGULAR'
            ELSE 'NEW CUSTOMER'
        END AS customer_segment
    FROM 
        customer_spending
)

SELECT 
    customer_segment,
    COUNT(*) AS customer_count
FROM 
    customer_segments
GROUP BY 
    customer_segment
ORDER BY 
    customer_count DESC;



WITH customer_spending AS (
    SELECT 
        c.customer_key,
        SUM(f.sales_amount) AS total_spending,
        MIN(order_date) AS first_order,
        MAX(order_date) AS last_order,
        DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
    FROM 
        gold.fact_sales f
    LEFT JOIN  
        gold.dim_customers c ON f.customer_key = c.customer_key
    GROUP BY 
        c.customer_key
)

SELECT
    CASE 
        WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'REGULAR'
        ELSE 'NEW CUSTOMER'
    END AS customer_segment,
    COUNT(*) AS total_customers
FROM 
    customer_spending
GROUP BY 
    CASE 
        WHEN lifespan >= 12 AND total_spending > 5000 THEN 'VIP'
        WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'REGULAR'
        ELSE 'NEW CUSTOMER'
    END
ORDER BY 
    total_customers DESC;

