-- ==============================================================================
-- Oracle EBS Concurrent Processing, Queue Health, and Stuck Request Triage
-- Target: Oracle EBS R12.1 / R12.2
-- Non-Destructive / Read-Only
-- ==============================================================================

SET LINESIZE 250 PAGESIZE 1000 TRIM ON TI ON TIMI ON;

PROMPT ==============================================================================
PROMPT 1. CONCURRENT MANAGERS STATUS & QUEUE LOAD
PROMPT ==============================================================================
SELECT 
    q.concurrent_queue_name,
    q.user_concurrent_queue_name,
    q.max_processes,
    q.running_processes,
    COUNT(r.request_id) AS pending_requests
FROM fnd_concurrent_queues_vl q
LEFT JOIN fnd_concurrent_requests r 
    ON q.concurrent_queue_id = r.controlling_manager 
   AND r.phase_code = 'P' AND r.status_code IN ('I', 'Q')
GROUP BY q.concurrent_queue_name, q.user_concurrent_queue_name, q.max_processes, q.running_processes
ORDER BY pending_requests DESC;

PROMPT ==============================================================================
PROMPT 2. TOP LONG-RUNNING & STUCK CONCURRENT REQUESTS (RUNNING > 60 MINS)
PROMPT ==============================================================================
SELECT 
    r.request_id,
    p.user_concurrent_program_name,
    u.user_name requester,
    r.phase_code,
    r.status_code,
    r.actual_start_date,
    ROUND((SYSDATE - r.actual_start_date)*24*60, 2) runtime_mins,
    r.oracle_process_id spid
FROM fnd_concurrent_requests r
JOIN fnd_concurrent_programs_vl p ON r.concurrent_program_id = p.concurrent_program_id
JOIN fnd_user u ON r.requested_by = u.user_id
WHERE r.phase_code = 'R'
  AND (SYSDATE - r.actual_start_date)*24*60 > 60
ORDER BY r.actual_start_date ASC;
