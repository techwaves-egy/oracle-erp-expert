-- ==============================================================================
-- Oracle Database & EBS Security Audit & Privilege Compliance Checklist
-- Non-Destructive / Read-Only Script
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- ==============================================================================

SET LINESIZE 220 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. USERS WITH DBA ROLE OR 'ANY' SYSTEM PRIVILEGES
PROMPT ==============================================================================
SELECT grantee, granted_role, admin_option, default_role 
FROM dba_role_privs 
WHERE granted_role IN ('DBA', 'EXP_FULL_DATABASE', 'IMP_FULL_DATABASE')
ORDER BY grantee;

SELECT grantee, privilege, admin_option 
FROM dba_sys_privs 
WHERE privilege LIKE '%ANY%' 
  AND grantee NOT IN ('SYS', 'SYSTEM', 'AUDSYS', 'MDSYS', 'ORDSYS', 'WMSYS', 'LBACSYS', 'DVSYS', 'CTXSYS', 'GSMADMIN_INTERNAL')
ORDER BY grantee, privilege;

PROMPT ==============================================================================
PROMPT 2. OPEN DATABASE ACCOUNTS & PASSWORD EXPIRATION STATUS
PROMPT ==============================================================================
SELECT 
    username, 
    account_status, 
    lock_date, 
    expiry_date, 
    created, 
    profile 
FROM dba_users 
WHERE account_status = 'OPEN'
ORDER BY username;

PROMPT ==============================================================================
PROMPT 3. TRANSPARENT DATA ENCRYPTION (TDE) WALLET STATUS
PROMPT ==============================================================================
SELECT 
    wrl_type, 
    wrl_parameter, 
    status, 
    wallet_type 
FROM v$encryption_wallet;

PROMPT ==============================================================================
PROMPT 4. UNIFIED AUDITING / STANDARD AUDIT POLICIES
PROMPT ==============================================================================
SELECT policy_name, enabled_option, entity_name, entity_type, success, failure 
FROM audit_unified_enabled_policies;
