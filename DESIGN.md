# Design Document

By Veer Sinha

Video overview: <https://youtu.be/hi0bjXFzIZo>

## Scope

The purpose of this database is to manage a Starbucks loyalty program and store management system in India. It keeps track of customers, their purchases, Stars earned through transactions, membership tiers, rewards, products, and inventory at different Starbucks stores.

The database includes:

* Customers who are registered in the Starbucks loyalty program.
* Membership tiers such as Green, Gold, and Reserve.
* Starbucks stores located in different cities in India.
* Products such as coffee, food, merchandise, and coffee beans.
* Customer transactions and the products purchased in each transaction.
* Stars earned by customers and their membership upgrade history.
* Rewards that customers can redeem using their Stars.
* Inventory available at each Starbucks store.

The database does not include employee information, salaries, supplier management, online delivery tracking, or payment card details. It also does not manage the preparation of drinks or food in the stores.

This project uses fictional customer information and sample Starbucks store and product data for demonstration purposes.

## Functional Requirements

This database allows users to:

* Register customers and store their personal information.
* View customers' membership tiers, including Green, Gold, and Reserve.
* Record customer purchases and the products included in each transaction.
* Track Stars earned by customers through purchases.
* Automatically record earned Stars and upgrade customers when they reach the required number of Stars.
* View available rewards and the Stars required to redeem them.
* Manage Starbucks products, including coffee, food, merchandise, and coffee beans.
* Track inventory levels at different Starbucks stores.
* Automatically reduce inventory when products are purchased.
* Prevent purchases when there is insufficient inventory.
* Find the most popular products, highest*spending customers, and stores with the highest sales.

## Representation

The database includes 14 tables, 6 indexes, 1 view and 4 triggers.

### Entities

#### Customers

The `customers` table includes:

* `customer_id`, which specifies the unique ID for the customer as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `first_name`, which specifies the customer's first name as `TEXT`.
* `last_name`, which specifies the customer's last name as `TEXT`.
* `email`, which specifies the customer's email address as `TEXT`. A `UNIQUE` constraint ensures no two customers have the same email address.
* `phone_number`, which specifies the customer's phone number as `TEXT`. A `UNIQUE` constraint prevents duplicate phone numbers.
* `join_date`, which specifies when the customer joined the loyalty program as `TEXT`. The default value is the current date, as denoted by `DEFAULT CURRENT_DATE`.

The `first_name`, `last_name`, and `email` columns are required and therefore have the `NOT NULL` constraint applied. The `join_date` column is also required, while `phone_number` is optional.

#### Membership Tiers

The `membership_tiers` table includes:

* `tier_id`, which specifies the unique ID for the membership tier as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `tier_name`, which specifies the name of the membership tier as `TEXT`. A `UNIQUE` constraint ensures that each tier has a different name.
* `minimum_stars`, which specifies the minimum number of Stars required for the tier as an `INTEGER`.
* `maximum_stars`, which specifies the maximum number of Stars for the tier as an `INTEGER`.
* `description`, which contains additional information about the membership tier as `TEXT`.

The `tier_name` and `minimum_stars` columns have the `NOT NULL` constraint applied. A `CHECK` constraint ensures that `minimum_stars` cannot be negative and that `maximum_stars`, when provided, cannot be smaller than `minimum_stars`. The `maximum_stars` column can be `NULL` for the highest membership tier.

#### Stores

The `stores` table includes:

* `store_id`, which specifies the unique ID for the Starbucks store as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `store_name`, which specifies the name of the store as `TEXT`.
* `city`, which specifies the city where the store is located as `TEXT`.
* `state`, which specifies the state where the store is located as `TEXT`.
* `address`, which specifies the store's address as `TEXT`.
* `postal_code`, which specifies the postal code of the store as `TEXT`.
* `opening_date`, which specifies when the store opened as `TEXT`.
* `store_type`, which specifies the type of Starbucks store as `TEXT`.
* `status`, which specifies whether the store is open, closed, or under renovation as `TEXT`.

