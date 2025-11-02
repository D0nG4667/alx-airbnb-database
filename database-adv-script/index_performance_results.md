# Index Performance: Identification, Creation, and Measurement

## Objective

Create indexes for high-usage columns and measure query performance before and after indexing using `EXPLAIN` / `EXPLAIN ANALYZE`. Document results and recommendations.

---

## 1. Identified High-Usage Columns

Based on typical backend queries and schema usage:

## **Users**

- `email` (WHERE, login)
- `full_name` (search / display)

## **Bookings**

- `user_id` (JOIN, WHERE)
- `property_id` (JOIN, WHERE)
- `check_in_date`, `check_out_date` (availability queries / WHERE / ORDER BY)
- `status`, `created_at` (admin filters)

## **Properties**

- `host_id` (JOIN)
- `location` (filter)
- `pricepernight` (range filter)
- `name` / `description` (full-text search candidate)

## **Reviews**

- `property_id`, `user_id` (JOIN / WHERE)

## **Payments**

- `booking_id`, `payment_date` (JOIN / WHERE)

---

## 2. Indexes Added

See `database_index.sql` for the CREATE INDEX commands used. Key indexes include:

- `idx_users_email` — UNIQUE index on `users(email)`
- `idx_bookings_user_id` — index for booking→user joins
- `idx_bookings_property_id` — index for booking→property joins
- `idx_bookings_property_checkin` — composite index for property + check_in_date
- `idx_properties_location` — index to speed up location filters
- `idx_properties_price` — index for price range queries
- `idx_reviews_property_id` — index for property review lookups
- plus optional full-text / trigram indexes for search-heavy text fields

---

## 3. Measuring Performance: Workflow

### Step A — Baseline (before adding indexes)

1. Connect to your test database (use a representative dataset).
2. Run `EXPLAIN ANALYZE` on queries you care about. Example queries:

**Availability check:**

```sql
EXPLAIN ANALYZE
SELECT 1
FROM bookings
WHERE property_id = 'PROPERTY_UUID'
  AND check_in_date < '2025-12-10'
  AND check_out_date > '2025-12-01'
LIMIT 1;
````

**Property search:**

```sql
EXPLAIN ANALYZE
SELECT property_id, property_name, location, pricepernight
FROM properties
WHERE location ILIKE '%Beach Town%'
  AND pricepernight BETWEEN 50 AND 300
ORDER BY pricepernight
LIMIT 50;
```

**Bookings by user:**

```sql
EXPLAIN ANALYZE
SELECT b.*
FROM bookings b
WHERE b.user_id = 'USER_UUID'
ORDER BY b.check_in_date DESC
LIMIT 50;
```

Record:

- Total execution time (`Execution Time:`)
- Planned vs actual row counts
- Whether an index scan or sequential scan was used

### Step B — Create Indexes

Execute `psql -f database_index.sql` (or run the commands manually).

### Step C — Refresh planner statistics

```sql
ANALYZE bookings;
ANALYZE properties;
ANALYZE users;
ANALYZE reviews;
ANALYZE payments;
```

### Step D — Re-run `EXPLAIN ANALYZE` on same queries

Compare metrics:

- Wall clock time before vs after
- Cost estimates and actual row counts
- Whether the query plan changed from `Seq Scan` to `Index Scan` or `Bitmap Index Scan`
- I/O and buffer usage improvements

---

## 4. Example Expected Improvements

- **Availability check**: moves from `Seq Scan` to `Index Scan` on `idx_bookings_property_checkin`, reducing scan rows dramatically and lowering execution time.
- **Bookings by user**: becomes index-backed, returning rows faster and avoiding full-table scans on large booking tables.
- **Property search**: if `location` is selective, index reduces scanned rows; consider trigram/full-text for ILIKE and text search.

---

## 5. Caveats & Best Practices

- **Index overhead**: Indexes speed reads but slow writes (INSERT/UPDATE/DELETE). Only index columns used frequently in WHERE/JOIN/ORDER BY.
- **Composite indexes**: Order matters — e.g., `(property_id, check_in_date)` helps queries filtering on both; does not help queries that filter only on `check_in_date`.
- **Partial indexes**: For status-specific queries, consider partial indexes:

  ```sql
  CREATE INDEX idx_bookings_active_property_checkin ON bookings (property_id, check_in_date)
  WHERE status = 'confirmed';
  ```

- **GIN / Trigram / Full-text**: Use GIN indexes with `pg_trgm` or `tsvector` for fast `ILIKE` or full-text searches.
- **Monitoring**: Keep `pg_stat_user_indexes` and run periodic `REINDEX` / `VACUUM` as needed for heavily updated tables.
- **Testing**: Always test in an environment representative of production data volumes.
