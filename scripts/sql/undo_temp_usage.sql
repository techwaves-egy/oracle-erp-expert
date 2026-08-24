-- ==============================================================================
-- Real-Time TEMP and UNDO Space Utilization Diagnostics
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. ACTIVE SESSIONS CONSUMING TEMP TABLESPACE (> 100MB)
PROMPT ==============================================================================
SELECT 
    s.inst_id,
    s.sid,
    s.serial#,
    s.username,
    s.program,
    s.sql_id,
    ROUND(u.blocks * 8192 / 1024 / 1024 / 1024, 2) AS temp_used_gb,
    u.tablespace,
    u.segtype
FROM gv$tempseg_usage u
JOIN gv$session s ON u.session_addr = s.saddr AND u.inst_id = s.inst_id
ORDER BY temp_used_gb DESC;

PROMPT ==============================================================================
PROMPT 2. UNDO RETENTION & STEAL ERRORS (LAST 4 HOURS)
PROMPT ==============================================================================
SELECT 
    begin_time,
    end_time,
    undoblks,
    txncount,
    maxquerylen,
    ssolderrcnt,
    nospaceerrcnt
FROM v$undostat
WHERE begin_time > SYSDATE - 4/24
ORDER BY begin_time DESC;
