-- ============================================================
-- Oracle DBA Portfolio
-- Project: Backup & Recovery with RMAN
-- File: 01-rman-configuration.sql
-- Purpose: Demonstrate RMAN configuration and validation
-- ============================================================

-- ============================================================
-- NOTE
-- This file documents RMAN commands for a laboratory or
-- authorized Oracle environment.
--
-- Do NOT execute configuration changes against production
-- without an approved backup and recovery plan.
-- ============================================================


-- ============================================================
-- 1. Display Current RMAN Configuration
-- ============================================================

-- Run from the RMAN client:
--
-- SHOW ALL;


-- ============================================================
-- 2. Configure Backup Retention Policy
-- ============================================================

-- Keep sufficient backups to support a 7-day recovery window.
--
-- RMAN command:
--
-- CONFIGURE RETENTION POLICY
-- TO RECOVERY WINDOW OF 7 DAYS;


-- ============================================================
-- 3. Enable Backup Optimization
-- ============================================================

-- RMAN can avoid backing up files that are already backed up
-- according to the configured retention and backup requirements.
--
-- RMAN command:
--
-- CONFIGURE BACKUP OPTIMIZATION ON;


-- ============================================================
-- 4. Enable Control File Autobackup
-- ============================================================

-- Control file and SPFILE protection is important because
-- these files contain critical database configuration and
-- recovery metadata.
--
-- RMAN command:
--
-- CONFIGURE CONTROLFILE AUTOBACKUP ON;


-- ============================================================
-- 5. Configure Disk Backup Device
-- ============================================================

-- Example configuration for two disk backup channels.
--
-- RMAN command:
--
-- CONFIGURE DEVICE TYPE DISK
-- PARALLELISM 2;


-- ============================================================
-- 6. Configure Backup Compression
-- ============================================================

-- Compression can reduce backup storage requirements.
-- The exact compression algorithm should be selected based
-- on database workload, CPU capacity and Oracle licensing.
--
-- Example:
--
-- CONFIGURE COMPRESSION ALGORITHM 'BASIC';


-- ============================================================
-- 7. Display the Final Configuration
-- ============================================================

-- RMAN command:
--
-- SHOW ALL;


-- ============================================================
-- 8. Database-Level Information
-- ============================================================

-- The following SQL queries can be used from SQL*Plus,
-- SQLcl or another Oracle SQL client.


-- Database name, role and open mode

SELECT
    name,
    db_unique_name,
    database_role,
    open_mode,
    log_mode,
    force_logging
FROM v$database;


-- ============================================================
-- 9. Check Archive Log Mode
-- ============================================================

-- ARCHIVELOG mode is normally required for online backup and
-- many recovery scenarios.

SELECT
    name,
    log_mode
FROM v$database;


-- ============================================================
-- 10. Check Database Incarnation
-- ============================================================

SELECT
    incarnation#,
    resetlogs_change#,
    resetlogs_time,
    status
FROM v$database_incarnation
ORDER BY incarnation#;


-- ============================================================
-- 11. Check Current Redo Log Configuration
-- ============================================================

SELECT
    group#,
    thread#,
    sequence#,
    bytes,
    members,
    archived,
    status
FROM v$log
ORDER BY group#;


-- ============================================================
-- 12. DBA Configuration Review Checklist
-- ============================================================

-- Review the following items regularly:
--
-- [ ] Retention policy configured
-- [ ] Control file autobackup enabled
-- [ ] Backup optimization reviewed
-- [ ] Backup destination available
-- [ ] Backup compression reviewed
-- [ ] ARCHIVELOG mode enabled where required
-- [ ] Backup jobs monitored
-- [ ] Archived redo logs protected
-- [ ] Backups validated
-- [ ] Restore testing performed
-- [ ] Recovery procedures documented