# Playbook 21: Inter-Agent Handover & Persistent State Tracking

## 1. Scope
Defines the mandatory protocol for maintaining session continuity, recording actions taken, capturing verified telemetry, and maintaining a prioritized "What's Next" action backlog across multi-agent turns and handovers.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Incident Response / RCA Expert**
* **Change Management Expert**
* All Activated Domain Specialists

---

## 3. The 3-Step Handover Lifecycle

```
[Step 1: Ingest Prior State]
Read docs/SESSION_STATE.md & docs/WORK_LOG.md
                │
                ▼
[Step 2: Execute New Diagnostics or Remediation]
Execute verified tasks without duplicating prior work
                │
                ▼
[Step 3: Update Persistent State & What's Next]
Append action to docs/WORK_LOG.md
Update active status & next steps in docs/SESSION_STATE.md
```

---

## 4. Mandatory State Updates per Operational Phase

### A. When Starting a New Turn or Task:
1. Check `docs/SESSION_STATE.md` to see:
   - Environment parameters already verified (avoids asking the user repeatedly).
   - What diagnostic queries have already run.
   - Current database / application state.
   - The prioritized **What's Next** backlog.

### B. While Performing Work:
1. Every significant command, SQL execution, or diagnostic finding must be appended to `docs/WORK_LOG.md` using the format:
```markdown
### [YYYY-MM-DD HH24:MI:SS UTC] — <Action Title>
* **Actor**: `<Expert Role>`
* **Phase**: `<Investigation | Remediation | Verification>`
* **Actions Taken**:
  1. Executed query/script `<script_name>`.
  2. Findings: `<Concrete telemetry>`.
* **Outcome**: `<Confirmed / Ruled Out / In Progress>`
* **Next Steps**: `<Immediate follow-up task>`
```

### C. Before Ending a Turn:
1. Update `docs/SESSION_STATE.md`:
   - Refresh the **Active Environmental Context** table with newly confirmed parameters.
   - Update **Verified Facts & Empirical Telemetry**.
   - Update the **What's Next & Immediate Action Backlog** table with assigned experts, targets, and priority (`P1`, `P2`, `P3`).
   - Confirm the current **Rollback / Safety State**.
