# Modify attendance — user status sync (backend)

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/attendance-record/Update-attendance-record-with-breaks`
- Automation: `test/Excp.HRSystem.Application.Tests/Attendance/AttendanceUserStatusResolverTests.cs`
- Related code: `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs`, `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs`
- Related docs: `docs/backend/technical/attendance-status-sync-from-record.md`

## Scope

- User `AttendanceStatus` flag updates after modify-attendance saves times/breaks.
- Status derivation from record start, end, and open breaks.

## Test scenarios

- Start without end → `In`.
- Start and end → `EndShift`.
- No times → `Out`.
- Open break while working → `Break`.

## Test cases

### Status resolver

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-MOD-STATUS-001 | Verify start without end maps to In. | Main | - | 1. Run xUnit `AttendanceUserStatusResolverTests.FromRecord_start_without_end_returns_In`. | Status is `In`. | `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs` |
| TC-02 | EXCP-ATT-MOD-STATUS-002 | Verify start and end map to EndShift. | Main | - | 1. Run xUnit `FromRecord_start_and_end_returns_EndShift`. | Status is `EndShift`. | `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs` |
| TC-03 | EXCP-ATT-MOD-STATUS-003 | Verify empty record maps to Out. | Edge | - | 1. Run xUnit `FromRecord_no_times_returns_Out`. | Status is `Out`. | `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs` |
| TC-04 | EXCP-ATT-MOD-STATUS-004 | Verify open break maps to Break. | Edge | Record has start, no end, one break with null end. | 1. Run xUnit `FromRecord_open_break_returns_Break`. | Status is `Break`. | `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs` |

### Update endpoint

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-05 | EXCP-ATT-MOD-STATUS-005 | Verify clearing end time via update sets user status to In. | Main | User ended work earlier (`EndShift`). Today's record has start and null end after POST. | 1. POST `Update-attendance-record-with-breaks` with start time and `endTime` null.<br>2. Query user `AttendanceStatus` or call get-users-list. | 1. HTTP 200.<br>2. User status is `In`. | `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs` |
