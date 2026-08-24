#!/bin/bash
# ==============================================================================
# Oracle ASM Disk Group Health & Capacity Monitor via asmcmd
# Target: Oracle Grid Infrastructure / ASM 11g / 12c / 19c / 23ai
# ==============================================================================

set -uo pipefail

echo "============================================================"
echo " ASM Disk Group & Storage Subsystem Check"
echo " Timestamp: $(date)"
echo "============================================================"

if ! command -v asmcmd &>/dev/null; then
  echo "asmcmd not found on PATH. Please ensure GRID_HOME environment is set."
  exit 1
fi

echo "--- 1. Disk Group Free Space & Redundancy (asmcmd lsdg) ---"
asmcmd lsdg

echo "--- 2. Active ASM Rebalance Operations (asmcmd lsop) ---"
asmcmd lsop || echo "No active rebalance operations."

echo "--- 3. Disks Status in Disk Groups (asmcmd lsdsk) ---"
asmcmd lsdsk -k || true

echo "============================================================"
echo " ASM Health Check Complete."
echo "============================================================"
