# Playbook 02: EBS User Login & Access Failure Triage

## 1. Problem Statement
Users report: *"Cannot log in to Oracle E-Business Suite"*, *"500 Internal Server Error / 502 Bad Gateway on Login"*, *"Forms not launching after clicking responsibility"*, or *"Page hangs after submitting credentials"*.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **EBS Architect**
* **EBS System Administrator**
* **WebLogic Expert**
* **Forms & Reports Expert**
* **Oracle Database DBA**
* **Network Engineer**
* **Linux Security Expert**

---

## 3. End-to-End Diagnostic Pipeline

```
[User Browser]
      │
      ▼  (Step 1: Network & DNS resolution)
[DNS / Load Balancer VIP]
      │
      ▼  (Step 2: Web Tier / OHS Apache)
[Oracle HTTP Server (OHS)]
      │
      ▼  (Step 3: WebLogic Managed Servers)
[oacore_server / WLS Domain]
      │
      ▼  (Step 4: Database Authentication & FND Users)
[Oracle DB / APPS Schema]
      │
      ▼  (Step 5: Forms Socket / Servlet Session)
[Forms Runtime (frmweb)]
```

---

## 4. Layer Diagnostics & Commands

### Step 1: Network & Connectivity (Network Engineer)
```bash
# Verify DNS resolution and SSL handshake
curl -Iv https://<ebs_external_url>:<port>/OA_HTML/AppsLogin
openssl s_client -connect <ebs_host>:<ssl_port> -servername <ebs_external_url>

# Check VIP port listening states
ss -tunap | grep -E ':(8000|8080|443|7001|7201)'
```

### Step 2: Web Tier (OHS) Status (EBS System Admin)
```bash
# Check OHS processes and error logs
$ADMIN_SCRIPTS_HOME/adapcctl.sh status

tail -100f $LOG_HOME/ora/10.1.3/Apache/Apache/logs/error_log
tail -100f $IAS_ORACLE_HOME/instances/*/diagnostics/logs/OHS/ohs1/ohs1.log
```

### Step 3: WebLogic Managed Servers & oacore (WebLogic Expert)
```bash
# Check oacore status
$ADMIN_SCRIPTS_HOME/adoacorectl.sh status

# Check for OutOfMemory or Stuck Threads in oacore server logs
grep -E "OutOfMemoryError|STUCK|BEA-000337" $LOG_HOME/appl/rgf/service_group/*/oacore*/logs/oacore*.log
```

### Step 4: Database FND User & DB Connection Health (DBA & EBS Architect)
```sql
-- Check if APPS or FND_USER accounts are locked or expired
SELECT user_id, user_name, start_date, end_date, password_date, encrypted_user_password
FROM fnd_user 
WHERE user_name IN ('SYSADMIN', '<AFFECTED_USER>');

-- Check database lockouts / profile option status
SELECT profile_option_name, profile_option_value 
FROM fnd_profile_option_values v
JOIN fnd_profile_options p ON v.profile_option_id = p.profile_option_id
WHERE p.profile_option_name IN ('APPS_AUTH_AGENT', 'APPS_SERVLET_AGENT', 'ICX_FORMS_LAUNCHER');

-- Check active APPS database sessions and connection limits
SELECT count(*), status FROM v$session WHERE username = 'APPS' GROUP BY status;
SELECT count(*), max_utilization, limit_value FROM v$resource_limit WHERE resource_name = 'sessions';
```

### Step 5: Forms Launching & FRM Errors (Forms Expert)
```bash
# Verify forms server status
$ADMIN_SCRIPTS_HOME/adformsctl.sh status

# Common FRM-92101 / FRM-92102 causes:
# - Check frmweb process dumps in $LOG_HOME
# - Check Java Web Start (JWS) .jnlp file delivery & certificate validity
```

---

## 5. Decision Matrix & Remediation

| Symptom | Confirmed Cause | Expert Recommendation |
|---|---|---|
| `502 Bad Gateway` / `503 Service Unavailable` | `oacore` instances stopped or crashed with JVM OutOfMemory | Restart `oacore` managed servers, collect heap dumps if recurring, adjust `-Xmx` memory arguments in context file. |
| `FRM-92101: There was a failure in the Forms server` | `frmweb` process termination or Forms socket timeout | Verify `forms-config.xml`, check system file descriptor limits (`ulimit -n`), verify JRE versions on client. |
| `Login page fails with ORA-28000: the account is locked` | `APPS` or `APPLSYSPUB` database user locked | Unlock database account via `ALTER USER APPLSYSPUB ACCOUNT UNLOCK;` and verify `FND_USER` synchronization. |
| Redirect to wrong IP / Hostname | Corrupt or unsynchronized Context XML | Execute AutoConfig on all application tier nodes after updating context file. |
