-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 05-wait-events.sql
-- Purpose: Analyze Oracle wait events and identify potential
--          performance bottlenecks
-- ============================================================


-- ------------------------------------------------------------
-- 1. Display current system wait events
-- ------------------------------------------------------------

SELECT
    event,
    wait_class,
    total_waits,
    time_waited,
    ROUND(time_waited / 100, 2) AS time_waited_seconds
FROM v$system_event
ORDER BY time_waited DESC;


-- ------------------------------------------------------------
-- 2. Display non-idle wait events
-- ------------------------------------------------------------

SELECT
    event,
    wait_class,
    total_waits,
    time_waited,
    ROUND(time_waited / 100, 2) AS time_waited_seconds
FROM v$system_event
WHERE wait_class <> 'Idle'
ORDER BY time_waited DESC;


-- ------------------------------------------------------------
-- 3. Identify current sessions waiting on events
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    event,
    wait_class,
    state,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE username IS NOT NULL
  AND wait_class <> 'Idle'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 4. Summarize waits by wait class
-- ------------------------------------------------------------

SELECT
    wait_class,
    COUNT(*) AS event_count,
    SUM(total_waits) AS total_waits,
    SUM(time_waited) AS total_time_waited
FROM v$system_event
WHERE wait_class <> 'Idle'
GROUP BY wait_class
ORDER BY total_time_waited DESC;


-- ------------------------------------------------------------
-- 5. Identify sessions waiting on user I/O
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    event,
    wait_class,
    state,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE username IS NOT NULL
  AND wait_class = 'User I/O'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 6. Identify sessions waiting on concurrency
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    event,
    wait_class,
    state,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE username IS NOT NULL
  AND wait_class = 'Concurrency'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 7. Identify sessions waiting on application locks
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    blocking_session,
    event,
    wait_class,
    state,
    seconds_in_wait,
    sql_id
FROM v$session
WHERE username IS NOT NULL
  AND wait_class = 'Application'
ORDER BY seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 8. Identify blocking sessions
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    status,
    blocking_session,
    event,
    wait_class,
    sql_id
FROM v$session
WHERE blocking_session IS NOT NULL
ORDER BY blocking_session, sid;


-- ------------------------------------------------------------
-- 9. Display sessions involved in blocking chains
-- ------------------------------------------------------------

SELECT
    sid,
    serial#,
    username,
    blocking_session,
    final_blocking_session,
    event,
    wait_class,
    seconds_in_wait
FROM v$session
WHERE blocking_session IS NOT NULL
   OR final_blocking_session IS NOT NULL
ORDER BY final_blocking_session, blocking_session, sid;


-- ------------------------------------------------------------
-- 10. Identify SQL associated with waiting sessions
-- ------------------------------------------------------------

SELECT
    s.sid,
    s.serial#,
    s.username,
    s.sql_id,
    s.event,
    s.wait_class,
    s.seconds_in_wait,
    q.executions,
    q.buffer_gets,
    q.disk_reads,
    ROUND(q.elapsed_time / 1000000, 2) AS elapsed_seconds,
    q.sql_text
FROM v$session s
JOIN v$sql q
    ON s.sql_id = q.sql_id
WHERE s.username IS NOT NULL
  AND s.sql_id IS NOT NULL
  AND s.wait_class <> 'Idle'
ORDER BY s.seconds_in_wait DESC;


-- ------------------------------------------------------------
-- 11. Top wait events by total time
-- ------------------------------------------------------------

SELECT
    event,
    wait_class,
    total_waits,
    ROUND(time_waited / 100, 2) AS total_wait_seconds,
    ROUND(
        CASE
            WHEN total_waits > 0
            THEN (time_waited / 100) / total_waits
            ELSE 0
        END,
        4
    ) AS avg_wait_seconds
FROM v$system_event
WHERE wait_class <> 'Idle'
ORDER BY time_waited DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 12. Wait-event investigation checklist
-- ------------------------------------------------------------
--
-- When investigating a performance problem:
--
-- 1. Identify the dominant non-idle wait events.
-- 2. Group waits by wait class.
-- 3. Identify sessions currently experiencing waits.
-- 4. Check whether blocking sessions exist.
-- 5. Associate the session with its SQL_ID.
-- 6. Review the SQL execution plan.
-- 7. Determine whether the problem is related to:
--      - CPU
--      - Disk I/O
--      - Locks
--      - Concurrency
--      - Network
--      - Memory
--      - Application behavior
--
-- IMPORTANT:
-- A wait event is not automatically a performance problem.
-- Oracle databases legitimately wait for resources during
-- normal operation. The DBA should investigate waits in the
-- context of workload, duration, frequency, and business impact.
--
-- ============================================================