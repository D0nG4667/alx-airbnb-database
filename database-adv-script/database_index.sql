-- database_index.sql
-- Purpose: Create indexes to optimize common queries and provide EXPLAIN/ANALYZE commands
--          for measuring performance before and after index creation.
-- Author: Gabriel Okundaye
-- Usage:
-- 1) Run the EXPLAIN ANALYZE blocks under "=== BASELINE ===" to capture baseline timings.
-- 2) Run the CREATE INDEX blocks (or run entire file).
-- 3) Run ANALYZE <table> (or run the ANALYZE commands below).
-- 4) Run the EXPLAIN ANALYZE blocks under "=== AFTER INDEXES ===" to capture post-index timings.
-- 5) Compare the results manually or save outputs to files for CI comparison.

-------------------------
-- =======================
-- === INDEX CREATION ====
-- =======================
-------------------------

-- -------------------------------
-- 1. Users table
-- -------------------------------
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- Optionally for name similarity search:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_users_full_name_trgm ON users USING gin (full_name gin_trgm_ops);

-- -------------------------------
-- 2. Bookings table
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);
CREATE INDEX IF NOT EXISTS idx_bookings_check_in_date ON bookings (check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_check_out_date ON bookings (check_out_date);
CREATE INDEX IF NOT EXISTS idx_bookings_property_checkin ON bookings (property_id, check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_status_createdat ON bookings (status, created_at);

-- -------------------------------
-- 3. Properties table
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties (location);
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (pricepernight);

-- For full-text search (optional):
-- ALTER TABLE properties ADD COLUMN IF NOT EXISTS search_vector tsvector;
-- UPDATE properties SET search_vector = to_tsvector('english', coalesce(name,'') || ' ' || coalesce(description,''));
-- CREATE INDEX IF NOT EXISTS idx_properties_search_vector ON properties USING gin(search_vector);

-- -------------------------------
-- 4. Reviews table
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_reviews_property_id ON reviews (property_id);
CREATE INDEX IF NOT EXISTS idx_reviews_user_id ON reviews (user_id);

-- -------------------------------
-- 5. Payments table (if exists)
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_payments_booking_id ON payments (booking_id);
CREATE INDEX IF NOT EXISTS idx_payments_payment_date ON payments (payment_date);

-- -------------------------------
-- 6. Messages table (if exists)
-- -------------------------------
CREATE INDEX IF NOT EXISTS idx_messages_sender_id ON messages (sender_id);
CREATE INDEX IF NOT EXISTS idx_messages_recipient_id ON messages (recipient_id);

-------------------------
-- =======================
-- === ANALYZE / INFO ====
-- =======================
-------------------------

-- After creating indexes, update planner statistics:
ANALYZE users;
ANALYZE bookings;
ANALYZE properties;
ANALYZE reviews;
ANALYZE payments;
ANALYZE messages;

-------------------------
-- =======================
-- === EXPLAIN SAMPLES ===
-- =======================
-------------------------

/*
WORKFLOW FOR MEASUREMENT:

1) Baseline:
   - BEFORE creating indexes (or BEFORE uncommenting the CREATE INDEX block), run the EXPLAIN ANALYZE queries in the "=== BASELINE ===" section and save outputs.
2) Apply Indexes:
   - Run the CREATE INDEX statements (the file already contains them).
3) Refresh planner stats:
   - Ensure ANALYZE commands have run (above).
4) After Indexes:
   - Run the EXPLAIN ANALYZE queries in the "=== AFTER INDEXES ===" section and save outputs.
5) Compare:
   - Compare "Execution Time" and whether the plan changed (Seq Scan -> Index Scan / Bitmap Index Scan).

Note: The EXPLAIN ANALYZE statements are provided below as examples. Run them in psql or your SQL client.
*/


-- =======================
-- === BASELINE (run BEFORE applying indexes) ===
-- =======================

-- Availability check (typical query to check for overlapping bookings)
-- Replace 'PROPERTY_UUID' with a real UUID from your dataset.
EXPLAIN ANALYZE
SELECT 1
FROM bookings
WHERE property_id = 'PROPERTY_UUID'
  AND check_in_date < '2025-12-10'
  AND check_out_date > '2025-12-01'
LIMIT 1;

-- Bookings by user (typical user history)
-- Replace 'USER_UUID' with a real UUID.
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 'USER_UUID'
ORDER BY b.check_in_date DESC
LIMIT 50;

-- Property search (text filter + price range)
-- EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM properties
WHERE location ILIKE '%Beach Town%'
  AND pricepernight BETWEEN 50 AND 300
ORDER BY pricepernight
LIMIT 50;

-- Count bookings per property (aggregate heavy query)
EXPLAIN ANALYZE
SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC
LIMIT 100;


-- =======================
-- === AFTER INDEXES (run AFTER creating indexes and ANALYZE) ===
-- =======================

-- Re-run the same queries with EXPLAIN ANALYZE to capture improvements.
EXPLAIN ANALYZE
SELECT 1
FROM bookings
WHERE property_id = 'PROPERTY_UUID'
  AND check_in_date < '2025-12-10'
  AND check_out_date > '2025-12-01'
LIMIT 1;

EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 'USER_UUID'
ORDER BY b.check_in_date DESC
LIMIT 50;

EXPLAIN ANALYZE
SELECT property_id, name, location, pricepernight
FROM properties
WHERE location ILIKE '%Beach Town%'
  AND pricepernight BETWEEN 50 AND 300
ORDER BY pricepernight
LIMIT 50;

EXPLAIN ANALYZE
SELECT p.property_id, p.name, COUNT(b.booking_id) as booking_count
FROM properties p
LEFT JOIN bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.name
ORDER BY booking_count DESC
LIMIT 100;

-------------------------
-- =======================
-- === OPTIONAL: SAVE EXPLAIN OUTPUTS TO FILES (shell example) ===
-- =======================
-- In your shell you can capture outputs:
-- psql -d airbnb_db -c "EXPLAIN ANALYZE SELECT ... " > explain_before_availability.txt
-- After indexes: psql -d airbnb_db -c "EXPLAIN ANALYZE SELECT ... " > explain_after_availability.txt
-- Then compare the Execution Time lines or diff the plans.
-------------------------
