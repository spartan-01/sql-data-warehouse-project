--which 5 products generate the highest revenue ?
SELECT Top 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
left join gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue DESC


-- what are 5 worst-performing products in term of sales ?

SELECT Top 5
p.product_name,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
left join gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name
ORDER BY total_revenue


---using the window function

SELECT *
FROM(
SELECT
p.product_name,
SUM(f.sales_amount) total_revenue,
ROW_NUMBER() OVER (ORDER BY SUM(f.sales_amount)DESC) AS rank_products
FROM gold.fact_sales f
left join gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.product_name)t
WHERE rank_products <= 5 


--best subcategory
SELECT Top 5
p.subcategory,
SUM(f.sales_amount) total_revenue
FROM gold.fact_sales f
left join gold.dim_products p
ON p.product_key = f.product_key
GROUP BY p.subcategory
ORDER BY total_revenue DESC




