-- ==============================================================================
-- Comprehensive Session Diagnostics & Active Wait Event Snapshot
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. ACTIVE USER SESSIONS (EXCLUDING BACKGROUND)
PROMPT ==============================================================================
SELECT 
    s.inst_id,
    s.sid,
    s.serial#,
    s.username,
    s.status,
    s.osuser,
    s.machine,
    s.program,
    s.module,
    s.sql_id,
    s.event,
    s.seconds_in_wait,
    s.blocking_session,
    s.blocking_instance
FROM gv$session s
WHERE s.status = 'ACTIVE'
  AND s.type != 'BACKGROUND'
ORDER BY s.seconds_in_wait DESC;

PROMPT ==============================================================================
PROMPT 2. TOP SYSTEM WAIT EVENTS ACROSS ALL RAC NODES
PROMPT ==============================================================================
SELECT 
    inst_id,
    event,
    total_waits,
    round(time_waited_micro / 1000000, 2) AS time_waited_secs,
    round(average_wait * 10, 2) AS avg_wait_ms,
    wait_class
FROM gv$system_event
WHERE wait_class != 'Idle'
ORDER BY time_waited_micro DESC
FETCH FIRST 15 ROWS ONLY;

PROMPT ==============================================================================
PROMPT 3. HIERARCHICAL BLOCKING SESSION TREE
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
