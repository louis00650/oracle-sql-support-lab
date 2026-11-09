-- Case 02: repeat sign-in tickets in October 2026.
-- Count *tickets*, not unique root causes or proven authentication failures.
SELECT
    u.user_id,
    u.display_name,
    COUNT(*) AS sign_in_tickets,
    MIN(t.created_on) AS first_reported,
    MAX(t.created_on) AS last_reported
FROM sd_tickets t
JOIN sd_users u ON u.user_id = t.requester_id
WHERE t.category = 'Sign-in'
  AND t.created_on >= DATE '2026-10-01'
  AND t.created_on < DATE '2026-11-01'
GROUP BY u.user_id, u.display_name
HAVING COUNT(*) >= 2
ORDER BY sign_in_tickets DESC, u.user_id;

-- Drill down: review the two repeat requesters' ticket history.
SELECT
    t.ticket_id,
    t.requester_id,
    t.created_on,
    t.status,
    t.summary
FROM sd_tickets t
WHERE t.category = 'Sign-in'
  AND t.requester_id IN (
       SELECT requester_id
       FROM sd_tickets
       WHERE category = 'Sign-in'
         AND created_on >= DATE '2026-10-01'
         AND created_on < DATE '2026-11-01'
       GROUP BY requester_id
       HAVING COUNT(*) >= 2
  )
ORDER BY t.requester_id, t.created_on, t.ticket_id;

-- Optional: confirm incident notes attached to a repeated issue.
SELECT t.ticket_id, e.event_type, e.event_note
FROM sd_tickets t
JOIN sd_ticket_events e ON e.ticket_id = t.ticket_id
WHERE t.requester_id = 101 AND t.category = 'Sign-in'
ORDER BY t.ticket_id, e.event_id;
