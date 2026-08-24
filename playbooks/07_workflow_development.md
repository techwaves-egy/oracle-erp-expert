# Playbook 07: Oracle Workflow & Business Event Implementation

## 1. Scope
End-to-end design, implementation, deployment, and testing of Custom Oracle Workflows, Notifications, Item Attributes, and Business Event System (BES) subscriptions.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **Workflow Expert**
* **SQL / PL/SQL Expert**
* **Oracle EBS Architect**
* **EBS System Administrator**
* **Change Management Expert**

---

## 3. Workflow Implementation Lifecycle

```
[Design Workflow Process & Activities]
                 │
                 ▼
[Write PL/SQL Engine Package: XX_CUSTOM_WF_PKG]
                 │
                 ▼
[Generate & Upload Workflow Definition (.wft / .xml)]
                 │
                 ▼
[Configure Business Event & Subscription (WF_EVENTS)]
                 │
                 ▼
[Test Engine Execution & Background Process Validation]
```

---

## 4. Implementation Steps & Commands

### Step 1: PL/SQL Workflow Activity Implementation
Implement standard function signature in APPS schema:
```sql
PROCEDURE <procedure_name> (
    itemtype    IN VARCHAR2,
    itemkey     IN VARCHAR2,
    actid       IN NUMBER,
    funcmode    IN VARCHAR2,
    resultout   OUT NOCOPY VARCHAR2
);
```
*(Reference: [templates/workflow_package_template.sql](file:///d:/Techwaves-egy/Oracle%20Skill/templates/workflow_package_template.sql))*

### Step 2: Upload Workflow Definition via WFLOAD (OS Level)
```bash
# Upload / Upgrade custom workflow to database:
WFLOAD apps/<apps_pwd> 0 Y UPGRADE <file_name>.wft

# Force overwrite (if required):
WFLOAD apps/<apps_pwd> 0 Y FORCE <file_name>.wft

# Download existing workflow definition from database:
WFLOAD apps/<apps_pwd> 0 Y DOWNLOAD <output_file>.wft <ITEM_TYPE>
```

### Step 3: Register Business Event & Subscription (PL/SQL API)
```sql
-- Register Event Subscription to execute PL/SQL or trigger Workflow
DECLARE
    l_sub_guid RAW(16);
BEGIN
    wf_event_subscriptions_pkg.insert_row(
        x_rowid             => l_sub_guid,
        x_guid              => sys_guid(),
        x_system_guid       => wf_events_pkg.get_system_guid(),
        x_source_type       => 'LOCAL',
        x_source_agent_guid => NULL,
        x_event_filter_guid => wf_events_pkg.get_event_guid('oracle.apps.custom.order.created'),
        x_phase             => 50,
        x_status            => 'ENABLED',
        x_rule_data         => 'KEY',
        x_out_agent_guid    => NULL,
        x_to_agent_guid     => NULL,
        x_rule_function     => 'XX_CUSTOM_WORKFLOW_PKG.event_rule_subscription',
        x_parameters        => NULL,
        x_owner_name        => 'CUSTOM',
        x_owner_tag         => 'CUSTOM',
        x_customization_level => 'U',
        x_description       => 'Trigger Custom Workflow on Order Creation'
    );
    COMMIT;
END;
/
```

### Step 4: Troubleshooting Stuck Workflows & Deferred Queues
```sql
-- Check stuck workflow activities in ERROR status
SELECT 
    wi.item_type,
    wi.item_key,
    wi.begin_date,
    ias.activity_result_code,
    ias.activity_status,
    ias.error_name,
    ias.error_message,
    ias.error_stack
FROM wf_items wi
JOIN wf_item_activity_statuses ias ON wi.item_type = ias.item_type AND wi.item_key = ias.item_key
WHERE ias.activity_status = 'ERROR'
ORDER BY wi.begin_date DESC;

-- Check backlog in WF_DEFERRED Queue
SELECT COUNT(*), msg_state FROM applsys.aq$wf_deferred GROUP BY msg_state;
```
