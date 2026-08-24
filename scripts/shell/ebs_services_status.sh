#!/bin/bash
# ==============================================================================
# Oracle EBS Application Tier Services Status Verifier
# Target: Oracle EBS R12.1 / R12.2
# ==============================================================================

set -uo pipefail

echo "============================================================"
echo " Oracle EBS Application Tier Service Health Check"
echo " Timestamp: $(date)"
echo " Context: ${CONTEXT_NAME:-Not Set}"
echo "============================================================"

if [ -z "${ADMIN_SCRIPTS_HOME:-}" ]; then
  echo "ERROR: ADMIN_SCRIPTS_HOME environment variable is not set."
  echo "Please source EBSapps.env run first."
  exit 1
fi

echo "--- 1. Checking WebLogic Admin Server ---"
${ADMIN_SCRIPTS_HOME}/adadminsrvctl.sh status || true

echo "--- 2. Checking WebLogic Node Manager ---"
${ADMIN_SCRIPTS_HOME}/adnodemgrctl.sh status || true

echo "--- 3. Checking WebLogic Managed Servers (oacore, forms, oafm) ---"
${ADMIN_SCRIPTS_HOME}/adoacorectl.sh status || true
${ADMIN_SCRIPTS_HOME}/adformsctl.sh status || true
${ADMIN_SCRIPTS_HOME}/adoafmctl.sh status || true

echo "--- 4. Checking Oracle HTTP Server (OHS) ---"
${ADMIN_SCRIPTS_HOME}/adapcctl.sh status || true

echo "--- 5. Checking Concurrent Processing Services ---"
${ADMIN_SCRIPTS_HOME}/adcmctl.sh status || true

echo "============================================================"
echo " EBS Service Status Check Complete."
echo "============================================================"
