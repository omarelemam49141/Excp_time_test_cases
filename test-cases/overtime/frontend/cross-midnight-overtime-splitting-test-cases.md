# Cross-Midnight Overtime Splitting - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `frontend`
- Routes: `(Add the primary screen route or API path here.)`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Home timer end after midnight | Main | Overtime is persisted as two day-bounded segments |
- | All Attendance request with cross-day range | Main | Request submits split segments with correct dates/times |
- | All Attendance modify with cross-day range | Main | Existing overtime updates first segment and creates remaining segment requests |
- | Quick Entry new overtime with cross-day range | Main | Save payload contains split per-day overtime requests |
- | Quick Entry pending overtime edit with cross-day range | Edge | Save payload updates base overtime and creates extra day requests |
- | Break crossing midnight | Edge | Break is split into two day-bounded break rows in payload |
- | Invalid datetime range | Edge | Submit/save is blocked when end is not after start |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-CROSS-MIDNIGHT-001 | Verify Home end overtime across midnight | Main | - | 1. Start overtime at `2026-04-28 18:00`.<br>2. End overtime at `2026-04-29 00:50`.<br>3. Verify backend receives complete range and resulting records are:<br>4. `2026-04-28 18:00 -> 24:00`<br>5. `2026-04-29 00:00 -> 00:50` | - | - |
| TC-02 | EXCP-OT-CROSS-MIDNIGHT-002 | Verify Request overtime dialog cross-day split | Main | - | 1. Open request overtime dialog.<br>2. Set start date/time `2026-04-28 18:00`, end date/time `2026-04-29 00:50`.<br>3. Submit.<br>4. Verify two overtime requests are sent, one for each date. | - | - |
| TC-03 | EXCP-OT-CROSS-MIDNIGHT-003 | Verify Modify overtime cross-day split | Main | - | 1. Open modify overtime for a pending item on `2026-04-28`.<br>2. Set end date to `2026-04-29` and end time `00:50`.<br>3. Save.<br>4. Verify:<br>5. Existing overtime id is updated with first segment.<br>6. Additional request is created for next day segment. | - | - |
| TC-04 | EXCP-OT-CROSS-MIDNIGHT-004 | Verify Quick Entry new overtime cross-day split | Main | - | 1. Add new overtime on row `2026-04-28`.<br>2. Set `startDate=2026-04-28`, `startTime=18:00`, `endDate=2026-04-29`, `endTime=00:50`.<br>3. Save quick entry.<br>4. Verify bulk request contains split overtime requests by date. | - | - |
| TC-05 | EXCP-OT-CROSS-MIDNIGHT-005 | Verify Break split across midnight | Main | - | 1. Add overtime `23:30 -> 00:30`.<br>2. Add break `23:50 -> 00:10`.<br>3. Save.<br>4. Verify break payload is split:<br>5. First day `23:50 -> 24:00`<br>6. Next day `00:00 -> 00:10` | - | - |
| TC-06 | EXCP-OT-CROSS-MIDNIGHT-006 | Verify Invalid end before start | Edge | - | 1. Set start `2026-04-29 01:00`, end `2026-04-29 00:50.<br>2. Submit/save.<br>3. Verify no API request is sent and form stays invalid. | - | - |
