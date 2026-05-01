
USE sample_sales;

-- Question 1:
-- Create a list of all transactions that took place on January 15, 2024,
-- sorted by sale amount from highest to lowest.

SELECT Transaction_Date, Store_ID, Product_Number, Sale_Amount
FROM store_sales
WHERE Transaction_Date = '2024-01-15'
ORDER BY Sale_Amount DESC;

-- Question 2:
-- Which transactions had a sale amount greater than $500?
-- Display the transaction date, store ID, product number, and sale amount.

SELECT Transaction_Date, Store_ID, Product_Number, Sale_Amount
FROM store_sales
WHERE Sale_Amount > 500
ORDER BY Sale_Amount DESC;

-- Question 3:
-- Find all products whose product number begins with the prefix 105250.
-- What category do they belong to?

SELECT p.ProdNum, p.Description, ic.Category
FROM products p
JOIN inventory_categories ic
ON p.Categoryid = ic.Categoryid
WHERE p.ProdNum LIKE '105250%';

-- Aggregation
-- Question 4:
-- What is the total sales revenue across all transactions?
-- What is the average transaction amount?

SELECT
SUM(Sale_Amount) AS Total_Sales_Revenue,
AVG(Sale_Amount) AS Average_Transaction_Amount
FROM store_sales;

-- Question 5:
-- How many transactions were recorded for each product category?
-- Which category has the most transactions?

SELECT ic.Category,
COUNT(*) AS Number_Of_Transactions
FROM store_sales ss
JOIN products p
ON ss.Product_Number = p.ProdNum
JOIN inventory_categories ic
ON p.Categoryid = ic.Categoryid
GROUP BY ic.Category
ORDER BY Number_Of_Transactions DESC;

-- Question 6:
-- Which store generated the highest total revenue?
-- Which generated the lowest?

SELECT ss.Store_ID, sl.StoreLocation, sl.State,
SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
ON ss.Store_ID = sl.Store_ID
GROUP BY ss.Store_ID, sl.StoreLocation, sl.State
ORDER BY Total_Revenue DESC;

-- The first row shows the store with the highest total revenue.
-- The last row shows the store with the lowest total revenue.


