# ALX AirBnB Database - Sample Data Seed

## Project Overview

This directory contains SQL scripts to populate the AirBnB database with **sample data**. The sample data reflects real-world usage with multiple users, properties, bookings, payments, reviews, and messages.

## Directory Structure

database-script-0x02/
│
├── seed.sql       # SQL script to insert sample data
├── README.md      # Project documentation

## How to Use

1. Ensure your AirBnB database is created using `schema.sql` from database-script-0x01.

2. Navigate to the seed script directory:

```shell
cd alx-airbnb-database/database-script-0x02
```

3. Run the seed script in your SQL database (PostgreSQL/MySQL):

- Example for PostgreSQL

```shell
psql -U <username> -d <database> -f seed.sql
```

## Notes

- Sample users include both guests and hosts.
- Bookings are linked to existing users and properties.
- Payments correspond to bookings.
- Reviews and messages simulate real-world interactions.
- UUIDs are hardcoded for reproducibility; you can generate new ones if desired.
