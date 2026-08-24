#!/bin/bash
# ==============================================================================
# Oracle EBS Application Tier Graceful Ordered Startup Sequence
# Target: Oracle EBS R12.2 (Node Manager -> AdminServer -> Managed Servers -> OHS -> CM)
# ==============================================================================

set -euo pipefail

echo "============================================================"
echo " Starting Oracle EBS Application Services in Correct Order"
echo " Timestamp: $(date)"
echo "============================================================"

if [ -z "${ADMIN_SCRIPTS_HOME:-}" ]; then
  echo "ERROR: ADMIN_SCRIPTS_HOME environment variable is not set."
  echo "Please source EBSapps.env run first."
  exit 1
fi

echo "Step 1: Starting WebLogic Node Manager..."
${ADMIN_SCRIPTS_HOME}/adnodemgrctl.sh start

echo "Step 2: Starting WebLogic AdminServer..."
${ADMIN_SCRIPTS_HOME}/adadminsrvctl.sh start

echo "Step 3: Starting Managed Servers (oacore, forms, oafm)..."
${ADMIN_SCRIPTS_HOME}/adoacorectl.sh start
${ADMIN_SCRIPTS_HOME}/adformsctl.sh start
${ADMIN_SCRIPTS_HOME}/adoafmctl.sh start

echo "Step 4: Starting Oracle HTTP Server (OHS)..."
${ADMIN_SCRIPTS_HOME}/adapcctl.sh start

echo "Step 5: Starting Concurrent Managers..."
${ADMIN_SCRIPTS_HOME}/adcmctl.sh start

echo "============================================================"
echo " All Application Tier Services Startup Complete."
echo "============================================================"
