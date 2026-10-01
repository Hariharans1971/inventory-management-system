# Inventory Management System Using MySQL
## Project Documentation

**Author:** Hariharan S.  
**Degree:** B.Tech, Computer Science and Engineering (AI & ML), 2026  
**Training:** Python Full Stack, Besant Technologies, Velachery  
**Database:** MySQL 8 / InnoDB  
**Project type:** Relational database and SQL analytics project

## 1. Abstract
The Inventory Management System is a relational database project designed to organize product, supplier, warehouse, inventory, purchasing, sales, payment, employee, and stock-movement information. It uses MySQL 8 to store connected business records and SQL queries to retrieve and analyze them. The database includes 13 related tables, primary and foreign keys, reusable views, stored procedures, triggers, transactions, indexes, and business reports. Synthetic CSV data is used to demonstrate database operations and reporting. The project is intended for learning and demonstration; it is not a deployed inventory application or an audited financial system.

## 2. Introduction
Inventory information is spread across different business activities: products are sourced from suppliers, stored in warehouses, ordered by customers, and associated with payments and stock changes. A relational database can keep these records structured and linked, reduce unnecessary duplication, and support consistent queries. This project models those activities in one MySQL database and demonstrates common SQL development practices.

## 3. Problem Statement
When product, stock, purchase, sales, and payment records are maintained separately, it can be difficult to retrieve a consistent view of available stock, review transaction history, identify items requiring replenishment, or summarize business activity. The project addresses this data-organization and reporting problem by creating a relational schema and reusable SQL operations.

## 4. Objectives
- Organize product, category, supplier, warehouse, customer, and employee records.
- Track available quantities for products at individual warehouses.
- Store purchase and sales orders with their line items.
- Record payment details and payment statuses.
- Maintain a historical stock-movement table.
- Use keys and constraints to represent relationships and protect referential integrity.
- Create reports for stock, purchasing, sales, and payments.
- Demonstrate views, stored procedures, triggers, transactions, and indexes.

## 5. Scope
### Included
- Database and table creation in MySQL 8.
- CSV-based sample data import.
- SQL querying and business reporting.
- Database objects for reusable queries and stock validation.
- Transaction and query-plan demonstrations.
- Validation queries for selected integrity conditions.

### Not included
- A web, mobile, or desktop user interface.
- User authentication, roles, or application-level access control.
- Live barcode scanning, supplier integrations, or real-time synchronization.
- Automatic reconciliation of stock-movement history with current stock.
- Audited accounting, tax, revenue, or profit reporting.

## 6. Technologies and Tools
| Technology | Purpose |
|---|---|
| MySQL 8 | Relational database engine |
| MySQL Workbench | SQL authoring, execution, and data import |
| SQL | Schema, queries, reports, and database objects |
| CSV | Sample data exchange and import |
| GitHub | Version control and project sharing |
| ER diagram | Visual representation of table relationships |

## 7. System Overview
The database is named `inventory_management`. It stores data in 13 InnoDB tables. Primary keys identify records, foreign keys connect dependent records, and unique constraints prevent selected duplicate combinations. Queries join these tables to generate operational reports. Views provide reusable query interfaces, procedures package common operations, and triggers reject negative available-stock values on insert or update.

### High-level workflow
1. Create the database and relational tables.
2. Import the synthetic CSV files into the corresponding tables in dependency order.
3. Run SQL queries to inspect and analyze records.
4. Create and query views and stored procedures.
5. Test stock-validation triggers and transaction behavior.
6. Inspect indexes and query plans, then run validation queries.

## 8. Database Design
The schema contains the following tables:

| Table | Responsibility |
|---|---|
| `categories` | Product category lookup |
| `suppliers` | Supplier contact and profile records |
| `products` | Product name, category, supplier, price, SKU, and reorder threshold |
| `warehouses` | Warehouse details |
| `warehouse_inventory` | Available stock for a product at a warehouse |
| `purchase_orders` | Purchase-order header records |
| `purchase_order_items` | Product lines within purchase orders |
| `customers` | Customer records |
| `sales_orders` | Sales-order header records |
| `sales_order_items` | Product lines within sales orders |
| `payments` | Payment records linked to sales orders |
| `employees` | Employee records |
| `stock_movements` | Historical stock movement records |

### Main relationships
- One category can be associated with many products.
- One supplier can supply many products and be linked to many purchase orders.
- One warehouse can have many inventory records, purchase orders, and sales orders.
- One product can appear in many warehouse inventory records, purchase lines, sales lines, and stock movements.
- One purchase order can contain multiple purchase-order items.
- One customer can have multiple sales orders.
- One sales order can contain multiple sales-order items and payment records.
- One employee can be associated with multiple stock movements.

The `warehouse_inventory` table has a unique constraint on `(warehouse_id, product_id)`, so a product is represented at most once per warehouse in this table. The `stock_movements.reference_id` field is a general reference and is not constrained to one specific transaction table.

**ER diagram:** See `er diagram inventory.png` in the repository.

## 9. Dataset
The project uses fictional, synthetic CSV data for demonstration. The documented dataset size is 5,795 rows across 13 tables.

| Table | Rows |
|---|---:|
| categories | 8 |
| suppliers | 20 |
| products | 150 |
| warehouses | 6 |
| warehouse_inventory | 900 |
| purchase_orders | 120 |
| purchase_order_items | 466 |
| customers | 400 |
| sales_orders | 500 |
| sales_order_items | 1,500 |
| payments | 500 |
| employees | 25 |
| stock_movements | 1,200 |
| **Total** | **5,795** |

