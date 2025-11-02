-- ==========================================================================
-- Initial Query: Retrieve all bookings with user, property, and payment details
-- ==========================================================================
-- BEFORE optimization
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id;


-- ==========================================================================
-- Optimized Query: Using selective columns and indexed joins
-- ==========================================================================
-- AFTER optimization
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount
FROM bookings b
JOIN users u USING(user_id)
JOIN properties p USING(property_id)
LEFT JOIN payments pay USING(booking_id)
WHERE b.start_date >= '2025-01-01';  -- Filter to reduce scanned rows

