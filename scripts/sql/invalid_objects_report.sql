-- ==============================================================================
-- Invalid Database Objects Report & Automated Recompile Script Generator
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai & Oracle EBS
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. INVALID OBJECTS COUNT BY SCHEMA AND TYPE
PROMPT ==============================================================================
SELECT 
    owner, 
    object_type, 
    COUNT(*) AS invalid_count 
FROM dba_objects 
WHERE status = 'INVALID'
GROUP BY owner, object_type
ORDER BY owner, object_type;

PROMPT ==============================================================================
PROMPT 2. EBS SPECIFIC INVALID OBJECTS (APPS / APPLSYS / CORE MODULES)
PROMPT ==============================================================================
SELECT 
    owner, 
    object_name, 
    object_type, 
    status, 
    last_ddl_time
FROM dba_objects
WHERE status = 'INVALID'
  AND owner IN ('APPS', 'APPLSYS', 'GL', 'AP', 'AR', 'PO', 'INV', 'ONT', 'PA', 'HR')
ORDER BY last_ddl_time DESC
FETCH FIRST 30 ROWS ONLY;
