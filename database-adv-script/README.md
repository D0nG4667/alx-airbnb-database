# Advanced SQL Queries with Joins

## 🧠 Objective

The goal of this task is to **master SQL joins** by writing complex queries that combine data from multiple related tables in the Airbnb database. This exercise builds a strong foundation for understanding relational database design and efficient data retrieval strategies.

---

## 🧩 Task Overview

In this task, you will write and document SQL queries that utilize different types of joins — **INNER JOIN**, **LEFT JOIN**, and **FULL OUTER JOIN** — to explore how data relationships between entities such as Users, Properties, Bookings, and Reviews are represented and queried.

---

## Schema relationships (relevant tables)

> Typical simplified columns used in the queries:

- **users**: `(user_id PK, full_name, email, ...)`
- **properties**: `(property_id PK, property_name, location, host_id FK -> users.user_id, ...)`
- **bookings**: `(booking_id PK, property_id FK -> properties.property_id, user_id FK -> users.user_id, check_in_date, check_out_date, ...)`
- **reviews**: `(review_id PK, property_id FK -> properties.property_id, user_id FK -> users.user_id, rating, comment, ...)`

Key relationships:

- `users (1) <-- (N) bookings`
- `properties (1) <-- (N) bookings`
- `properties (1) <-- (N) reviews`
- `users (1) <-- (N) reviews` (guest writes reviews)

---

---

## 🏗️ Queries Implemented

It explains each JOIN type, ties them to the schema relationships, shows the exact SQL examples (matching `joins_queries.sql`), gives expected behavior, and provides quick tips for testing and performance (EXPLAIN / indexes).

> All queries use deterministic ordering via `ORDER BY` so results are reproducible for tests.

### 1. INNER JOIN — Bookings with Users

**Purpose:** Return bookings that have an associated user (only matching pairs).

```sql
-- INNER JOIN: bookings with their users
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
    b.user_id = u.user_id
ORDER BY 
    b.booking_id;
```

**Behavior:**
Only bookings with a valid `user_id` that matches a `users.user_id` will appear. Bookings with `NULL` or orphaned `user_id` are excluded.

---

### 2. LEFT JOIN — Properties with Reviews (include properties with no reviews)

**Purpose:** Get all properties, and include review data when present — properties with no reviews still appear (review columns will be `NULL`).

```sql
-- LEFT JOIN: properties and their reviews, including properties without reviews
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
    p.property_id = r.property_id
ORDER BY 
    p.property_id, r.review_id;
```

**Behavior:**

- Every `properties` row is returned.
- If a property has reviews, there will be one row per review (property repeated).
- If a property has no reviews, review columns (`review_id`, `rating`, `comment`) are `NULL`.

**Checks (common test cases):**

- Properties with no reviews exist in the output.
- Properties with multiple reviews appear multiple times (one row per review).
- `ORDER BY p.property_id, r.review_id` makes results deterministic for automated checks.

---

### 3. FULL OUTER JOIN — All Users and All Bookings

**Purpose:** Return all users and all bookings — including users who never booked and bookings that are orphaned (not linked to a user).

```sql
-- FULL OUTER JOIN: all users and all bookings, matching where possible
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
    u.user_id = b.user_id
ORDER BY 
    u.user_id, b.booking_id;
```

**Behavior:**

- Returns all rows from `users` and all rows from `bookings`.
- When a booking has a matching user, fields from both sides are populated.
- When a booking has no user, `user` columns are `NULL`.
- When a user has no bookings, `booking` columns are `NULL`.

**Note:** Not all DBMS support `FULL OUTER JOIN` (e.g., MySQL before v8 lacks it); alternative approaches exist (UNION of LEFT and RIGHT joins).

---

## Testing & Validation

- Use controlled test data with:

  - properties with 0, 1, and multiple reviews,
  - bookings with valid `user_id`, bookings with `NULL`/orphan `user_id`,
  - users with and without bookings.
- Run each query and verify:

  - INNER JOIN excludes non-matching rows,
  - LEFT JOIN includes all properties including those with `NULL` reviews,
  - FULL OUTER JOIN includes unmatched rows from both tables.
- Use `COUNT(*)` with filters to verify expected row counts (unit-testable).
- Example assertion for LEFT JOIN test:

  - `SELECT COUNT(*) FROM properties p LEFT JOIN reviews r ON ... WHERE r.review_id IS NULL;`
  - This yields the number of properties without reviews.

---

## Performance tips

- **Indexes**: Ensure FK columns used in joins are indexed (e.g., `bookings.user_id`, `reviews.property_id`). This drastically improves join performance.
- **EXPLAIN / ANALYZE**: Use `EXPLAIN` or `EXPLAIN ANALYZE` to verify the query plan and identify slow joins or missing indexes.
- **Limit columns**: Select only the fields you need (avoid `SELECT *`) to reduce I/O.
- **Pagination**: For large result sets, use `LIMIT` / `OFFSET` or keyset pagination.
- **Avoid full table scans**: Provide selective WHERE clauses when possible to limit processed rows.

---

## 📂 Repository Structure

```folder
alx-airbnb-database/
│
├── database-adv-script/
│   ├── joins_queries.sql
│   └── README.md
```

Perfect ✅ — here’s a **world-class implementation** of the **subqueries.sql** file and accompanying **README.md** following professional backend and database engineering standards (for your ALX Airbnb Database Module).

---

## 📄 `database-adv-script/subqueries.sql`

This script demonstrates both **non-correlated** and **correlated** subqueries clearly and efficiently.

```sql
-- subqueries.sql
-- ALX Airbnb Database Module
-- Author: Gabriel Osasumwen Okundaye
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
```

## 🧩 File: `subqueries.sql`

### Objective

Practice writing **correlated** and **non-correlated** subqueries.

### Tasks

#### 1️⃣ Find all properties where the average rating is greater than 4.0

**Type:** Non-correlated subquery  
**Explanation:**  
The subquery calculates the average rating per property independently and returns property IDs where the average rating > 4.0. The outer query then fetches property details for those IDs.

#### 2️⃣ Find all users who have made more than 3 bookings

**Type:** Correlated subquery  
**Explanation:**  
The subquery counts bookings for each user by referencing `u.user_id` from the outer query. It executes once per user to determine if the user meets the booking threshold.

---

### 🧠 Key Learning Outcomes

- Understand when to use correlated vs non-correlated subqueries.
- Write efficient filtering logic with `IN`, `EXISTS`, and aggregate functions.
- Optimize queries using indexing and performance tuning principles.

---

### ✅ Expected Output

1. **Query 1:** List of properties with an average rating > 4.0
2. **Query 2:** List of users who have made more than 3 bookings
