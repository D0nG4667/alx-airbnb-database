# AirBnB Database Normalization (3NF)

## Original Schema

Entities: User, Property, Booking, Payment, Review, Message

### Observations

1. **User**

   * `email` is unique. ✅
   * No transitive dependencies. ✅

2. **Property**

   * `host_id` references `User(user_id)`. ✅
   * `pricepernight` and `location` are dependent on the property only. ✅

3. **Booking**

   * `total_price` is derived: `total_price = pricepernight * number_of_nights`. ❌

     * Storing derived attributes violates 3NF; can be computed dynamically.

4. **Payment**

   * Linked to `Booking` via `booking_id`. ✅

5. **Review**

   * `rating` and `comment` depend directly on `(property_id, user_id)`. ✅

6. **Message**

   * `sender_id` and `recipient_id` are FKs. ✅

---

## 1NF Check

* Each table has atomic columns. ✅
* Repeating groups: None. ✅

## 2NF Check

* No partial dependencies on a composite primary key (all tables use single-column PKs). ✅

## 3NF Check

* **Booking Table:** `total_price` depends on `property_id` (through pricepernight) and `start_date`/`end_date`. This is a transitive dependency. ❌

  * Solution: Remove `total_price` from Booking; compute on query.

* Other tables: No transitive dependencies detected. ✅

---

## Revised Schema (3NF)

### User

```sql
CREATE TABLE User (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR NOT NULL,
    last_name VARCHAR NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    password_hash VARCHAR NOT NULL,
    phone_number VARCHAR,
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Property

```sql
CREATE TABLE Property (
    property_id UUID PRIMARY KEY,
    host_id UUID REFERENCES User(user_id),
    name VARCHAR NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR NOT NULL,
    price_per_night DECIMAL NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### Booking

```sql
CREATE TABLE Booking (
    booking_id UUID PRIMARY KEY,
    property_id UUID REFERENCES Property(property_id),
    user_id UUID REFERENCES User(user_id),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

> Note: `total_price` is removed; can be calculated as `DATEDIFF(end_date, start_date) * price_per_night`.

### Payment

```sql
CREATE TABLE Payment (
    payment_id UUID PRIMARY KEY,
    booking_id UUID REFERENCES Booking(booking_id),
    amount DECIMAL NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL
);
```

### Review

```sql
CREATE TABLE Review (
    review_id UUID PRIMARY KEY,
    property_id UUID REFERENCES Property(property_id),
    user_id UUID REFERENCES User(user_id),
    rating INT CHECK(rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

### Message

```sql
CREATE TABLE Message (
    message_id UUID PRIMARY KEY,
    sender_id UUID REFERENCES User(user_id),
    recipient_id UUID REFERENCES User(user_id),
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

---

## Normalization Steps Summary

1. **1NF (Atomicity)**

   * Ensured all tables have atomic values and no repeating groups.

2. **2NF (No Partial Dependencies)**

   * All tables use single-column primary keys. ✅

3. **3NF (No Transitive Dependencies)**

   * Removed `total_price` from Booking to avoid dependency on `Property.price_per_night`.
   * Ensured all non-key attributes depend only on the primary key of the table.

4. **FK & Constraints**

   * Added necessary foreign keys and constraints to maintain referential integrity.
   * Added CHECK constraints for rating and ENUM constraints for status and payment_method.

5. **Indexes**

   * Primary keys are automatically indexed.
   * Additional indexes:

     * `User.email`
     * `Property.property_id`
     * `Booking.booking_id`
     * `Booking.property_id`
     * `Payment.booking_id`

---

✅ The revised schema is now fully normalized to **3NF**, ensuring minimal redundancy, better data integrity, and easier maintenance.

```mermaid
erDiagram
    USER {
        UUID user_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR email UNIQUE
        VARCHAR password_hash
        VARCHAR phone_number
        ENUM role
        TIMESTAMP created_at
    }

    PROPERTY {
        UUID property_id PK
        UUID host_id FK
        VARCHAR name
        TEXT description
        VARCHAR location
        DECIMAL price_per_night
        TIMESTAMP created_at
        TIMESTAMP updated_at
    }

    BOOKING {
        UUID booking_id PK
        UUID property_id FK
        UUID user_id FK
        DATE start_date
        DATE end_date
        ENUM status
        TIMESTAMP created_at
    }

    PAYMENT {
        UUID payment_id PK
        UUID booking_id FK
        DECIMAL amount
        TIMESTAMP payment_date
        ENUM payment_method
    }

    REVIEW {
        UUID review_id PK
        UUID property_id FK
        UUID user_id FK
        INT rating
        TEXT comment
        TIMESTAMP created_at
    }

    MESSAGE {
        UUID message_id PK
        UUID sender_id FK
        UUID recipient_id FK
        TEXT message_body
        TIMESTAMP sent_at
    }

    %% Relationships
    USER ||--o{ PROPERTY : "hosts"
    USER ||--o{ BOOKING : "makes"
    USER ||--o{ REVIEW : "writes"
    USER ||--o{ MESSAGE : "sends"
    PROPERTY ||--o{ BOOKING : "booked_in"
    PROPERTY ||--o{ REVIEW : "receives"
    BOOKING ||--o{ PAYMENT : "has"
    USER ||--o{ MESSAGE : "receives"
```

### Features of this Diagram

* **Primary keys (PK)** are marked.
* **Foreign keys (FK)** indicate relationships.
* **One-to-many relationships** are represented (`||--o{`).
* The diagram reflects **3NF**, with no transitive dependencies.
