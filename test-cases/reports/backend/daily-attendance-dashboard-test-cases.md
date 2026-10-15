# Daily attendance dashboard — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/Reports/daily-attendance-dashboard`
- Related code: `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs`, `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateDailyAttendanceDashboardBuilder.cs`
- Related docs: `docs/backend/technical/daily-attendance-dashboard-api.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Reports/DailyAttendanceDashboardRulesTests.cs`

## Scope

One-day company snapshot rules: present / late / leave / absent buckets, late minutes total (from official start), colour bands, late-from clock, percents, branch average, optional role filter.

## Test pages

- `POST /api/Reports/daily-attendance-dashboard`

## Test scenarios

- Leave beats punch for the day's bucket
- No check-in and not on leave counts as absent
- Late vs on time after grace (classification only)
- Displayed minutes from official start, not after grace
- Overtime gap does not change dashboard lateness
- Colour bands under 15 / 15–30 / above 30
- Company-wide late minutes equal the sum of late people
- Percents and averages round as shown on the dashboard
- Late-from clock is official shift start
- Missing branch location is Unassigned
- Default roles exclude Admin and HR
- Role filter narrows workforce

## Test cases

### Dashboard rules

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-01 | EXCP-REPORT-DAD-001 | Verify An employee on authorised leave is counted on leave even if they also checked in. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-001`. | 1. The day bucket is on leave, not present or late. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | - |
| TC-02 | EXCP-REPORT-DAD-002 | Verify An employee with no check-in and no leave is counted absent. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-002`. | 1. The day bucket is absent. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-001 |
| TC-03 | EXCP-REPORT-DAD-003 | Verify A check-in after grace is late and a check-in inside grace is on time. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-003`. | 1. After grace maps to late.<br>2. Inside grace maps to on time. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-002 |
| TC-04 | EXCP-REPORT-DAD-004 | Verify Late colour bands are green under 15 minutes, amber from 15 through 30, and red above 30. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-004`. | 1. 14 minutes is green.<br>2. 15 minutes is amber.<br>3. 30 minutes is amber.<br>4. 31 minutes is red. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-003 |
| TC-05 | EXCP-REPORT-DAD-005 | Verify Percents round to whole numbers and late average uses one decimal. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-005`. | 1. 56 of 64 is 88 percent.<br>2. Average of 324 minutes across 12 people is 27.0.<br>3. Percent and average are 0 when the total count is 0. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-004 |
| TC-06 | EXCP-REPORT-DAD-006 | Verify The late-from clock is the official shift start (not start plus grace). | Main | Automated test for this key. Shift start `"09:00"`. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-006`. | 1. Late-from is `"09:00"` regardless of grace minutes on the policy card. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-005 |
| TC-07 | EXCP-REPORT-DAD-007 | Verify A missing branch location is treated as Unassigned. | Edge | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-007`. | 1. No location becomes `"Unassigned"`. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-006 |
| TC-08 | EXCP-REPORT-DAD-008 | Verify Company-wide late minutes equal the sum of each late person's minutes. | Main | Automated test for this key. Two late people at 60 and 10 minutes. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-008`. | 1. Late minutes total is 70.<br>2. On-time people do not add to the total. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-005 |
| TC-09 | EXCP-REPORT-DAD-009 | Verify Displayed late minutes count from official start while late vs on time still uses grace. | Main | Automated test for this key. Start 09:00, grace 30. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-009`. | 1. Check-in 10:00 is late with 60 displayed minutes.<br>2. Check-in 09:20 is on time with 0 displayed minutes. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-003 |
| TC-10 | EXCP-REPORT-DAD-010 | Verify Overtime gap minutes do not change dashboard late minutes. | Edge | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-010`. | 1. Same check-in with gap 0 vs gap 45 yields the same displayed late minutes. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-009 |

### Role filter (API)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-11 | EXCP-REPORT-DAD-011 | Verify Default request excludes Admin and HR from workforce. | Main | Active Admin and HR users with email exist. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-011`. | 1. Default role set is Employee and Leader only. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateDailyAttendanceDashboardBuilder.cs` | EXCP-REPORT-DAD-010 |
| TC-12 | EXCP-REPORT-DAD-012 | Verify Request with roles Employee only excludes Leader-only users. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-012`. | 1. Only users with the Employee role are included. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateDailyAttendanceDashboardBuilder.cs` | EXCP-REPORT-DAD-011 |
| TC-13 | EXCP-REPORT-DAD-013 | Verify Request including Admin role includes admin users. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-013`. | 1. Admin users appear in workforce when Admin is in roles. | `src/Excp.HRSystem.Application/Builders/Services/Reports/UserAttendanceReports/GenerateDailyAttendanceDashboardBuilder.cs` | EXCP-REPORT-DAD-011 |
