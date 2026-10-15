# Request Refusal Reason — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/change-reqeust-status`, `POST /api/Requests/bulk-change-request-status`, `POST /api/attendance-overtime/Refuse-overtime`, `GET /api/attendance-overtime/Refuse-overtime`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionGuards.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Domain.Shared/Localization/HRSystem/en.json`, `src/Excp.HRSystem.Domain.Shared/Localization/HRSystem/ar.json`
- Related docs: `docs/backend/technical/request-refusal-reason.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestNotificationPolicyTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/RequestDecisionSqliteTests.cs`

## Scope

This document covers the mandatory refusal reason: every way of refusing a request or an overtime (single, bulk, overtime, and the old refuse link) needs a reason of at most 500 characters, which is saved with the request, written to the history and sent to the employee.

## Test pages

- `/admin-leader/list-requests`

## Test scenarios

- A refusal without a reason is refused with a translated message and changes nothing.
- A refusal with a reason saves it, audits it and tells the employee.
- A reason that is too long is refused.

## Test cases

### Reason rule

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-REASON-001 | Verify a single refusal without a reason is refused and changes nothing | Main | A pending request the signed-in leader can decide. | 1. Send `POST /api/Requests/change-reqeust-status` with "Rejected" and no reason, then with an empty reason, then with a reason of only spaces.<br>2. Read the request, its history and the notifications. | 1. Each call returns a bad request response with the message `"A reason is required when refusing."`.<br>2. The request is still pending.<br>3. There is no history entry and no notification. | Request: 1 |
| TC-02 | EXCP-REQ-HRS-REASON-002 | Verify a single refusal saves the reason, audits it and tells the employee after saving | Main | A pending request the signed-in leader can decide. | 1. Send `change-reqeust-status` with "Rejected" and the reason `"  المستند ناقص  "`.<br>2. Read the request, its history and the notifications. | 1. The request is rejected and shows the reason without the extra spaces.<br>2. The history entry names the leader, goes from pending to rejected and has the reason as its comment.<br>3. The employee has one notification that contains the reason and links to the request.<br>4. The employee's screen receives the notification only after the decision is saved. | Reason: "المستند ناقص" |
| TC-03 | EXCP-REQ-HRS-REASON-003 | Verify a bulk refusal without a reason is refused as a whole | Main | A pending request the signed-in leader can decide. | 1. Send `POST /api/Requests/bulk-change-request-status` with "Rejected", the request and no reason.<br>2. Read the request and its history. | 1. The call returns a bad request response with the message `"A reason is required when refusing."`.<br>2. The request is still pending and has no history. | Request: 1 |
| TC-04 | EXCP-REQ-HRS-REASON-004 | Verify empty and blank reasons are refused and padded reasons are accepted | Regression | - | 1. Check a missing reason, an empty reason, a reason of spaces and tabs, a normal reason and a reason with spaces around it. | 1. The first three need a reason.<br>2. The last two are accepted. | Reasons: none, "", "   ", "not suitable", "  padded  " |
| TC-05 | EXCP-REQ-HRS-REASON-005 | Verify a reason of 500 characters is accepted and 501 is too long | Edge | - | 1. Check a reason of exactly 500 characters, one of 501 characters and one of 500 characters with spaces around it. | 1. 500 characters are accepted.<br>2. 501 characters are refused with `"The refusal reason is too long (500 characters at most)."`.<br>3. The spaces around the third reason are ignored before counting. | Reasons: 500, 501, 500 padded |
