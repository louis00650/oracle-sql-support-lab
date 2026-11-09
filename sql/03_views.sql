-- Reporting views. CREATE OR REPLACE allows rerunning these definitions.

CREATE OR REPLACE VIEW sd_open_ticket_queue AS
SELECT
    t.ticket_id,
    t.priority,
    t.status,
    t.category,
    u.display_name AS requester,
    NVL(tech.tech_name, 'Unassigned') AS technician,
    t.created_on,
    t.summary
FROM sd_tickets t
JOIN sd_users u ON u.user_id = t.requester_id
LEFT JOIN sd_technicians tech ON tech.tech_id = t.assigned_tech_id
WHERE t.status NOT IN ('Resolved', 'Closed');

CREATE OR REPLACE VIEW sd_signin_summary AS
SELECT
    u.user_id,
    u.display_name,
    COUNT(*) AS sign_in_tickets,
    MIN(t.created_on) AS first_reported,
    MAX(t.created_on) AS last_reported
FROM sd_tickets t
JOIN sd_users u ON u.user_id = t.requester_id
WHERE t.category = 'Sign-in'
GROUP BY u.user_id, u.display_name;
