-- VIEWS AND STORED PROCEDURES
-- Requires schema and imported CSV data.
-- Views are reusable SELECT statements; procedures store callable SQL routines.

--Create an inventory summary view
-- View labels stock Out of Stock, Low Stock, or In Stock.
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
-- View combines order, customer, warehouse, and product-line details.
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
-- Creates and calls a procedure returning all products.
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
-- Input parameter filters products by category ID.
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



SELECT
    category_id,
    category_name
FROM categories
ORDER BY category_id;

--GetCustomerOrders
-- Input customer ID returns order totals.
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
-- Input warehouse ID returns stock details and status.
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
