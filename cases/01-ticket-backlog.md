# Case 01 — Ticket backlog review

**Scenario**  
The support queue contains a mix of open, pending, and resolved requests. The first check is to identify unresolved P1/P2 tickets and how long they have been waiting. This is a report, not an assertion that a ticket has breached an agreed SLA.

**Input**  
[`sql/cases/01_backlog.sql`](../sql/cases/01_backlog.sql) uses the `SD_OPEN_TICKET_QUEUE` view and a fixed reporting date of `2026-11-01`.

### Query

```sql
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
```

### Expected output from sample data

| Ticket | Priority | Status | Requester | Technician | Age (days) |
|---:|---|---|---|---|---:|
| 1009 | P1 | Open | Sofia Chen | Casey Ng | 11 |
| 1001 | P2 | Open | Amira Patel | Jordan Lee | 9 |
| 1014 | P2 | Pending User | Leo Chan | Sam Rivera | 8 |
| 1004 | P2 | Open | Daniel Wong | Sam Rivera | 7 |
| 1010 | P2 | Open | Noah Brooks | Unassigned | 5 |
| 1003 | P2 | In Progress | Amira Patel | Jordan Lee | 4 |
| 1005 | P2 | In Progress | Priya Shah | Casey Ng | 2 |
| 1017 | P2 | Open | Eli Morgan | Sam Rivera | 2 |

There are **11 unresolved tickets**, including **8 P1/P2 tickets**. Across all unresolved tickets the status breakdown is:

| Status | Tickets |
|---|---:|
| In Progress | 2 |
| Open | 7 |
| Pending User | 2 |

### Notes

The oldest priority item is ticket `1009`. Ticket `1010` is high priority but has no assigned technician; that would be a reasonable triage follow-up. `Pending User` is not necessarily an escalation failure. The sample has no SLA calendar or agreed response-time thresholds, so I would not label these items **SLA breached** from age alone.

The SQL file also shows a Top-N query with `FETCH FIRST 3 ROWS ONLY`, ordered by age and ticket number to make ties deterministic.

**Validation state:** Expected outputs calculated from the supplied synthetic dataset. Oracle APEX run evidence to be added after execution.
