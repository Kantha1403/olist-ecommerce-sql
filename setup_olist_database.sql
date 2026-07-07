-- ============================================================
-- Olist E-Commerce Database Setup Script
-- ============================================================
-- Note: Before running, copy olist_orders_dataset_fixed.csv into
-- the same folder as the other Olist CSVs (it has corrected
-- YYYY-MM-DD dates and no trailing empty columns, fixing an
-- Excel auto-formatting issue in the original orders CSV).
--
-- Adjust the file paths below to match your own folder location.
-- ============================================================

CREATE DATABASE olist_ecommerce;
USE olist_ecommerce;

-- ============================================================
-- 1. CREATE TABLES (in dependency order)
-- ============================================================

CREATE TABLE customers (
	customer_id varchar(50) PRIMARY KEY,
	customer_unique_id varchar(50),
	customer_zip_code_prefix varchar(10),
	customer_city varchar(100),
	customer_state varchar(5)
);

CREATE TABLE sellers (
	seller_id varchar(50) PRIMARY KEY,
	seller_zip_code_prefix varchar(10),
	seller_city varchar(100),
	seller_state varchar(5)
);

CREATE TABLE product_category_name_translation (
	product_category_name varchar(100) PRIMARY KEY,
	product_category_name_english varchar(100)
);

CREATE TABLE products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category_name varchar(100),
	product_name_length INT,
	product_description_length INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

CREATE TABLE geolocation (
	geolocation_zip_code_prefix varchar(10),
	geolocation_lat DECIMAL(10,8),
	geolocation_lng DECIMAL(11,8),
	geolocation_city varchar(100),
	geolocation_state varchar(5)
);

CREATE TABLE orders (
	order_id varchar(50) PRIMARY KEY,
	customer_id varchar(50),
	order_status varchar(20),
	order_purchase_timestamp DATETIME,
	order_approved_at DATETIME,
	order_delivered_carrier_date DATETIME,
	order_delivered_customer_date DATETIME,
	order_estimated_delivery_date DATETIME,
	FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
	order_id varchar(50),
	order_item_id INT,
	product_id varchar(50),
	seller_id varchar(50),
	shipping_limit_date DATETIME,
	price DECIMAL(10,2),
	freight_value DECIMAL(10,2),
	PRIMARY KEY (order_id, order_item_id),
	FOREIGN KEY (order_id) REFERENCES orders(order_id),
	FOREIGN KEY (product_id) REFERENCES products(product_id),
	FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_payments (
	order_id varchar(50),
	payment_sequential INT,
	payment_type varchar(20),
	payment_installments INT,
	payment_value DECIMAL(10,2),
	PRIMARY KEY (order_id, payment_sequential),
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE order_reviews (
	review_id varchar(50),
	order_id varchar(50),
	review_score INT,
	review_comment_title varchar(255),
	review_comment_message TEXT,
	review_creation_date DATETIME,
	review_answer_timestamp DATETIME,
	PRIMARY KEY (review_id, order_id),
	FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- ============================================================
-- 2. ENABLE LOCAL FILE LOADING (run once per MySQL session/server)
-- ============================================================
SET GLOBAL local_infile = 1;

-- ============================================================
-- 3. LOAD DATA (in dependency order: parents before children)
-- ============================================================

-- customers
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_customers_dataset.csv'
INTO TABLE customers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state);

-- sellers
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_sellers_dataset.csv'
INTO TABLE sellers
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(seller_id, seller_zip_code_prefix, seller_city, seller_state);

-- product_category_name_translation
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/product_category_name_translation.csv'
INTO TABLE product_category_name_translation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_category_name, product_category_name_english);

-- products
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_products_dataset.csv'
INTO TABLE products
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(product_id, product_category_name, product_name_length, product_description_length,
 product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm);

-- geolocation
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_geolocation_dataset.csv'
INTO TABLE geolocation
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(geolocation_zip_code_prefix, geolocation_lat, geolocation_lng, geolocation_city, geolocation_state);

-- orders (uses the corrected CSV — fixed dates + removed trailing empty columns)
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_orders_dataset_fixed.csv'
INTO TABLE orders
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at,
 order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date);

-- Clean up zero-dates ('0000-00-00 00:00:00') produced by blank CSV fields
-- on orders that never shipped/delivered (cancelled, unavailable, etc.)
UPDATE orders SET order_approved_at = NULL WHERE order_approved_at = 0;
UPDATE orders SET order_delivered_carrier_date = NULL WHERE order_delivered_carrier_date = 0;
UPDATE orders SET order_delivered_customer_date = NULL WHERE order_delivered_customer_date = 0;

-- order_items
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_order_items_dataset.csv'
INTO TABLE order_items
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value);

-- order_payments
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_order_payments_dataset.csv'
INTO TABLE order_payments
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(order_id, payment_sequential, payment_type, payment_installments, payment_value);

-- order_reviews
LOAD DATA LOCAL INFILE 'C:/Users/KL/Downloads/archive (3)/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(review_id, order_id, review_score, review_comment_title, review_comment_message,
 review_creation_date, review_answer_timestamp);

-- ============================================================
-- 4. FINAL VERIFICATION
-- ============================================================
-- Expected counts:
-- customers ~99441 | sellers ~3095 | product_category_name_translation ~71
-- products ~32951 | geolocation ~1000163 | orders ~99441
-- order_items ~112650 | order_payments ~103886 | order_reviews ~99223 (1 dup id in source data)

SELECT 'customers' AS table_name, COUNT(*) AS row_count FROM customers
UNION ALL SELECT 'sellers', COUNT(*) FROM sellers
UNION ALL SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'geolocation', COUNT(*) FROM geolocation
UNION ALL SELECT 'orders', COUNT(*) FROM orders
UNION ALL SELECT 'order_items', COUNT(*) FROM order_items
UNION ALL SELECT 'order_payments', COUNT(*) FROM order_payments
UNION ALL SELECT 'order_reviews', COUNT(*) FROM order_reviews;