The `store_name`, `city`, `state`, `address`, `store_type`, and `status` columns have the `NOT NULL` constraint applied. The `store_type` column defaults to `Regular` and has a `CHECK` constraint allowing only `Regular`, `Reserve`, or `Drive*Thru`. Similarly, the `status` column defaults to `Open` and only allows `Open`, `Closed`, or `Under Renovation`.

#### Products

The `products` table includes:

* `product_id`, which specifies the unique ID for the product as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `product_name`, which specifies the name of the product as `TEXT`.
* `category`, which specifies the product category as `TEXT`.
* `price`, which specifies the price of the product as an `INTEGER`.
* `availability`, which specifies whether the product is available as an `INTEGER`.

All columns are required. The `category` column has a `CHECK` constraint allowing only `Coffee`, `Food`, `Merchandise`, or `Coffee Beans`. The `price` column cannot contain negative values. The `availability` column defaults to `1` and can contain only `0` or `1`, representing unavailable and available products.

#### Coffees

The `coffees` table includes:

* `coffee_id`, which specifies the unique ID for the coffee as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `coffee_name`, which specifies the name of the coffee as `TEXT`.
* `category`, which specifies the type of coffee as `TEXT`.
* `size`, which specifies the size of the coffee as `TEXT`.
* `price`, which specifies the price of the coffee as an `INTEGER`.
* `availability`, which specifies whether the coffee is available as an `INTEGER`.
* `description`, which contains additional information about the coffee as `TEXT`.
* `product_id`, which references the corresponding product in the `products` table as an `INTEGER`.

The `coffee_name`, `category`, `size`, `price`, and `availability` columns are required. The `price` column cannot be negative, while `availability` defaults to `1` and can only contain `0` or `1`. The `product_id` column has `FOREIGN KEY` and `UNIQUE` constraints to connect each coffee to at most one product record. This reference is optional.

#### Food

The `food` table includes:

* `food_id`, which specifies the unique ID for the food item as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `food_name`, which specifies the name of the food item as `TEXT`.
* `category`, which specifies the food category as `TEXT`.
* `price`, which specifies the price of the food item as an `INTEGER`.
* `availability`, which specifies whether the food item is available as an `INTEGER`.
* `description`, which contains additional information about the food item as `TEXT`.
* `product_id`, which references the corresponding product in the `products` table as an `INTEGER`.

The `food_name`, `category`, `price`, and `availability` columns have the `NOT NULL` constraint applied. A `CHECK` constraint prevents negative prices and limits `availability` to `0` or `1`, with a default value of `1`. The optional `product_id` column has `FOREIGN KEY` and `UNIQUE` constraints.

#### Merchandise

The `merchandise` table includes:

* `merchandise_id`, which specifies the unique ID for the merchandise as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `merchandise_name`, which specifies the name of the merchandise as `TEXT`.
* `category`, which specifies the merchandise category as `TEXT`.
* `price`, which specifies the price of the merchandise as an `INTEGER`.
* `material`, which specifies the material used to make the merchandise as `TEXT`.
* `capacity_ml`, which specifies the capacity of the merchandise in millilitres as an `INTEGER`.
* `availability`, which specifies whether the merchandise is available as an `INTEGER`.
* `description`, which contains additional information about the merchandise as `TEXT`.
* `product_id`, which references the corresponding product in the `products` table as an `INTEGER`.

The `merchandise_name`, `category`, `price`, and `availability` columns are required. The `price` column cannot contain negative values, and `capacity_ml`, when provided, must be greater than `0`. The `availability` column defaults to `1` and accepts only `0` or `1`. The optional `product_id` column has `FOREIGN KEY` and `UNIQUE` constraints.

#### Coffee Beans

The `coffee_beans` table includes:

