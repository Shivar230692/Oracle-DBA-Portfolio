-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 07-performance-report.sql
-- Purpose: Generate a consolidated Oracle performance
--          investigation report
-- ============================================================


-- ------------------------------------------------------------
-- 1. Database status
-- ------------------------------------------------------------

SELECT
    name,
    dbid,
    open_mode,
    database_role,
    log_mode,
    flashback_on
FROM v$database;


-- ------------------------------------------------------------
-- 2. Instance status
-- ------------------------------------------------------------

SELECT
    instance_name,
    host_name,
    version,
    status,
    startup_time
FROM v$instance;


-- ------------------------------------------------------------
-- 3. Current active sessions
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS active_sessions
FROM v$session
WHERE status = 'ACTIVE'
  AND username IS NOT NULL;


-- ------------------------------------------------------------
-- 4. Current inactive sessions
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS inactive_sessions
FROM v$session
WHERE status = 'INACTIVE'
  AND username IS NOT NULL;


-- ------------------------------------------------------------
-- 5. Sessions currently waiting
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS waiting_sessions
FROM v$session
WHERE username IS NOT NULL
  AND wait_class <> 'Idle';


-- ------------------------------------------------------------
-- 6. Blocking sessions
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    blocking_session,
    event,
    wait_class,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE blocking_session IS NOT NULL
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 7. Top SQL by CPU
-- ------------------------------------------------------------

SELECT
    sql_id,
    executions,
    ROUND(cpu_time / 1000000, 2) AS cpu_seconds,
    ROUND(elapsed_time / 1000000, 2) AS elapsed_seconds,
    buffer_gets,
    disk_reads,
    sql_text
FROM v$sql
WHERE sql_text IS NOT NULL
ORDER BY cpu_time DESC
FETCH FIRST 10 ROWS ONLY;


-- ------------------------------------------------------------
-- 8. Top SQL by elapsed time
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
FETCH FIRST 10 ROWS ONLY;


-- ------------------------------------------------------------
-- 9. Top SQL by logical reads
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
FETCH FIRST 10 ROWS ONLY;


-- ------------------------------------------------------------
-- 10. Top non-idle wait events
-- ------------------------------------------------------------

SELECT
    event,
    wait_class,
    total_waits,
    ROUND(time_waited / 100, 2) AS wait_seconds
FROM v$system_event
WHERE wait_class <> 'Idle'
ORDER BY time_waited DESC
FETCH FIRST 10 ROWS ONLY;


-- ------------------------------------------------------------
-- 11. Wait summary by wait class
-- ------------------------------------------------------------

SELECT
    wait_class,
    COUNT(*) AS event_count,
    SUM(total_waits) AS total_waits,
    ROUND(SUM(time_waited) / 100, 2) AS wait_seconds
FROM v$system_event
WHERE wait_class <> 'Idle'
GROUP BY wait_class
ORDER BY wait_seconds DESC;


-- ------------------------------------------------------------
-- 12. Index health summary
-- ------------------------------------------------------------

SELECT
    COUNT(*) AS total_indexes,
    SUM(
        CASE
            WHEN status = 'VALID' THEN 1
            ELSE 0
        END
    ) AS valid_indexes,
    SUM(
        CASE
            WHEN status <> 'VALID' THEN 1
            ELSE 0
        END
    ) AS invalid_indexes
FROM user_indexes;


-- ------------------------------------------------------------
-- 13. Invalid indexes
-- ------------------------------------------------------------

SELECT
    index_name,
    table_name,
    status,
    visibility
FROM user_indexes
WHERE status <> 'VALID'
ORDER BY table_name, index_name;


-- ------------------------------------------------------------
-- 14. Tables with missing optimizer statistics
-- ------------------------------------------------------------

SELECT
    table_name,
    num_rows,
    last_analyzed
FROM user_tables
WHERE last_analyzed IS NULL
ORDER BY table_name;


-- ------------------------------------------------------------
-- 15. Tables with statistics older than 30 days
-- ------------------------------------------------------------

SELECT
    table_name,
    num_rows,
    last_analyzed
FROM user_tables
WHERE last_analyzed < SYSDATE - 30
ORDER BY last_analyzed;


-- ------------------------------------------------------------
-- 16. Tablespace utilization
-- ------------------------------------------------------------

SELECT
    df.tablespace_name,
    ROUND(SUM(df.bytes) / 1024 / 1024, 2) AS allocated_mb,
    ROUND(
        NVL(SUM(fs.bytes), 0) / 1024 / 1024,
        2
    ) AS free_mb,
    ROUND(
        (SUM(df.bytes) - NVL(SUM(fs.bytes), 0))
        / SUM(df.bytes) * 100,
        2
    ) AS used_percent
FROM dba_data_files df
LEFT JOIN dba_free_space fs
    ON df.file_id = fs.file_id
GROUP BY df.tablespace_name
ORDER BY used_percent DESC;


-- ------------------------------------------------------------
-- 17. High-utilization tablespaces
-- ------------------------------------------------------------

SELECT
    df.tablespace_name,
    ROUND(SUM(df.bytes) / 1024 / 1024, 2) AS allocated_mb,
    ROUND(
        NVL(SUM(fs.bytes), 0) / 1024 / 1024,
        2
    ) AS free_mb,
    ROUND(
        (SUM(df.bytes) - NVL(SUM(fs.bytes), 0))
        / SUM(df.bytes) * 100,
        2
    ) AS used_percent
FROM dba_data_files df
LEFT JOIN dba_free_space fs
    ON df.file_id = fs.file_id
GROUP BY df.tablespace_name
HAVING
    (SUM(df.bytes) - NVL(SUM(fs.bytes), 0))
    / SUM(df.bytes) * 100 >= 80
ORDER BY used_percent DESC;


-- ------------------------------------------------------------
-- 18. Performance investigation summary
-- ------------------------------------------------------------
--
-- Review the results from this report and investigate:
--
-- SESSION ACTIVITY
--   - Unexpectedly high active sessions
--   - Long-running sessions
--   - Blocking sessions
--
-- SQL PERFORMANCE
--   - High CPU SQL
--   - High elapsed-time SQL
--   - High logical reads
--   - High physical reads
--
-- WAIT EVENTS
--   - Dominant non-idle waits
--   - I/O waits
--   - Concurrency waits
--   - Application/locking waits
--
-- INDEXES
--   - Invalid indexes
--   - Invisible indexes
--   - Ineffective or unnecessary indexes
--
-- STATISTICS
--   - Missing optimizer statistics
--   - Potentially stale statistics
--
-- STORAGE
--   - High tablespace utilization
--   - Datafile growth requirements
--   - Storage-related performance symptoms
--
-- ============================================================
-- DBA PERFORMANCE WORKFLOW
-- ============================================================
--
-- 1. Detect
-- 2. Measure
-- 3. Identify the affected session or SQL_ID
-- 4. Review execution plan
-- 5. Analyze wait events
-- 6. Investigate indexes and statistics
-- 7. Check storage and tablespace conditions
-- 8. Determine root cause
-- 9. Apply an appropriate change
-- 10. Measure performance again
--
-- ============================================================
-- IMPORTANT
-- ============================================================
--
-- This report is intended for read-only investigation.
-- Do not automatically terminate sessions, rebuild indexes,
-- resize datafiles, or change optimizer parameters based
-- solely on these queries.
--
-- Performance tuning should be evidence-based and changes
-- should be tested and authorized before implementation.
--
-- ============================================================