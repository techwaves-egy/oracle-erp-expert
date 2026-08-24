# Oracle Center of Excellence — Workspace Context & Domain Model

## 1. Directory Structure

```
Oracle Skill/
├── AGENTS.md                  # Master CoE charter, 27-expert roster, rules & protocols
├── GEMINI.md                  # Workspace guidelines & playbook dispatch map
├── .agents/
│   └── skills/
│       └── oracle-erp-database-expert/
│           └── SKILL.md       # Multi-agent skill definition, teams & query toolkit
├── docs/                      # Architectural specifications & institutional memory
│   ├── SESSION_STATE.md       # Live state, verified context & "What's Next" backlog
│   ├── WORK_LOG.md            # Append-only chronological audit log of all actions
│   ├── ARCHITECTURE.md        # 9-layer enterprise technology stack diagram
│   ├── EXPERT_ROSTER.md       # Detailed breakdown of all 27 specialized roles
│   ├── CONTEXT.md             # This domain model & conventions reference
│   ├── RUNBOOK_INDEX.md       # Master index of all 21 operational playbooks
│   └── KNOWN_ISSUES.md        # Catalog of known Oracle EBS/DB bugs & Doc IDs
├── playbooks/                 # Step-by-step diagnostic & remediation procedures (00-21)
├── templates/                 # Reusable production forms, XML templates & SQL scripts
└── scripts/                   # Automated non-destructive scripts (SQL & Shell)
    ├── sql/                   # Diagnostic query packs
    └── shell/                 # Lifecycle and health audit shell routines
```

---

## 2. Naming Conventions & Enterprise Standards

### Custom Development (CEMLI / EBR Standards)
* **Custom Schema**: `XXCUST` (or client-specific 2-letter prefix e.g. `XX_FIN`).
* **Custom Tables**: Created in custom schema, granted to `APPS`.
* **Editioning Views (EV)**: Created in `APPS` as `TABLE_NAME#`.
* **Synonyms**: `APPS` synonym pointing to Editioning View `TABLE_NAME#`.
* **Custom Packages**: `XX_<MODULE>_<NAME>_PKG` (e.g. `XX_AR_INVOICE_PKG`).

### Oracle EBS File Editions (R12.2)
* `fs1`: Production Run or Patch File System.
* `fs2`: Alternating Run or Patch File System.
* `fs_ne`: Non-Editioned File System (Log files, concurrent output, staging).

### Database SIDs & Services
* **Production Database**: `PRODDB` (or RAC instances `PRODDB1`, `PRODDB2`).
* **Disaster Recovery Standby**: `DR_STANDBY`.
* **EBS Service Name**: `ebs_online_srv`.
