-- Q7: How many customers and how much revenue sit in each segment (Champions, Loyal, New, Needs Attention, At Risk, Lost)?

DROP VIEW IF EXISTS customer_segments;

-- Assigning segmentation to each customerID
CREATE VIEW customer_segments AS
SELECT
	CustomerID
	, recency_days
	, frequency
	, monetary
	, r_score
	, f_score
	, m_score
	, CASE 
		WHEN r_score >= 4 AND f_score >= 4 THEN 'Champions'
		WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal'
		WHEN r_score >= 4 AND f_score <= 2 THEN 'New'
		WHEN r_score = 3 AND f_score <= 2 THEN 'Needs Attention'
		WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
		WHEN r_score <= 2 AND f_score <= 2 THEN 'Lost'
	END AS segment
FROM customer_scores 
;
-- Checking for nulls(indicating gaps in segmentation)
-- SELECT * 
-- FROM customer_segments
-- WHERE segment IS NULL
-- ;
-- Result: no nulls (commented out as it performed successfully)

-- Previewing one customer per segment
SELECT *
FROM customer_segments
WHERE CustomerID in (
	SELECT MIN(CustomerID) FROM customer_segments GROUP BY segment
	)
ORDER BY segment
;
/*
RESULT:
CustomerID | recency_days | frequency | monetary | r_score | f_score | m_score | segment
-----------+--------------+-----------+----------+---------+---------+---------+----------------
12355      |          215 |         2 |   947.61 |       2 |       3 |       3 | At Risk
12347      |            3 |         8 |  4921.53 |       5 |       5 |       5 | Champions
12346      |          530 |         2 |   169.36 |       1 |       2 |       1 | Lost
12348      |           76 |         5 |  1658.40 |       3 |       4 |       4 | Loyal
12363      |          110 |         2 |   552.00 |       3 |       2 |       2 | Needs Attention
12367      |            5 |         1 |   150.90 |       5 |       1 |       1 | New
*/


-- n_customers, revenue, share columns, avgs per segment
SELECT 
	segment
	, COUNT(*) as n_customers
	, ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) as pct_customers
	, ROUND(SUM(monetary), 2) as revenue
	, ROUND(SUM(monetary) * 100.0 / SUM(SUM(monetary)) OVER(), 1) as pct_revenue
	, ROUND(AVG(monetary), 2) as avg_spend
	, ROUND(AVG(frequency), 1) as avg_orders
	, ROUND(AVG(recency_days),0) as avg_recency_days
FROM customer_segments
GROUP BY segment
ORDER BY revenue DESC
;
/*
RESULT (summary):
segment         | n_customers | pct_customers |     revenue | pct_revenue | avg_spend | avg_orders | avg_recency_days
----------------+-------------+---------------+-------------+-------------+-----------+------------+-----------------
Champions       |        1476 |          25.2 | 11883670.82 |        70.8 |   8051.27 |       15.5 |             21.0
Loyal           |        1219 |          20.8 |  2428035.61 |        14.5 |   1991.83 |        5.3 |             78.0
At Risk         |         815 |          13.9 |  1602491.28 |         9.5 |   1966.25 |        5.0 |            367.0
Lost            |        1527 |          26.1 |   536517.85 |         3.2 |    351.35 |        1.3 |            457.0
New             |         436 |           7.5 |   170005.89 |         1.0 |    389.92 |        1.5 |             28.0
Needs Attention |         379 |           6.5 |   163238.08 |         1.0 |    430.71 |        1.3 |            108.0


FINDINGS
- Champions are 25.2% of customers but generate 70.8% of revenue (£11.9M),
  averaging £8,051 and 15.5 orders each.
- At Risk customers (815) spent almost as much as Loyal customers (£1,966 vs.
  £1,992 on average) but haven't ordered in about a year: £1.6M in past revenue
  that a win-back campaign could target.
- Lost is the largest segment (26.1% of customers) but only 3.2% of revenue.
- New and Needs Attention customers are mostly one-time buyers; the opportunity
  is converting them to a second order.

NOTES
- Segments use recency and frequency scores only; spend tends to follow
  frequency and is shown in the results rather than used in the rules.
- Segment rules are a common RFM convention, not tuned to this business.
- Customers with 2 orders straddle the F=2/F=3 boundary (ties broken by spend),
  so At Risk and Loyal can include 2-order customers who spent more.
*/
