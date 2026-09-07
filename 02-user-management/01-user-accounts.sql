-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 01-user-accounts.sql
-- Purpose: Demonstrate Oracle user account monitoring
-- ============================================================


-- ============================================================
-- 1. DBA_USERS
-- Database-wide user account information
-- Requires appropriate DBA/catalog privileges
-- ============================================================

SELECT
    username,
    account_status,
    lock_date,
    expiry_date,
    default_tablespace,
    temporary_tablespace,
    created,
    profile
FROM dba_users
ORDER BY username;


-- ============================================================
-- 2. Find locked or expired accounts
-- Useful for account security monitoring
-- ============================================================

SELECT
    username,
    account_status,
    lock_date,
    expiry_date
FROM dba_users
WHERE account_status <> 'OPEN'
ORDER BY username;


-- ============================================================
-- 3. ALL_USERS
-- Lists users visible to the current session
-- ============================================================

SELECT
    username,
    user_id,
    created
FROM all_users
ORDER BY username;


-- ============================================================
-- 4. USER_USERS
-- Configuration information for the current user
-- ============================================================

SELECT
    username,
    user_id,
    account_status,
    default_tablespace,
    temporary_tablespace,
    created,
    profile
FROM user_users;


-- ============================================================
-- 5. Check the currently connected user
-- ============================================================

SELECT
    USER AS current_user
FROM dual;