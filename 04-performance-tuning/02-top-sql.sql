-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 02-top-sql.sql
-- Purpose: Identify SQL statements consuming significant
--          database resources
-- ============================================================


-- ------------------------------------------------------------
-- 1. Top SQL by CPU time
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    ROUND(cpu_time / 1000000, 2) AS cpu_seconds,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    buffer_gets,
    disk_reads,
    rows_processed,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY cpu_time DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 2. Top SQL by elapsed time
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    ROUND(
        CASE
            WHEN executions > 0
            THEN elapsed_time / executions / 1000
            ELSE 0
        END,
        2
    ) AS avg_elapsed_ms,
    buffer_gets,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY elapsed_time DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 3. Top SQL by logical reads
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    buffer_gets,
    ROUND(
        CASE
            WHEN executions > 0
            THEN buffer_gets / executions
            ELSE 0
        END,
        2
    ) AS avg_buffer_gets,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY buffer_gets DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 4. Top SQL by physical reads
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    disk_reads,
    ROUND(
        CASE
            WHEN executions > 0
            THEN disk_reads / executions
            ELSE 0
        END,
        2
    ) AS avg_disk_reads,
    buffer_gets,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY disk_reads DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 5. SQL with high execution counts
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    ROUND(
        CASE
            WHEN executions > 0
            THEN elapsed_time / executions / 1000
            ELSE 0
        END,
        2
    ) AS avg_elapsed_ms,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY executions DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 6. SQL with high average elapsed time
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    ROUND(
        CASE
            WHEN executions > 0
            THEN elapsed_time / executions / 1000
            ELSE 0
        END,
        2
    ) AS avg_elapsed_ms,
    ROUND(elapsed_time / 1000000, 2) AS total_elapsed_seconds,
    buffer_gets,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
  AND executions > 0
ORDER BY (elapsed_time / executions) DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 7. SQL with high buffer gets per execution
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    buffer_gets,
    ROUND(buffer_gets / executions, 2) AS buffers_per_execution,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
  AND executions > 0
ORDER BY (buffer_gets / executions) DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 8. Investigate a specific SQL_ID
-- ------------------------------------------------------------
--
-- Replace <SQL_ID> with the SQL_ID identified during
-- performance investigation.
--
-- Example:
-- WHERE sql_id = 'abc123xyz'


SELECT
    sql_id,
    child_number,
    executions,
    ROUND(cpu_time / 1000000, 2) AS cpu_seconds,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    buffer_gets,
    disk_reads,
    rows_processed,
    sql_text
FROM v$sql
WHERE sql_id = '<SQL_ID>';


-- ------------------------------------------------------------
-- DBA Performance Investigation Workflow
-- ------------------------------------------------------------
--
-- 1. Identify high-resource SQL.
-- 2. Record the SQL_ID.
-- 3. Compare CPU time and elapsed time.
-- 4. Check execution count.
-- 5. Review logical and physical reads.
-- 6. Calculate average resource consumption per execution.
-- 7. Retrieve the execution plan for suspicious SQL.
-- 8. Investigate indexes, statistics, joins, filters,
--    and wait events.
--
-- IMPORTANT:
-- V$SQL contains SQL currently available in the shared pool.
-- Historical analysis may require AWR/ASH or other licensed
-- Oracle diagnostic features depending on the environment.
--
-- ============================================================