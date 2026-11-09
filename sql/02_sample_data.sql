-- Synthetic test data. Run once, after 01_schema.sql, in a clean schema.
-- Identifiers and dates are fixed to make all cases reproducible.

INSERT INTO sd_users VALUES (101, 'Amira Patel', 'Finance',    'amira@example.invalid',  'Active');
INSERT INTO sd_users VALUES (102, 'Daniel Wong', 'Operations', 'daniel@example.invalid', 'Active');
INSERT INTO sd_users VALUES (103, 'Priya Shah',  'HR',         'priya@example.invalid',  'Active');
INSERT INTO sd_users VALUES (104, 'Leo Chan',    'Sales',      'leo@example.invalid',    'Active');
INSERT INTO sd_users VALUES (105, 'Sofia Chen',  'Operations', 'sofia@example.invalid',  'Inactive');
INSERT INTO sd_users VALUES (106, 'Noah Brooks', 'Finance',    'noah@example.invalid',   'Active');
INSERT INTO sd_users VALUES (107, 'Mia Tran',    'IT',         'mia@example.invalid',    'Active');
INSERT INTO sd_users VALUES (108, 'Eli Morgan',  'Sales',      'eli@example.invalid',    'Active');

INSERT INTO sd_technicians VALUES (201, 'Jordan Lee', 'Service Desk');
INSERT INTO sd_technicians VALUES (202, 'Sam Rivera', 'Service Desk');
INSERT INTO sd_technicians VALUES (203, 'Casey Ng', 'Endpoint Team');

INSERT INTO sd_devices VALUES (301, 'LT-0041', 'Laptop',  101, 'Active',   'Encrypted',     DATE '2026-10-30');
INSERT INTO sd_devices VALUES (302, 'LT-0042', 'Laptop',  102, 'Active',   'Encrypted',     DATE '2026-10-14');
INSERT INTO sd_devices VALUES (303, 'LT-0043', 'Laptop',  103, 'Active',   'Not Encrypted', DATE '2026-10-29');
INSERT INTO sd_devices VALUES (304, 'LT-0044', 'Laptop',  105, 'Active',   'Encrypted',     DATE '2026-10-15');
INSERT INTO sd_devices VALUES (305, 'LT-0045', 'Laptop', NULL, 'In Stock', 'Unknown',       DATE '2026-10-01');
INSERT INTO sd_devices VALUES (306, 'DT-0012', 'Desktop', 104, 'Active',   'Encrypted',     DATE '2026-10-28');
INSERT INTO sd_devices VALUES (307, 'LT-0046', 'Laptop',  106, 'Active',   'Encrypted',     DATE '2026-10-30');
INSERT INTO sd_devices VALUES (308, 'LT-0047', 'Laptop',  107, 'Active',   'Encrypted',     DATE '2026-10-30');
INSERT INTO sd_devices VALUES (309, 'LT-0048', 'Laptop',  108, 'Active',   'Encrypted',     DATE '2026-10-23');

-- Columns listed explicitly: requester, technician, device, category, priority,
-- status, creation/resolution date, and a short incident summary.
INSERT INTO sd_tickets VALUES (1001,101,201,301,'Sign-in',     'P2','Open',        DATE '2026-10-23',NULL,'Repeated sign-in prompt on laptop');
INSERT INTO sd_tickets VALUES (1002,101,202,301,'Sign-in',     'P3','Closed',      DATE '2026-10-20',DATE '2026-10-21','Password reset did not persist');
INSERT INTO sd_tickets VALUES (1003,101,201,301,'Sign-in',     'P2','In Progress', DATE '2026-10-28',NULL,'MFA sign-in loop reported again');
INSERT INTO sd_tickets VALUES (1004,102,202,302,'Network',     'P2','Open',        DATE '2026-10-25',NULL,'VPN disconnects during morning login');
INSERT INTO sd_tickets VALUES (1005,103,203,303,'Endpoint',    'P2','In Progress', DATE '2026-10-30',NULL,'Endpoint encryption not reporting');
INSERT INTO sd_tickets VALUES (1006,104,201,306,'Application', 'P3','Closed',      DATE '2026-10-22',DATE '2026-10-23','Web application export error');
INSERT INTO sd_tickets VALUES (1007,102,201,302,'Sign-in',     'P3','Pending User',DATE '2026-10-26',NULL,'Account unlock request');
INSERT INTO sd_tickets VALUES (1008,102,201,302,'Sign-in',     'P3','Resolved',    DATE '2026-10-29',DATE '2026-10-29','Sign-in issue temporarily resolved');
INSERT INTO sd_tickets VALUES (1009,105,203,304,'Endpoint',    'P1','Open',        DATE '2026-10-21',NULL,'Device still assigned to departed employee');
INSERT INTO sd_tickets VALUES (1010,106,NULL,307,'Application','P2','Open',        DATE '2026-10-27',NULL,'Portal permission mismatch');
INSERT INTO sd_tickets VALUES (1011,107,203,308,'Endpoint',    'P4','Closed',      DATE '2026-10-18',DATE '2026-10-19','Laptop update verified');
INSERT INTO sd_tickets VALUES (1012,108,202,309,'Network',     'P3','Open',        DATE '2026-10-31',NULL,'Intermittent wireless access');
INSERT INTO sd_tickets VALUES (1013,103,201,303,'Sign-in',     'P3','Closed',      DATE '2026-10-22',DATE '2026-10-23','Initial sign-in troubleshooting');
INSERT INTO sd_tickets VALUES (1014,104,202,306,'Application','P2','Pending User',DATE '2026-10-24',NULL,'User awaiting ERP test export');
INSERT INTO sd_tickets VALUES (1015,106,203,307,'Sign-in',     'P4','Open',        DATE '2026-10-30',NULL,'SSO intermittent in browser');
INSERT INTO sd_tickets VALUES (1016,107,201,308,'Application','P2','Resolved',    DATE '2026-10-19',DATE '2026-10-20','Application settings corrected');
INSERT INTO sd_tickets VALUES (1017,108,202,309,'Sign-in',     'P2','Open',        DATE '2026-10-30',NULL,'New login prompt after profile change');

INSERT INTO sd_ticket_events VALUES (2001,1001,DATE '2026-10-23','Investigation','Checked sign-in timestamp and recorded prompt behavior.');
INSERT INTO sd_ticket_events VALUES (2002,1002,DATE '2026-10-21','Update','Password change confirmed; ticket closed.');
INSERT INTO sd_ticket_events VALUES (2003,1003,DATE '2026-10-28','Escalation','MFA loop reproduced; escalated with timestamps.');
INSERT INTO sd_ticket_events VALUES (2004,1004,DATE '2026-10-26','Investigation','VPN disconnect times collected for review.');
INSERT INTO sd_ticket_events VALUES (2005,1005,DATE '2026-10-30','Investigation','Encryption status requires device-side check.');
INSERT INTO sd_ticket_events VALUES (2006,1007,DATE '2026-10-27','User Reply','Waiting for user to retest sign-in.');
INSERT INTO sd_ticket_events VALUES (2007,1009,DATE '2026-10-22','Escalation','Inactive owner and active device flagged for review.');
INSERT INTO sd_ticket_events VALUES (2008,1010,DATE '2026-10-28','Update','Ticket remains unassigned pending triage.');
INSERT INTO sd_ticket_events VALUES (2009,1014,DATE '2026-10-26','User Reply','Requested sample export to reproduce application issue.');
INSERT INTO sd_ticket_events VALUES (2010,1017,DATE '2026-10-31','Investigation','Captured new sign-in prompt for follow-up.');

COMMIT;
