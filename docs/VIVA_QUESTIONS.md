# Inventory Management System — Viva and Interview Questions

## Project overview
**1. What is your project?**  
It is a MySQL-based Inventory Management System database that organizes product, supplier, warehouse, stock, purchase, sales, payment, employee, and stock-movement records and provides SQL reports.

**2. Why did you choose this project?**  
It provides a practical way to apply relational database design and SQL concepts to a familiar business problem.

**3. What is the main objective?**  
To store related inventory and transaction data consistently and retrieve useful operational summaries through SQL.

**4. Is it a complete deployed application?**  
No. This deliverable focuses on the database, SQL logic, and reports. It does not currently include a frontend or application API.

**5. How many tables and rows are in the sample dataset?**  
There are 13 tables and 5,795 synthetic sample rows in total, according to the project dataset counts.

## Database design
**6. What is a primary key?**  
A column or set of columns that uniquely identifies a row in a table.

**7. What is a foreign key?**  
A constraint that links a column to a key in another table and helps preserve referential integrity.

**8. Why use InnoDB?**  
InnoDB supports transactions and foreign-key constraints, which are useful for relational business data.

**9. Why separate purchase_orders from purchase_order_items?**  
The header stores order-level details, while the item table stores individual products and quantities. One order can contain multiple lines.

**10. Why is warehouse_inventory a separate table?**  
A product may be stored in multiple warehouses, and each warehouse can hold many products. The table represents the stock quantity for each warehouse/product pair.

**11. What does the unique constraint on warehouse_id and product_id do?**  
It prevents duplicate inventory rows for the same product in the same warehouse.

**12. What is normalization?**  
Organizing data into related tables to reduce unnecessary duplication and update anomalies.

## SQL concepts
**13. What is the difference between WHERE and HAVING?**  
WHERE filters rows before grouping; HAVING filters grouped results after GROUP BY.

**14. What is the difference between INNER JOIN and LEFT JOIN?**  
INNER JOIN returns matching rows. LEFT JOIN preserves all rows from the left table and returns NULL for missing right-side matches.

**15. What is a subquery?**  
A query nested inside another SQL statement.

**16. What is a CTE?**  
A Common Table Expression is a named temporary result available to a single SQL statement, commonly introduced with WITH.

**17. What is a window function?**  
A function that calculates across a related set of rows while keeping individual rows in the output. The project uses DENSE_RANK for ranking.

**18. What is a view?**  
A named SELECT statement that can be queried like a virtual table.

**19. What is a stored procedure?**  
A saved SQL routine that can be called by name and can accept input parameters.

**20. What is a trigger?**  
A stored program that runs automatically when a specified table event occurs.

## Integrity and performance
**21. How does your project prevent negative stock?**  
Two BEFORE triggers check quantity_available on insert and update and signal an error if the new value is negative.

**22. What is a transaction?**  
A group of database operations handled as a unit. COMMIT saves the changes; ROLLBACK cancels uncommitted changes.

**23. What is an index?**  
A data structure that can help MySQL locate rows faster, with additional storage and write-maintenance costs.

**24. What does EXPLAIN do?**  
It displays the execution plan MySQL expects to use for a query.

**25. Does an index always make a query faster?**  
No. The optimizer may choose a table scan for small tables or queries that return a large portion of the rows.

## Project limitations and next steps
**26. Are the data records real?**  
No. The included dataset is synthetic and intended for education and demonstration.

**27. Do stock movements automatically reconcile the current stock balance?**  
No. The movement history is sample data and may not exactly reconcile with warehouse_inventory.

**28. Is the inventory value an audited financial figure?**  
No. It is an analytical estimate using current quantity and listed unit price.

**29. How could you extend the project?**  
Add a Python Flask API, a web dashboard, authentication, role-based permissions, stock reconciliation, and automated tests.

**30. What did you learn?**  
Relational schema design, keys and constraints, joins, aggregations, CTEs, window functions, views, stored procedures, triggers, transactions, indexes, and query-plan inspection.
