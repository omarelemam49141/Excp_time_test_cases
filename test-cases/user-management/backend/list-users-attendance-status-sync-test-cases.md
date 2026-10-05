# List users — attendance status sync (backend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/custom-account/get-users-list` (or equivalent get-users-list endpoint)
- Automation: `test/Excp.HRSystem.Application.Tests/Attendance/AttendanceUserStatusResolverTests.cs`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs`, `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs`
- Related docs: `docs/backend/technical/attendance-status-sync-from-record.md`

## Scope

- Get-users-list derives status from today's attendance record when the user flag is stale.
- Corrected status is returned in the API and persisted on the user row.

## Test scenarios

- Stale `EndShift` with active record (start, no end) → response shows `In`.
- Correction persists after refresh.

## Test cases

### List API status correction

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-USER-LIST-STATUS-001 | Verify stale EndShift is corrected to In when record has no end time. | Main | Employee has today's record: start set, end null. User flag is `EndShift`. | 1. POST get-users-list including that user.<br>2. Read `attendanceStatus`, `todayStartTime`, `todayEndTime`.<br>3. Call get-users-list again. | 1. `attendanceStatus` is `In`.<br>2. `todayEndTime` is empty/null in the response.<br>3. Second call still shows `In` (persisted). | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs` |
| TC-02 | EXCP-USER-LIST-STATUS-002 | Verify completed day shows EndShift when both times exist. | Regression | Record has start and end; user flag matches. | 1. POST get-users-list for that user. | `attendanceStatus` is `EndShift`. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs` |
