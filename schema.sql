-- Representing customers
CREATE TABLE "customers" (
    "customer_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "phone_number" TEXT UNIQUE,
    "join_date" TEXT NOT NULL DEFAULT CURRENT_DATE
);

-- Representing membership tiers
CREATE TABLE "membership_tiers" (
    "tier_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "tier_name" TEXT NOT NULL UNIQUE,
    "minimum_stars" INTEGER NOT NULL CHECK ("minimum_stars" >= 0),
    "maximum_stars" INTEGER,
    "description" TEXT,
    CHECK ("maximum_stars" IS NULL OR "maximum_stars" >= "minimum_stars")
);

-- Representing Starbucks stores
CREATE TABLE "stores" (
    "store_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "store_name" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "postal_code" TEXT,
    "opening_date" TEXT,
    "store_type" TEXT NOT NULL DEFAULT 'Regular'
        CHECK ("store_type" IN ('Regular', 'Reserve', 'Drive-Thru')),
    "status" TEXT NOT NULL DEFAULT 'Open'
        CHECK ("status" IN ('Open', 'Closed', 'Under Renovation'))
);

-- Representing all sellable products
CREATE TABLE "products" (
    "product_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "product_name" TEXT NOT NULL,
    "category" TEXT NOT NULL
        CHECK ("category" IN ('Coffee', 'Food', 'Merchandise', 'Coffee Beans')),
    "price" INTEGER NOT NULL CHECK ("price" >= 0),
    "availability" INTEGER NOT NULL DEFAULT 1
        CHECK ("availability" IN (0, 1))
);

