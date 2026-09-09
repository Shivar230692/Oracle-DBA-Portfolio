-- ============================================================
-- Oracle DBA Portfolio
-- Project: Performance Tuning
-- File: 06-tablespace-performance.sql
-- Purpose: Analyze Oracle tablespace and datafile usage
--          as part of performance and capacity monitoring
-- ============================================================


-- ------------------------------------------------------------
-- 1. Display tablespace status
-- ------------------------------------------------------------

SELECT
    tablespace_name,
    status,
    contents,
    extent_management
FROM dba_tablespaces
ORDER BY tablespace_name;


-- ------------------------------------------------------------
-- 2. Display datafile information
-- ------------------------------------------------------------

SELECT
    file_id,
    file_name,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb,
    autoextensible,
    ROUND(maxbytes / 1024 / 1024, 2) AS max_size_mb,
    status
FROM dba_data_files
ORDER BY tablespace_name, file_id;


-- ------------------------------------------------------------
-- 3. Calculate tablespace used space
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
-- 4. Identify tablespaces with high utilization
-- ------------------------------------------------------------
--
-- This calculation uses allocated datafile space.
-- In production, autoextend limits and ASM/storage capacity
-- should also be considered.
--

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
-- 5. Identify autoextensible datafiles
-- ------------------------------------------------------------

SELECT
    file_id,
    file_name,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS current_size_mb,
    autoextensible,
    ROUND(maxbytes / 1024 / 1024, 2) AS maximum_size_mb
FROM dba_data_files
WHERE autoextensible = 'YES'
ORDER BY tablespace_name, file_id;


-- ------------------------------------------------------------
-- 6. Identify datafiles that cannot autoextend
-- ------------------------------------------------------------

SELECT
    file_id,
    file_name,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb,
    autoextensible
FROM dba_data_files
WHERE autoextensible = 'NO'
ORDER BY tablespace_name, file_id;


-- ------------------------------------------------------------
-- 7. Display temporary tablespace information
-- ------------------------------------------------------------

SELECT
    tablespace_name,
    status,
    contents
FROM dba_tablespaces
WHERE contents = 'TEMPORARY'
ORDER BY tablespace_name;


-- ------------------------------------------------------------
-- 8. Display temporary files
-- ------------------------------------------------------------

SELECT
    file_id,
    file_name,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb,
    autoextensible,
    ROUND(maxbytes / 1024 / 1024, 2) AS max_size_mb,
    status
FROM dba_temp_files
ORDER BY tablespace_name, file_id;


-- ------------------------------------------------------------
-- 9. Display segment sizes
-- ------------------------------------------------------------

SELECT
    owner,
    segment_name,
    segment_type,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb
FROM dba_segments
ORDER BY bytes DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 10. Identify large segments in a specific tablespace
-- ------------------------------------------------------------
--
-- Replace USERS with the tablespace being investigated.
--

SELECT
    owner,
    segment_name,
    segment_type,
    tablespace_name,
    ROUND(bytes / 1024 / 1024, 2) AS size_mb
FROM dba_segments
WHERE tablespace_name = 'USERS'
ORDER BY bytes DESC
FETCH FIRST 20 ROWS ONLY;


-- ------------------------------------------------------------
-- 11. Tablespace performance investigation checklist
-- ------------------------------------------------------------
--
-- Investigate:
--
-- 1. Tablespaces approaching capacity.
-- 2. Datafiles reaching their maximum size.
-- 3. Datafiles that cannot autoextend.
-- 4. Large database segments.
-- 5. Temporary tablespace pressure.
-- 6. Storage growth trends.
-- 7. I/O-related wait events.
-- 8. Datafiles with unusual I/O activity.
-- 9. ASM or underlying storage capacity.
-- 10. Whether storage problems are causing application impact.
--
-- IMPORTANT:
-- High tablespace utilization does not automatically mean
-- poor database performance. Capacity, storage latency,
-- I/O contention, and application workload should be
-- analyzed together.
--
-- ============================================================