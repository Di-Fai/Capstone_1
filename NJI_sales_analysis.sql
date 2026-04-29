-- Capstone 1 Sales Analysis
-- This script analyzes STORE SALES ONLY for the New Jersey sales territory.
-- Online_sales has been excluded from all questions and answers for this updated version.
-- -------------------------------------------------------------------

USE sample_sales;
SHOW TABLES;
-- I used this query to confirm the tables in my database.

-- -------------------------------------------------------------------

SELECT SalesManager, Region, State
FROM Management
WHERE SalesManager = 'Miami Vue';

-- Objective:
-- Identify my sales manager, assigned region, and assigned state.

-- Logic:
-- The Management table connects each sales manager to a region and state.
-- I filtered the table where SalesManager = 'Miami Vue' so I can confirm
-- that my assigned territory is New Jersey in the Northeast Region.

-- -------------------------------------------------------------------

-- Exercise 4.1
-- Objective:
-- Find the total STORE revenue for New Jersey, plus the earliest and latest
-- store transaction dates so we know what time period the data covers.

-- Logic:
-- I started with store_sales because the updated analysis excludes online sales.
-- I joined store_sales to store_locations using Store_ID because store_sales
-- contains the revenue, but store_locations tells me which state each store is in.
-- Then I filtered the results to only include New Jersey stores.
-- I used SUM() to calculate total revenue, MIN() to find the first sale date,
-- and MAX() to find the last sale date.

SELECT
'New Jersey Store Sales' AS Territory,
SUM(ss.Sale_Amount) AS Total_Revenue,
MIN(ss.Transaction_Date) AS Start_Date,
MAX(ss.Transaction_Date) AS End_Date
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey';

-- This query answers the overall revenue question using store sales only.
-- Online_sales is not included because this updated analysis is focused only
-- on physical store performance in the New Jersey territory.

-- -------------------------------------------------------------------

-- Exercise 4.2
-- Objective:
-- Find the month-by-month STORE revenue breakdown for New Jersey.

-- Logic:
-- Use store_sales as the main table because it contains in-store transaction data.
-- Joine store_sales to store_locations so I could filter for New Jersey stores.
-- Use YEAR() and MONTH() to separate each transaction date into year and month.
-- Groupe by year and month so each month gets one summary row.
-- Use SUM() to calculate monthly revenue and COUNT() to count the number
-- of store transactions for each month.

SELECT
    YEAR(ss.Transaction_Date) AS Sales_Year,
    MONTH(ss.Transaction_Date) AS Sales_Month,
    SUM(ss.Sale_Amount) AS Monthly_Revenue,
    COUNT(*) AS Number_Of_Transactions
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey'
GROUP BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date)
ORDER BY
    Sales_Year,
    Sales_Month;

-- I used Sales_Year and Sales_Month to make the results easier to read.
-- Instead of showing every single sale date, this query summarizes the data by month,
-- which makes it easier to explain monthly store performance.

-- -------------------------------------------------------------------

-- Exercise 4.3
-- Objective:
-- Identify the states that belong to the Northeast Region.

-- Logic:
-- I used the management table because it connects each state to a region.
-- I filtered where Region = 'Northeast' to see which states should be included
-- when comparing New Jersey to the larger Northeast Region.

SELECT DISTINCT State
FROM management
WHERE Region = 'Northeast';

-- -------------------------------------------------------------------

-- Exercise 4.3 Continued
-- Objective:
-- Compare New Jersey STORE revenue against the rest of the Northeast Region STORE revenue.

-- Logic:
-- I used store_sales as the main table because this updated version excludes online_sales.
-- I joined store_sales to store_locations using Store_ID to identify each store's state.
-- I joined store_locations to management using State so I could filter for the Northeast Region.
-- I used a CASE statement to separate New Jersey from the other Northeast states.
-- I used SUM() to calculate total revenue and COUNT() to count store transactions.
-- I grouped by the CASE statement so the result shows New Jersey Territory and
-- the rest of the Northeast Region as separate comparison rows.

