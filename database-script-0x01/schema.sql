-- =========================================
-- AirBnB Database Schema - 3NF
-- =========================================

-- ======================
-- Table: User
-- ======================
CREATE TABLE IF NOT EXISTS "User" (
    user_id UUID PRIMARY KEY,
    first_name VARCHAR(255) NOT NULL,
    last_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    role ENUM('guest', 'host', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_user_email ON "User"(email);

-- ======================
-- Table: Property
-- ======================
CREATE TABLE IF NOT EXISTS Property (
    property_id UUID PRIMARY KEY,
    host_id UUID NOT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    location VARCHAR(255) NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_host FOREIGN KEY (host_id) REFERENCES "User"(user_id)
);

CREATE INDEX idx_property_id ON Property(property_id);

-- ======================
-- Table: Booking
-- ======================
CREATE TABLE IF NOT EXISTS Booking (
    booking_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status ENUM('pending', 'confirmed', 'canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_property FOREIGN KEY (property_id) REFERENCES Property(property_id),
    CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "User"(user_id)
);

CREATE INDEX idx_booking_id ON Booking(booking_id);
CREATE INDEX idx_booking_property_id ON Booking(property_id);

-- ======================
-- Table: Payment
-- ======================
CREATE TABLE IF NOT EXISTS Payment (
    payment_id UUID PRIMARY KEY,
    booking_id UUID NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    payment_method ENUM('credit_card', 'paypal', 'stripe') NOT NULL,
    CONSTRAINT fk_booking FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
);

CREATE INDEX idx_payment_id ON Payment(payment_id);
CREATE INDEX idx_payment_booking_id ON Payment(booking_id);

-- ======================
-- Table: Review
-- ======================
CREATE TABLE IF NOT EXISTS Review (
    review_id UUID PRIMARY KEY,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_review_property FOREIGN KEY (property_id) REFERENCES Property(property_id),
    CONSTRAINT fk_review_user FOREIGN KEY (user_id) REFERENCES "User"(user_id)
);

-- ======================
-- Table: Message
-- ======================
CREATE TABLE IF NOT EXISTS Message (
    message_id UUID PRIMARY KEY,
    sender_id UUID NOT NULL,
    recipient_id UUID NOT NULL,
    message_body TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sender FOREIGN KEY (sender_id) REFERENCES "User"(user_id),
    CONSTRAINT fk_recipient FOREIGN KEY (recipient_id) REFERENCES "User"(user_id)
);
