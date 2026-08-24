# Playbook 12: Non-CDB to 19c / 23ai PDB Multitenant Conversion

## 1. Scope
Converting standalone, legacy Non-CDB Oracle Databases into Pluggable Databases (PDBs) hosted within an Oracle 19c or 23ai Multitenant Container Database (CDB).

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle Database DBA**
* **Oracle EBS Architect**
* **RMAN Backup & Recovery Expert**
* **Storage Expert**
* **Change Management Expert**

---

## 3. Non-CDB to PDB Conversion Architecture

```
[Legacy Non-CDB Database (Source)]
                 │
                 ▼  (Step 1: Open READ ONLY & Generate XML Manifest)
[DBMS_PDB.DESCRIBE('/stage/pdb_desc.xml')]
                 │
                 ▼  (Step 2: Connect to Target 19c CDB)
[CREATE PLUGGABLE DATABASE ebs_pdb USING '/stage/pdb_desc.xml' NOCOPY]
                 │
                 ▼  (Step 3: Run noncdb_to_pdb.sql Cleanup Script)
[@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql]
                 │
                 ▼  (Step 4: Open PDB READ WRITE & Save State)
[ALTER PLUGGABLE DATABASE ebs_pdb OPEN READ WRITE;]
[ALTER PLUGGABLE DATABASE ebs_pdb SAVE STATE;]
```

---

## 4. Execution Steps & Commands

### Step 1: Prepare Source Database
1. Ensure the source database is cleanly shut down and started in `READ ONLY` mode:
```sql
SHUTDOWN IMMEDIATE;
STARTUP MOUNT;
ALTER DATABASE OPEN READ ONLY;
```
2. Generate the PDB metadata XML manifest using `DBMS_PDB`:
```sql
BEGIN
    DBMS_PDB.DESCRIBE(
        pdb_descr_file => '/stage/noncdb_source.xml'
    );
END;
/
```
3. Shut down the source database:
```sql
SHUTDOWN IMMEDIATE;
```

### Step 2: Plug into Target Container Database (CDB)
Connect to the 19c CDB (`sys as sysdba`) and validate compatibility:
```sql
-- 1. Check compatibility
SET SERVEROUTPUT ON;
DECLARE
    l_compatible BOOLEAN;
BEGIN
    l_compatible := DBMS_PDB.CHECK_PLUG_COMPATIBILITY(
        pdb_descr_file => '/stage/noncdb_source.xml',
        pdb_name       => 'EBS_PDB'
    );
    IF l_compatible THEN
        DBMS_OUTPUT.PUT_LINE('Database is fully compatible for plugging into CDB.');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Check PDB_PLUG_IN_VIOLATIONS for non-compatible items.');
    END IF;
END;
/

-- Check violations if any:
SELECT type, message, action FROM pdb_plug_in_violations WHERE name = 'EBS_PDB';

-- 2. Create Pluggable Database (using existing datafiles via NOCOPY or COPY):
CREATE PLUGGABLE DATABASE ebs_pdb 
USING '/stage/noncdb_source.xml' 
NOCOPY 
TEMPFILE REUSE;
```

### Step 3: Run Post-Plug Conversion Script
```sql
-- Switch to the new PDB container
ALTER SESSION SET CONTAINER = ebs_pdb;

-- Execute the mandatory noncdb cleanup script to convert dictionary objects
@$ORACLE_HOME/rdbms/admin/noncdb_to_pdb.sql

-- Compile any invalid objects
@$ORACLE_HOME/rdbms/admin/utlrp.sql
```

### Step 4: Open PDB and Persist Startup State
```sql
-- Open the new PDB
ALTER PLUGGABLE DATABASE ebs_pdb OPEN READ WRITE;

-- Ensure PDB automatically opens when CDB starts
ALTER PLUGGABLE DATABASE ebs_pdb SAVE STATE;

-- Verify PDB open mode and service
SELECT name, open_mode, restricted FROM v$pdbs;
```
