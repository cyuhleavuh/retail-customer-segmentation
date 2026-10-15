-- Q2: How did monthly revenue change versus the same month last year?

WITH monthly AS (
	SELECT
		YearMonth
		, ROUND(SUM(Revenue), 2) AS revenue
	FROM cln_sales
	GROUP BY YearMonth
),
with_last_year AS (
	SELECT
		YearMonth
		, revenue
		, LAG(revenue, 12) OVER (ORDER BY YearMonth) AS revenue_last_year
	FROM monthly
)
SELECT
	YearMonth
	, revenue
	, revenue_last_year
	, ROUND((revenue - revenue_last_year) / revenue_last_year * 100, 1) AS yoy_change_pct
FROM with_last_year
ORDER BY YearMonth
;
/*
RESULT:
YearMonth |    revenue | revenue_last_year | yoy_change_pct
----------+------------+-------------------+---------------
2009-12   |  797901.16 |              NULL |           NULL
2010-01   |  612297.42 |              NULL |           NULL
2010-02   |  537909.68 |              NULL |           NULL
2010-03   |  761705.98 |              NULL |           NULL
2010-04   |  646340.93 |              NULL |           NULL
2010-05   |  643492.03 |              NULL |           NULL
2010-06   |  696583.19 |              NULL |           NULL
2010-07   |  632994.32 |              NULL |           NULL
2010-08   |  674037.72 |              NULL |           NULL
2010-09   |  869243.12 |              NULL |           NULL
2010-10   | 1094435.98 |              NULL |           NULL
2010-11   | 1429700.78 |              NULL |           NULL
2010-12   |  775638.36 |         797901.16 |           -2.8
2011-01   |  593196.64 |         612297.42 |           -3.1
2011-02   |  507799.87 |         537909.68 |           -5.6
2011-03   |  689833.51 |         761705.98 |           -9.4
2011-04   |  515377.99 |         646340.93 |          -20.3
2011-05   |  739953.00 |         643492.03 |           15.0
2011-06   |  698588.98 |         696583.19 |            0.3
2011-07   |  688219.34 |         632994.32 |            8.7
2011-08   |  724216.50 |         674037.72 |            7.4
2011-09   | 1028320.38 |         869243.12 |           18.3
2011-10   | 1103314.25 |        1094435.98 |            0.8
2011-11   | 1452115.98 |        1429700.78 |            1.6
2011-12   |  446021.32 |         775638.36 |          -42.5
*/

-- Supporting query: revenue by period, 2010 vs. 2011

WITH by_period AS (
	SELECT 'Jan–Apr' AS period, 1 AS sort_order, Year, Revenue
	FROM cln_sales WHERE Month BETWEEN 1 AND 4
	UNION ALL
	SELECT 'May–Nov', 2, Year, Revenue
	FROM cln_sales WHERE Month BETWEEN 5 AND 11
	UNION ALL
	SELECT 'Sep–Nov', 3, Year, Revenue
	FROM cln_sales WHERE Month BETWEEN 9 AND 11
	UNION ALL
	SELECT 'Apr–May', 4, Year, Revenue
	FROM cln_sales WHERE Month IN (4, 5)
),
totals AS (
	SELECT
		period
		, sort_order
		, SUM(CASE WHEN Year = 2010 THEN Revenue END) AS rev_2010
		, SUM(CASE WHEN Year = 2011 THEN Revenue END) AS rev_2011
	FROM by_period
	GROUP BY period, sort_order
)
SELECT
	period
	, ROUND(rev_2010, 2) AS rev_2010
	, ROUND(rev_2011, 2) AS rev_2011
	, ROUND((rev_2011 - rev_2010) * 100.0 / rev_2010, 1) AS change_pct
FROM totals
ORDER BY sort_order
;
/*
RESULT:
period  |   rev_2010 |   rev_2011 | change_pct
--------+------------+------------+-----------
Jan–Apr | 2558254.01 | 2306208.01 |       -9.9
May–Nov | 6040487.14 | 6434728.43 |        6.5
Sep–Nov | 3393379.88 | 3583750.61 |        5.6
Apr–May | 1289832.96 | 1255330.99 |       -2.7
*/

/*
FINDINGS
- Revenue fell 9.9% YoY in Jan–Apr 2011, then grew 6.5% in May–Nov 2011.
- The Sep–Nov peak season grew 5.6%; November is the top month in both years.
- April's -20.3% was mostly offset by May's +15.0% (combined -2.7%), suggesting a
  timing shift, possibly from Easter falling later in 2011 (Apr 24 vs. Apr 4).

NOTES
- Dec 2011 covers Dec 1–9 only, so its -42.5% is not a valid comparison.
- Dec 2009–Nov 2010 have no prior year, so their YoY values are NULL.
- LAG(revenue, 12) assumes one row per month with no gaps; all 25 months are present.
*/
