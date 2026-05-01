/*
File: Nji_bonus_queries.sql
Project: Capstone 1 - Bonus Queries
Student: Nji

Note:
This script uses the main capstone tables:
- store_sales
- store_locations
- products
- inventory_categories
- management
- Shipper_List

If your database uses slightly different column names, update the column names to match your tables.
*/


/*
SELECT, Filtering & Sorting

Question 1:
Create a list of all transactions that took place on January 15, 2024,
sorted by sale amount from highest to lowest.
*/

SELECT
    Transaction_Date,
    Store_ID,
    Product_Number,
    Sale_Amount
FROM store_sales
WHERE Transaction_Date = '2024-01-15'
ORDER BY Sale_Amount DESC;


/*
Question 2:
Which transactions had a sale amount greater than $500?
Display the transaction date, store ID, product number, and sale amount.
*/

SELECT
    Transaction_Date,
    Store_ID,
    Product_Number,
    Sale_Amount
FROM store_sales
WHERE Sale_Amount > 500
ORDER BY Sale_Amount DESC;


/*
Question 3:
Find all products whose product number begins with the prefix 105250.
What category do they belong to?
*/

SELECT
    p.ProdNum,
    p.Description,
    ic.Category
FROM products p
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE p.ProdNum LIKE '105250%';


/*
Aggregation

Question 4:
What is the total sales revenue across all transactions?
What is the average transaction amount?
*/

SELECT
    SUM(Sale_Amount) AS Total_Sales_Revenue,
    AVG(Sale_Amount) AS Average_Transaction_Amount
FROM store_sales;


/*
Question 5:
How many transactions were recorded for each product category?
Which category has the most transactions?
*/

SELECT
    ic.Category,
    COUNT(*) AS Number_Of_Transactions
FROM store_sales ss
JOIN products p
    ON ss.Product_Number = p.ProdNum
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
GROUP BY ic.Category
ORDER BY Number_Of_Transactions DESC;


/*
Question 6:
Which store generated the highest total revenue?
Which generated the lowest?
*/

SELECT
    ss.Store_ID,
    sl.StoreLocation,
    sl.State,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
GROUP BY ss.Store_ID, sl.StoreLocation, sl.State
ORDER BY Total_Revenue DESC;

/*
The first row shows the store with the highest total revenue.
The last row shows the store with the lowest total revenue.
*/


/*
Question 7:
What is the total revenue for each category, sorted from highest to lowest?
*/

SELECT
    ic.Category,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN products p
    ON ss.Product_Number = p.ProdNum
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
GROUP BY ic.Category
ORDER BY Total_Revenue DESC;


/*
Question 8:
Which stores had total revenue above $50,000?
Hint: you'll need HAVING.
*/

SELECT
    ss.Store_ID,
    sl.StoreLocation,
    sl.State,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
GROUP BY ss.Store_ID, sl.StoreLocation, sl.State
HAVING SUM(ss.Sale_Amount) > 50000
ORDER BY Total_Revenue DESC;


/*
Joins

Question 9:
Find all sales records where the category is either "Textbooks" or "Technology & Accessories."
*/

SELECT
    ss.Transaction_Date,
    ss.Store_ID,
    ss.Product_Number,
    ic.Category,
    ss.Sale_Amount
FROM store_sales ss
JOIN products p
    ON ss.Product_Number = p.ProdNum
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE ic.Category IN ('Textbooks', 'Technology & Accessories')
ORDER BY ss.Transaction_Date;


/*
Question 10:
List all transactions where the sale amount was between $100 and $200,
and the category was "Textbooks."
*/

SELECT
    ss.Transaction_Date,
    ss.Store_ID,
    ss.Product_Number,
    ic.Category,
    ss.Sale_Amount
FROM store_sales ss
JOIN products p
    ON ss.Product_Number = p.ProdNum
JOIN inventory_categories ic
    ON p.Categoryid = ic.Categoryid
WHERE ss.Sale_Amount BETWEEN 100 AND 200
  AND ic.Category = 'Textbooks'
ORDER BY ss.Sale_Amount;


/*
Question 11:
Write a query that displays each store's total sales along with the city and state
where that store is located.
*/

SELECT
    ss.Store_ID,
    sl.City,
    sl.State,
    SUM(ss.Sale_Amount) AS Total_Sales
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
GROUP BY ss.Store_ID, sl.City, sl.State
ORDER BY Total_Sales DESC;

