#!/bin/bash
# ==============================================================================
# Oracle EBS 12.2 ADOP Phase Runner with Pre-Checks & Error Trapping
# Target: Oracle EBS R12.2 Online Patching
# ==============================================================================

set -euo pipefail

PHASE="${1:-}"
EXTRA_ARGS="${2:-}"

if [ -z "${PHASE}" ]; then
  echo "Usage: $0 <prepare|apply|finalize|cutover|cleanup|fs_clone|abort> [extra_args]"
  exit 1
fi

echo "============================================================"
echo " Executing ADOP Phase: ${PHASE}"
echo " Timestamp: $(date)"
echo " Extra Args: ${EXTRA_ARGS}"
echo "============================================================"

# Pre-Check: Verify Run File System is Sourced
if [ -z "${FILE_EDITION:-}" ] || [ "${FILE_EDITION}" != "run" ]; then
  echo "ERROR: You must source the RUN file system environment first."
  echo "Example: source <EBS_BASE>/EBSapps.env run"
  exit 1
fi

# Pre-Check: Check Free Disk Space on Application Tier (> 25GB)
FREE_GB=$(df -BG "${RUN_BASE:-/}" | awk 'NR==2 {gsub("G",""); print $4}')
if [ "${FREE_GB}" -lt 25 ]; then
  echo "WARNING: Low disk space detected (${FREE_GB}GB). ADOP recommend at least 25-50GB free."
fi

# Execute ADOP command
echo "Running: adop phase=${PHASE} ${EXTRA_ARGS}"
adop phase="${PHASE}" ${EXTRA_ARGS}

echo "============================================================"
echo " ADOP Phase ${PHASE} Execution Finished."
echo "============================================================"
