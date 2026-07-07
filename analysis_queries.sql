-- ============================================================
-- Olist E-Commerce SQL Analysis Queries
-- Dataset: Brazilian E-Commerce Public Dataset by Olist (Kaggle)
-- Tool: MySQL Workbench (MySQL 8.0)
-- ============================================================

USE olist_ecommerce;

-- ============================================================
-- Query 1: Monthly Revenue, Orders, and Average Order Value
-- Business Question: How is the business performing month over month?
-- Tables: orders, order_payments
-- Concepts: DATE_FORMAT, JOIN, GROUP BY, aggregate functions
-- ============================================================

SELECT 
    DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(op.payment_value) AS total_revenue,
    SUM(op.payment_value) / COUNT(DISTINCT o.order_id) AS avg_order_value
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
GROUP BY order_month
ORDER BY order_month;


-- ============================================================
-- Query 2: Top 10 Product Categories by Revenue
-- Business Question: Which product categories drive the most revenue?
-- Tables: order_items, products, product_category_name_translation
-- Concepts: LEFT JOIN, COALESCE (NULL handling), GROUP BY, ORDER BY, LIMIT
-- ============================================================

SELECT 
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    SUM(oi.price) AS total_revenue
FROM order_items oi
LEFT JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================
-- Query 3: Delivery Performance — On Time vs Late vs Not Delivered
-- Business Question: What percentage of orders are delivered on time?
-- Tables: orders
-- Concepts: CASE statement, NULL handling, subquery for percentage calculation
-- ============================================================

SELECT 
    CASE 
        WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    COUNT(*) AS order_count,
    COUNT(*) * 100.0 / (SELECT COUNT(*) FROM orders) AS percentage
FROM orders
GROUP BY delivery_status
ORDER BY order_count DESC;


-- ============================================================
-- Query 4: Top 3 Sellers by Revenue per State
-- Business Question: Who are the top-performing sellers in each Brazilian state?
-- Tables: order_items, sellers
-- Concepts: CTE, window function (RANK + PARTITION BY), filtering on window result
-- ============================================================

WITH seller_totals AS (
    SELECT 
        s.seller_id,
        s.seller_state,
        SUM(oi.price) AS seller_revenue
    FROM order_items oi
    JOIN sellers s ON oi.seller_id = s.seller_id
    GROUP BY s.seller_id, s.seller_state
),
ranked_sellers AS (
    SELECT 
        seller_id,
        seller_state,
        seller_revenue,
        RANK() OVER (PARTITION BY seller_state ORDER BY seller_revenue DESC) AS state_rank
    FROM seller_totals
)
SELECT *
FROM ranked_sellers
WHERE state_rank <= 3
ORDER BY seller_state, state_rank;


-- ============================================================
-- Query 5: Customer Order History — First Order, Most Recent Order, Total Orders
-- Business Question: What does each customer's order history look like?
-- Tables: orders
-- Concepts: MIN, MAX, COUNT, GROUP BY
-- Note: Most customers placed only 1 order — low repeat purchase rate
-- ============================================================

SELECT 
    customer_id,
    MIN(order_purchase_timestamp) AS first_order,
    MAX(order_purchase_timestamp) AS most_recent_order,
    COUNT(order_id) AS total_orders
FROM orders
GROUP BY customer_id
ORDER BY total_orders DESC;


-- ============================================================
-- Query 6: Month-over-Month Revenue Change
-- Business Question: How does this month's revenue compare to last month's?
-- Tables: orders, order_payments
-- Concepts: CTE, window function (LAG), month-over-month calculation
-- ============================================================

WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m') AS order_month,
        SUM(op.payment_value) AS total_revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    GROUP BY order_month
)
SELECT 
    order_month,
    total_revenue,
    LAG(total_revenue) OVER (ORDER BY order_month) AS prev_month_revenue,
    total_revenue - LAG(total_revenue) OVER (ORDER BY order_month) AS mom_change
FROM monthly_revenue
ORDER BY order_month;


-- ============================================================
-- Query 7: Average Review Score by Product Category
-- Business Question: Which product categories have the highest and lowest customer satisfaction?
-- Tables: order_reviews, orders, order_items, products, product_category_name_translation
-- Concepts: multiple JOINs, LEFT JOIN, COALESCE, AVG, GROUP BY, ORDER BY
-- ============================================================

WITH category_reviews AS (
    SELECT 
        COALESCE(t.product_category_name_english, p.product_category_name) AS category,
        ROUND(AVG(r.review_score), 2) AS avg_review_score,
        COUNT(r.review_id) AS total_reviews
    FROM order_reviews r
    JOIN orders o ON r.order_id = o.order_id
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    LEFT JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
    GROUP BY category
)
SELECT *
FROM category_reviews
ORDER BY avg_review_score DESC;


-- ============================================================
-- Query 8: Delivery Delay Impact on Review Scores
-- Business Question: Do late deliveries actually result in lower review scores?
-- Tables: orders, order_reviews
-- Concepts: CASE statement, JOIN, AVG, GROUP BY
-- ============================================================

SELECT 
    CASE 
        WHEN order_delivered_customer_date IS NULL THEN 'Not Delivered'
        WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 'Late'
        ELSE 'On Time'
    END AS delivery_status,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
GROUP BY delivery_status
ORDER BY avg_review_score DESC;


-- ============================================================
-- Query 9: Top 10 Sellers by Revenue with Average Review Score
-- Business Question: Among highest-revenue sellers, who also maintains strong customer satisfaction?
-- Tables: order_items, sellers, order_reviews
-- Concepts: multiple JOINs, CTE, aggregate functions, ORDER BY, LIMIT
-- ============================================================

WITH seller_metrics AS (
    SELECT 
        oi.seller_id,
        s.seller_state,
        SUM(oi.price) AS total_revenue,
        ROUND(AVG(r.review_score), 2) AS avg_review_score,
        COUNT(DISTINCT oi.order_id) AS total_orders
    FROM order_items oi
    JOIN sellers s ON oi.seller_id = s.seller_id
    JOIN order_reviews r ON oi.order_id = r.order_id
    GROUP BY oi.seller_id, s.seller_state
)
SELECT *
FROM seller_metrics
ORDER BY total_revenue DESC
LIMIT 10;
