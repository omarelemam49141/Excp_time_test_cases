# Overtime ask-after-gap settings (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/system-work-schedule/save-admin-bundle`, `POST /api/AttendanceRecord/Get-shift-and-reminder-config`
- Related code: `src/Excp.HRSystem.Application/Services/SystemWorkSchedule/SystemWorkScheduleAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceRecords/AttendanceRecordAPIController.cs`, `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkScheduleSnapshot.cs`
- Related docs: `docs/backend/technical/overtime-ask-after-gap-settings.md`
- Automation: `test/Excp.HRSystem.Application.Tests/WorkSchedule/OvertimeAskAfterGapSettingsTests.cs`

## Scope

- Persist `overtimeAskAfterGapMinutes` on defaults and date-rule overrides.
- Expose value on `Get-shift-and-reminder-config` for the employee app.

## Test scenarios

- Save and reload admin defaults
- Shift config DTO includes ask-after value
- Date rule override wins for matching dates

## Test cases

### Wave 1 — Settings persistence

| ID | Key | Case | Type | Steps | Expected |
|----|-----|------|------|-------|----------|
| TC-01 | EXCP-SCHED-OT-ASK-API-001 | Verify admin save persists `overtimeAskAfterGapMinutes` on defaults. | Main | 1. Sign in as Admin.<br>2. Save admin bundle with `defaults.overtimeAskAfterGapMinutes` = `15`.<br>3. Load admin bundle again. | 1. Reloaded defaults show `15`. |
| TC-02 | EXCP-SCHED-OT-ASK-API-002 | Verify `Get-shift-and-reminder-config` returns `overtimeAskAfterGapMinutes`. | Main | 1. Set defaults `overtimeAskAfterGapMinutes` to `15` and save.<br>2. Call `POST Get-shift-and-reminder-config` for today. | 1. Response `data.overtimeAskAfterGapMinutes` is `15`. |
| TC-03 | EXCP-SCHED-OT-ASK-API-003 | Verify date rule `overrideOvertimeAskAfterGapMinutes` overrides defaults for matching date. | Edge | 1. Set defaults ask-after to `0`.<br>2. Add a specific-date rule with `overrideOvertimeAskAfterGapMinutes` = `20` for today.<br>3. Call `Get-shift-and-reminder-config` for today. | 1. Response `data.overtimeAskAfterGapMinutes` is `20`. |
