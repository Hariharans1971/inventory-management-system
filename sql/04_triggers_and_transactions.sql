-- TRIGGERS AND TRANSACTIONS
-- Requires schema and imported CSV data.
-- Triggers validate table changes automatically.
-- Transactions use COMMIT to save and ROLLBACK to undo uncommitted changes.

--triggers
--Prevent negative stock on INSERT
-- BEFORE INSERT rejects negative starting stock.
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
-- BEFORE UPDATE rejects changes that make stock negative.
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
-- UPDATE warehouse_inventory
-- SET quantity_available = -10
-- WHERE inventory_id = 1;
-- INSERT INTO warehouse_inventory
--     (warehouse_id, product_id, quantity_available)
-- VALUES
--     (1, 1, -10);
SHOW TRIGGERS
FROM inventory_management;

--Practise START TRANSACTION and ROLLBACK
-- Temporary stock update is undone; original quantity should return.
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
