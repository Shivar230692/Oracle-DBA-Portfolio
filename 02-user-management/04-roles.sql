-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 04-roles.sql
-- Purpose: Demonstrate Oracle role management and auditing
-- ============================================================


-- ============================================================
-- 1. DBA_ROLES
-- Lists roles that exist in the database
-- Requires appropriate DBA/catalog privileges
-- ============================================================

SELECT
    role,
    password_required
FROM dba_roles
ORDER BY role;


-- ============================================================
-- 2. Find common Oracle administrative roles
-- Useful for reviewing predefined security roles
-- ============================================================

SELECT
    role,
    password_required
FROM dba_roles
WHERE role IN (
    'DBA',
    'RESOURCE',
    'CONNECT',
    'SELECT_CATALOG_ROLE',
    'EXECUTE_CATALOG_ROLE'
)
ORDER BY role;


-- ============================================================
-- 3. DBA_ROLE_PRIVS
-- Shows roles granted to users or other roles
-- ============================================================

SELECT
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
ORDER BY grantee, granted_role;


-- ============================================================
-- 4. Find roles granted to users
-- Useful for reviewing role-based access
-- ============================================================

SELECT
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE grantee IN (
    SELECT username
    FROM dba_users
)
ORDER BY grantee, granted_role;


-- ============================================================
-- 5. USER_ROLE_PRIVS
-- Roles explicitly granted to the current user
-- ============================================================

SELECT
    username,
    granted_role,
    admin_option,
    default_role
FROM user_role_privs
ORDER BY granted_role;


-- ============================================================
-- 6. ROLE_SYS_PRIVS
-- System privileges assigned to roles
-- ============================================================

SELECT
    role,
    privilege,
    admin_option
FROM role_sys_privs
ORDER BY role, privilege;


-- ============================================================
-- 7. Find roles containing powerful system privileges
-- Useful for security reviews
-- ============================================================

SELECT
    role,
    privilege,
    admin_option
FROM role_sys_privs
WHERE privilege IN (
    'CREATE USER',
    'ALTER USER',
    'DROP USER',
    'CREATE TABLE',
    'CREATE ANY TABLE',
    'ALTER ANY TABLE',
    'DROP ANY TABLE'
)
ORDER BY role, privilege;


-- ============================================================
-- 8. ROLE_TAB_PRIVS
-- Object privileges assigned to roles
-- ============================================================

SELECT
    role,
    owner,
    table_name,
    column_name,
    privilege
FROM role_tab_privs
ORDER BY role, owner, table_name, privilege;


-- ============================================================
-- 9. Find SELECT privileges assigned to roles
-- Useful for reviewing read access
-- ============================================================

SELECT
    role,
    owner,
    table_name,
    privilege
FROM role_tab_privs
WHERE privilege = 'SELECT'
ORDER BY role, owner, table_name;


-- ============================================================
-- 10. Count roles assigned to each grantee
-- Useful for access review
-- ============================================================

SELECT
    grantee,
    COUNT(*) AS role_count
FROM dba_role_privs
GROUP BY grantee
ORDER BY role_count DESC, grantee;


-- ============================================================
-- 11. Count system privileges assigned to each role
-- Useful for identifying highly privileged roles
-- ============================================================

SELECT
    role,
    COUNT(*) AS system_privilege_count
FROM role_sys_privs
GROUP BY role
ORDER BY system_privilege_count DESC, role;


-- ============================================================
-- 12. Count object privileges assigned to each role
-- Useful for reviewing role-based object access
-- ============================================================

SELECT
    role,
    COUNT(*) AS object_privilege_count
FROM role_tab_privs
GROUP BY role
ORDER BY object_privilege_count DESC, role;