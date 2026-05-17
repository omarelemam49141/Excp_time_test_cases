# Overtime review readiness guard - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `"POST /api/attendance-overtime/Check-overtime-review-readiness"`, `"GET /api/attendance-overtime/Accept-overtime"`, `"GET /api/attendance-overtime/Refuse-overtime"`, `"POST /api/Requests/change-reqeust-status"`, `"POST /api/Requests/bulk-change-request-status"`, `"POST /api/attendance-overtime/Validate-employee-overtime-period-readiness"`, `"POST /api/attendance-overtime/Validate-employees-overtime-period-readiness"`, `"POST /api/attendance-overtime/Notify-employee-overtime-day-fix-required"`, `"POST /api/attendance-record/Bulk-apply-attendance-changes"`, `"POST /api/attendance-record/Apply-quick-entry-range-correction"`
- Related code: `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeReviewReadinessAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Services/AttendanceBulk/AttendanceBulkQuickEntryAppService.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestReviewLockService.cs`
- Related docs: `docs/backend/technical/overtime-review-readiness-guard.md`

## Scope

This document covers backend readiness checks before a team leader approves or refuses overtime, pending leave blockers before overtime decisions, period validation for one employee, and employee notifications for days that need Quick Entry fixes.

## Test pages

- `"POST /api/attendance-overtime/Check-overtime-review-readiness"`
- `"GET /api/attendance-overtime/Accept-overtime"`
- `"GET /api/attendance-overtime/Refuse-overtime"`
- `"POST /api/Requests/change-reqeust-status"`
- `"POST /api/Requests/bulk-change-request-status"`
- `"POST /api/attendance-overtime/Validate-employee-overtime-period-readiness"`
- `"POST /api/attendance-overtime/Validate-employees-overtime-period-readiness"`
- `"POST /api/attendance-overtime/Notify-employee-overtime-day-fix-required"`
- `"POST /api/attendance-record/Bulk-apply-attendance-changes"`
- `"POST /api/attendance-record/Apply-quick-entry-range-correction"`

## Test scenarios

- A clean pending overtime can still be approved or refused.
- If correction changes the leader pending list, the decision is stopped and the API returns a response that tells the client to reload.
- If correction creates new pending overtime for the same day, the original decision is stopped so the leader can review the updated list.
- If the day has missing or invalid attendance or break information, the decision is blocked until the employee fixes the day.
- If a pending leave request covers the overtime day, the decision is blocked until the leader or admin accepts or refuses that leave request.
- Bulk approve/refuse reports blocked overtime items without approving them.
- A leader can validate one employee period, validate multiple or all direct reports in one batch call, and notify the employee for a day that needs fixes.
- When the employee saves or corrects a day in Quick Entry, the leader receives an update for the affected overtime date.

## Test cases

