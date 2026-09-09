-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 01-session-monitoring.sql
-- Purpose: Monitor active database sessions and identify
--          potentially problematic sessions
-- ============================================================

-- ------------------------------------------------------------
-- 1. Display current database session information
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    machine,
    program,
    module,
    logon_time
FROM v$session
WHERE username IS NOT NULL
ORDER BY logon_time DESC;


-- ------------------------------------------------------------
-- 2. Identify currently active user sessions
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    event,
    wait_class,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE username IS NOT NULL
  AND status = 'ACTIVE'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 3. Identify sessions currently waiting
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    event,
    wait_class,
    state,
    seconds_in_wait
FROM v$session
WHERE username IS NOT NULL
  AND state <> 'WAITING'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 4. Identify sessions consuming CPU
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    sql_id,
    cpu_time,
    event
FROM v$session
WHERE username IS NOT NULL
ORDER BY cpu_time DESC;


-- ------------------------------------------------------------
-- 5. Identify sessions with a SQL statement currently running
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    sql_id,
    sql_exec_start,
    event,
    wait_class
FROM v$session
WHERE username IS NOT NULL
  AND sql_id IS NOT NULL
ORDER BY sql_exec_start;


-- ------------------------------------------------------------
-- 6. Identify blocking sessions
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    blocking_session,
    event,
    wait_class,
    seconds_in_wait
FROM v$session
WHERE blocking_session IS NOT NULL
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 7. Display sessions with high logical I/O
-- ------------------------------------------------------------

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.sql_id,
    ss.value AS logical_reads
FROM v$session s
JOIN v$sesstat ss
    ON s.sid = ss.sid
JOIN v$statname sn
    ON ss.statistic# = sn.statistic#
WHERE s.username IS NOT NULL
  AND sn.name = 'session logical reads'
ORDER BY ss.value DESC;


-- ------------------------------------------------------------
-- 8. Display session information useful during troubleshooting
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    machine,
    program,
    module,
    action,
    sql_id,
    event,
    wait_class
FROM v$session
WHERE username IS NOT NULL
ORDER BY username, sid;


-- ------------------------------------------------------------
-- DBA Troubleshooting Checklist
-- ------------------------------------------------------------
--
-- 1. Check for unusually high active sessions.
-- 2. Identify sessions waiting on important resources.
-- 3. Check blocking_session for lock-related problems.
-- 4. Identify SQL_ID values associated with problematic sessions.
-- 5. Investigate high CPU or logical I/O consumers.
-- 6. Review the SQL execution plan for expensive SQL.
-- 7. Check whether indexes, statistics, or SQL design require
--    further investigation.
--
-- NOTE:
-- These queries are intended for monitoring and analysis.
-- Avoid terminating sessions unless the impact and cause
-- are understood and the action is authorized.
-- ============================================================