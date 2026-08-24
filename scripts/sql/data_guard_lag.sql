-- ==============================================================================
-- Oracle Data Guard MRP Status, Transport Lag & Archive Continuity
-- Target: Oracle Data Guard 11g / 12c / 19c / 23ai (Standby or Primary)
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. DATA GUARD MANAGED STANDBY PROCESSES (MRP0 / RFS)
PROMPT ==============================================================================
SELECT 
    inst_id,
    process, 
    status, 
    thread#, 
    sequence#, 
    block#, 
    blocks,
    delay_mins
FROM gv$managed_standby 
WHERE process IN ('MRP0', 'RFS')
ORDER BY thread#, process;

PROMPT ==============================================================================
PROMPT 2. DATA GUARD ARCHIVE LOG GAPS
PROMPT ==============================================================================
SELECT * FROM v$archive_gap;

PROMPT ==============================================================================
PROMPT 3. STANDBY APPLY LAG & TRANSPORT LAG (DATA GUARD BROKER STATS)
PROMPT ==============================================================================
SELECT name, value, datum_time, time_computed 
FROM v$dataguard_stats;
