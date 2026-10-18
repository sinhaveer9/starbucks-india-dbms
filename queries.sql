-- In this SQL file, write (and comment!) the typical SQL queries users will run on your database

-- 1. BASIC SELECT
-- Show the first name, last name, and email of all registered customers.

SELECT "first_name", "last_name", "email"
FROM "customers";

-- 2. JOIN EXAMPLE
-- Show the customers who made transactions with the total amount spend.

SELECT "customers"."first_name", "customers"."last_name",
       "transactions"."transaction_id", "transactions"."total_amount"
FROM "customers"
JOIN "transactions" ON "customers"."customer_id" = "transactions"."customer_id"
ORDER BY "transactions"."transaction_id";


-- 3. AGGREGATE FUNCTION AND GROUP BY
-- Count how many transactions each customer has made.

SELECT "customers"."first_name", "customers"."last_name",
       COUNT("transactions"."transaction_id") AS "total_transactions"
FROM "customers"
LEFT JOIN "transactions" ON "customers"."customer_id" = "transactions"."customer_id"
GROUP BY "customers"."customer_id"
ORDER BY "total_transactions" DESC;


-- 4. SUBQUERY EXAMPLE
-- Find products that cost more than the average product price.

SELECT "product_name", "price"
FROM "products"
WHERE "price" > (
    SELECT AVG("price")
    FROM "products")
ORDER BY "price" DESC;


-- 5. MULTI-TABLE JOIN
-- Show which products were purchased, by which customers, and at which stores.

SELECT "customers"."first_name", "customers"."last_name",
       "stores"."store_name", "products"."product_name",
       "transaction_items"."quantity", "transaction_items"."subtotal"
FROM "transaction_items"
JOIN "transactions" ON "transaction_items"."transaction_id" = "transactions"."transaction_id"
JOIN "customers" ON "transactions"."customer_id" = "customers"."customer_id"
JOIN "stores" ON "transactions"."store_id" = "stores"."store_id"
JOIN "products" ON "transaction_items"."product_id" = "products"."product_id"
ORDER BY "transactions"."transaction_id";

-- 6. AGGREGATE FUNCTION AND HAVING
-- Find customers who have spent more than 1000 rupees on completed transactions.

SELECT "customers"."first_name", "customers"."last_name",
       SUM("transactions"."total_amount") AS "total_spent"
FROM "customers"
JOIN "transactions" ON "customers"."customer_id" = "transactions"."customer_id"
WHERE "transactions"."status" = 'Completed'
GROUP BY "customers"."customer_id"
HAVING SUM("transactions"."total_amount") > 1000
ORDER BY "total_spent" DESC;

-- 7. SUBQUERY AND JOIN
-- Find customers who have spent more than the average total spending per customer.

SELECT "customers"."first_name", "customers"."last_name",
       SUM("transactions"."total_amount") AS "total_spent"
FROM "customers"
JOIN "transactions" ON "customers"."customer_id" = "transactions"."customer_id"
WHERE "transactions"."status" = 'Completed'
GROUP BY "customers"."customer_id"
HAVING SUM("transactions"."total_amount") > (
    SELECT AVG("customer_total")
    FROM (
        SELECT SUM("total_amount") AS "customer_total"
        FROM "transactions"
        WHERE "status" = 'Completed'
        GROUP BY "customer_id"
    )
)

ORDER BY "total_spent" DESC;

-- 8. TRIGGER TEST
-- Test the earn_stars trigger by inserting a completed transaction.
-- The trigger should automatically add 10 Stars to customer 9.
-- ROLLBACK removes the test transaction and the Stars awarded by the trigger.

BEGIN TRANSACTION;

INSERT INTO "transactions"
    ("customer_id", "store_id", "total_amount",
     "stars_earned", "payment_method", "status")
VALUES
    (9, 1, 100, 10, 'UPI', 'Completed');

SELECT "customer_id", "stars_change", "change_type"
FROM "star_history"
WHERE "transaction_id" = last_insert_rowid();

ROLLBACK;


-- 9. VIEW QUERY - CUSTOMER STAR BALANCES
-- Show each customer's available Stars using the database view.

SELECT "customer_id", "first_name", "last_name", "available_stars"
FROM "customer_star_balances"
ORDER BY "available_stars" DESC;

-- 10. ACTIVE MEMBERSHIP
-- Show the latest membership tier recorded for each customer.
-- If a customer has no tier history, display No Membership Record.

SELECT "customers"."first_name", "customers"."last_name",
       COALESCE("membership_tiers"."tier_name", 'No Membership Record') AS "current_tier"
FROM "customers"

LEFT JOIN "tier_history" ON "tier_history"."tier_history_id" = (
    SELECT "tier_history_id"
    FROM "tier_history"
    WHERE "customer_id" = "customers"."customer_id"
    ORDER BY "tier_history_id" DESC
    LIMIT 1
)

LEFT JOIN "membership_tiers" ON "tier_history"."new_tier_id" = "membership_tiers"."tier_id"
ORDER BY "customers"."customer_id";

