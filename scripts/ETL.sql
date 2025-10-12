CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
   DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
   BEGIN TRY
    PRINT '================================';
    PRINT 'Loading Bronze Layer';
    PRINT '================================';

    PRINT '--------------------------------';
    PRINT 'Loading CRM Tables';
    PRINT '--------------------------------';

    SET @start_time = GETDATE();
    PRINT 'Truncating Table: bronze.crm_cust_info';
    TRUNCATE TABLE bronze.crm_cust_info;
    PRINT 'Inserting data into: bronze.crm_cust_info';
    BULK INSERT bronze.crm_cust_info
    FROM '/var/opt/mssql/cust_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
     SET @end_time = GETDATE();
     PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
     PRINT '--------------------------'

    SET @start_time = GETDATE();
    PRINT 'Truncating Table: bronze.crm_prd_info';
    TRUNCATE TABLE bronze.crm_prd_info;
    PRINT 'Inserting data into: bronze.crm_prd_info';
    BULK INSERT bronze.crm_prd_info
    FROM '/var/opt/mssql/prd_info.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
    PRINT'---------------------'

    PRINT 'Truncating Table: bronze.crm_sales_details';
    TRUNCATE TABLE bronze.crm_sales_details;
    PRINT 'Inserting data into: bronze.crm_sales_details';
    BULK INSERT bronze.crm_sales_details
    FROM '/var/opt/mssql/sales_details.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
    PRINT'---------------------'

    PRINT '--------------------------------';
    PRINT 'Loading ERP Tables';
    PRINT '--------------------------------';


    SET @end_time = GETDATE();
    PRINT 'Truncating Table: bronze.erp_cust_az12';
    TRUNCATE TABLE bronze.erp_cust_az12;
    PRINT 'Inserting data into: bronze.erp_cust_az12';
    BULK INSERT bronze.erp_cust_az12
    FROM '/var/opt/mssql/cust_az12.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK,
        ERRORFILE = '/var/opt/mssql/bulk_error.log',
        MAXERRORS = 10
    );
    SET @end_time = GETDATE();
    PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
    PRINT'---------------------'


    SET @end_time = GETDATE();
    PRINT 'Truncating Table: bronze.erp_loc_a101';
    TRUNCATE TABLE bronze.erp_loc_a101;
    PRINT 'Inserting data into: bronze.erp_loc_a101';
    BULK INSERT bronze.erp_loc_a101
    FROM '/var/opt/mssql/loc_a101.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
    PRINT'---------------------'


    SET @end_time = GETDATE();
    PRINT 'Truncating Table: bronze.erp_px_cat_g1v2';
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    PRINT 'Inserting data into: bronze.erp_px_cat_g1v2';
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM '/var/opt/mssql/px_cat_g1v2.csv'
    WITH (
        FIRSTROW = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR = '\n',
        TABLOCK
    );
    SET @end_time = GETDATE();
    PRINT 'Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' Seconds';
    PRINT'---------------------'

    SET @batch_end_time = GETDATE();
    PRINT '======================'
    PRINT 'Loading Bronze Layer is Completed';
    PRINT 'Total Load Duration ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' Seconds'; 


    END TRY
    BEGIN CATCH
      PRINT'================================';
      PRINT'ERROR OCCURED DURING LOADING BRONZE LAYER';
      PRINT'Error Message' + ERROR_MESSAGE();
      PRINT'Error Number' + CAST(ERROR_NUMBER() AS NVARCHAR)
      PRINT'Error Number' + CAST(ERROR_STATE() AS NVARCHAR)
      PRINT'================================'

    END CATCH
END;
GO

-- Exécution
EXEC bronze.load_bronze;
