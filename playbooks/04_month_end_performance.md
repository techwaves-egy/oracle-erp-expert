# Playbook 04: Month-End Financial Closing & Batch Bottlenecks

## 1. Problem Statement
Critical batch jobs, GL posting, Create Accounting, AR/AP reconciliations, or Order Management processing runs slower than baseline during month-end / quarter-end closing.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Concurrent Processing Expert**
* **Oracle Performance Engineer**
* **SQL / PL/SQL Expert**
* **Oracle Database DBA**
* **WebLogic Expert**
* **Storage Expert**
* **Capacity Planning Expert**

---

## 3. Investigation & Diagnostic Matrix

### Step 1: Concurrent Request Queue Analysis (Concurrent Processing Expert)
```sql
-- Identify long-running, pending, or erroring concurrent requests
SELECT 
    r.request_id,
    p.user_concurrent_program_name,
    u.user_name,
    r.phase_code,
    r.status_code,
    r.actual_start_date,
    ROUND((SYSDATE - r.actual_start_date)*24*60, 1) AS runtime_minutes,
    r.oracle_process_id AS spid,
    q.user_concurrent_queue_name AS manager_name
FROM fnd_concurrent_requests r
JOIN fnd_concurrent_programs_vl p ON r.concurrent_program_id = p.concurrent_program_id
JOIN fnd_user u ON r.requested_by = u.user_id
JOIN fnd_concurrent_queues_vl q ON r.controlling_manager = q.concurrent_queue_id
WHERE r.phase_code IN ('R', 'P')
ORDER BY r.actual_start_date ASC;

-- Check Conflict Resolution Manager (CRM) backlog
SELECT COUNT(*) FROM fnd_concurrent_requests WHERE status_code = 'Q' AND phase_code = 'P';
```

### Step 2: TEMP and UNDO Tablespace Contention (DBA & Storage Expert)
```sql
-- Check active TEMP space usage per session
SELECT 
    s.sid,
    s.username,
    s.program,
    s.sql_id,
    ROUND(u.blocks * 8192 / 1024 / 1024 / 1024, 2) AS temp_used_gb,
    u.tablespace
FROM gv$tempseg_usage u
JOIN gv$session s ON u.session_addr = s.saddr AND u.inst_id = s.inst_id
ORDER BY temp_used_gb DESC;

-- Check UNDO retention and unexpired steal errors
SELECT 
    begin_time,
    end_time,
    undoblks,
    txncount,
    maxquerylen,
    ssolderrcnt,
    nospaceerrcnt
FROM v$undostat
WHERE begin_time > SYSDATE - 1/24
ORDER BY begin_time DESC;
```

### Step 3: Top SQL Regressions vs Historical Baselines (Performance & SQL Experts)
```sql
-- Top SQL by Elapsed Time in the last hour from ASH
SELECT 
    sql_id,
    sql_plan_hash_value,
    COUNT(*) as ash_samples,
    ROUND(COUNT(*) * 10 / 60, 2) AS est_active_session_mins
FROM gv$active_session_history
WHERE sample_time > SYSDATE - 1/24
  AND sql_id IS NOT NULL
GROUP BY sql_id, sql_plan_hash_value
ORDER BY ash_samples DESC
FETCH FIRST 10 ROWS ONLY;

-- Compare execution plan changes via AWR history
SELECT 
    h.snap_id,
    h.plan_hash_value,
    ROUND(h.elapsed_time_delta / NULLIF(h.executions_delta, 0) / 1000, 2) AS avg_elapsed_ms,
    ROUND(h.buffer_gets_delta / NULLIF(h.executions_delta, 0), 2) AS avg_buffer_gets,
    h.executions_delta
FROM dba_hist_sqlstat h
WHERE h.sql_id = '<TARGET_SQL_ID>'
ORDER BY h.snap_id DESC;
```

### Step 4: Storage I/O Latency (Storage & Linux Experts)
```bash
# Check disk await times on database and redo storage
iostat -xz 1 5
# Look for: await > 10ms, %util > 85%, or queue depth spikes
```

---

## 4. Month-End Optimization Tactics
1. **Dynamic Concurrent Manager Allocation**: Temporarily increase target process slots for Standard Manager or dedicated Financials queues during the closing window.
2. **SQL Plan Baselines**: If execution plan regression is confirmed on a high-volume query, pin the known good `plan_hash_value` using `DBMS_SPM`.
3. **Redo Log Buffer & Checkpoint Tuning**: Ensure log file switches occur every 15–20 minutes and `log_buffer` does not exhibit `log buffer space` wait events.
4. **Gather Schema Statistics**: Ensure outdated CBO statistics on high-churn transaction tables (`AP_INVOICES_ALL`, `GL_JE_LINES`, etc.) are refreshed using `FND_STATS`.
