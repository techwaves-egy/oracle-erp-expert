# CoE Response Templates

## 1. Domain Expert Output Template
Each individual activated domain expert must output their findings conforming to this exact structure:

```markdown
EXPERT: <e.g., Performance Engineer | EBS Architect | DBA | Linux Expert>
ROLE: <Domain Role Title>

OBSERVATIONS:
- <Specific observed symptoms, metric anomalies, or behaviors>

EVIDENCE:
- <Log entries, SQL output tables, OS command results, or trace lines>

ANALYSIS:
- <Deep technical correlation explaining WHY this behavior occurred and how it links to the symptom>

RISK:
- <Low | Medium | High | Critical>

RECOMMENDATION:
- <Clear, targeted remediation or optimization proposal>

COMMANDS / SQL:
```sql
-- Non-destructive diagnostic query or remediation statement
```

EXPECTED RESULT:
- <Measurable expected outcome post-change>

VALIDATION:
- <Verification query or command to confirm success>

ROLLBACK:
- <Step-by-step commands to cleanly reverse the change if anomalies appear>

CONFIDENCE: <90-100% (Confirmed) | 75-89% (Highly Likely) | 50-74% (Possible) | <50% (Insufficient Evidence)>
```

---

## 2. Lead Oracle Architect Master Response Template
The Lead Oracle Architect orchestrates the findings and delivers the master executive and technical solution:

```markdown
# [Executive Summary: Incident / Request Title]

## 1. Executive Briefing & Impact
- **Affected System**: <EBS PROD / Database SID / Host>
- **Business Impact**: <Severity & operational impact>
- **Current Status**: <Investigating | Contained | Resolved | Monitoring>

## 2. Layer & Root Cause Identification
- **Root Cause Layer**: `<Client | Network | Web | WebLogic | EBS App | Database | RAC/ASM | Storage | OS>`
- **Confirmed Root Cause**: <Direct factual summary supported by telemetry>

## 3. Contributing Evidence & Multi-Expert Findings
| Domain Expert | Finding Summary | Evidence Reference | Confidence |
|---|---|---|---|
| <Expert Name> | <Summary> | <Log/SQL reference> | <Confidence %> |

## 4. Conflict Resolution & Cross-Validation
<Explanation of how conflicting theories were analyzed and resolved using direct evidence>

## 5. Step-by-Step Action Plan
### Phase 1: Immediate Containment & Non-Destructive Verification
1. ...
2. ...

### Phase 2: Targeted Implementation
```bash
# Exact commands with parameters
```

## 6. Production Safety Gate
- [x] Target Host / SID explicitly validated: `<HOST> / <SID>`
- [x] RMAN Backup & Archive log stream verified within SLA
- [x] Change Risk Level: **<Low | Medium | High | Critical>**
- [x] Rollback Procedure Documented & Tested

## 7. Post-Implementation Validation
```sql
-- Verification Query
```

## 8. Rollback Procedure
```bash
# Exact commands to reverse change immediately
```

## 9. Root Cause Prevention & Permanent Recommendations
- <Architectural, configuration, or monitoring improvements to prevent recurrence>
```
