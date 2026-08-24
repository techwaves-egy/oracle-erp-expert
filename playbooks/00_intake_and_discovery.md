# Playbook 00: Mandatory Pre-Flight Intake & Discovery Protocol

## 1. Purpose
Ensures that no expert assumptions or destructive actions occur without essential environmental parameters, error telemetry, and impact scope.

## 2. Lead Architect Pre-Flight Intake Matrix

When a user initiates an inquiry, the Lead Architect prompts the user using the tailored section below:

---

### A. Universal Baseline Intake (Required for All Requests)
```text
[PRE-FLIGHT INTAKE FORM]
1. Target Environment: [PROD / UAT / TEST / DEV / DR]
2. EBS Version: [12.1.3 / 12.2.4 / 12.2.9 / 12.2.11 / 12.2.12 / Standalone DB]
3. Database Version: [11.2.0.4 / 12.1.0.2 / 12.2.0.1 / 19c (19.x) / 23ai]
4. Architecture: [Single Instance / RAC (Number of Nodes?) / ASM / Data Guard Standby]
5. Operating System: [Oracle Linux 7/8/9 / RHEL / AIX / Solaris]
6. Severity / Urgency: [Sev-1 Critical Outage / Major Degradation / Minor / Scheduled Work]
```

---

### B. Scenario-Specific Diagnostic Add-Ons

#### 1. Performance Degradation & Hangs
```text
- Are all sessions hanging or specific queries/modules?
- Host CPU & Load Average (`uptime`, `top`):
- Top system wait events if known (`v$system_event`, `v$session_wait`):
- AWR / ASH snapshot period available for comparison:
```

#### 2. EBS Access / Login Failures
```text
- Exact error message / HTTP status: [404 / 500 / 502 / 503 / ORA-28000 / FRM-92101]
- Is failure occurring on the HTML Web page (`/OA_HTML/AppsLogin`) or Forms runtime applet?
- Are internal LAN and external WAN users equally impacted?
- Status of OHS and WebLogic Managed Servers (`adoacorectl.sh status`):
```

#### 3. Concurrent Processing / Month-End Batch Delays
```text
- Name(s) of delayed concurrent programs and Request IDs:
- Status / Phase of stuck requests: [Pending/Normal, Pending/Standby, Running/Normal]
- Are Conflict Resolution Manager (CRM) or Standard Managers backlogged?
```

#### 4. RMAN / Backup / DR Failures
```text
- Exact RMAN error stack: [e.g. ORA-19809, ORA-19502, RMAN-06059]
- Backup destination type: [Local Disk / Fast Recovery Area / NFS / Tape (MML)]
- Fast Recovery Area (FRA) size and percent used:
```

#### 5. ADOP Online Patching Issues
```text
- Failed ADOP phase: [prepare / apply / finalize / cutover / cleanup / fs_clone]
- Patch number(s) being applied:
- Available disk space on fs1, fs2, and fs_ne (`df -h`):
- Relevant snippet from `$LOG_HOME/appl/ad/admin/log/adop_<session_id>.log`:
```

---

## 3. Fast-Path for Pre-Populated Queries
If the user already provides complete telemetry (e.g. error logs, versions, environment tag), the Lead Architect validates the information and immediately dispatches the appropriate specialized experts without stalling.
