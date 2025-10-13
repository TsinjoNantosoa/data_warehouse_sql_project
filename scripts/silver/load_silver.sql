/*
===============================================================================
Procédure stockée : silver.load_silver
===============================================================================
Objectif :
    Cette procédure stockée exécute le processus ETL (Extraction, Transformation, 
    et Chargement) pour remplir les tables de la couche 'silver' à partir de la 
    couche 'bronze' dans une architecture Data Lake.

    Elle assure le nettoyage des données, la normalisation et la cohérence entre 
    les systèmes sources CRM et ERP avant leur utilisation dans la couche analytique 
    'gold'.

Actions effectuées :
    1. Supprime les données existantes dans toutes les tables Silver.
    2. Charge et transforme les données à partir des tables Bronze correspondantes.
    3. Applique des règles de qualité des données telles que :
        - Standardisation des valeurs de genre et de statut marital.
        - Validation et formatage des champs date.
        - Recalcul ou correction des valeurs de ventes ou de prix invalides.
        - Remplacement des valeurs catégorielles manquantes ou incohérentes.
    4. Affiche la durée de chargement pour chaque table et la durée totale du processus.

Gestion des erreurs :
    Comprend un bloc TRY...CATCH pour capturer et afficher toute erreur SQL 
    survenue lors de l'exécution.

Paramètres :
    Aucun — cette procédure ne nécessite pas de paramètres d'entrée
    et ne retourne aucun jeu de résultats.

Exemple d'utilisation :
    EXEC silver.load_silver;

Auteur :
    [Votre Nom ou Nom de l'Équipe]

Créé le :
    [Insérer la Date]

Dernière modification :
    [Insérer la Date de la dernière mise à jour]

===============================================================================
*/

