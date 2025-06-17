/*
===============================================================================
Quality Checks
===============================================================================

Script Purpose:
    This script performs quality checks to validate the integrity, consistency,
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Run these checks after data loading Silver Layer.
    - Investigate and resolve any discrepancies found during the checks.

===============================================================================
*/

-- =============================================================================
-- Checking 'gold.dim_customers'
-- =============================================================================

-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results



---check 
SELECT * FROM gold.dim_customers

---CHECK FOR DUPLICATES

SELECT cst_id, COUNT(*) FROM
(SELECT	ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry 
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON         ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON         ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1


--check data integration

SELECT	
		ci.cst_gndr,
		ca.gen,
	    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender info
		     ELSE COALESCE(ca.gen, 'n/a')
	     END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON         ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON         ci.cst_key = la.cid
ORDER BY 1,2




---check 
SELECT * FROM gold.dim_customers

---CHECK FOR DUPLICATES

SELECT cst_id, COUNT(*) FROM
(SELECT	ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_marital_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry 
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON         ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON         ci.cst_key = la.cid
)t GROUP BY cst_id
HAVING COUNT(*) > 1


--check data integration

SELECT	
		ci.cst_gndr,
		ca.gen,
	    CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr --CRM is the Master for gender info
		     ELSE COALESCE(ca.gen, 'n/a')
	     END AS new_gen
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON         ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON         ci.cst_key = la.cid
ORDER BY 1,2



--check the data quality
SELECT * FROM gold.fact_sales


--foreign key integrity (Dimensions)
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c 
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL

