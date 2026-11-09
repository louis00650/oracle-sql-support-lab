-- Case 04: read-only validation checks; no rows should be missing parents.
SELECT COUNT(*) AS tickets_without_requester
FROM sd_tickets t
WHERE NOT EXISTS (
    SELECT 1 FROM sd_users u WHERE u.user_id = t.requester_id
);

SELECT COUNT(*) AS assigned_devices_without_owner
FROM sd_devices d
WHERE d.assigned_user_id IS NOT NULL
  AND NOT EXISTS (
       SELECT 1 FROM sd_users u WHERE u.user_id = d.assigned_user_id
  );

SELECT COUNT(*) AS duplicate_asset_tags
FROM (
    SELECT asset_tag
    FROM sd_devices
    GROUP BY asset_tag
    HAVING COUNT(*) > 1
);

SELECT COUNT(*) AS resolved_without_date
FROM sd_tickets
WHERE status IN ('Resolved', 'Closed') AND resolved_on IS NULL;

-- Show the ticket that is not assigned to a technician.
SELECT t.ticket_id, t.priority, t.status, t.summary
FROM sd_tickets t
WHERE t.assigned_tech_id IS NULL;

-- Negative tests (do NOT run as part of the default scripts):
-- INSERT INTO sd_tickets VALUES (9999,999,NULL,NULL,'Sign-in','P3','Open',DATE '2026-10-31',NULL,'Unknown requester');
-- Expected ORA-02291: parent key does not exist.
-- INSERT INTO sd_devices VALUES (399,'LT-0041','Laptop',NULL,'In Stock','Unknown',NULL);
-- Expected ORA-00001: duplicate unique asset_tag.
-- INSERT INTO sd_tickets VALUES (9998,101,NULL,NULL,'Sign-in','P9','Open',DATE '2026-10-31',NULL,'Bad priority');
-- Expected ORA-02290: check constraint violated.