* `bean_id`, which specifies the unique ID for the coffee beans as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `bean_name`, which specifies the name of the coffee beans as `TEXT`.
* `origin`, which specifies where the coffee beans originate as `TEXT`.
* `roast_type`, which specifies the roast level as `TEXT`.
* `weight_grams`, which specifies the weight of the coffee beans in grams as an `INTEGER`.
* `price`, which specifies the price of the coffee beans as an `INTEGER`.
* `availability`, which specifies whether the coffee beans are available as an `INTEGER`.
* `description`, which contains additional information about the coffee beans as `TEXT`.
* `product_id`, which references the corresponding product in the `products` table as an `INTEGER`.

The `bean_name`, `origin`, `roast_type`, `weight_grams`, `price`, and `availability` columns are required. The `roast_type` column has a `CHECK` constraint allowing only `Blonde`, `Medium`, or `Dark`. The `weight_grams` column must be greater than `0`, while `price` cannot be negative. The `availability` column defaults to `1` and accepts only `0` or `1`. The optional `product_id` column has `FOREIGN KEY` and `UNIQUE` constraints.

#### Tier History

The `tier_history` table includes:

* `tier_history_id`, which specifies the unique ID for the membership history record as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `customer_id`, which specifies the customer whose membership changed as an `INTEGER`. This column references the `customers` table using a `FOREIGN KEY`.
* `previous_tier_id`, which specifies the customer's previous membership tier as an `INTEGER`. This column references the `membership_tiers` table using a `FOREIGN KEY`.
* `new_tier_id`, which specifies the customer's new membership tier as an `INTEGER`. This column also references the `membership_tiers` table using a `FOREIGN KEY`.
* `upgrade_date`, which specifies when the membership change occurred as `TEXT`. It defaults to the current timestamp.
* `stars_at_upgrade`, which specifies the number of Stars recorded when the customer was upgraded as an `INTEGER`.

The `customer_id`, `new_tier_id`, `upgrade_date`, and `stars_at_upgrade` columns are required. The `previous_tier_id` column can be `NULL` when there is no previous membership tier. A `CHECK` constraint ensures that `stars_at_upgrade` cannot be negative.

#### Transactions

The `transactions` table includes:

* `transaction_id`, which specifies the unique ID for the transaction as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `customer_id`, which specifies the customer who made the purchase as an `INTEGER`. This column references the `customers` table using a `FOREIGN KEY`.
* `store_id`, which specifies the Starbucks store where the purchase was made as an `INTEGER`. This column references the `stores` table using a `FOREIGN KEY`.
* `transaction_date`, which specifies when the transaction occurred as `TEXT`. It defaults to the current timestamp.
* `total_amount`, which specifies the total purchase amount as an `INTEGER`.
* `stars_earned`, which specifies the number of Stars earned from the transaction as an `INTEGER`.
* `payment_method`, which specifies how the customer paid as `TEXT`.
* `status`, which specifies the status of the transaction as `TEXT`.

All columns are required. The `total_amount` and `stars_earned` columns have `CHECK` constraints preventing negative values. The `stars_earned` column defaults to `0`. The `status` column defaults to `Completed` and accepts only `Completed`, `Cancelled`, or `Refunded`.

#### Transaction Items

The `transaction_items` table includes:

* `item_id`, which specifies the unique ID for the transaction item as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `transaction_id`, which specifies the transaction containing the item as an `INTEGER`. This column references the `transactions` table using a `FOREIGN KEY`.
* `product_id`, which specifies the product purchased as an `INTEGER`. This column references the `products` table using a `FOREIGN KEY`.
* `quantity`, which specifies how many units of the product were purchased as an `INTEGER`.
* `unit_price`, which specifies the price of one unit of the product as an `INTEGER`.
* `subtotal`, which specifies the total price of that transaction item as an `INTEGER`.

All columns are required. The `quantity` column has a `CHECK` constraint requiring values greater than `0`. The `unit_price` and `subtotal` columns cannot contain negative values.

