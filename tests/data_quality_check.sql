/*
================================================================================
           ============== Quality checks =======================
================================================================================
Script purpose:
    This script performs various quality checks for
data consistency, accuracy, and standartization across the 'silver' schema.
It also includes checks for:
  - Null or Duplicate primary;
  - White spaces in fields;
  - Data standartization & Consistency;
  - Invalid data ranges & orders;
  - Data consistency between related fields.

Usage notice:
  - Run these checks after loading the 'silver' layer
  - Investigate and resolve discrepancies found during check.
================================================================================
*/

-- ==================================================
-- Checking silver.crm_cust_info
-- ==================================================

-- Check for white spaces
-- Expectation: No results

SELECT
  cst_gndr
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr)

SELECT
  cst_marital_status
FROM silver.crm_cust_info
WHERE cst_marital_status != TRIM(cst_marital_status)

-- Data standartization & consistensy

SELECT
  DISTINCT cst_gndr
FROM silver.crm_cust_info

SELECT
  DISTINCT cst_marital_status
FROM silver.crm_cust_info

-- Check for null & duplicates in pk
-- Expectation: No result

SELECT 
  cst_id,
COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL

SELECT
*
FROM silver.crm_cust_info

-- ==================================================
-- Checking silver.crm_prd_info
-- ==================================================

-- Check for nulls & duplicates in pk
-- Expectation: No results

SELECT
  prd_id,
COUNT(*) AS count
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL


-- Check for white spaces
-- Expectation: No results

SELECT
  prd_nm
FROM silver.crm_prd_info
WHERE len(prd_nm) != LEN(TRIM(prd_nm))

-- Check for negative values & null 
-- Expectation: No results

SELECT
	prd_cost
FROM silver.crm_prd_info
WHERE ISNULL(prd_cost,0) < 0 OR ISNULL(prd_cost,0) IS NULL

-- Data standartization & Consistency
SELECT
DISTINCT prd_line
FROM  silver.crm_prd_info

-- Check for invalid Date Orders

SELECT
  *
FROM silver.crm_prd_info
WHERE prd_end_date < prd_start_date


-- ==================================================
-- Checking silver.crm_sales_details
-- ==================================================


  
-- Check for uniqness of the pk

SELECT
  sls_prd_num,
COUNT(*)
FROM silver.crm_sales_details
GROUP BY sls_prd_num 
HAVING COUNT(*) > 1 AND sls_prd_num IS NULL


-- Check for white spaces
SELECT 
  sls_prd_key
FROM silver.crm_sales_details
WHERE len(sls_prd_key ) != LEN(TRIM(sls_prd_key))

-- Check for joining
SELECT 
	*
FROM silver.crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id
FROM silver.crm_cust_info)

-- Check for neg. numbers & null

SELECT
  NULLIF(sls_order_dt,0) AS sls_order_dt
FROM silver.crm_sales_details
WHERE sls_order_dt <= 0 
OR len(sls_order_dt) != 8
OR sls_order_dt < 19000101
OR sls_order_dt > 20500101


-- Check for Invalid date orders

SELECT
 *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt 


 -- Check data consistency: Between sales, quantity and price.
 -- >> Sales = Quantity * Price
 -- >> Values must not be null, negative and zero

 SELECT
   sls_price AS old_price,
   sls_quantity,
   sls_sales AS old_sales,
	 CASE WHEN sls_sales != ABS(sls_price) * sls_quantity OR sls_sales IS NULL OR sls_sales <= 0
	   THEN NULLIF(sls_quantity,0) * ABS(sls_price)
		 ELSE sls_sales
	 END AS sls_sales,
	 CASE WHEN sls_price <= 0 OR sls_price is NULL 
		 THEN sls_sales / NULLIF( sls_quantity,0)
		 ELSE sls_price
	 END AS sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_price * sls_quantity
 OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
 OR sls_price IS NULL OR sls_quantity IS NULL OR sls_sales IS NULL
 OR sls_price <= 0 OR sls_quantity <= 0 OR sls_sales <= 0


-- ==================================================
-- Checking silver.erp_cust_az12
-- ==================================================

-- Identify out-of-range dates
SELECT
  DISTINCT bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1900-01-01' OR bdate > GETDATE()

-- Data standartization & Consistency
SELECT
  DISTINCT gen,
  CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
	   WHEN UPPER(TRIM(gen)) IN ('M','MALE')THEN 'Male'
	   ELSE 'n/a'
  END AS GEN
FROM silver.erp_cust_az12

-- ==================================================
-- Checking silver.erp_loc_a101
-- ==================================================

-- Data standartization & Consistency
SELECT
  DISTINCT
  CASE WHEN UPPER(TRIM(country)) IN ('USA','US', 'UNITED STATES') THEN 'United States'
  	   WHEN UPPER(TRIM(country)) IN ('DE', 'GERMANY') THEN 'Germany'
  	   WHEN TRIM(country) IS NULL OR country = '' THEN 'n/a'
  	   ELSE TRIM(country) 
  END AS country,
  country
FROM bronze.erp_loc_a101

-- ==================================================
-- Checking silver.erp_px_cat_g1v2
-- ==================================================


-- Checking for Join
SELECT
	id,
	cat,
	subcat,
	maintenance,
	*
FROM silver.erp_px_cat_g1v2
JOIN silver.crm_prd_info
ON id = cat_id
WHERE id NOT IN (
  SELECT
    cat_id
FROM silver.crm_prd_info)

-- Check for unwanted space
SELECT
  cat,
  LEN(cat),
  len(TRIM(cat))
FROM bronze.erp_px_cat_g1v2
WHERE len(cat) != len(TRIM(cat)) OR len(subcat) != len(TRIM(subcat)) or len(maintenance) != len(TRIM(maintenance))

-- Data standartization & Consistency
SELECT
DISTINCT
  maintenance
  --,cat
  --,subcat
FROM bronze.erp_px_cat_g1v2




