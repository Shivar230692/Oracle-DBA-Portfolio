-- ============================================================
-- Oracle DBA Portfolio
-- Project: Backup & Recovery with RMAN
-- File: 06-backup-monitoring.sql
-- Purpose: Monitor RMAN backups and recovery-related activity
-- ============================================================

-- ============================================================
-- NOTE
-- These queries are intended for an Oracle Database laboratory
-- or authorized DBA environment.
-- ============================================================


-- ============================================================
-- 1. RMAN BACKUP JOB DETAILS
-- ============================================================

-- Review recent RMAN backup jobs.

SELECT
    session_key,
    input_type,
    status,
    start_time,
    end_time,
    input_bytes,
    output_bytes,
    time_taken_display
FROM v$rman_backup_job_details
ORDER BY start_time DESC;


-- ============================================================
-- 2. BACKUP JOB STATUS
-- ============================================================

-- Identify successful, failed or running backup jobs.

SELECT
    session_key,
    input_type,
    status,
    start_time,
    end_time
FROM v$rman_backup_job_details
ORDER BY start_time DESC;


-- ============================================================
-- 3. BACKUP SET INFORMATION
-- ============================================================

SELECT
    bs.recid,
    bs.set_stamp,
    bs.backup_type,
    bs.incremental_level,
    bs.pieces,
    bs.start_time,
    bs.completion_time,
    bs.status
FROM v$backup_set bs
ORDER BY bs.completion_time DESC;


-- ============================================================
-- 4. BACKUP PIECE INFORMATION
-- ============================================================

-- Review physical RMAN backup pieces.

SELECT
    recid,
    stamp,
    handle,
    status,
    device_type,
    bytes,
    compressed
FROM v$backup_piece
ORDER BY recid DESC;


-- ============================================================
-- 5. BACKUP DATAFILE INFORMATION
-- ============================================================

-- Review datafiles included in backup sets.

SELECT
    file#,
    checkpoint_change#,
    checkpoint_time,
    completion_time,
    backup_type,
    incremental_level
FROM v$backup_datafile
ORDER BY completion_time DESC;


-- ============================================================
-- 6. ARCHIVED REDO LOG STATUS
-- ============================================================

SELECT
    thread#,
    sequence#,
    first_time,
    next_time,
    archived,
    deleted,
    status
FROM v$archived_log
ORDER BY first_time DESC;


-- ============================================================
-- 7. RECENT ARCHIVED REDO LOGS
-- ============================================================

-- Review recently generated archived redo logs.

SELECT
    thread#,
    sequence#,
    first_time,
    next_time,
    blocks,
    block_size,
    archived
FROM v$archived_log
WHERE first_time >= SYSDATE - 1
ORDER BY first_time DESC;


-- ============================================================
-- 8. DATABASE ARCHIVE LOG MODE
-- ============================================================

SELECT
    name,
    db_unique_name,
    database_role,
    open_mode,
    log_mode
FROM v$database;


-- ============================================================
-- 9. DATABASE BACKUP SUMMARY
-- ============================================================

SELECT
    input_type,
    status,
    COUNT(*) AS backup_job_count
FROM v$rman_backup_job_details
GROUP BY input_type, status
ORDER BY input_type, status;


-- ============================================================
-- 10. BACKUP SIZE AND DURATION
-- ============================================================

SELECT
    input_type,
    start_time,
    end_time,
    input_bytes,
    output_bytes,
    time_taken_display
FROM v$rman_backup_job_details
WHERE status = 'COMPLETED'
ORDER BY start_time DESC;


-- ============================================================
-- 11. FAILED BACKUP JOBS
-- ============================================================

SELECT
    session_key,
    input_type,
    status,
    start_time,
    end_time,
    time_taken_display
FROM v$rman_backup_job_details
WHERE status <> 'COMPLETED'
ORDER BY start_time DESC;


-- ============================================================
-- 12. BACKUP PIECE STATUS
-- ============================================================

SELECT
    status,
    device_type,
    COUNT(*) AS piece_count,
    SUM(bytes) AS total_bytes
FROM v$backup_piece
GROUP BY status, device_type
ORDER BY status, device_type;


-- ============================================================
-- 13. RMAN BACKUP MONITORING CHECKLIST
-- ============================================================

-- Review the following items regularly:
--
-- [ ] Latest full database backup completed
-- [ ] Incremental backups completed
-- [ ] Archived redo log backups completed
-- [ ] No unexpected failed backup jobs
-- [ ] Backup pieces are available
-- [ ] Backup storage capacity is sufficient
-- [ ] Backup duration is within expected range
-- [ ] Backup sizes are within expected range
-- [ ] Restore validation completed
-- [ ] Recovery testing performed


-- ============================================================
-- 14. DBA INCIDENT INVESTIGATION
-- ============================================================

-- When a backup fails, investigate:
--
-- 1. RMAN job status
-- 2. RMAN output and error messages
-- 3. Backup destination availability
-- 4. Available disk space
-- 5. Archived redo log generation
-- 6. Database alert log
-- 7. RMAN configuration
-- 8. Backup piece availability
-- 9. Network/storage issues
-- 10. Recovery requirements


-- ============================================================
-- 15. PORTFOLIO REPORTING
-- ============================================================

-- A DBA can use these queries to build operational reports
-- containing:
--
-- * Last successful backup
-- * Backup duration
-- * Backup size
-- * Backup status
-- * Archived log activity
-- * Failed backup jobs
-- * Backup piece status
--
-- These reports can support proactive backup monitoring and
-- disaster recovery readiness.