#### Inventory

The `inventory` table includes:

* `inventory_id`, which specifies the unique ID for the inventory record as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `store_id`, which specifies the Starbucks store holding the inventory as an `INTEGER`. This column references the `stores` table using a `FOREIGN KEY`.
* `product_id`, which specifies the product being stocked as an `INTEGER`. This column references the `products` table using a `FOREIGN KEY`.
* `quantity`, which specifies the number of units currently available as an `INTEGER`.
* `minimum_stock`, which specifies the minimum stock level for the product as an `INTEGER`.
* `last_updated`, which specifies when the inventory record was last updated as `TEXT`. It defaults to the current timestamp.

The `store_id`, `product_id`, `quantity`, `minimum_stock`, and `last_updated` columns are required. The `quantity` and `minimum_stock` columns cannot contain negative values and default to `0` and `10`, respectively. A combined `UNIQUE` constraint on `store_id` and `product_id` ensures that each product has only one inventory record per store.

#### Star History

The `star_history` table includes:

* `star_history_id`, which specifies the unique ID for the Star history record as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `customer_id`, which specifies the customer whose Stars changed as an `INTEGER`. This column references the `customers` table using a `FOREIGN KEY`.
* `transaction_id`, which specifies the related transaction as an `INTEGER`. This column references the `transactions` table using a `FOREIGN KEY`.
* `stars_change`, which specifies the number of Stars added or removed as an `INTEGER`. Positive values represent Stars added, while negative values represent Stars removed.
* `change_type`, which specifies the reason for the Star change as `TEXT`.
* `change_date`, which specifies when the Star change occurred as `TEXT`. It defaults to the current timestamp.
* `description`, which contains additional information about the Star change as `TEXT`.

The `customer_id`, `stars_change`, `change_type`, and `change_date` columns are required. The `transaction_id` column is optional because not every Star change is associated with a purchase. A `CHECK` constraint prevents `stars_change` from being `0`. The `change_type` column accepts only `Earned`, `Redeemed`, `Adjusted`, or `Expired`.

#### Rewards

The `rewards` table includes:

* `reward_id`, which specifies the unique ID for the reward as an `INTEGER`. This column has the `PRIMARY KEY` and `AUTOINCREMENT` constraints applied.
* `reward_name`, which specifies the name of the reward as `TEXT`.
* `description`, which contains additional information about the reward as `TEXT`.
* `stars_required`, which specifies the number of Stars needed to redeem the reward as an `INTEGER`.
* `minimum_tier_id`, which specifies the minimum membership tier required to access the reward as an `INTEGER`. This column references the `membership_tiers` table using a `FOREIGN KEY`.
* `availability`, which specifies whether the reward is available as an `INTEGER`.
* `reward_type`, which specifies the category of the reward as `TEXT`.

The `reward_name`, `stars_required`, `minimum_tier_id`, `availability`, and `reward_type` columns are required. The `stars_required` column must be greater than `0`. The `availability` column defaults to `1` and accepts only `0` or `1`. The `reward_type` column has a `CHECK` constraint allowing only `Free Drink`, `Free Food`, `Discount`, `Merchandise`, or `Other`.

### Relationships

The below entity relationship diagram describes the relationships among the entities in the database.

![ER Diagram](diagram.png)

As detailed by the diagram:

* One customer is capable of making 0 to many transactions. 0, if they have not purchased anything, and many if they make multiple purchases. A transaction is made by one and only one customer.

* One Starbucks store is capable of having 0 to many transactions. 0, if no purchases have been made at that store, and many if customers make multiple purchases. A transaction takes place at one and only one store.

* One transaction is capable of containing 0 to many transaction items. 0, if no products have been added to the transaction, and many if multiple products are purchased. A transaction item belongs to one and only one transaction.

