# ALX AirBnB Database

## Project Overview

This repository contains the database schema for an AirBnB-like application. The schema is designed following **Third Normal Form (3NF)** to ensure minimal redundancy and maintain data integrity.

## Directory Structure

database-script-0x01/
│
├── schema.sql       # SQL script to create tables, constraints, and indexes
├── README.md        # Project documentation

## Features

- Users with roles: guest, host, admin
- Properties listed by hosts
- Bookings linked to users and properties
- Payments associated with bookings
- Reviews for properties by users
- Messaging system between users
- Fully normalized to 3NF
- Indexes for primary keys, foreign keys, and email

## How to Use

1. Clone the repository:

```shell
git clone https://github.com/D0nG4667/alx-airbnb-database.git
```

2. Navigate to the database script directory:

```shell
cd alx-airbnb-database/database-script-0x01
```

3. Run the schema SQL file in your preferred SQL database (PostgreSQL/MySQL):

 - Example for PostgreSQL
 
```shell
psql -U <username> -d <database> -f schema.sql
```

## Notes

- `total_price` is not stored in Booking to avoid redundancy; calculate dynamically using `price_per_night` and booking duration.
- All ENUM and CHECK constraints are included to maintain data integrity.
