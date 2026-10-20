-- Q6: How does each customer score from 1–5 on recency, frequency and spend?

DROP VIEW IF EXISTS customer_scores;

CREATE VIEW customer_scores AS
SELECT
	CustomerID
	, recency_days
	, frequency
	, monetary
	, NTILE(5) OVER (ORDER BY recency_days DESC, frequency) AS r_score
	, NTILE(5) OVER (ORDER BY frequency, monetary)          AS f_score
	, NTILE(5) OVER (ORDER BY monetary)                     AS m_score
FROM customer_rfm;

-- Spot check: the highest-spending customer (18102, top of Q5 by monetary)
-- and the first customer in Q5's sample (12346, a lapsed low spender)
SELECT *
FROM customer_scores
WHERE CustomerID IN (18102, 12346);

-- Check query: size and range of each score group
SELECT
	'Recency'           AS measure
	, r_score           AS score
	, COUNT(*)          AS customers
	, MIN(recency_days) AS min_value
	, MAX(recency_days) AS max_value
FROM customer_scores
GROUP BY r_score

UNION ALL

SELECT
	'Frequency'                AS measure
	, f_score                  AS score
	, COUNT(*)                 AS customers
	, MIN(frequency)           AS min_value
	, MAX(frequency)           AS max_value
FROM customer_scores
GROUP BY f_score

UNION ALL

SELECT
	'Monetary'                 AS measure
	, m_score                  AS score
	, COUNT(*)                 AS customers
	, ROUND(MIN(monetary), 2)  AS min_value
	, ROUND(MAX(monetary), 2)  AS max_value
FROM customer_scores
GROUP BY m_score
;

/*
RESULT (spot check):
CustomerID | recency_days | frequency |  monetary | r_score | f_score | m_score
-----------+--------------+-----------+-----------+---------+---------+--------
12346      |          530 |         2 |    169.36 |       1 |       2 |       1
18102      |            1 |       145 | 580987.04 |       5 |       5 |       5

RESULT (check query):
measure   | score | customers | min_value | max_value
----------+-------+-----------+-----------+----------
Recency   |     1 |      1171 |       409 |       739
Recency   |     2 |      1171 |       187 |       409
Recency   |     3 |      1170 |        59 |       187
Recency   |     4 |      1170 |        20 |        59
Recency   |     5 |      1170 |         1 |        20
Frequency |     1 |      1171 |         1 |         1
Frequency |     2 |      1171 |         1 |         2
Frequency |     3 |      1170 |         2 |         4
Frequency |     4 |      1170 |         4 |         8
Frequency |     5 |      1170 |         8 |       373
Monetary  |     1 |      1171 |      2.90 |    284.50
Monetary  |     2 |      1171 |    284.55 |    603.25
Monetary  |     3 |      1170 |    603.42 |   1201.21
Monetary  |     4 |      1170 |   1201.52 |   2879.70
Monetary  |     5 |      1170 |   2883.10 | 580987.04

CHECKS
- Each score group holds 1,170-1,171 customers (5,852 / 5).
- Score 5 is the best group on every measure: most recent, most orders, highest spend.
- The top customer (18102) scores 5-5-5; a lapsed low spender (12346) scores 1-2-1.

NOTES
- Score 5 means: ordered within 20 days, 8+ orders, or £2,883+ spent.
  Score 1 means: no order in over a year, 1 order, or under £285 spent.
- One-time buyers fill all of F=1 and spill into F=2, so both scores mostly
  mean "ordered once." Ties are broken by spend (frequency) and by frequency
  (recency), so scores are repeatable.
- Values at group boundaries can appear in two groups because of ties.
- Saved as the view `customer_scores`, which Q7 builds on.
*/