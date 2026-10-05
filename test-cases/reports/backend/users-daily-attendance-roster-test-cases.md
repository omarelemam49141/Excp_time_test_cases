# Users daily attendance roster — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/Reports/users-daily-attendance-roster`
- Related code: `src/Excp.HRSystem.Application/Attendance/AttendanceNetDurations.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/RosterCumulativeOvertime.cs`, `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs`, `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterNetTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/AttendancePunctualityTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterPunctualityTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/RosterCumulativeOvertimeTests.cs`
- Related docs: `docs/backend/technical/users-daily-attendance-roster-api.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterNetTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/AttendancePunctualityTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterPunctualityTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/RosterCumulativeOvertimeTests.cs`

## Scope

One-day all-employee roster: start time, end time, and net working hours with home/site overtime gap. Cumulative payable overtime for `periodStart` through `workDate`.

## Test pages

- `POST /api/Reports/users-daily-attendance-roster`

## Test scenarios

- Punched day uses real start/end and gap-aware net hours
- Overnight wrap when end is before start
- Approved leave without punch credits shift times and required hours
- Missing punch shows empty times and zero net
- Inactive employees can be included or excluded
- `WorkPlace.None` and Home use home gap; Site uses site gap
- Punctuality status after late/early allowance (On time / Late N min / Early N min / None)
- Roster API returns `punctualityStatus` and `punctualityMinutes` per row
- Cumulative payable overtime clock uses hours-report payable leftover (`accepted + gap payable`) with pending treated as accepted

## Delivery waves

| Wave | Intent | Keys |
|------|--------|------|
| 3 | Daily roster API + xUnit | EXCP-REPORT-UAR-API-001 … 006, EXCP-REPORT-UAR-XUNIT-001 |
| 5 | Punctuality helper + xUnit | EXCP-REPORT-UAR-PUNC-001 … 007 |
| 6 | Roster API punctuality fields | EXCP-REPORT-UAR-PUNC-API-001 … 005 |
| 8 | Cumulative overtime helper + xUnit | EXCP-REPORT-UAR-OT-001 … 003 |
| 9 | Roster API period start + payable OT | EXCP-REPORT-UAR-OT-API-001 … 005 |

## Test cases

