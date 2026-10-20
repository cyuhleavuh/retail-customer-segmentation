-- Q5: For each customer: days since last order, number of orders, total spend?

DROP VIEW IF EXISTS customer_rfm;

CREATE VIEW customer_rfm AS
WITH snapshot AS (
	SELECT DATE(MAX(InvoiceDate), '+1 day') AS snapshot_date
	FROM cln_sales
)
SELECT
	CustomerID
	, CAST(julianday((SELECT snapshot_date FROM snapshot))
		- julianday(DATE(MAX(InvoiceDate))) AS INTEGER) AS recency_days
	, COUNT(DISTINCT Invoice)                          AS frequency
	, SUM(Revenue)                                     AS monetary
FROM cln_sales
WHERE CustomerID IS NOT NULL
GROUP BY CustomerID
;

-- Preview: sample rows
SELECT CustomerID, recency_days, frequency, ROUND(monetary, 2) AS monetary
FROM customer_rfm
ORDER BY CustomerID
LIMIT 5
  ;
/*
CustomerID | recency_days | frequency | monetary
-----------+--------------+-----------+---------
12346      |          530 |         2 |   169.36
12347      |            3 |         8 |  4921.53
12348      |           76 |         5 |  1658.40
12349      |           19 |         3 |  3678.69
12350      |          311 |         1 |   294.40
*/

-- Sanity check
SELECT
	COUNT(*)                                         AS customer_rows
	, COUNT(DISTINCT CustomerID)                     AS unique_customers
	, MIN(recency_days)                              AS min_recency
	, MAX(recency_days)                              AS max_recency
	, ROUND(SUM(monetary), 2)                        AS total_monetary
	, SUM(CASE WHEN monetary <= 0 THEN 1 ELSE 0 END) AS zero_or_negative
FROM customer_rfm
;
/*
customer_rows | unique_customers | min_recency | max_recency | total_monetary | zero_or_negative
--------------+------------------+-------------+-------------+----------------+-----------------
         5852 |             5852 |           1 |         739 |    16783959.54 |                0
*/


/*
CHECKS
- One row per customer (5,852 rows, 5,852 unique IDs).
- Recency ranges from 1 to 739 days, matching the Dec 2009–Dec 2011 date range.
- Total spend equals known-customer revenue in Q4 (£16,783,959.54).
- No customer has zero or negative spend.

NOTES
- Recency is measured from 2011-12-10, the day after the last order in the data.
- Saved as the view `customer_rfm`, which Q6 builds on.
*/

