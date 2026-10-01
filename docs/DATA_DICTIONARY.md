# Inventory Management System — Data Dictionary

This data dictionary summarizes the columns and relationships in the MySQL schema. Confirm exact column definitions in `sql/01_database_and_tables.sql` before making schema changes.

| Table | Column | Type | Key / rule | Description |
|---|---|---|---|---|
| categories | category_id | INT | PK | Unique category identifier |
| categories | category_name | VARCHAR(100) | NOT NULL | Category label |
| categories | description | TEXT | — | Category description |
| suppliers | supplier_id | INT | PK | Unique supplier identifier |
| suppliers | supplier_name | VARCHAR(150) | NOT NULL | Supplier name |
| suppliers | email | VARCHAR(150) | — | Supplier email |
| suppliers | phone | VARCHAR(20) | — | Supplier phone |
| suppliers | address | TEXT | — | Supplier address |
| suppliers | created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation time |
| warehouses | warehouse_id | INT | PK | Unique warehouse identifier |
| warehouses | warehouse_name | VARCHAR(150) | NOT NULL | Warehouse name |
| warehouses | location | VARCHAR(255) | — | Warehouse location |
| warehouses | contact_number | VARCHAR(20) | — | Warehouse contact number |
| customers | customer_id | INT | PK | Unique customer identifier |
| customers | customer_name | VARCHAR(150) | NOT NULL | Customer name |
| customers | email | VARCHAR(150) | — | Customer email |
| customers | phone | VARCHAR(20) | — | Customer phone |
| customers | address | TEXT | — | Customer address |
| customers | created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation time |
| employees | employee_id | INT | PK | Unique employee identifier |
| employees | employee_name | VARCHAR(150) | NOT NULL | Employee name |
| employees | email | VARCHAR(150) | — | Employee email |
| employees | role | VARCHAR(100) | — | Employee role |
| employees | hire_date | DATE | — | Hire date |
| products | product_id | INT | PK | Unique product identifier |
| products | product_name | VARCHAR(150) | NOT NULL | Product name |
| products | category_id | INT | FK → categories | Product category |
| products | supplier_id | INT | FK → suppliers | Associated supplier |
| products | unit_price | DECIMAL(10,2) | NOT NULL | Listed product unit price |
| products | reorder_level | INT | DEFAULT 10 | Stock threshold for replenishment review |
| products | sku | VARCHAR(50) | UNIQUE | Stock keeping unit |
| products | created_at | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Record creation time |
| warehouse_inventory | inventory_id | INT | PK | Unique inventory-row identifier |
| warehouse_inventory | warehouse_id | INT | FK → warehouses | Warehouse holding the stock |
| warehouse_inventory | product_id | INT | FK → products | Product being stocked |
| warehouse_inventory | quantity_available | INT | NOT NULL, DEFAULT 0 | Current available quantity |
| warehouse_inventory | last_updated | TIMESTAMP | Auto-updated | Last update timestamp |
| purchase_orders | purchase_order_id | INT | PK | Unique purchase order |
| purchase_orders | supplier_id | INT | FK → suppliers, NOT NULL | Supplier receiving the order |
| purchase_orders | warehouse_id | INT | FK → warehouses, NOT NULL | Destination warehouse |
| purchase_orders | order_date | DATE | — | Purchase order date |
| purchase_orders | expected_date | DATE | — | Expected delivery date |
| purchase_orders | status | VARCHAR(50) | — | Purchase order status |
| purchase_order_items | purchase_item_id | INT | PK | Unique purchase line |
| purchase_order_items | purchase_order_id | INT | FK → purchase_orders, NOT NULL | Parent purchase order |
| purchase_order_items | product_id | INT | FK → products, NOT NULL | Ordered product |
| purchase_order_items | quantity | INT | NOT NULL | Ordered quantity |
| purchase_order_items | unit_cost | DECIMAL(10,2) | NOT NULL | Purchase unit cost |
| sales_orders | sales_order_id | INT | PK | Unique sales order |
| sales_orders | customer_id | INT | FK → customers, NOT NULL | Customer placing order |
| sales_orders | warehouse_id | INT | FK → warehouses, NOT NULL | Warehouse associated with order |
| sales_orders | order_date | DATE | — | Sales order date |
| sales_orders | order_status | VARCHAR(50) | — | Sales order status |
| sales_order_items | sales_item_id | INT | PK | Unique sales line |
| sales_order_items | sales_order_id | INT | FK → sales_orders, NOT NULL | Parent sales order |
| sales_order_items | product_id | INT | FK → products, NOT NULL | Sold product |
| sales_order_items | quantity | INT | NOT NULL | Sold quantity |
| sales_order_items | unit_price | DECIMAL(10,2) | NOT NULL | Sale unit price |
| payments | payment_id | INT | PK | Unique payment identifier |
| payments | sales_order_id | INT | FK → sales_orders, NOT NULL | Related sales order |
| payments | payment_date | DATE | — | Payment date |
| payments | amount | DECIMAL(10,2) | NOT NULL | Payment amount |
| payments | payment_method | VARCHAR(50) | — | Payment method |
| payments | payment_status | VARCHAR(50) | — | Payment status |
| stock_movements | movement_id | INT | PK | Unique movement identifier |
| stock_movements | product_id | INT | FK → products, NOT NULL | Product moved |
| stock_movements | warehouse_id | INT | FK → warehouses, NOT NULL | Related warehouse |
| stock_movements | employee_id | INT | FK → employees | Employee recording movement |
| stock_movements | movement_type | VARCHAR(50) | — | Type of stock movement |
| stock_movements | quantity | INT | NOT NULL | Movement quantity |
| stock_movements | movement_date | DATETIME | — | Movement timestamp |
| stock_movements | reference_id | INT | — | General reference to related activity; no single-table FK |

## Constraint notes
- Primary keys uniquely identify rows.
- Foreign keys connect dependent rows to parent records.
- `products.sku` is unique.
- `warehouse_inventory` has a unique constraint on `(warehouse_id, product_id)`.
- `purchase_order_items` and `sales_order_items` each have a unique constraint on the order/product pair.
- Monetary values use `DECIMAL(10,2)` to avoid binary floating-point representation for stored currency-like amounts.
- The schema's stock triggers validate non-negative `warehouse_inventory.quantity_available`; they do not automatically update inventory from order activity.
