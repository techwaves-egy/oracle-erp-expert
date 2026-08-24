# Production Change Advisory Board (CAB) Request Form

**Change Reference**: `CR-<YYYYMMDD>-<SERVICE_ID>`  
**Date of Submission**: `[Date]`  
**Lead Oracle Architect / Requestor**: `[Name / CoE Lead]`  
**Target Environment**: `[PROD | DR]`  
**Target System / Host / SID**: `[e.g. ebsdb01 / PRODDB / EBS R12.2]`  

---

## 1. Change Classification & Risk Assessment

* **Change Type**: `[Standard / Pre-Approved | Normal (Scheduled CAB) | Emergency (Outage Fix)]`
* **Risk Rating**: `[Low | Medium | High | Critical]`
* **Business Impact**: `[No Outage / Online | Brief Cutover (15 mins) | Scheduled Outage Window (2 hours)]`
* **Scheduled Maintenance Window**: `[Start: YYYY-MM-DD HH24:MI UTC] to [End: YYYY-MM-DD HH24:MI UTC]`

---

## 2. Technical Scope & Justification
* **Description of Change**: Concise explanation of what is being modified (e.g. Applying EBS RUP patch 33527700, adding datafile to tablespace APPS_TS_TX_DATA, adjusting SGA size).
* **Business Justification**: Why is this change necessary? (e.g. Resolving ORA-01653 table extension failure, compliance mandate, quarterly security patch).

---

## 3. Pre-Requisites & Production Safety Gate Checklist
- [x] Hostname and Database SID verified: `<HOSTNAME> / <SID>`
- [x] Full RMAN backup verified within 24h: `Completed SCN <SCN_NUMBER>`
- [x] Data Guard standby sync verified (Transport & Apply lag < 5 mins)
- [x] Flashback Database Guaranteed Restore Point created: `GRP_CR_<NUMBER>`
- [x] Tested in lower environment (`UAT`/`TEST`): Verified without errors on `[Date]`

---

## 4. Step-by-Step Implementation Procedure

```bash
# Phase 1: Pre-Change Verification
# Phase 2: Execute State-Altering Change
# Phase 3: Post-Change Verification
```

---

## 5. Post-Implementation Verification Query / Command
```sql
-- Query to confirm successful application
```

---

## 6. Rollback / Backout Plan
If any validation fails or unexpected errors occur before cutover completion:
```bash
# Exact step-by-step backout commands
```
* **Estimated Rollback Duration**: `[XX Minutes]`

---

## 7. Sign-off & Approvals
- **Lead Oracle Architect**: `[Approved]`
- **Head of Infrastructure / DBA Lead**: `[Approved]`
- **Business Process Owner**: `[Approved]`
