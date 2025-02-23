--Create Dimensions in Gold Layer
----------------------------------------------
-- dimension :  Gold.dim_customers
----------------------------------------------

IF OBJECT_ID('Gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW Gold.dim_customers;
GO
CREATE VIEW Gold.dim_customer AS
	SELECT
		ROW_NUMBER() OVER (ORDER BY cst_id) AS Customer_Key, 
			ci.cst_id AS Customer_Id,
			ci.cst_key AS Customer_Number,
			ci.cst_firstname AS FirstName,
			ci.cst_lastname AS LastName,
			la.cntry AS Country,
			ci.cst_marital_status AS Marital_Status,
			CASE WHEN ci.cst_gndr!='N/A' THEN ci.cst_gndr
				 ELSE COALESCE(ca.gen,'N/A')
			END AS Gender,
			ca.bdate AS Birthday,
			ci.cst_create_date AS Create_date
	FROM Silver.crm_cust_info ci
	LEFT JOIN Silver.erp_CUST_AZ12 ca
	ON ci.cst_key=ca.cid
	LEFT JOIN Silver.erp_LOC_A101 la
	ON ci.cst_key=la.cid
GO

----------------------------------------------
-- dimension :  Gold.dim_products
----------------------------------------------

IF OBJECT_ID('Gold.dim_products', 'V') IS NOT NULL
    DROP VIEW Gold.dim_products;
GO
CREATE VIEW Gold.dim_products AS
SELECT
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt,pn.prd_key) AS Product_Key, 
	pn.prd_id AS Product_Id,
	pn.prd_key AS Product_Number,
	pn.prd_nm AS Product_Name,
	pn.cat_id AS Category_Id,
	pc.cat AS Category,
	pc.subcat AS Sub_category,
	pc.maintenance AS Maintenance,
	pn.prd_cost AS Cost,
	pn.prd_line AS Product_Line,
	pn.prd_start_dt AS StartDate
FROM Silver.crm_prd_info pn
LEFT JOIN Silver.erp_PX_CAT_G1V2 pc
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL
GO

----------------------------------------------
-- dimension :  Gold.fact_sales
----------------------------------------------

IF OBJECT_ID('Gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW Gold.fact_sales;
GO
CREATE VIEW Gold.fact_sales AS
SELECT 
sd.sls_ord_num AS Order_Number,
pr.Product_Key,
cu.Customer_Key,
sd.sls_order_dt AS Order_Date,
sd.sls_ship_dt AS Shipping_Date,
sd.sls_due_dt AS Due_Date,
sd.sls_sales AS Sales_Amount,
sd.sls_quantity AS Quantity,
sd.sls_price AS Price
FROM Silver.crm_sales_details sd
LEFT JOIN Gold.dim_products pr
ON sd.sls_prd_key= pr.Product_Number
LEFT JOIN Gold.dim_customer cu
ON sd.sls_cust_id= cu.Customer_Id
GO