### Wave 3 — Daily roster API

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-01 | EXCP-REPORT-UAR-API-001 | Verify A punched site day returns real start/end and net hours after deducting only break time above the site overtime gap. | Main | Admin token. Employee with site punch 08:00–17:00 and 45 minutes of completed breaks. Site gap 30, home gap 0. | 1. `POST /api/Reports/users-daily-attendance-roster` with that `workDate`, `periodStart` equal to `workDate`, and `includeInactive` true.<br>2. Find the employee row. | 1. `attendanceStart` is `"08:00:00"`.<br>2. `attendanceEnd` is `"17:00:00"`.<br>3. `netWorkDurationWithoutBreaks` is `"8:45:00"` (9h minus 15m excess break). | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | - |
| TC-02 | EXCP-REPORT-UAR-API-002 | Verify Overnight attendance (end before start) still produces a positive net duration. | Edge | Employee punched 22:00 start and 06:00 end, no breaks, any workplace. | 1. Call the roster API for that date.<br>2. Read the employee row. | 1. `attendanceStart` is `"22:00:00"`.<br>2. `attendanceEnd` is `"06:00:00"`.<br>3. `netWorkDurationWithoutBreaks` is `"8:00:00"`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-API-001 |
| TC-03 | EXCP-REPORT-UAR-API-003 | Verify Approved leave with no punch returns shift start/end and that day's required work hours as net. | Main | Employee has approved leave and no attendance row. Shift 08:00–17:00. Required net hours 8. | 1. Call the roster API for the leave date.<br>2. Read the employee row. | 1. `isApprovedLeave` is true.<br>2. `attendanceStart` is `"08:00:00"`.<br>3. `attendanceEnd` is `"17:00:00"`.<br>4. `netWorkDurationWithoutBreaks` is `"8:00:00"`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-API-001 |
| TC-04 | EXCP-REPORT-UAR-API-004 | Verify An employee with no punch and no leave still appears with empty times and zero net. | Main | Employee exists with email, not deleted, no attendance and no leave on `workDate`. | 1. Call the roster API.<br>2. Read the employee row. | 1. The employee is in `rows`.<br>2. `attendanceStart` is null or empty.<br>3. `attendanceEnd` is null or empty.<br>4. `netWorkDurationWithoutBreaks` is `"0:00:00"`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-API-001 |
| TC-05 | EXCP-REPORT-UAR-API-005 | Verify `includeInactive` false hides inactive employees and true includes them with `isActive` false. | Main | At least one inactive identity user with email. | 1. Call with `includeInactive` true.<br>2. Call again with `includeInactive` false. | 1. First response includes the inactive user and `isActive` is false.<br>2. Second response does not include that user. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-API-001 |
| TC-06 | EXCP-REPORT-UAR-API-006 | Verify `WorkPlace.None` and Home use the home overtime gap while Site uses the site gap. | Edge | Same punch 08:00–17:00 with 45 minutes breaks. Site gap 30, home gap 0. | 1. Call for a Site punch.<br>2. Call for Home and None punches on equivalent days. | 1. Site row net is `"8:45:00"`.<br>2. Home and None rows net is `"8:15:00"` (all 45m deducted). | `src/Excp.HRSystem.Application/Attendance/AttendanceNetDurations.cs`, `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterNetTests.cs` | EXCP-SCHED-OT-GAP-006, EXCP-REPORT-UAR-API-001 |
| TC-07 | EXCP-REPORT-UAR-XUNIT-001 | Verify `dotnet test` passes for roster and gap Keys with Trait filters | Main | xUnit files exist under `test/Excp.HRSystem.Application.Tests/Reports/`. | 1. From `EXCPTIME_MVC` root run `dotnet test test/Excp.HRSystem.Application.Tests/Excp.HRSystem.Application.Tests.csproj --filter "FullyQualifiedName~AttendanceNetDurations OR FullyQualifiedName~UsersDailyAttendanceRosterNet"`. | 1. All tests pass.<br>2. Traits cover `EXCP-SCHED-OT-GAP-006` through `008` and `EXCP-REPORT-UAR-API-001` through `006`. | `test/Excp.HRSystem.Application.Tests/Reports/AttendanceNetDurationsOvertimeGapTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/UsersDailyAttendanceRosterNetTests.cs` | EXCP-REPORT-UAR-API-006 |

