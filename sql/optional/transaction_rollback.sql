-- Optional transaction demonstration for SQL*Plus or SQLcl, NOT APEX SQL Commands.
-- Run in one session with autocommit OFF, in a disposable lab schema.
-- Never run any of these statements on real tickets.
SET AUTOCOMMIT OFF

-- Expected: ticket 1001 status = Open.
SELECT ticket_id, status FROM sd_tickets WHERE ticket_id = 1001;

SAVEPOINT before_test;
UPDATE sd_tickets SET status = 'In Progress' WHERE ticket_id = 1001;
-- Expected now: In Progress (uncommitted in this session).
SELECT ticket_id, status FROM sd_tickets WHERE ticket_id = 1001;

ROLLBACK TO before_test;
-- Expected again: Open.
SELECT ticket_id, status FROM sd_tickets WHERE ticket_id = 1001;

-- Optional explicit rollback to finish with no uncommitted changes.
ROLLBACK;
