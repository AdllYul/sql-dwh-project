
/*
==================================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
==================================================================================
Script Purpose:
    This stored procedure implements ETL (Extract, Transform, and Load ) process to
the 'silver' layer.
  Actions performed:
    - Truncates Silver tables;
    - Inserts Cleansed & Transformed data from 'bronze' tables to 'silver'tables.
  Parameters:
    None.
    This stored procedure doesn't accepts any parameters or returns any values.
  Usage example:
    EXEC silver.load_silver;
==================================================================================
*/

EXEC silver.load_silver

CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	DECLARE @start_time datetime, @end_time datetime, @start_batch_time datetime, @end_batch_time datetime
  
	BEGIN TRY  
	SET @start_batch_time = GETDATE()
	PRINT '============================================'
	PRINT '========= LOADING SILVER LAYER ... ========='
	PRINT '============================================'

	PRINT '--------------------------------------------'
	PRINT '--------- LOADING ERP TABLES ... -----------'
	PRINT '--------------------------------------------'

	PRINT '>> Truncating Table: silver.crm_cust_info';
	SET @start_time = GETDATE()
	TRUNCATE TABLE silver.crm_cust_info;
	PRINT '>> Inserting Data Into: silver.crm_cust_info';

	INSERT INTO silver.crm_cust_info (
		cst_id
		,cst_key
		,cst_firstname
		,cst_lastname
		,cst_marital_status
		,cst_gndr
		,cst_create_date) 
    
	SELECT
		cst_id
		,cst_key
		,TRIM (cst_firstname) cst_firstname
		,TRIM (cst_lastname) cst_lastname
		,CASE 
			WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single' 
			WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
			ELSE 'n/a' 
		 END AS cst_marital_status -- Normalize marital values to readable format
		,CASE 
			WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male' 
			WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
			ELSE 'n/a' 
		 END AS cst_gndr -- Normalize gender values to readable format
		,cst_create_date
	FROM (
	 SELECT
	   *,
	   ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
	 FROM bronze.crm_cust_info
	 WHERE cst_id IS NOT NULL) t 
	WHERE flag_last = 1 -- Select the most recent record per customer

	SET @end_time = GETDATE()
	PRINT ('Process took ' + CAST(DATEDIFF(SECOND ,@start_time,@end_time) AS NVARCHAR) + ' seconds')	
	PRINT '---------------------------------'

	PRINT '>> Truncating Table: silver.crm_prd_info';
	TRUNCATE TABLE silver.crm_prd_info;
	
	SET @start_time = GETDATE()
	PRINT '>> Inserting Data Into: silver.crm_prd_info';

	INSERT INTO silver.crm_prd_info(
	prd_id,
	prd_key,
    cat_id,
	prd_nm, 
	prd_cost, 
	prd_line,
	prd_start_date,
	prd_end_date 
	)
    
	SELECT  
		prd_id
		,SUBSTRING(prd_key,7) AS prd_key -- Extracting product key
		,REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id -- Extracting category id
		,prd_nm
		,ISNULL(prd_cost,0) AS prd_cost
		,CASE UPPER(TRIM(prd_line))
			WHEN 'M' THEN 'Mountain'
			WHEN 'R' THEN 'Road'
			WHEN 'S' THEN 'Other Sales'
			WHEN 'T' THEN 'Touring'
			ELSE 'n/a' 
		END AS prd_line -- Map product line codes to descriptive values
		,prd_start_date
		,DATEADD(DAY ,-1,CAST(LEAD(prd_start_date) OVER (PARTITION BY prd_key ORDER BY prd_start_date) AS date)) AS prd_end_date -- Calculate end date 
	  FROM bronze.crm_prd_info

	SET @end_time = GETDATE()
	PRINT ('Process took ' + CAST(DATEDIFF(SECOND ,@start_time,@end_time) AS NVARCHAR) + ' seconds')	
	PRINT '---------------------------------'

	PRINT '>> Truncating Table: silver.crm_sales_details';
	TRUNCATE TABLE silver.crm_sales_details;
	SET @start_time = GETDATE() 
	PRINT '>> Inserting Data Into: silver.crm_sales_details';

	INSERT INTO silver.crm_sales_details(
	sls_prd_num,
	sls_prd_key,
	sls_cust_id,
	sls_order_dt,
	sls_ship_dt,
	sls_due_dt,
	sls_sales,
	sls_quantity,
	sls_price
	)

	SELECT 
		sls_prd_num,
		sls_prd_key,
		sls_cust_id,
		CASE 
			WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_order_dt AS varchar) AS date)
			END AS sls_order_dt,
		CASE 
			WHEN sls_ship_dt = 0 or LEN(sls_ship_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_ship_dt AS varchar) AS date)
			END AS sls_ship_dt,
		CASE 
			WHEN sls_due_dt = 0 or LEN(sls_due_dt) != 8 THEN NULL
			ELSE CAST(CAST(sls_due_dt AS varchar) AS date)
			END AS sls_due_dt,
		CASE WHEN sls_sales != ABS(sls_price) * sls_quantity OR sls_sales IS NULL OR sls_sales <= 0
			THEN NULLIF(sls_quantity,0) * ABS(sls_price)
			ELSE sls_sales -- Recalculate sales if original value is invalid
		END AS sls_sales,
		sls_quantity,
		CASE WHEN sls_price <= 0 OR sls_price IS NULL 
			THEN sls_sales / NULLIF( sls_quantity,0)
			ELSE sls_price
		END AS sls_price
	FROM bronze.crm_sales_details

	SET @end_time = GETDATE()
	PRINT ('Process took ' + CAST(DATEDIFF(SECOND ,@start_time,@end_time) AS NVARCHAR) + ' seconds')	
	PRINT '---------------------------------'

	PRINT '>> Truncating Table: silver.erp_cust_az12';
	TRUNCATE TABLE silver.erp_cust_az12;
	SET @start_time = GETDATE()
	PRINT '>> Inserting Data Into: silver.erp_cust_az12';

	INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
	SELECT
	CASE WHEN cid LIKE 'NASA%' THEN SUBSTRING(cid,4) -- Remove 'NAS' prefix if present
		 ELSE cid
		 END AS cid_new, 
	CASE WHEN bdate > GETDATE() THEN NULL -- Set future birthdates to NULL
		ELSE bdate
		END AS bdate,
	CASE WHEN UPPER(TRIM(gen)) IN ('F','FEMALE') THEN 'Female'
		 WHEN UPPER(TRIM(gen)) IN ('M','MALE')THEN 'Male'
		 ELSE 'n/a'
	END AS gen -- Normalize gender values & handle unknown cases
	FROM bronze.erp_cust_az12

	SET @end_time = GETDATE()
	PRINT ('Process took ' + CAST(DATEDIFF(SECOND ,@start_time,@end_time) AS NVARCHAR) +  ' seconds')	
	PRINT '---------------------------------'

	PRINT '>> Truncating Table: silver.erp_loc_a101';
	TRUNCATE TABLE silver.erp_loc_a101;
	SET @start_time = GETDATE()
	PRINT '>> Inserting Data Into: silver.erp_loc_a101';

	INSERT INTO silver.erp_loc_a101 (cid,country)

	SELECT
	REPLACE(cid,'-','') AS cid,
	CASE WHEN UPPER(TRIM(country)) IN ('USA','US', 'UNITED STATES') THEN 'United States'
		 WHEN UPPER(TRIM(country)) IN ('DE', 'GERMANY') THEN 'Germany'
		 WHEN TRIM(country) IS NULL OR country = '' THEN 'n/a'
		 ELSE TRIM(country) 
		 END AS country -- Normalize & handle missing or blank counrty codes
	FROM bronze.erp_loc_a101

	SET @end_time = GETDATE()
	PRINT ('Process took ' + CAST(DATEDIFF(SECOND ,@start_time,@end_time) AS NVARCHAR) + ' seconds')	
	PRINT '---------------------------------'

	PRINT '>> Truncating Table: silver.erp_px_cat_g1v2';
	TRUNCATE TABLE silver.erp_px_cat_g1v2;
	SET @start_time = GETDATE()
	PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2';

	INSERT INTO silver.erp_px_cat_g1v2(
	id,
	cat,
	subcat,
	maintenance)
	SELECT
		id,
		cat,
		subcat,
		maintenance
  FROM bronze.erp_px_cat_g1v2
  SET @end_time = GETDATE()
  PRINT ('Process took ' + CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + ' seconds')
	
  SET @end_batch_time = GETDATE()
  	PRINT ('Loading Silver Layer is completed:  ' + CAST(DATEDIFF(second,@start_batch_time,@end_batch_time) AS NVARCHAR) + ' seconds')
  	PRINT '---------------------------------'
  END TRY
    
  BEGIN CATCH 
  PRINT '====================================='
  PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER'
  PRINT ('Error message: ' + ERROR_MESSAGE())
  PRINT ('Error number ' + CAST(ERROR_NUMBER() AS NVARCHAR))
  PRINT '====================================='
  END CATCH
END
