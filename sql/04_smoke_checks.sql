-- These return counts and are safe to run repeatedly.
-- Expected: 8 users, 3 technicians, 9 devices, 17 tickets, 10 events.
SELECT 'SD_USERS' AS object_name, COUNT(*) AS row_count FROM sd_users
UNION ALL SELECT 'SD_TECHNICIANS', COUNT(*) FROM sd_technicians
UNION ALL SELECT 'SD_DEVICES', COUNT(*) FROM sd_devices
UNION ALL SELECT 'SD_TICKETS', COUNT(*) FROM sd_tickets
UNION ALL SELECT 'SD_TICKET_EVENTS', COUNT(*) FROM sd_ticket_events;

-- Expected: 11 unresolved tickets.
SELECT COUNT(*) AS unresolved_count FROM sd_open_ticket_queue;

-- Expected: 2 requesters with two or more sign-in incidents.
SELECT COUNT(*) AS repeat_requesters
FROM sd_signin_summary
WHERE sign_in_tickets >= 2;

-- Expected: 0. These are integrity tests, not production data checks.
SELECT COUNT(*) AS orphan_requester_tickets
FROM sd_tickets t
WHERE NOT EXISTS (SELECT 1 FROM sd_users u WHERE u.user_id = t.requester_id);