-- 11. USER SUBSCRIPTION / REGISTRATION
-- Register a new customer in the Starbucks loyalty program.
-- ROLLBACK is used so this example does not permanently add a customer.

BEGIN TRANSACTION;

INSERT INTO "customers"
    ("first_name", "last_name", "email", "phone_number", "join_date")
VALUES
    ('Aarav', 'Sharma', 'aarav.sharma@example.com', '9876501234', DATE('now'));

SELECT "customer_id", "first_name", "last_name", "email"
FROM "customers"
WHERE "email" = 'aarav.sharma@example.com';

ROLLBACK;


-- 12. USER TRANSACTIONS
-- Show all transactions made by customer 1.

SELECT "transactions"."transaction_id",
       "stores"."store_name",
       "transactions"."transaction_date",
       "transactions"."total_amount",
       "transactions"."stars_earned",
       "transactions"."status"
FROM "transactions"
JOIN "stores" ON "transactions"."store_id" = "stores"."store_id"
WHERE "transactions"."customer_id" = 1
ORDER BY "transactions"."transaction_date" DESC;

-- 13. USER TIER HISTORY
-- Show all membership changes recorded for customer 1.

SELECT "customers"."first_name", "customers"."last_name",
       "membership_tiers"."tier_name",
       "tier_history"."stars_at_upgrade",
       "tier_history"."upgrade_date"
FROM "tier_history"
JOIN "customers" ON "tier_history"."customer_id" = "customers"."customer_id"
JOIN "membership_tiers" ON "tier_history"."new_tier_id" = "membership_tiers"."tier_id"
WHERE "customers"."customer_id" = 1
ORDER BY "tier_history"."upgrade_date";


-- 14. TOTAL REVENUE OF EACH STORE
-- Calculate the revenue generated by completed transactions at each store.

SELECT "stores"."store_name", "stores"."city",
       COUNT("transactions"."transaction_id") AS "total_orders",
       COALESCE(SUM("transactions"."total_amount"), 0) AS "total_revenue"
FROM "stores"
LEFT JOIN "transactions" ON "stores"."store_id" = "transactions"."store_id"
    AND "transactions"."status" = 'Completed'
GROUP BY "stores"."store_id"
ORDER BY "total_revenue" DESC;

-- 15. CUSTOMER STAR LEADERBOARD
-- Find the top 10 customers with the highest Star balances.
-- Rank customers according to the Stars they currently have.

SELECT
    "first_name" || ' ' || "last_name" AS "customer",
    "available_stars" AS "total_stars",
    RANK() OVER (
        ORDER BY "available_stars" DESC
    ) AS "rank"
FROM "customer_star_balances"
ORDER BY "rank"
LIMIT 10;

-- 16. CHECK INVENTORY BEFORE A PURCHASE
-- Check the available quantity of Espresso at store 1.
-- This helps determine whether the product is in stock.

SELECT
    "inventory"."inventory_id",
    "stores"."store_name",
    "products"."product_name",
    "inventory"."quantity"
FROM "inventory"
JOIN "stores"
    ON "inventory"."store_id" = "stores"."store_id"
JOIN "products"
    ON "inventory"."product_id" = "products"."product_id"
WHERE "inventory"."store_id" = 1
AND "products"."product_name" = 'Espresso';


-- 17. MOST POPULAR STARBUCKS PRODUCTS
-- Find the top 10 products based on the total quantity sold.

SELECT
    "products"."product_name",
    SUM("transaction_items"."quantity") AS "total_sold"
FROM "products"
JOIN "transaction_items"
    ON "products"."product_id" = "transaction_items"."product_id"
GROUP BY "products"."product_id"
ORDER BY "total_sold" DESC
LIMIT 10;

-- 18. REGISTER A NEW CUSTOMER
-- Register a new customer named Ananya Gupta in the Starbucks loyalty program.
-- The customer ID is generated automatically.

INSERT INTO "customers"
    ("first_name", "last_name", "email", "phone_number", "join_date")
VALUES
    ('Ananya', 'Gupta', 'ananya.gupta@example.com', '9876543219', DATE('now'));

-- 19. ADD A NEW STARBUCKS PRODUCT
-- Add a new coffee product named Caramel Cold Brew to the Starbucks menu.

INSERT INTO "products"
    ("product_name", "category", "price", "availability")
VALUES
    ('Caramel Cold Brew', 'Coffee', 390, 1);

-- 20. Find how many more Stars each customer needs to reach the next membership tier.
-- Green customers need 1000 Stars for Gold.
-- Gold customers need 5000 Stars for Reserve.

SELECT "first_name", "last_name", "available_stars",
CASE
    WHEN "available_stars" < 1000 THEN 'Gold'
    WHEN "available_stars" < 5000 THEN 'Reserve'
    ELSE 'Highest Tier'
END AS "next_tier",
CASE
    WHEN "available_stars" < 1000 THEN 1000 - "available_stars"
    WHEN "available_stars" < 5000 THEN 5000 - "available_stars"
    ELSE 0
END AS "stars_needed"
FROM "customer_star_balances"
ORDER BY "stars_needed";
