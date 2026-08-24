#!/bin/bash
# ==============================================================================
# Oracle Linux Host Resource & Kernel Subsystem Health Snapshot
# Target: Oracle Linux 7/8/9 / RHEL / UEK
# ==============================================================================

set -uo pipefail

echo "============================================================"
echo " Oracle Host OS Resource & Health Audit"
echo " Host: $(hostname) | Date: $(date)"
echo "============================================================"

echo "--- 1. Uptime & Load Average ---"
uptime

echo "--- 2. CPU Core Utilization (sar 1 3) ---"
sar -u 1 3 || top -bn1 | head -15

echo "--- 3. Memory & HugePages Allocation ---"
free -m
grep -E "HugePages_Total|HugePages_Free|Hugepagesize" /proc/meminfo || true

echo "--- 4. Filesystem Capacity (> 80% used) ---"
df -hP | awk '0+$5 >= 80 {print $0}'

echo "--- 5. Swap Activity & Memory Paging ---"
vmstat 1 3

echo "--- 6. Storage Disk Latency (iostat 1 3) ---"
iostat -xz 1 3 || true

echo "============================================================"
echo " Host Audit Complete."
echo "============================================================"
