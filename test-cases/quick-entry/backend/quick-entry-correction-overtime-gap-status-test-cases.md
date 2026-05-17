# Quick Entry correction overtime gap status - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/attendance-record/Apply-quick-entry-range-correction`, `POST /api/attendance-record/Bulk-apply-attendance-changes`, `POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status`
- Related code: `src/Excp.HRSystem.Application/Services/AttendanceBulk/AttendanceBulkQuickEntryAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceRecords/AttendanceRecordAPIController.cs`, `src/Excp.HRSystem.EntityFrameworkCore/Scripts/FixAttendanceOver8Hours_CreateOvertime_ByDateRange.sql`, `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Record App Contracts/Dtos/APIs/BulkApplyAttendanceChangesInputDto.cs`
- Related docs: `docs/backend/technical/quick-entry-correction-overtime-gap-preservation.md`, `docs/backend/technical/quick-entry-correction-diff-cumulative-totals.md`

## Scope

Covers `POST /api/attendance-record/Apply-quick-entry-range-correction` and `POST /api/attendance-record/Bulk-apply-attendance-changes` for days where existing overtime is preserved, attendance Save runs automatic correction, and the total overtime remains within the configured overtime gap.

## Test pages

- `POST /api/attendance-record/Apply-quick-entry-range-correction`
- `POST /api/attendance-record/Bulk-apply-attendance-changes`
- `POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status`

## Test scenarios

- The correction applies the configured overtime gap to preserved overtime entries, not only newly created entries.
- Preserved overtime within the configured gap is no longer pending after correction.
- A one-day correction can succeed when the only required change is overtime/request status synchronization.
- Quick Entry bulk save recalculates overtime status after overtime-only edits.
- Quick Entry bulk save succeeds when the employee fills normal missing attendance days and automatic correction has nothing to change.
- The leader pending overtime API does not return within-gap overtime after correction.
- Overtime that exceeds the configured gap remains pending and is still visible to the correct team lead.

## Test cases

### Preserved overtime within gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-HRS-CORRECTION-001 | Verify preserved overtime within the configured gap is finalized by one-day quick-entry correction | Main | The work schedule overtime gap is `"30"` minutes.<br>An employee reports to a known team lead.<br>On `"2026-03-29"`, the employee has attendance from `"09:00"` to `"17:00"`.<br>On `"2026-03-29"`, the employee has an existing pending overtime entry from `"17:20"` to `"17:30"`.<br>The existing overtime has a linked pending request before correction. | 1. Call `"POST /api/attendance-record/Apply-quick-entry-range-correction"` for the employee with `"from"` set to `"2026-03-29"` and `"to"` set to `"2026-03-29"`.<br>2. Reload the employee overtime for `"2026-03-29"`.<br>3. Read the linked request status for the preserved overtime. | 1. The correction returns success.<br>2. The day still shows the preserved overtime from `"17:20"` to `"17:30"`.<br>3. The total overtime for the day is within `"30"` minutes.<br>4. The preserved overtime status is `"WithinOvertimeGap"`.<br>5. The linked request is not `"Pending"`. | From: `"2026-03-29"`<br>To: `"2026-03-29"`<br>Overtime gap: `"30"` minutes |
| TC-02 | EXCP-QE-HRS-CORRECTION-002 | Verify corrected within-gap overtime is not returned by the leader pending overtime API | Regression | TC-01 has been completed.<br>The team lead has a valid access token.<br>The same team lead has at least one other real pending overtime entry for comparison. | 1. Call `"POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status"` with the team lead token.<br>2. Send `"overTimeStatus"` as `"Pending"` with normal paging fields.<br>3. Read the returned overtime entries. | 1. The response is successful.<br>2. The corrected `"2026-03-29"` within-gap overtime is not included in the pending results.<br>3. Other real pending overtime for the team lead is still included when it matches the normal filters. | overTimeStatus: `"Pending"`<br>pageNumber: `"1"`<br>pageSize: `"10"` |

### Overtime above gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-QE-HRS-CORRECTION-003 | Verify Quick Entry bulk save marks overtime as pending when the edited duration exceeds the configured gap | Edge | The work schedule overtime gap is `"30"` minutes.<br>An employee reports to a known team lead.<br>On `"2026-02-01"`, the employee has attendance from `"09:00"` to `"17:00"`.<br>On `"2026-02-01"`, the employee has an existing overtime entry from `"17:20"` to `"17:30"` with status `"WithinOvertimeGap"`. | 1. Call `"POST /api/attendance-record/Bulk-apply-attendance-changes"` with an empty `"attendanceDays"` list and one `"overtimeUpdates"` item for the existing overtime.<br>2. Set the overtime update to start at `"17:20:00"` and end at `"17:51:00"`.<br>3. Call `"POST /api/attendance-record/Get-bulk-details-in-range"` with `"from"` and `"to"` set to `"2026-02-01"`.<br>4. Read the overtime status in the response. | 1. The bulk save returns success.<br>2. The day total overtime is greater than `"30"` minutes.<br>3. The edited overtime for `"2026-02-01"` is returned with status `"Pending"`.<br>4. The team lead pending overtime API includes the edited pending overtime when normal leader filters match. | From: `"2026-02-01"`<br>To: `"2026-02-01"`<br>Start: `"17:20:00"`<br>End: `"17:51:00"`<br>Overtime gap: `"30"` minutes |

### Normal attendance save

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-QE-HRS-CORRECTION-004 | Verify Quick Entry bulk save succeeds when normal missing attendance days need no correction | Regression | The employee is signed in with their own account.<br>The employee is not using an admin employee field.<br>The employee has missing attendance for `"2026-04-09"`, `"2026-04-12"`, `"2026-04-13"`, `"2026-04-14"`, `"2026-04-15"`, and `"2026-04-16"`. | 1. Call `"POST /api/attendance-record/Bulk-apply-attendance-changes"` without `"targetUserId"`.<br>2. Send `"attendanceDays"` for the missing dates with normal work times.<br>3. Send empty `"overtimeUpdates"` and empty `"overtimeRequests"`.<br>4. Call `"POST /api/attendance-record/Get-bulk-details-in-range"` for `"2026-04-09"` to `"2026-04-16"`. | 1. The bulk save returns success.<br>2. The response does not include the message `"No days in the selected range require correction."`.<br>3. The response does not return `"409"`.<br>4. The reloaded range shows the saved attendance times for each submitted date.<br>5. No new overtime entry is shown for those normal work days. | From: `"2026-04-09"`<br>To: `"2026-04-16"`<br>Start: `"09:00:00"`<br>End: `"17:00:00"`<br>First day start: `"09:36:00" |