### Wave 5 — Punctuality helper

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-08 | EXCP-REPORT-UAR-PUNC-001 | Verify Approved leave resolves to punctuality status `None` with zero minutes even when punch start exists. | Main | Unit test fixture. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-001`. | 1. `AttendancePunctuality.Resolve` returns `None` and `0` minutes.<br>2. API status string is `"None"`. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | - |
| TC-09 | EXCP-REPORT-UAR-PUNC-002 | Verify Missing punch start resolves to punctuality status `None`. | Main | Unit test fixture. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-002`. | 1. `Resolve` with `actualStart` null returns `None` and `0` minutes. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | EXCP-REPORT-UAR-PUNC-001 |
| TC-10 | EXCP-REPORT-UAR-PUNC-003 | Verify Punch start inside late grace (shift 09:00, tolerance 15, start 09:05) is `OnTime`. | Main | Schedule late tolerance 15 minutes. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-003`. | 1. Combined `LatenessShortageComputation` + `Resolve` returns `OnTime` and `0` minutes. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/LatenessShortageComputation.cs` | EXCP-REPORT-UAR-PUNC-002 |
| TC-11 | EXCP-REPORT-UAR-PUNC-004 | Verify Punch start beyond late grace (shift 09:00, tolerance 15, start 09:20) is `Late` with 5 minutes. | Main | Same schedule. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-004`. | 1. Status is `Late`.<br>2. Minutes equal `5` (penalizable late minutes). | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | EXCP-REPORT-UAR-PUNC-003 |
| TC-12 | EXCP-REPORT-UAR-PUNC-005 | Verify Punch start inside early grace (shift 09:00, early tolerance 10, start 08:55) is `OnTime`. | Main | Schedule early tolerance 10 minutes. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-005`. | 1. Status is `OnTime` and minutes are `0`. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | EXCP-REPORT-UAR-PUNC-004 |
| TC-13 | EXCP-REPORT-UAR-PUNC-006 | Verify Punch start beyond early grace (shift 09:00, early tolerance 10, start 08:40) is `Early` with 10 minutes. | Edge | Same schedule. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-006`. | 1. Status is `Early`.<br>2. Minutes equal `10` (early beyond tolerance). | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | EXCP-REPORT-UAR-PUNC-005 |
| TC-14 | EXCP-REPORT-UAR-PUNC-007 | Verify Employee late-tolerance override is read from `IdentityUser` extra properties. | Edge | User with `LateToleranceMinutesOverride` set to 30. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-PUNC-007`. | 1. `TryGetLateToleranceOverrideMinutes` returns `30`. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/AttendancePunctuality.cs` | EXCP-REPORT-UAR-PUNC-006 |

### Wave 6 — Roster API punctuality fields

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-15 | EXCP-REPORT-UAR-PUNC-API-001 | Verify Roster row with punch start inside late grace returns `punctualityStatus` `OnTime` and `punctualityMinutes` `0`. | Main | Shift 09:00, late tolerance 15, employee punched 09:05. | 1. `POST /api/Reports/users-daily-attendance-roster` for that date.<br>2. Read the employee row. | 1. `punctualityStatus` is `"OnTime"`.<br>2. `punctualityMinutes` is `0`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-PUNC-003 |
| TC-16 | EXCP-REPORT-UAR-PUNC-API-002 | Verify Roster row with punch start beyond late grace returns `Late` with penalizable minutes matching hours-report daily shortage. | Main | Shift 09:00, late tolerance 15, employee punched 09:20. | 1. Call roster API.<br>2. Compare to employee-hours report penalizable minutes for same employee/date. | 1. `punctualityStatus` is `"Late"`.<br>2. `punctualityMinutes` is `5`.<br>3. Minutes match hours-report `penalizableLateMinutes`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-PUNC-API-001 |
| TC-17 | EXCP-REPORT-UAR-PUNC-API-003 | Verify Roster row with punch start beyond early grace returns `Early` with beyond-tolerance minutes. | Edge | Shift 09:00, early tolerance 10, employee punched 08:40. | 1. Call roster API.<br>2. Read the employee row. | 1. `punctualityStatus` is `"Early"`.<br>2. `punctualityMinutes` is `10`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-PUNC-API-002 |
| TC-18 | EXCP-REPORT-UAR-PUNC-API-004 | Verify Approved leave row returns `punctualityStatus` `None` regardless of displayed shift times. | Main | Employee on approved leave (with or without punch). | 1. Call roster API for leave date.<br>2. Read the employee row. | 1. `isApprovedLeave` is true.<br>2. `punctualityStatus` is `"None"`.<br>3. `punctualityMinutes` is `0`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-PUNC-API-003 |
| TC-19 | EXCP-REPORT-UAR-PUNC-API-005 | Verify Absent employee (no punch start) returns `punctualityStatus` `None`. | Main | Employee with no attendance on `workDate`. | 1. Call roster API.<br>2. Read the employee row. | 1. `attendanceStart` is null or empty.<br>2. `punctualityStatus` is `"None"`.<br>3. `punctualityMinutes` is `0`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-PUNC-API-004 |

### Wave 8 — Cumulative overtime helper

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-20 | EXCP-REPORT-UAR-OT-001 | Verify Payable clock formatting of zero seconds is `"0:00:00"`. | Main | Unit test fixture. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-OT-001`. | 1. `RosterCumulativeOvertime.FormatPayableClockHours` returns `"0:00:00"` when accepted payable and gap payable seconds are both `0`. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/RosterCumulativeOvertime.cs` | - |
| TC-21 | EXCP-REPORT-UAR-OT-002 | Verify Payable clock formatting sums accepted payable seconds and gap payable seconds. | Main | Unit test fixture. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-OT-002`. | 1. Metrics with `3600` accepted payable seconds and `1800` gap payable seconds format as `"1:30:00"`. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/RosterCumulativeOvertime.cs` | EXCP-REPORT-UAR-OT-001 |
| TC-22 | EXCP-REPORT-UAR-OT-003 | Verify Metrics input treats pending overtime as accepted and keeps the default hours-report pipeline flags. | Main | Unit test fixture. | 1. Run xUnit with Trait `EXCP-REPORT-UAR-OT-003`. | 1. `SimulatePendingAsAccepted` is true.<br>2. `UseRefusedOvertimeForShortage` is false.<br>3. Salary, prizes, and KPI amounts are `0`.<br>4. `BulkShortageCompensationMode` is null.<br>5. `StartDate` and `EndDate` use the period start and work date calendar days. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/RosterCumulativeOvertime.cs` | EXCP-REPORT-UAR-OT-002 |

