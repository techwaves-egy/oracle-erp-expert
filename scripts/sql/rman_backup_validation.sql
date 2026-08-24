-- ==============================================================================
-- RMAN Backup History, Verification, and Coverage Validation
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. RMAN BACKUP JOBS SUMMARY (LAST 14 DAYS)
PROMPT ==============================================================================
SELECT 
    session_key, 
    input_type, 
    status, 
    start_time, 
    end_time, 
    ROUND(elapsed_seconds/60, 2) AS elapsed_min,
    ROUND(input_bytes/1024/1024/1024, 2) AS input_gb,
    ROUND(output_bytes/1024/1024/1024, 2) AS output_gb,
    output_device_type
FROM v$rman_backup_job_details
WHERE start_time > SYSDATE - 14
ORDER BY start_time DESC;

PROMPT ==============================================================================
PROMPT 2. FAST RECOVERY AREA (FRA) USAGE BREAKDOWN
PROMPT ==============================================================================
SELECT 
    name, 
    ROUND(space_limit/1024/1024/1024, 2) AS limit_gb,
    ROUND(space_used/1024/1024/1024, 2) AS used_gb,
    ROUND(space_reclaimable/1024/1024/1024, 2) AS reclaimable_gb,
    ROUND((space_used - space_reclaimable)/space_limit * 100, 2) AS pct_actual_used
FROM v$recovery_file_dest;

SELECT 
    file_type,
    percent_space_used,
    percent_space_reclaimable,
    number_of_files
FROM v$flash_recovery_area_usage;
