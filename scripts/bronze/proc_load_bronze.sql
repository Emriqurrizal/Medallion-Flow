-- Create a procedure to load data from CSV files into bronze tables
CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
    BEGIN TRY -- TRY-CATCH block to handle errors during data loading
        PRINT 'Loading data into bronze layer'

        PRINT 'Loading CRM tables:'

        -- Load data into bronze.crm_cust_info and truncate the table before loading new data
        PRINT 'Truncating bronze.crm_cust_info'
        TRUNCATE TABLE bronze.crm_cust_info;
        PRINT 'Loading data into bronze.crm_cust_info'
        BULK INSERT bronze.crm_cust_info
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_crm\cust_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )

        -- Load data into bronze.crm_prd_info and truncate the table before loading new data
        PRINT 'Truncating bronze.crm_prd_info'
        TRUNCATE TABLE bronze.crm_prd_info;
        PRINT 'Loading data into bronze.crm_prd_info'
        BULK INSERT bronze.crm_prd_info
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_crm\prd_info.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )

        -- Load data into bronze.crm_sales_details and truncate the table before loading new data
        PRINT 'Truncating bronze.crm_sales_details'
        TRUNCATE TABLE bronze.crm_sales_details;
        PRINT 'Loading data into bronze.crm_sales_details'
        BULK INSERT bronze.crm_sales_details
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_crm\sales_details.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )

        PRINT 'Loading ERP tables'

        -- Load data into bronze.erp_cust_az12 and truncate the table before loading new data
        PRINT 'Truncating bronze.erp_cust_az12'
        TRUNCATE TABLE bronze.erp_cust_az12;
        PRINT 'Loading data into bronze.erp_cust_az12'
        BULK INSERT bronze.erp_cust_az12
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_erp\cust_az12.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )

        -- Load data into bronze.erp_loc_a101 and truncate the table before loading new data
        PRINT 'Truncating bronze.erp_loc_a101'
        TRUNCATE TABLE bronze.erp_loc_a101;
        PRINT 'Loading data into bronze.erp_loc_a101'
        BULK INSERT bronze.erp_loc_a101
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_erp\loc_a101.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )

        -- Load data into bronze.erp_px_cat_g1v2 and truncate the table before loading new data
        PRINT 'Truncating bronze.erp_px_cat_g1v2'
        TRUNCATE TABLE bronze.erp_px_cat_g1v2;
        PRINT 'Loading data into bronze.erp_px_cat_g1v2'
        BULK INSERT bronze.erp_px_cat_g1v2
        FROM 'C:\Users\Emriqurrizal\Documents\KULIAH\PROJECTS\erp-crm-medallion-warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            TABLOCK
        )
    END TRY
    BEGIN CATCH
        PRINT 'Error occurred while loading data into bronze layer:'
        PRINT ERROR_MESSAGE()
    END CATCH
END
GO