SELECT
    CASE
        WHEN sl.State = 'New Jersey' THEN 'New Jersey Territory'
        ELSE 'Rest of Northeast Region'
    END AS Area_Of_Comparison,
    SUM(ss.Sale_Amount) AS Total_Revenue,
    COUNT(*) AS Number_Of_Transactions
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
JOIN management m
    ON sl.State = m.State
WHERE m.Region = 'Northeast'
GROUP BY
    CASE
        WHEN sl.State = 'New Jersey' THEN 'New Jersey Territory'
        ELSE 'Rest of Northeast Region'
    END
ORDER BY Total_Revenue DESC;

-- This query compares New Jersey store performance to the rest of the Northeast Region.
-- Online sales are excluded because the purpose of this updated analysis is to focus
-- only on revenue generated from physical store locations.

-- -------------------------------------------------------------------

-- Exercise 4.4
-- Objective:
-- Find the number of STORE transactions per month and the average transaction size
-- by product category for New Jersey.

-- Logic:
-- I used store_sales because it contains store transaction details.
-- I joined store_sales to store_locations so I could filter only New Jersey stores.
-- I joined store_sales to products using Product_Number = ProdNum so each sale
-- can be connected to product information.
-- I joined products to inventory_categories using Categoryid so each sale can be
-- grouped by product category.
-- I grouped by year, month, and category to summarize performance by category each month.
-- I used COUNT() to count transactions, AVG() to find average transaction size,
-- and SUM() to calculate total revenue for each category.

SELECT
    YEAR(ss.Transaction_Date) AS Sales_Year,
    MONTH(ss.Transaction_Date) AS Sales_Month,
    ic.Category,
    COUNT(*) AS Number_Of_Transactions,
    AVG(ss.Sale_Amount) AS Average_Transaction_Size,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
JOIN products p
    ON ss.Product_Number = p.ProductNumber
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'New Jersey'
GROUP BY
    YEAR(ss.Transaction_Date),
    MONTH(ss.Transaction_Date),
    ic.Category
ORDER BY
    Sales_Year,
    Sales_Month,
    ic.Category;

-- This query shows how each product category performed each month in New Jersey stores.
-- It helps identify categories with strong or weak in-store performance.

-- -------------------------------------------------------------------

-- Exercise 4.5
-- Objective:
-- Rank in-store sales performance for each store in the New Jersey sales territory.

-- Logic:
-- I used store_sales because it contains revenue for physical store transactions.
-- I joined store_sales to store_locations using Store_ID to identify each store location.
-- I filtered the results to New Jersey only.
-- I grouped by store so each store has one summary row.
-- I calculated total store revenue, number of transactions, and average transaction size.
-- I sorted by total revenue from highest to lowest to rank store performance.

SELECT
    ss.Store_ID,
    sl.StoreLocation,
    sl.State,
    SUM(ss.Sale_Amount) AS Total_Store_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    AVG(ss.Sale_Amount) AS Average_Transaction_Size
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey'
GROUP BY
    ss.Store_ID,
    sl.StoreLocation,
    sl.State
ORDER BY Total_Store_Revenue DESC;

-- This query returns all New Jersey store locations ranked from highest revenue
-- to lowest revenue. It helps the sales manager quickly identify the strongest
-- and weakest physical stores in the territory.

-- -------------------------------------------------------------------

-- Exercise 4.6 Supporting Query 1
-- Objective:
-- Identify the lowest-performing New Jersey stores based on total store revenue.

-- Logic:
-- This query uses the same store ranking logic as Exercise 4.5, but sorts revenue
-- from lowest to highest. This helps show which stores may need more sales attention,
-- promotions, staff support, or inventory review next quarter.

SELECT
ss.Store_ID,
sl.StoreLocation,
SUM(ss.Sale_Amount) AS Total_Store_Revenue,
COUNT(*) AS Number_Of_Transactions,
AVG(ss.Sale_Amount) AS Average_Transaction_Size
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey'
GROUP BY
ss.Store_ID,
sl.StoreLocation
ORDER BY Total_Store_Revenue ASC;

