# Service Desk SQL Lab

I built a small Oracle SQL database to practise investigating the kinds of data problems I might see in IT support or application support. The data is fictional: users, devices, technicians, support tickets, and ticket updates. My earlier work involved web application testing and issue tracking, so I wanted to connect SQL queries to that type of work rather than keep a collection of unrelated exercises.

This page follows the lab in the order I built it: **create tables → insert records → query the support queue → investigate patterns → check data integrity**. I keep the complete scripts and longer outputs in the linked files so the walkthrough stays readable.

> **Verification status:** All records are synthetic. The outputs below are **expected results calculated from the seed data**, not screenshots or claims of a completed run on my Oracle account. The scripts are prepared for an Oracle training schema; I still need to verify them in Oracle APEX/SQLcl and record any differences.

## 1. Create the tables

I started with users, then added technicians, devices, tickets, and ticket events. Primary and foreign keys keep the records linked. For example, a ticket cannot refer to a requester who does not exist.

This is the users table from my schema:

```sql
CREATE TABLE sd_users (
    user_id         NUMBER(6) CONSTRAINT sd_users_pk PRIMARY KEY,
    display_name    VARCHAR2(80 CHAR) NOT NULL,
    department      VARCHAR2(40 CHAR) NOT NULL,
    email           VARCHAR2(120 CHAR) NOT NULL,
    account_status  VARCHAR2(10 CHAR) NOT NULL,
    CONSTRAINT sd_users_email_uk UNIQUE (email),
    CONSTRAINT sd_users_status_ck CHECK (account_status IN ('Active', 'Inactive'))
);
```

In `SD_TICKETS`, I added a foreign key to the requester:

```sql
CONSTRAINT sd_tickets_requester_fk
    FOREIGN KEY (requester_id) REFERENCES sd_users (user_id)
```

The full [table definitions and constraints](sql/01_schema.sql) include five tables. I avoided `ON DELETE CASCADE` for support records because deleting an account should not silently erase its ticket history. A short [data model](docs/data-model.md) explains the relationships.

## 2. Insert sample records and check the setup

I inserted a few related records first, then populated the rest of the fictional queue. Two examples from the seed file:

```sql
INSERT INTO sd_users
VALUES (101, 'Amira Patel', 'Finance', 'amira@example.invalid', 'Active');

INSERT INTO sd_tickets
VALUES (1001, 101, 201, 301, 'Sign-in', 'P2', 'Open',
        DATE '2026-10-23', NULL, 'Repeated sign-in prompt on laptop');
```

The ticket insert depends on technician `201` and device `301`, so the other parent tables must be populated first. The [complete seed script](sql/02_sample_data.sql) handles that order and ends with `COMMIT`.

I used a basic count query to check whether the data was loaded:

```sql
SELECT COUNT(*) AS ticket_count FROM sd_tickets;
```

**Expected result**

| TICKET_COUNT |
|---:|
| 17 |

The dataset has **8 users, 3 technicians, 9 devices, 17 tickets and 10 ticket events**. The other counts are checked in [`04_smoke_checks.sql`](sql/04_smoke_checks.sql).

## 3. Check the unresolved queue

My first question was straightforward: *which urgent tickets are still unresolved?* I created an `SD_OPEN_TICKET_QUEUE` view to join ticket data to requester and technician names. That avoids repeating the same joins in each report ([view SQL](sql/03_views.sql)).

```sql
SELECT ticket_id, priority, status, technician,
       DATE '2026-11-01' - TRUNC(created_on) AS age_days
FROM sd_open_ticket_queue
WHERE priority IN ('P1', 'P2')
ORDER BY CASE priority WHEN 'P1' THEN 1 ELSE 2 END,
         age_days DESC, ticket_id
FETCH FIRST 3 ROWS ONLY;
```

**Expected result — first three urgent tickets**

| Ticket | Priority | Status | Technician | Age (days) |
|---:|---|---|---|---:|
| 1009 | P1 | Open | Casey Ng | 11 |
| 1001 | P2 | Open | Jordan Lee | 9 |
| 1014 | P2 | Pending User | Sam Rivera | 8 |

With the full query, I expect **11 unresolved tickets, including 8 P1/P2 tickets**. One P2 ticket (`1010`) is unassigned. Ticket age is measured from a fixed reporting date, **1 November 2026**, so the output stays consistent; these are calendar days, **not** measured SLA breaches.

[Full backlog SQL](sql/cases/01_backlog.sql) · [All rows and notes](cases/01-ticket-backlog.md)

## 4. Look for repeated sign-in problems

