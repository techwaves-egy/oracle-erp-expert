# Playbook 06: EBS 12.2 Online Patching (ADOP) Cycle

## 1. Scope & Objective
Execution, troubleshooting, and validation of the Oracle E-Business Suite R12.2 Online Patching cycle across dual application file systems (`fs1`, `fs2`, `fs_ne`) and Database Edition-Based Redefinition (EBR).

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **ADOP / Patching Expert**
* **Oracle EBS Architect**
* **Oracle Database DBA**
* **Oracle Linux Expert**
* **WebLogic Expert**
* **RMAN Backup & Recovery Expert**
* **Change Management Expert**

---

## 3. ADOP Lifecycle & Phase Flow

```
[Production Baseline: fs1 (RUN), fs2 (PATCH)]
                     │
                     ▼
            [adop phase=prepare]
   (Synchronizes patch fs from run fs via fs_clone / rsync)
                     │
                     ▼
            [adop phase=apply]
   (Applies patches to patch fs and creates new DB patch edition)
                     │
                     ▼
           [adop phase=finalize]
   (Compiles invalid objects and prepares for brief cutover)
                     │
                     ▼
            [adop phase=cutover]
  (Downtime window: Flips run/patch fs pointers & DB edition)
                     │
                     ▼
           [adop phase=cleanup]
   (Drops old DB editions and cleans staging tables)
```

---

## 4. Pre-Patch Readiness & Safety Gates

### Phase 0: Mandatory Safety Checks
```bash
# 1. Check disk space on application tier filesystems
df -h $FILE_EDITION
# Ensure fs1, fs2, and fs_ne have at least 25-50GB free headroom

# 2. Check Database Editions status
```
```sql
SELECT edition_name, parent_edition_name, usable 
FROM dba_editions 
ORDER BY edition_name;

-- 3. Verify no active ADOP session is lingering
SELECT adop_session_id, prepared_phase, applied_phase, finalized_phase, cutover_phase, status 
FROM ad_adop_sessions 
ORDER BY adop_session_id DESC;

-- 4. Check for invalid database objects
SELECT count(*) FROM dba_objects WHERE status = 'INVALID' AND owner = 'APPS';
```

---

## 5. Execution & Phase Commands

### Step 1: Prepare Phase
```bash
source <EBS_BASE>/EBSapps.env run
adop phase=prepare
```

### Step 2: Apply Phase
```bash
adop phase=apply patches=<PATCH_NUMBER>
# For merged patches:
# adop phase=apply patchtop=<DIR> patches=<P1,P2,P3>
```

### Step 3: Finalize Phase
```bash
adop phase=finalize
```

### Step 4: Cutover Phase (Requires Scheduled Outage Window)
```bash
adop phase=cutover
```

### Step 5: Cleanup Phase (Post-Cutover)
```bash
source <EBS_BASE>/EBSapps.env run
adop phase=cleanup
# For deep cleanup of older unused editions:
# adop phase=cleanup cleanup_mode=full
```

---

## 6. Failure Recovery & Abort Strategy

### When to Abort
If a patch fails during `prepare`, `apply`, or `finalize` and cannot be resolved quickly:
```bash
# Abort the active cycle safely
adop phase=abort

# Followed by mandatory cleanup and fs_clone:
adop phase=cleanup
adop phase=fs_clone
```

> [!CAUTION]
> **Never run `adop phase=abort` after `cutover` has completed!** Once cutover succeeds, the patch filesystem has become the new run filesystem. You cannot abort; any regression must be addressed via a forward-fix patch or full enterprise restore.