### Single overtime decision

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-REVIEW-READINESS-001 | Verify a clean pending overtime can be approved | Main | A direct report has one pending overtime on `"2026-05-06"`.<br>The day has complete attendance, complete breaks, complete overtime, and complete overtime breaks.<br>The signed-in user has the team leader role. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Check-overtime-review-readiness"` with the overtime id.<br>3. Read the readiness response.<br>4. Call `"GET /api/attendance-overtime/Accept-overtime"` for the same overtime id. | 1. The readiness response shows `"Ready"` as text.<br>2. The readiness response does not show `"ReviewerNotAllowed"`.<br>3. The approve response is successful.<br>4. The overtime is no longer `"Pending"`. | Date: `"2026-05-06"` |
| TC-02 | EXCP-OT-HRS-REVIEW-READINESS-002 | Verify corrected within-gap overtime stops the decision and notifies the employee | Regression | A direct report has pending overtime on `"2026-05-07"` that is within the configured overtime gap after correction. | 1. Sign in as the team leader.<br>2. Call `"GET /api/attendance-overtime/Accept-overtime"` for the overtime id.<br>3. Read the response body.<br>4. Call the leader pending overtime list for the same employee and date.<br>5. Sign in as the employee and call `"POST /api/Notifications/get-my-notifications"`. | 1. The approve response is `"409"`.<br>2. The response shows `"QueueChanged"`.<br>3. The corrected overtime is not returned as `"Pending"` after reload.<br>4. The overtime is not approved by the failed decision.<br>5. The employee notification list includes `"Attendance day updated by system"` with a Quick Entry link for `"2026-05-07"`. | Date: `"2026-05-07"` |
| TC-03 | EXCP-OT-HRS-REVIEW-READINESS-003 | Verify correction that creates new pending overtime stops the decision | Main | A direct report has attendance on `"2026-05-08"` that exceeds the work schedule and has one stale pending overtime before correction. | 1. Sign in as the team leader.<br>2. Call `"GET /api/attendance-overtime/Refuse-overtime"` for the stale pending overtime.<br>3. Read the response body.<br>4. Reload the leader pending overtime list for `"2026-05-08"`. | 1. The refuse response is `"409"`.<br>2. The response shows `"QueueChanged"`.<br>3. The reloaded list includes the updated pending overtime that the leader must review.<br>4. The original refuse decision is not applied. | Date: `"2026-05-08"` |
| TC-04 | EXCP-OT-HRS-REVIEW-READINESS-004 | Verify missing day information blocks approve or refuse | Edge | A direct report has pending overtime on `"2026-05-09"` and the same day has a break with no end time. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Check-overtime-review-readiness"` with the overtime id.<br>3. Read the issue list.<br>4. Call `"GET /api/attendance-overtime/Accept-overtime"` for the same overtime id. | 1. The readiness response shows `"EmployeeActionRequired"` as text.<br>2. The response includes an issue code such as `"AttendanceBreakMissingEnd"`.<br>3. The approve response is `"409"`.<br>4. The overtime remains `"Pending"`. | Date: `"2026-05-09"` |
| TC-05 | EXCP-OT-HRS-REVIEW-READINESS-005 | Verify pending leave metadata supports in-modal leave review before overtime approval | Main | A direct report has pending overtime on `"2026-05-11"`.<br>The same employee has a pending leave request that covers `"2026-05-11"`. | 1. Sign in as the team leader or admin.<br>2. Call `"POST /api/attendance-overtime/Check-overtime-review-readiness"` with the overtime id.<br>3. Read the readiness response.<br>4. Call `"GET /api/attendance-overtime/Accept-overtime"` for the same overtime id.<br>5. Call `"POST /api/Requests/change-reqeust-status"` for the returned pending leave request id with `"newStatus"` set to `"Approved"` or `"Rejected"`.<br>6. Call `"POST /api/attendance-overtime/Check-overtime-review-readiness"` again for the same overtime id. | 1. The first readiness response shows `"ReviewerActionRequired"` as text.<br>2. The first readiness response includes issue code `"PendingLeaveRequestAwaitingDecision"`.<br>3. The first readiness response includes the pending leave request id, request number, start date, and end date.<br>4. The approve response before the leave decision is `"409"`.<br>5. The overtime remains `"Pending"` before the leave decision.<br>6. After the leave is accepted or refused, readiness no longer shows `"ReviewerActionRequired"` for that leave request.<br>7. If there are no other readiness issues, the second readiness response shows `"Ready"` as text. | Date: `"2026-05-11"` |

### Linked request and bulk decisions

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-OT-HRS-REVIEW-READINESS-006 | Verify a linked overtime request uses the same readiness guard | Regression | A pending request is linked to a pending overtime on `"2026-05-10"` and correction will change the day. | 1. Sign in as the team leader.<br>2. Call `"POST /api/Requests/change-reqeust-status"` with `"newStatus"` set to `"Approved"` for the linked request.<br>3. Read the response. | 1. The response is `"409"`.<br>2. The response shows `"QueueChanged"`.<br>3. The linked request remains `"Pending"` until the leader reloads and reviews again. | newStatus: `"Approved"` |
| TC-07 | EXCP-OT-HRS-REVIEW-READINESS-007 | Verify bulk approve reports overtime blocked by readiness | Regression | Two pending overtime items are selected: one clean and one with missing day information. | 1. Sign in as the team leader.<br>2. Call `"POST /api/Requests/bulk-change-request-status"` with both overtime ids and `"newStatus"` set to `"Approved"`.<br>3. Read the bulk result. | 1. The clean item is approved.<br>2. The problem item is reported as failed.<br>3. The failed item remains `"Pending"`.<br>4. The result includes an error message for the failed item. | newStatus: `"Approved"` |

