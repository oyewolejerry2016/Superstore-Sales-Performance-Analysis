-- ============================================================
--   SQL PORTFOLIO PROJECT
--   Superstore Sales Performance Analysis
--   Database : SQL_project
--   Author   : Oyewole Jeremiah Oladayo
--   Date     : 2026
-- ============================================================


-- ===========================================================
-- SECTION 1 — DATABASE & TABLE SETUP
-- ===========================================================

CREATE DATABASE SQL_project;
GO
USE SQL_project;
GO


-- ===========================================================
-- SECTION 3 — DATA CLEANING & VALIDATION
-- ===========================================================

-- ---- 3.1  Checking for duplicate store IDs ----
SELECT * FROM superstore_sales;

SELECT
    store_id,
    COUNT(*) AS occurrences
FROM superstore_sales
GROUP BY store_id
HAVING COUNT(*) > 1;


-- ---- 3.2  Checking for NULL values across all columns ----
SELECT
    SUM(CASE WHEN store_id             IS NULL THEN 1 ELSE 0 END) AS null_store_id,
    SUM(CASE WHEN store_area           IS NULL THEN 1 ELSE 0 END) AS null_store_area,
    SUM(CASE WHEN items_available      IS NULL THEN 1 ELSE 0 END) AS null_items,
    SUM(CASE WHEN daily_customer_count IS NULL THEN 1 ELSE 0 END) AS null_customers,
    SUM(CASE WHEN store_sales          IS NULL THEN 1 ELSE 0 END) AS null_sales,
    SUM(CASE WHEN performance          IS NULL THEN 1 ELSE 0 END) AS null_performance
FROM superstore_sales;


-- ---- 3.3  Validate the 'performance' column (only 3 allowed values) ----
SELECT
    performance,
    COUNT(*) AS store_count
FROM superstore_sales
WHERE performance NOT IN ('High', 'Medium', 'Low')
GROUP BY performance;


-- ---- 3.4  Detecting impossible / outlier values ----
SELECT *
FROM superstore_sales
WHERE store_area           <= 0
   OR items_available      <= 0
   OR daily_customer_count <  0
   OR store_sales          <  0;


-- ---- 3.5  Identifying stores with unusually low customer counts ----
SELECT
    store_id,
    daily_customer_count,
    store_sales,
    performance
FROM superstore_sales
WHERE daily_customer_count < 50
ORDER BY daily_customer_count;


-- ---- 3.6  Standardising performance labels (trim whitespace, fix case) ----
UPDATE superstore_sales
SET performance = TRIM(
    CONCAT(
        UPPER(SUBSTRING(LOWER(performance), 1, 1)),
        SUBSTRING(LOWER(performance), 2, LEN(performance))
    )
);


-- ---- 3.7  Verifying row count after cleaning ----
SELECT COUNT(*) AS total_stores FROM superstore_sales;


-- ===========================================================
-- SECTION 4 — EXPLORATORY DATA ANALYSIS (EDA)
-- ===========================================================

-- ---- 4.1  Overall dataset snapshot ----
SELECT
    COUNT(*)                              AS total_stores,
    MIN(store_sales)                      AS min_sales,
    MAX(store_sales)                      AS max_sales,
    ROUND(AVG(store_sales),          2)   AS avg_sales,
    ROUND(STDEV(store_sales),        2)   AS std_dev_sales,   -- was STDDEV()
    MIN(store_area)                       AS min_area,
    MAX(store_area)                       AS max_area,
    ROUND(AVG(store_area),           2)   AS avg_area,
    MIN(daily_customer_count)             AS min_customers,
    MAX(daily_customer_count)             AS max_customers,
    ROUND(AVG(daily_customer_count), 2)   AS avg_customers
FROM superstore_sales;


-- ---- 4.2  Distribution of stores by performance tier ----
SELECT
    performance,
    COUNT(*)                                            AS store_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM superstore_sales
GROUP BY performance
ORDER BY CASE performance                               -- was FIELD()
             WHEN 'High'   THEN 1
             WHEN 'Medium' THEN 2
             WHEN 'Low'    THEN 3
             ELSE 4
         END;


-- ---- 4.3  Average KPIs per performance tier ----
SELECT
    performance,
    COUNT(*)                              AS stores,
    ROUND(AVG(store_area),           0)   AS avg_area_sqft,
    ROUND(AVG(items_available),      0)   AS avg_items,
    ROUND(AVG(daily_customer_count), 0)   AS avg_daily_customers,
    ROUND(AVG(store_sales),          2)   AS avg_sales,
    ROUND(SUM(store_sales),          2)   AS total_sales
