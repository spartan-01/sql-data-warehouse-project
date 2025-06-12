/* Quality Check
============================================================  
Script Purpose:  
    This script performs a series of quality checks to ensure data consistency, accuracy, and standardization across the 'silver' schema. The checks include:  
    - Null or duplicate primary keys.  
    - Unwanted spaces in string fields.  
    - Data standardization and consistency.  
    - Invalid date ranges and sequences.  
    - Data consistency between related fields.  

Usage Notes:  
    - Execute these checks after loading data into the Silver Layer.  
    - Investigate and resolve any discrepancies identified during the checks.  
============================================================


-- Drop the table if it already exists
IF OBJECT_ID('silver.crm_sales_details') IS NOT NULL
    DROP TABLE silver.crm_sales_details;
GO

-- Create and populate the table in one step using SELECT INTO
SELECT
    sls_ord_num,
    sls_prd_key,
    sls_cust_id,

    -- Cleaned Order Date
    CASE 
        WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
    END AS sls_order_dt,

    -- Cleaned Ship Date
    CASE 
        WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
    END AS sls_ship_dt,

    -- Cleaned Due Date
    CASE 
        WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
        ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
    END AS sls_due_dt,

    -- Cleaned Sales Amount
    CASE 
        WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)
        ELSE sls_sales
    END AS sls_sales,

    -- Quantity
    sls_quantity,

    -- Cleaned Price
    CASE 
        WHEN sls_price IS NULL OR sls_price < 0
            THEN sls_sales / NULLIF(sls_quantity, 0)
        ELSE sls_price
    END AS sls_price

INTO silver.crm_sales_details
FROM bronze.crm_sales_details;

----==================================================

----check for invalid Date Orders

SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

SELECT DISTINCT
sls_sales,
sls_quantity,
sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
OR sls_sales IS NULL OR sls_quantity IS NULL OR sls_price IS NULL
OR sls_sales <= 0 OR sls_quantity = 0 OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

SELECT * FROM silver.crm_sales_details



SELECT * FROM silver.crm_sales_details


INSERT INTO silver.erp_loc_a101 (cid, cntry)
SELECT
REPLACE (cid, '-', '')cid,
CASE WHEN TRIM(cntry) = 'DE' THEN 'Germany'
     WHEN TRIM(cntry) IN ('US', 'USA') THEN 'United State'
	 WHEN TRIM(cntry) ='' OR cntry IS NULL THEN 'n/a'
	 ELSE TRIM(cntry)
	 END AS cntry
FROM bronze.erp_loc_a101

--====

SELECT cst_key FROM silver.crm_cust_info

--- CHECK FOR DATA STANDIZATION

SELECT
REPLACE (CID, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE REPLACE (CID, '-', '') NOT IN
(SELECT cst_key FROM silver.crm_cust_info)

----
SELECT
REPLACE (cid, '-', '') cid,
cntry
FROM bronze.erp_loc_a101 WHERE cid NOT IN 
(SELECT cst_key FROM silver.crm_cust_info)

--- CHECK FOR DATA STANDIZATION and Consistency

SELECT DISTINCT cntry
FROM bronze.erp_loc_a101
ORDER BY cntry

-- FINAL CHECK FOR DATA STANDIZATION and Consistency
 SELECT DISTINCT cntry
 FROM silver.erp_loc_a101
 ORDER BY cntry

 SELECT * FROM silver.erp_loc_a101


CREATE OR ALTER PROCEDURE silver.load_silver
BEGIN

PRINT '>> insertng data into :silver.crm_cust_info';
TRUNCATE TABLE silver.crm_cust_info;
PRINT '>> insertng data into :silver.crm_cust_info';
INSERT INTO silver.crm_cust_info (
cst_id,
cst_key,
cst_firstname,
cst_lastname,
cst_marital_status,
cst_gndr,
cst_create_date)

SELECT
cst_id,
cst_key,
TRIM(cst_firstname) AS cst_firstname,
TRIM(cst_lastname) AS cst_lastname,
CASE WHEN UPPER (TRIM(cst_marital_status)) = 'S' THEN 'Single'
     WHEN UPPER (TRIM(cst_marital_status)) = 'M' THEN 'Married'
	 ELSE 'n/a'
END	 cst_marital_status,

CASE WHEN UPPER (TRIM(cst_gndr)) = 'F' THEN 'Female'
     WHEN UPPER (TRIM(cst_gndr)) = 'M' THEN 'Male'
	 ELSE 'n/a'
END	 cst_gndr,
cst_create_date
FROM(SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC ) as flag_last
FROM bronze.crm_cust_info
WHERE cst_id IS NOT NULL
)t WHERE flag_last =1


SELECT * FROM silver.crm_cust_info

---insert the table from bronzen.crm_prd_info  to silver.crm_prd_info 

INSERT INTO silver.crm_prd_info (
prd_id,
cat_id,
prd_key,
prd_nm,
prd_cost,
prd_line,
prd_start_dt,
prd_end_dt
)
SELECT 
prd_id,
REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key,
prd_nm,
ISNULL(prd_cost, 0) AS prd_cost,
CASE  UPPER(TRIM(prd_line)) 
      WHEN 'M' THEN 'Mountain'
      WHEN  'R' THEN 'Road'
	  WHEN  'S' THEN 'Other Sales'
	  WHEN  'T' THEN 'Touring'
	  ELSE 'n/a'
END AS prd_line,
CAST (prd_start_dt AS DATE) AS prd_start_dt,
CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE)AS prd_end_dt
FROM bronze.crm_prd_info

===
CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50) NULL,
    cat NVARCHAR(50) NULL,
    subcat NVARCHAR(50) NULL,
    maintenance NVARCHAR(50) NULL
--INSERT INTO THE TABLE
PRINT '>> insertng data into :silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT '>> insertng data into :ssilver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2
(id, cat, subcat, maintenance)
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2


SELECT * FROM silver.erp_px_cat_g1v2

---check for unwated spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--Data Standardization & Consistency
SELECT DISTINCT 
cat 
FROM bronze.erp_px_cat_g1v2

--
SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2



--
SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2



--check the data
SELECT * FROM silver.erp_px_cat_g1v2

---
SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'erp_px_cat_g1v2';



INSERT INTO dbo.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT id, cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2;
---------------------------------------------
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'erp_px_cat_g1v2';
---------------------------------------------------

==
PRINT '>> insertng data into :silver.crm_cust_info';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> insertng data into :silver.crm_cust_info';
INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))--Remove 'NAS' prefix if present
     ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END  AS bdate, -- Set future birthdates to NULL 
 CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
      WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	  ELSE 'n/a'
	END AS gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az12



------------check for data transformation

SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)


--check the birthdate. Identfy out-of-range date

SELECT DISTINCT 
 bdate
 FROM bronze.erp_cust_az12
 WHERE bdate < '1924-01-01' OR bdate > GETDATE()


 --dATA Standization & Consistency

 SELECT DISTINCT 
 gen,
FROM bronze.erp_cust_az12

---check date quality
SELECT DISTINCT 
 bdate
 FROM silver.erp_cust_az12
 WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--=====

  SELECT DISTINCT 
 gen
FROM silver.erp_cust_az12

--=======

SELECT * FROM silver.crm_cust_info


--

PRINT '>> insertng data into :silver.crm_cust_info';
TRUNCATE TABLE silver.erp_cust_az12;
PRINT '>> insertng data into :silver.crm_cust_info';
INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
SELECT
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))--Remove 'NAS' prefix if present
     ELSE cid
END cid,
CASE WHEN bdate > GETDATE() THEN NULL
     ELSE bdate
END  AS bdate, -- Set future birthdates to NULL 
 CASE WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
      WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
	  ELSE 'n/a'
	END AS gen -- Normalize gender values and handle unknown cases
FROM bronze.erp_cust_az12



------------check for data transformation

SELECT
cid,
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END cid,
bdate,
gen
FROM bronze.erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
     ELSE cid
END NOT IN (SELECT DISTINCT cst_key FROM silver.crm_cust_info)


--check the birthdate. Identfy out-of-range date

SELECT DISTINCT 
 bdate
 FROM bronze.erp_cust_az12
 WHERE bdate < '1924-01-01' OR bdate > GETDATE()


 --dATA Standization & Consistency

 SELECT DISTINCT 
 gen,
FROM bronze.erp_cust_az12

---check date quality
SELECT DISTINCT 
 bdate
 FROM silver.erp_cust_az12
 WHERE bdate < '1924-01-01' OR bdate > GETDATE()

--=====

  SELECT DISTINCT 
 gen
FROM silver.erp_cust_az12

--=======

SELECT * FROM silver.crm_cust_info

==CREATE TABLE silver.erp_px_cat_g1v2 (
    id NVARCHAR(50) NULL,
    cat NVARCHAR(50) NULL,
    subcat NVARCHAR(50) NULL,
    maintenance NVARCHAR(50) NULL
--INSERT INTO THE TABLE
PRINT '>> insertng data into :silver.erp_px_cat_g1v2';
TRUNCATE TABLE silver.erp_px_cat_g1v2;
PRINT '>> insertng data into :ssilver.erp_px_cat_g1v2';
INSERT INTO silver.erp_px_cat_g1v2
(id, cat, subcat, maintenance)
SELECT
id,
cat,
subcat,
maintenance
FROM bronze.erp_px_cat_g1v2


SELECT * FROM silver.erp_px_cat_g1v2

---check for unwated spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

--Data Standardization & Consistency
SELECT DISTINCT 
cat 
FROM bronze.erp_px_cat_g1v2

--
SELECT DISTINCT 
subcat
FROM bronze.erp_px_cat_g1v2



--
SELECT DISTINCT 
maintenance
FROM bronze.erp_px_cat_g1v2



--check the data
SELECT * FROM silver.erp_px_cat_g1v2

---
SELECT * 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME = 'erp_px_cat_g1v2';



INSERT INTO dbo.erp_px_cat_g1v2 (id, cat, subcat, maintenance)
SELECT id, cat, subcat, maintenance
FROM bronze.erp_px_cat_g1v2;
---------------------------------------------
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_NAME = 'erp_px_cat_g1v2';
---------------------------------------------------






