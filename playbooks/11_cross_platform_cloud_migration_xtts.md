# Playbook 11: Cross-Platform & Cloud Migration via RMAN XTTS v4

## 1. Scope
Migrating multi-terabyte Oracle Databases and EBS instances across different operating systems (e.g. AIX/Solaris Big Endian to Linux x86-64 Little Endian) or from On-Premises to Oracle Cloud Infrastructure (OCI / Exadata Cloud Service) with **near-zero business downtime** using **RMAN Cross-Platform Transportable Tablespaces with Incremental Backups (XTTS v4)**.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **RMAN Backup & Recovery Expert**
* **Storage Expert**
* **Oracle Linux Expert**
* **Network Engineer**
* **Business Continuity & Change Management Experts**

---

## 3. XTTS v4 Migration Workflow

```
[Online Phase: Initial Level 0 Backup & Cross-Platform Transfer]
                              │
                              ▼
[Online Phase: Periodic Level 1 Incremental Roll-Forwards (Catch-up)]
                              │
                              ▼
[Cutover Window: Tablespaces READ ONLY + Final Level 1 Sync]
                              │
                              ▼
[Target Side: Convert Datafiles to Target Endianness]
                              │
                              ▼
[Data Pump Metadata Import (impdp transport_datafiles)]
                              │
                              ▼
[Validation & Open Database for Production Traffic]
```

---

## 4. Execution Steps & Commands

### Step 1: Prepare Source & Target Configuration
Configure `xtt.properties` on source and target systems:
```properties
tablespaces=APPS_TS_TX_DATA,APPS_TS_TX_IDX,XXCUST_DATA
platformid=6   # AIX (Source Endian: Big) -> Target Linux (Little)
srcdir=/u01/oradata/src
destdir=/u02/oradata/tgt
parallel=8
rollforwardprefix=xtt_rf_
```

### Step 2: Initial Full Level 0 Backup (Online - No Outage)
```bash
# On Source:
$ORACLE_HOME/perl/bin/perl xttdriver.pl --backup --level=0

# Transfer generated backup pieces to target staging storage via rsync / SCP:
rsync -avP /stage/xtts_backup/* target_host:/stage/xtts_backup/
```

### Step 3: Incremental Catch-up Backups (Repeatable Online)
Run periodic Level 1 incremental backups while production remains active to minimize final cutover duration:
```bash
# On Source (Daily / Hourly):
$ORACLE_HOME/perl/bin/perl xttdriver.pl --backup --level=1

# Transfer incremental files to Target:
rsync -avP /stage/xtts_backup/incr* target_host:/stage/xtts_backup/

# On Target: Roll forward the restored datafiles
$ORACLE_HOME/perl/bin/perl xttdriver.pl --restore
```

### Step 4: Cutover Window Execution (Downtime Window)
1. Set source tablespaces to `READ ONLY`:
```sql
ALTER TABLESPACE APPS_TS_TX_DATA READ ONLY;
ALTER TABLESPACE APPS_TS_TX_IDX READ ONLY;
ALTER TABLESPACE XXCUST_DATA READ ONLY;
```
2. Take final Level 1 incremental backup on source:
```bash
$ORACLE_HOME/perl/bin/perl xttdriver.pl --backup --level=1
```
3. Transfer final incremental and apply on target:
```bash
$ORACLE_HOME/perl/bin/perl xttdriver.pl --restore
```
4. Export metadata from source using Data Pump:
```bash
expdp system/password@source_db TRANSPORT_TABLESPACES=APPS_TS_TX_DATA,APPS_TS_TX_IDX,XXCUST_DATA DUMPFILE=xtts_meta.dmp DIRECTORY=DATA_PUMP_DIR
```
5. Import metadata into target database:
```bash
impdp system/password@target_db DUMPFILE=xtts_meta.dmp DIRECTORY=DATA_PUMP_DIR TRANSPORT_DATAFILES='/u02/oradata/tgt/apps_tx_data01.dbf','/u02/oradata/tgt/apps_tx_idx01.dbf'
```
6. Set tablespaces to `READ WRITE` on target:
```sql
ALTER TABLESPACE APPS_TS_TX_DATA READ WRITE;
ALTER TABLESPACE APPS_TS_TX_IDX READ WRITE;
ALTER TABLESPACE XXCUST_DATA READ WRITE;
```
