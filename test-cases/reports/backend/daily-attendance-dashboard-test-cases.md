# Daily attendance dashboard — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/Reports/daily-attendance-dashboard`
- Related code: `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs`
- Related docs: `docs/backend/technical/daily-attendance-dashboard-api.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Reports/DailyAttendanceDashboardRulesTests.cs`

## Scope

One-day company snapshot rules: present / late / leave / absent buckets, late minutes total, colour bands, late-from clock, percents, branch average.

## Test pages

- `POST /api/Reports/daily-attendance-dashboard`

## Test scenarios

- Leave beats punch for the day's bucket
- No check-in and not on leave counts as absent
- Late vs on time after grace
- Colour bands under 15 / 15–30 / above 30
- Company-wide late minutes equal the sum of late people
- Percents and averages round as shown on the dashboard
- Late-from clock is shift start plus that person's grace
- Missing branch location is Unassigned

## Test cases

### Dashboard rules

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-01 | EXCP-REPORT-DAD-001 | Verify An employee on authorised leave is counted on leave even if they also checked in. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-001`. | 1. The day bucket is on leave, not present or late. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | - |
| TC-02 | EXCP-REPORT-DAD-002 | Verify An employee with no check-in and no leave is counted absent. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-002`. | 1. The day bucket is absent. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-001 |
| TC-03 | EXCP-REPORT-DAD-003 | Verify A check-in after grace is late and a check-in inside grace is on time. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-003`. | 1. After grace maps to late.<br>2. Inside grace maps to on time. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-002 |
| TC-04 | EXCP-REPORT-DAD-004 | Verify Late colour bands are green under 15 minutes, amber from 15 through 30, and red above 30. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-004`. | 1. 14 minutes is green.<br>2. 15 minutes is amber.<br>3. 30 minutes is amber.<br>4. 31 minutes is red. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-003 |
| TC-05 | EXCP-REPORT-DAD-005 | Verify Percents round to whole numbers and late average uses one decimal. | Main | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-005`. | 1. 56 of 64 is 88 percent.<br>2. Average of 324 minutes across 12 people is 27.0.<br>3. Percent and average are 0 when the total count is 0. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-004 |
| TC-06 | EXCP-REPORT-DAD-006 | Verify The late-from clock is the shift start plus that person's grace minutes. | Main | Automated test for this key. Shift start `"09:00"`. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-006`. | 1. Grace 30 minutes gives late-from `"09:30"`.<br>2. Grace 0 minutes gives late-from `"09:00"`.<br>3. Negative grace is treated as 0. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-005 |
| TC-07 | EXCP-REPORT-DAD-007 | Verify A missing branch location is treated as Unassigned. | Edge | Automated test for this key. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-007`. | 1. No location becomes `"Unassigned"`. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-006 |
| TC-08 | EXCP-REPORT-DAD-008 | Verify Company-wide late minutes equal the sum of each late person's minutes. | Main | Automated test for this key. Two late people at 60 and 10 minutes. | 1. Run `dotnet test` filtered by Trait `EXCP-REPORT-DAD-008`. | 1. Late minutes total is 70.<br>2. On-time people do not add to the total. | `src/Excp.HRSystem.Application/Services/Reports/UserAttendanceReports/DailyAttendanceDashboardRules.cs` | EXCP-REPORT-DAD-005 |
