-- Q4: How do orders with and without a Customer ID compare?

WITH orders AS (
	SELECT 
		Invoice
		, CASE WHEN CustomerID IS NULL THEN 'Guest' ELSE 'Known' END AS customer_type
		, SUM(Revenue) AS order_revenue
		, SUM(Quantity) AS order_units
		, COUNT(DISTINCT StockCode) AS order_products
	FROM cln_sales
	GROUP BY Invoice, customer_type
	)
SELECT 
	customer_type
	, COUNT(*) AS orders
	, ROUND(COUNT(*) * 100.00 / SUM(COUNT(*)) OVER(), 1) AS pct_orders
	, ROUND(SUM(order_revenue), 2) AS revenue
	, ROUND(SUM(order_revenue) * 100.00 / SUM(SUM(order_revenue)) OVER(), 1) AS pct_revenue
	, ROUND(AVG(order_revenue), 2) AS avg_order_value
	, ROUND(AVG(order_units), 1) AS avg_units
	, ROUND(AVG(order_products), 1) AS avg_products
FROM orders
GROUP BY customer_type
;

/*
RESULT:
customer_type | orders | pct_orders |     revenue | pct_revenue | avg_order_value | avg_units | avg_products
--------------+--------+------------+-------------+-------------+-----------------+-----------+-------------
Guest         |   2922 |        7.4 |  2575278.90 |        13.3 |          881.34 |     235.9 |         77.3
Known         |  36591 |       92.6 | 16783959.54 |        86.7 |          458.69 |     282.7 |         20.9


FINDINGS
- Known customers placed 92.6% of orders and earned 86.7% of revenue.
- Guest orders are fewer (7.4%) but larger: £881 on average vs. £459, with
  77 distinct products per order vs. 21, despite slightly fewer units (236 vs. 283).

NOTES
- Guest orders' many-products, few-units pattern suggests a different kind of
  transaction, but the data can't confirm the cause.
- Averages can be pulled up by a few very large orders.
- Only known-customer orders (86.7% of revenue) can be segmented with RFM in Q5-Q7.
*/