FROM superstore_sales
GROUP BY performance
ORDER BY AVG(store_sales) DESC;                         


-- ---- 4.4  Sales distribution buckets ----
WITH bucketed AS (
    SELECT
        CASE
            WHEN store_sales < 30000                  THEN 'Under 30K'
            WHEN store_sales BETWEEN 30000 AND 49999  THEN '30K - 50K'
            WHEN store_sales BETWEEN 50000 AND 69999  THEN '50K - 70K'
            WHEN store_sales BETWEEN 70000 AND 89999  THEN '70K - 90K'
            WHEN store_sales BETWEEN 90000 AND 109999 THEN '90K - 110K'
            ELSE '110K+'
        END AS sales_bucket,
        store_sales
    FROM superstore_sales
)
SELECT
    sales_bucket,
    COUNT(*)         AS store_count,
    MIN(store_sales) AS min_in_bucket,
    MAX(store_sales) AS max_in_bucket
FROM bucketed
GROUP BY sales_bucket
ORDER BY MIN(store_sales);


-- ===========================================================
-- SECTION 5 — BUSINESS ANALYSIS
-- ===========================================================

-- ---- 5.1  Sales efficiency: revenue per square foot ----
SELECT TOP 15                                        
    store_id,
    store_area,
    store_sales,
    ROUND(store_sales * 1.0 / store_area, 2) AS sales_per_sqft,
    performance
FROM superstore_sales
ORDER BY sales_per_sqft DESC;


-- ---- 5.2  Customer conversion value: sales per daily customer ----
SELECT TOP 15                                        
    store_id,
    daily_customer_count,
    store_sales,
    ROUND(store_sales * 1.0 / NULLIF(daily_customer_count, 0), 2) AS sales_per_customer,
    performance
FROM superstore_sales
ORDER BY sales_per_customer DESC;


-- ---- 5.3  Items utilization: sales per available item ----
SELECT TOP 15                                        
    store_id,
    items_available,
    store_sales,
    ROUND(store_sales * 1.0 / items_available, 2) AS sales_per_item,
    performance
FROM superstore_sales
ORDER BY sales_per_item DESC;


-- ---- 5.4  Top 10 and Bottom 10 stores by total sales ----
-- Top 10
SELECT TOP 10                                        
    store_id,
    store_sales,
    performance,
    'Top 10' AS ranking_group
FROM superstore_sales
ORDER BY store_sales DESC;

-- Bottom 10
SELECT TOP 10                                           
    store_id,
    store_sales,
    performance,
    'Bottom 10' AS ranking_group
FROM superstore_sales
ORDER BY store_sales ASC;


-- ---- 5.5  High-performing stores that are small (under-resourced champions) ----
SELECT
    store_id,
    store_area,
    store_sales,
    daily_customer_count,
    ROUND(store_sales * 1.0 / store_area, 2) AS sales_per_sqft
FROM superstore_sales
WHERE performance = 'High'
  AND store_area < (SELECT AVG(store_area) FROM superstore_sales)
ORDER BY sales_per_sqft DESC;


-- ---- 5.6  Low-performing stores with large area (potential turnaround targets) ----
SELECT
    store_id,
    store_area,
    store_sales,
    daily_customer_count,
    ROUND(store_sales * 1.0 / store_area, 2) AS sales_per_sqft
FROM superstore_sales
WHERE performance = 'Low'
  AND store_area > (SELECT AVG(store_area) FROM superstore_sales)
ORDER BY store_area DESC;


-- ---- 5.7  Correlation proxy — avg sales by customer-count band ----
SELECT
    CASE
        WHEN daily_customer_count < 300  THEN 'Very Low (<300)'
        WHEN daily_customer_count < 600  THEN 'Low (300-599)'
        WHEN daily_customer_count < 900  THEN 'Medium (600-899)'
        WHEN daily_customer_count < 1200 THEN 'High (900-1199)'
        ELSE 'Very High (1200+)'
    END                        AS customer_band,
    COUNT(*)                   AS stores,
    ROUND(AVG(store_sales), 2) AS avg_sales,
    ROUND(MIN(store_sales), 2) AS min_sales,
    ROUND(MAX(store_sales), 2) AS max_sales
FROM superstore_sales
GROUP BY
    CASE
        WHEN daily_customer_count < 300  THEN 'Very Low (<300)'
        WHEN daily_customer_count < 600  THEN 'Low (300-599)'
        WHEN daily_customer_count < 900  THEN 'Medium (600-899)'
        WHEN daily_customer_count < 1200 THEN 'High (900-1199)'
        ELSE 'Very High (1200+)'
    END                                                       
ORDER BY MIN(daily_customer_count);


