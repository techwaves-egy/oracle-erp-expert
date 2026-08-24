-- ==============================================================================
-- Oracle Database Security, Role Grants, and Privilege Audit
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. USERS WITH DIRECT DBA ROLE OR SYSTEM PRIVILEGES
PROMPT ==============================================================================
SELECT grantee, granted_role, admin_option, default_role 
FROM dba_role_privs 
WHERE granted_role IN ('DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
ORDER BY grantee;

PROMPT ==============================================================================
PROMPT 2. DIRECT 'ANY' SYSTEM PRIVILEGE GRANTEES
PROMPT ==============================================================================
SELECT grantee, privilege, admin_option 
FROM dba_sys_privs 
WHERE privilege LIKE '%ANY%' 
  AND grantee NOT IN ('SYS', 'SYSTEM', 'AUDSYS', 'MDSYS', 'ORDSYS', 'WMSYS', 'LBACSYS', 'DVSYS', 'CTXSYS', 'GSMADMIN_INTERNAL')
ORDER BY grantee, privilege;

PROMPT ==============================================================================
PROMPT 3. DATABASE USER ACCOUNTS WITH DEFAULT PROFILES & OPEN STATUS
PROMPT ==============================================================================
SELECT 
    username, 
    account_status, 
    lock_date, 
    expiry_date, 
    profile 
FROM dba_users 
WHERE account_status = 'OPEN' 
  AND profile = 'DEFAULT'
ORDER BY username;
