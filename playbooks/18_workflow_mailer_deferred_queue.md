# Playbook 18: Workflow Notification Mailer & Deferred Queue Recovery

## 1. Scope
Triage and recovery for Oracle Workflow Notification Mailer failures, SMTP/IMAP connection timeouts, stuck notification backlogs, and `WF_DEFERRED` / `WF_ERROR` queue accumulation.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Workflow Expert**
* **Oracle Database DBA**
* **Network Engineer**
* **EBS System Administrator**

---

## 3. Workflow Mailer & Queue Diagnostic Pipeline

```
[Users report: Approval Emails Not Received]
                     │
                     ▼
  [Step 1: Check Workflow Service Component Status in OAM / DB]
                     │
                     ▼
  [Step 2: Check SMTP / IMAP Network Port Connectivity]
                     │
                     ▼
  [Step 3: Check WF_DEFERRED / WF_NOTIFICATION_OUT Queue Depths]
                     │
                     ▼
  [Step 4: Restart Workflow Mailer & Launch Background Process]
```

---

## 4. Diagnostic Commands & Queries

### Step 1: Check Mailer Service Component Status
```sql
-- Check status of Workflow Notification Mailer component
SELECT 
    component_name, 
    component_status, 
    component_status_info
FROM fnd_svc_components
WHERE component_name LIKE '%Mailer%';
```

### Step 2: Check Deferred & Error Queue Depths
```sql
-- Check WF_DEFERRED backlog
SELECT msg_state, COUNT(*) 
FROM applsys.aq$wf_deferred 
GROUP BY msg_state;

-- Check WF_ERROR queue for failing activities
SELECT msg_state, COUNT(*) 
FROM applsys.aq$wf_error 
GROUP BY msg_state;

-- Check pending unsent notifications
SELECT COUNT(*) 
FROM wf_notifications 
WHERE status = 'OPEN' 
  AND mail_status = 'MAIL';
```

### Step 3: Test Mail Server Connectivity (Network Expert)
```bash
# Test SMTP Relay (Port 25 / 587) from EBS Application Node:
nc -zv <smtp_host> 25
openssl s_client -connect <smtp_host>:587 -starttls smtp

# Test IMAP Server (Port 993 / 143):
nc -zv <imap_host> 993
```

---

## 5. Remediation & Queue Clearance

### Step 1: Start / Restart Notification Mailer via OAM or Script
```sql
-- Bounce Workflow Mailer Service Component
EXEC fnd_svc_component.stop_component(fnd_svc_component.get_component_id('Workflow Notification Mailer'));
EXEC fnd_svc_component.start_component(fnd_svc_component.get_component_id('Workflow Notification Mailer'));
```

### Step 2: Submit Workflow Background Process
Submit via Oracle Applications UI or PL/SQL:
* **Item Type**: `[Leave blank for ALL or specify e.g. OERROR / POAPPRV]`
* **Process Deferred**: `Yes`
* **Process Timeout**: `Yes`
* **Process Stuck**: `Yes`
