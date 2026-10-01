# Inventory Management System — Test Cases

These are suggested repeatable test cases based on the project SQL. Mark each result as Pass/Fail only after executing it in your MySQL environment.

| ID | Area | Test | Expected result | Actual result |
|---|---|---|---|---|
| TC-01 | Schema | Run database/table creation on a fresh database | Database and all 13 tables are created | Pending execution |
| TC-02 | Import | Import CSVs in documented dependency order | Rows load without foreign-key errors | Pending execution |
| TC-03 | Data | Run table row-count query | Counts match the supplied dataset | Pending execution |
| TC-04 | Relationships | Inspect foreign keys and join parent-child tables | Related records join correctly | Pending execution |
| TC-05 | Product query | Run product details query | Product, category, supplier fields are returned where matches exist | Pending execution |
| TC-06 | Subquery | Find products priced above average | Returned prices exceed calculated average | Pending execution |
| TC-07 | CTE | Run completed sales by product | Product totals are returned; products without sales show zero in outer result | Pending execution |
| TC-08 | Window function | Rank products by completed-sales value | Each product has a rank; ties share a DENSE_RANK | Pending execution |
| TC-09 | Inventory report | Query stock at/below reorder threshold | Only qualifying inventory rows are shown | Pending execution |
| TC-10 | View | Query `vw_inventory_summary` | Stock rows include correct status based on quantity and reorder level | Pending execution |
| TC-11 | Procedure | Call `GetAllProducts()` | Product result set is returned | Pending execution |
| TC-12 | Procedure | Call `GetProductsByCategory(1)` | Only products for category 1 are returned | Pending execution |
| TC-13 | Procedure | Call `GetCustomerOrders(13)` | Order totals for customer 13 are returned, if present | Pending execution |
| TC-14 | Procedure | Call `GetWarehouseStock(3)` | Stock details for warehouse 3 are returned, if present | Pending execution |
| TC-15 | Trigger | Attempt negative inventory insert in isolated test | Trigger rejects insert with SQLSTATE 45000 | Pending execution |
| TC-16 | Trigger | Attempt negative inventory update in isolated test | Trigger rejects update with SQLSTATE 45000 | Pending execution |
| TC-17 | Transaction | Update quantity inside transaction, then ROLLBACK | Quantity returns to original value | Pending execution |
| TC-18 | Transaction | Commit a sample row in a temporary test table | Insert persists after COMMIT | Pending execution |
| TC-19 | Index | Run SHOW INDEX and EXPLAIN | Index metadata and query plan are displayed | Pending execution |
| TC-20 | Integrity | Run negative-stock, duplicate-pair, and orphan checks | No rows returned for clean data | Pending execution |

## Safe testing notes
- Use a test database or backup before changing records.
- Trigger tests intentionally raise an error; run each separately and restore any test data.
- Index creation can fail if the same named index already exists. Check existing indexes before rerunning.
- Record actual output, MySQL version, and execution date in your final submission.
