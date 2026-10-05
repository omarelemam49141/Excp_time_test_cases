# System Work Schedule Admin Settings JSON Transfer API - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/system-work-schedule/export-admin-settings`, `POST /api/system-work-schedule/import-admin-settings`
- Related code: `src/Excp.HRSystem.Application/Services/SystemWorkSchedule/SystemWorkScheduleAppService.cs`
- Related docs: `docs/backend/technical/overtime-gap-home-vs-site.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Export combined admin settings payload
- Import combined payload and replace existing data
- Validate authorization and payload validation paths


## Test cases

### General

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SCHED-ANG-ADMIN-001 | Verify Export combined admin settings payload | Main | - | 1. Export combined admin settings payload | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-SCHED-ANG-ADMIN-002 | Verify Import combined payload and replace existing data | Main | - | 1. Import combined payload and replace existing data | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-SCHED-ANG-ADMIN-003 | Verify Validate authorization and payload validation paths | Main | - | 1. Validate authorization and payload validation paths | The result matches the scenario description when you follow the actions in the product. | - |

### Wave 1 — Home vs site overtime gap

| ID | Key | Case | Type | Steps | Expected |
|----|-----|------|------|-------|----------|
| TC-04 | EXCP-SCHED-OT-JSON-001 | Verify Export admin settings JSON includes `overtimeGapMinutesFromHome` on defaults and rules. | Main | 1. Set site gap `30` and home gap `15` via admin API or UI.<br>2. `POST /api/system-work-schedule/export-admin-settings`. | 1. Response `defaults.overtimeGapMinutes` is `30`.<br>2. Response `defaults.overtimeGapMinutesFromHome` is `15`. |
| TC-05 | EXCP-SCHED-OT-JSON-002 | Verify Import without `overtimeGapMinutesFromHome` copies site gap into home column. | Edge | 1. Export current settings.<br>2. Remove the `overtimeGapMinutesFromHome` key from `defaults` in JSON.<br>3. `POST /api/system-work-schedule/import-admin-settings`.<br>4. Export again. | 1. Import returns success.<br>2. New export shows `overtimeGapMinutesFromHome` equal to `overtimeGapMinutes`. |
| TC-06 | EXCP-SCHED-OT-JSON-003 | Verify Import preserves explicit `overtimeGapMinutesFromHome: 0` when site gap is greater than zero. | Edge | 1. Export settings with `overtimeGapMinutes: 30` and `overtimeGapMinutesFromHome: 0`.<br>2. `POST /api/system-work-schedule/import-admin-settings` with that JSON.<br>3. Export again. | 1. Import returns success.<br>2. New export shows `overtimeGapMinutes: 30`.<br>3. New export shows `overtimeGapMinutesFromHome: 0`. |
