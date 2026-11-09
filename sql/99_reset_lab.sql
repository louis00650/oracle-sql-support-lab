-- DESTRUCTIVE: removes every SD_ lab view/table and all its sample data.
-- Inspect object names before running. Never use on shared/production schemas.
DROP VIEW sd_signin_summary;
DROP VIEW sd_open_ticket_queue;
DROP TABLE sd_ticket_events;
DROP TABLE sd_tickets;
DROP TABLE sd_devices;
DROP TABLE sd_technicians;
DROP TABLE sd_users;