/*
If your table does not have a City column, use StoreLocation instead of City.
*/


/*
Question 12:
For each sale, display the transaction date, sale amount, city, state,
and the name of the store manager responsible for that state.
*/

SELECT
    ss.Transaction_Date,
    ss.Sale_Amount,
    sl.City,
    sl.State,
    m.Store_Manager
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
JOIN management m
    ON sl.State = m.State
ORDER BY ss.Transaction_Date;

/*
If your management table uses a different manager column name,
replace Store_Manager with the correct column name.
*/


/*
Question 13:
Write a query that shows total sales by region. Which region generates the most revenue?
*/

SELECT
    m.Region,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
JOIN management m
    ON sl.State = m.State
GROUP BY m.Region
ORDER BY Total_Revenue DESC;

/*
The first row shows the region that generates the most revenue.
*/


/*
Question 14:
For states that have a preferred shipper listed in Shipper_List,
show the total sales alongside the preferred shipper and volume discount.
*/

SELECT
    sl.State,
    sh.Preferred_Shipper,
    sh.Volume_Discount,
    SUM(ss.Sale_Amount) AS Total_Sales
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
JOIN Shipper_List sh
    ON sl.State = sh.State
GROUP BY sl.State, sh.Preferred_Shipper, sh.Volume_Discount
ORDER BY Total_Sales DESC;


/*
Question 15:
Are there any states with sales data that do not appear in Shipper_List?
*/

SELECT DISTINCT
    sl.State
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
LEFT JOIN Shipper_List sh
    ON sl.State = sh.State
WHERE sh.State IS NULL;

/*
If this query returns rows, those states have store sales data but are missing
from the Shipper_List table.
*/


/*
Question 16:
Display total revenue by regional director.
*/

SELECT
    m.Regional_Director,
    SUM(ss.Sale_Amount) AS Total_Revenue
FROM store_sales ss
JOIN store_locations sl
    ON ss.Store_ID = sl.Store_ID
JOIN management m
    ON sl.State = m.State
GROUP BY m.Regional_Director
ORDER BY Total_Revenue DESC;


/*
Subqueries

Question 17:
Using a subquery, find all transactions from stores located in Texas.
*/

SELECT
    Transaction_Date,
    Store_ID,
    Product_Number,
    Sale_Amount
FROM store_sales
WHERE Store_ID IN (
    SELECT Store_ID
    FROM store_locations
    WHERE State = 'Texas'
)
ORDER BY Transaction_Date;


/*
Question 18:
Which stores had total sales above the average store revenue?
Hint: use a subquery to calculate the average first.
*/

SELECT
    store_totals.Store_ID,
    store_totals.Total_Revenue
FROM (
    SELECT
        Store_ID,
        SUM(Sale_Amount) AS Total_Revenue
    FROM store_sales
    GROUP BY Store_ID
) AS store_totals
WHERE store_totals.Total_Revenue > (
    SELECT AVG(Total_Revenue)
    FROM (
        SELECT
            Store_ID,
            SUM(Sale_Amount) AS Total_Revenue
        FROM store_sales
        GROUP BY Store_ID
    ) AS average_store_sales
)
ORDER BY store_totals.Total_Revenue DESC;


/*
Question 19:
Find the top 5 highest-grossing stores, then use that result to look up their city
and state from Store_Locations.
*/

SELECT
    top_stores.Store_ID,
    sl.City,
    sl.State,
    top_stores.Total_Revenue
FROM (
    SELECT
        Store_ID,
        SUM(Sale_Amount) AS Total_Revenue
    FROM store_sales
    GROUP BY Store_ID
    ORDER BY Total_Revenue DESC
    LIMIT 5
) AS top_stores
JOIN store_locations sl
    ON top_stores.Store_ID = sl.Store_ID
ORDER BY top_stores.Total_Revenue DESC;

/*
If your table does not have a City column, use StoreLocation instead of City.
*/


/*
Question 20:
Write a query using a subquery to find all sales records from stores managed by
the Northeast region's store managers.
*/

SELECT
    ss.Transaction_Date,
    ss.Store_ID,
    ss.Product_Number,
    ss.Sale_Amount
FROM store_sales ss
WHERE ss.Store_ID IN (
    SELECT sl.Store_ID
    FROM store_locations sl
    WHERE sl.State IN (
        SELECT m.State
        FROM management m
        WHERE m.Region = 'Northeast'
    )
)
ORDER BY ss.Transaction_Date;
