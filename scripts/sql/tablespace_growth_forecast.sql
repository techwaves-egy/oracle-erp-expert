-- ==============================================================================
-- Tablespace Capacity, Free Space, and Autoextend Headroom Forecast
-- Target: Oracle RDBMS 11g / 12c / 19c / 23ai
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. TABLESPACES WITH DETAILED DATAFILE HEADROOM & MAX AUTOEXTEND
PROMPT ==============================================================================
SELECT 
    df.tablespace_name,
    COUNT(df.file_id) AS file_count,
    ROUND(SUM(df.bytes)/1024/1024/1024, 2) AS current_size_gb,
    ROUND(SUM(CASE WHEN df.autoextensible = 'YES' THEN df.maxbytes ELSE df.bytes END)/1024/1024/1024, 2) AS max_autoextend_gb,
    ROUND(NVL(SUM(fs.bytes), 0)/1024/1024/1024, 2) AS free_allocated_gb,
    ROUND((SUM(df.bytes) - NVL(SUM(fs.bytes), 0)) / SUM(df.bytes) * 100, 2) AS pct_current_used
FROM dba_data_files df
LEFT JOIN (SELECT tablespace_name, file_id, SUM(bytes) AS bytes FROM dba_free_space GROUP BY tablespace_name, file_id) fs
       ON df.tablespace_name = fs.tablespace_name AND df.file_id = fs.file_id
GROUP BY df.tablespace_name
ORDER BY pct_current_used DESC;
