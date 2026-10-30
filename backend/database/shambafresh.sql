-- =====================================================================
-- ShambaFresh database (MySQL 5.7+ / 8 / MariaDB / XAMPP)
-- Run the WHOLE file once. Running it again RESETS all data.
-- Demo password for every user:  Password123
-- =====================================================================

-- ShambaFresh database schema (MySQL / MariaDB)
-- Import in phpMyAdmin, or run:  npm run setup

CREATE DATABASE IF NOT EXISTS shambafresh CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE shambafresh;

DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS farmers;
DROP TABLE IF EXISTS contact_messages;
DROP TABLE IF EXISTS users;

-- 1. USERS: everyone who can log in (buyer, farmer or admin)
CREATE TABLE users (
  id            INT AUTO_INCREMENT PRIMARY KEY,
  full_name     VARCHAR(100) NOT NULL,
  email         VARCHAR(120) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role          ENUM('buyer','farmer','admin') NOT NULL DEFAULT 'buyer',
  phone         VARCHAR(20),
  created_at    TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. FARMERS: extra farm details for users whose role is 'farmer' (1 user : 1 farm)
CREATE TABLE farmers (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  user_id     INT NOT NULL UNIQUE,
  farm_name   VARCHAR(120) NOT NULL,
  location    VARCHAR(120) NOT NULL,
  description TEXT,
  verified    TINYINT(1) NOT NULL DEFAULT 0,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. CATEGORIES: Vegetables, Fruits, Grains & pulses, Roots & tubers
CREATE TABLE categories (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(60) NOT NULL UNIQUE,
  description VARCHAR(120),
  icon        VARCHAR(10)
);

-- 4. PRODUCTS: produce listed by farmers
CREATE TABLE products (
  id          INT AUTO_INCREMENT PRIMARY KEY,
  farmer_id   INT NOT NULL,
  category_id INT NOT NULL,
  name        VARCHAR(100) NOT NULL,
  description TEXT,
  price       DECIMAL(10,2) NOT NULL,
  unit        VARCHAR(20) NOT NULL DEFAULT 'kg',
  stock_qty   INT NOT NULL DEFAULT 0,
  badge       VARCHAR(30),
  icon        VARCHAR(10),
  is_active   TINYINT(1) NOT NULL DEFAULT 1,
  created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (farmer_id)   REFERENCES farmers(id)    ON DELETE CASCADE,
  FOREIGN KEY (category_id) REFERENCES categories(id)
);

-- 5. ORDERS: one order placed by a buyer
CREATE TABLE orders (
  id               INT AUTO_INCREMENT PRIMARY KEY,
  buyer_id         INT NOT NULL,
  total_amount     DECIMAL(10,2) NOT NULL,
  status           ENUM('pending','confirmed','delivered','cancelled') NOT NULL DEFAULT 'pending',
  delivery_address VARCHAR(255) NOT NULL,
  phone            VARCHAR(20) NOT NULL,
  payment_method   ENUM('mpesa','cash') NOT NULL DEFAULT 'mpesa',
  created_at       TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (buyer_id) REFERENCES users(id)
);

-- 6. ORDER_ITEMS: the produce inside an order (links orders and products)
CREATE TABLE order_items (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  order_id   INT NOT NULL,
  product_id INT NOT NULL,
  quantity   INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (order_id)   REFERENCES orders(id)   ON DELETE CASCADE,
  FOREIGN KEY (product_id) REFERENCES products(id)
);

-- 7. CONTACT_MESSAGES: messages sent from the Contact page
CREATE TABLE contact_messages (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  name       VARCHAR(100) NOT NULL,
  email      VARCHAR(120) NOT NULL,
  subject    VARCHAR(150),
  message    TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ========== SAMPLE DATA (hash = bcrypt of Password123) ==========

INSERT INTO users (id, full_name, email, password_hash, role, phone) VALUES
(1, 'Site Admin', 'admin@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'admin', '0700000001'),
(2, 'Brian Otieno', 'buyer@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'buyer', '0700000002'),
(3, 'Esther Njeri', 'njeri@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000001'),
(4, 'Hassan Mwinyi', 'mwinyi@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000002'),
(5, 'Faith Chebet', 'chebet@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000003'),
(6, 'David Mutua', 'mutua@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000004'),
(7, 'Rose Wambui', 'wambui@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000005'),
(8, 'Joseph Kariuki', 'kariuki@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000006'),
(9, 'Beatrice Nyamu', 'nyamu@shambafresh.co.ke', '$2a$10$LwVoUTC3eAKrkdtUD6gnneUqCDct4DNPBhAPgtRvvKPChcqnUK05C', 'farmer', '0722000007');

INSERT INTO farmers (id, user_id, farm_name, location, description, verified) VALUES
(1, 3, 'Njeri Greens', 'Limuru', 'Leafy greens and carrots grown in the cool Limuru highlands.', 1),
(2, 4, 'Pwani Fresh Farm', 'Kilifi', 'Coconuts and tropical produce from the Kenyan coast.', 1),
(3, 5, 'Chebet Highlands', 'Uasin Gishu', 'Pulses and grains grown on family land near Eldoret.', 1),
(4, 6, 'Mutua Dryland Farm', 'Kitui', 'Drought-tolerant sorghum and millet from eastern Kenya.', 1),
(5, 7, 'Wambui Orchards', 'Murang''a', 'Hass avocado orchards on the slopes of the Aberdares.', 1),
(6, 8, 'Kariuki Roots', 'Meru', 'Arrow roots, yams and other root crops from Meru.', 1),
(7, 9, 'Rift Valley Co-op', 'Nakuru', 'A cooperative of 60 growers supplying cabbages and kale.', 1);

INSERT INTO categories (id, name, description, icon) VALUES
(1, 'Vegetables', 'Crisp, green and local', '🥬'),
(2, 'Fruits', 'Ripe and ready to eat', '🥑'),
(3, 'Grains & pulses', 'Protein-rich pantry basics', '🌾'),
(4, 'Roots & tubers', 'Hearty and filling', '🥔');

INSERT INTO products (id, farmer_id, category_id, name, description, price, unit, stock_qty, badge, icon) VALUES
(1, 1, 1, 'Fresh Spinach', 'Tender spinach leaves, washed and bundled.', 40, 'bunch', 180, 'Fresh today', '🥬'),
(2, 2, 2, 'Coastal Coconuts', 'Mature coconuts from the Kilifi coast, full of sweet water.', 60, 'piece', 300, 'Coastal', '🥥'),
(3, 3, 3, 'Green Grams', 'Clean, sorted green grams (ndengu) from Uasin Gishu.', 180, 'kg', 250, 'Protein-rich', '🫘'),
(4, 4, 3, 'Sorghum', 'Whole-grain sorghum from Kitui, ideal for porridge and ugali.', 85, 'kg', 400, 'Staple', '🌾'),
(5, 5, 2, 'Hass Avocados', 'Creamy, rich Hass avocados from Murang''a.', 25, 'piece', 500, 'Popular', '🥑'),
(6, 6, 4, 'Arrow Roots', 'Fresh arrow roots (nduma), boiled or fried.', 110, 'kg', 100, 'Farm fresh', '🥔'),
(7, 7, 1, 'Cabbages', 'Firm, heavy cabbages from the Rift Valley.', 50, 'piece', 350, 'Good value', '🥬'),
(8, 1, 1, 'Carrots', 'Sweet, crunchy Limuru carrots.', 90, 'kg', 140, 'Crunchy', '🥕');

INSERT INTO orders (id, buyer_id, total_amount, status, delivery_address, phone, payment_method) VALUES
(1, 2, 320, 'confirmed', 'Westlands, Nairobi', '0700000002', 'mpesa');

INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 3, 40),
(1, 5, 2, 25);

-- Check: 9 users, 7 farmers, 4 categories, 8 products, 1 order, 2 items
SELECT (SELECT COUNT(*) FROM users) users,(SELECT COUNT(*) FROM farmers) farmers,(SELECT COUNT(*) FROM categories) categories,(SELECT COUNT(*) FROM products) products,(SELECT COUNT(*) FROM orders) orders,(SELECT COUNT(*) FROM order_items) order_items;