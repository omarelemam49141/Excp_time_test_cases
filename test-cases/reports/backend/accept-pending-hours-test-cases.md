# Accepted balances and pending hours (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/Reports/employee-hours-report`, `POST /api/Reports/employee-hours-report/accept-pending`
- Related code: `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptanceService.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs`
- Related docs: `docs/backend/technical/employee-hours-report-accepted-and-pending-hours.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Reports/PendingHoursAcceptancePlannerTests.cs`, `test/Excp.HRSystem.Application.Tests/Reports/EmployeeHoursReportMetricsSimulatePendingTests.cs`

## Scope

- Accepted balance hours are a preview only (never saved).
- Pending hours chosen by the admin are real and saved: status changes, oldest first, the last row is split when needed.
- Coverage is capped at the actual shortage; any excess is ignored and never becomes overtime.

## Test scenarios

- Oldest pending request first
- Last request split
- Excess stays pending
- Split boundary skips breaks
- Preview cap on accepted overtime
- Coverage cap

## Test cases

### Wave 1 — Pending acceptance planning

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-REPORT-ACCEPTPENDING-001 | Verify pending rows are accepted oldest first. | Main | - | 1. Three pending rows of 60 min on 10, 11 and 12 Oct.<br>2. Accept 120 min. | 1. The 10 Oct and 11 Oct rows are accepted in full.<br>2. The 12 Oct row stays pending. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs` |
| TC-02 | EXCP-REPORT-ACCEPTPENDING-002 | Verify the last row is split when the amount ends inside it. | Main | EXCP-REPORT-ACCEPTPENDING-001 | 1. Two pending rows of 60 min.<br>2. Accept 90 min. | 1. The first row is accepted in full.<br>2. The second row is split: 30 min accepted, the rest stays pending. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptanceService.cs` |
| TC-03 | EXCP-REPORT-ACCEPTPENDING-003 | Verify an amount above the pending total accepts what exists and the rest stays pending. | Edge | EXCP-REPORT-ACCEPTPENDING-001 | 1. One pending row of 60 min.<br>2. Accept 150 min. | 1. 60 min is accepted.<br>2. 90 min is reported as unmet. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs` |
| TC-04 | EXCP-REPORT-ACCEPTPENDING-004 | Verify the split boundary skips breaks inside the accepted part. | Edge | EXCP-REPORT-ACCEPTPENDING-002 | 1. Row 18:00-20:00 with a 19:00-19:15 break.<br>2. Accept 90 net min. | 1. The split is at 19:45. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs` |
| TC-05 | EXCP-REPORT-ACCEPTPENDING-005 | Verify a row that crosses midnight cannot be split by clock. | Edge | EXCP-REPORT-ACCEPTPENDING-002 | 1. Row 23:00-01:00, accept 30 min. | 1. No clock boundary is returned and the row stays pending in full. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/PendingHoursAcceptancePlanner.cs` |

### Wave 2 — Preview on accepted balances

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-06 | EXCP-REPORT-ACCEPTED-PREVIEW-001 | Verify applying fewer accepted overtime hours is a preview and does not touch pending hours. | Main | - | 1. 2 h accepted and 30 min pending overtime.<br>2. Generate with 1 h to apply. | 1. Accepted overtime used is 1 h; the balance still shows 2 h.<br>2. Pending stays 30 min. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs` |
| TC-07 | EXCP-REPORT-ACCEPTED-PREVIEW-002 | Verify coverage above the actual shortage is ignored and never becomes overtime. | Edge | - | 1. 2 h shortage and 3 h accepted coverage. | 1. Shortage becomes 0.<br>2. Accepted overtime stays 0. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs` |

### Wave 3 — Cover shortage from the overtime balance

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-08 | EXCP-REPORT-COVER-SHORTAGE-001 | Verify chosen weekday overtime hours cover shortage one to one, even in weighted mode. | Main | - | 1. 2 h shortage, 3 h accepted weekday overtime, weighted mode.<br>2. Choose 1 h from the 1.5x bucket. | 1. 1 h covers 1 h of shortage.<br>2. Effective shortage is 1 h and payable overtime is 2 h. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs` |
| TC-09 | EXCP-REPORT-COVER-SHORTAGE-002 | Verify coverage is capped to the bucket and to the remaining shortage. | Edge | EXCP-REPORT-COVER-SHORTAGE-001 | 1. 2 h shortage, 3 h overtime.<br>2. Choose 5 h. | 1. Only 2 h is covered, shortage is 0 and 1 h of overtime stays payable. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs` |
| TC-10 | EXCP-REPORT-COVER-SHORTAGE-003 | Verify the weekend bucket is chosen separately and nothing is added automatically. | Edge | EXCP-REPORT-COVER-SHORTAGE-001 | 1. Weekday and weekend overtime of 2 h each, 2 h shortage.<br>2. Choose 1 h from the 2.0x bucket only. | 1. Only the 2.0x bucket gives 1 h.<br>2. The other hour of shortage stays uncovered. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportMetricsService.cs` |
