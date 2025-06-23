3 PERFORMANCE ANALYSIS

Compare the current value to a target value
Helps measure success and compare performance.
--Formulae=  performance analysis: current measure - target measure
--that is current -average sales
current year sakes - previous year sales


-------------------------------

/*Analyze the yearly performance of products by comparing their sales to both the average sales performance of the product and the previouse years sales*/


WITH yearly_product_sales AS (
    SELECT
        YEAR(f.order_date) AS order_year,
        p.product_name,
        SUM(f.sales_amount) AS current_sales
    FROM gold.fact_sales f
    LEFT JOIN gold.dim_products p
        ON f.product_key = p.product_key
    WHERE f.order_date IS NOT NULL
    GROUP BY
        YEAR(f.order_date),
        p.product_name
)
SELECT
    order_year,
    product_name,
    current_sales,
    AVG(current_sales) OVER (PARTITION BY product_name) AS avg_sales,
    current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diff_avg,
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS prev_year_sales,
    CASE
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
        WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
        ELSE 'Avg'
    END AS avg_change,
    -- Percentage change from previous year
    CASE
        WHEN LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) IS NOT NULL
             AND LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) <> 0
        THEN ROUND(
            (current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year))
            / LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) * 100, 2)
        ELSE NULL -- Retaining NULL for pct_change_from_prev_year where prev_year_sales is NULL or zero
    END AS pct_change_from_prev_year,
    -- Change direction from previous year (NULLs removed)
    CASE
        WHEN LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) IS NULL THEN 'No Change' -- Changed from NULL to 'No Change'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END AS py_change
FROM yearly_product_sales
ORDER BY product_name, order_year;