-- ===========================================================
-- SECTION 6 — ADVANCED SQL
-- ===========================================================

-- ---- 6.1  Window function: rank stores within each performance tier ----
SELECT
    store_id,
    performance,
    store_sales,
    RANK()       OVER (PARTITION BY performance ORDER BY store_sales DESC) AS rank_in_tier,
    DENSE_RANK() OVER (PARTITION BY performance ORDER BY store_sales DESC) AS dense_rank_in_tier,
    ROUND(
        store_sales * 100.0 / SUM(store_sales) OVER (PARTITION BY performance),
        2
    )                                                                       AS pct_of_tier_sales
FROM superstore_sales
ORDER BY performance, rank_in_tier;


-- ---- 6.2  Window function: running total of sales (sorted by store_id) ----
SELECT
    store_id,
    store_sales,
    performance,
    SUM(store_sales) OVER (ORDER BY store_id)                             AS running_total_sales,
    ROUND(AVG(store_sales) OVER (ORDER BY store_id
          ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2)                   AS moving_avg_3
FROM superstore_sales
ORDER BY store_id;


-- ---- 6.3  Window function: percentile rank and z-score ----
SELECT
    store_id,
    store_sales,
    performance,
    ROUND(PERCENT_RANK() OVER (ORDER BY store_sales) * 100, 2)           AS percentile,
    ROUND(
        (store_sales - AVG(store_sales) OVER()) /
        NULLIF(STDEV(store_sales) OVER(), 0),                             -- was STDDEV()
    3)                                                                     AS z_score
FROM superstore_sales
ORDER BY z_score DESC;


-- ---- 6.4  CTE: tier summary then compare each store to its tier average ----
WITH tier_stats AS (
    SELECT
        performance,
        ROUND(AVG(store_sales), 2) AS tier_avg_sales,
        ROUND(AVG(store_area),  2) AS tier_avg_area
    FROM superstore_sales
    GROUP BY performance
)
SELECT
    s.store_id,
    s.performance,
    s.store_sales,
    t.tier_avg_sales,
    ROUND(s.store_sales - t.tier_avg_sales, 2) AS diff_from_tier_avg,
    CASE
        WHEN s.store_sales >= t.tier_avg_sales THEN 'Above Average'
        ELSE 'Below Average'
    END                                         AS vs_tier
FROM superstore_sales s
JOIN tier_stats t ON s.performance = t.performance
ORDER BY s.performance, diff_from_tier_avg DESC;


-- ---- 6.5  Subquery: stores that outperform the global average on all three KPIs ----
SELECT
    store_id,
    store_area,
    items_available,
    daily_customer_count,
    store_sales,
    performance
FROM superstore_sales
WHERE store_sales          > (SELECT AVG(store_sales)          FROM superstore_sales)
  AND store_area           > (SELECT AVG(store_area)           FROM superstore_sales)
  AND daily_customer_count > (SELECT AVG(daily_customer_count) FROM superstore_sales)
ORDER BY store_sales DESC;


-- ---- 6.6  CTE chain: classify stores, then summarise classification ----
WITH base AS (
    SELECT
        store_id,
        store_sales,
        performance,
        ROUND(store_sales * 1.0 / store_area,                        2) AS sales_per_sqft,
        ROUND(store_sales * 1.0 / NULLIF(daily_customer_count, 0),   2) AS sales_per_customer
    FROM superstore_sales
),
classified AS (
    SELECT
        *,
        CASE
            WHEN sales_per_sqft >= 70 AND sales_per_customer >= 100 THEN 'Elite'
            WHEN sales_per_sqft >= 50 OR  sales_per_customer >= 80  THEN 'Strong'
            WHEN sales_per_sqft >= 35 OR  sales_per_customer >= 60  THEN 'Average'
            ELSE 'Needs Improvement'
        END AS store_class
    FROM base
)
SELECT
    store_class,
    COUNT(*)                          AS stores,
    ROUND(AVG(store_sales),        2) AS avg_sales,
    ROUND(AVG(sales_per_sqft),     2) AS avg_sales_per_sqft,
    ROUND(AVG(sales_per_customer), 2) AS avg_sales_per_customer
FROM classified
GROUP BY store_class
ORDER BY avg_sales DESC;


-- ===========================================================
-- SECTION 7 — VIEWS & STORED PROCEDURES
-- ===========================================================

-- ---- 7.1  View: enriched store profile ----

CREATE OR ALTER VIEW vw_store_profile AS                
SELECT
    store_id,
    store_area,
    items_available,
    daily_customer_count,
    store_sales,
    performance,
    ROUND(store_sales * 1.0 / store_area,                      2) AS sales_per_sqft,
    ROUND(store_sales * 1.0 / NULLIF(daily_customer_count, 0), 2) AS sales_per_customer,
    ROUND(store_sales * 1.0 / items_available,                 2) AS sales_per_item,
    DENSE_RANK() OVER (ORDER BY store_sales DESC)                  AS global_sales_rank
FROM superstore_sales;

-- Using the view
SELECT TOP 10 * FROM vw_store_profile                  
ORDER BY global_sales_rank;


-- ---- 7.2  View: performance tier summary ----
CREATE OR ALTER VIEW vw_tier_summary AS                 
SELECT
    performance,
    COUNT(*)                              AS total_stores,
    ROUND(AVG(store_sales),          2)   AS avg_sales,
    ROUND(MIN(store_sales),          2)   AS min_sales,
    ROUND(MAX(store_sales),          2)   AS max_sales,
    ROUND(SUM(store_sales),          2)   AS total_sales,
    ROUND(AVG(store_area),           2)   AS avg_area,
    ROUND(AVG(daily_customer_count), 2)   AS avg_daily_customers
FROM superstore_sales
GROUP BY performance;

-- Using the view
SELECT * FROM vw_tier_summary ORDER BY avg_sales DESC;


-- ---- 7.3  Stored Procedure: finding stores by performance tier ----

DROP PROCEDURE IF EXISTS sp_get_stores_by_tier;
GO

CREATE OR ALTER PROCEDURE sp_get_stores_by_tier        
    @p_performance VARCHAR(10)                          
AS
BEGIN
    SELECT
        store_id,
        store_area,
        items_available,
        daily_customer_count,
        store_sales,
        ROUND(store_sales * 1.0 / store_area, 2) AS sales_per_sqft
    FROM superstore_sales
    WHERE performance = @p_performance
    ORDER BY store_sales DESC;
END;
GO

-- Calling the procedure
EXEC sp_get_stores_by_tier 'High';                      
EXEC sp_get_stores_by_tier 'Low';


-- ---- 7.4  Stored Procedure: top N stores by sales ----
DROP PROCEDURE IF EXISTS sp_top_n_stores;
GO

CREATE OR ALTER PROCEDURE sp_top_n_stores
    @p_n INT                                            
AS
BEGIN
    SELECT TOP (@p_n)                                  
        store_id,
        store_sales,
        performance,
        RANK() OVER (ORDER BY store_sales DESC) AS sales_rank
    FROM superstore_sales
    ORDER BY store_sales DESC;
END;
GO

-- Calling the procedure
EXEC sp_top_n_stores 10;                                


-- ===========================================================
-- SECTION 8 — SUMMARY REPORT QUERY
-- ===========================================================

SELECT '=== OVERALL DATASET ==='      AS metric, ''    AS value
UNION ALL
SELECT 'Total Stores',                CAST(COUNT(*)                          AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Total Revenue',               CAST(ROUND(SUM(store_sales), 0)        AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Average Store Sales',         CAST(ROUND(AVG(store_sales), 2)        AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Highest Single Store Sales',  CAST(MAX(store_sales)                  AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Lowest Single Store Sales',   CAST(MIN(store_sales)                  AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Avg Daily Customers',         CAST(ROUND(AVG(daily_customer_count),1) AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT 'Avg Store Area (sqft)',        CAST(ROUND(AVG(store_area), 1)         AS VARCHAR) FROM superstore_sales
UNION ALL
SELECT '--- HIGH tier stores ---',    ''
UNION ALL
SELECT 'Count',    CAST(COUNT(*)                   AS VARCHAR) FROM superstore_sales WHERE performance = 'High'
UNION ALL
SELECT 'Avg Sales',CAST(ROUND(AVG(store_sales), 2) AS VARCHAR) FROM superstore_sales WHERE performance = 'High'
UNION ALL
SELECT '--- MEDIUM tier stores ---',  ''
UNION ALL
SELECT 'Count',    CAST(COUNT(*)                   AS VARCHAR) FROM superstore_sales WHERE performance = 'Medium'
UNION ALL
SELECT 'Avg Sales',CAST(ROUND(AVG(store_sales), 2) AS VARCHAR) FROM superstore_sales WHERE performance = 'Medium'
UNION ALL
SELECT '--- LOW tier stores ---',     ''
UNION ALL
SELECT 'Count',    CAST(COUNT(*)                   AS VARCHAR) FROM superstore_sales WHERE performance = 'Low'
UNION ALL
SELECT 'Avg Sales',CAST(ROUND(AVG(store_sales), 2) AS VARCHAR) FROM superstore_sales WHERE performance = 'Low';


-- ============================================================
-- END OF PROJECT
-- ============================================================