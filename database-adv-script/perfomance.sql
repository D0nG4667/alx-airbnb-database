-- ======================================================
-- File: performance.sql
-- Purpose: Initial and optimized queries for bookings
-- ======================================================

-- ==========================
-- Initial Query
-- ==========================
-- Retrieve all bookings along with user, property, and payment details
-- Includes multiple conditions in WHERE clause using AND
EXPLAIN
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
WHERE b.start_date >= '2025-01-01'
  AND b.status = 'confirmed';

-- ==========================
-- Optimized Query
-- ==========================
-- Optimization strategies:
-- 1. Select only necessary columns
-- 2. Ensure joins are on indexed columns
-- 3. Filter bookings with multiple conditions
-- 4. Avoid unnecessary LEFT JOINs if not required
EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.name AS property_name,
    p.location,
    pay.amount AS payment_amount
FROM bookings b
JOIN users u ON b.user_id = u.user_id
JOIN properties p ON b.property_id = p.property_id
LEFT JOIN payments pay ON b.booking_id = pay.booking_id
WHERE b.start_date >= '2025-01-01'
  AND b.end_date <= '2025-12-31'
  AND b.status = 'confirmed';
