-- ==============================================================================
-- Oracle RAC Interconnect Latency & Global Cache Diagnostics
-- Target: Oracle RAC 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. GLOBAL CACHE (GC) WAIT EVENTS BY INSTANCE
PROMPT ==============================================================================
SELECT 
    inst_id,
    event,
    total_waits,
    round(time_waited_micro / 1000000, 2) AS time_waited_secs,
    round(average_wait * 10, 2) AS avg_wait_ms
FROM gv$system_event
WHERE event LIKE 'gc%'
ORDER BY time_waited_micro DESC;

PROMPT ==============================================================================
PROMPT 2. INTERCONNECT BLOCK LOSS & CORRUPTION CHECK
PROMPT ==============================================================================
SELECT 
    inst_id, 
    name, 
    value 
FROM gv$sysstat 
WHERE name IN ('gc cr blocks lost', 'gc current blocks lost', 'gc cr blocks served', 'gc current blocks served')
ORDER BY name, inst_id;
