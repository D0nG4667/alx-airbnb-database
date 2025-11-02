# Partitioning Performance Report: Booking Table

## Objective

Improve query performance for the Booking table by implementing range partitioning based on the `start_date` column.

---

## Implementation

- Created a parent table `bookings_partitioned` partitioned by RANGE on `start_date`.
- Added yearly partitions (2023, 2024, 2025).
- Added indexes on `user_id` for each partition.

---

## Performance Observations

- Queries fetching bookings for a specific year now scan only the relevant partition instead of the full table.
- Reduced I/O and query execution time for date-range searches.
- EXPLAIN ANALYZE shows significantly fewer rows scanned for partitioned queries compared to the original table.

---

## Conclusion

Partitioning by `start_date` optimizes large table queries effectively and enhances overall performance for date-specific searches.
