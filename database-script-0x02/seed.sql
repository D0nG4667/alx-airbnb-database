-- =========================================
-- AirBnB Database - Sample Data Seed
-- =========================================

-- ======================
-- Users
-- ======================
INSERT INTO "User" (user_id, first_name, last_name, email, password_hash, phone_number, role)
VALUES
('11111111-1111-1111-1111-111111111111', 'Alice', 'Smith', 'alice@example.com', 'hash1', '555-0100', 'guest'),
('22222222-2222-2222-2222-222222222222', 'Bob', 'Johnson', 'bob@example.com', 'hash2', '555-0200', 'host'),
('33333333-3333-3333-3333-333333333333', 'Carol', 'Williams', 'carol@example.com', 'hash3', NULL, 'guest'),
('44444444-4444-4444-4444-444444444444', 'David', 'Brown', 'david@example.com', 'hash4', '555-0400', 'host');

-- ======================
-- Properties
-- ======================
INSERT INTO Property (property_id, host_id, name, description, location, price_per_night)
VALUES
('aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '22222222-2222-2222-2222-222222222222', 'Sunny Apartment', 'Cozy apartment in the city center', 'New York, NY', 120.00),
('aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '44444444-4444-4444-4444-444444444444', 'Beach House', 'Ocean view house with 3 bedrooms', 'Miami, FL', 250.00);

-- ======================
-- Bookings
-- ======================
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, status)
VALUES
('bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', '2025-11-01', '2025-11-05', 'confirmed'),
('bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333', '2025-12-10', '2025-12-15', 'pending');

-- ======================
-- Payments
-- ======================
INSERT INTO Payment (payment_id, booking_id, amount, payment_method)
VALUES
('ccccccc1-cccc-cccc-cccc-ccccccccccc1', 'bbbbbbb1-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 480.00, 'credit_card'),
('ccccccc2-cccc-cccc-cccc-ccccccccccc2', 'bbbbbbb2-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 1250.00, 'paypal');

-- ======================
-- Reviews
-- ======================
INSERT INTO Review (review_id, property_id, user_id, rating, comment)
VALUES
('ddddddd1-dddd-dddd-dddd-ddddddddddd1', 'aaaaaaa1-aaaa-aaaa-aaaa-aaaaaaaaaaa1', '11111111-1111-1111-1111-111111111111', 5, 'Great stay, very clean and cozy!'),
('ddddddd2-dddd-dddd-dddd-ddddddddddd2', 'aaaaaaa2-aaaa-aaaa-aaaa-aaaaaaaaaaa2', '33333333-3333-3333-3333-333333333333', 4, 'Beautiful view, but a bit noisy at night.');

-- ======================
-- Messages
-- ======================
INSERT INTO Message (message_id, sender_id, recipient_id, message_body)
VALUES
('eeeeeee1-eeee-eeee-eeee-eeeeeeeeeee1', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-222222222222', 'Hi Bob, is the apartment available for next weekend?'),
('eeeeeee2-eeee-eeee-eeee-eeeeeeeeeee2', '22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Yes Alice, it is available!'),
('eeeeeee3-eeee-eeee-eeee-eeeeeeeeeee3', '33333333-3333-3333-3333-333333333333', '44444444-4444-4444-4444-444444444444', 'Hi David, can I book the beach house for December?');
