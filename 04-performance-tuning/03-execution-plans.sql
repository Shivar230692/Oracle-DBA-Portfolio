-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 03-execution-plans.sql
-- Purpose: Demonstrate Oracle execution plan analysis
-- ============================================================


-- ------------------------------------------------------------
-- 1. Explain plan for a simple query
-- ------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT
    employee_id,
    employee_name,
    department,
    salary
FROM employees
WHERE department = 'IT';

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ------------------------------------------------------------
-- 2. Explain plan for a query using a primary key
-- ------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT
    employee_id,
    employee_name,
    department,
    salary
FROM employees
WHERE employee_id = 1001;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ------------------------------------------------------------
-- 3. Explain plan for a filtered query
-- ------------------------------------------------------------

EXPLAIN PLAN FOR
SELECT
    employee_id,
    employee_name,
    salary
FROM employees
WHERE salary > 75000;

SELECT *
FROM TABLE(DBMS_XPLAN.DISPLAY);


-- ------------------------------------------------------------
-- 4. Display the execution plan for a SQL_ID
-- ------------------------------------------------------------
--
-- Replace <SQL_ID> with the SQL_ID identified during
-- performance investigation.
--
-- Example:
-- SELECT *
-- FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR('abc123xyz', NULL,
--                                      'ALLSTATS LAST'));
--
-- This requires the appropriate privileges and the SQL
-- statement must still be available in the shared pool.


-- ------------------------------------------------------------
-- 5. Execution plan with runtime statistics
-- ------------------------------------------------------------
--
-- The following example can be used after executing a SQL
-- statement with appropriate statistics collection.
--
-- SELECT *
-- FROM TABLE(
--     DBMS_XPLAN.DISPLAY_CURSOR(
--         '<SQL_ID>',
--         NULL,
--         'ALLSTATS LAST'
--     )
-- );


-- ------------------------------------------------------------
-- 6. Find SQL statements available in the shared pool
-- ------------------------------------------------------------

SELECT
    sql_id,
    child_number,
    executions,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    buffer_gets,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY elapsed_time DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 7. Display SQL plan hash values
-- ------------------------------------------------------------

SELECT
    sql_id,
    child_number,
    plan_hash_value,
    executions,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY elapsed_time DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 8. Identify SQL with multiple child cursors
-- ------------------------------------------------------------

SELECT
    sql_id,
    COUNT(*) AS child_cursor_count
FROM v$sql
WHERE sql_text IS NOT NULL
GROUP BY sql_id
HAVING COUNT(*) > 1
ORDER BY child_cursor_count DESC;


-- ------------------------------------------------------------
-- 9. Identify SQL with significant optimizer cost
-- ------------------------------------------------------------

SELECT
    sql_id,
    child_number,
    plan_hash_value,
    optimizer_cost,
    executions,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY optimizer_cost DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 10. Execution Plan Analysis Checklist
-- ------------------------------------------------------------
--
-- When reviewing an Oracle execution plan, investigate:
--
-- 1. Access paths
--    - TABLE ACCESS FULL
--    - INDEX RANGE SCAN
--    - INDEX UNIQUE SCAN
--    - INDEX FULL SCAN
--
-- 2. Join methods
--    - NESTED LOOPS
--    - HASH JOIN
--    - MERGE JOIN
--
-- 3. Estimated versus actual rows
--
-- 4. High-cost operations
--
-- 5. Excessive logical reads
--
-- 6. Excessive physical reads
--
-- 7. Missing or ineffective indexes
--
-- 8. Out-of-date optimizer statistics
--
-- 9. Unexpected full table scans
--
-- 10. Plan changes between executions
--
-- ============================================================
-- DBA PERFORMANCE PRINCIPLE
-- ============================================================
--
-- Do not assume that an index is always better than a
-- full table scan. The correct access path depends on
-- data volume, selectivity, statistics, clustering,
-- predicates, and the optimizer's cost calculations.
--
-- ============================================================