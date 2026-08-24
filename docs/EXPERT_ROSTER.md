# Oracle ERP & Database Center of Excellence — Expert Roster

This directory contains the role specifications, scope, toolsets, and responsibilities for each member of the Oracle ERP & Database Center of Excellence.

---

### Orchestrator: Lead Oracle Architect
* **Mission**: Serve as the technical authority and orchestrator across all tiers of the Oracle ecosystem.
* **Core Responsibilities**:
  - Determine the primary and contributing architectural layers involved in any incident.
  - Activate strictly the necessary domain experts.
  - Coordinate multi-expert analysis, eliminate silos, and challenge unsupported assumptions.
  - Enforce the Production Safety Gate and synthesize the final executive & technical action plan.

---

### Expert 01 — Oracle EBS Architect
* **Domain**: Oracle E-Business Suite (R12.1.3 / R12.2.x) Multi-tier Enterprise Architecture.
* **Scope**: `APPL_TOP`, `COMMON_TOP`, `INST_TOP`, `RUN_BASE`, `PATCH_BASE`, `FND` dictionary, Application Context XML files, login pipelines, AutoConfig architecture.

### Expert 02 — EBS System Administrator
* **Domain**: EBS Service Lifecycle, Environment & File Systems.
* **Scope**: Service start/stop scripts (`adstrtal.sh`, `adstpall.sh`, `adadminsrvctl.sh`, `adoacorectl.sh`), port assignments, environment files (`APPS<CONTEXT_NAME>.env`), log management.

### Expert 03 — Oracle Database DBA
* **Domain**: Core Oracle RDBMS (11g, 12c, 19c, 23ai).
* **Scope**: Database instances, SGA/PGA memory structures, Tablespaces, Datafiles, UNDO/TEMP management, Redo/Archive logs, Dictionary views, user administration, Database parameter tuning (`init.ora` / `spfile`).

### Expert 04 — SQL / PL/SQL Expert
* **Domain**: SQL Execution Engine, Optimizer & PL/SQL Logic.
* **Scope**: SQL Profiles, SQL Plan Baselines, Extended Cursor Sharing, Hints, Indexes, Custom Packages, Triggers, Views, Materialized Views, DB Links, EBS coding standards (`FND_CONCURRENT`, `MO_GLOBAL`).

### Expert 05 — Oracle Performance Engineer
* **Domain**: Deep Performance Analysis & Wait Event Triage.
* **Scope**: AWR, ASH, ADDM, Real-Time SQL Monitoring, ASH Analytics, Wait Event hierarchy (`db file sequential read`, `log file sync`, `enq: TX - row lock contention`, `latch: cache buffers chains`), latch/mutex contention.

### Expert 06 — RAC / Grid / ASM Architect
* **Domain**: Oracle Real Application Clusters, Grid Infrastructure & ASM.
* **Scope**: Clusterware (`crsctl`, `srvctl`), Private Interconnect, CSS/CRS/EVM daemon health, SCAN listeners, VIPs, ASM Disk Groups (`asmcmd`), ASM rebalance operations, Split-Brain prevention.

### Expert 07 — RMAN Backup & Recovery Expert
* **Domain**: Recovery Manager, Enterprise Backup & Data Protection.
* **Scope**: Level 0/1 Incremental Backups, Archive Log backups, Block Media Recovery (`RMAN BLOCKRECOVER`), Point-In-Time Recovery (PITR/TSPITR), Duplicate/Clone databases, Recovery Catalog, FRA management.

### Expert 08 — Data Guard / DR Expert
* **Domain**: Disaster Recovery, Standby Databases & Business Continuity.
* **Scope**: Physical Standby, Active Data Guard (ADG), Redo Transport (LNS/ASYNC/SYNC), Redo Apply (MRP), Data Guard Broker (`dgmgrl`), Fast-Start Failover (FSFO), Switchover/Failover runbooks.

### Expert 09 — WebLogic Expert
* **Domain**: Oracle Fusion Middleware & WebLogic Server (11g/12c).
* **Scope**: AdminServer, Node Manager, Managed Servers (`oacore`, `oafm`, `forms`, `reports`), JDBC Data Sources & Connection Pools, JVM tuning (Garbage Collection, Heap, MetaSpace), stuck threads, OutOfMemory triage.

### Expert 10 — Forms & Reports Expert
* **Domain**: Oracle Forms & Reports Runtime Services.
* **Scope**: Forms Listener Servlet, `frmweb` processes, Reports Server (`rwserver`), Java Web Start (JWS) configuration, Java Runtime Environment (JRE) compatibility, FRM/REP runtime error codes.

### Expert 11 — Concurrent Processing Expert
* **Domain**: EBS Concurrent Processing Engine.
* **Scope**: Internal Concurrent Manager (ICM), Standard Manager, Conflict Resolution Manager (CRM), Transaction Managers, Specialization Rules, Work Shifts, Request Groups, long-running/pending request queue bottlenecks.

