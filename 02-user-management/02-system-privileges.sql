-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 02-system-privileges.sql
-- Purpose: Demonstrate Oracle system privilege auditing
-- ============================================================


-- ============================================================
-- 1. DBA_SYS_PRIVS
-- Lists system privileges granted to users and roles
-- Requires appropriate DBA/catalog privileges
-- ============================================================

SELECT
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
ORDER BY grantee, privilege;


-- ============================================================
-- 2. Find users with powerful system privileges
-- Example: CREATE USER, DROP USER, ALTER USER
-- ============================================================

SELECT
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
WHERE privilege IN (
    'CREATE USER',
    'DROP USER',
    'ALTER USER'
)
ORDER BY grantee, privilege;


-- ============================================================
-- 3. Find privileges that allow object creation
-- Useful for reviewing schema capabilities
-- ============================================================

SELECT
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
WHERE privilege LIKE 'CREATE %'
ORDER BY grantee, privilege;


-- ============================================================
-- 4. USER_SYS_PRIVS
-- System privileges granted directly to the current user
-- ============================================================

SELECT
    username,
    privilege,
    admin_option
FROM user_sys_privs
ORDER BY privilege;


-- ============================================================
-- 5. Check whether the current user has CREATE TABLE
-- ============================================================

SELECT
    privilege,
    admin_option
FROM user_sys_privs
WHERE privilege = 'CREATE TABLE';


-- ============================================================
-- 6. Count system privileges by grantee
-- Useful for security reviews
-- ============================================================

SELECT
    grantee,
    COUNT(*) AS privilege_count
FROM dba_sys_privs
GROUP BY grantee
ORDER BY privilege_count DESC, grantee;