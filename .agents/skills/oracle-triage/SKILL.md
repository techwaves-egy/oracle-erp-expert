---
name: oracle-triage
description: >-
  Rapid incident triage for Oracle Database hangs, blocking locks, 100% CPU, and EBS login/access failures.
---

# Oracle Incident Triage (/oracle-triage)

When `/oracle-triage` is invoked:
1. Identify the failing layer immediately (Client, Web, WLS, EBS, DB, RAC, Storage, OS).
2. For Database Hangs / Locks:
   - Run hierarchical blocking session tree query: [scripts/sql/session_diagnostics.sql](file:///d:/Techwaves-egy/Oracle%20Skill/scripts/sql/session_diagnostics.sql).
   - Identify root blocker `SID`, `SERIAL#`, `SQL_ID`, and offending query.
   - Provide controlled termination command (`ALTER SYSTEM KILL SESSION`) with rollback guarantee.
3. For EBS Login / Access Failures:
   - Check OHS and WLS `oacore` service health: [playbooks/02_ebs_login_failures.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/02_ebs_login_failures.md).
   - Check APPS / FND_USER account lockouts.
4. Update `docs/SESSION_STATE.md` and append actions to `docs/WORK_LOG.md`.
