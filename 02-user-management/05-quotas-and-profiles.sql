-- ============================================================
-- Oracle DBA Portfolio
-- Project: User Management & Security
-- File: 05-quotas-and-profiles.sql
-- Purpose: Demonstrate Oracle quotas and profile auditing
-- ============================================================


-- ============================================================
-- 1. DBA_TS_QUOTAS
-- Displays tablespace quotas for all database users
-- Requires appropriate DBA/catalog privileges
-- ============================================================

SELECT
    username,
    tablespace_name,
    bytes,
    max_bytes,
    blocks,
    max_blocks
FROM dba_ts_quotas
ORDER BY username, tablespace_name;


-- ============================================================
-- 2. Find users with unlimited tablespace quota
-- MAX_BYTES = -1 represents unlimited quota
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
-- 3. Find users with assigned storage quotas
-- Displays quota usage compared with the configured limit
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
-- 4. USER_TS_QUOTAS
-- Displays tablespace quota information for the current user
-- ============================================================

SELECT
    tablespace_name,
    bytes,
    max_bytes,
    blocks,
    max_blocks
FROM user_ts_quotas
ORDER BY tablespace_name;


-- ============================================================
-- 5. Identify quota usage percentage
-- Helps identify users approaching their quota limit
-- ============================================================

SELECT
    username,
    tablespace_name,
    bytes AS bytes_used,
    max_bytes AS quota_limit,
    ROUND((bytes / max_bytes) * 100, 2) AS quota_used_percent
FROM dba_ts_quotas
WHERE max_bytes > 0
ORDER BY quota_used_percent DESC;


-- ============================================================
-- 6. DBA_PROFILES
-- Displays profile settings for database users
-- ============================================================

SELECT
    profile,
    resource_name,
    resource_type,
    limit
FROM dba_profiles
ORDER BY profile, resource_type, resource_name;


-- ============================================================
-- 7. Password-related profile settings
-- Useful for security and password policy reviews
-- ============================================================

SELECT
    profile,
    resource_name,
    limit
FROM dba_profiles
WHERE resource_name IN (
    'FAILED_LOGIN_ATTEMPTS',
    'PASSWORD_LIFE_TIME',
    'PASSWORD_REUSE_TIME',
    'PASSWORD_REUSE_MAX',
    'PASSWORD_LOCK_TIME',
    'PASSWORD_GRACE_TIME',
    'PASSWORD_VERIFY_FUNCTION'
)
ORDER BY profile, resource_name;


-- ============================================================
-- 8. Resource-related profile settings
-- Useful for reviewing database resource restrictions
-- ============================================================

SELECT
    profile,
    resource_name,
    limit
FROM dba_profiles
WHERE resource_type = 'KERNEL'
ORDER BY profile, resource_name;


-- ============================================================
-- 9. Identify profiles used by database users
-- Helps connect users to their security policies
-- ============================================================

SELECT
    username,
    profile,
    account_status
FROM dba_users
ORDER BY profile, username;


-- ============================================================
-- 10. Count users assigned to each profile
-- Useful for profile impact analysis
-- ============================================================

SELECT
    profile,
    COUNT(*) AS user_count
FROM dba_users
GROUP BY profile
ORDER BY user_count DESC, profile;