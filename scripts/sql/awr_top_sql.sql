-- ==============================================================================
-- Top SQL by Elapsed Time, CPU, and Buffer Gets (AWR / ASH Telemetry)
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. TOP SQL IN ACTIVE SESSION HISTORY (LAST 60 MINUTES)
PROMPT ==============================================================================
SELECT 
    sql_id,
    sql_plan_hash_value,
    COUNT(*) AS ash_samples,
    ROUND(COUNT(*) * 10 / 60, 2) AS active_session_minutes,
    ROUND(COUNT(*) / SUM(COUNT(*)) OVER () * 100, 2) AS pct_db_time
FROM gv$active_session_history
WHERE sample_time > SYSDATE - 1/24
  AND sql_id IS NOT NULL
GROUP BY sql_id, sql_plan_hash_value
ORDER BY ash_samples DESC
FETCH FIRST 10 ROWS ONLY;

PROMPT ==============================================================================
PROMPT 2. TOP SQL BY TOTAL ELAPSED TIME IN CURSOR CACHE (V$SQL)
PROMPT ==============================================================================
SELECT 
    sql_id,
    plan_hash_value,
    executions,
    ROUND(elapsed_time / 1000000, 2) AS total_elapsed_sec,
    ROUND(elapsed_time / NULLIF(executions, 0) / 1000, 2) AS avg_elapsed_ms,
    ROUND(cpu_time / NULLIF(executions, 0) / 1000, 2) AS avg_cpu_ms,
    ROUND(buffer_gets / NULLIF(executions, 0), 2) AS avg_buffer_gets,
    sql_text
FROM v$sql
WHERE executions > 0
ORDER BY elapsed_time DESC
FETCH FIRST 10 ROWS ONLY;
