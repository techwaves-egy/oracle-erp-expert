#!/bin/bash
# ==============================================================================
# Oracle EBS Application Tier Graceful Ordered Shutdown Sequence
# Target: Oracle EBS R12.2 (CM -> OHS -> Managed Servers -> AdminServer -> Node Manager)
# ==============================================================================

set -uo pipefail

echo "============================================================"
echo " Stopping Oracle EBS Application Services in Safe Order"
echo " Timestamp: $(date)"
echo "============================================================"

if [ -z "${ADMIN_SCRIPTS_HOME:-}" ]; then
  echo "ERROR: ADMIN_SCRIPTS_HOME environment variable is not set."
  echo "Please source EBSapps.env run first."
  exit 1
fi

echo "Step 1: Stopping Concurrent Managers..."
${ADMIN_SCRIPTS_HOME}/adcmctl.sh stop || true

echo "Step 2: Stopping Oracle HTTP Server (OHS)..."
${ADMIN_SCRIPTS_HOME}/adapcctl.sh stop || true

echo "Step 3: Stopping Managed Servers (forms, oacore, oafm)..."
${ADMIN_SCRIPTS_HOME}/adformsctl.sh stop || true
${ADMIN_SCRIPTS_HOME}/adoacorectl.sh stop || true
${ADMIN_SCRIPTS_HOME}/adoafmctl.sh stop || true

echo "Step 4: Stopping WebLogic AdminServer..."
${ADMIN_SCRIPTS_HOME}/adadminsrvctl.sh stop || true

echo "Step 5: Stopping WebLogic Node Manager..."
${ADMIN_SCRIPTS_HOME}/adnodemgrctl.sh stop || true

echo "============================================================"
echo " All Application Tier Services Stopped."
echo "============================================================"
