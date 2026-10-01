-- INDEXES, QUERY OPTIMIZATION, AND VALIDATION
-- Requires schema and imported CSV data.
-- Indexes can speed up searches; EXPLAIN displays the query plan.
-- Final validation queries check for common data-integrity issues.

--SQL indexes
--Explore existing indexes
-- SHOW INDEX lists indexes defined on these tables.
SHOW INDEX FROM products;
SHOW INDEX FROM sales_orders;
SHOW INDEX FROM sales_order_items;
SHOW INDEX FROM stock_movements;

--Understand how indexes help
-- EXPLAIN displays the execution plan MySQL chooses.
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
-- Integrity checks should return no rows when data is consistent.
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
