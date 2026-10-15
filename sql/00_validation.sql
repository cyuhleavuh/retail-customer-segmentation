   -- Validation: should match the Dash project (£19.36M, 39,513 orders)
   SELECT
     ROUND(SUM(Revenue), 2)  AS total_revenue,
     COUNT(DISTINCT Invoice) AS total_orders
   FROM cln_sales;
   
   -- Result: £19,359,238.44 revenue, 39,513 orders. Matches the Dash project.