The records are fictional and should not be interpreted as actual company, customer, or financial data.

## 10. Implementation
### Schema and constraints
The schema uses `INT` identifiers, `VARCHAR` text fields, `DATE`/`DATETIME` temporal fields, `DECIMAL(10,2)` for monetary values, primary keys, foreign keys, and selected unique constraints. Tables use InnoDB.

### Queries and reports
The SQL scripts include:
- Row-count checks and product detail retrieval.
- Subquery example comparing product prices with the average.
- CTE and window-function examples for completed-sales analysis.
- Inventory status and estimated inventory value reports.
- Sales totals by order, status, month, and customer.
- Payment summaries and pending-payment details.
- Supplier and purchase-order summaries.
- Product-level comparison of received purchases and completed sales.

### Views
| View | Purpose |
|---|---|
| `vw_product_details` | Product information enriched with category and supplier names |
| `vw_inventory_summary` | Product stock by warehouse with a stock-status label |
| `vw_sales_details` | Sales-order line details combined with customer, warehouse, product, and category |

### Stored procedures
| Procedure | Purpose |
|---|---|
| `GetAllProducts()` | Returns product details |
| `GetProductsByCategory(p_category_id)` | Filters products by category |
| `GetCustomerOrders(p_customer_id)` | Returns a customer's order-level totals |
| `GetWarehouseStock(p_warehouse_id)` | Returns stock details for one warehouse |

### Triggers
- `trg_check_stock_insert`: rejects an inserted `warehouse_inventory` row if its available quantity is negative.
- `trg_check_stock_update`: rejects an update if the new available quantity is negative.

These triggers validate the `warehouse_inventory.quantity_available` field. They do not automatically reconcile stock from sales, purchases, or movement records.

### Transactions
The examples demonstrate `START TRANSACTION`, `ROLLBACK`, and `COMMIT` using InnoDB tables. The rollback example temporarily changes stock and then cancels the change. The commit example saves a sample row in a temporary demonstration table before removing that table.

### Indexes and optimization
The project inspects existing indexes, creates selected date and movement-history indexes, and uses `EXPLAIN` and `ANALYZE TABLE` to examine query behavior. An index can help some queries, but MySQL's optimizer may choose a table scan when it estimates that to be more efficient, especially for small tables or broad filters.

## 11. Setup and Execution
1. Install MySQL Server 8.0 or later and MySQL Workbench (or a compatible SQL client).
2. Open and run `sql/01_database_and_tables.sql` against a new project database.
3. Import the CSV datasets using MySQL Workbench's Table Data Import Wizard in this order: categories, suppliers, warehouses, customers, employees, products, warehouse_inventory, purchase_orders, purchase_order_items, sales_orders, sales_order_items, payments, stock_movements.
4. Run `sql/02_basic_queries_and_reports.sql`.
5. Run `sql/03_views_and_procedures.sql`.
6. Run `sql/04_triggers_and_transactions.sql`.
7. Run `sql/05_indexes_and_validation.sql`.

Use the SQL comments and README as a companion guide. Some statements, such as index creation, are not intended to be run repeatedly without checking whether the index already exists. Trigger negative-value tests intentionally cause SQL errors and should be run separately when demonstrating them.

## 12. Testing and Validation
The project includes SQL checks and demonstrations for:
- Table row counts.
- Negative inventory quantities.
- Duplicate warehouse/product combinations.
- Orphaned product-category references.
- Trigger rejection of invalid stock values.
- Rollback restoration and committed transaction behavior.
- Existing index inspection and query-plan review.

Expected validation behavior: the negative-stock, duplicate-pair, and orphan-category checks should return no records when the relevant data is consistent. Actual execution outcomes should be recorded after running the scripts in the target MySQL environment; this document does not claim a fresh end-to-end execution test.

## 13. Limitations and Assumptions
- All sample data is synthetic.
- Stock-movement history may not reconcile exactly with current warehouse balances.
- `reference_id` in `stock_movements` is polymorphic/general and has no foreign key to a single order table.
- Inventory value uses listed product `unit_price` and is an analytical estimate, not accounting valuation.
- Sales and purchase totals are query-derived order values, not audited revenue, cost, or profit.
- This is a database project, not a complete production inventory application.

## 14. Future Enhancements
- Build a Python Flask or Django API and a web-based dashboard.
- Add user login, role-based permissions, and audit logging.
- Implement stock updates from confirmed purchase receipts and sales dispatches.
- Add stock reconciliation and low-stock notification workflows.
- Add returns, cancellations, adjustments, and multi-currency support.
- Add automated SQL tests and repeatable database seeding.
- Introduce reporting dashboards and exportable business summaries.

## 15. Conclusion
The project demonstrates how a relational database can organize core inventory and transaction records and how MySQL features can support reporting, reusable query logic, validation, transaction handling, and query optimization. It provides a practical foundation for further development into a full-stack inventory application.

## 16. References
- MySQL 8.0 Reference Manual: https://dev.mysql.com/doc/refman/8.0/en/
- MySQL Workbench Manual: https://dev.mysql.com/doc/workbench/en/
- Project source code and datasets: https://github.com/Hariharans1971/inventory-management-system
