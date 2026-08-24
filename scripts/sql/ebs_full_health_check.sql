-- ==============================================================================
-- Oracle EBS & Database Full Health Check Diagnostic Script
-- Target: Oracle RDBMS 11g/12c/19c/23ai with EBS R12.1/R12.2
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 220 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. DATABASE INSTANCE & HIGH AVAILABILITY STATUS
PROMPT ==============================================================================
SELECT inst_id, instance_name, host_name, version, status, database_status, startup_time 
FROM gv$instance ORDER BY inst_id;

SELECT name, db_unique_name, open_mode, database_role, log_mode, protection_mode 
FROM v$database;

PROMPT ==============================================================================
PROMPT 2. TABLESPACE UTILIZATION (> 80% USED)
PROMPT ==============================================================================
SELECT 
    m.tablespace_name,
    ROUND(m.tablespace_size * t.block_size / 1024 / 1024 / 1024, 2) AS total_gb,
    ROUND(m.used_space * t.block_size / 1024 / 1024 / 1024, 2) AS used_gb,
    ROUND(m.used_percent, 2) AS used_pct,
    ROUND((m.tablespace_size - m.used_space) * t.block_size / 1024 / 1024 / 1024, 2) AS free_gb
FROM dba_tablespace_usage_metrics m
JOIN dba_tablespaces t ON m.tablespace_name = t.tablespace_name
WHERE m.used_percent > 80
ORDER BY m.used_percent DESC;

PROMPT ==============================================================================
PROMPT 3. ACTIVE BLOCKING LOCK SESSIONS
PROMPT ==============================================================================
SELECT 
    lpad(' ', (level-1)*2) || sid as sess_tree,
    inst_id,
    serial#,
    username,
    status,
    sql_id,
    event,
    seconds_in_wait,
    blocking_instance,
    blocking_session
FROM gv$session
START WITH blocking_session IS NULL AND sid IN (SELECT blocking_session FROM gv$session WHERE blocking_session IS NOT NULL)
CONNECT BY PRIOR sid = blocking_session AND PRIOR inst_id = blocking_instance;

PROMPT ==============================================================================
PROMPT 4. FAST RECOVERY AREA (FRA) USAGE
PROMPT ==============================================================================
SELECT 
    name, 
    ROUND(space_limit/1024/1024/1024, 2) AS limit_gb,
    ROUND(space_used/1024/1024/1024, 2) AS used_gb,
    ROUND(space_reclaimable/1024/1024/1024, 2) AS reclaimable_gb,
    ROUND((space_used - space_reclaimable)/space_limit * 100, 2) AS pct_actual_used
FROM v$recovery_file_dest;

PROMPT ==============================================================================
PROMPT 5. EBS ACTIVE & PENDING CONCURRENT REQUESTS (Phase: Running / Pending)
PROMPT ==============================================================================
SELECT 
    r.request_id,
    p.user_concurrent_program_name,
    u.user_name requester,
    r.phase_code,
    r.status_code,
    r.actual_start_date,
    ROUND((SYSDATE - r.actual_start_date)*24*60, 2) runtime_mins,
    r.oracle_process_id spid
FROM fnd_concurrent_requests r
JOIN fnd_concurrent_programs_vl p ON r.concurrent_program_id = p.concurrent_program_id
JOIN fnd_user u ON r.requested_by = u.user_id
WHERE r.phase_code IN ('R', 'P')
ORDER BY r.actual_start_date ASC
FETCH FIRST 25 ROWS ONLY;

PROMPT ==============================================================================
PROMPT 6. RECENT RMAN BACKUP SUMMARY (LAST 7 DAYS)
PROMPT ==============================================================================
SELECT 
    session_key, input_type, status, 
    start_time, end_time, 
    ROUND(elapsed_seconds/60, 2) elapsed_min,
    ROUND(output_bytes/1024/1024/1024, 2) output_gb
FROM v$rman_backup_job_details
WHERE start_time > SYSDATE - 7
ORDER BY start_time DESC;
