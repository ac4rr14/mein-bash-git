-- Einfaches SQL-Skript: Kunden & Bestellungen

-- 0) Sauberer Start (optional)
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customers;

-- 1) Tabellen anlegen
CREATE TABLE customers (
  id        INTEGER PRIMARY KEY,
  name      VARCHAR(100) NOT NULL,
  email     VARCHAR(255) UNIQUE
);

CREATE TABLE orders (
  id          INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  order_date  DATE     NOT NULL,
  amount      DECIMAL(10,2) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(id)
);

-- 2) Beispieldaten einfügen
INSERT INTO customers (id, name, email) VALUES
  (1, 'Anna Schmidt', 'anna@example.com'),
  (2, 'Max Müller',   'max@example.com'),
  (3, 'Lea Weber',    'lea@example.com');

INSERT INTO orders (id, customer_id, order_date, amount) VALUES
  (1, 1, '2025-10-01', 59.90),
  (2, 1, '2025-10-05', 24.50),
  (3, 2, '2025-10-06', 89.00),
  (4, 3, '2025-10-10', 15.99),
  (5, 2, '2025-10-12', 42.00);

-- 3) Nützlicher Index (beschleunigt JOINS/Filter)
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- 4) Abfragen

-- 4a) Alle Bestellungen inkl. Kundenname
SELECT
  o.id        AS order_id,
  c.name      AS customer,
  o.order_date,
  o.amount
FROM orders o
JOIN customers c ON c.id = o.customer_id
ORDER BY o.order_date;

-- 4b) Umsatz pro Kunde
SELECT
  c.id,
  c.name,
  SUM(o.amount) AS total_amount
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.id
GROUP BY c.id, c.name
ORDER BY total_amount DESC;

-- 4c) Bestellungen in einem Datumsbereich
SELECT *
FROM orders
WHERE order_date BETWEEN '2025-10-01' AND '2025-10-31'
ORDER BY order_date;

-- 5) Update-Beispiel (E-Mail von Kunde 3 ändern)
UPDATE customers
SET email = 'lea.weber@example.com'
WHERE id = 3;

-- 6) Delete-Beispiel (eine Bestellung löschen)
DELETE FROM orders
WHERE id = 5;
