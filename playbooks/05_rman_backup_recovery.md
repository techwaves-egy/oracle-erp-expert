# Playbook 05: RMAN Backup Failure & Recovery Validation

## 1. Problem Statement
RMAN backup job fails with errors (`ORA-19809: limit exceeded for recovery files`, `ORA-19502: write error on file`, `ORA-19504: failed to create file`, `RMAN-06059: expected archived log not found`), or recovery validation is requested.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **RMAN Backup & Recovery Expert**
* **Oracle Database DBA**
* **Storage Expert**
* **Oracle Linux Expert**
* **Data Guard / DR Expert**
* **Linux Security Expert**

---

## 3. Diagnostic & Triage Workflow

### Step 1: Analyze RMAN Error Stack & History (RMAN Expert)
```sql
-- Check recent failed RMAN sessions
SELECT 
    session_key,
    command_id,
    input_type,
    status,
    start_time,
    end_time,
    elapsed_seconds,
    output_bytes_display,
    status
FROM v$rman_status
WHERE status != 'COMPLETED'
  AND start_time > SYSDATE - 3
ORDER BY start_time DESC;

-- Identify exact RMAN output log lines
SELECT 
    output 
FROM v$rman_output 
WHERE session_key = <SESSION_KEY>
ORDER BY recid;
```

### Step 2: Check Fast Recovery Area (FRA) Saturation (Storage & DBA Experts)
```sql
-- Inspect FRA utilization and reclaimable capacity
SELECT 
    name,
    ROUND(space_limit/1024/1024/1024, 2) AS limit_gb,
    ROUND(space_used/1024/1024/1024, 2) AS used_gb,
    ROUND(space_reclaimable/1024/1024/1024, 2) AS reclaimable_gb,
    ROUND((space_used - space_reclaimable)/space_limit * 100, 2) AS pct_actual_used
FROM v$recovery_file_dest;

-- Breakdown of components consuming FRA
SELECT 
    file_type,
    percent_space_used,
    percent_space_reclaimable,
    number_of_files
FROM v$flash_recovery_area_usage;
```

### Step 3: Archive Log Continuity & Missing Sequences (DBA & DR Experts)
```sql
-- Check for missing or unbacked archive logs
SELECT 
    thread#,
    sequence#,
    first_time,
    next_time,
    archived,
    status,
    deleted
FROM v$archived_log
WHERE next_time > SYSDATE - 2
  AND deleted = 'NO'
ORDER BY sequence# DESC;

-- Check Crosscheck status in RMAN:
-- RMAN> CROSSCHECK ARCHIVELOG ALL;
```

---

## 4. Remediation & Restore Validation

### Resolving ORA-19809 (FRA Full)
1. **Never use OS `rm` to delete archive logs from the FRA!** This will desynchronize the RMAN controlfile catalog.
2. Back up archive logs to tape/secondary storage and delete backed-up logs via RMAN:
```text
RMAN> BACKUP ARCHIVELOG ALL DELETE INPUT;
```
3. Or dynamically resize the FRA (if underlying storage capacity exists):
```sql
ALTER SYSTEM SET db_recovery_file_dest_size = 500G SCOPE=BOTH;
```

### Restore & Recoverability Validation Protocol
A successful backup does not prove recoverability. Validate regularly:
```text
# Run non-destructive validate commands:
RMAN> RESTORE DATABASE VALIDATE;
RMAN> RESTORE ARCHIVELOG ALL VALIDATE;
RMAN> RESTORE CONTROLFILE VALIDATE;
```
