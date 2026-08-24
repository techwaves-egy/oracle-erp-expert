---
name: oracle-health
description: >-
  Execute a comprehensive 9-layer Oracle ERP & Database Health Check and Audit.
  Generates an executive scorecard and technical telemetry report branded under Techwaves EGY.
---

# Oracle ERP & Database Full Health Check (/oracle-health)

When `/oracle-health` is invoked:
1. Activate the full 27-expert council under the **Lead Oracle Architect**.
2. Execute the non-destructive audit queries from [playbooks/01_health_check.md](file:///d:/Techwaves-egy/Oracle%20Skill/playbooks/01_health_check.md) and [scripts/sql/ebs_full_health_check.sql](file:///d:/Techwaves-egy/Oracle%20Skill/scripts/sql/ebs_full_health_check.sql).
3. Evaluate:
   - OS & Storage: CPU load, HugePages, filesystem space (`df -h`), disk I/O latency.
   - Database: Instance status, tablespace utilization (>80%), invalid objects count.
   - Performance: Top active wait events and active blocking sessions.
   - Resilience: Last 7-day RMAN backup status and Data Guard MRP transport/apply lag.
   - EBS Services: Concurrent manager queue health and invalid APPS objects.
4. Deliver an executive scorecard with Green/Amber/Red ratings, prioritized findings, and **Techwaves EGY** branding (`info@techwaves-egy.com`).
5. Update `docs/SESSION_STATE.md` and append findings to `docs/WORK_LOG.md`.
