-- Stored Procedure to Load data from Source to Bronze
-- it does not take any parameter
-- for execution : EXEC Bronze.load_Bronze;

EXEC Bronze.load_Bronze

CREATE OR ALTER PROCEDURE Bronze.load_Bronze AS
BEGIN  
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY
		SET @batch_start_time = GETDATE();
		PRINT '==========================================';
		PRINT 'LOADING BRONZE LAYER';
		PRINT '==========================================';

		PRINT '------------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_cust_info';
		TRUNCATE TABLE Bronze.crm_cust_info;
		PRINT '>> Inserting Table: Bronze.crm_cust_info';
		BULK INSERT Bronze.crm_cust_info
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';
	

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_prd_info';
		TRUNCATE TABLE Bronze.crm_prd_info;
		PRINT '>> Inserting Table: Bronze.crm_prd_info';
		BULK INSERT Bronze.crm_prd_info
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.crm_sales_details';
		TRUNCATE TABLE Bronze.crm_sales_details;
		PRINT '>> Inserting Table: Bronze.crm_sales_details';
		BULK INSERT Bronze.crm_sales_details
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';


		
		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_CUST_AZ12';
		TRUNCATE TABLE Bronze.erp_CUST_AZ12;
		PRINT '>> Inserting Table: Bronze.erp_CUST_AZ12';
		BULK INSERT Bronze.erp_CUST_AZ12
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';



		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_LOC_A101';
		TRUNCATE TABLE Bronze.erp_LOC_A101;
		PRINT '>> Inserting Table: Bronze.erp_LOC_A101';
		BULK INSERT Bronze.erp_LOC_A101
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';




		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: Bronze.erp_PX_CAT_G1V2';
		TRUNCATE TABLE Bronze.erp_PX_CAT_G1V2;
		PRINT '>> Inserting Table: Bronze.erp_PX_CAT_G1V2';
		BULK INSERT Bronze.erp_PX_CAT_G1V2
		FROM 'C:\Users\mridu\OneDrive\Desktop\Data Warehouse\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR) + 'seconds';

		SET @batch_end_time = GETDATE();
		PRINT '==========================================';
		PRINT 'LOADING BRONZE LAYER COMPLETED';
		PRINT 'Total Load Duration:'+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '==========================================';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER ';
		PRINT 'Error Message '+ ERROR_MESSAGE();
		PRINT 'Error Message '+ CAST(ERROR_NUMBER() AS NVARCHAR);
	END CATCH
END
