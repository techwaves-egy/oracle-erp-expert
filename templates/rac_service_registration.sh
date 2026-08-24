#!/bin/bash
# ==============================================================================
# Oracle RAC Database Service Creation & SCAN Configuration
# Target: Oracle Grid Infrastructure 12c / 19c / 23ai
# ==============================================================================

set -euo pipefail

DB_NAME="PRODDB"
SERVICE_NAME="ebs_online_srv"
PREFERRED_INSTANCES="PRODDB1,PRODDB2"
AVAILABLE_INSTANCES=""
FAILOVER_TYPE="TRANSACTION" # Application Continuity for 19c/23ai
FAILOVER_METHOD="BASIC"

echo "------------------------------------------------------------"
echo "Creating RAC Database Service: ${SERVICE_NAME} on DB: ${DB_NAME}"
echo "------------------------------------------------------------"

# 1. Add Service with Application Continuity (TAF/TAC) parameters
srvctl add service -db "${DB_NAME}" \
  -service "${SERVICE_NAME}" \
  -preferred "${PREFERRED_INSTANCES}" \
  -failovertype "${FAILOVER_TYPE}" \
  -failovermethod "${FAILOVER_METHOD}" \
  -failoverretries 30 \
  -failoverdelay 5 \
  -commit_outcome TRUE \
  -retention 86400 \
  -replay_init_time 300

# 2. Start the new service across preferred nodes
srvctl start service -db "${DB_NAME}" -service "${SERVICE_NAME}"

# 3. Check service status
srvctl status service -db "${DB_NAME}" -service "${SERVICE_NAME}"
srvctl config service -db "${DB_NAME}" -service "${SERVICE_NAME}"

echo "------------------------------------------------------------"
echo "RAC Service ${SERVICE_NAME} registered and active."
echo "------------------------------------------------------------"
