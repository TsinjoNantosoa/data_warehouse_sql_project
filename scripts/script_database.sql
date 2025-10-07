/*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, this script creates schemas called bronze, silver, and gold.
    
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

-- Switch to the system database
USE master;
GO

-- Drop the database if it already exists to avoid errors
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    DROP DATABASE DataWarehouse;
    PRINT 'Database DataWarehouse has been dropped.';
END
GO

-- Create the new database
CREATE DATABASE DataWarehouse;
GO

-- Switch to the newly created database
USE DataWarehouse;
GO

-- Create different schemas to organize data

-- Bronze schema: for raw / ingested data
CREATE SCHEMA bronze;
GO

-- Silver schema: for cleaned / transformed data
CREATE SCHEMA silver;
GO

-- Gold schema: for final data used for reporting / analytics
CREATE SCHEMA gold;
GO

PRINT 'Database DataWarehouse and schemas bronze, silver, gold have been successfully created.';
