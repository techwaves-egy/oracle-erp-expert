# Playbook 01: Enterprise Oracle ERP & Database Full Health Check

## 1. Trigger
Invoked when user requests: *"Perform Oracle ERP health check"*, *"Run full database health audit"*, or before scheduled enterprise maintenance.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **EBS Architect** & **EBS System Administrator**
* **Oracle Database DBA** & **Performance Engineer**
* **RAC / Grid / ASM Architect**
* **RMAN Backup & Recovery Expert**
* **Data Guard / DR Expert**
* **WebLogic Expert**
* **Concurrent Processing Expert**
* **Oracle Linux Expert** & **Storage Expert**
* **Oracle Security Architect**
* **Monitoring & Capacity Planning Experts**

## 3. Investigation & Diagnostic Matrix

### Phase 1: Operating System & Hardware Resources (Linux & Storage Experts)
```bash
# 1. OS Load and Core Resource Usage
uptime
vmstat 1 5
free -m
sar -u 1 5
sar -q 1 5

# 2. Filesystem Capacity & Inodes
df -h
df -i

# 3. Disk Latency & I/O Service Time
iostat -xz 1 5
sar -d 1 5
```

### Phase 2: Oracle Database Core Health & Instances (DBA & RAC Experts)
```sql
-- Database status, role, and open mode
SELECT inst_id, instance_name, host_name, version, status, database_status, startup_time 
FROM gv$instance;

SELECT name, db_unique_name, open_mode, database_role, log_mode, protection_mode 
FROM v$database;

-- Clusterware resource status (via OS terminal)
-- crsctl stat res -t
```

### Phase 3: Tablespace & Storage Capacity (DBA & Capacity Planning)
```sql
SELECT 
    m.tablespace_name,
    ROUND(m.tablespace_size * t.block_size / 1024 / 1024 / 1024, 2) AS total_gb,
    ROUND(m.used_space * t.block_size / 1024 / 1024 / 1024, 2) AS used_gb,
    ROUND(m.used_percent, 2) AS used_pct,
    ROUND((m.tablespace_size - m.used_space) * t.block_size / 1024 / 1024 / 1024, 2) AS free_gb
FROM dba_tablespace_usage_metrics m
JOIN dba_tablespaces t ON m.tablespace_name = t.tablespace_name
WHERE m.used_percent > 80
ORDER BY m.used_percent DESC;
```

### Phase 4: Performance & Wait Event Telemetry (Performance Engineer)
```sql
-- Top 10 System Wait Events
SELECT 
    event,
    total_waits,
    round(time_waited_micro / 1000000, 2) AS time_waited_secs,
    round(average_wait * 10, 2) AS avg_wait_ms,
    wait_class
FROM v$system_event
WHERE wait_class != 'Idle'
ORDER BY time_waited_micro DESC
FETCH FIRST 10 ROWS ONLY;

-- Check for any blocking sessions
SELECT 
    inst_id, sid, serial#, username, status, blocking_instance, blocking_session, event, seconds_in_wait
FROM gv$session
WHERE blocking_session IS NOT NULL;
```

### Phase 5: RMAN & Data Guard Resilience (RMAN & DR Experts)
```sql
-- Latest Backup Status across types
SELECT 
    session_key, input_type, status, 
    start_time, end_time, 
    ROUND(elapsed_seconds/60, 2) elapsed_min,
    ROUND(output_bytes/1024/1024/1024, 2) output_gb
FROM v$rman_backup_job_details
WHERE start_time > SYSDATE - 7
ORDER BY start_time DESC;

-- Data Guard MRP and Gap check (on Standby)
SELECT process, status, thread#, sequence#, block#, blocks 
FROM v$managed_standby 
WHERE process IN ('MRP0', 'RFS');

SELECT * FROM v$archive_gap;
```

### Phase 6: EBS Application Tier & Concurrent Managers (EBS & Concurrent Experts)
```sql
-- Concurrent Manager Queue Status
SELECT 
    q.concurrent_queue_name,
    q.user_concurrent_queue_name,
    q.max_processes,
    q.running_processes,
    COUNT(r.request_id) AS pending_requests
FROM fnd_concurrent_queues_vl q
LEFT JOIN fnd_concurrent_requests r 
    ON q.concurrent_queue_id = r.controlling_manager 
   AND r.phase_code = 'P' AND r.status_code IN ('I', 'Q')
GROUP BY q.concurrent_queue_name, q.user_concurrent_queue_name, q.max_processes, q.running_processes
HAVING q.running_processes = 0 OR COUNT(r.request_id) > 10;

-- EBS Invalid Objects Count
SELECT owner, object_type, COUNT(*) 
FROM dba_objects 
WHERE status = 'INVALID' AND owner IN ('APPS', 'APPLSYS', 'GL', 'AP', 'AR', 'PO', 'INV')
GROUP BY owner, object_type;
```

---

## 4. Health Check Report Delivery Structure
1. **Executive Scorecard** (Overall Rating: Green / Amber / Red)
2. **Critical & High Priority Findings**
3. **Layer-by-Layer Health Breakdown**:
   - Operating System & Storage Subsystem
   - RAC / ASM & High Availability
   - Oracle Database RDBMS & Memory
   - Performance & SQL Efficiency
   - RMAN Backups & Disaster Recovery
   - EBS Application Tier & WebLogic Services
   - Concurrent Processing & Workflow
4. **Capacity & Growth Forecast**
5. **Prioritized Action Plan with Production Safety Verification**
