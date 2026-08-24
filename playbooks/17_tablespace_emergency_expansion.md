# Playbook 17: Tablespace Capacity Emergency Expansion

## 1. Scope
Emergency remediation for tablespace exhaustion (`ORA-01653: unable to extend table`, `ORA-01654: unable to extend index`, `ORA-01652: unable to extend temp segment`), datafile autoextend management, and Bigfile tablespace resizing.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **Storage Expert**
* **Capacity Planning Expert**
* **Change Management Expert**

---

## 3. Immediate Diagnostic Queries

### Step 1: Identify Tablespaces Near Exhaustion (> 85% Used)
```sql
SELECT 
    m.tablespace_name,
    ROUND(m.tablespace_size * t.block_size / 1024 / 1024 / 1024, 2) AS total_gb,
    ROUND(m.used_space * t.block_size / 1024 / 1024 / 1024, 2) AS used_gb,
    ROUND(m.used_percent, 2) AS used_pct,
    ROUND((m.tablespace_size - m.used_space) * t.block_size / 1024 / 1024 / 1024, 2) AS free_gb
FROM dba_tablespace_usage_metrics m
JOIN dba_tablespaces t ON m.tablespace_name = t.tablespace_name
WHERE m.used_percent > 85
ORDER BY m.used_percent DESC;
```

### Step 2: Check Physical Datafile Autoextend Limits
```sql
SELECT 
    tablespace_name,
    file_name,
    file_id,
    ROUND(bytes/1024/1024/1024, 2) AS size_gb,
    ROUND(maxbytes/1024/1024/1024, 2) AS max_gb,
    autoextensible,
    increment_by * 8192 / 1024 / 1024 AS inc_mb
FROM dba_data_files
WHERE tablespace_name = '<TABLESPACE_NAME>'
ORDER BY file_id;
```

---

## 4. Emergency Remediation Procedures

### Scenario 1: Bigfile Tablespace Resizing (Instant Expansion)
```sql
-- For Bigfile tablespaces (e.g. up to 32TB with 8K block size):
ALTER TABLESPACE APPS_TS_TX_DATA RESIZE 500G;
```

### Scenario 2: Smallfile Tablespace — Resize Existing Datafile
```sql
-- Resize datafile up to maximum smallfile limit (32GB for 8K block size):
ALTER DATABASE DATAFILE '+DATA/PRODDB/DATAFILE/apps_tx_data01.dbf' RESIZE 30G;
```

### Scenario 3: Smallfile Tablespace — Add New Datafile (ASM Target)
```sql
-- Add new autoextensible datafile to ASM disk group:
ALTER TABLESPACE APPS_TS_TX_DATA ADD DATAFILE '+DATA' 
  SIZE 10G 
  AUTOEXTEND ON NEXT 1G MAXSIZE 31G;
```

### Scenario 4: Smallfile Tablespace — Add New Datafile (Filesystem Target)
```sql
-- Verify free filesystem space first (`df -h /u02/oradata`):
ALTER TABLESPACE APPS_TS_TX_DATA ADD DATAFILE '/u02/oradata/PRODDB/apps_tx_data08.dbf' 
  SIZE 10G 
  AUTOEXTEND ON NEXT 1G MAXSIZE 31G;
```

### Scenario 5: Emergency TEMP Tablespace Expansion
```sql
-- Add new tempfile to resolve ORA-01652:
ALTER TABLESPACE TEMP ADD TEMPFILE '+DATA' 
  SIZE 20G 
  AUTOEXTEND ON NEXT 2G MAXSIZE 31G;
```