### Wave 9 — Roster API period start and payable overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-23 | EXCP-REPORT-UAR-OT-API-001 | Verify The roster API returns 400 when `periodStart` is missing. | Main | Admin token. | 1. `POST /api/Reports/users-daily-attendance-roster` with `workDate` only (no `periodStart`). | 1. The response status is 400. | `src/Excp.HRSystem.Application.Contracts/Entities/Reports/UserAttendanceReports/Fluent Validations/UsersDailyAttendanceRosterInputValidation.cs` | EXCP-REPORT-UAR-OT-003 |
| TC-24 | EXCP-REPORT-UAR-OT-API-002 | Verify The roster API returns 400 when `periodStart` is after `workDate`. | Main | Admin token. | 1. `POST /api/Reports/users-daily-attendance-roster` with `periodStart` one day after `workDate`. | 1. The response status is 400. | `src/Excp.HRSystem.Application.Contracts/Entities/Reports/UserAttendanceReports/Fluent Validations/UsersDailyAttendanceRosterInputValidation.cs` | EXCP-REPORT-UAR-OT-API-001 |
| TC-25 | EXCP-REPORT-UAR-OT-API-003 | Verify Roster `cumulativePayableOvertimeHours` matches hours-report "Payable overtime hours" with pending treated as accepted. | Main | Same employee and date range with accepted overtime and shortage. | 1. `POST /api/Reports/users-daily-attendance-roster` with `periodStart` and `workDate`.<br>2. Read that employee row `cumulativePayableOvertimeHours`.<br>3. Open `/admin/reports/employee-hours-report` for the same employee and dates with "What if pending overtime was accepted?" on.<br>4. Read "Payable overtime hours". | 1. The roster cell clock equals the hours-report "Payable overtime hours" clock.<br>2. The response echoes `periodStart`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-OT-API-002 |
| TC-26 | EXCP-REPORT-UAR-OT-API-004 | Verify An employee with no leftover overtime in the range returns `"0:00:00"`. | Main | Employee with no overtime (and no payable leftover) between `periodStart` and `workDate`. | 1. Call the roster API for that range.<br>2. Read the employee row. | 1. `cumulativePayableOvertimeHours` is `"0:00:00"`. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-OT-API-003 |
| TC-27 | EXCP-REPORT-UAR-OT-API-005 | Verify Pending overtime in the range is included in the payable clock (same as hours-report simulation on). | Main | Employee with pending overtime in the range. | 1. Call the roster API.<br>2. Compare to hours-report "Payable overtime hours" with simulation on and with simulation off. | 1. Roster clock matches hours-report with simulation on.<br>2. Roster clock does not match the simulation-off payable hours when pending OT changes the leftover. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateUsersDailyAttendanceRosterBuilder.cs` | EXCP-REPORT-UAR-OT-API-003 |
