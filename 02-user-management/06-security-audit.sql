-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 06-security-audit.sql
-- Purpose: Perform a consolidated Oracle security audit
-- ============================================================


-- ============================================================
-- 1. USER ACCOUNT SECURITY AUDIT
-- Identify locked, expired or otherwise non-open accounts
-- ============================================================

SELECT
    username,
    account_status,
    lock_date,
    expiry_date,
    profile,
    default_tablespace
FROM dba_users
WHERE account_status <> 'OPEN'
ORDER BY username;


-- ============================================================
-- 2. USERS WITH POWERFUL SYSTEM PRIVILEGES
-- Review administrative capabilities
-- ============================================================

SELECT
    grantee,
    privilege,
    admin_option
FROM dba_sys_privs
WHERE privilege IN (
    'CREATE USER',
    'ALTER USER',
    'DROP USER',
    'CREATE ANY TABLE',
    'ALTER ANY TABLE',
    'DROP ANY TABLE',
    'GRANT ANY PRIVILEGE',
    'GRANT ANY ROLE'
)
ORDER BY grantee, privilege;


-- ============================================================
-- 3. USERS WITH OBJECT MODIFICATION PRIVILEGES
-- Review INSERT, UPDATE and DELETE access
-- ============================================================

SELECT
    grantee,
    owner,
    table_name,
    privilege,
    grantable
FROM dba_tab_privs
WHERE privilege IN (
    'INSERT',
    'UPDATE',
    'DELETE'
)
ORDER BY owner, table_name, grantee, privilege;


-- ============================================================
-- 4. OBJECT PRIVILEGES WITH GRANT OPTION
-- Identify users/roles that can pass object privileges onward
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
-- 5. USERS AND THEIR ROLES
-- Review role assignments
-- ============================================================

SELECT
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
ORDER BY grantee, granted_role;


-- ============================================================
-- 6. USERS WITH DBA ROLE
-- Important administrative access review
-- ============================================================

SELECT
    grantee,
    granted_role,
    admin_option,
    default_role
FROM dba_role_privs
WHERE granted_role = 'DBA'
ORDER BY grantee;


-- ============================================================
-- 7. PRIVILEGES CONTAINED IN ROLES
-- Review system privileges inherited through roles
-- ============================================================

SELECT
    role,
    privilege,
    admin_option
FROM role_sys_privs
ORDER BY role, privilege;


-- ============================================================
-- 8. OBJECT PRIVILEGES CONTAINED IN ROLES
-- Review object-level access provided through roles
-- ============================================================

SELECT
    role,
    owner,
    table_name,
    privilege
FROM role_tab_privs
ORDER BY role, owner, table_name, privilege;


-- ============================================================
-- 9. TABLESPACE QUOTA AUDIT
-- Review users with configured storage limits
-- ============================================================

SELECT
    username,
    tablespace_name,
    bytes AS bytes_used,
    max_bytes AS quota_limit
FROM dba_ts_quotas
WHERE max_bytes <> -1
ORDER BY username, tablespace_name;


-- ============================================================
-- 10. USERS WITH UNLIMITED TABLESPACE QUOTA
-- Important storage/security review
-- ============================================================

SELECT
    username,
    tablespace_name,
    bytes,
    max_bytes
FROM dba_ts_quotas
WHERE max_bytes = -1
ORDER BY username, tablespace_name;


-- ============================================================
-- 11. PASSWORD AND ACCOUNT SECURITY POLICIES
-- Review important profile settings
-- ============================================================

SELECT
    profile,
    resource_name,
    limit
FROM dba_profiles
WHERE resource_name IN (
    'FAILED_LOGIN_ATTEMPTS',
    'PASSWORD_LIFE_TIME',
    'PASSWORD_LOCK_TIME',
    'PASSWORD_GRACE_TIME',
    'PASSWORD_REUSE_TIME',
    'PASSWORD_REUSE_MAX',
    'PASSWORD_VERIFY_FUNCTION'
)
ORDER BY profile, resource_name;


-- ============================================================
-- 12. USERS AND THEIR SECURITY PROFILES
-- Connect users to password/resource policies
-- ============================================================

SELECT
    username,
    profile,
    account_status,
    created
FROM dba_users
ORDER BY profile, username;


-- ============================================================
-- 13. SECURITY SUMMARY BY USER
-- Count direct system privileges and assigned roles
-- ============================================================

SELECT
    u.username,
    u.account_status,
    u.profile,
    COUNT(DISTINCT sp.privilege) AS system_privilege_count,
    COUNT(DISTINCT rp.granted_role) AS role_count
FROM dba_users u
LEFT JOIN dba_sys_privs sp
    ON u.username = sp.grantee
LEFT JOIN dba_role_privs rp
    ON u.username = rp.grantee
GROUP BY
    u.username,
    u.account_status,
    u.profile
ORDER BY
    system_privilege_count DESC,
    role_count DESC,
    u.username;


-- ============================================================
-- 14. USERS WITH MULTIPLE ROLES
-- Useful for identifying complex access assignments
-- ============================================================

SELECT
    grantee,
    COUNT(*) AS role_count
FROM dba_role_privs
GROUP BY grantee
HAVING COUNT(*) > 1
ORDER BY role_count DESC, grantee;


-- ============================================================
-- 15. USERS WITH MULTIPLE DIRECT SYSTEM PRIVILEGES
-- Useful for identifying highly privileged accounts
-- ============================================================

SELECT
    grantee,
    COUNT(*) AS system_privilege_count
FROM dba_sys_privs
GROUP BY grantee
HAVING COUNT(*) > 1
ORDER BY system_privilege_count DESC, grantee;