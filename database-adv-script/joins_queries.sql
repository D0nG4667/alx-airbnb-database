/*
===========================================================
File: joins_queries.sql
Project: ALX Airbnb Database Module
Author: Gabriel Okundaye
Description:
  This script demonstrates the use of SQL JOIN operations
  (INNER JOIN, LEFT JOIN, FULL OUTER JOIN) in the Airbnb
  relational database schema.
===========================================================
*/


-----------------------------------------------------------
-- 1. INNER JOIN
-- Retrieve all bookings and their respective users.
-- Returns only records where both booking and user exist.
-----------------------------------------------------------
SELECT 
    b.booking_id,
    b.property_id,
    b.check_in_date,
    b.check_out_date,
    u.user_id,
    u.full_name,
    u.email
FROM 
    bookings AS b
INNER JOIN 
    users AS u 
ON 
    b.user_id = u.user_id;


-----------------------------------------------------------
-- 2. LEFT JOIN
-- Retrieve all properties and their reviews.
-- Includes properties that have no associated reviews.
-----------------------------------------------------------
SELECT 
    p.property_id,
    p.property_name,
    p.location,
    r.review_id,
    r.rating,
    r.comment
FROM 
    properties AS p
LEFT JOIN 
    reviews AS r 
ON 
    p.property_id = r.property_id;


-----------------------------------------------------------
-- 3. FULL OUTER JOIN
-- Retrieve all users and all bookings.
-- Includes users without bookings and bookings without users.
-----------------------------------------------------------
SELECT 
    u.user_id,
    u.full_name,
    b.booking_id,
    b.property_id,
    b.check_in_date
FROM 
    users AS u
FULL OUTER JOIN 
    bookings AS b 
ON 
    u.user_id = b.user_id;