* One product is capable of appearing in 0 to many transaction items. 0, if the product has never been purchased, and many if it has been purchased multiple times. A transaction item is associated with one and only one product.

* One product can be associated with 0 or 1 record in the coffees, food, merchandise, or coffee_beans tables. These tables store additional information about different types of products. Each category-specific record can be associated with 0 or 1 product.

* One Starbucks store is capable of having 0 to many inventory records. 0, if no products have been added to its inventory, and many if the store stocks multiple products. Each inventory record belongs to one and only one store.

* One product is capable of appearing in 0 to many inventory records. 0, if the product is not stocked at any store, and many if it is available at multiple stores. Each inventory record is associated with one and only one product.

* One customer is capable of having 0 to many Star history records. 0, if the customer has not earned or used any Stars, and many if their Stars change multiple times. Each Star history record belongs to one and only one customer.

* One transaction can be associated with 0 to many Star history records. 0, if no Star changes are recorded for that transaction, and many if multiple Star changes are recorded. A Star history record can be associated with 0 or 1 transaction because some changes may happen without a purchase.

* vOne customer is capable of having 0 to many tier history records. 0, if no membership history has been recorded, and many if their membership changes multiple times. Each tier history record belongs to one and only one customer.

* One membership tier is capable of appearing in 0 to many tier history records. Each tier history record must reference one new membership tier and may also reference one previous membership tier.

* One membership tier is capable of being the minimum required tier for 0 to many rewards. 0, if no rewards require that tier, and many if multiple rewards require it. Each reward is associated with one and only one minimum membership tier.

## Optimizations

* Per the typical queries in `queries.sql`, it is common for users of the database to view all transactions made by a particular customer. For that reason, an index is created on the `customer_id` column in the `transactions` table to speed up the identification of transactions belonging to a customer.

* Similarly, it is common for users to view transactions made at a particular Starbucks store and on different dates. As such, an index is created on the `store_id` and `transaction_date` columns in the `transactions` table to make searching for store transactions more efficient.

* It is also common for users to view all products purchased in a particular transaction. For that reason, an index is created on the `transaction_id` column in the `transaction_items` table to speed up the identification of products belonging to a transaction.

* Users may want to identify the most popular Starbucks products based on how many times they have been purchased. As such, an index is created on the `product_id` column in the `transaction_items` table to improve queries involving individual products.

* It is also common for users to check the Stars earned or used by a particular customer. For that reason, an index is created on the `customer_id` and `change_date` columns in the `star_history` table to make accessing customer Star history more efficient.

* Users may want to view the membership upgrade history of a particular customer. As such, an index is created on the `customer_id` column in the `tier_history` table to speed up the identification of membership changes.

* A view called `customer_star_balances` is created to calculate the current available Stars of each customer. This allows users to check Star balances without repeatedly writing queries to calculate them.

* The database also includes four triggers to automate certain operations. The `earn_stars` trigger records Stars earned from completed transactions, while the `upgrade_membership` trigger upgrades customers when they reach the required number of Stars. Similarly, the `update_inventory` trigger reduces inventory when products are purchased, and the `check_inventory` trigger prevents transaction items from being added when there is insufficient stock.

## Limitations

This database is designed to manage Starbucks customers, purchases, membership tiers, rewards, products, and inventory. It does not include employee records, salaries, suppliers, or delivery tracking.

The database records the payment method and total amount of each purchase, but it cannot process real payments or connect to banking systems.

Customers can earn Stars from completed purchases. However, the number of Stars earned must be entered when adding a transaction. The database does not calculate this amount automatically.

The database also stores rewards and customer Star balances, but it cannot automatically redeem rewards or deduct the required Stars. These changes must be added separately to the `star_history` table.

Stock levels decrease automatically when products are purchased, but the database cannot order new stock or restock products on its own.

All customer information and transaction records are fictional. The stores and products are also sample data, so this database does not represent the actual operations or loyalty program of Starbucks India.
