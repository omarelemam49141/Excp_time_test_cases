# List users — attendance status sync (backend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/custom-account/get-users-list` (or equivalent get-users-list endpoint)
- Automation: `test/Excp.HRSystem.Application.Tests/Attendance/AttendanceUserStatusResolverTests.cs`, `test/Excp.HRSystem.Application.Tests/Attendance/AttendanceListPlatformResolverTests.cs`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs`, `src/Excp.HRSystem.Application/Attendance/AttendanceUserStatusResolver.cs`, `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs`, `src/Excp.HRSystem.Application/Services/Account/CustomAccountAppService.cs`
- Related docs: `docs/backend/technical/attendance-status-sync-from-record.md`

## Scope

- Get-users-list derives status from today's attendance record when the user flag is stale.
- Corrected status is returned in the API and persisted on the user row.
- Start/end platforms are resolved day-aware: only today's attendance entry can produce a platform, the value captured on the entry wins, and the saved start/end-work platform is the fallback when the entry does not record where the action came from.
- Leader callers are always scoped to their own team, whatever list parameters the client sends.

## Test scenarios

- Stale `EndShift` with active record (start, no end) → response shows `In`.
- Correction persists after refresh.
- No start or no end today → no platform is returned for that side; an end with no attributable source stays empty (the UI shows "Platform unavailable").
- A leader asking for another team (or for everyone) still receives only their own team.

## Test cases

### List API status correction

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-USER-LIST-STATUS-001 | Verify stale EndShift is corrected to In when record has no end time. | Main | Employee has today's record: start set, end null. User flag is `EndShift`. | 1. POST get-users-list including that user.<br>2. Read `attendanceStatus`, `todayStartTime`, `todayEndTime`.<br>3. Call get-users-list again. | 1. `attendanceStatus` is `In`.<br>2. `todayEndTime` is empty/null in the response.<br>3. Second call still shows `In` (persisted). | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs` |
| TC-02 | EXCP-USER-LIST-STATUS-002 | Verify completed day shows EndShift when both times exist. | Regression | Record has start and end; user flag matches. | 1. POST get-users-list for that user. | `attendanceStatus` is `EndShift`. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUsersListBuilder.cs` |

### Platform provenance

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-03 | EXCP-USR-LIST-PLATFORM-001 | Verify no start time today means no start platform is returned | Main | The employee has no attendance entry for today.<br>An earlier saved start platform ("Web") still exists on the account. | 1. POST get-users-list for that employee.<br>2. Read `startWorkPlatform`. | `startWorkPlatform` is empty (null) — a platform is never returned without today's start. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-04 | EXCP-USR-LIST-PLATFORM-002 | Verify no end time today means no end platform is returned | Main | The employee has a start today but no end yet.<br>An earlier saved end platform ("Web") still exists on the account. | 1. POST get-users-list for that employee.<br>2. Read `endWorkPlatform`. | `endWorkPlatform` is empty (null) — yesterday's platform does not appear without today's end. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-05 | EXCP-USR-LIST-PLATFORM-003 | Verify an end captured from the web shows "Web" | Main | Today's attendance entry has an end and the entry records that it came from the web. | 1. POST get-users-list for that employee.<br>2. Read `endWorkPlatform`. | `endWorkPlatform` is `"Web"`, taken from today's entry. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-06 | EXCP-USR-LIST-PLATFORM-004 | Verify a start captured from the mobile app shows "Mobile" | Main | Today's attendance entry has a start and the entry records that it came from the mobile app. | 1. POST get-users-list for that employee.<br>2. Read `startWorkPlatform`. | `startWorkPlatform` is `"Mobile"`, taken from today's entry. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-07 | EXCP-USR-LIST-PLATFORM-005 | Verify an end falls back to the saved end-work platform when the entry records no source | Regression | Today's entry has an end but does not record where it came from.<br>The saved end-work platform on the account is `"Mobile"`. | 1. POST get-users-list for that employee.<br>2. Read `endWorkPlatform`. | `endWorkPlatform` is `"Mobile"` (the value saved by the end-work action). | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-08 | EXCP-USR-LIST-PLATFORM-006 | Verify a start falls back to the saved start-work platform when the entry records no source | Regression | Today's entry has a start but does not record where it came from.<br>The saved start-work platform on the account is `"Web"`. | 1. POST get-users-list for that employee.<br>2. Read `startWorkPlatform`. | `startWorkPlatform` is `"Web"` (the value saved by the start-work action). | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-09 | EXCP-USR-LIST-PLATFORM-007 | Verify an end with no recorded source and no saved platform stays empty | Edge | Today's entry has an end, records no source, and no end-work platform is saved on the account. | 1. POST get-users-list for that employee.<br>2. Read `endWorkPlatform`. | 1. `endWorkPlatform` is empty (null) — nothing is guessed.<br>2. The users list shows "Platform unavailable" for that end. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-10 | EXCP-USR-LIST-PLATFORM-008 | Verify an unknown saved platform value is never returned | Edge | Today's entry has an end with no recorded source and the saved platform value is "Unknown". | 1. POST get-users-list for that employee.<br>2. Read `endWorkPlatform`. | `endWorkPlatform` is empty (null) — "Unknown" is not shown as a platform. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |
| TC-11 | EXCP-USR-LIST-PLATFORM-009 | Verify saved platform values are matched regardless of letter case | Regression | Today's entry has a start with no recorded source and the saved start platform is written as `"web"` (lowercase). | 1. POST get-users-list for that employee.<br>2. Read `startWorkPlatform`. | `startWorkPlatform` is `"Web"` with standard capitalization. | `src/Excp.HRSystem.Application/Attendance/AttendanceListPlatformResolver.cs` |

### Leader scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-12 | EXCP-USER-LIST-SCOPE-001 | Verify a leader only receives their own team | Main | Signed in as a leader who is not an admin.<br>At least one employee outside that leader's team exists. | 1. POST get-users-list without a leader id.<br>2. POST get-users-list naming another leader's id.<br>3. Compare both responses. | 1. Both responses contain only employees whose leader is the signed-in leader.<br>2. Employees of other leaders never appear. | `src/Excp.HRSystem.Application/Services/Account/CustomAccountAppService.cs` |

