-- =====================================================
-- Rank Customers by Total Spending
-- Demonstrates: RANK() over ordered aggregates
-- =====================================================

SELECT c.c_custkey,
       c.c_name,
       SUM(o.o_totalprice) AS total_spent,
       RANK() OVER (
           ORDER BY SUM(o.o_totalprice) DESC
           )               AS spending_rank
FROM customer c
         JOIN orders o ON o.o_custkey = c.c_custkey
GROUP BY c.c_custkey, c.c_name
ORDER BY spending_rank;


-- =====================================================
-- Top Order Per Customer
-- Demonstrates: ROW_NUMBER() with PARTITION BY
-- =====================================================

SELECT *
FROM (SELECT o.*,
             ROW_NUMBER() OVER (
                 PARTITION BY o_custkey
                 ORDER BY o_totalprice DESC
                 ) AS rn
      FROM orders o) ranked
WHERE rn < 3;


-- =====================================================
-- Running Total of Sales Over Time
-- Demonstrates: Cumulative SUM()
-- =====================================================

SELECT o_orderdate,
       SUM(o_totalprice) AS daily_sales,
       SUM(SUM(o_totalprice)) OVER (
           ORDER BY o_orderdate
           )             AS running_total
FROM orders
GROUP BY o_orderdate
ORDER BY o_orderdate;


-- =====================================================
-- Moving Average (7-Day Window)
-- Demonstrates: ROWS frame specification
-- =====================================================

SELECT o_orderdate,
       SUM(o_totalprice) AS daily_sales,
       AVG(SUM(o_totalprice)) OVER (
           ORDER BY o_orderdate
           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
           )             AS moving_avg_7d
FROM orders
GROUP BY o_orderdate
ORDER BY o_orderdate;


-- =====================================================
-- Percent Contribution to Total Revenue
-- Demonstrates: Window aggregate without GROUP BY collapse
-- =====================================================

SELECT o_orderkey,
       o_totalprice,
       o_totalprice / SUM(o_totalprice) OVER () * 100 AS percent_of_total
FROM orders;


-- =====================================================
-- NTILE (Quartiles of Orders)
-- Demonstrates: Data segmentation
-- =====================================================

SELECT o_orderkey,
       o_totalprice,
       NTILE(4) OVER (
           ORDER BY o_totalprice
           ) AS revenue_quartile
FROM orders;


-- =====================================================
-- LAG() — Compare With Previous Order
-- Demonstrates: Time-series comparison
-- =====================================================

SELECT o_orderkey,
       o_orderdate,
       o_totalprice,
       LAG(o_totalprice) OVER (
           ORDER BY o_orderdate
           ) AS previous_order_value
FROM orders
ORDER BY o_orderdate;


-- =====================================================
-- LEAD() — Compare With Next Order
-- Demonstrates: Forward-looking analytics
-- =====================================================

SELECT o_orderkey,
       o_orderdate,
       o_totalprice,
       LEAD(o_totalprice) OVER (
           ORDER BY o_orderdate
           ) AS next_order_value
FROM orders
ORDER BY o_orderdate;


-- =====================================================
-- Dense Rank Per Region
-- Demonstrates: Partitioned ranking
-- =====================================================

SELECT r.r_name,
       c.c_custkey,
       SUM(o.o_totalprice) AS total_spent,
       DENSE_RANK() OVER (
           PARTITION BY r.r_name
           ORDER BY SUM(o.o_totalprice) DESC
           )               AS region_rank
FROM region r
         JOIN nation n ON n.n_regionkey = r.r_regionkey
         JOIN customer c ON c.c_nationkey = n.n_nationkey
         JOIN orders o ON o.o_custkey = c.c_custkey
GROUP BY r.r_name, c.c_custkey
ORDER BY r.r_name, region_rank;


-- =====================================================
-- Window-Based Top 3 Per Customer
-- Demonstrates: Advanced filtering with window logic
-- =====================================================

SELECT *
FROM (SELECT o.*,
             ROW_NUMBER() OVER (
                 PARTITION BY o_custkey
                 ORDER BY o_totalprice DESC
                 ) AS rn
      FROM orders o) t
WHERE rn <= 3;
