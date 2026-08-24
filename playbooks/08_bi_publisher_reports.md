# Playbook 08: BI Publisher (XML Publisher) & Custom Reports Implementation

## 1. Scope
Creation, registration, data templating, layout design (RTF/Excel/PDF), bursting configuration, and deployment of Oracle BI Publisher (XML Publisher) reports in Oracle EBS.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **SQL / PL/SQL Expert**
* **Forms & Reports Expert**
* **Concurrent Processing Expert**
* **EBS Architect**
* **Automation / Ansible Expert**

---

## 3. End-to-End Implementation Architecture

```
[SQL / PL/SQL Data Package]
             │
             ▼
[XML Data Template (.xml)]
             │
             ▼
[RTF / Excel Layout Template (.rtf)]
             │
             ▼
[Register Executable & Concurrent Program via FND_PROGRAM]
             │
             ▼
[Register XML Publisher Data Definition & Template via XDOLoader]
             │
             ▼
[Optional: Bursting Engine (.xml) for Automated Email/FTP Distribution]
```

---

## 4. Implementation Steps & Commands

### Step 1: Create Data Template XML
Design a high-performance XML Data Template adhering to Oracle XML Publisher DTD.  
*(Reference: [templates/bi_publisher_data_template.xml](file:///d:/Techwaves-egy/Oracle%20Skill/templates/bi_publisher_data_template.xml))*

### Step 2: Register Concurrent Program
Run the automated registration script to configure the Executable (`XDODTEXE` or PL/SQL), Concurrent Program, Parameters, and Request Group.  
*(Reference: [templates/fnd_concurrent_registration.sql](file:///d:/Techwaves-egy/Oracle%20Skill/templates/fnd_concurrent_registration.sql))*

### Step 3: Deploy Data Definition & RTF Template via XDOLoader
```bash
# 1. Upload Data Definition XML into XML Publisher Repository
java oracle.apps.xdo.oa.util.XDOLoader \
  UPLOAD \
  -DB_USERNAME apps \
  -DB_PASSWORD <apps_password> \
  -JDBC_CONNECTION <db_host>:<port>:<sid> \
  -LOB_TYPE DATA_TEMPLATE \
  -APPS_SHORT_NAME AR \
  -LOB_CODE XX_AR_INVOICE_REP \
  -LANGUAGE en \
  -TERRITORY US \
  -XDO_FILE_TYPE XML \
  -FILE_NAME XX_AR_INVOICE_REP.xml

# 2. Upload RTF Layout Template
java oracle.apps.xdo.oa.util.XDOLoader \
  UPLOAD \
  -DB_USERNAME apps \
  -DB_PASSWORD <apps_password> \
  -JDBC_CONNECTION <db_host>:<port>:<sid> \
  -LOB_TYPE TEMPLATE \
  -APPS_SHORT_NAME AR \
  -LOB_CODE XX_AR_INVOICE_REP \
  -LANGUAGE en \
  -TERRITORY US \
  -XDO_FILE_TYPE RTF \
  -FILE_NAME XX_AR_INVOICE_REP.rtf
```

### Step 4: Configure Automated Bursting (Optional)
Deploy XML Publisher Bursting Control File for splitting reports and emailing directly to customer email addresses:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<xapi:requestset xmlns:xapi="http://xmlns.oracle.com/oxp/xapi">
  <xapi:request select="/XX_FIN_AR_INVOICE_REPORT/G_HEADER">
    <xapi:delivery>
      <xapi:email server="smtp.domain.com" port="25" from="billing@domain.com" reply-to="billing@domain.com">
        <xapi:message id="inv_msg" to="${CUSTOMER_EMAIL}" cc="" attachment="true" subject="Invoice #${INVOICE_NUMBER}">
          Dear Customer, please find attached your invoice #${INVOICE_NUMBER}.
        </xapi:message>
      </xapi:email>
    </xapi:delivery>
    <xapi:document output="invoice_${INVOICE_NUMBER}.pdf" output-type="pdf" delivery="inv_msg">
      <xapi:template type="rtf" location="xdo://AR.XX_AR_INVOICE_REP.en.US/?getSource=true" filter=""/>
    </xapi:document>
  </xapi:request>
</xapi:requestset>
```

### Step 5: Test Execution via PL/SQL (Silent Background Testing)
```sql
DECLARE
    l_request_id NUMBER;
BEGIN
    fnd_global.apps_initialize(
        user_id      => 1001,  -- SYSADMIN or valid user
        resp_id      => 50123, -- Receivables Manager
        resp_appl_id => 222    -- AR Application ID
    );

    l_request_id := fnd_request.submit_request(
        application => 'AR',
        program     => 'XX_AR_INVOICE_REP',
        description => 'Test Execution of Custom AR Report',
        start_time  => SYSDATE,
        sub_request => FALSE,
        argument1   => '204',        -- P_ORG_ID
        argument2   => '2026/01/01', -- P_FROM_DATE
        argument3   => '2026/08/24', -- P_TO_DATE
        argument4   => 'ALL'         -- P_STATUS
    );
    COMMIT;
    dbms_output.put_line('Submitted Request ID: ' || l_request_id);
END;
/
```
