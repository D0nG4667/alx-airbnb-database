# Complex SQL Queries with Joins

## 🧠 Objective

The goal of this task is to **master SQL joins** by writing complex queries that combine data from multiple related tables in the Airbnb database. This exercise builds a strong foundation for understanding relational database design and efficient data retrieval strategies.

---

## 🧩 Task Overview

In this task, you will write and document SQL queries that utilize different types of joins — **INNER JOIN**, **LEFT JOIN**, and **FULL OUTER JOIN** — to explore how data relationships between entities such as Users, Properties, Bookings, and Reviews are represented and queried.

---

## 🏗️ Queries Implemented

### 1. INNER JOIN — Retrieve All Bookings and Their Respective Users

```sql
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
````

**Explanation:**
This query fetches all **bookings** along with details of the **users** who made those bookings. Only records where a booking is linked to an existing user are returned.

---

### 2. LEFT JOIN — Retrieve All Properties and Their Reviews

```sql
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
```

**Explanation:**
This query retrieves all **properties** and their **reviews**, including properties that have **no reviews**. Properties without a review will show `NULL` values in the review columns.

---

### 3. FULL OUTER JOIN — Retrieve All Users and All Bookings

```sql
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
```

**Explanation:**
This query returns **all users** and **all bookings**, even if:

* A user has **not made any booking**, or
* A booking is **not associated** with any registered user.

---

## 📂 Repository Structure

```folder
alx-airbnb-database/
│
├── database-adv-script/
│   ├── joins_queries.sql
│   └── README.md
```
