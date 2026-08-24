# Playbook 09: Oracle Database 19c / 23ai Upgrade via AutoUpgrade

## 1. Scope
Automated, standardized, and zero-loss upgrade of Oracle Databases (11.2.0.4, 12.1.0.2, 12.2.0.1, 18c) to Oracle Database 19c (Long Term Support) or 23ai using the official Oracle **AutoUpgrade Tool** (`autoupgrade.jar`).

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **Oracle Performance Engineer**
* **SQL / PL/SQL Expert**
* **RMAN Backup & Recovery Expert**
* **Oracle Linux Expert**
* **Storage Expert**
* **Change Management Expert**

---

## 3. End-to-End Upgrade Lifecycle

```
[Pre-Upgrade Assessment: Analyze Mode]
                 │
                 ▼
[Automated Pre-Fixups: Fixups Mode]
                 │
                 ▼
[Guaranteed Restore Point (GRP) & Flashback Protection]
                 │
                 ▼
[Execution: Deploy Mode (dbupgrade + dictionary compile)]
                 │
                 ▼
[Post-Upgrade: Post-Fixups, Timezone Upgrade & Statistics]
                 │
                 ▼
[Performance Validation: SQL Plan Baselines & AWR Diff]
```

---

## 4. Execution Steps & Commands

### Step 1: Pre-Upgrade Analysis (Analyze Mode)
Download latest `autoupgrade.jar` and execute non-destructive pre-upgrade analysis:
```bash
$ORACLE_HOME_19C/jdk/bin/java -jar autoupgrade.jar -config autoupgrade.cfg -mode analyze
```
*Review the generated HTML report in `./logs/cfgtoollogs/autoupgrade` for any `REQUIRED` or `MANUAL` action items.*

### Step 2: Automated Pre-Fixups (Fixups Mode)
Automatically resolve trivial pre-upgrade requirements (e.g. dictionary stats, obsolete parameter removal, empty recyclebin):
```bash
$ORACLE_HOME_19C/jdk/bin/java -jar autoupgrade.jar -config autoupgrade.cfg -mode fixups
```

### Step 3: Production Safety Gate & Guaranteed Restore Point (GRP)
AutoUpgrade automatically manages Flashback and Guaranteed Restore Points when configured:
```sql
-- Manual GRP verification (Optional fallback safety net):
SELECT flashback_on FROM v$database;
CREATE RESTORE POINT PRE_19C_UPGRADE GUARANTEE FLASHBACK DATABASE;
```

### Step 4: Upgrade Execution (Deploy Mode)
Execute the complete unattended upgrade:
```bash
$ORACLE_HOME_19C/jdk/bin/java -jar autoupgrade.jar -config autoupgrade.cfg -mode deploy
```

### Step 5: Post-Upgrade Verification & Timezone Upgrade
```sql
-- 1. Check Database Version and Components Status
SELECT comp_id, comp_name, version, status FROM dba_registry;

-- 2. Check Database Invalid Objects
SELECT owner, object_type, count(*) 
FROM dba_objects 
WHERE status = 'INVALID' 
GROUP BY owner, object_type;

-- 3. Upgrade Timezone File Version (DBMS_DST)
SELECT version FROM v$timezone_file;
-- AutoUpgrade handles DST automatically if specified in config.
```

### Step 6: Post-Upgrade Performance Safeguards
1. Gather Data Dictionary and Fixed Object Statistics:
```sql
EXEC DBMS_STATS.GATHER_DICTIONARY_STATS;
EXEC DBMS_STATS.GATHER_FIXED_OBJECTS_STATS;
```
2. Enable SQL Plan Management (SPM) Evolution to capture and prevent execution plan regressions.

---

## 5. Instant Rollback / Fallback Procedure
If catastrophic regressions occur during the maintenance window:
```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
FLASHBACK DATABASE TO RESTORE POINT PRE_19C_UPGRADE;
ALTER DATABASE OPEN RESETLOGS;
DROP RESTORE POINT PRE_19C_UPGRADE;
```
*(Reference Configuration: [templates/autoupgrade_config.cfg](file:///d:/Techwaves-egy/Oracle%20Skill/templates/autoupgrade_config.cfg))*
