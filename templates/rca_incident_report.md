# Formal Root Cause Analysis (RCA) & Incident Post-Mortem Report

**Document Reference**: `RCA-<YYYYMMDD>-<INCIDENT_ID>`  
**Date of Report**: `[Date]`  
**Lead Oracle Architect / Incident Manager**: `[Name / CoE Lead]`  
**Target System**: `[EBS PROD / DB SID / Hostname]`  
**Incident Severity**: `[Sev-1 (Critical Outage) | Sev-2 (Major Degradation)]`  

---

## 1. Executive Summary & Impact
* **Incident Description**: Concise summary of what occurred and what business functionality was degraded or unavailable.
* **Incident Start Time**: `[YYYY-MM-DD HH24:MI UTC]`
* **Incident Resolution Time**: `[YYYY-MM-DD HH24:MI UTC]`
* **Total Business Downtime / Duration**: `[XX hours / YY minutes]`
* **Affected Business Units / Users**: `[e.g. All AR billing users, 450 active sessions, external web orders stalled]`

---

## 2. Chronological Timeline of Events

| Timestamp (UTC) | Event / Symptom | Action Taken | Performed By |
|---|---|---|---|
| `14:02` | Alert triggered: OEM Host CPU 100% | Linux & DBA experts assigned | Monitoring Engineer |
| `14:15` | Identified blocking session tree rooted at SID 412 | SQL & Performance analysis | Performance Engineer |
| `14:28` | Terminated blocking session SID 412 cleanly | Controlled session kill | DBA Expert |
| `14:32` | Application services stabilized; CPU dropped to 18% | Service validation | Lead Architect |

---

## 3. Confirmed Technical Root Cause
* **Root Cause Layer**: `[Oracle Database / SQL Optimizer / Storage / WebLogic / Network / OS]`
* **Technical Mechanism**: Direct factual explanation with evidence (e.g. Unindexed foreign key constraint on table `XX_PO_HEADERS_ALL` caused full table lock `enq: TM - contention` during batch transaction updates).

---

## 4. Supporting Technical Evidence
```sql
-- Excerpt of blocking lock tree or offending SQL execution plan
```

---

## 5. 5-Whys Root Cause Drilldown
1. **Why did the ERP hang?** High session queue and blocking lock contention across 120 sessions.
2. **Why was there lock contention?** Session 412 acquired an exclusive TM table lock on `XX_PO_HEADERS_ALL`.
3. **Why was an exclusive TM lock acquired?** A `DELETE` operation executed on parent table `XX_VENDORS` with an unindexed foreign key on the child table.
4. **Why was the foreign key unindexed?** A recent custom migration omitted the B-tree index on `XX_PO_HEADERS_ALL.VENDOR_ID`.
5. **Why was it omitted in migration?** The pre-deployment validation checklist did not enforce index checks on new foreign keys.

---

## 6. Corrective & Preventive Action Items (CAPA)

| ID | Action Item | Owner | Target Date | Status |
|---|---|---|---|---|
| **CAPA-01** | Create missing B-tree index on `XX_PO_HEADERS_ALL(VENDOR_ID)` | SQL Expert / DBA | `2026-08-25` | **Completed** |
| **CAPA-02** | Add automated CI/CD schema validation rule for unindexed foreign keys | Automation Expert | `2026-09-01` | **In Progress** |
| **CAPA-03** | Configure OEM alert for blocking locks exceeding 120 seconds | Monitoring Engineer | `2026-08-28` | **Open** |

---

## 7. Sign-off & Approvals
- **Lead Oracle Architect**: `[Signature / Approved]`
- **Head of Enterprise Applications**: `[Signature / Approved]`
