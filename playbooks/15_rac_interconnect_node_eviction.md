# Playbook 15: RAC Interconnect Degradation & Node Eviction Recovery

## 1. Scope
Triage and recovery for Oracle Real Application Clusters (RAC) node evictions, reboot loops, Private Interconnect latency/packet drop, and split-brain voting disk arbitration.

## 2. Activated Experts
* **Lead Oracle Architect** (Orchestrator)
* **RAC / Grid / ASM Architect**
* **Oracle Linux Expert**
* **Network Engineer**
* **Oracle Database DBA**
* **Incident Response / RCA Expert**

---

## 3. Node Eviction Root Cause Classification

```
+-------------------------------------------------------------------------+
| Primary Eviction Triggers:                                              |
| 1. Network Split-Brain: Loss of private interconnect heartbeat between  |
|    nodes for > CSS Misscount (typically 30 seconds).                    |
| 2. Disk Split-Brain: Node unable to write to majority of voting disks   |
|    within disk timeout (200 seconds).                                   |
| 3. Operating System Hang / CPU Starvation: High load prevents ocssd.bin |
|    or oprocd scheduling within deadline.                                |
+-------------------------------------------------------------------------+
```

---

## 4. Diagnostic Commands & Log Analysis

### Step 1: Inspect Grid Infrastructure & Clusterware Alert Logs
```bash
# Locate Clusterware alert log
tail -200f $GRID_HOME/log/<node_name>/alert<node_name>.log

# Inspect CSS daemon log for eviction reason:
grep -E "CRS-1607|CRS-1614|CRS-1632|eviction|fatal" $GRID_HOME/log/<node_name>/cssd/ocssd.log
```

### Step 2: Voting Disk & Cluster Interconnect Status (RAC Architect)
```bash
# Query voting disk location and online status
crsctl query css votedisk

# Check configured cluster interconnect interfaces
oifcfg getif

# Check clusterware component health
crsctl check crs
crsctl check cluster -all
```

### Step 3: Private Interconnect Latency & MTU Verification (Network Expert)
```bash
# Check for MTU mismatches (e.g. Jumbo Frames 9000 MTU vs Standard 1500)
ip link show | grep -E "eth|ens|bond"

# Ping private interconnect IP of other nodes with large packets (Jumbo frames check):
ping -s 8972 -c 5 <peer_node_priv_ip>

# Check for dropped packets or buffer overruns on private NICs:
netstat -i
ethtool -S <priv_nic_name> | grep -E "drop|error|crc"
```

### Step 4: Cluster Cache Transfer Wait Events (DBA & Performance Engineer)
```sql
-- Check for high interconnect transfer wait events:
SELECT 
    inst_id,
    event,
    total_waits,
    round(time_waited_micro/1000000, 2) AS time_waited_secs,
    round(average_wait*10, 2) AS avg_wait_ms
FROM gv$system_event
WHERE event IN ('gc cr block 2-way', 'gc cr block 3-way', 'gc current block 2-way', 'gc current block 3-way', 'gc cr block lost', 'gc current block lost')
ORDER BY time_waited_micro DESC;
```
