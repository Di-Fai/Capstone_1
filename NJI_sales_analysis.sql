-- Capstone 1 Sales Analysis
-- This script analyzes STORE SALES for the New Jersey sales territory.
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
-- I joined store_sales to store_locations using Store_ID because store_sales
-- contains the revenue, but store_locations tells me which state each store is located.
-- I filtered the results to only include New Jersey stores.
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

-- This query return the overall revenue for store_sales.

-- -------------------------------------------------------------------

-- Exercise 4.2
-- Objective:
-- Find the month-by-month STORE revenue breakdown for New Jersey.

-- Logic:
-- Use store_sales as the main table because it contains in-store transaction data.
-- Join store_sales to store_locations so I could filter for New Jersey stores.
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
-- I joined store_sales to store_locations using Store_ID to identify each store by state.
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
-- I grouped by year, month, and category to summarize performance by category for each month.
-- I used COUNT() to count transactions, AVG() to find average transaction size,
-- and SUM() to calculate total revenue for each category.

SELECT
YEAR(ss.Transaction_Date) AS Sales_Year,
MONTH(ss.Transaction_Date) AS Sales_Month,
ic.Category,
COUNT(*) AS Number_Of_Transactions,
AVG(ss.Sale_Amount) AS Average_Transaction_size,
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
AVG(ss.Sale_Amount) AS Average_Transaction_size
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
-- Exercise 4.6

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
AVG(ss.Sale_Amount) AS Average_Revenue
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
-- I filtered by New Jersey stores only.
-- I grouped by category and sorted revenue from lowest to highest.
-- This helps show which product categories may need better promotion,
-- placement, pricing, or inventory planning next quarter.

SELECT
ic.Category,
SUM(ss.Sale_Amount) AS Total_Category_Revenue,
COUNT(*) AS Number_Of_Transactions,
AVG(ss.Sale_Amount) AS Average_Transaction_Revenue
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


/*
Recommendation:

Based on my New Jersey store sales analysis, My recommendation for next quarter is to focus on low-performing stores and weak product categories.

From the store results, Newark and Trenton are the top-performing stores, so they should be used as a benchmark. 
The lowest-performing store is Paterson, which has low total revenue and fewer transactions, meaning it likely needs more customer traffic, promotions, or better store strategy.

Other lower-performing stores like Montclair, Cape May, and Bayonne also need attention because they are below average compared to the top stores.

For product categories, Technology & Accessories and Textbooks are the strongest because they generate the most revenue and higher transaction values. On the other hand, Stationery and Supplies and Books generate a lower revenue and low average transaction size.

To improve performance, stores can bundle low-value items with higher-value products to increase the average transaction size.

Next quarter focus:
1. Improve low-performing stores like Paterson  
2. Increase customer traffic and sales activity  
3. Strengthen weak categories  
4. Apply strategies from top stores like Newark and Trenton  
5. Increase total revenue and average transaction size  

Overall, the goal is to close the gap between low and high-performing stores and improve overall store sales in New Jersey.
*/



-- ----------------------------------------------------------------------------------------

-- Question 5


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

/*
Based on my analysis, Paterson is the lowest-performing store in New Jersey, with low total revenue and a lower number of transactions compared to other stores.

This suggests that the main issue is not the value of each sale, but the lack of customer traffic and overall sales activity.

To improve performance, I recommend:
- Increasing local promotions and marketing to attract more customers
- Improving in-store experience, such as product placement and customer service
- Ensuring popular and high-demand products are always in stock
- Running targeted discounts or events to bring more people into the store

The goal for Paterson should be to increase the number of transactions, which will directly improve total revenue.
*/


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

/*
Based on my analysis, Stationery and Supplies is the weakest-performing category in New Jersey, with the lowest total revenue and a very low average transaction size.

This shows that while customers may purchase these items, they are low-value sales and do not contribute much to overall revenue.

To improve this category, I recommend:
- Bundling stationery items with higher-value products like textbooks or technology accessories
- Improving product visibility and placement in-store
- Offering promotions such as “buy more, save more” deals
- Reviewing pricing strategy to increase value per transaction

The goal is to increase the average transaction size and make this category contribute more to overall store revenue.
*/
