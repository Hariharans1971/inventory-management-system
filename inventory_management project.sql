-- ==========================================
-- INVENTORY MANAGEMENT SYSTEM
-- Author: Hariharan S.
-- Database: MySQL 8
-- ==========================================

-- 1. DATABASE CREATION

-- 2. TABLE CREATION

-- 3. BASIC SQL QUERIES

-- 4. JOINS

-- 5. SUBQUERIES AND CTEs

-- 6. WINDOW FUNCTIONS

-- 7. BUSINESS REPORTS

-- 8. VIEWS

-- 9. STORED PROCEDURES

-- 10. TRIGGERS

-- 11. TRANSACTIONS

-- 12. INDEXES AND QUERY OPTIMIZATION

-- 13. VALIDATION QUERIES

CREATE DATABASE IF NOT EXISTS inventory_management;
USE inventory_management;
SHOW databases;

CREATE TABLE IF NOT EXISTS categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100) NOT NULL,
    description TEXT
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS suppliers (
    supplier_id INT PRIMARY KEY,
    supplier_name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS warehouses (
    warehouse_id INT PRIMARY KEY,
    warehouse_name VARCHAR(150) NOT NULL,
    location VARCHAR(255),
    contact_number VARCHAR(20)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    phone VARCHAR(20),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS employees (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(150) NOT NULL,
    email VARCHAR(150),
    role VARCHAR(100),
    hire_date DATE
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(150) NOT NULL,
    category_id INT,
    supplier_id INT,
    unit_price DECIMAL(10,2) NOT NULL,
    reorder_level INT DEFAULT 10,
    sku VARCHAR(50) UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id)
        REFERENCES categories(category_id),
    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS warehouse_inventory (
    inventory_id INT PRIMARY KEY,
    warehouse_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity_available INT NOT NULL DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE (warehouse_id, product_id),
    FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_orders (
    purchase_order_id INT PRIMARY KEY,
    supplier_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    order_date DATE,
    expected_date DATE,
    status VARCHAR(50),
    FOREIGN KEY (supplier_id)
        REFERENCES suppliers(supplier_id),
    FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS purchase_order_items (
    purchase_item_id INT PRIMARY KEY,
    purchase_order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,
    UNIQUE (purchase_order_id, product_id),
    FOREIGN KEY (purchase_order_id)
        REFERENCES purchase_orders(purchase_order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sales_orders (
    sales_order_id INT PRIMARY KEY,
    customer_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    order_date DATE,
    order_status VARCHAR(50),
    FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id),
    FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS sales_order_items (
    sales_item_id INT PRIMARY KEY,
    sales_order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    UNIQUE (sales_order_id, product_id),
    FOREIGN KEY (sales_order_id)
        REFERENCES sales_orders(sales_order_id),
    FOREIGN KEY (product_id)
        REFERENCES products(product_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS payments (
    payment_id INT PRIMARY KEY,
    sales_order_id INT NOT NULL,
    payment_date DATE,
    amount DECIMAL(10,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_status VARCHAR(50),
    FOREIGN KEY (sales_order_id)
        REFERENCES sales_orders(sales_order_id)
) ENGINE=InnoDB;

CREATE TABLE IF NOT EXISTS stock_movements (
    movement_id INT PRIMARY KEY,
    product_id INT NOT NULL,
    warehouse_id INT NOT NULL,
    employee_id INT,
    movement_type VARCHAR(50),
    quantity INT NOT NULL,
    movement_date DATETIME,
    reference_id INT,
    FOREIGN KEY (product_id)
        REFERENCES products(product_id),
    FOREIGN KEY (warehouse_id)
        REFERENCES warehouses(warehouse_id),
    FOREIGN KEY (employee_id)
        REFERENCES employees(employee_id)
) ENGINE=InnoDB;

SHOW TABLES;

--Check all 13 table counts
SELECT 'categories' AS table_name, COUNT(*) AS total FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL SELECT 'warehouse_inventory', COUNT(*) FROM warehouse_inventory
UNION ALL SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL SELECT 'purchase_order_items', COUNT(*) FROM purchase_order_items
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales_orders', COUNT(*) FROM sales_orders
UNION ALL SELECT 'sales_order_items', COUNT(*) FROM sales_order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'stock_movements', COUNT(*) FROM stock_movements;

--View complete product details
SELECT
    p.product_id,
    p.product_name,
    c.category_name,
    s.supplier_name,
    p.unit_price,
    p.reorder_level,
    p.sku
FROM products p
INNER JOIN categories c
    ON p.category_id = c.category_id
INNER JOIN suppliers s
    ON p.supplier_id = s.supplier_id
ORDER BY p.product_id;

--Subquery: products priced above the overall average
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

--CTE: total completed sales value by product
WITH completed_product_sales AS (
    SELECT
        soi.product_id,
        SUM(soi.quantity) AS units_sold,
        SUM(soi.quantity * soi.unit_price) AS sales_value
    FROM sales_order_items soi
    INNER JOIN sales_orders so
        ON soi.sales_order_id = so.sales_order_id
    WHERE so.order_status = 'Completed'
    GROUP BY soi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    COALESCE(cps.units_sold, 0) AS units_sold,
    ROUND(COALESCE(cps.sales_value, 0), 2) AS sales_value
FROM products p
LEFT JOIN completed_product_sales cps
    ON p.product_id = cps.product_id
ORDER BY sales_value DESC;

--Window function: rank products by total completed sales value
WITH product_sales AS (
    SELECT
        p.product_id,
        p.product_name,
        COALESCE(SUM(CASE WHEN so.order_status = 'Completed' THEN soi.quantity * soi.unit_price ELSE 0 END), 0) AS sales_value
    FROM products p
    LEFT JOIN sales_order_items soi
        ON p.product_id = soi.product_id
    LEFT JOIN sales_orders so
        ON soi.sales_order_id = so.sales_order_id
    GROUP BY p.product_id, p.product_name
)
SELECT
    product_id,
    product_name,
    ROUND(sales_value, 2) AS sales_value,
    DENSE_RANK() OVER (ORDER BY sales_value DESC) AS sales_rank
FROM product_sales
ORDER BY sales_rank, product_name;

--CRUD practice templates (uncomment and adapt IDs before use)
-- INSERT INTO categories (category_id, category_name, description)
-- VALUES (999, 'Sample Category', 'Temporary practice record');
-- UPDATE categories SET category_name = 'Updated Sample'
-- WHERE category_id = 999;
-- DELETE FROM categories WHERE category_id = 999;

--Inventory report by warehouse
SELECT
    w.warehouse_name,
    p.product_id,
    p.product_name,
    wi.quantity_available,
    p.reorder_level,
    CASE
        WHEN wi.quantity_available = 0 THEN 'Out of Stock'
        ELSE 'Low Stock'
    END AS stock_status
FROM warehouse_inventory wi
INNER JOIN warehouses w
    ON wi.warehouse_id = w.warehouse_id
INNER JOIN products p
    ON wi.product_id = p.product_id
WHERE wi.quantity_available <= p.reorder_level
ORDER BY wi.quantity_available ASC;

--Total inventory value
--inventory value = quantity available * unit price
SELECT
    p.product_id,
    p.product_name,
    SUM(wi.quantity_available) AS total_stock,
    p.unit_price,
    SUM(wi.quantity_available * p.unit_price)
        AS total_inventory_value
FROM products p
INNER JOIN warehouse_inventory wi
    ON p.product_id = wi.product_id
GROUP BY
    p.product_id,
    p.product_name,
    p.unit_price
ORDER BY total_inventory_value DESC;

--Overall inventory value
SELECT
    SUM(wi.quantity_available) AS total_units,
    ROUND(
        SUM(wi.quantity_available * p.unit_price),
        2
    ) AS total_inventory_value
FROM warehouse_inventory wi
INNER JOIN products p
    ON wi.product_id = p.product_id;
    
--Sales performance report
SELECT
    so.sales_order_id,
    c.customer_name,
    w.warehouse_name,
    so.order_date,
    so.order_status,
    SUM(soi.quantity) AS total_items,
    ROUND(
        SUM(soi.quantity * soi.unit_price),
        2
    ) AS order_value
FROM sales_orders so
INNER JOIN customers c
    ON so.customer_id = c.customer_id
INNER JOIN warehouses w
    ON so.warehouse_id = w.warehouse_id
INNER JOIN sales_order_items soi
    ON so.sales_order_id = soi.sales_order_id
GROUP BY
    so.sales_order_id,
    c.customer_name,
    w.warehouse_name,
    so.order_date,
    so.order_status
ORDER BY order_value DESC;

--Sales summary by order status
SELECT
    so.order_status,
    COUNT(DISTINCT so.sales_order_id) AS total_orders,
    SUM(soi.quantity) AS total_items,
    ROUND(
        SUM(soi.quantity * soi.unit_price), 2
    ) AS total_order_value
FROM sales_orders so
INNER JOIN sales_order_items soi
    ON so.sales_order_id = soi.sales_order_id
GROUP BY so.order_status
ORDER BY total_order_value DESC;

--Monthly completed sales
SELECT
    DATE_FORMAT(so.order_date, '%Y-%m') AS sales_month,
    COUNT(DISTINCT so.sales_order_id) AS completed_orders,
    SUM(soi.quantity) AS total_units_sold,
    ROUND(
        SUM(soi.quantity * soi.unit_price), 2
    ) AS completed_sales_value
FROM sales_orders so
INNER JOIN sales_order_items soi
    ON so.sales_order_id = soi.sales_order_id
WHERE so.order_status = 'Completed'
GROUP BY DATE_FORMAT(so.order_date, '%Y-%m')
ORDER BY sales_month;

--Top 10 customers by completed sales
SELECT
    c.customer_id,
    c.customer_name,
    COUNT(DISTINCT so.sales_order_id) AS completed_orders,
    SUM(soi.quantity) AS total_units,
    ROUND(
        SUM(soi.quantity * soi.unit_price), 2
    ) AS completed_sales_value
FROM customers c
INNER JOIN sales_orders so
    ON c.customer_id = so.customer_id
INNER JOIN sales_order_items soi
    ON so.sales_order_id = soi.sales_order_id
WHERE so.order_status = 'Completed'
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY completed_sales_value DESC
LIMIT 10;

--Payment analysis
SELECT
    payment_method,
    payment_status,
    COUNT(payment_id) AS total_payments,
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(AVG(amount), 2) AS average_payment
FROM payments
GROUP BY
    payment_method,
    payment_status
ORDER BY
    payment_method,
    payment_status;
    
--Pending payments report
SELECT
    p.payment_id,
    c.customer_id,
    c.customer_name,
    so.sales_order_id,
    so.order_date,
    p.payment_date,
    p.payment_method,
    p.amount,
    p.payment_status
FROM payments p
INNER JOIN sales_orders so
    ON p.sales_order_id = so.sales_order_id
INNER JOIN customers c
    ON so.customer_id = c.customer_id
WHERE p.payment_status = 'Pending'
ORDER BY p.amount DESC;

--Total completed payments
SELECT
    COUNT(*) AS completed_payments,
    ROUND(SUM(amount), 2) AS total_completed_amount,
    ROUND(AVG(amount), 2) AS average_completed_payment
FROM payments
WHERE payment_status = 'Completed';

--Supplier performance report
SELECT
    s.supplier_id,
    s.supplier_name,
    COUNT(DISTINCT po.purchase_order_id) AS total_orders,
    SUM(poi.quantity) AS total_units_ordered,
    ROUND(
        SUM(poi.quantity * poi.unit_cost), 2
    ) AS total_purchase_value
FROM suppliers s
INNER JOIN purchase_orders po
    ON s.supplier_id = po.supplier_id
INNER JOIN purchase_order_items poi
    ON po.purchase_order_id = poi.purchase_order_id
GROUP BY
    s.supplier_id,
    s.supplier_name
ORDER BY total_purchase_value DESC;

--Purchase order status report
SELECT
    po.status,
    COUNT(DISTINCT po.purchase_order_id) AS total_orders,
    SUM(poi.quantity) AS total_units,
    ROUND(
        SUM(poi.quantity * poi.unit_cost), 2
    ) AS total_purchase_value
FROM purchase_orders po
INNER JOIN purchase_order_items poi
    ON po.purchase_order_id = poi.purchase_order_id
GROUP BY po.status
ORDER BY total_purchase_value DESC;

--Product-wise purchase and sales comparison
WITH purchase_summary AS (
    SELECT
        poi.product_id,
        SUM(poi.quantity) AS units_purchased,
        ROUND(SUM(poi.quantity * poi.unit_cost), 2)
            AS purchase_value
    FROM purchase_order_items poi
    INNER JOIN purchase_orders po
        ON poi.purchase_order_id = po.purchase_order_id
    WHERE po.status = 'Received'
    GROUP BY poi.product_id
),
sales_summary AS (
    SELECT
        soi.product_id,
        SUM(soi.quantity) AS units_sold,
        ROUND(SUM(soi.quantity * soi.unit_price), 2)
            AS sales_value
    FROM sales_order_items soi
    INNER JOIN sales_orders so
        ON soi.sales_order_id = so.sales_order_id
    WHERE so.order_status = 'Completed'
    GROUP BY soi.product_id
)
SELECT
    p.product_id,
    p.product_name,
    COALESCE(ps.units_purchased, 0) AS units_purchased,
    COALESCE(ss.units_sold, 0) AS units_sold,
    COALESCE(ps.purchase_value, 0) AS purchase_value,
    COALESCE(ss.sales_value, 0) AS sales_value
FROM products p
LEFT JOIN purchase_summary ps
    ON p.product_id = ps.product_id
LEFT JOIN sales_summary ss
    ON p.product_id = ss.product_id
ORDER BY sales_value DESC;

--Create a product details view
SELECT *
FROM vw_product_details;
SELECT
    product_name,
    category_name,
    supplier_name,
    unit_price
FROM vw_product_details
WHERE unit_price > 1000
ORDER BY unit_price DESC;

--Create an inventory summary view
CREATE OR REPLACE VIEW vw_inventory_summary AS
SELECT
    w.warehouse_id,
    w.warehouse_name,
    w.location,
    p.product_id,
    p.product_name,
    c.category_name,
    wi.quantity_available,
    p.reorder_level,
    CASE
        WHEN wi.quantity_available = 0
            THEN 'Out of Stock'
        WHEN wi.quantity_available <= p.reorder_level
            THEN 'Low Stock'
        ELSE 'In Stock'
    END AS stock_status
FROM warehouse_inventory wi
INNER JOIN warehouses w
    ON wi.warehouse_id = w.warehouse_id
INNER JOIN products p
    ON wi.product_id = p.product_id
LEFT JOIN categories c
    ON p.category_id = c.category_id;
    
SELECT *
FROM vw_inventory_summary
ORDER BY warehouse_name, product_name;
SELECT
    warehouse_name,
    product_name,
    quantity_available,
    reorder_level,
    stock_status
FROM vw_inventory_summary
WHERE stock_status IN ('Low Stock', 'Out of Stock')
ORDER BY quantity_available ASC;

--Create a sales details view
CREATE OR REPLACE VIEW vw_sales_details AS
SELECT
    so.sales_order_id,
    c.customer_id,
    c.customer_name,
    w.warehouse_name,
    so.order_date,
    so.order_status,
    p.product_id,
    p.product_name,
    cat.category_name,
    soi.quantity,
    soi.unit_price,
    (soi.quantity * soi.unit_price) AS line_total
FROM sales_orders so
INNER JOIN customers c
    ON so.customer_id = c.customer_id
INNER JOIN warehouses w
    ON so.warehouse_id = w.warehouse_id
INNER JOIN sales_order_items soi
    ON so.sales_order_id = soi.sales_order_id
INNER JOIN products p
    ON soi.product_id = p.product_id
LEFT JOIN categories cat
    ON p.category_id = cat.category_id;
    
SELECT *
FROM vw_sales_details
LIMIT 20;
SELECT
    customer_name,
    product_name,
    quantity,
    unit_price,
    line_total,
    order_date
FROM vw_sales_details
WHERE order_status = 'Completed'
ORDER BY line_total DESC
LIMIT 20;

--Create your first stored procedure
DROP PROCEDURE IF EXISTS GetAllProducts;

DELIMITER //

CREATE PROCEDURE GetAllProducts()
BEGIN
    SELECT *
    FROM vw_product_details
    ORDER BY product_id;
END //

DELIMITER ;
CALL GetAllProducts();

--Stored procedure with a parameter
DROP PROCEDURE IF EXISTS GetProductsByCategory;

DELIMITER //

CREATE PROCEDURE GetProductsByCategory(
    IN p_category_id INT
)
BEGIN
    SELECT
        product_id,
        product_name,
        category_name,
        supplier_name,
        unit_price,
        reorder_level
    FROM vw_product_details
    WHERE category_id = p_category_id
    ORDER BY product_name;
END //

DELIMITER ;

CALL GetProductsByCategory(1);

CREATE OR REPLACE VIEW vw_product_details AS
SELECT
    p.product_id,
    p.product_name,
    p.sku,
    p.category_id,
    c.category_name,
    s.supplier_name,
    p.unit_price,
    p.reorder_level,
    p.created_at
FROM products p
LEFT JOIN categories c
    ON p.category_id = c.category_id
LEFT JOIN suppliers s
    ON p.supplier_id = s.supplier_id;

SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

--GetCustomerOrders
DROP PROCEDURE IF EXISTS GetCustomerOrders;

DELIMITER //

CREATE PROCEDURE GetCustomerOrders(
    IN p_customer_id INT
)
BEGIN
    SELECT
        c.customer_id,
        c.customer_name,
        so.sales_order_id,
        so.order_date,
        so.order_status,
        SUM(soi.quantity) AS total_units,
        ROUND(
            SUM(soi.quantity * soi.unit_price), 2
        ) AS order_value
    FROM customers c
    INNER JOIN sales_orders so
        ON c.customer_id = so.customer_id
    INNER JOIN sales_order_items soi
        ON so.sales_order_id = soi.sales_order_id
    WHERE c.customer_id = p_customer_id
    GROUP BY
        c.customer_id,
        c.customer_name,
        so.sales_order_id,
        so.order_date,
        so.order_status
    ORDER BY so.order_date DESC;
END //

DELIMITER ;
CALL GetCustomerOrders(13);

--GetWarehouseStock
DROP PROCEDURE IF EXISTS GetWarehouseStock;

DELIMITER //

CREATE PROCEDURE GetWarehouseStock(
    IN p_warehouse_id INT
)
BEGIN
    SELECT
        w.warehouse_id,
        w.warehouse_name,
        w.location,
        p.product_id,
        p.product_name,
        c.category_name,
        wi.quantity_available,
        p.reorder_level,
        CASE
            WHEN wi.quantity_available = 0
                THEN 'Out of Stock'
            WHEN wi.quantity_available <= p.reorder_level
                THEN 'Low Stock'
            ELSE 'In Stock'
        END AS stock_status
    FROM warehouse_inventory wi
    INNER JOIN warehouses w
        ON wi.warehouse_id = w.warehouse_id
    INNER JOIN products p
        ON wi.product_id = p.product_id
    LEFT JOIN categories c
        ON p.category_id = c.category_id
    WHERE w.warehouse_id = p_warehouse_id
    ORDER BY p.product_name;
END //

DELIMITER ;
CALL GetWarehouseStock(3);

--triggers
--Prevent negative stock on INSERT
DROP TRIGGER IF EXISTS trg_check_stock_insert;

DELIMITER //

CREATE TRIGGER trg_check_stock_insert
BEFORE INSERT ON warehouse_inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity_available < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END //

DELIMITER ;

--Prevent negative stock on UPDATE
DROP TRIGGER IF EXISTS trg_check_stock_update;

DELIMITER //

CREATE TRIGGER trg_check_stock_update
BEFORE UPDATE ON warehouse_inventory
FOR EACH ROW
BEGIN
    IF NEW.quantity_available < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Stock quantity cannot be negative';
    END IF;
END //

DELIMITER ;

--Test the triggers
UPDATE warehouse_inventory
SET quantity_available = -10
WHERE inventory_id = 1;
INSERT INTO warehouse_inventory
    (warehouse_id, product_id, quantity_available)
VALUES
    (1, 1, -10);
SHOW TRIGGERS
FROM inventory_management;

--Practise START TRANSACTION and ROLLBACK
SELECT
    inventory_id,
    product_id,
    warehouse_id,
    quantity_available
FROM warehouse_inventory
WHERE inventory_id = 1;

START TRANSACTION;

UPDATE warehouse_inventory
SET quantity_available = quantity_available + 5
WHERE inventory_id = 1;

SELECT
    inventory_id,
    quantity_available
FROM warehouse_inventory
WHERE inventory_id = 1;

ROLLBACK;

SELECT
    inventory_id,
    quantity_available
FROM warehouse_inventory
WHERE inventory_id = 1;

--COMMIT
CREATE TABLE transaction_demo (
    id INT PRIMARY KEY,
    description VARCHAR(100)
) ENGINE=InnoDB;

START TRANSACTION;

INSERT INTO transaction_demo
    (id, description)
VALUES
    (1, 'Transaction committed successfully');

COMMIT;

SELECT * FROM transaction_demo;

DROP TABLE transaction_demo;


--SQL indexes
--Explore existing indexes
SHOW INDEX FROM products;
SHOW INDEX FROM sales_orders;
SHOW INDEX FROM sales_order_items;
SHOW INDEX FROM stock_movements;

--Understand how indexes help
SELECT *
FROM sales_orders
WHERE customer_id = 13;
EXPLAIN
SELECT *
FROM sales_orders
WHERE customer_id = 13;

SHOW INDEX FROM payments;
SHOW INDEX FROM purchase_orders;
SHOW INDEX FROM warehouse_inventory;

--Payments by date
CREATE INDEX idx_payments_payment_date
ON payments(payment_date);
--Purchase orders by date
CREATE INDEX idx_purchase_orders_order_date
ON purchase_orders(order_date);
--Sales orders by date
CREATE INDEX idx_sales_orders_order_date
ON sales_orders(order_date);
--Product movement history by date
CREATE INDEX idx_stock_product_date
ON stock_movements(product_id, movement_date);

EXPLAIN
SELECT *
FROM sales_orders
WHERE order_date >= '2026-01-01'
  AND order_date < '2027-01-01';
ANALYZE TABLE sales_orders;

EXPLAIN
SELECT *
FROM sales_orders
FORCE INDEX (idx_sales_orders_order_date)
WHERE order_date >= '2026-01-01'
  AND order_date < '2027-01-01';

-- Final validation queries
-- Confirm row counts across all 13 tables
SELECT 'categories' AS table_name, COUNT(*) AS total FROM categories
UNION ALL SELECT 'suppliers', COUNT(*) FROM suppliers
UNION ALL SELECT 'products', COUNT(*) FROM products
UNION ALL SELECT 'warehouses', COUNT(*) FROM warehouses
UNION ALL SELECT 'warehouse_inventory', COUNT(*) FROM warehouse_inventory
UNION ALL SELECT 'purchase_orders', COUNT(*) FROM purchase_orders
UNION ALL SELECT 'purchase_order_items', COUNT(*) FROM purchase_order_items
UNION ALL SELECT 'customers', COUNT(*) FROM customers
UNION ALL SELECT 'sales_orders', COUNT(*) FROM sales_orders
UNION ALL SELECT 'sales_order_items', COUNT(*) FROM sales_order_items
UNION ALL SELECT 'payments', COUNT(*) FROM payments
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'stock_movements', COUNT(*) FROM stock_movements;

-- Check for negative inventory
SELECT inventory_id, warehouse_id, product_id, quantity_available
FROM warehouse_inventory
WHERE quantity_available < 0;

-- Check for duplicate warehouse/product pairs (should return no rows)
SELECT warehouse_id, product_id, COUNT(*) AS duplicate_count
FROM warehouse_inventory
GROUP BY warehouse_id, product_id
HAVING COUNT(*) > 1;

-- Check for orphaned product category references (should return no rows)
SELECT p.product_id, p.category_id
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
WHERE p.category_id IS NOT NULL AND c.category_id IS NULL;
