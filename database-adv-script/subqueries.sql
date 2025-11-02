-- subqueries.sql
-- ALX Airbnb Database Module
-- Author: Gabriel Okundaye
-- Topic: Practice Subqueries (Correlated and Non-Correlated)
-- ---------------------------------------------------------------------------
-- This script demonstrates:
-- 1. A non-correlated subquery: find all properties with an average rating > 4.0
-- 2. A correlated subquery: find all users who have made more than 3 bookings
-- ---------------------------------------------------------------------------

-- ===========================================================
-- 1️⃣ NON-CORRELATED SUBQUERY
-- Find all properties where the average rating is greater than 4.0
-- ===========================================================

SELECT 
    p.property_id,
    p.property_name,
    p.location,
    p.host_id
FROM properties AS p
WHERE p.property_id IN (
    SELECT r.property_id
    FROM reviews AS r
    GROUP BY r.property_id
    HAVING AVG(r.rating) > 4.0
)
ORDER BY p.property_name;

-- Explanation:
-- The subquery calculates average ratings per property (independent of the outer query).
-- The main query selects all properties whose IDs are returned by the subquery.
-- This is a non-correlated subquery since it runs independently of each row in the outer query.


-- ===========================================================
-- 2️⃣ CORRELATED SUBQUERY
-- Find all users who have made more than 3 bookings
-- ===========================================================

SELECT 
    u.user_id,
    u.full_name,
    u.email
FROM users AS u
WHERE (
    SELECT COUNT(*) 
    FROM bookings AS b
    WHERE b.user_id = u.user_id
) > 3
ORDER BY u.full_name;

-- Explanation:
-- The subquery counts how many bookings each user has made,
-- referring back to the current user_id in the outer query.
-- Because it depends on the outer query row, it is a correlated subquery.

-- ✅ Best Practice Notes:
-- - Always index foreign key columns like `reviews.property_id` and `bookings.user_id` for performance.
-- - For large datasets, consider rewriting as JOINs for faster evaluation in production environments.
