# Playbook 20: Oracle Alert Log Monitoring & Critical ORA- Error Triage

## 1. Scope
Rapid triage and root cause isolation for critical Oracle Database internal errors: `ORA-00600` (Internal Error), `ORA-07445` (Exception Encountered / Core Dump), `ORA-04031` (Shared Pool / Streams Pool Out of Memory), `ORA-01555` (Snapshot Too Old / Undo Exhaustion), and `ORA-00060` (Deadlock Detected).

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **Oracle Performance Engineer**
* **SQL / PL/SQL Expert**
* **Oracle Linux Expert**
* **Incident Response / RCA Expert**

---

## 3. Critical ORA- Error Decision Matrix

| Error Code | Meaning | Root Cause Category | Diagnostic Action |
|---|---|---|---|
| `ORA-00600` | Oracle Internal Kernel Exception | Known RDBMS bug, dictionary inconsistency, or corrupt block | Extract first 2 arguments (e.g. `[kdsgrp1]`), locate incident trace file, search My Oracle Support (MOS) ORA-600 Lookup Tool. |
| `ORA-07445` | OS Exception / Signal (SIGSEGV) | Memory pointer corruption or kernel library incompatibility | Extract C function call stack from trace file in ADR (`/diag/rdbms/.../incident`). |
| `ORA-04031` | Unable to allocate Shared/Streams Memory | Shared Pool fragmentation, cursor pinning, or `SHARED_POOL_SIZE` too small | Query `v$sgastat`, check unpinned large packages, flush or resize Shared Pool. |
| `ORA-01555` | Snapshot Too Old | UNDO retention too small, UNDO tablespace unextended, or high query runtime | Check `v$undostat`, increase `UNDO_RETENTION`, optimize SQL elapsed time. |
| `ORA-00060` | Deadlock Detected | Circular lock dependency between concurrent user transactions | Inspect deadlock graph in alert log / trace file; index unindexed foreign keys or change transaction update order. |

---

## 4. Diagnostic Queries & Commands

### Step 1: Query Alert Log via ADRCI (DBA Expert)
```bash
# Enter ADRCI CLI
adrci
adrci> show homes
adrci> set home <rdbms_home_path>
adrci> show alert -tail 100 -p "message_text like '%ORA-%'"
adrci> show incident
```

### Step 2: Query Live Alert Log & Trace Files via SQL (12c / 19c / 23ai)
```sql
-- Query latest 50 alert log entries via X$DBGALERTEXT
SELECT 
    originating_timestamp, 
    message_text 
FROM v$diag_alert_ext 
WHERE message_text LIKE '%ORA-%' 
  AND originating_timestamp > SYSDATE - 1
ORDER BY originating_timestamp DESC
FETCH FIRST 50 ROWS ONLY;
```

### Step 3: Shared Pool Memory Diagnostic (for ORA-04031)
```sql
-- Check Top Shared Pool Allocations
SELECT 
    pool, 
    name, 
    ROUND(bytes/1024/1024, 2) AS mb 
FROM v$sgastat 
WHERE pool = 'shared pool' 
ORDER BY bytes DESC 
FETCH FIRST 15 ROWS ONLY;

-- Check Free Memory in Shared Pool
SELECT pool, name, ROUND(bytes/1024/1024, 2) AS free_mb 
FROM v$sgastat 
WHERE name = 'free memory' AND pool = 'shared pool';
```
