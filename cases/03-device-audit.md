# Case 03 — Endpoint inventory follow-up

**Scenario**  
A device list shows several possible inventory or endpoint-management issues. The goal is to review active devices with stale check-ins, missing encryption reporting, or an inactive assigned user. This is a triage list, not proof of compromise or actual BitLocker status.

**Input**  
[`sql/cases/03_devices.sql`](../sql/cases/03_devices.sql); uses `SD_DEVICES`, `SD_USERS`, and a fixed stale-check threshold of `2026-10-20`.

### Query

```sql
SELECT
    d.asset_tag,
    NVL(u.display_name, '(unassigned)') AS assigned_to,
    CASE WHEN u.account_status = 'Inactive'
         THEN 'Inactive owner' ELSE 'OK' END AS ownership_check,
    CASE WHEN d.encryption_status <> 'Encrypted'
         THEN 'Review encryption' ELSE 'OK' END AS encryption_check,
    CASE WHEN d.last_check_in IS NULL
           OR d.last_check_in < DATE '2026-10-20'
         THEN 'Stale or missing' ELSE 'OK' END AS check_in_check
FROM sd_devices d
LEFT JOIN sd_users u ON u.user_id = d.assigned_user_id
WHERE d.device_status = 'Active'
  AND (u.account_status = 'Inactive'
       OR d.encryption_status <> 'Encrypted'
       OR d.last_check_in IS NULL
       OR d.last_check_in < DATE '2026-10-20')
ORDER BY d.asset_tag;
```

### Expected output from sample data

| Asset tag | Assigned to | Owner | Encryption | Check-in |
|---|---|---|---|---|
| LT-0042 | Daniel Wong | OK | OK | Stale or missing |
| LT-0043 | Priya Shah | OK | Review encryption | OK |
| LT-0044 | Sofia Chen | Inactive owner | OK | Stale or missing |

### Notes

Three active devices need a follow-up. `LT-0044` has more than one flag. `LT-0045` is **In Stock** and intentionally unassigned, so it is not treated as an issue by this report. That distinction prevents a false positive.

A practical next step would be to compare the flags with actual device-management and directory records. A database row should not be considered proof that disk encryption is enabled or disabled.

`LEFT JOIN` keeps devices without a user, while the `CASE` expressions turn raw status values into readable review flags. The SQL file also includes a full ownership list for checking unassigned devices, plus an Oracle `MINUS` query. The `MINUS` query returns device ID `305` (`LT-0045`) as the only device without any linked support ticket. That is an inventory fact, not automatically a fault.

**Validation state:** These are expected flags from synthetic records; no actual endpoint was queried.
