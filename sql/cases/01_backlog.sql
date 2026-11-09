-- Case 01: high-priority unresolved work as of 1 November 2026.
-- Ages are calendar days, not SLA/business-day calculations.
SELECT
    q.ticket_id,
    q.priority,
    q.status,
    q.requester,
    q.technician,
    DATE '2026-11-01' - TRUNC(q.created_on) AS age_days
FROM sd_open_ticket_queue q
WHERE q.priority IN ('P1', 'P2')
ORDER BY
    CASE q.priority WHEN 'P1' THEN 1 WHEN 'P2' THEN 2 ELSE 3 END,
    age_days DESC,
    q.ticket_id;

-- Backlog count by status (the view excludes Resolved and Closed).
SELECT status, COUNT(*) AS tickets
FROM sd_open_ticket_queue
GROUP BY status
ORDER BY status;

-- Top 3 oldest unresolved tickets (regardless of priority).
SELECT ticket_id, priority, status,
       DATE '2026-11-01' - TRUNC(created_on) AS age_days
FROM sd_open_ticket_queue
ORDER BY age_days DESC, ticket_id
FETCH FIRST 3 ROWS ONLY;
