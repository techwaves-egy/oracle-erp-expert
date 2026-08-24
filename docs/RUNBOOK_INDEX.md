# Master Oracle CoE Playbook Index

This catalog maps every operational trigger and problem category to its primary Standard Operating Procedure (SOP).

| ID | Playbook Title | File Link | Primary Trigger / Symptoms | Activated Experts |
|:---|:---|:---|:---|:---|
| **00** | Intake & Discovery | [00_intake_and_discovery.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/00_intake_and_discovery.md) | Incomplete problem statement / pre-flight | Lead Architect |
| **01** | Full Health Check | [01_health_check.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/01_health_check.md) | *"Perform ERP health check"*, scheduled audit | All 27 Experts |
| **02** | EBS Login Failures | [02_ebs_login_failures.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/02_ebs_login_failures.md) | 500/502 Bad Gateway, FRM-92101, AppsLogin | EBS, WLS, Forms, DBA, Network |
| **03** | Database Hang & Locks | [03_database_hang_and_locks.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/03_database_hang_and_locks.md) | DB hanging, 100% CPU, row lock contention | DBA, Performance, SQL, RAC, Linux |
| **04** | Month-End Closing | [04_month_end_performance.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/04_month_end_performance.md) | GL/AR batch slow, TEMP exhaustion | Concurrent, Performance, SQL, DBA |
| **05** | RMAN Backup & Recovery | [05_rman_backup_recovery.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/05_rman_backup_recovery.md) | ORA-19809 (FRA full), backup failed | RMAN, DBA, Storage, Linux, DR |
| **06** | ADOP Online Patching | [06_adop_online_patching.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/06_adop_online_patching.md) | ADOP cycle phases (prepare to cutover) | ADOP, EBS, DBA, WLS, Backup |
| **07** | Custom Workflow | [07_workflow_development.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/07_workflow_development.md) | Custom approvals, WFLOAD, BES events | Workflow, SQL/PLSQL, EBS Admin |
| **08** | BI Publisher Reports | [08_bi_publisher_reports.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/08_bi_publisher_reports.md) | XML Data Template, RTF, Bursting email | SQL/PLSQL, Forms/Reports, Concurrent |
| **09** | Database 19c Upgrade | [09_database_upgrade_19c_autoupgrade.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/09_database_upgrade_19c_autoupgrade.md) | AutoUpgrade 11g/12c -> 19c / 23ai | DBA, Performance, RMAN, Linux |
| **10** | EBS 12.2 Modernization | [10_ebs_r12_2_upgrade_and_cemli.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/10_ebs_r12_2_upgrade_and_cemli.md) | 12.1 to 12.2 upgrade, CEMLI EBR standard | EBS Architect, ADOP, SQL, DBA |
| **11** | Cloud Migration (XTTS) | [11_cross_platform_cloud_migration_xtts.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/11_cross_platform_cloud_migration_xtts.md) | Cross-platform endian / OCI migration | DBA, RMAN, Storage, Network, BC |
| **12** | Non-CDB to PDB | [12_noncdb_to_pdb_conversion.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/12_noncdb_to_pdb_conversion.md) | Multitenant conversion (`DBMS_PDB`) | DBA, EBS Architect, Storage |
| **13** | Data Guard Switchover | [13_dataguard_switchover_failover.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/13_dataguard_switchover_failover.md) | Role transition, switchover, DR failover | DR, DBA, Storage, Network |
| **14** | Listener / TNS Triage | [14_listener_tns_connectivity.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/14_listener_tns_connectivity.md) | ORA-12541, ORA-12514, ORA-12154 | Network, DBA, RAC, Linux |
| **15** | RAC Node Eviction | [15_rac_interconnect_node_eviction.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/15_rac_interconnect_node_eviction.md) | CSS misscount, voting disk timeout, reboot | RAC/ASM, Linux, Network, DBA |
| **16** | ASM Disk Group Mgmt | [16_asm_diskgroup_rebalance_expansion.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/16_asm_diskgroup_rebalance_expansion.md) | Disk group full, rebalance power tuning | RAC/ASM, Storage, DBA |
| **17** | Tablespace Emergency | [17_tablespace_emergency_expansion.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/17_tablespace_emergency_expansion.md) | ORA-01653, ORA-01654, autoextend headroom | DBA, Storage, Capacity |
| **18** | Workflow Mailer Fix | [18_workflow_mailer_deferred_queue.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/18_workflow_mailer_deferred_queue.md) | Mailer down, WF_DEFERRED backlog | Workflow, DBA, Network |
| **19** | AutoConfig Rebuild | [19_autoconfig_failure_context_rebuild.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/19_autoconfig_failure_context_rebuild.md) | AC-50480, context XML desync | AutoConfig, EBS Admin, DBA |
| **20** | Alert Log ORA- Triage | [20_alert_log_ora_error_triage.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/20_alert_log_ora_error_triage.md) | ORA-00600, ORA-07445, ORA-04031 | DBA, Performance, SQL, Linux |
| **21** | Agent State Handover | [21_agent_handover_and_state_tracking.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/21_agent_handover_and_state_tracking.md) | Multi-agent handoff, history tracking, next steps | Lead Architect, RCA, All Experts |