-- Representing coffee drinks and their sizes
CREATE TABLE "coffees" (
    "coffee_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "coffee_name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "size" TEXT NOT NULL,
    "price" INTEGER NOT NULL CHECK ("price" >= 0),
    "availability" INTEGER NOT NULL DEFAULT 1 CHECK ("availability" IN (0, 1)),
    "description" TEXT,
    "product_id" INTEGER UNIQUE,
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

-- Representing food items
CREATE TABLE "food" (
    "food_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "food_name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "price" INTEGER NOT NULL CHECK ("price" >= 0),
    "availability" INTEGER NOT NULL DEFAULT 1 CHECK ("availability" IN (0, 1)),
    "description" TEXT,
    "product_id" INTEGER UNIQUE,
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

-- Representing Starbucks merchandise
CREATE TABLE "merchandise" (
    "merchandise_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "merchandise_name" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "price" INTEGER NOT NULL CHECK ("price" >= 0),
    "material" TEXT,
    "capacity_ml" INTEGER CHECK ("capacity_ml" > 0),
    "availability" INTEGER NOT NULL DEFAULT 1 CHECK ("availability" IN (0, 1)),
    "description" TEXT,
    "product_id" INTEGER UNIQUE,
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

-- Representing packaged coffee beans sold to customers
CREATE TABLE "coffee_beans" (
    "bean_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "bean_name" TEXT NOT NULL,
    "origin" TEXT NOT NULL,
    "roast_type" TEXT NOT NULL CHECK ("roast_type" IN ('Blonde', 'Medium', 'Dark')),
    "weight_grams" INTEGER NOT NULL CHECK ("weight_grams" > 0),
    "price" INTEGER NOT NULL CHECK ("price" >= 0),
    "availability" INTEGER NOT NULL DEFAULT 1 CHECK ("availability" IN (0, 1)),
    "description" TEXT,
    "product_id" INTEGER UNIQUE,
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

-- Representing customers' membership tier changes
CREATE TABLE "tier_history" (
    "tier_history_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "customer_id" INTEGER NOT NULL,
    "previous_tier_id" INTEGER,
    "new_tier_id" INTEGER NOT NULL,
    "upgrade_date" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "stars_at_upgrade" INTEGER NOT NULL CHECK ("stars_at_upgrade" >= 0),
    FOREIGN KEY ("customer_id") REFERENCES "customers"("customer_id"),
    FOREIGN KEY ("previous_tier_id") REFERENCES "membership_tiers"("tier_id"),
    FOREIGN KEY ("new_tier_id") REFERENCES "membership_tiers"("tier_id")
);

-- Representing customer purchases
CREATE TABLE "transactions" (
    "transaction_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "customer_id" INTEGER NOT NULL,
    "store_id" INTEGER NOT NULL,
    "transaction_date" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "total_amount" INTEGER NOT NULL CHECK ("total_amount" >= 0),
    "stars_earned" INTEGER NOT NULL DEFAULT 0 CHECK ("stars_earned" >= 0),
    "payment_method" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'Completed'
        CHECK ("status" IN ('Completed', 'Cancelled', 'Refunded')),
    FOREIGN KEY ("customer_id") REFERENCES "customers"("customer_id"),
    FOREIGN KEY ("store_id") REFERENCES "stores"("store_id")
);

-- Representing individual products within each transaction
CREATE TABLE "transaction_items" (
    "item_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "transaction_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL CHECK ("quantity" > 0),
    "unit_price" INTEGER NOT NULL CHECK ("unit_price" >= 0),
    "subtotal" INTEGER NOT NULL CHECK ("subtotal" >= 0),
    FOREIGN KEY ("transaction_id") REFERENCES "transactions"("transaction_id"),
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id")
);

-- Representing stock of sellable products at each store
CREATE TABLE "inventory" (
    "inventory_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "store_id" INTEGER NOT NULL,
    "product_id" INTEGER NOT NULL,
    "quantity" INTEGER NOT NULL DEFAULT 0 CHECK ("quantity" >= 0),
    "minimum_stock" INTEGER NOT NULL DEFAULT 10 CHECK ("minimum_stock" >= 0),
    "last_updated" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ("store_id") REFERENCES "stores"("store_id"),
    FOREIGN KEY ("product_id") REFERENCES "products"("product_id"),
    UNIQUE ("store_id", "product_id")
);

-- Representing Stars earned, redeemed, adjusted or expired
CREATE TABLE "star_history" (
    "star_history_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "customer_id" INTEGER NOT NULL,
    "transaction_id" INTEGER,
    "stars_change" INTEGER NOT NULL CHECK ("stars_change" != 0),
    "change_type" TEXT NOT NULL
        CHECK ("change_type" IN ('Earned', 'Redeemed', 'Adjusted', 'Expired')),
    "change_date" TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "description" TEXT,
    FOREIGN KEY ("customer_id") REFERENCES "customers"("customer_id"),
    FOREIGN KEY ("transaction_id") REFERENCES "transactions"("transaction_id")
);

-- Representing available rewards and membership eligibility
CREATE TABLE "rewards" (
    "reward_id" INTEGER PRIMARY KEY AUTOINCREMENT,
    "reward_name" TEXT NOT NULL,
    "description" TEXT,
    "stars_required" INTEGER NOT NULL CHECK ("stars_required" > 0),
    "minimum_tier_id" INTEGER NOT NULL,
    "availability" INTEGER NOT NULL DEFAULT 1 CHECK ("availability" IN (0, 1)),
    "reward_type" TEXT NOT NULL
        CHECK ("reward_type" IN ('Free Drink', 'Free Food', 'Discount', 'Merchandise', 'Other')),
    FOREIGN KEY ("minimum_tier_id") REFERENCES "membership_tiers"("tier_id")
);

-- Indexes for frequent customer, store and product lookups
CREATE INDEX "idx_transactions_customer" ON "transactions"("customer_id");
CREATE INDEX "idx_transactions_store_date" ON "transactions"("store_id", "transaction_date");
CREATE INDEX "idx_transaction_items_transaction" ON "transaction_items"("transaction_id");
CREATE INDEX "idx_transaction_items_product" ON "transaction_items"("product_id");
CREATE INDEX "idx_star_history_customer_date" ON "star_history"("customer_id", "change_date");
CREATE INDEX "idx_tier_history_customer" ON "tier_history"("customer_id");

-- A view of each customer's current redeemable Star balance
CREATE VIEW "customer_star_balances" AS
SELECT "customers"."customer_id",
       "customers"."first_name",
       "customers"."last_name",
       COALESCE(SUM("star_history"."stars_change"), 0) AS "available_stars"
FROM "customers"
LEFT JOIN "star_history"
    ON "customers"."customer_id" = "star_history"."customer_id"
GROUP BY "customers"."customer_id";

-- Automatically upgrading customers to Gold and Reserve
CREATE TRIGGER "upgrade_membership"
AFTER INSERT ON "star_history"
FOR EACH ROW
WHEN NEW."change_type" = 'Earned'
BEGIN
    -- Upgrading customers to Gold
    INSERT INTO "tier_history"
        ("customer_id", "previous_tier_id", "new_tier_id", "stars_at_upgrade")
    SELECT
        NEW."customer_id", 1, 2, SUM("stars_change")
    FROM "star_history"
    WHERE "customer_id" = NEW."customer_id"
    HAVING SUM("stars_change") >= 1000
    AND NOT EXISTS (
        SELECT 1
        FROM "tier_history"
        WHERE "customer_id" = NEW."customer_id"
        AND "new_tier_id" = 2
    );

    -- Upgrading customers to Reserve
    INSERT INTO "tier_history"
        ("customer_id", "previous_tier_id", "new_tier_id", "stars_at_upgrade")
    SELECT
        NEW."customer_id", 2, 3, SUM("stars_change")
    FROM "star_history"
    WHERE "customer_id" = NEW."customer_id"
    HAVING SUM("stars_change") >= 5000
    AND NOT EXISTS (
        SELECT 1
        FROM "tier_history"
        WHERE "customer_id" = NEW."customer_id"
        AND "new_tier_id" = 3
    );
END;


-- Automatically updating inventory after a purchase
CREATE TRIGGER "update_inventory"
AFTER INSERT ON "transaction_items"
FOR EACH ROW
BEGIN
    UPDATE "inventory"
    SET "quantity" = "quantity" - NEW."quantity",
        "last_updated" = CURRENT_TIMESTAMP
    WHERE "product_id" = NEW."product_id"
    AND "store_id" = (
        SELECT "store_id"
        FROM "transactions"
        WHERE "transaction_id" = NEW."transaction_id"
    );
END;


-- Checking inventory before a purchase
CREATE TRIGGER "check_inventory"
BEFORE INSERT ON "transaction_items"
FOR EACH ROW
BEGIN
    SELECT RAISE(ABORT, 'Insufficient inventory')
    WHERE NEW."quantity" <= 0
    OR NOT EXISTS (
        SELECT 1
        FROM "inventory"
        JOIN "transactions"
            ON "inventory"."store_id" = "transactions"."store_id"
        WHERE "transactions"."transaction_id" = NEW."transaction_id"
        AND "inventory"."product_id" = NEW."product_id"
        AND "inventory"."quantity" >= NEW."quantity"
    );
END;


-- Automatically recording Stars earned from purchases
CREATE TRIGGER "earn_stars"
AFTER INSERT ON "transactions"
FOR EACH ROW
WHEN NEW."status" = 'Completed'
AND NEW."stars_earned" > 0
BEGIN
    INSERT INTO "star_history"
        ("customer_id", "transaction_id", "stars_change", "change_type", "description")
    VALUES
        (NEW."customer_id", NEW."transaction_id", NEW."stars_earned", 'Earned', 'Stars earned from purchase');
END;
