---------------------------------------------
-- Checking for uniqueness of Customer_Key in Gold.dim_customers
---------------------------------------------
SELECT 
    Customer_Key,
    COUNT(*) AS Duplicate_Count
FROM Gold.dim_customers
GROUP BY Customer_Key
HAVING COUNT(*) > 1;

---------------------------------------------
-- Checking for uniqueness of Product_Key in Gold.dim_products
---------------------------------------------
SELECT 
    Product_Key,
    COUNT(*) AS Duplicate_Count
FROM Gold.dim_products
GROUP BY Product_Key
HAVING COUNT(*) > 1;

---------------------------------------------
-- Checking for data model connectivity in fact and dimensions
---------------------------------------------
SELECT * 
FROM Gold.fact_sales f
LEFT JOIN Gold.dim_customers c
ON c.Customer_key = f.Customer_key
LEFT JOIN Gold.dim_products p
ON p.Product_key = f.Product_key
WHERE p.Product_key IS NULL OR c.Customer_key IS NULL  
