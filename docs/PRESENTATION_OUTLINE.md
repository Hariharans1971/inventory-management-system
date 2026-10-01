# Inventory Management System — Presentation Outline

Suggested 8–10 minute presentation. Add screenshots from your own MySQL Workbench execution and ER diagram.

## Slide 1 — Title
- Inventory Management System Using MySQL
- Hariharan S.
- B.Tech CSE (AI & ML), 2026
- Python Full Stack Training — Besant Technologies, Velachery

## Slide 2 — Problem and motivation
- Inventory operations involve products, suppliers, warehouses, purchasing, sales, and payments.
- Disconnected records make consolidated reporting harder.
- A relational database organizes linked records and supports repeatable queries.

## Slide 3 — Objectives and scope
- Store related business records in MySQL.
- Track current stock by product and warehouse.
- Record purchase and sales order details and payments.
- Produce operational reports.
- Scope is SQL/database focused; no frontend or API is included.

## Slide 4 — Technology stack and dataset
- MySQL 8, MySQL Workbench, SQL, CSV, GitHub.
- 13 tables and 5,795 synthetic rows.
- Briefly show row counts and explain that data is fictional.

## Slide 5 — ER diagram
- Show `er diagram inventory.png`.
- Explain primary keys and foreign keys.
- Walk through product/category/supplier and order/header/item relationships.
- Explain warehouse_inventory's warehouse/product uniqueness.

## Slide 6 — SQL implementation
- Schema and constraints.
- SELECT, joins, subqueries, CTEs, window function.
- Business reports for inventory, sales, purchases, and payments.
- Show one short query and explain its output.

## Slide 7 — Database objects
- Views: product details, inventory summary, sales details.
- Procedures: GetAllProducts, GetProductsByCategory, GetCustomerOrders, GetWarehouseStock.
- Triggers: prevent negative available stock.

## Slide 8 — Transactions and performance
- Demonstrate rollback restoring the prior value.
- Explain commit using the temporary demo table.
- Show an index and an EXPLAIN plan; discuss optimizer choices.

## Slide 9 — Testing, limitations
- Row counts and integrity checks.
- Trigger and transaction test cases.
- Synthetic dataset; movement history may not reconcile exactly.
- Value reports are estimates, not audited financial reporting.

## Slide 10 — Conclusion and future scope
- Summarize relational design and SQL skills demonstrated.
- Future: Flask API, dashboard, authentication, stock reconciliation, automated tests.
- Thank you / Questions.

## Demo checklist
- Open the ER diagram.
- Show the 13 tables and imported row counts.
- Run one inventory report and one sales report.
- Query one view and call one procedure.
- Explain trigger behavior and transaction rollback.
- Show EXPLAIN output.
