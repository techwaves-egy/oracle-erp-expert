# Playbook 10: EBS R12.1.3 to R12.2 Upgrade & CEMLI Remediation

## 1. Scope
Comprehensive technical upgrade path from Oracle E-Business Suite R12.1.3 (or 11i) to R12.2 (12.2.11 / 12.2.12 / 12.2.13), including Dual File System configuration, Database Edition-Based Redefinition (EBR) enablement (`AD_ZD`), and custom CEMLI remediation.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Oracle EBS Architect**
* **ADOP / Patching Expert**
* **SQL / PL/SQL Expert**
* **Oracle Database DBA**
* **WebLogic Expert**
* **EBS System Administrator**
* **Change Management & Business Continuity Experts**

---

## 3. EBS 12.2 Upgrade Lifecycle

```
[Pre-Upgrade Assessment & CEMLI Audit]
                 │
                 ▼
[Database 19c Upgrade & Interoperability Patches]
                 │
                 ▼
[EBS 12.2 Rapid Install: Lay Down Dual File System (fs1/fs2)]
                 │
                 ▼
[Apply EBS 12.2 Upgrade Driver (u10124646.drv)]
                 │
                 ▼
[Enable Edition-Based Redefinition (AD_ZD.UPGRADE)]
                 │
                 ▼
[Apply Latest Release Update Pack (RUP - e.g. 12.2.12)]
                 │
                 ▼
[Remediate & Validate Custom CEMLI Objects]
```

---

## 4. CEMLI & Edition-Based Redefinition (EBR) Compliance Standards

In EBS 12.2, all custom database objects (Custom Extensions, Modifications, Localizations, Interfaces) must comply with **Edition-Based Redefinition (EBR)**:

### Rule 1: Custom Table & Synonym Standards
* Custom tables must reside in custom schemas (e.g. `XXCUST`) and grant full DML privileges to `APPS`.
* In the `APPS` schema, every custom table must have an **Editioning View (EV)** named `XXCUST_TABLE_NAME#` and a public/APPS synonym pointing to the Editioning View:
```sql
-- Upgrade standard table to Edition-Based Redefinition
EXEC AD_ZD_TABLE.UPGRADE('XXCUST', 'XX_INVOICE_HEADERS');
```

### Rule 2: Package & Code Standards
* All custom packages, views, triggers, and functions must be compiled in the current database edition using `AD_ZD`:
```sql
-- Compile Editioned Custom Object
EXEC AD_ZD.COMPILE;
```
* Triggers must be **Forward Cross-Edition Triggers (FCET)** or standard DML triggers on Editioning Views (`#`), never directly on physical base tables.

---

## 5. Key Verification Queries

```sql
-- 1. Check Database Editioning Status
SELECT edition_name, parent_edition_name, usable FROM dba_editions;

-- 2. Verify AD_ZD Object Status & EV Health
SELECT 
    owner, 
    table_name, 
    ev_name, 
    status 
FROM ad_zd_tables 
WHERE status != 'VALID';

-- 3. Check for Non-Compliant Direct Base Table Triggers
SELECT 
    owner, 
    trigger_name, 
    table_name, 
    status 
FROM dba_triggers 
WHERE table_owner = 'APPS' 
  AND table_name NOT LIKE '%#' 
  AND trigger_type NOT LIKE '%CROSS%';
```
