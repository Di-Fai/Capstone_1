-- Capstone 1 Sales Analysis
-- This script analyzes online sales for New Jersey as part of the Northeast Region.
-- -------------------------------------------------------------------
-- -------------------------------------------------------------------
USE sample_sales;
SHOW TABLES;
-- I used this prompt to confirm the tables in my database
-- ------------------------------------------------------------------
SELECT SalesManager, Region, State
FROM Management
WHERE SalesManager = 'Miami Vue';

-- I used this prompt to Identify My managers Region and State to know what sales territory i am working on
-- -------------------------------------------------------------------------

-- Exercise 4.1
-- Objective:
-- Find TOTAL REVENUE (online_Sales and Store_Sales) for New Jersey in the Northeast Region,
-- The earliest and latest transaction dates, so we know what time period the data covers.

-- Logic :    
-- For Online_Sales I filtered Where  ShiptoState = New Jersey
-- For store sales, I connected store_sales to store_locations using Store_ID, Where State = New Jersey.

SELECT
'New Jersey Total Sales' AS Territory,
SUM(Revenue) AS Total_Revenue,
MIN(Sale_Date) AS Start_Date,
MAX(Sale_Date) AS End_Date
FROM (
SELECT
ss.Transaction_Date AS Sale_Date,
ss.Sale_Amount AS Revenue
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.Store_ID
WHERE sl.State = 'New Jersey'
UNION ALL
SELECT
os.Date AS Sale_Date,
os.SalesTotal AS Revenue
FROM online_sales os
WHERE os.ShiptoState = 'New Jersey'
) AS Total_Revenue;

-- Because the question asked for an overall revenue, 
-- I took Online_sales and Store_sales into considaration
-- I combined both using UNION ALL, then calculated
-- SUM() = total revenue
-- MIN() = earliest sale date
-- MAX() = latest sale date

-- --------------------------------------------------------------------------


-- Exercise 4.2
-- Objective:
-- Find the Month-by-month revenue breakdown for New Jersey
-- (online + in-store combined).
-- Logic : 
-- Extract year and month from each transaction date,
-- group by months, Count the number of transactions for each month
-- and sum revenue per month

SELECT
    YEAR(Sale_Date) AS Sales_Year,
    MONTH(Sale_Date) AS Sales_Month,
    SUM(Revenue) AS Monthly_Revenue,
    COUNT(*) AS Number_Of_Transactions
FROM (
    SELECT
        ss.Transaction_Date AS Sale_Date,
        ss.Sale_Amount AS Revenue
    FROM store_sales ss
    JOIN store_locations sl
        ON ss.Store_ID = sl.Store_ID
    WHERE sl.State = 'New Jersey'

    UNION ALL

    SELECT
        os.Date AS Sale_Date,
        os.SalesTotal AS Revenue
    FROM online_sales os
    WHERE os.ShiptoState = 'New Jersey'
) AS combined_sales
GROUP BY YEAR(Sale_Date), MONTH(Sale_Date)
ORDER BY Sales_Year, Sales_Month;

-- I used the columns Sales_Year and Sales Month for better readability.
-- Intead of using the full date I believe filtering the results by Year and Month
-- makes the result easier to understand base on the questions requirements
-- I used the COUNT funtion on the number of transactions for each month for better insights on monthly performance


-- ---------------------------------------------------------------------

-- Exercise 4.3

-- Objective :
-- Compare NJ total revenue vs. the entire Northeast Region total revenue.
-- Logic: 
-- First identify which states belong to the Northeast Region using the management table.
-- Then sum online + store sales for each scope and display side by side.

SELECT DISTINCT State
FROM   management
WHERE  Region = 'Northeast';
-- I used this query to identify which states are in the Northeast Region

-- Objective:
-- I want to compare New Jersey territory Revenue agaist 
-- the rest of the Northeast Revenue taking into considaration 
-- that I now know all the states present in the Northeast region which are 
-- Maryland, Massachusetts, Maine, New Jersey
-- I tried to run separate UNION ALL branches but I couldnt figure out 
-- Why my values were Off as i ran separate quaries for each state but the sum of totatal revenue
-- was off so i asked Chat GPT to troubleshoot my query 
SELECT
CASE
WHEN State = 'New Jersey' THEN 'New Jersey Territory'
ELSE 'Northeast Region'
END AS Areas_of_comparison,
-- I used this query to separate New Jersey from the Northeast Region for the purpose of my comparison

SUM(Revenue) AS Total_Revenue,
COUNT(*) AS Number_Of_Transactions
FROM (
SELECT
sl.State,
ss.Sale_Amount AS Revenue
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.Store_ID

UNION ALL

SELECT
        os.ShiptoState AS State,
        os.SalesTotal AS Revenue
FROM online_sales os
) AS Sales_Comparisons
WHERE State IN ('Maryland', 'Massachusetts', 'Maine', 'New Jersey')
GROUP BY
CASE
WHEN State = 'New Jersey' THEN 'New Jersey Territory'
ELSE 'Northeast Region'
END;
-- I sued Join to connect store_sales to store_locations using Store_ID.
-- For store sales, I used store_locations to find the state of each store.
-- For online sales, I used ShiptoState to know where the online order was shipped.
-- Then I filtered only sales from the Northeast states.
-- Finally, I separated the results into two groups: Northeast Region and New Jersey Territory

-- --------------------------------------------------------------------------------

-- Exercise 4.4

-- Objective:
-- Find the number of transactions per month and the average transaction size
-- by product category for New Jersey sales.
-- This includes BOTH store sales and online sales.

-- Logic:
--  Pull New Jersey store sales by joining store_sales to store_locations.
--  Pull New Jersey online sales using ShiptoState.
--  Join both sales tables to products, then to inventory_categories,
--    so each sale has a product category.
--  Use UNION ALL to combine store and online sales together.
--  Group the results by year, month, and category.
--  Count transactions, average revenue, and total revenue.

SELECT
    YEAR(Sale_Date) AS Sales_Year,
    MONTH(Sale_Date) AS Sales_Month,
    Category,
    COUNT(*) AS Number_Of_Transactions,
    AVG(Revenue) AS Average_Transaction_Size,
    SUM(Revenue) AS Total_Revenue
FROM (
    SELECT
        ss.Transaction_Date AS Sale_Date,
        ss.Sale_Amount AS Revenue,
        ic.Category
    FROM store_sales ss
    JOIN store_locations sl ON ss.Store_ID = sl.Store_ID
    JOIN products p ON ss.Product_Number = p.ProdNum
    JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
    WHERE sl.State = 'New Jersey'

    UNION ALL

    SELECT
        os.Date AS Sale_Date,
        os.SalesTotal AS Revenue,
        ic.Category
    FROM online_sales os
    JOIN products p ON os.Product_Number = p.ProdNum
    JOIN inventory_categories ic ON p.Categoryid = ic.Categoryid
    WHERE os.ShiptoState = 'New Jersey'
) AS combined_sales
GROUP BY Sales_Year, Sales_Month, Category
ORDER BY Sales_Year, Sales_Month, Category;