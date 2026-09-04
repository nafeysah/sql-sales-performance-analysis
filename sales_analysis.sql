-- ============================================
-- SALES PERFORMANCE ANALYSIS
-- ============================================

-- Setup: rename imported table to a clean name
RENAME TABLE `sales_project`.`raw_sales_data - cleaneddata` TO `sales_project`.`sales_data`;


-- ============================================
-- DATA CLEANING
-- ============================================

-- 1. Fix inconsistent OrderDate formats (4 formats found: DD/MM/YYYY, YYYY/MM/DD, YYYY-MM-DD, MM-DD-YYYY, DD-Mon-YYYY)
ALTER TABLE sales_data ADD COLUMN OrderDateClean DATE;

SET SQL_SAFE_UPDATES = 0;

UPDATE sales_data
SET OrderDateClean = 
    CASE
        WHEN OrderDate REGEXP '[A-Za-z]' 
            THEN STR_TO_DATE(OrderDate, '%d-%b-%Y')
        WHEN OrderDate LIKE '%/%' AND LENGTH(SUBSTRING_INDEX(OrderDate, '/', 1)) = 4 
            THEN STR_TO_DATE(OrderDate, '%Y/%m/%d')
        WHEN OrderDate LIKE '%/%' 
            THEN STR_TO_DATE(OrderDate, '%d/%m/%Y')
        WHEN OrderDate LIKE '%-%' AND LENGTH(SUBSTRING_INDEX(OrderDate, '-', 1)) = 4 
            THEN STR_TO_DATE(OrderDate, '%Y-%m-%d')
        WHEN OrderDate LIKE '%-%' 
            THEN STR_TO_DATE(OrderDate, '%m-%d-%Y')
    END;

-- Verify: should return 0
SELECT COUNT(*) FROM sales_data WHERE OrderDateClean IS NULL;


-- 2. Merge inconsistent product name spellings into single labels
UPDATE sales_data SET Products = 'Headset' WHERE Products = 'Head Set';
UPDATE sales_data SET Products = 'Keyboard' WHERE Products = 'Key Board';
UPDATE sales_data SET Products = 'Laptop' WHERE Products = 'Lap Top';
UPDATE sales_data SET Products = 'Phone' WHERE Products = 'Smartphone';
UPDATE sales_data SET Products = 'Webcam' WHERE Products = 'Web Cam';

-- Verify: should show 10 clean unique products
SELECT DISTINCT Products FROM sales_data ORDER BY Products;


-- 3. Convert Revenue from currency-formatted text into usable numeric values
ALTER TABLE sales_data ADD COLUMN RevenueClean DECIMAL(12,2);

UPDATE sales_data
SET RevenueClean = CAST(REGEXP_REPLACE(Revenue, '[^0-9.]', '') AS DECIMAL(12,2));

-- Verify: should return 0
SELECT COUNT(*) FROM sales_data WHERE RevenueClean IS NULL;


-- ============================================
-- ANALYSIS
-- ============================================

-- Query 1: Total revenue by region
SELECT Region, SUM(RevenueClean) AS total_revenue
FROM sales_data
GROUP BY Region
ORDER BY total_revenue DESC;


-- Query 2: Top 5 sales reps by revenue
SELECT SalesRep, SUM(RevenueClean) AS sales_revenue
FROM sales_data
GROUP BY SalesRep
ORDER BY sales_revenue DESC
LIMIT 5;


-- Query 3: Month-over-month revenue trend
SELECT DATE_FORMAT(OrderDateClean, '%Y-%m') AS OrderMonth,
    SUM(RevenueClean) AS monthly_revenue
FROM sales_data
GROUP BY OrderMonth
ORDER BY OrderMonth ASC;


-- Query 4: Order status breakdown, with percentage of total orders
SELECT Status, 
    COUNT(*) AS status_count,
    (SELECT COUNT(*) FROM sales_data) AS total_orders,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM sales_data) * 100, 2) AS percentage
FROM sales_data
GROUP BY Status;


-- Query 5: Average order value by region
SELECT Region, ROUND(AVG(RevenueClean), 2) AS avg_order_value
FROM sales_data
GROUP BY Region;


-- Query 6: Sales reps ranked by revenue within each region (window function)
SELECT Region, SalesRep, SUM(RevenueClean) AS rep_revenue,
    RANK() OVER (PARTITION BY Region ORDER BY SUM(RevenueClean) DESC) AS region_rank
FROM sales_data
GROUP BY Region, SalesRep;


-- Query 7: Regions performing above the company average revenue (CTE)
WITH region_revenue AS (
    SELECT Region, SUM(RevenueClean) AS total_revenue
    FROM sales_data
    GROUP BY Region
)
SELECT Region, total_revenue
FROM region_revenue
WHERE total_revenue > (
    SELECT AVG(total_revenue) FROM region_revenue
);


-- Query 8: Top 5 products by revenue
SELECT Products, SUM(RevenueClean) AS product_revenue
FROM sales_data
GROUP BY Products
ORDER BY product_revenue DESC
LIMIT 5;
