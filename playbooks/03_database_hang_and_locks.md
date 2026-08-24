# Playbook 03: Oracle Database Hang & Lock Tree Investigation

## 1. Problem Statement
The Oracle Database is unresponsive, user transactions are hanging, batch jobs are stalled, or CPU utilization is pinned at 100%.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **Oracle Performance Engineer**
* **SQL / PL/SQL Expert**
* **RAC / Grid / ASM Architect**
* **Oracle Linux Expert**
* **Storage Expert**

---

## 3. Immediate Triage Workflow

```
[System Unresponsive / High Latency]
                 │
                 ▼
  [Step 1: Check OS CPU, Run-Queue & Memory Paging]
                 │
                 ▼
  [Step 2: Check Active Sessions & Wait Events]
                 │
                 ▼
  [Step 3: Build Root Blocking Lock Tree]
                 │
                 ▼
  [Step 4: Analyze Root Blocker SQL & Resource Consumption]
                 │
                 ▼
  [Step 5: Execute Controlled Termination or SQL Mitigation]
```

---

## 4. Diagnostic Commands & Queries

### Step 1: OS Resource Health (Linux Expert)
```bash
# Check CPU run-queue and load average vs available cores
uptime
sar -q 1 5
mpstat -P ALL 1 3

# Check Memory paging / swapping
vmstat 1 5
free -m
```

### Step 2: System Wait Events & Active Sessions (Performance Engineer)
```sql
-- Identify Top Active Wait Events across RAC instances
SELECT 
    inst_id,
    event,
    COUNT(*) as waiting_sessions
FROM gv$session
WHERE status = 'ACTIVE'
  AND wait_class != 'Idle'
GROUP BY inst_id, event
ORDER BY waiting_sessions DESC;
```

### Step 3: Identify Root Blocking Session Tree (DBA & Performance Engineer)
```sql
-- Hierarchical Blocking Session Query
SELECT 
    LPAD(' ', (LEVEL-1)*3) || 'INST:' || inst_id || ' SID:' || sid || ' SERIAL#:' || serial# AS session_tree,
    username,
    status,
    sql_id,
    event,
    seconds_in_wait,
    blocking_instance,
    blocking_session,
    program,
    module
FROM gv$session
START WITH blocking_session IS NULL 
       AND sid IN (SELECT DISTINCT blocking_session FROM gv$session WHERE blocking_session IS NOT NULL)
CONNECT BY PRIOR sid = blocking_session 
       AND PRIOR inst_id = blocking_instance;
```

### Step 4: Inspect the Root Blocker Query (SQL Expert)
```sql
-- Inspect the active SQL text and plan of the root blocker
SELECT 
    sql_id,
    sql_fulltext,
    executions,
    elapsed_time/1000000 AS elapsed_secs,
    cpu_time/1000000 AS cpu_secs,
    buffer_gets,
    disk_reads
FROM v$sql
WHERE sql_id = '<ROOT_BLOCKER_SQL_ID>';

-- Check for unindexed foreign keys causing table-level share locks (TM locks)
SELECT 
    o.object_name,
    l.locked_mode,
    s.sid,
    s.serial#,
    s.username,
    s.program
FROM gv$locked_object l
JOIN dba_objects o ON l.object_id = o.object_id
JOIN gv$session s ON l.session_id = s.sid AND l.inst_id = s.inst_id;
```

---

## 5. Remediation Protocol

### Controlled Session Termination (Production Safety Gate)
```sql
-- 1. Validate session details before termination:
SELECT inst_id, sid, serial#, username, osuser, machine, program, module, sql_id 
FROM gv$session 
WHERE sid = <TARGET_SID> AND inst_id = <TARGET_INST_ID>;

-- 2. Kill the blocking session cleanly at database level:
ALTER SYSTEM KILL SESSION '<SID>,<SERIAL#>,@<INST_ID>' IMMEDIATE;

-- 3. If session hangs in KILLED status and holds locks at OS level (Emergency only):
-- Linux Expert: Identify OS SPID
SELECT p.spid 
FROM gv$process p 
JOIN gv$session s ON p.addr = s.paddr AND p.inst_id = s.inst_id 
WHERE s.sid = <TARGET_SID> AND s.inst_id = <TARGET_INST_ID>;

-- Kill at OS level (Authorized DBA action):
-- kill -9 <SPID>
```
