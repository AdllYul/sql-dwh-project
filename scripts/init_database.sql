/*
===================================================
CREATE DATABASE AND SCHEMAS
===================================================
Script Purpose:
This script creates a new database 'DataWarehouse' after checking if it already exists.
If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas within the 
database: 'bronze', 'silver' and 'gold'.

WARNING:
Running this scripts will drop 'DataWarehouse' database, if it is exists. If the database exists, it is droped and recreated. 
Proceed with caution and ensure you have proper backup.
*/

USE master;
GO

--Drop and recreate the 'DataWarehouse' database
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
  ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
  DROP TABLE DataWarehouse;
END;
GO
--Create Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

--Create Schemas
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO 

CREATE SCHEMA gold;

