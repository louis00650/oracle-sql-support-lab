# Case 04 — Data integrity and a controlled change

**Scenario**  
Before troubleshooting an application error, it is useful to know whether ticket and asset records point to valid parent records. This case checks for orphan references, duplicate asset tags, and incomplete resolution data. It also includes an optional rollback exercise for a disposable training schema.

**Input**  
Read-only checks are in [`sql/cases/04_integrity.sql`](../sql/cases/04_integrity.sql). Keys and constraints are created in [`sql/01_schema.sql`](../sql/01_schema.sql).

### Read-only validation

```sql
SELECT COUNT(*) AS tickets_without_requester
FROM sd_tickets t
WHERE NOT EXISTS (
    SELECT 1
    FROM sd_users u
    WHERE u.user_id = t.requester_id
);
```

### Expected output from sample data

| Check | Expected count |
|---|---:|
| Tickets without a matching requester | 0 |
| Assigned devices without a matching owner | 0 |
| Duplicate asset tags | 0 |
| Resolved or closed tickets missing a resolution date | 0 |

These zeroes are expected because the sample data was deliberately seeded with valid references and the schema includes PK/FK/UNIQUE/CHECK constraints. **A zero is not evidence that these checks have been run against a production system.**

Another query highlights ticket `1010` as unassigned. This is allowed by the nullable technician foreign key and may be an operational problem rather than a referential-integrity problem.

### Failure modes worth understanding

The SQL file includes **commented-out negative tests** to show how Oracle should reject invalid data. They are not part of the default run:

| Example | Expected Oracle error | Why |
|---|---|---|
| Ticket references missing user | `ORA-02291` | Parent key not found |
| Device reuses `LT-0041` asset tag | `ORA-00001` | Unique constraint violated |
| Ticket has priority `P9` | `ORA-02290` | Check constraint violated |

### Optional transaction exercise

[`sql/optional/transaction_rollback.sql`](../sql/optional/transaction_rollback.sql) demonstrates:

```sql
SAVEPOINT before_test;
UPDATE sd_tickets
SET status = 'In Progress'
WHERE ticket_id = 1001;

ROLLBACK TO before_test;
```

Expected status for ticket `1001`: **Open → In Progress (uncommitted) → Open**. Run the entire sequence in one SQL*Plus/SQLcl session with autocommit off. APEX SQL Commands may auto-commit between submissions, so it is not suitable for this particular rollback demonstration.

### Notes

Foreign keys protect relationships, but not every support-quality issue. An unassigned ticket is allowed by the schema; a device assigned to an inactive user still has a *valid* foreign key. Those conditions need separate business-rule checks.

Dropping a foreign key constraint to silence an error would remove the protection rather than solve the data problem. On a real application, changes would require approval, a documented rollback plan, and environment-specific checks.

**Validation state:** Expected outputs, not a claim of live Oracle execution.
