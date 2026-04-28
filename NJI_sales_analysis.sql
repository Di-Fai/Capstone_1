-- Capstone 1 Sales Analysis
-- Student: Nji Dimitri
--  
-- Database: Sample_Sales
-- This script analyzes online sales for New Jersey as part of the Northeast Region.
-- -------------------------------------------------------------------
-- -------------------------------------------------------------------

USE sample_sales;

SHOW TABLES;
-- I used this prompt to confirm the tables in my database

SELECT SalesManager, Region, State
FROM Management
WHERE SalesManager = 'Miami Vue';

-- I used this prompt to Identify My managers Region and State to know what sales territory i am working on

-- EXE #4
-- What is total revenue overall for sales in the assigned territory, 
-- plus the start date and end date that tells you what period the data covers?
-- #4.1. Total overall revenue for New Jersey (Northeast Region), including the date range

-- -----------------
-- Online_Sales
-- ------------------
SELECT
'New Jersey' AS Sales_Territory,
MIN(Date) AS Start_Date,
MAX(Date) AS End_Date,
COUNT(*) AS Number_Of_Transactions,
ROUND(SUM(SalesTotal), 2) AS Total_Revenue
FROM Online_Sales 
-- ROUND(AVG(SalesTotal), 2) AS Average_Transaction_Size
WHERE ShiptoState = 'New Jersey';

-- Sales Statistics for the Northeast Region (New Jersay) Online_Sales from  Febuary - 02 -2022 to December 31 - 2025
-- Number of transactions = 3631
-- Total Revenue          = 2225561.25

-- ---------------------
-- Store_Sales
-- ---------------------
SELECT 
'New Jersey' AS Sales_Territory,
MIN(ss.Transaction_Date) AS start_date,
MAX(ss.Transaction_Date) AS end_date,
COUNT(*) AS Number_Of_Transactions,
ROUND(SUM(ss.Sale_Amount), 2) AS total_revenue
FROM Store_Sales ss
JOIN Store_Locations sl
    ON ss.Store_ID = sl.Store_ID
WHERE sl.State = 'New Jersey';

-- Sales Statistics for the Northeast Region (New Jersay) Store_Sales from January-01-2022 to December-31-2025
-- Number of transactions = 38195
-- Total Revenue          = 5175405.87

-- Using the UNION ALL function was a little challangimg to me so i had chat GPT link my Online_Sale and Store_Sales Queries.


SELECT
    'New Jersey' AS sales_territory,
    MIN(Transaction_Date) AS start_date,
    MAX(Transaction_Date) AS end_date,
    ROUND(SUM(Sale_Amount), 2) AS total_revenue
FROM (
    SELECT
        ss.Transaction_Date,
        ss.Sale_Amount
    FROM store_sales ss
    JOIN store_locations sl
        ON ss.store_id = sl.store_id
    WHERE sl.state = 'New Jersey'

    UNION ALL

    SELECT
        os.Date,
        os.SalesTotal
    FROM online_sales os
    WHERE os.ShiptoState = 'New Jersey'
) AS all_sales;





-- -------------------------------------------------------------

-- What is the month by month revenue breakdown for the sales territory? 
-- #4.2. Month-by-month revenue breakdown for New Jersey

SELECT
    DATE_FORMAT(Date, '%Y-%m') AS Sales_Month,
    ROUND(SUM(SalesTotal), 2) AS Monthly_Revenue,
    COUNT(*) AS Number_Of_Transactions
FROM Online_Sales
WHERE ShiptoState = 'New Jersey'
GROUP BY DATE_FORMAT(Date, '%Y-%m')
ORDER BY Sales_Month ASC;

-- I used the (%y-%m) here to help me group the sales by months intead of individual days 
 -- ------------------------------------------------------------------------------------------------------
 -- #4c
 -- 3. Compare New Jersey revenue to the larger Northeast Region

WITH northeast_states AS (
    SELECT 'New Jersey' AS State_Name
    UNION ALL SELECT 'New York'
    UNION ALL SELECT 'Massachusetts'
    UNION ALL SELECT 'Maine'
    UNION ALL SELECT 'Maryland'
)
SELECT
    CASE
        WHEN ShiptoState = 'New Jersey' THEN 'New Jersey Territory'
        ELSE 'Rest of Northeast Region'
    END AS Area,
    ROUND(SUM(SalesTotal), 2) AS Total_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    ROUND(AVG(SalesTotal), 2) AS Average_Transaction_Size
FROM Online_Sales
WHERE ShiptoState IN (SELECT State_Name FROM northeast_states)
GROUP BY Area;

-- ---------------------------------------------------------------------

-- #4d
-- 4. Transactions per month and average transaction size by product category code

SELECT
    DATE_FORMAT(Date, '%Y-%m') AS Sales_Month,
    SUBSTRING_INDEX(ProdNum, '-', -1) AS Product_Category_Code,
    COUNT(*) AS Number_Of_Transactions,
    ROUND(AVG(SalesTotal), 2) AS Average_Transaction_Size,
    ROUND(SUM(SalesTotal), 2) AS Total_Revenue
FROM Online_Sales
WHERE ShiptoState = 'New Jersey'
GROUP BY
    DATE_FORMAT(Date, '%Y-%m'),
    SUBSTRING_INDEX(ProdNum, '-', -1)
ORDER BY
    Sales_Month,
    Product_Category_Code;
    
    -- ---------------------------------------------------------------------
    
    -- #4e
 -- 5. Ranking online sales performance by state within the Northeast Region

WITH northeast_states AS (
    SELECT 'New Jersey' AS State_Name
    UNION ALL SELECT 'New York'
    UNION ALL SELECT 'Massachusetts'
    UNION ALL SELECT 'Maine'
    UNION ALL SELECT 'Maryland'
)
SELECT
    ShiptoState AS State,
    ROUND(SUM(SalesTotal), 2) AS Total_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    ROUND(AVG(SalesTotal), 2) AS Average_Transaction_Size,
    RANK() OVER (ORDER BY SUM(SalesTotal) DESC) AS Revenue_Rank
FROM Online_Sales
WHERE ShiptoState IN (SELECT State_Name FROM northeast_states)
GROUP BY ShiptoState
ORDER BY Revenue_Rank;


