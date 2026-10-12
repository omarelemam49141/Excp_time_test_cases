# Overtime Decisions And Readiness Checks Hardening — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `GET /api/attendance-overtime/Accept-overtime`, `POST /api/attendance-overtime/Accept-overtime`, `GET /api/attendance-overtime/Refuse-overtime`, `POST /api/attendance-overtime/Refuse-overtime`, `POST /api/attendance-overtime/Check-overtime-review-readiness`, `POST /api/attendance-overtime/Validate-employee-overtime-period-readiness`, `POST /api/attendance-overtime/Validate-employees-overtime-period-readiness`, `POST /api/attendance-overtime/Notify-employee-overtime-day-fix-required`
- Related code: `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeReviewReadinessAppService.cs`, `src/Excp.HRSystem.Application.Contracts/Services/OvertimeReviewReadiness/Dtos/OvertimeReviewReadinessDtos.cs`
- Related docs: `docs/backend/technical/overtime-decision-hardening.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/OvertimeDecisionEndpointTests.cs`

## Scope

This document covers who may call the overtime approve, refuse and readiness APIs, the rule that nobody decides their own overtime, the required reason when refusing, and the protection of the leader-scope check in the readiness API.

Each case is covered by automated tests that run the real controller and the real approve/refuse steps with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `/api/attendance-overtime/*`

## Test scenarios

- Only administrators and leaders can call the approve, refuse and readiness APIs.
- A caller cannot switch off the leader-scope check of the readiness API, and the readiness service cannot be called directly with a chosen user.
- Nobody can approve or refuse their own overtime.
- Refusing needs a reason on the new refuse API; the old refuse link keeps working.

## Test cases

### Access

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-REVIEW-READINESS-032 | Verify an employee cannot call the overtime approve, refuse and readiness APIs | Regression | An employee account, a leader account and an administrator account exist. A pending overtime entry exists. | 1. Sign in as the employee.<br>2. Call each API listed in the metadata with a valid body.<br>3. Repeat as the leader and as the administrator. | 1. Every call as the employee returns a forbidden response and changes nothing.<br>2. The same calls as the leader and as the administrator are not refused for their role. | Overtime id: "77" |
| TC-02 | EXCP-OT-HRS-REVIEW-READINESS-033 | Verify the leader-scope check of the period readiness API cannot be switched off by the caller | Regression | An employee who is not in the signed-in leader's team. | 1. Sign in as a leader who is not the employee's leader.<br>2. Call `POST /api/attendance-overtime/Validate-employee-overtime-period-readiness` for that employee with `"skipLeaderScopeValidation": true` in the body.<br>3. Look at the correction history of the employee. | 1. The call is refused because the employee is outside the leader's team.<br>2. No correction run is recorded for the employee.<br>3. The same call without the extra field gives the same refusal. | Employee id: "employee-outside-team-id" |
| TC-03 | EXCP-OT-HRS-REVIEW-READINESS-036 | Verify the readiness service cannot be called directly with a chosen user | Regression | The API is running. | 1. Open the API description page.<br>2. Look for paths that start with `/api/app/overtime-review-readiness`.<br>3. Send a call to `/api/app/overtime-review-readiness/validate-employee-period-for-leader/<any user id>`. | 1. The API description has no path that starts with `/api/app/overtime-review-readiness`.<br>2. The direct call returns not found. | User id: "any-user-id" |

### Own overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-OT-HRS-REVIEW-READINESS-034 | Verify nobody can approve or refuse their own overtime | Regression | A pending overtime entry belongs to an administrator, and another pending entry belongs to a leader. Each owner is also allowed to decide that kind of request for their team. | 1. Sign in as the administrator.<br>2. Approve and then refuse the administrator's own overtime entry, with the new APIs and with the old links.<br>3. Repeat as the leader with the leader's own entry.<br>4. Read both entries. | 1. Every call returns a forbidden response.<br>2. The message is `"You cannot approve or reject your own request."`.<br>3. Both entries are still pending and any linked request is unchanged. | Overtime ids: "78", "79" |

### Refusal reason

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-OT-HRS-REVIEW-READINESS-035 | Verify the new refuse API needs a reason and saves it | Regression | A pending overtime entry linked to a pending request. The signed-in leader may decide it. | 1. Sign in as the leader.<br>2. Send `POST /api/attendance-overtime/Refuse-overtime` with the overtime id and no reason, then with a reason of only spaces.<br>3. Send it again with the reason `"Not approved by plan"`.<br>4. Read the overtime entry and its request. | 1. The first two calls return a bad request response with the message `"A reason is required when refusing."` and change nothing.<br>2. The third call succeeds.<br>3. The overtime entry and its request are rejected.<br>4. The request shows the reason `"Not approved by plan"`. | Overtime id: "80"<br>Reason: "Not approved by plan" |
| TC-06 | EXCP-OT-HRS-REVIEW-READINESS-037 | Verify the old refuse link keeps working without a reason for current clients | Regression | Same as TC-05, with a new pending entry. | 1. Sign in as the leader.<br>2. Open `GET /api/attendance-overtime/Refuse-overtime?overTimeId=81` with no reason. | 1. The call succeeds.<br>2. The overtime entry and its request are rejected. | Overtime id: "81" |