### Period validation and notification

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-OT-HRS-REVIEW-READINESS-008 | Verify a leader can validate one employee period | Main | A direct report has one clean day, one day corrected by the system, one day that needs employee action, and one day covered by a pending leave request between `"2026-05-06"` and `"2026-05-12"`. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Validate-employee-overtime-period-readiness"` for the employee and date range.<br>3. Read the summary counts and day list. | 1. The response is successful.<br>2. The summary includes clean days.<br>3. The summary includes corrected days when correction changes the pending list.<br>4. The summary includes days that need employee action.<br>5. The summary includes days that need reviewer action. | From: `"2026-05-06"`<br>To: `"2026-05-12"` |
| TC-09 | EXCP-OT-HRS-REVIEW-READINESS-009 | Verify a leader cannot validate an employee outside their team | Edge | The signed-in team leader does not manage the selected employee. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Validate-employee-overtime-period-readiness"` for the other employee. | 1. The response is blocked.<br>2. No correction is applied for the other employee. | - |
| TC-10 | EXCP-OT-HRS-REVIEW-READINESS-010 | Verify a leader can notify the employee to fix a problem day | Main | A direct report has a day that returns `"EmployeeActionRequired"` with issue code `"AttendanceBreakMissingEnd"`. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Notify-employee-overtime-day-fix-required"` for the employee and date.<br>3. Sign in as the employee.<br>4. Open notifications. | 1. The notify response is successful.<br>2. The employee sees a notification asking them to fix the day in Quick Entry.<br>3. The notification link includes `"from"`, `"to"`, `"focusDate"`, and `"issueCode"` for `"2026-05-09"`. | Date: `"2026-05-09"` |

### Batch period validation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-OT-HRS-REVIEW-READINESS-015 | Verify a leader can validate selected employees in one batch call | Main | A team leader has at least two direct reports with mixed readiness days between `"2026-05-06"` and `"2026-05-13"`. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Validate-employees-overtime-period-readiness"` with `"includeAllEmployees": false`, both employee ids, and the date range.<br>3. Read the aggregate counts and `employees` array. | 1. The response is successful.<br>2. Aggregate counts sum successful employees only.<br>3. Each employee entry includes `employeeUserName`, `employeeEmail`, and nested day results.<br>4. `employeeCount` matches successful employees. | From: `"2026-05-06"`<br>To: `"2026-05-13"` |
| TC-16 | EXCP-OT-HRS-REVIEW-READINESS-016 | Verify includeAllEmployees validates all direct reports | Main | A team leader has multiple direct reports. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Validate-employees-overtime-period-readiness"` with `"includeAllEmployees": true` and a valid date range.<br>3. Compare `employees` length with the leader's direct-report directory. | 1. The response is successful.<br>2. Every current direct report appears in `employees` or as a failed scope row.<br>3. No employee outside the leader team is corrected. | From: `"2026-05-06"`<br>To: `"2026-05-13"` |
| TC-17 | EXCP-OT-HRS-REVIEW-READINESS-017 | Verify out-of-scope employees return per-employee errors without correction | Edge | The signed-in team leader does not manage the selected employee. | 1. Sign in as the team leader.<br>2. Call `"POST /api/attendance-overtime/Validate-employees-overtime-period-readiness"` with the other employee id and a valid date range.<br>3. Read the matching `employees` entry. | 1. The HTTP response is successful.<br>2. The out-of-scope employee row has `success: false`.<br>3. The error message explains the employee is outside the leader team.<br>4. Aggregate counts do not include corrected days for that employee. | - |

### Quick Entry change updates

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-OT-HRS-REVIEW-READINESS-011 | Verify employee Quick Entry save updates the leader for the affected overtime date | Regression | A direct report has pending overtime on `"2026-05-09"` and the team leader is connected to realtime updates. | 1. Sign in as the employee.<br>2. Call `"POST /api/attendance-record/Bulk-apply-attendance-changes"` with corrected attendance information for `"2026-05-09"`.<br>3. Watch the team leader realtime client. | 1. The save response is successful.<br>2. The team leader client receives a pending-request update.<br>3. The update includes the employee account id.<br>4. The update includes the affected date `"2026-05-09"`.<br>5. The update includes the overtime id when the overtime still exists for that date. | Date: `"2026-05-09"` |
