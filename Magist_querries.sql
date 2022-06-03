USE `magist`;
-- EXERCISE 11:
-- H  ow many orders are there in the dataset?

SELECT DISTINCT COUNT(*) as Orders_count
FROM orders;
-- ..........................................................................................................................
-- Are orders actually delivered? 

SELECT order_status, count(*) as no_of_orders
FROM orders
GROUP BY order_status;
-- ..........................................................................................................................
-- Is Magist having user growth?

SELECT YEAR(order_purchase_timestamp),
MONTH(order_purchase_timestamp), 
COUNT(*) AS users 
FROM orders
GROUP BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp) 
ORDER BY YEAR(order_purchase_timestamp),MONTH(order_purchase_timestamp);
-- ..........................................................................................................................

-- How many products are there in the products table? 
SELECT COUNT(DISTINCT product_id) AS 'Total Products'
FROM products;
-- ..........................................................................................................................
-- Which are the categories with most products? 
SELECT product_category_name, COUNT(DISTINCT product_id)
FROM products
GROUP BY product_category_name
ORDER BY COUNT(DISTINCT product_id) DESC;
-- ..........................................................................................................................
-- How many of those products were present in actual transactions? 
SELECT COUNT(DISTINCT product_id) as products
FROM order_items;
 -- ..........................................................................................................................
 -- What’s the price for the most expensive and cheapest products? 
 SELECT 
Max(price) AS 'most expensive product',
Min(price) AS 'cheapest product'
FROM order_items;
 -- ..........................................................................................................................
 -- What are the highest and lowest payment values?
 
 SELECT MAX(payment_value) AS highest_payment_value,
MIN(payment_value) AS lowest_payment_value
FROM order_payments;
  -- ..........................................................................................................................

 -- EXERCISE 12
 -- What categories of tech products does Magist have?
 
SELECT DISTINCT( product_category_name) AS Tech_products FROM products WHERE 
product_category_name IN ("audio", "cine_foto","electronicos", "informatica_acessorios" ,"pcs", "relogios_presentes","tablets_impressao_imagem" ,"telefonia");
 -- ..........................................................................................................................
-- How many products of these tech categories have been sold (within the time window of the database snapshot)? 

SELECT COUNT(DISTINCT product_id)
FROM order_items;  #32951


SELECT COUNT(DISTINCT order_items.product_id), products.product_category_name
FROM order_items
	JOIN products
    ON products.product_id = order_items.product_id
WHERE products.product_category_name IN ("audio", "cine_foto", "electronicos", "informatica_acessorios", "pcs", "relogios_presentes", "tablets_impressao_imagem", "telefonica");
-- GROUP BY products.product_category_name; #3093

-- What percentage does that represent from the overall number of products sold? 
SELECT 3093/32951 * 100;
-- so 9.38 % tech products only
 



-- ------------------------------------------------------------------------------------------------------------------------------
-- What’s the average price of the products being sold?
SELECT ROUND(AVG(price)) AS average_price
FROM order_items;
-- GROUP BY product_id;
-- ------------------------------------------------------------------------------------------------------------------------------
-- Are expensive tech products popular? *

SELECT o.review_score,
CASE
    WHEN price < 10 THEN "very cheap"
    WHEN price >= 10 AND price <100 THEN "cheap"
    WHEN price >= 100 AND price <200 THEN "moderate"
    WHEN price >= 200 AND price <300 THEN "expensive"
    WHEN price >=300 AND price <600 THEN "most expensive"
    ELSE "super expensive"
END AS price_analysis
FROM order_items oi
JOIN order_reviews as o
ON oi.order_id = o.order_id
GROUP BY o.review_score
ORDER BY o.review_score DESC;

-- thus most expensive Tech_products are not the popular ones.
-- ---------------------------------------------------------------------------------------------------------------------------------
-- In relation to the sellers:
-- How many months of data are included in the magist database?
SELECT MAX(order_purchase_timestamp)
FROM orders;   #2018-10-17 19:30:18
SELECT MIN(order_purchase_timestamp)
FROM orders;  #2016-09-04 23:15:19

