# Case 02 — Recurring sign-in tickets

**Scenario**  
Several users have logged in more than once about account or authentication problems. The aim is to find repeat requesters before assuming these are unrelated one-off issues.

**Input**  
[`sql/cases/02_signin.sql`](../sql/cases/02_signin.sql). The search includes the full month of October 2026, using an inclusive lower date and exclusive upper date.

### Query

```sql
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
```

### Expected output from sample data

| User ID | Name | Tickets | First reported | Last reported |
|---:|---|---:|---|---|
| 101 | Amira Patel | 3 | 2026-10-20 | 2026-10-28 |
| 102 | Daniel Wong | 2 | 2026-10-26 | 2026-10-29 |

The dates in Oracle may display differently depending on `NLS_DATE_FORMAT`; the values are the same.

A second query drills into the five tickets:

| Ticket | Requester ID | Date | Status | Summary |
|---:|---:|---|---|---|
| 1002 | 101 | 2026-10-20 | Closed | Password reset did not persist |
| 1001 | 101 | 2026-10-23 | Open | Repeated sign-in prompt on laptop |
| 1003 | 101 | 2026-10-28 | In Progress | MFA sign-in loop reported again |
| 1007 | 102 | 2026-10-26 | Pending User | Account unlock request |
| 1008 | 102 | 2026-10-29 | Resolved | Sign-in issue temporarily resolved |

### Notes

Amira has three sign-in tickets within eight days. The event notes include an MFA loop reproduction and an escalation. That warrants checking whether the same underlying issue has reopened, but ticket counts alone cannot prove a root cause. Daniel has two related tickets; one is marked resolved, while the other is pending a user retest.

The test demonstrates `GROUP BY`, `HAVING`, `COUNT`, date filtering, and a grouped subquery used to retrieve the individual ticket history.

**Validation state:** Expected outputs from synthetic data; not a real employee account investigation.
