-- Q1: What are total revenue, orders and average order value by year?

SELECT 
	Year,
	ROUND(SUM(Revenue), 2) AS 'total_revenue',
	COUNT(DISTINCT(Invoice)) AS 'total_orders',
	ROUND(SUM(Revenue) / COUNT(DISTINCT(Invoice)), 2) AS 'AOV'
FROM cln_sales 
GROUP BY Year
ORDER BY Year
;

/*
Result:
Year	total_revenue	total_orders	AOV
2009	797901.16	1666	478.93
2010	9374379.51	19627	477.63
2011	9186957.76	18220	504.22

Finding:
- 2009 covers December only, so it isn't comparable to the full years.
- From 2010 to 2011, revenue held nearly steady (down 2.0%) even though orders fell 7.2%, because the average order value rose 5.6%, from £477.63 to £504.22.
- 2011 data isn't complete(ends on December 9th, likely excludes holiday season), which could explain the slight dip.
*/


