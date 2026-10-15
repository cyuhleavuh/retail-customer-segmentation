-- Q0: Do the totals in retail.db match the prior Python analysis of this data?
-- Expected: £19,359,238.44 revenue and 39,513 orders, from the earlier pandas
-- analysis of the same cleaned data (see README).

SELECT
	ROUND(SUM(Revenue), 2)  AS total_revenue
	, COUNT(DISTINCT Invoice) AS total_orders
FROM cln_sales;

/*
RESULT:
total_revenue | total_orders
--------------+-------------
  19359238.44 |        39513

FINDINGS
- Both totals match the prior analysis exactly, confirming the data loaded into
  SQLite without loss or duplication.

NOTES
- Revenue is gross sales: cancelled and returned orders are tracked separately
  in `cncld` and are not subtracted here.
*/