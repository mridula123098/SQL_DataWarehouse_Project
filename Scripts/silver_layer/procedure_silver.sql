/* Strored Procedure: Load Silver Layer (Bronze ---> Silver) 
Performs ETL (Extract, Transform, Load) into Silver Schema Tables
Does not take any parameters
for execution: EXEC Silver.load_silver         */


CREATE OR ALTER PROCEDURE Silver.load_silver AS
BEGIN

	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
	BEGIN TRY

		SET @batch_start_time = GETDATE();
		PRINT '==========================================';
		PRINT 'LOADING SILVER LAYER';
		PRINT '==========================================';

		PRINT '------------------------------------------';
		PRINT 'LOADING CRM TABLES';
		PRINT '------------------------------------------';
	
		--inserted standardized/cleanded data into silver cm cust
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.crm_cust_info';
		TRUNCATE TABLE Silver.crm_cust_info;
		PRINT '>> INSERTING DATA INTO: Silver.crm_cust_info';
		INSERT INTO Silver.crm_cust_info(
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
			TRIM(cst_firstname) AS cst_firstname,
			TRIM(cst_lastname) AS cst_lastname,
			CASE 
				WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
				WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
				ELSE 'N/A'
			END cst_marital_status,  
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'N/A'
			END cst_gndr,  
			cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
			FROM Bronze.crm_cust_info
			WHERE cst_id IS NOT NULL
		) t 
		WHERE flag_last = 1;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
		PRINT '>> ---------------------------------------------------------';

		--inserted standardized/cleanded data into silver crm prd
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.crm_prd_info';
		TRUNCATE TABLE Silver.crm_prd_info;
		PRINT '>> INSERTING DATA INTO: Silver.crm_prd_info';
		INSERT INTO Silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)
		SELECT
		prd_id,
		REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,
		SUBSTRING(prd_key,7,len(prd_key)) AS prd_key,
		prd_nm,
		ISNULL(prd_cost,0) AS prd_cost,
		CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
			 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
			 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
			 WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
			 ELSE 'N/A'
		END AS prd_line,
		prd_start_dt,
		DATEADD(DAY, -1, LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
		FROM Bronze.crm_prd_info;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
		PRINT '>> ---------------------------------------------------------';

		--inserted standardized/cleanded data into silver crm sales details
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.crm_sales_details';
		TRUNCATE TABLE Silver.crm_sales_details;
		PRINT '>> INSERTING DATA INTO: Silver.crm_sales_details';
		INSERT INTO Silver.crm_sales_details(
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
		CASE WHEN sls_order_dt=0 or len(sls_order_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
		END AS sls_order_dt,
		CASE WHEN sls_ship_dt=0 or len(sls_ship_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
		END AS sls_ship_dt,
		CASE WHEN sls_due_dt=0 or len(sls_due_dt)!=8 THEN NULL
			 ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
		END AS sls_due_dt,
		case when sls_sales is null or sls_sales<=0 or sls_sales!=sls_quantity*abs(sls_price)
				then sls_quantity*abs(sls_price)
			 else sls_sales
		end as sls_sales,
		sls_quantity,
		case when sls_price is null or sls_price<=0
				then sls_sales/nullif(sls_quantity,0)
			 else sls_price
		end as sls_price
		FROM Bronze.crm_sales_details;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+'seconds';
		PRINT '>> ---------------------------------------------------------';

		--insert standardized data in silver erp cust 
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.erp_CUST_AZ12';
		TRUNCATE TABLE Silver.erp_CUST_AZ12;
		PRINT '>> INSERTING DATA INTO: Silver.erp_CUST_AZ12';
		INSERT INTO Silver.erp_CUST_AZ12(
			cid,
			bdate,gen
		)
		SELECT
		CASE WHEN cid like 'NAS%' THEN  SUBSTRING(cid,4,len(cid))
			 ELSE cid
		END AS cid,
		CASE WHEN bdate > GETDATE() THEN NULL
			 ELSE bdate
		END AS bdate,
		CASE WHEN UPPER(TRIM(gen))IN ('F','FEMALE') THEN 'Female'
			 WHEN UPPER(TRIM(gen))IN ('M','MALE') THEN 'Male'
			 ELSE 'N/A'
		END AS gen
		FROM Bronze.erp_CUST_AZ12;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
		PRINT '>> ---------------------------------------------------------';


		PRINT '------------------------------------------';
		PRINT 'LOADING ERP TABLES';
		PRINT '------------------------------------------';
		--insert standardized data in silver erp loc
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.erp_LOC_A101';
		TRUNCATE TABLE Silver.erp_LOC_A101;
		PRINT '>> INSERTING DATA INTO: Silver.erp_LOC_A101';
		INSERT INTO Silver.erp_LOC_A101(
			cid,
			cntry
		)
		SELECT 
		REPLACE(cid,'-','')cid,
		CASE WHEN TRIM(cntry)='DE' THEN 'Germany'
			 WHEN TRIM(cntry) in ('US','USA') THEN 'United States'
			 WHEN TRIM(cntry)='' or cntry is null THEN 'N/A'
		ELSE TRIM(cntry)
		END AS cntry
		FROM Bronze.erp_LOC_A101;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
		PRINT '>> ---------------------------------------------------------';

		--insert standardized data in silver erp px cat 
		SET @start_time = GETDATE();
		PRINT'>> TRUNCATING TABLE: Silver.erp_PX_CAT_G1V2';
		TRUNCATE TABLE Silver.erp_PX_CAT_G1V2;
		PRINT '>> INSERTING DATA INTO: Silver.erp_PX_CAT_G1V2';
		INSERT INTO Silver.erp_PX_CAT_G1V2(
			id,
			cat,
			subcat,
			maintenance
		)
		SELECT	
			id,
			cat,
			subcat,
			maintenance
		FROM Bronze.erp_PX_CAT_G1V2;
		SET @end_time = GETDATE();
		PRINT '>> Load Duration:'+ CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+ 'seconds';
		PRINT '>> ---------------------------------------------------------';

		SET @batch_end_time = GETDATE();
		PRINT '==========================================';
		PRINT 'LOADING SILVER LAYER COMPLETED';
		PRINT 'Total Load Duration:'+ CAST(DATEDIFF(SECOND,@batch_start_time,@batch_end_time) AS NVARCHAR) + 'seconds';
		PRINT '==========================================';
	END TRY
	BEGIN CATCH
		PRINT '==========================================';
		PRINT 'ERROR OCCURED DURING LOADING SILVER LAYER ';
		PRINT 'Error Message '+ ERROR_MESSAGE();
		PRINT 'Error Message '+ CAST(ERROR_NUMBER() AS NVARCHAR);
	END CATCH
END

EXEC Silver.load_silver
