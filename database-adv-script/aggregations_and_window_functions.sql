/*
===========================================================
File: aggregations_and_window_functions.sql
Project: ALX Airbnb Database Module
Author: Gabriel Okundaye
Description:
  Demonstrates SQL aggregation (COUNT + GROUP BY) and
  window functions (ROW_NUMBER, RANK) for analyzing bookings
  and ranking properties by popularity.
===========================================================
*/

-----------------------------------------------------------
-- 1) Total number of bookings made by each user
--    Includes users with zero bookings (LEFT JOIN + COALESCE).
-----------------------------------------------------------
-- Recommended: ensure bookings.user_id is indexed for performance.
SELECT
    u.user_id,
    u.full_name,
    COALESCE(b.booking_count, 0) AS total_bookings
FROM
    users u
LEFT JOIN (
    SELECT
        user_id,
        COUNT(*) AS booking_count
    FROM bookings
    GROUP BY user_id
) b ON u.user_id = b.user_id
ORDER BY
    total_bookings DESC,
    u.full_name;


-----------------------------------------------------------
-- 2) Rank properties by total number of bookings
--    Use RANK() so properties with equal counts share the same rank.
-----------------------------------------------------------
-- Step A: compute booking counts per property
WITH property_counts AS (
    SELECT
        p.property_id,
        p.property_name,
        COALESCE(COUNT(b.booking_id), 0) AS bookings_count
    FROM properties p
    LEFT JOIN bookings b ON p.property_id = b.property_id
    GROUP BY p.property_id, p.property_name
)

-- Step B: apply window functions to rank properties
SELECT
    property_id,
    property_name,
    bookings_count,
    RANK() OVER (ORDER BY bookings_count DESC) AS popularity_rank,
    ROW_NUMBER() OVER (ORDER BY bookings_count DESC, property_id) AS row_number_order
FROM property_counts
ORDER BY bookings_count DESC, property_name;


-----------------------------------------------------------
-- Notes & Best Practices:
-- - Indexes:
--   * bookings.user_id
--   * bookings.property_id
--   * properties.property_id
--   * users.user_id
-- - Use EXPLAIN / EXPLAIN ANALYZE to inspect query plans and
--   ensure the aggregates and joins use indexes effectively.
-- - For very large datasets, consider materialized views for
--   frequently requested aggregates (e.g., daily property counts).
-- - RANK vs ROW_NUMBER:
--   * RANK(): equal values receive the same rank; gaps can occur.
--   * ROW_NUMBER(): always unique row numbers; useful when a strict ordering is required.
-----------------------------------------------------------
