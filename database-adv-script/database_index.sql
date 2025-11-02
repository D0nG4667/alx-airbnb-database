-- Purpose: Create indexes to optimize common queries in the ALX Airbnb schema.
-- Author: Gabriel Okundaye
-- Note: Choose index names that follow your project's naming convention.

-- -------------------------------
-- 1. Users table
-- -------------------------------
-- Index on email for lookups during login / registration checks (unique index recommended)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email ON users (email);

-- If you search users by full_name or do ILIKE searches, consider a trigram GIN index:
-- Requires the pg_trgm extension:
-- CREATE EXTENSION IF NOT EXISTS pg_trgm;
-- CREATE INDEX IF NOT EXISTS idx_users_full_name_trgm ON users USING gin (full_name gin_trgm_ops);

-- -------------------------------
-- 2. Bookings table
-- -------------------------------
-- FK lookups and joins
CREATE INDEX IF NOT EXISTS idx_bookings_user_id ON bookings (user_id);
CREATE INDEX IF NOT EXISTS idx_bookings_property_id ON bookings (property_id);

-- Range/date queries for availability and filtering
CREATE INDEX IF NOT EXISTS idx_bookings_check_in_date ON bookings (check_in_date);
CREATE INDEX IF NOT EXISTS idx_bookings_check_out_date ON bookings (check_out_date);

-- Composite index commonly used in availability queries (property + date range)
-- Note: composite index helps queries filtering by property and date
CREATE INDEX IF NOT EXISTS idx_bookings_property_checkin ON bookings (property_id, check_in_date);

-- If you frequently query by status and created_at (e.g., admin dashboards)
CREATE INDEX IF NOT EXISTS idx_bookings_status_createdat ON bookings (status, created_at);

-- -------------------------------
-- 3. Properties table
-- -------------------------------
-- FK lookups and joins
CREATE INDEX IF NOT EXISTS idx_properties_host_id ON properties (host_id);

-- Common search/filter columns – if you filter by location often
CREATE INDEX IF NOT EXISTS idx_properties_location ON properties (location);

-- For price range queries
CREATE INDEX IF NOT EXISTS idx_properties_price ON properties (pricepernight);

-- For full-text search over title/description consider a tsvector GIN index:
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

-- -------------------------------
-- Maintenance / Notes
-- -------------------------------
-- To drop an index:
-- DROP INDEX IF EXISTS idx_name;

-- To analyze table stats after creating indexes:
-- ANALYZE users;
-- ANALYZE bookings;
-- ANALYZE properties;
