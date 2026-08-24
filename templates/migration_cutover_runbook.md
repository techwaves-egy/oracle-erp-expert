# Production Migration & Upgrade Cutover Runbook

**System Name**: `[Source System] -> [Target System / Cloud OCI]`  
**Target Window**: `[Start Time: YYYY-MM-DD HH24:MI] to [End Time: YYYY-MM-DD HH24:MI]`  
**Total Allocated Window**: `[XX Hours]`  
**Lead Oracle Architect / Cutover Commander**: `[Name / Lead]`  
**Go / No-Go Decision Gate**: `[T + XX Hours]`  

---

## 1. Cutover Milestone Schedule

| Phase | Milestone Description | Target Duration | Planned Start (T+) | Planned End (T+) | Owner | Status |
|---|---|---|---|---|---|---|
| **Phase 0** | Pre-Cutover Health Check & Final Level 1 Sync | 60 mins | `T-01:00` | `T-00:00` | DBA / RMAN | **Pending** |
| **Phase 1** | Application Blackout & Service Shutdown | 30 mins | `T+00:00` | `T+00:30` | EBS Admin | **Pending** |
| **Phase 2** | Final Database Sync & Guaranteed Restore Point | 45 mins | `T+00:30` | `T+01:15` | DBA Expert | **Pending** |
| **Phase 3** | Database Upgrade (19c) / XTTS TTS Import | 120 mins | `T+01:15` | `T+03:15` | DBA / Patching | **Pending** |
| **Phase 4** | EBS Interoperability & AutoConfig Execution | 90 mins | `T+03:15` | `T+04:45` | AutoConfig / EBS | **Pending** |
| **Phase 5** | Database & Application Service Startup | 30 mins | `T+04:45` | `T+05:15` | EBS Admin | **Pending** |
| **Phase 6** | Technical Smoke Testing & Critical Batch Check | 60 mins | `T+05:15` | `T+06:15` | QA / Functional | **Pending** |
| **Phase 7** | **Go / No-Go Decision Gate** | 15 mins | `T+06:15` | `T+06:30` | Stakeholders / Lead | **Pending** |
| **Phase 8** | Release System to Business Users | 15 mins | `T+06:30` | `T+06:45` | Change Manager | **Pending** |

---

## 2. Abort & Rollback Criteria
If any of the following occur prior to the Go / No-Go gate, the Lead Architect initiates immediate rollback:
1. Critical database upgrade failure unresolved after 60 minutes.
2. Incompatible CEMLI corruption preventing core financial transaction processing.
3. Network throughput degradation between app and database exceeding 50ms latency.

### Rollback Procedure
1. Flashback target database to `PRE_UPGRADE_RESTORE_POINT` or point DNS back to Source environment.
2. Restart source database and application tier services: `$ADMIN_SCRIPTS_HOME/adstrtal.sh`.
3. Notify enterprise stakeholders of rollback and resumption of normal operations.
