# Data model

The dataset represents a deliberately small internal IT support environment. All names, devices, and tickets are fictional.

```text
SD_USERS (user_id PK)
   |                    SD_TECHNICIANS (tech_id PK)
   | requester_id             | assigned_tech_id (nullable)
   +------------- SD_TICKETS -+
   |                 |     |
   | assigned_user_id|     +--- SD_TICKET_EVENTS (ticket_id FK)
   |                 |
SD_DEVICES (device_id PK) --- device_id (nullable)
```

| Table | Main columns | Reason |
|---|---|---|
| `SD_USERS` | `user_id`, `display_name`, `department`, `account_status` | Identify requester and account lifecycle |
| `SD_TECHNICIANS` | `tech_id`, `tech_name`, `team_name` | Track assignee; NULL ticket assignment is permitted |
| `SD_DEVICES` | `asset_tag`, `assigned_user_id`, `encryption_status`, `last_check_in` | Find ownership and endpoint follow-up issues |
| `SD_TICKETS` | `requester_id`, `assigned_tech_id`, `category`, `priority`, `status`, dates | Backlog and recurring-issue analysis |
| `SD_TICKET_EVENTS` | `ticket_id`, `event_on`, `event_note` | Small record of work updates and escalations |

### Relationships and deliberate decisions

- A user can open multiple tickets. Every ticket must reference an existing user.
- A technician can own multiple tickets; a ticket can remain unassigned.
- A device can be unassigned (for example, a spare laptop in stock). This is not automatically an error.
- `asset_tag` and `email` must be unique. The supplied data never uses real identities.
- Ticket category, priority, and status are restricted to a small set of accepted values.
- A ticket with `Resolved` or `Closed` status needs a `resolved_on` value. Resolution cannot precede creation.
- There is intentionally **no cascade deletion** on users/devices/tickets. Historical support data should not disappear automatically if a user record is removed.
- No index tuning, triggers, procedures, or automation is implied. Those would be separate exercises.

### Reference dates

All sample ticket dates are in October 2026; reports use `DATE '2026-11-01'` as the fixed reporting point. Changing that date changes `age_days` and stale-device results. The sample does not model business calendars, holidays, response SLAs, or time-zone normalization.
