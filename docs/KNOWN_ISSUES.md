# Oracle ERP & Database Known Issues & My Oracle Support (MOS) Reference

This catalog documents common enterprise Oracle EBS and Database bugs, known error signatures, and their official Oracle reference Doc IDs.

---

## 1. Database & High Availability Known Issues

| Error / Symptom | Affected Versions | Cause / Bug Summary | Oracle Doc ID / Fix |
|:---|:---|:---|:---|
| `ORA-01555: snapshot too old` | 11g, 12c, 19c | High query runtime exceeds `UNDO_RETENTION` or small undo tablespace | MOS Doc ID `10630.1` — Increase `UNDO_RETENTION` & tune SQL |
| `ORA-04031: unable to allocate bytes of shared memory` | 11g, 12c, 19c | Shared pool fragmentation or unpinned heavy PL/SQL packages | MOS Doc ID `146599.1` — Pin packages via `DBMS_SHARED_POOL.KEEP` |
| `ORA-00600 [kdsgrp1]` | 12c, 19c | Index vs Table row count block inconsistency / corruption | MOS Doc ID `285586.1` — Rebuild corrupted B-Tree index |
| `gc cr block lost` / RAC Eviction | 12c, 19c RAC | Interconnect packet drop due to UDP buffer overrun or MTU mismatch | MOS Doc ID `563566.1` — Configure Jumbo Frames (9000 MTU) |
| `RMAN-06059: expected archived log not found` | 11g–19c | Archive logs deleted outside RMAN (desynchronized catalog) | Run `RMAN> CROSSCHECK ARCHIVELOG ALL; DELETE EXPIRED;` |

---

## 2. Oracle EBS & WebLogic Known Issues

| Error / Symptom | Affected Versions | Cause / Bug Summary | Oracle Doc ID / Fix |
|:---|:---|:---|:---|
| `FRM-92101: There was a failure in the Forms server` | EBS 12.1 / 12.2 | `frmweb` process killed due to OS memory limit or JRE mismatch | MOS Doc ID `1077728.1` — Set `ulimit -s 10240` and update JRE |
| `BEA-000337: [STUCK] ExecuteThread` | WLS 11g / 12c | JDBC pool exhaustion or long-running database blocking locks | MOS Doc ID `1307651.1` — Increase JDBC MaxCapacity & kill blockers |
| `ADOP Cutover fails at AC-50480` | EBS 12.2 | Port conflict on target Run file system | MOS Doc ID `1905593.1` — Check `netstat` and run port validation |
| `Workflow Notification Mailer fails with Connection Timeout` | EBS 12.1 / 12.2 | TLS 1.2 handshake issue or SMTP relay security block | MOS Doc ID `562551.1` — Update Java mailer SSL truststore |
| `CEMLI package compilation invalid after cutover` | EBS 12.2 | Custom package references base table instead of Editioning View (`#`) | MOS Doc ID `1531121.1` — Migrate CEMLI to `AD_ZD_TABLE.UPGRADE` |
