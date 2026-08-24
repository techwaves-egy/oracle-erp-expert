---
name: oracle-upgrade
description: >-
  Plan, configure, and execute Oracle Database 19c/23ai upgrades, EBS 12.2 modernization, and cross-platform OCI cloud migrations.
---

# Oracle Upgrade & Cloud Migration (/oracle-upgrade)

When `/oracle-upgrade` is invoked:
1. For Database 19c / 23ai Upgrades:
   - Generate AutoUpgrade configuration file: [templates/autoupgrade_config.cfg](file:///d:/Techwaves-egy/Oracle%20Skill/templates/autoupgrade_config.cfg).
   - Execute pre-upgrade check steps: `autoupgrade.jar -mode analyze`.
   - Configure Flashback Database Guaranteed Restore Point (GRP) fallback.
2. For EBS R12.1 to R12.2 Modernization:
   - Enforce Edition-Based Redefinition (EBR / `AD_ZD`) and Editioning Views (`#`): [playbooks/10_ebs_r12_2_upgrade_and_cemli.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/10_ebs_r12_2_upgrade_and_cemli.md).
3. For Cross-Platform Endian & OCI Migration:
   - Configure RMAN XTTS v4 with minimal downtime: [playbooks/11_cross_platform_cloud_migration_xtts.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/11_cross_platform_cloud_migration_xtts.md).
   - Generate hour-by-hour cutover schedule: [templates/migration_cutover_runbook.md](file:///d:/Techwaves-egy/Oracle%20Skill/templates/migration_cutover_runbook.md).
