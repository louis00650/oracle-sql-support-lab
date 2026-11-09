-- Run only in a personal training schema. Objects use the SD_ prefix.
-- Five tables; create parents before dependent tables.

CREATE TABLE sd_users (
    user_id          NUMBER(6) CONSTRAINT sd_users_pk PRIMARY KEY,
    display_name     VARCHAR2(80 CHAR) NOT NULL,
    department       VARCHAR2(40 CHAR) NOT NULL,
    email            VARCHAR2(120 CHAR) NOT NULL,
    account_status   VARCHAR2(10 CHAR) NOT NULL,
    CONSTRAINT sd_users_email_uk UNIQUE (email),
    CONSTRAINT sd_users_status_ck CHECK (account_status IN ('Active', 'Inactive'))
);

CREATE TABLE sd_technicians (
    tech_id          NUMBER(6) CONSTRAINT sd_tech_pk PRIMARY KEY,
    tech_name        VARCHAR2(80 CHAR) NOT NULL,
    team_name        VARCHAR2(40 CHAR) NOT NULL
);

CREATE TABLE sd_devices (
    device_id         NUMBER(6) CONSTRAINT sd_devices_pk PRIMARY KEY,
    asset_tag         VARCHAR2(20 CHAR) NOT NULL,
    device_type       VARCHAR2(20 CHAR) NOT NULL,
    assigned_user_id  NUMBER(6),
    device_status     VARCHAR2(20 CHAR) NOT NULL,
    encryption_status VARCHAR2(20 CHAR) NOT NULL,
    last_check_in     DATE,
    CONSTRAINT sd_devices_asset_uk UNIQUE (asset_tag),
    CONSTRAINT sd_devices_user_fk FOREIGN KEY (assigned_user_id)
        REFERENCES sd_users (user_id),
    CONSTRAINT sd_devices_state_ck CHECK (device_status IN ('Active', 'In Stock', 'Retired')),
    CONSTRAINT sd_devices_encrypt_ck CHECK (encryption_status IN ('Encrypted', 'Not Encrypted', 'Unknown'))
);

CREATE TABLE sd_tickets (
    ticket_id        NUMBER(6) CONSTRAINT sd_tickets_pk PRIMARY KEY,
    requester_id     NUMBER(6) NOT NULL,
    assigned_tech_id NUMBER(6),
    device_id        NUMBER(6),
    category         VARCHAR2(20 CHAR) NOT NULL,
    priority         VARCHAR2(2 CHAR) NOT NULL,
    status           VARCHAR2(20 CHAR) NOT NULL,
    created_on       DATE NOT NULL,
    resolved_on      DATE,
    summary          VARCHAR2(200 CHAR) NOT NULL,
    CONSTRAINT sd_tickets_requester_fk FOREIGN KEY (requester_id) REFERENCES sd_users (user_id),
    CONSTRAINT sd_tickets_tech_fk FOREIGN KEY (assigned_tech_id) REFERENCES sd_technicians (tech_id),
    CONSTRAINT sd_tickets_device_fk FOREIGN KEY (device_id) REFERENCES sd_devices (device_id),
    CONSTRAINT sd_tickets_category_ck CHECK (category IN ('Sign-in', 'Endpoint', 'Network', 'Application')),
    CONSTRAINT sd_tickets_priority_ck CHECK (priority IN ('P1', 'P2', 'P3', 'P4')),
    CONSTRAINT sd_tickets_status_ck CHECK (status IN ('Open', 'In Progress', 'Pending User', 'Resolved', 'Closed')),
    CONSTRAINT sd_tickets_resolution_ck CHECK (status NOT IN ('Resolved', 'Closed') OR resolved_on IS NOT NULL),
    CONSTRAINT sd_tickets_dates_ck CHECK (resolved_on IS NULL OR resolved_on >= created_on)
);

CREATE TABLE sd_ticket_events (
    event_id    NUMBER(6) CONSTRAINT sd_events_pk PRIMARY KEY,
    ticket_id   NUMBER(6) NOT NULL,
    event_on    DATE NOT NULL,
    event_type  VARCHAR2(20 CHAR) NOT NULL,
    event_note  VARCHAR2(200 CHAR) NOT NULL,
    CONSTRAINT sd_events_ticket_fk FOREIGN KEY (ticket_id) REFERENCES sd_tickets (ticket_id),
    CONSTRAINT sd_events_type_ck CHECK (event_type IN ('Update', 'Investigation', 'Escalation', 'User Reply'))
);
