/*
====================================================================
DDL Script Purpose: Create Silver Tables
====================================================================
Script Purpose:
    This script creates tables in 'silver' schema, drops them if they
already exists.
  Run this script to re-define structure of 'bronze' layer tables.
====================================================================
*/


IF OBJECT_ID ('silver.crm_prd_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_prd_info;

CREATE TABLE silver.crm_prd_info(
prd_id NVARCHAR(50),
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost INT,
prd_line NVARCHAR(30),
prd_start_date DATE,
prd_end_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
);


IF OBJECT_ID ('silver.crm_sales_details', 'U') IS NOT NULL
	DROP TABLE silver.crm_sales_details;
CREATE TABLE silver.crm_sales_details(
sls_prd_num NVARCHAR(30),
sls_prd_key NVARCHAR(30),
sls_cust_id NVARCHAR(50),
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT
,dwh_create_date datetime2 DEFAULT GETDATE()

)


IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
	DROP TABLE silver.crm_cust_info

CREATE TABLE silver.crm_cust_info(
cst_id NVARCHAR(50),
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR (50),
cst_marital_status NVARCHAR(30),
cst_gndr NVARCHAR(30),
cst_create_date DATE,
dwh_create_date DATETIME2 DEFAULT GETDATE()
)




IF OBJECT_ID ('silver.erp_cust_az12', 'U') IS NOT NULL
	DROP TABLE silver.erp_cust_az12;

CREATE TABLE silver.erp_cust_az12 (
cid NVARCHAR(50),
bdate DATE,
den NVARCHAR(30)
,dwh_create_date datetime2 DEFAULT GETDATE()
)


IF OBJECT_ID ('silver.erp_loc_a101', 'U') IS NOT NULL
	DROP TABLE silver.erp_loc_a101;

CREATE TABLE silver.erp_loc_a101(
cid NVARCHAR(50),
country NVARCHAR(30)
,dwh_create_date DATETIME2 DEFAULT GETDATE()
)


IF OBJECT_ID ('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
	DROP TABLE silver.erp_px_cat_g1v2;

CREATE TABLE silver.erp_px_cat_g1v2(
id NVARCHAR(50),
cat NVARCHAR(50),
subcat NVARCHAR(50),
maintenance NVARCHAR(30)
,dwh_create_date DATETIME2 DEFAULT GETDATE()
)
