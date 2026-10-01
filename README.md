# Inventory Management System using MySQL

A relational database project built with **MySQL 8** and **MySQL Workbench** to manage products, suppliers, warehouses, inventory, purchasing, sales, payments, employees, and stock movements.

## Project Overview

The Inventory Management System organizes inventory and business transaction data in a relational database. It supports SQL queries and reports for monitoring stock levels, reviewing purchase and sales activity, tracking payments, and analyzing business operations.

This project was completed as part of the **Python Full Stack training at Besant Technologies, Velachery**.

## Objectives

- Store product, category, supplier, and warehouse information.
- Track product quantities across multiple warehouses.
- Record purchase orders and purchase-order line items.
- Record customer sales orders and sales-order line items.
- Track payments and payment statuses.
- Maintain stock movement records.
- Generate operational and business reports using SQL.

## Technologies Used

- MySQL 8
- MySQL Workbench
- SQL
- CSV datasets

## Database Design

The database is named `inventory_management` and contains **13 relational tables**.

| Table | Purpose |
|---|---|
| `categories` | Product category details |
| `suppliers` | Supplier contact and profile details |
| `products` | Product information, category, supplier, price, SKU, and reorder level |
| `warehouses` | Warehouse names, locations, and contact details |
| `warehouse_inventory` | Available quantity of each product in each warehouse |
| `purchase_orders` | Purchase order headers and statuses |
| `purchase_order_items` | Products and quantities belonging to purchase orders |
| `customers` | Customer profile and contact details |
| `sales_orders` | Customer sales order headers and statuses |
| `sales_order_items` | Products, quantities, and unit prices in sales orders |
| `payments` | Payment amounts, dates, methods, and statuses |
| `employees` | Employee details and roles |
| `stock_movements` | Stock movement type, quantity, date, employee, and reference information |

The ER diagram is included as `inventory_management.png`.

## Dataset

The project uses synthetic CSV data for demonstration and testing. The dataset contains **5,795 rows across 13 tables**.

| Table | Rows |
|---|---:|
| `categories` | 8 |
| `suppliers` | 20 |
| `products` | 150 |
| `warehouses` | 6 |
| `warehouse_inventory` | 900 |
| `purchase_orders` | 120 |
| `purchase_order_items` | 466 |
| `customers` | 400 |
| `sales_orders` | 500 |
| `sales_order_items` | 1,500 |
| `payments` | 500 |
| `employees` | 25 |
| `stock_movements` | 1,200 |
| **Total** | **5,795** |

The records are fictional and are intended for learning, demonstration, and SQL practice.

## SQL Concepts Demonstrated

The SQL script includes work covering:

- Database and table creation
- Primary keys, foreign keys, unique constraints, and InnoDB tables
- SELECT, filtering, sorting, and limiting results
- Aggregate functions, GROUP BY, and HAVING
- INNER JOIN and LEFT JOIN
- CASE expressions
- Common Table Expressions (CTEs)
- Date-based analysis and monthly reports
- Views
- Stored procedures
- Triggers for preventing negative inventory quantities
- Transactions using START TRANSACTION, COMMIT, and ROLLBACK
- Indexes and query-plan inspection using EXPLAIN
- ANALYZE TABLE and data validation
- Inventory, sales, payments, supplier, and purchase reports

## Database Objects

### Views

- `vw_product_details`
- `vw_inventory_summary`
- `vw_sales_details`

### Stored Procedures

- `GetAllProducts()`
- `GetProductsByCategory()`
- `GetCustomerOrders()`
- `GetWarehouseStock()`

### Triggers

- `trg_check_stock_insert`
- `trg_check_stock_update`

The inventory triggers reject negative `quantity_available` values in `warehouse_inventory`.

## Project Files

A simple repository structure is:

```text
inventory-management-system/
├── inventory_management.sql
├── inventory_management.png
├── README.md
└── Datasets/
    ├── categories.csv
    ├── suppliers.csv
    ├── products.csv
    ├── warehouses.csv
    ├── warehouse_inventory.csv
    ├── purchase_orders.csv
    ├── purchase_order_items.csv
    ├── customers.csv
    ├── sales_orders.csv
    ├── sales_order_items.csv
    ├── payments.csv
    ├── employees.csv
    └── stock_movements.csv
```

## Setup and Usage

### Requirements

- MySQL Server 8.0 or later
- MySQL Workbench 8.0 or a compatible SQL client

### 1. Create the database

The SQL script includes database creation and table definitions. You can also run:

```sql
CREATE DATABASE inventory_management;
USE inventory_management;
```

### 2. Create the tables

Open `inventory_management.sql` in MySQL Workbench and run the database/table creation section first.

### 3. Import the CSV datasets

Use MySQL Workbench's **Table Data Import Wizard** to import each CSV into its matching table.

Recommended import order:

1. `categories`
2. `suppliers`
3. `warehouses`
4. `customers`
5. `employees`
6. `products`
7. `warehouse_inventory`
8. `purchase_orders`
9. `purchase_order_items`
10. `sales_orders`
11. `sales_order_items`
12. `payments`
13. `stock_movements`

Importing parent tables before dependent tables helps satisfy foreign-key relationships.

### 4. Run the SQL reports and objects

After importing the data, execute the remaining sections of `inventory_management.sql` to run reports and create the views, stored procedures, triggers, transactions, and indexes used in the project.

## Example Reports

The project includes SQL reports for:

- Product details with category and supplier information
- Inventory by warehouse
- Low-stock and out-of-stock identification
- Estimated inventory value
- Sales performance by order
- Sales summary by order status
- Monthly completed sales
- Top customers by completed sales value
- Payment analysis and pending payments
- Supplier performance
- Purchase-order status analysis
- Product-wise purchase and completed-sales comparison

## Validation

The database was validated using:

- Table row-count checks
- Foreign-key/orphan checks
- Negative inventory checks
- Duplicate warehouse/product checks
- Trigger tests for invalid stock quantities
- Transaction tests using ROLLBACK and COMMIT
- Index inspection using SHOW INDEX
- Query-plan inspection using EXPLAIN

## Important Notes and Limitations

- The dataset is synthetic and should not be treated as real business or financial data.
- Stock movement history is sample data and may not reconcile exactly with current warehouse inventory balances.
- `stock_movements.reference_id` is a general reference field and is intentionally not a foreign key to a single transaction table.
- Inventory value reports use the product's listed `unit_price`; this is an analytical estimate and not an accounting valuation.
- Sales and purchase values are analytical order values. They should not be interpreted as audited revenue, cost, or profit.

## Author

**Hariharan S.**  
B.Tech, Computer Science and Engineering (AI & ML), 2026  
Besant Technologies, Velachery — Python Full Stack Training

---

*This project is intended for educational purposes and SQL practice.*
