# Optimization Report: Airbnb Clone Database Queries

## Objective

This report details the optimization process for complex SQL queries in the Airbnb Clone project. The goal is to improve query performance for retrieving bookings along with related user, property, and payment information.

---

## Initial Query

```sql
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
```

### Observations

* The query retrieves all bookings with associated users, properties, and payments.
* Initial performance analysis using `EXPLAIN` indicated potential inefficiencies:

  * Scans on large tables (bookings, users, properties).
  * LEFT JOIN on payments table may cause extra rows to be processed.
* The query filters on `start_date` and `status`, but other conditions could further narrow results.

---

## Optimization Strategies Applied

1. **Column Selection**

   * Only select columns required for the query, reducing I/O overhead.
2. **Explicit Joins**

   * Replaced `USING` with `ON` conditions for clarity and better index utilization.
3. **Additional Filters**

   * Added `end_date` filter to limit rows scanned.
4. **Index Awareness**

   * Ensured joins and filters are on indexed columns (`user_id`, `property_id`, `booking_id`).

---

## Optimized Query

```sql
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
```

### Results

* Query execution time reduced due to:

  * Fewer scanned rows by adding `end_date` filter.
  * Better use of indexes for join and filter columns.
* The query plan (`EXPLAIN`) shows reduced sequential scans and more efficient access paths.

---

## Conclusion

The optimization improved the performance of complex queries by:

* Reducing the amount of data scanned.
* Filtering on indexed columns.
* Limiting unnecessary joins.
* Selecting only required columns.

These changes are crucial for handling large datasets efficiently in production systems like Airbnb.
