# Playbook 13: Oracle Data Guard Switchover & Failover Runbook

## 1. Scope
Planned role transition (Switchover - Zero Data Loss) and Unplanned Disaster Recovery role transition (Failover) for Oracle Physical Standby / Active Data Guard environments.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Data Guard / DR Expert**
* **Oracle Database DBA**
* **Network Engineer**
* **EBS System Administrator**
* **Business Continuity Architect**

---

## 3. Switchover Lifecycle (Planned Maintenance / Zero Data Loss)

```
[Primary Database (PROD) & Physical Standby (DR) in SYNC]
                           │
                           ▼
          [Pre-Switchover Validation via DGMGRL]
                           │
                           ▼
          [Perform Switchover via Broker CLI]
          (dgmgrl: SWITCHOVER TO 'DR_STANDBY')
                           │
                           ▼
   [Standby becomes Primary; Former Primary becomes Standby]
                           │
                           ▼
          [Point Application / TNS Services to New Primary]
```

### Execution Steps (DGMGRL Broker Method - Preferred)

```bash
# 1. Connect to Data Guard Broker on Primary
dgmgrl sys/<sys_password>@PRODDB

# 2. Check overall configuration health
DGMGRL> SHOW CONFIGURATION;
DGMGRL> VALIDATE DATABASE 'PRODDB';
DGMGRL> VALIDATE DATABASE 'DR_STANDBY';

# 3. Execute zero-data-loss switchover
DGMGRL> SWITCHOVER TO 'DR_STANDBY';

# 4. Verify post-switchover status
DGMGRL> SHOW CONFIGURATION;
```

### Manual SQL*Plus Switchover (Fallback if Broker is not configured)

```sql
-- 1. On Primary: Verify switchover readiness
SELECT switchover_status FROM v$database;
-- Must return: 'TO STANDBY' or 'SESSIONS ACTIVE'

-- 2. On Primary: Convert to Standby
ALTER DATABASE COMMIT TO SWITCHOVER TO PHYSICAL STANDBY WITH SESSION SHUTDOWN;
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;

-- 3. On Standby: Verify readiness
SELECT switchover_status FROM v$database;
-- Must return: 'TO PRIMARY' or 'SESSIONS ACTIVE'

-- 4. On Standby: Convert to Primary
ALTER DATABASE COMMIT TO SWITCHOVER TO PRIMARY WITH SESSION SHUTDOWN;
ALTER DATABASE OPEN;

-- 5. On New Standby (Former Primary): Start Redo Apply (MRP)
ALTER DATABASE RECOVER MANAGED STANDBY DATABASE USING CURRENT LOGFILE DISCONNECT FROM SESSION;
```

---

## 4. Failover Lifecycle (Disaster Recovery Outage)

```bash
# Connect to Standby via DGMGRL
dgmgrl sys/<sys_password>@DR_STANDBY

# Execute failover (Immediate or Complete)
DGMGRL> FAILOVER TO 'DR_STANDBY';

# If Flashback Database was enabled on former primary, reinstate later:
# DGMGRL> REINSTATE DATABASE 'PRODDB';
```
