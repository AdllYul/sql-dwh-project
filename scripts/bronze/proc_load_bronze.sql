/*
===========================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===========================================================
Script Purpose:
    This stored procedure loads data into 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the 'BULK INSERT' command to load data from CSV files to bronze tables.
Parameters:
    None.
  This stored procedure doesn't accept any paremeters or return any values.
Usage Example:
    EXEC bronze.load_bronze;
===========================================================
*/



CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time datetime, @end_time datetime, @end_batch_time datetime, @start_batch_time datetime
	BEGIN TRY
		SET @start_batch_time = GETDATE()
		PRINT '================================';
		PRINT 'LOADING BRONZE LAYER...';
		PRINT '================================';

		PRINT '--------------------------------'
		PRINT 'Loading CRM Tables'
		PRINT '--------------------------------'

		
		PRINT '>> Truncating Table: bronze.crm_cust_info ';
		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.crm_cust_info; 

		PRINT '>> Inserting into: bronze.crm_cust_info ';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK)
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')
		PRINT '-----------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.crm_prd_info ';
		TRUNCATE TABLE bronze.crm_prd_info;

		PRINT '>> Inserting Into: bronze.crm_prd_info ';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			)
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')
		PRINT '-----------------'

		SET @start_time = GETDATE()
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>> Truncating Table: bronze.crm_sales_details ';

		PRINT '>> Inserting Into: bronze.crm_sales_details ';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			)
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')
		PRINT '-----------------'

		PRINT '--------------------------------';
		PRINT 'Loading ERP Tables';
		PRINT '--------------------------------'

		SET DATEFORMAT dmy;
		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_cust_az12 ';
		TRUNCATE TABLE bronze.erp_cust_az12

		PRINT '>> Inserting Into: bronze.erp_cust_az12 ';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			 )
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')
		PRINT '-----------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_loc_a101 ';
		TRUNCATE TABLE bronze.erp_loc_a101;

		PRINT '>> Inserting into: bronze.erp_loc_a101'
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			)
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')
		PRINT '-----------------'

		SET @start_time = GETDATE()
		PRINT '>> Truncating Table: bronze.erp_px_cat_g1v21 '
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;

		PRINT '>> Inserting: bronze.erp_px_cat_g1v2 '
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\HP\Desktop\SQLBAARA\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
			)
		SET @end_time = GETDATE()
		PRINT('Process took ' + CAST(DATEDIFF(second, @start_time, @end_time ) as NVARCHAR) + ' seconds')

		SET @end_batch_time = GETDATE()
		PRINT ('Loading Bronze Layer is completed: ' + CAST(DATEDIFF(second, @start_batch_time, @end_batch_time) as NVARCHAR)+ 'seconds')
	END TRY
	BEGIN CATCH
	PRINT '========================================='
	PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER'
	PRINT 'Error message: ' + Error_message();
	PRINT 'Error number: ' + CAST(Error_number() as nvarchar)
	PRINT '========================================='
	END CATCH
END

