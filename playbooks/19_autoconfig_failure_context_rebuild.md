# Playbook 19: EBS AutoConfig Failure & Context XML Rebuild

## 1. Scope
Triage and recovery when AutoConfig (`adautocfg.sh` / `adconfig.pl`) fails, causes service misconfigurations, encounters port conflicts, or requires Context XML template rebuilds.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **AutoConfig Expert**
* **EBS System Administrator**
* **Oracle EBS Architect**
* **Oracle Database DBA**

---

## 3. AutoConfig Lifecycle & Safety Protocol

```
[Pre-Check: Backup Current Context XML & Run adchkcfg.sh]
                           │
                           ▼
             [Execute adautocfg.sh on Run FS]
                           │
                           ▼
          [Check adconfig.log for Template Errors]
                           │
                           ▼
 [If 12.2: Synchronize to Patch FS via adop phase=fs_clone]
```

---

## 4. Diagnostic & Recovery Commands

### Step 1: Pre-Execution Non-Destructive Impact Check
```bash
# Run AutoConfig in check-only / diff mode (Does not modify active configuration):
$AD_TOP/bin/adchkcfg.sh contextfile=$CONTEXT_FILE

# Review generated diff HTML report in current directory
```

### Step 2: Running AutoConfig with Full Logging
```bash
# Application Tier:
$ADMIN_SCRIPTS_HOME/adautocfg.sh

# Database Tier:
cd $ORACLE_HOME/appsutil/scripts/<CONTEXT_NAME>
./adautocfg.sh
```

### Step 3: Inspect AutoConfig Log Files
```bash
# Application tier log:
tail -100f $INST_TOP/admin/log/<MMDDHHMI>/adconfig.log

# Common Errors:
# - AC-50480: Port conflict
# - AC-00005: File not found or permission denied
# - Template instantiation failure in $FND_TOP/admin/template
```

---

## 5. Context XML File Rebuild Protocol (If XML is Corrupted)

If the Context XML file is corrupted or desynchronized:
```bash
# 1. On Database Tier: Rebuild context from DB parameters
cd $ORACLE_HOME/appsutil/bin
perl adbldxml.pl

# 2. On Application Tier: Rebuild context from templates
cd $AD_TOP/bin
perl adclonectx.pl contextfile=$CONTEXT_FILE
```
