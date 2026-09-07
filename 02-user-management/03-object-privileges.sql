-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 03-object-privileges.sql
-- Purpose: Demonstrate Oracle object privilege auditing
-- ============================================================


-- ============================================================
-- 1. DBA_TAB_PRIVS
-- Lists explicit object privileges granted to users and roles
-- Requires appropriate DBA/catalog privileges
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantor,
    grantable
FROM dba_tab_privs
ORDER BY grantee, owner, table_name, privilege;


-- ============================================================
-- 2. Find SELECT privileges
-- Useful for identifying who can read database objects
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantable
FROM dba_tab_privs
WHERE privilege = 'SELECT'
ORDER BY owner, table_name, grantee;


-- ============================================================
-- 3. Find INSERT, UPDATE and DELETE privileges
-- Useful for reviewing data modification access
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantable
FROM dba_tab_privs
WHERE privilege IN ('INSERT', 'UPDATE', 'DELETE')
ORDER BY owner, table_name, grantee, privilege;


-- ============================================================
-- 4. Identify object privileges granted with GRANT OPTION
-- GRANTABLE = YES means the grantee can grant the privilege
-- to another user or role, where applicable.
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantable
FROM dba_tab_privs
WHERE grantable = 'YES'
ORDER BY grantee, owner, table_name, privilege;


-- ============================================================
-- 5. USER_TAB_PRIVS
-- Shows object privileges where the current user is involved
-- as owner, grantor or grantee.
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantor,
    grantable
FROM user_tab_privs
ORDER BY owner, table_name, grantee, privilege;


-- ============================================================
-- 6. Show objects owned by the current user
-- Useful for understanding the current schema
-- ============================================================

SELECT
    object_name,
    object_type,
    status
FROM user_objects
ORDER BY object_type, object_name;


-- ============================================================
-- 7. Count object privileges by grantee
-- Useful for security and access reviews
-- ============================================================

SELECT
    grantee,
    COUNT(*) AS privilege_count
FROM dba_tab_privs
GROUP BY grantee
ORDER BY privilege_count DESC, grantee;


-- ============================================================
-- 8. Count object privileges by object
-- Helps identify heavily shared database objects
-- ============================================================

SELECT
    owner,
    table_name,
    COUNT(*) AS privilege_count
FROM dba_tab_privs
GROUP BY owner, table_name
ORDER BY privilege_count DESC, owner, table_name;