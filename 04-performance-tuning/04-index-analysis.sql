-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 04-index-analysis.sql
-- Purpose: Analyze Oracle indexes and identify potential
--          indexing and performance issues
-- ============================================================


-- ------------------------------------------------------------
-- 1. List indexes owned by the current user
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    index_type,
    uniqueness,
    status,
    visibility
FROM user_indexes
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 2. Display indexed columns
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    column_position,
    column_name,
    descend
FROM user_ind_columns
ORDER BY table_name, index_name, column_position;


-- ------------------------------------------------------------
-- 3. Identify unusable indexes
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    status
FROM user_indexes
WHERE status <> 'VALID'
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 4. Identify indexes that are not visible
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    visibility,
    status
FROM user_indexes
WHERE visibility <> 'VISIBLE'
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 5. Identify unique indexes
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    uniqueness,
    status
FROM user_indexes
WHERE uniqueness = 'UNIQUE'
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 6. Display indexes for a specific table
-- ------------------------------------------------------------
--
-- Replace EMPLOYEES with the table being investigated.
--

SELECT
    index_name,
    index_type,
    uniqueness,
    status,
    visibility
FROM user_indexes
WHERE table_name = 'EMPLOYEES'
ORDER BY index_name;


-- ------------------------------------------------------------
-- 7. Display columns for indexes on EMPLOYEES
-- ------------------------------------------------------------

SELECT
    index_name,
    column_position,
    column_name,
    descend
FROM user_ind_columns
WHERE table_name = 'EMPLOYEES'
ORDER BY index_name, column_position;


-- ------------------------------------------------------------
-- 8. Identify indexes with statistics information
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    num_rows,
    distinct_keys,
    leaf_blocks,
    clustering_factor,
    last_analyzed
FROM user_indexes
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 9. Identify indexes with a high clustering factor
-- ------------------------------------------------------------
--
-- A high clustering factor can indicate that table rows are
-- not well ordered relative to the index.
--
-- This does not automatically mean the index is inefficient.
-- It must be considered together with table size, query
-- selectivity, access patterns, and optimizer statistics.
--

SELECT
    index_name,
    table_name,
    num_rows,
    clustering_factor,
    last_analyzed
FROM user_indexes
WHERE num_rows IS NOT NULL
ORDER BY clustering_factor DESC;


-- ------------------------------------------------------------
-- 10. Check whether optimizer statistics are available
-- ------------------------------------------------------------

SELECT
    table_name,
    num_rows,
    blocks,
    avg_row_len,
    last_analyzed
FROM user_tables
ORDER BY last_analyzed NULLS FIRST, table_name;


-- ------------------------------------------------------------
-- 11. Identify tables without recently analyzed statistics
-- ------------------------------------------------------------

SELECT
    table_name,
    num_rows,
    last_analyzed
FROM user_tables
WHERE last_analyzed IS NULL
   OR last_analyzed < SYSDATE - 30
ORDER BY last_analyzed NULLS FIRST;


-- ------------------------------------------------------------
-- 12. Index troubleshooting checklist
-- ------------------------------------------------------------
--
-- Investigate:
--
-- 1. Unusable indexes
-- 2. Invisible indexes
-- 3. Missing indexes for selective predicates
-- 4. Indexes that are not being used
-- 5. Incorrect column order in composite indexes
-- 6. High clustering factor
-- 7. Stale optimizer statistics
-- 8. Excessive index maintenance
-- 9. Duplicate or overlapping indexes
-- 10. Indexes that increase DML overhead without providing
--     sufficient query benefit
--
-- ============================================================
-- IMPORTANT DBA PRINCIPLE
-- ============================================================
--
-- Creating more indexes does not automatically improve
-- performance.
--
-- Indexes can improve selective queries, but they also
-- consume storage and add overhead to INSERT, UPDATE,
-- and DELETE operations.
--
-- Index decisions should be based on workload, execution
-- plans, data distribution, and measured performance.
--
-- ============================================================