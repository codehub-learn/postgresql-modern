-- =====================================================
-- Basic UPSERT
-- Demonstrates: Insert a row or update if key exists
-- =====================================================

INSERT INTO customer_events (id, customer_id, event_data)
VALUES (1,
        100,
        '{
          "event_type": "login",
          "device": "mobile"
        }')
ON CONFLICT (id)
    DO UPDATE SET customer_id = EXCLUDED.customer_id,
                  event_data  = EXCLUDED.event_data;



-- =====================================================
-- UPSERT Updating Only Specific Columns
-- Demonstrates: Update only event_data on conflict
-- =====================================================

INSERT INTO customer_events (id, customer_id, event_data)
VALUES (1,
        100,
        '{
          "event_type": "logout",
          "device": "desktop"
        }')
ON CONFLICT (id)
    DO UPDATE SET event_data = EXCLUDED.event_data;



-- =====================================================
-- UPSERT Merging JSON Data
-- Demonstrates: Combine existing JSON with new JSON
-- =====================================================

INSERT INTO customer_events (id, customer_id, event_data)
VALUES (2,
        200,
        '{
          "amount": 300,
          "currency": "USD"
        }')
ON CONFLICT (id)
    DO UPDATE SET event_data = customer_events.event_data || EXCLUDED.event_data;



-- =====================================================
-- UPSERT Only If Condition Is True
-- Demonstrates: Conditional updates using WHERE clause
-- =====================================================

INSERT INTO customer_events (id, customer_id, event_data)
VALUES (3,
        300,
        '{
          "event_type": "purchase",
          "amount": 500
        }')
ON CONFLICT (id)
    DO UPDATE SET event_data = EXCLUDED.event_data
WHERE (customer_events.event_data ->> 'event_type') != 'purchase';



-- =====================================================
-- UPSERT Incrementing Counters
-- Demonstrates: Atomic update pattern (common in analytics)
-- =====================================================

CREATE TABLE IF NOT EXISTS event_counters
(
    event_type   TEXT PRIMARY KEY,
    total_events INT DEFAULT 0
);

INSERT INTO event_counters (event_type, total_events)
VALUES ('login', 1)
ON CONFLICT (event_type)
    DO UPDATE SET total_events = event_counters.total_events + 1;



-- =====================================================
-- UPSERT with Timestamp Update
-- Demonstrates: Maintain last_updated metadata
-- =====================================================

CREATE TABLE IF NOT EXISTS customer_profiles
(
    customer_id  INT PRIMARY KEY,
    profile      JSONB,
    last_updated TIMESTAMP
);

INSERT INTO customer_profiles (customer_id, profile, last_updated)
VALUES (1,
        '{
          "tier": "gold",
          "preferences": {
            "language": "en"
          }
        }',
        now())
ON CONFLICT (customer_id)
    DO UPDATE SET profile      = EXCLUDED.profile,
                  last_updated = now();



-- =====================================================
-- UPSERT with Partial Unique Index
-- Demonstrates: Conflict resolution with business logic
-- =====================================================

CREATE TABLE IF NOT EXISTS user_sessions
(
    user_id    INT,
    session_id TEXT,
    active     BOOLEAN,
    created_at TIMESTAMP DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS unique_active_session
    ON user_sessions (user_id)
    WHERE active = TRUE;

INSERT INTO user_sessions (user_id, session_id, active)
VALUES (10, 'sess_abc123', TRUE)
ON CONFLICT (user_id)
WHERE active = TRUE
    DO
UPDATE
SET session_id = EXCLUDED.session_id,
    created_at = now();
