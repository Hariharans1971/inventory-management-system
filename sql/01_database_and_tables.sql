-- INVENTORY MANAGEMENT SYSTEM
-- Author: Hariharan S.
-- Database: MySQL 8
-- Split project script. Run files in numbered order as described in README.
-- Dataset import is a manual step between schema and reports.

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

-- Create the product view before any query or procedure uses it.
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

-- PAUSE: import CSVs in this foreign-key order before reports:
-- categories, suppliers, warehouses, customers, employees, products,
-- warehouse_inventory, purchase_orders, purchase_order_items, sales_orders,
-- sales_order_items, payments, stock_movements.

-- PAUSE: import the CSV data into all 13 tables before running report queries.
-- Import order is listed in README.md.
