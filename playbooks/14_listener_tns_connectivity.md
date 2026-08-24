# Playbook 14: Oracle Listener & TNS Connectivity Triage

## 1. Scope
Troubleshooting client connection failures, listener drops, SCAN listener unreachability, and common TNS errors (`ORA-12154`, `ORA-12514`, `ORA-12541`, `ORA-12520`).

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Network Engineer**
* **Oracle Database DBA**
* **RAC / Grid / ASM Architect**
* **Oracle Linux Expert**

---

## 3. TNS Error Decision Matrix

| Error Code | Error Text | Root Cause | Immediate Diagnostic / Resolution |
|---|---|---|---|
| `ORA-12541` / `TNS-12541` | `TNS:no listener` | Listener process stopped or firewall blocking port (1521). | `lsnrctl status`, `systemctl status firewalld`, `nc -zv <host> 1521`. |
| `ORA-12514` / `TNS-12514` | `TNS:listener does not currently know of service requested` | DB service not dynamically registered with listener or incorrect `SERVICE_NAME` in `tnsnames.ora`. | `lsnrctl services`, `ALTER SYSTEM REGISTER;`, verify `service_names` DB parameter. |
| `ORA-12154` / `TNS-12154` | `TNS:could not resolve the connect identifier specified` | Syntax error or missing entry in `tnsnames.ora` or `TNS_ADMIN` path incorrect. | `tnsping <alias>`, check `$TNS_ADMIN/tnsnames.ora` file syntax and permissions. |
| `ORA-12520` / `TNS-12520` | `TNS:listener could not find available handler for requested type of server` | `PROCESSES` or `SESSIONS` limit reached on database instance. | `SELECT count(*), limit_value FROM v$resource_limit WHERE resource_name='processes';` |

---

## 4. Diagnostic Commands

### Step 1: Local & SCAN Listener Status
```bash
# Standalone / Local Listener
lsnrctl status LISTENER
lsnrctl services LISTENER

# RAC / Grid Infrastructure SCAN Listeners
srvctl status scan_listener
srvctl status listener
crsctl stat res -t | grep -i listener
```

### Step 2: Network Port & Socket Inspection (Linux / Network Expert)
```bash
# Verify port listening state
ss -tunap | grep 1521

# Test network path and MTU
nc -zv <db_host> 1521
ping -c 4 <db_host>
traceroute <db_host>
```

### Step 3: Trigger Dynamic Service Registration (DBA Expert)
```sql
-- Force PMON/LREG to register database services immediately:
ALTER SYSTEM REGISTER;

-- Check registered service names in database:
SHOW PARAMETER service_names;
SHOW PARAMETER local_listener;
SHOW PARAMETER remote_listener;
```