CREATE OR ALTER PROCEDURE silver.load_silver
AS
BEGIN
    DECLARE 
        @start_time DATETIME, 
        @end_time DATETIME, 
        @batch_start_time DATETIME, 
        @batch_end_time DATETIME;

    SET @batch_start_time = GETDATE();

    BEGIN TRY
        PRINT '================================';
        PRINT 'Chargement de la couche Silver';
        PRINT '================================';

        -- ---------------------------------------------
        PRINT '--------------------------------';
        PRINT 'Chargement des tables CRM';
        PRINT '--------------------------------';

        SET @start_time = GETDATE();
        PRINT 'Vidage de la table : silver.crm_cust_info';
        TRUNCATE TABLE silver.crm_cust_info;

        PRINT 'Insertion des données dans : silver.crm_cust_info';
        INSERT INTO silver.crm_cust_info(
            cst_id,
            cst_key,
            cst_firstname,
            cst_lastname,
            cst_marital_status,
            cst_gndr,
            cst_create_date
        )
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname),
            TRIM(cst_lastname),
            CASE 
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
                WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                ELSE 'N/A'
            END,
            CASE 
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
                WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                ELSE 'N/A'
            END,
            cst_create_date
        FROM (
            SELECT * ,
                   ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
            FROM bronze.crm_cust_info
        ) t
        WHERE flag_last = 1;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        -- ---------------------------------------------
        PRINT 'Vidage de la table : silver.crm_prd_info';
        TRUNCATE TABLE silver.crm_prd_info;

        PRINT 'Insertion des données dans : silver.crm_prd_info';
        SET @start_time = GETDATE();
        INSERT INTO silver.crm_prd_info(
            prd_id,
            prd_key,
            cat_id,
            prd_nm,
            prd_cost,
            prd_line,
            prd_start_dt,
            prd_end_dt
        )
        SELECT 
            prd_id,
            prd_key,
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            prd_nm,
            ISNULL(prd_cost, 0),
            CASE 
                WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
                WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
                WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
                WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
                ELSE 'N/A'
            END,
            CAST(prd_start_dt AS DATE),
            CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE)
        FROM bronze.crm_prd_info;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        -- ---------------------------------------------
        PRINT 'Vidage de la table : silver.crm_sales_details';
        TRUNCATE TABLE silver.crm_sales_details;

        PRINT 'Insertion des données dans : silver.crm_sales_details';
        SET @start_time = GETDATE();
        INSERT INTO silver.crm_sales_details(
            sls_ord_num,
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
            sls_ord_num,
            sls_prd_key,
            sls_cust_id,
            CASE WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END,
            CASE WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END,
            CASE WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END,
            CASE WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> sls_quantity * ABS(sls_price)
                 THEN sls_quantity * ABS(sls_price)
                 ELSE sls_sales
            END,
            sls_quantity,
            CASE WHEN sls_price IS NULL OR sls_price <= 0
                 THEN sls_sales / NULLIF(sls_quantity, 0)
                 ELSE sls_price
            END
        FROM bronze.crm_sales_details;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        -- ---------------------------------------------
        PRINT 'Chargement des tables ERP';
        PRINT '--------------------------';

        SET @start_time = GETDATE();
        PRINT 'Vidage de la table : silver.erp_cust_az12';
        TRUNCATE TABLE silver.erp_cust_az12;

        PRINT 'Insertion des données dans : silver.erp_cust_az12';
        INSERT INTO silver.erp_cust_az12(
            cid,
            bdate,
            gen
        )
        SELECT 
            CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid))
                 ELSE cid
            END,
            CASE WHEN bdate > GETDATE() THEN NULL ELSE bdate END,
            CASE 
                WHEN UPPER(REPLACE(REPLACE(TRIM(gen), CHAR(10), ''), CHAR(13), '')) IN ('F','FEMALE') THEN 'Female'
                WHEN UPPER(REPLACE(REPLACE(TRIM(gen), CHAR(10), ''), CHAR(13), '')) IN ('M','MALE') THEN 'Male'
                ELSE 'N/A'
            END
        FROM bronze.erp_cust_az12;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        -- ---------------------------------------------
        PRINT 'Insertion des données dans : silver.erp_loc_a101';
        SET @start_time = GETDATE();
        INSERT INTO silver.erp_loc_a101(
            cid,
            cntry
        )
        SELECT 
            REPLACE(cid, '-', ''),
            CASE 
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), '')) = 'DE' THEN 'Germany'
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), '')) IN ('US','USA') THEN 'United States'
                WHEN TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), '')) = '' OR cntry IS NULL THEN 'N/A'
                ELSE TRIM(REPLACE(REPLACE(cntry, CHAR(10), ''), CHAR(13), ''))
            END
        FROM bronze.erp_loc_a101;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        -- ---------------------------------------------
        PRINT 'Vidage de la table : silver.erp_px_cat_g1v2';
        TRUNCATE TABLE silver.erp_px_cat_g1v2;

        PRINT 'Insertion des données dans : silver.erp_px_cat_g1v2';
        SET @start_time = GETDATE();
        INSERT INTO silver.erp_px_cat_g1v2(
            id,
            cat,
            subcat,
            maintenance
        )
        SELECT 
            id,
            cat,
            subcat,
            CASE 
                WHEN UPPER(REPLACE(REPLACE(TRIM(maintenance), CHAR(10), ''), CHAR(13), '')) = 'YES' THEN 'Yes'
                WHEN UPPER(REPLACE(REPLACE(TRIM(maintenance), CHAR(10), ''), CHAR(13), '')) = 'NO' THEN 'No'
                ELSE 'N/A'
            END
        FROM bronze.erp_px_cat_g1v2;

        SET @end_time = GETDATE();
        PRINT 'Durée de chargement : ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' secondes';
        PRINT '--------------------------'

        SET @batch_end_time = GETDATE();
        PRINT '======================';
        PRINT 'Chargement de la couche Silver terminé';
        PRINT 'Durée totale de chargement : ' + CAST(DATEDIFF(second, @batch_start_time, @batch_end_time) AS NVARCHAR) + ' secondes';

    END TRY
    BEGIN CATCH
        PRINT '================================';
        PRINT 'ERREUR SURVENUE PENDANT LE CHARGEMENT DE LA COUCHE SILVER';
        PRINT 'Message d''erreur : ' + ERROR_MESSAGE();
        PRINT 'Numéro d''erreur : ' + CAST(ERROR_NUMBER() AS NVARCHAR);
        PRINT 'État de l''erreur : ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '================================';
    END CATCH
END;
GO

-- Exécution
EXEC silver.load_silver;
