/*
===============================================================================
Quality Checks
===============================================================================
Script Purpose:
    This script performs quality checks to validate the integrity, consistency, 
    and accuracy of the Gold Layer. These checks ensure:
    - Uniqueness of surrogate keys in dimension tables.
    - Referential integrity between fact and dimension tables.
    - Validation of relationships in the data model for analytical purposes.

Usage Notes:
    - Investigate and resolve any discrepancies found during the checks.
===============================================================================
*/

-- ====================================================================
-- Checking 'gold.dim_customers'
-- ====================================================================
-- Check for Uniqueness of Customer Key in gold.dim_customers
-- Expectation: No results 
SELECT 
    customer_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_customers
GROUP BY customer_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.product_key'
-- ====================================================================
-- Check for Uniqueness of Product Key in gold.dim_products
-- Expectation: No results 
SELECT 
    product_key,
    COUNT(*) AS duplicate_count
FROM gold.dim_products
GROUP BY product_key
HAVING COUNT(*) > 1;

-- ====================================================================
-- Checking 'gold.fact_sales'
-- ====================================================================
-- Check the data model connectivity between fact and dimensions
SELECT * 
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c
ON c.customer_key = f.customer_key
LEFT JOIN gold.dim_products p
ON p.product_key = f.product_key
WHERE p.product_key IS NULL OR c.customer_key IS NULL  

USE DataWarehouse;
GO

-- 1. Compare Silver sales rows with Gold fact rows
SELECT
    (SELECT COUNT_BIG(*)
     FROM silver.crm_sales_details) AS SilverSalesRows,

    (SELECT COUNT_BIG(*)
     FROM gold.fact_sales) AS GoldFactRows;

-- 2. Compare total sales amounts
SELECT
    (SELECT SUM(sls_sales)
     FROM silver.crm_sales_details) AS SilverTotalSales,

    (SELECT SUM(sales_amount)
     FROM gold.fact_sales) AS GoldTotalSales;

-- 3. Check for missing dimension keys
SELECT
    SUM(CASE WHEN customer_key IS NULL THEN 1 ELSE 0 END)
        AS MissingCustomerKeys,
    SUM(CASE WHEN product_key IS NULL THEN 1 ELSE 0 END)
        AS MissingProductKeys
FROM gold.fact_sales;

-- 4. Inspect sample customer records
SELECT TOP 10 *
FROM gold.dim_customers;

-- 5. Inspect sample product records
SELECT TOP 10 *
FROM gold.dim_products;

-- 6. Inspect sample sales records
SELECT TOP 10 *
FROM gold.fact_sales;
GO

-- 7. Monthly sales trend
USE DataWarehouse;
GO

SELECT
    YEAR(order_date) AS SalesYear,
    MONTH(order_date) AS SalesMonth,
    DATETRUNC(MONTH, order_date) AS MonthStart,
    SUM(sales_amount) AS TotalSales,
    SUM(quantity) AS TotalQuantity,
    COUNT(DISTINCT order_number) AS TotalOrders
FROM gold.fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(MONTH, order_date),
         YEAR(order_date),
         MONTH(order_date)
ORDER BY MonthStart;
GO

-- 8. Top 10 products by revenue
SELECT TOP 10
    p.product_number,
    p.product_name,
    p.category,
    SUM(f.sales_amount) AS TotalRevenue,
    SUM(f.quantity) AS UnitsSold
FROM gold.fact_sales f
JOIN gold.dim_products p
    ON f.product_key = p.product_key
GROUP BY
    p.product_number,
    p.product_name,
    p.category
ORDER BY TotalRevenue DESC;
GO