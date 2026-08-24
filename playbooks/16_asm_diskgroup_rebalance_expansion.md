# Playbook 16: ASM Disk Group Full, Rebalance & Disk Management

## 1. Scope
Managing Automatic Storage Management (ASM) disk group capacity exhaustion, rebalance operations, adding/dropping storage LUNs, and disk header corruption triage.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **RAC / Grid / ASM Architect**
* **Storage Expert**
* **Oracle Database DBA**
* **Oracle Linux Expert**

---

## 3. ASM Diagnostic Commands

### Step 1: Disk Group Capacity & Free Headroom (ASM Architect)
```sql
-- Connect to ASM instance (+ASM)
SELECT 
    name,
    state,
    type,
    total_mb,
    free_mb,
    usable_file_mb,
    ROUND((total_mb - free_mb) / total_mb * 100, 2) AS pct_used,
    offline_disks
FROM v$asm_diskgroup;
```

### Step 2: Disk Status & Header Validation
```sql
SELECT 
    group_number,
    disk_number,
    name,
    path,
    header_status,
    mode_status,
    state,
    total_mb,
    free_mb,
    read_errs,
    write_errs
FROM v$asm_disk
ORDER BY group_number, disk_number;
```

### Step 3: Monitor Active Rebalance Operations
```sql
SELECT 
    group_number,
    operation,
    state,
    power,
    est_minutes,
    soa
FROM v$asm_operation;
```

---

## 4. Remediation & Expansion Procedures

### Scenario A: Adding Disks to Disk Group with Optimized Rebalance Power
```sql
-- Add new storage disks discovered under /dev/oracleasm/disks/ or ASMLib/udev:
ALTER DISKGROUP DATA ADD DISK 
  '/dev/oracleasm/disks/DATA_LUN09',
  '/dev/oracleasm/disks/DATA_LUN10'
REBALANCE POWER 8;
```

### Scenario B: Dropping a Faulty / Failing Disk Safely
```sql
-- Drop disk (ASM safely evacuates all allocation units to remaining disks):
ALTER DISKGROUP DATA DROP DISK DATA_0004 REBALANCE POWER 6;
```

### Scenario C: Speeding Up / Slowing Down Active Rebalance
```sql
-- Increase rebalance speed during maintenance window:
ALTER DISKGROUP DATA REBALANCE POWER 11;

-- Throttle rebalance speed during peak production hours:
ALTER DISKGROUP DATA REBALANCE POWER 1;
```
