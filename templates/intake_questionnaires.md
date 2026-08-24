# Pre-Flight Intake & Discovery Questionnaires

When interacting with the user, the Lead Oracle Architect uses these questionnaire formats to rapidly collect missing parameters.

---

### Universal Intake Prompt Template

```markdown
### 📋 Pre-Flight Discovery & Environmental Intake
Before dispatching specialized experts, please confirm the technical baseline for this issue:

1. **Target Environment**: `[PROD | UAT | TEST | DEV | DR]`
2. **Oracle EBS Version**: `[12.1.3 | 12.2.x (e.g. 12.2.10) | Standalone Database]`
3. **Database Version & Architecture**: `[11g | 12c | 19c | 23ai]` / `[Single-Instance | RAC (nodes?) | ASM | Data Guard]`
4. **Operating System**: `[Oracle Linux 7/8/9 | RHEL | AIX | Solaris]`
5. **Exact Error Code(s) & Symptoms**: `[e.g. ORA-xxxxx, FRM-xxxxx, HTTP 500/502, slow batch]`
6. **Scope & User Impact**: `[All users / Site Outage | Specific Module | Single User | Background Jobs]`
7. **Recent Changes & Timeline**: `[When did it start? Recent patches, deployments, AutoConfig, DB restarts?]`
```

---

### Domain-Specific Add-On Blocks

#### For Database Performance / Hang:
```markdown
- **Current OS Load & CPU**: `(Output of uptime / top / vmstat)`
- **Top Wait Events (if known)**: `(From v$system_event or OEM)`
- **Specific Query / SQL_ID**: `(If isolated to a particular process)`
- **AWR / ASH Snapshots Available?**: `(Yes/No + Snapshot IDs/Window)`
```

#### For EBS Login & Access Failures:
```markdown
- **Failure Point**: `(HTML Login Page / Responsibility Selection / Forms Launch)`
- **HTTP / Browser Error**: `(e.g., 500 Internal Server Error, 502 Bad Gateway, White Screen)`
- **Service Status**: `(Output of adstrtal.sh status / adoacorectl.sh status)`
```

#### For RMAN & Storage / FRA Issues:
```markdown
- **RMAN Error Output**: `(Full RMAN error stack)`
- **Backup Type**: `(Level 0 / Level 1 / Archive Log backup)`
- **Backup Target**: `(Fast Recovery Area / Local SAN / NFS / Tape)`
- **Filesystem Space**: `(Output of df -h)`
```
