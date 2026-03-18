-- =====================================================
-- Basic CTE: Customer Total Revenue
-- Demonstrates: Separating aggregation logic
-- =====================================================

WITH customer_revenue AS (SELECT o.o_custkey,
                                 SUM(o.o_totalprice) AS total_spent
                          FROM orders o
                          GROUP BY o.o_custkey)
SELECT *
FROM customer_revenue
ORDER BY total_spent DESC
LIMIT 1000;


-- =====================================================
-- Multi-CTE Pipeline: Nation Sales + Filter
-- Demonstrates: Chaining multiple CTEs
-- =====================================================

WITH nation_sales AS (SELECT n.n_name,
                             SUM(o.o_totalprice) AS total_sales
                      FROM nation n
                               JOIN customer c ON c.c_nationkey = n.n_nationkey
                               JOIN orders o ON o.o_custkey = c.c_custkey
                      GROUP BY n.n_name),
     filtered_sales AS (SELECT *
                        FROM nation_sales
                        WHERE total_sales > 1000000)
SELECT *
FROM filtered_sales
ORDER BY total_sales DESC;


-- =====================================================
-- CTE for Data Cleaning
-- Demonstrates: Filtering before further processing
-- =====================================================

WITH valid_orders AS (SELECT *
                      FROM orders
                      WHERE o_totalprice IS NOT NULL
                        AND o_totalprice > 0)
SELECT COUNT(*)
FROM valid_orders;


-- =====================================================
-- Pre-Aggregation Pattern
-- Demonstrates: Aggregate first, then join
-- =====================================================

WITH order_totals AS (SELECT o_custkey,
                             SUM(o_totalprice) AS total_spent
                      FROM orders
                      GROUP BY o_custkey)
SELECT c.c_name,
       ot.total_spent
FROM order_totals ot
         JOIN customer c
              ON c.c_custkey = ot.o_custkey
ORDER BY ot.total_spent DESC;


-- =====================================================
-- Time-Based Aggregation
-- Demonstrates: Analytical grouping using DATE_TRUNC
-- =====================================================

WITH monthly_sales AS (SELECT DATE_TRUNC('month', o_orderdate) AS month,
                              SUM(o_totalprice)                AS total_sales
                       FROM orders
                       GROUP BY 1)
SELECT *
FROM monthly_sales
ORDER BY month;


-- =====================================================
-- Complex Join Decomposition
-- Demonstrates: Breaking complex joins into readable steps
-- =====================================================

WITH region_customers AS (SELECT r.r_name,
                                 c.c_custkey
                          FROM region r
                                   JOIN nation n ON n.n_regionkey = r.r_regionkey
                                   JOIN customer c ON c.c_nationkey = n.n_nationkey),
     region_revenue AS (SELECT rc.r_name,
                               SUM(o.o_totalprice) AS total_revenue
                        FROM region_customers rc
                                 JOIN orders o ON o.o_custkey = rc.c_custkey
                        GROUP BY rc.r_name)
SELECT *
FROM region_revenue
ORDER BY total_revenue DESC;


-- =====================================================
-- Top-N Per Group Using CTE
-- Demonstrates: Using CTE for ranking logic
-- =====================================================

WITH ranked_orders AS (SELECT o.*,
                              ROW_NUMBER() OVER (
                                  PARTITION BY o_custkey
                                  ORDER BY o_totalprice DESC
                                  ) AS rn
                       FROM orders o)
SELECT *
FROM ranked_orders
WHERE rn = 1;


-- =====================================================
-- SQL Data Pipeline Pattern
-- Demonstrates: Multi-stage transformation
-- =====================================================

WITH high_value_orders AS (SELECT *
                           FROM orders
                           WHERE o_totalprice > 10000),
     customer_stats AS (SELECT c.c_custkey,
                               COUNT(*) AS order_count
                        FROM high_value_orders h
                                 JOIN customer c ON c.c_custkey = h.o_custkey
                        GROUP BY c.c_custkey)
SELECT *
FROM customer_stats
ORDER BY order_count DESC;


-- =====================================================
-- Deduplication Pattern
-- Demonstrates: Selecting latest record per group
-- =====================================================

WITH latest_orders AS (SELECT *
                       FROM (SELECT o.*,
                                    ROW_NUMBER() OVER (
                                        PARTITION BY o_custkey
                                        ORDER BY o_orderdate DESC
                                        ) rn
                             FROM orders o) t
                       WHERE rn = 1)
SELECT *
FROM latest_orders;


-- =====================================================
-- Chained Analytical CTE
-- Demonstrates: Real-world analytics structure
-- =====================================================

WITH base AS (SELECT o_custkey, o_totalprice
              FROM orders),
     aggregated AS (SELECT o_custkey,
                           SUM(o_totalprice) AS total_spent
                    FROM base
                    GROUP BY o_custkey),
     filtered AS (SELECT *
                  FROM aggregated
                  WHERE total_spent > 50000)
SELECT *
FROM filtered
ORDER BY total_spent DESC;