I wanted to see whether the same users had raised more than one sign-in ticket during October. `GROUP BY` and `HAVING` helped me find repeat requesters before reading individual notes.

```sql
SELECT u.display_name, COUNT(*) AS sign_in_tickets
FROM sd_tickets t
JOIN sd_users u ON u.user_id = t.requester_id
WHERE t.category = 'Sign-in'
  AND t.created_on >= DATE '2026-10-01'
  AND t.created_on < DATE '2026-11-01'
GROUP BY u.display_name
HAVING COUNT(*) >= 2
ORDER BY sign_in_tickets DESC, u.display_name;
```

**Expected result**

| Name | Sign-in tickets |
|---|---:|
| Amira Patel | 3 |
| Daniel Wong | 2 |

Amira has several reports of sign-in prompts, including an MFA-loop ticket. I would look at timestamps and ticket events next, rather than assume three tickets all have the same root cause.

[Full sign-in SQL](sql/cases/02_signin.sql) · [Ticket history and notes](cases/02-recurring-sign-in.md)

## 5. Review devices that need a follow-up

I also checked for active devices with a stale check-in, non-encrypted status, or an inactive assigned user. The query uses `LEFT JOIN` so device records are not lost just because there is no matching assignee, and `CASE` to make each review flag readable.

```sql
SELECT d.asset_tag,
       NVL(u.display_name, '(unassigned)') AS assigned_to,
       d.encryption_status,
       d.last_check_in
FROM sd_devices d
LEFT JOIN sd_users u ON u.user_id = d.assigned_user_id
WHERE d.device_status = 'Active'
  AND (u.account_status = 'Inactive'
       OR d.encryption_status <> 'Encrypted'
       OR d.last_check_in < DATE '2026-10-20'
       OR d.last_check_in IS NULL)
ORDER BY d.asset_tag;
```

**Expected follow-up list**

| Asset | Assigned to | Reason to check |
|---|---|---|
| LT-0042 | Daniel Wong | Stale check-in |
| LT-0043 | Priya Shah | Encryption status |
| LT-0044 | Sofia Chen | Inactive owner; stale check-in |

The spare laptop `LT-0045` is unassigned but marked **In Stock**. That should not be treated as an active-device fault. These flags only identify database records to investigate; they do not verify the device's real BitLocker or MDM state.

[Full device SQL](sql/cases/03_devices.sql) · [All checks and output](cases/03-device-audit.md)

## 6. Check data integrity before making changes

Finally, I checked whether any tickets reference missing users. I also tested the difference between a *valid foreign key* and a ticket that still needs operational attention.

```sql
SELECT COUNT(*) AS tickets_without_requester
FROM sd_tickets t
WHERE NOT EXISTS (
    SELECT 1 FROM sd_users u
    WHERE u.user_id = t.requester_id
);
```

**Expected result**

| TICKETS_WITHOUT_REQUESTER |
|---:|
| 0 |

The seed data has no orphan requester references. It does, however, contain ticket `1010`, which is **unassigned**. That is allowed by the nullable technician field, even though someone should review the queue. I also prepared a separate `SAVEPOINT` / `ROLLBACK TO` exercise to test a change safely in one session; it is not part of the default setup.

[Full integrity checks](sql/cases/04_integrity.sql) · [Integrity case and expected results](cases/04-data-integrity.md) · [Optional rollback exercise](sql/optional/transaction_rollback.sql)

## Running the lab

Use **Oracle APEX → SQL Workshop → SQL Scripts**, SQLcl, or SQL*Plus with a **personal training schema** (not `SYS`, `SYSTEM`, or production):

1. Run [`01_schema.sql`](sql/01_schema.sql), then [`02_sample_data.sql`](sql/02_sample_data.sql), then [`03_views.sql`](sql/03_views.sql).
2. Run [`04_smoke_checks.sql`](sql/04_smoke_checks.sql), followed by the four case scripts in [`sql/cases/`](sql/cases/).
3. Compare your results with the expected tables here and the longer case notes. Oracle may format dates differently based on session settings.

The scripts assume a clean lab schema. Running the inserts twice will cause primary-key errors. [`99_reset_lab.sql`](sql/99_reset_lab.sql) removes **only the lab objects**, but deletes their data; inspect it before running. The transaction example needs a single session with autocommit off and is better suited to SQLcl/SQL*Plus than separate APEX requests.

I am keeping this as a text-first project: the SQL is readable and reusable, while the detailed outputs live in the case files. A small amount of genuine Oracle execution evidence can be added after I run it in my own environment.