-- -------------------------------------------------------------------

-- Exercise 4.6 Supporting Query 2
-- Objective:
-- Identify the lowest-performing product categories in New Jersey stores.

-- Logic:
-- I joined store_sales to products and inventory_categories so each transaction
-- can be connected to a product category.
-- I filtered to New Jersey stores only.
-- I grouped by category and sorted revenue from lowest to highest.
-- This helps show which product categories may need better promotion,
-- placement, pricing, or inventory planning next quarter.

SELECT
    ic.Category,
    SUM(ss.Sale_Amount) AS Total_Category_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    AVG(ss.Sale_Amount) AS Average_Transaction_Size
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
JOIN products p
    ON ss.Product_Number = p.ProductNumber
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'New Jersey'
GROUP BY ic.Category
ORDER BY Total_Category_Revenue ASC;

-- -------------------------------------------------------------------

-- Exercise 4.6

/*
Recommendation:

Based on my New Jersey store sales analysis, I recommend that the sales manager focus next quarter on the lowest-performing physical stores and the product categories with weak in-store revenue.

From a business point of view, the stores at the bottom of the ranking are the biggest opportunity for improvement. These locations may need more local promotions, better inventory planning, stronger product placement, or extra staff support. The goal should not only be to reward the best stores, but also to bring weaker stores closer to the performance level of the stronger stores.

I also recommend reviewing the lowest-performing product categories in New Jersey stores. If a category has low revenue or a low average transaction size, the business should check whether customers are not interested in the product, whether the product is not being displayed well, or whether the store does not have enough inventory.

The top-performing stores should also be studied because they may already be using strategies that can help the weaker stores. For example, if a high-performing store has better product placement, stronger customer service, or better inventory availability, those same strategies can be used in lower-performing stores.

Since this updated analysis excludes online_sales, my recommendation is focused only on in-store sales performance. The next quarter should focus on:
1. Improving the lowest-performing New Jersey stores
2. Strengthening weak product categories
3. Learning from the best-performing stores and applying those strategies across the territory
4. Increasing total store revenue and transaction size in the New Jersey sales territory
*/

-- ----------------------------------------------------------------------------------------

-- Question 5

/*
Recommendation:

Based on my New Jersey store sales analysis, I recommend that the sales manager focus next quarter
on the lowest-performing physical stores and the product categories with weak in-store revenue.

The reason for this recommendation is that the lowest-performing stores represent the biggest
opportunity for improvement. These stores may need more local promotions, better inventory planning,
stronger product placement, or extra staff support.

I also recommend reviewing the lowest-performing product categories because low revenue or low
average transaction size may show that customers are not buying those products often, the products
are not being displayed well, or inventory is not meeting customer demand.

The top-performing stores should also be studied because their strategies may help improve weaker
stores. If stronger stores have better product placement, customer service, or inventory availability,
those same practices can be applied across the New Jersey territory.

Since this analysis excludes online_sales, this recommendation is focused only on in-store sales
performance for New Jersey stores.

Overall, next quarter should focus on:
-Improving the lowest-performing New Jersey stores
-Strengthening weak product categories
-Learning from the best-performing stores
-Increasing total store revenue and average transaction size
*/


-- Find the lowest-performing New Jersey stores

SELECT
    ss.Store_ID,
    sl.StoreLocation,
    SUM(ss.Sale_Amount) AS Total_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    AVG(ss.Sale_Amount) AS Average_Transaction_Size
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
WHERE sl.State = 'New Jersey'
GROUP BY ss.Store_ID, sl.StoreLocation
ORDER BY Total_Revenue ASC;


-- Find the weakest product categories in New Jersey stores

SELECT
    ic.Category,
    SUM(ss.Sale_Amount) AS Total_Revenue,
    COUNT(*) AS Number_Of_Transactions,
    AVG(ss.Sale_Amount) AS Average_Transaction_Size
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.StoreID
JOIN products p
    ON ss.Product_Number = p.ProductNumber
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE sl.State = 'New Jersey'
GROUP BY ic.Category
ORDER BY Total_Revenue ASC;
