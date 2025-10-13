/*
================================================================================
Objectif de la procédure : bronze.load_bronze
================================================================================
Cette procédure charge les données brutes dans les tables de la "Bronze Layer" 
d'un entrepôt de données. Elle réalise les actions suivantes :

1. Troncature des tables existantes pour éviter les doublons.
2. Chargement des fichiers CSV dans les tables CRM et ERP correspondantes.
3. Mesure et affichage du temps de chargement pour chaque table.
4. Gestion des erreurs avec TRY...CATCH pour capturer et afficher les erreurs.

Tables concernées :
- CRM : crm_cust_info, crm_prd_info, crm_sales_details
- ERP : erp_cust_az12, erp_loc_a101, erp_px_cat_g1v2
================================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze
AS
BEGIN
    -- Déclaration des variables de temps
    DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;

    BEGIN TRY
        PRINT '================================';
        PRINT 'Chargement de la Bronze Layer';
        PRINT '================================';

        -- =====================
        -- Chargement des tables CRM
        -- =====================
        PRINT '--------------------------------';
        PRINT 'Chargement des tables CRM';
        PRINT '--------------------------------';

        -- crm_cust_info
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.crm_cust_info';
        TRUNCATE TABLE bronze.crm_cust_info;

        PRINT 'Insertion des données dans : bronze.crm_cust_info';
        BULK INSERT bronze.crm_cust_info
        FROM '/var/opt/mssql/cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- crm_prd_info
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.crm_prd_info';
        TRUNCATE TABLE bronze.crm_prd_info;

        PRINT 'Insertion des données dans : bronze.crm_prd_info';
        BULK INSERT bronze.crm_prd_info
        FROM '/var/opt/mssql/prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- crm_sales_details
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.crm_sales_details';
        TRUNCATE TABLE bronze.crm_sales_details;

        PRINT 'Insertion des données dans : bronze.crm_sales_details';
        BULK INSERT bronze.crm_sales_details
        FROM '/var/opt/mssql/sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- =====================
        -- Chargement des tables ERP
        -- =====================
        PRINT '--------------------------------';
        PRINT 'Chargement des tables ERP';
        PRINT '--------------------------------';

        -- erp_cust_az12
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.erp_cust_az12';
        TRUNCATE TABLE bronze.erp_cust_az12;

        PRINT 'Insertion des données dans : bronze.erp_cust_az12';
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
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- erp_loc_a101
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.erp_loc_a101';
        TRUNCATE TABLE bronze.erp_loc_a101;

        PRINT 'Insertion des données dans : bronze.erp_loc_a101';
        BULK INSERT bronze.erp_loc_a101
        FROM '/var/opt/mssql/loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- erp_px_cat_g1v2
        SET @start_time = GETDATE();
        PRINT 'Troncature de la table : bronze.erp_px_cat_g1v2';
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;

        PRINT 'Insertion des données dans : bronze.erp_px_cat_g1v2';
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM '/var/opt/mssql/px_cat_g1v2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            TABLOCK
        );

        SET @end_time = GETDATE();
        PRINT 'Durée du chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------';

        -- Fin du batch
        SET @batch_end_time = GETDATE();
        PRINT '======================';
        PRINT 'Chargement de la Bronze Layer terminé';
        PRINT 'Durée totale du chargement : ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' secondes'; 

    END TRY
    BEGIN CATCH
        -- Gestion des erreurs
        PRINT '================================';
        PRINT 'ERREUR SURVENUE LORS DU CHARGEMENT DE LA BRONZE LAYER';
        PRINT 'Message d''erreur : ' + ERROR_MESSAGE();
        PRINT 'Numéro d''erreur : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'État de l''erreur : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================';
    END CATCH
END;
GO

-- Exécution de la procédure
EXEC bronze.load_bronze;
