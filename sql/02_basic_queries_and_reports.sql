-- BASIC QUERIES AND BUSINESS REPORTS
-- Requires the database, tables, product view, and CSV data from step 01.
-- SELECT retrieves data; WHERE filters; GROUP BY summarizes; HAVING filters groups.
-- JOIN combines related tables; subqueries and CTEs organize complex queries.

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
-- INNER JOIN returns rows with matching category and supplier.
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
-- Compares each product price with the overall average.
--Subquery: products priced above the overall average
SELECT product_id, product_name, unit_price
FROM products
WHERE unit_price > (SELECT AVG(unit_price) FROM products)
ORDER BY unit_price DESC;

--CTE: total completed sales value by product
-- CTE names completed-sales totals for the main query.
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
-- DENSE_RANK ranks sales values while retaining each product row.
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
-- Lists items at or below their reorder threshold.
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
-- Estimates stock value as quantity multiplied by unit price.
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
-- Calculates units and order value for each sales order.
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
-- Groups completed sales by month.
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
-- Compares payment count, total, and average by method and status.
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
-- Summarizes purchase volume and value by supplier.
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
-- CTEs compare received purchases with completed sales by product.
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
