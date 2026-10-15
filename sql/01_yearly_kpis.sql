-- Q1: What are total revenue, orders and average order value by year?

SELECT
	Year
	, ROUND(SUM(Revenue), 2)                           AS total_revenue
	, COUNT(DISTINCT Invoice)                          AS total_orders
	, ROUND(SUM(Revenue) / COUNT(DISTINCT Invoice), 2) AS AOV
FROM cln_sales
GROUP BY Year
ORDER BY Year
;
/*
RESULT:
Year | total_revenue | total_orders |    AOV
-----+---------------+--------------+-------
2009 |     797901.16 |         1666 | 478.93
2010 |    9374379.51 |        19627 | 477.63
2011 |    9186957.76 |        18220 | 504.22
*/

/*
FINDINGS
- In each full year, the business earned about £9.2–9.4M from 18,000–20,000 orders,
  averaging £478–£504 per order.
- Revenue held steady from 2010 to 2011 even though orders fell from 19,627 to
  18,220, because average order value rose from £477.63 to £504.22.

NOTES
- 2009 covers December only; 2011 ends on December 9.
*/