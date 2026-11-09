-- Case 03: review active devices with any one of three follow-up flags.
-- A laptop explicitly marked 'In Stock' is intentionally not treated as a fault.
SELECT
    d.asset_tag,
    NVL(u.display_name, '(unassigned)') AS assigned_to,
    CASE WHEN u.account_status = 'Inactive' THEN 'Inactive owner' ELSE 'OK' END AS ownership_check,
    CASE WHEN d.encryption_status <> 'Encrypted' THEN 'Review encryption' ELSE 'OK' END AS encryption_check,
    CASE WHEN d.last_check_in IS NULL OR d.last_check_in < DATE '2026-10-20'
         THEN 'Stale or missing' ELSE 'OK' END AS check_in_check
FROM sd_devices d
LEFT JOIN sd_users u ON u.user_id = d.assigned_user_id
WHERE d.device_status = 'Active'
  AND (
       u.account_status = 'Inactive'
       OR d.encryption_status <> 'Encrypted'
       OR d.last_check_in IS NULL
       OR d.last_check_in < DATE '2026-10-20'
  )
ORDER BY d.asset_tag;

-- Ownership overview: LEFT JOIN preserves the unassigned spare.
SELECT
    d.asset_tag,
    d.device_status,
    NVL(u.display_name, '(unassigned)') AS assigned_to
FROM sd_devices d
LEFT JOIN sd_users u ON u.user_id = d.assigned_user_id
ORDER BY d.asset_tag;

-- Oracle MINUS: devices that have never been linked to a ticket.
-- Expected device_id: 305 (the spare LT-0045).
SELECT device_id FROM sd_devices
MINUS
SELECT device_id FROM sd_tickets WHERE device_id IS NOT NULL;