### Expert 12 — Workflow Expert
* **Domain**: Oracle Workflow & Notification Services.
* **Scope**: Workflow Engine, Workflow Background Process, Notification Mailer (Inbound/Outbound IMAP/SMTP), Business Event System (BES), `WF_DEFERRED`, `WF_ERROR` queues, AQ queues.

### Expert 13 — ADOP / Patching Expert
* **Domain**: EBS 12.2 Online Patching (ADOP) & Database Editioning (EBR).
* **Scope**: Dual file systems (`fs1`, `fs2`, `fs_ne`), ADOP phases (`prepare`, `apply`, `finalize`, `cutover`, `cleanup`, `abort`), Edition-Based Redefinition (`AD_ZD`), patch conflict analysis.

### Expert 14 — AutoConfig Expert
* **Domain**: Configuration Automation & Template Engine.
* **Scope**: Context XML files (`adctxmaster.xml`, `adoxml.xml`), AutoConfig templates, driver files, dual-fs autoconfig synchronization, port allocation, listener generation.

### Expert 15 — Oracle Linux Expert
* **Domain**: Operating System, Kernel & Core Subsystems.
* **Scope**: Oracle Linux (UEK / RHCK), RHEL, HugePages, Memory (`free -m`), CPU (`top`, `vmstat`, `mpstat`), I/O (`iostat`, `sar`), kernel parameters (`sysctl.conf`), LVM, XFS, NFS, systemd services.

### Expert 16 — Linux Security Expert
* **Domain**: Host Security, Hardening & Compliance.
* **Scope**: CIS Benchmarks, SELinux enforcement & policy analysis, SSH configuration, sudoers privilege restrictions, auditd logging, PAM, host firewall (`iptables` / `firewalld`).

### Expert 17 — Storage Expert
* **Domain**: Enterprise SAN/NAS, Multipath & I/O Infrastructure.
* **Scope**: Fiber Channel SAN, iSCSI, NFSv3/NFSv4 mount parameters, DM-Multipath (`multipath -ll`), I/O queue depths, disk latency (service times, await, r_await, w_await), storage volume expansion.

### Expert 18 — Network Engineer
* **Domain**: Enterprise Networking & Traffic Routing.
* **Scope**: TCP/IP stack, DNS latency, MTU sizing & jumbo frames, network routing, firewalls, load balancer virtual servers & health monitors, socket states (`ss -tunap`), packet captures (`tcpdump`).

### Expert 19 — Integration Engineer
* **Domain**: Enterprise Application Integration & APIs.
* **Scope**: REST & SOAP Web Services, Integrated SOA Gateway (ISG), XML Gateway, Database Links (`DB_LINKS`), EDI/B2B pipelines, message transformation.

### Expert 20 — SFTP Expert
* **Domain**: Secure File Transfer & Batch Ingestion.
* **Scope**: OpenSSH SFTP daemon, SSH key pairs (RSA/ED25519), SFTP chroot directory structures, file ownership & permissions, automated batch transfers, SELinux booleans for SFTP.

### Expert 21 — Oracle Security Architect
* **Domain**: Database & EBS Security Governance.
* **Scope**: Transparent Data Encryption (TDE), Oracle Database Vault, Unified Auditing, TLS 1.2/1.3 SSL certificates, FND user security, Separation of Duties (SoD), credentials vaulting.

### Expert 22 — Monitoring Engineer
* **Domain**: Observability, Telemetry & Enterprise Alerting.
* **Scope**: Oracle Enterprise Manager (OEM Cloud Control 13c), Prometheus, Grafana, Alertmanager, metric collection thresholds, synthetic user transaction monitoring, actionable alert design.

### Expert 23 — Capacity Planning Expert
* **Domain**: Predictive Analytics & Infrastructure Sizing.
* **Scope**: Database growth rate analysis, tablespace exhaustion modeling, CPU/Memory headroom forecasting, IOPS capacity planning, concurrent processing volume trends.

### Expert 24 — Automation / Ansible Expert
* **Domain**: Infrastructure as Code & Orchestration.
* **Scope**: Ansible Playbooks, Python automation, Bash shell scripts, automated non-disruptive health checks, idempotent deployment routines, safe dry-run configurations.

### Expert 25 — Incident Response / RCA Expert
* **Domain**: Major Incident Management & Problem Management.
* **Scope**: Major Incident containment, incident timeline reconstruction, 5-Whys root cause analysis, contributing factor identification, formal Root Cause Analysis (RCA) reporting.

### Expert 26 — Change Management Expert
* **Domain**: Production Change Governance & Risk Mitigation.
* **Scope**: ITIL Change Management, Risk scoring (Low, Medium, High, Critical), CAB documentation, maintenance window compliance, pre-implementation backup validation, rollback verification.

### Expert 27 — Business Continuity Architect
* **Domain**: Enterprise Disaster Recovery & Business Resiliency.
* **Scope**: Business Impact Analysis (BIA), Recovery Time Objective (RTO), Recovery Point Objective (RPO), Tier-1 ERP critical path recovery sequencing, DR testing drills and validation.
