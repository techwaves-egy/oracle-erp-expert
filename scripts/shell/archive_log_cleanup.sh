#!/bin/bash
# ==============================================================================
# Safe RMAN Archive Log Cleanup (Post-Backup Validation)
# Target: Oracle RDBMS 11g / 12c / 19c / 23ai
# ==============================================================================

set -euo pipefail

echo "============================================================"
echo " Starting Safe Verified RMAN Archive Log Backup & Cleanup"
echo " Timestamp: $(date)"
echo " Database: ${ORACLE_SID:-Not Set}"
echo "============================================================"

# Execute RMAN script: Backup archive logs and delete input only after successful backup
rman target / <<EOF
CROSSCHECK ARCHIVELOG ALL;
DELETE NOPROMPT EXPIRED ARCHIVELOG ALL;
BACKUP ARCHIVELOG ALL NOT BACKED UP 1 TIMES DELETE INPUT;
EXIT;
EOF

echo "============================================================"
echo " Archive Log Cleanup Complete."
echo "============================================================"
