-- =====================================================
-- Create Table
-- =====================================================

DROP TABLE IF EXISTS customer_events;

CREATE TABLE customer_events
(
    id          BIGSERIAL PRIMARY KEY,
    customer_id INT,
    event_data  JSONB,
    created_at  TIMESTAMP DEFAULT now()
);


-- =====================================================
-- Generate Large Dataset (10,000 Rows)
-- Each customer gets multiple events
-- =====================================================

INSERT INTO customer_events (customer_id, event_data)
SELECT (random() * 1000)::INT AS customer_id,
       jsonb_build_object(
               'event_type',
               (ARRAY ['login','logout','purchase','view','cart_add'])
                   [floor(random() * 5 + 1)],
               'device',
               (ARRAY ['mobile','desktop','tablet'])
                   [floor(random() * 3 + 1)],
               'amount',
               CASE
                   WHEN random() > 0.5
                       THEN (random() * 1000)::INT
                   ELSE NULL
                   END,
               'location',
               (ARRAY ['EU','US','APAC'])
                   [floor(random() * 3 + 1)],
               'metadata',
               jsonb_build_object(
                       'ip', '192.168.' || (random() * 255)::INT || '.' || (random() * 255)::INT,
                       'browser',
                       (ARRAY ['chrome','firefox','safari','edge'])
                           [floor(random() * 4 + 1)]
               )
       )                      AS event_data
FROM generate_series(1, 10000);


-- =====================================================
-- Basic JSON Query
-- =====================================================

SELECT event_data ->> 'event_type' AS event_type,
       COUNT(*)
FROM customer_events
GROUP BY event_type
ORDER BY COUNT(*) DESC;


-- =====================================================
-- Filter JSONB Data
-- =====================================================

SELECT *
FROM customer_events
WHERE event_data ->> 'event_type' = 'purchase';


-- =====================================================
-- Nested JSON Query
-- =====================================================

SELECT event_data -> 'metadata' ->> 'browser' AS browser,
       COUNT(*)
FROM customer_events
GROUP BY browser
ORDER BY COUNT(*) DESC;


-- =====================================================
-- JSON Path Query
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$.metadata ? (@.browser == "chrome")'
      );


-- =====================================================
-- GIN Index (Critical for Performance)
-- =====================================================

CREATE INDEX idx_customer_events_gin
    ON customer_events
        USING GIN (event_data);


-- =====================================================
-- Expression Index for Frequent Filter
-- =====================================================

CREATE INDEX idx_customer_events_event_type
    ON customer_events ((event_data ->> 'event_type'));


-- =====================================================
-- 9️⃣ UPSERT Example
-- =====================================================

INSERT INTO customer_events (customer_id, event_data)
VALUES (1,
        '{
          "event_type": "purchase",
          "amount": 999,
          "device": "mobile"
        }')
ON CONFLICT (id)
    DO UPDATE SET event_data = customer_events.event_data || EXCLUDED.event_data;


-- =====================================================
-- Merge JSON Objects
-- =====================================================

SELECT id,
       event_data,
       event_data || '{
         "processed": true
       }'::jsonb AS updated_event
FROM customer_events
LIMIT 20;

-- =====================================================
-- Find Events Where Purchase Amount > 500
-- Demonstrates: Numeric comparison in JSON Path
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$ ? (@.amount > 500)'
      );


-- =====================================================
-- Find Mobile Purchases
-- Demonstrates: Multiple conditions with AND
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$ ? (@.event_type == "purchase" && @.device == "mobile")'
      );


-- =====================================================
-- Filter Nested JSON Fields
-- Demonstrates: Access nested metadata
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$.metadata ? (@.browser == "chrome")'
      );


-- =====================================================
-- Combine Parent + Nested Conditions
-- Demonstrates: Multi-level JSON filtering
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$ ? (@.event_type == "login" && @.metadata.browser == "firefox")'
      );


-- =====================================================
-- Extract JSON Values Using JSON Path
-- Demonstrates: jsonb_path_query
-- Returns matching values instead of rows
-- =====================================================

SELECT id,
       jsonb_path_query(event_data, '$.metadata.browser') AS browser
FROM customer_events
LIMIT 20;


-- =====================================================
-- Extract Numeric Values
-- Demonstrates: Retrieve purchase amounts
-- =====================================================

SELECT id,
       jsonb_path_query(event_data, '$.amount') AS purchase_amount
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$ ? (@.event_type == "purchase")'
      )
LIMIT 20;


-- =====================================================
-- Return Full JSON Objects Matching Condition
-- Demonstrates: jsonb_path_query returning structures
-- =====================================================

SELECT id,
       jsonb_path_query(event_data, '$ ? (@.device == "mobile")')
FROM customer_events
LIMIT 20;


-- =====================================================
-- Count Chrome Browser Events
-- Demonstrates: JSON Path filtering + aggregation
-- =====================================================

SELECT COUNT(*)
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$.metadata ? (@.browser == "chrome")'
      );


-- =====================================================
-- Events With Purchase Amount Between 200 and 400
-- Demonstrates: Range queries
-- =====================================================

SELECT *
FROM customer_events
WHERE jsonb_path_exists(
              event_data,
              '$ ? (@.amount >= 200 && @.amount <= 400)'
      );


-- =====================================================
-- Extract Multiple Fields via JSON Path
-- Demonstrates: jsonb_path_query_first
-- =====================================================

SELECT id,
       jsonb_path_query_first(event_data, '$.event_type') AS event_type,
       jsonb_path_query_first(event_data, '$.device')     AS device
FROM customer_events
LIMIT 20;