SELECT TIMESTAMPDIFF(MONTH, '2016-09-04', '2018-10-17');
-- ANS: 25
-- ---------------------------------------------------------------------------------------------------------------------------------------
-- How many sellers are there? 
SELECT  COUNT(DISTINCT seller_id) 
FROM sellers;

-- How many Tech sellers are there? 

SELECT COUNT(DISTINCT s.seller_id)
FROM products p 
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN sellers s
ON oi.seller_id = s.seller_id
WHERE product_category_name IN ("audio", "cine_foto","electronicos", "informatica_acessorios" ,"pcs", "relogios_presentes","tablets_impressao_imagem" ,"telefonia");
-- What percentage of overall sellers are Tech sellers?
SELECT (468/3095)*100;  # 15.12%

-- ------------------------------------------------------------------------------------------------------
-- What is the total amount earned by all sellers?

SELECT SUM(price) AS amount_earned
FROM order_items;

-- What is the total amount earned by all Tech sellers?

SELECT SUM(oi.price) AS amount_earned
FROM order_items oi
JOIN products p
ON oi.product_id = p.product_id
WHERE product_category_name IN ("audio", "cine_foto","electronicos", "informatica_acessorios" ,"pcs", "relogios_presentes","tablets_impressao_imagem" ,"telefonia");  #2728741.023
-- ------------------------------------------------------------------------------------------------------------------------------
-- Can you work out the average monthly income of all sellers?
SELECT MAX(order_purchase_timestamp)
FROM orders;   #2018-10-17 19:30:18
SELECT MIN(order_purchase_timestamp)
FROM orders;  #2016-09-04 23:15:19

SELECT TIMESTAMPDIFF(MONTH, '2016-09-04', '2018-10-17');
SELECT SUM(price) AS amount_earned
FROM order_items;  #13591643.701720357

SELECT COUNT(DISTINCT seller_id)
FROM sellers;   #3095

SELECT 13591643.701/ 3095 / 25; 

-- answer : 175.65 

-- Can you work out the average monthly income of Tech sellers?

-- ---------------------------------------------------------------------------------------------------------------------
-- What’s the average time between the order being placed and the product being delivered?

SELECT MAX(order_purchase_timestamp) FROM orders; # 2018-10-17 19:30:18
SELECT Min(order_purchase_timestamp) FROM orders; # 2016-09-04 23:15:19
SELECT TIMESTAMPDIFF( HOUR , '2018-10-17 15:22:46' , '2018-10-17 19:30:18'); # 4

SELECT MAX(order_delivered_customer_date) FROM orders; # 2018-10-17 15:22:46
SELECT Min(order_delivered_customer_date) FROM orders; #2016-10-11 15:46:32
SELECT TIMESTAMPDIFF( HOUR , '2016-09-04 23:15:19' , '2016-10-11 15:46:32'); # 880

SELECT ((880+4)/2);#442
SELECT 442/24; #18 days 

-- ReSELECT AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS AVG_Delivery_Time
FROM orders;

----------------------------------------------------------------------------------------------------
-- How many orders are delivered on time 
SELECT COUNT(order_status) 
FROM orders
WHERE order_status = 'shipped';


 -- orders delivered with a delay?
SELECT COUNT(order_status) 
FROM orders
WHERE order_status = 'shipped' AND order_status != 'delivered';

-- --------------------------------------------------------------------------------------------------------------------------------
-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT  p.product_category_name, o.order_status, 
CASE
    WHEN product_weight_g < 1000 THEN "light"
    WHEN product_weight_g >= 1000 AND product_weight_g <3000 THEN "moderate"
    -- WHEN product_weight_g >= 1000 AND product_weight_g <2000 THEN "big"
    ELSE "big"
END AS weight_analysis
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN orders o
ON oi.order_id = o.order_id
GROUP BY o.order_status, weight_analysis
ORDER BY weight_analysis;





