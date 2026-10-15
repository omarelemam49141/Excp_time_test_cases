# Request Decision Consistency — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/change-reqeust-status`, `POST /api/Requests/bulk-change-request-status`, `POST /api/AttendanceOverTime/Accept-overtime`, `POST /api/AttendanceOverTime/Refuse-overtime`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`
- Related docs: `docs/backend/technical/request-decision-consistency.md`, `docs/backend/technical/bulk-change-request-status.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionServiceWiringTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/RequestDecisionSqliteTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/OvertimeDecisionEndpointTests.cs`

## Scope

This document covers the rule that a request and the overtime linked to it never disagree: deciding the request decides the overtime, and an overtime cannot be accepted or refused once its request was decided.

Each case is covered by automated tests that run the real decision services with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `/admin-leader/list-requests`

## Test scenarios

- Approving or rejecting a request that has an overtime also approves or rejects that overtime.
- An overtime that is no longer pending is never overwritten.
- Accepting or refusing an overtime whose request was already decided is refused.

## Test cases

### Request decides overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-DECISION-001 | Verify deciding a request also decides its pending overtime | Main | A pending overtime request exists. The signed-in leader is an actionable receiver and not the issuer. | 1. Send `POST /api/Requests/change-reqeust-status` with "Approved".<br>2. Open the pending overtime tab.<br>3. Repeat with a second overtime request and "Rejected".<br>4. Repeat with a request sent through `POST /api/Requests/bulk-change-request-status`. | 1. The request is approved and its overtime is approved.<br>2. The overtime is no longer in the pending tab.<br>3. The second overtime is rejected.<br>4. The bulk call gives the same result.<br>5. A call refused by the routing rules leaves the overtime pending. | Overtime ids: "51", "52" |
| TC-02 | EXCP-REQ-HRS-DECISION-002 | Verify an overtime that is not pending is never overwritten | Regression | A pending request is linked to an overtime that is already approved, rejected or has the fixed "within overtime gap" status. | 1. Send `POST /api/Requests/change-reqeust-status` with "Rejected" for the request. | 1. The request is rejected.<br>2. The overtime keeps its status.<br>3. A request with no overtime, or whose overtime row is missing, is still decided normally. | Overtime statuses: "Approved", "Rejected", "WithinOvertimeGap" |

### Overtime respects request state

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-REQ-HRS-DECISION-003 | Verify an overtime cannot be accepted or refused once its request was decided | Regression | An overtime is still pending but its request is approved, rejected or cancelled (for example it was decided before this rule existed). The leader is an actionable receiver. | 1. Send `POST /api/AttendanceOverTime/Accept-overtime`.<br>2. Send `POST /api/AttendanceOverTime/Refuse-overtime` with a reason.<br>3. Send the old `GET` Refuse-overtime route. | 1. Every call returns a conflict response.<br>2. The message is `"This request was already decided and cannot be approved or rejected again."`.<br>3. The request and the overtime are unchanged. | Request statuses: "Approved", "Rejected", "Cancelled" |

### Allowed statuses and failed side effects

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-REQ-HRS-DECISION-004 | Verify a decision with any status other than approved or rejected is refused without a server error | Regression | A pending request exists. The signed-in leader is an actionable receiver. | 1. Send `POST /api/Requests/change-reqeust-status` with each status in the test data.<br>2. Send it with "Approved" and with "Rejected". | 1. Each call in step 1 returns a validation error and not a server error (500).<br>2. The request stays pending.<br>3. The calls in step 2 succeed. | Statuses: "Pending", "Cancelled", "1", "Whatever" |
| TC-05 | EXCP-REQ-HRS-DECISION-005 | Verify a leave decision is not saved when the leave balance or attendance update fails | Regression | A pending leave request exists. The leave balance update is made to fail (for example the balance row is missing). | 1. Send `POST /api/Requests/change-reqeust-status` with "Rejected".<br>2. Read the request, the leave balance and the request history.<br>3. Repair the balance and send the same call again. | 1. The first call returns an error with the message `"The leave balance or attendance could not be updated, so the decision was not saved. Please try again."`.<br>2. The request is still pending and no history row is added.<br>3. The second call succeeds and the pending days are released. | Leave days: "2" |

### Bulk transactions, duplicates and item cap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-REQ-HRS-DECISION-006 | Verify each bulk item is saved or rolled back on its own | Main | Three pending requests. The signed-in leader can decide the first and third; the second belongs to another leader's team, or its leave balance update is made to fail. | 1. Send `POST /api/Requests/bulk-change-request-status` with "Approved" and the three requests in order.<br>2. Read the three requests. | 1. The response shows success, failure, success.<br>2. The first and third requests are approved.<br>3. The second request is unchanged and has no history row. | Items: 3 |
| TC-07 | EXCP-REQ-HRS-DECISION-007 | Verify repeated items in one bulk call are decided once | Regression | A pending request linked to an overtime, and a pending overtime without a request. | 1. Send the bulk call with the request twice (second time in capital letters), the request's own overtime, the overtime-only item twice.<br>2. Read the response and the request history. | 1. Each request and overtime is decided once.<br>2. The response lists only the unique items and shows how many were skipped as repeated.<br>3. The request has one history row. | Repeated items: 4 |
| TC-08 | EXCP-REQ-HRS-DECISION-008 | Verify a bulk call is limited to 200 items | Regression | The signed-in leader has more than 200 pending requests. | 1. Send the bulk call with 201 items.<br>2. Send it with exactly 200 items. | 1. The first call returns a bad-request response with the message `"A single bulk action can include at most 200 items. Select fewer items and try again."` and changes nothing.<br>2. The second call is processed. | Items: 201, 200 |
| TC-09 | EXCP-REQ-HRS-DECISION-009 | Verify bulk overtime decisions are saved one by one and readiness corrections are kept | Regression | Two pending overtime items of different employees with pending requests. The first employee's decision fails to save; for a separate run, one employee's day is not ready. | 1. Send the bulk call with "Approved" for both overtime items.<br>2. Repeat with the not-ready employee only. | 1. The failed item is reported as failed and its overtime and request stay pending.<br>2. The other item is approved together with its request.<br>3. For the not-ready day nothing is approved, the response shows the readiness message and the automatic day corrections stay saved. | Overtime items: 2 |
| TC-10 | EXCP-REQ-HRS-DECISION-010 | Verify on a real database that a failing bulk item rolls back alone and the others stay saved | Main | Three pending requests the signed-in leader can decide. The second is a leave request whose balance update fails. | 1. Send `POST /api/Requests/bulk-change-request-status` with "Approved" and the three requests in order.<br>2. Read the three requests, their history and the notifications. | 1. The response shows two successes and one failure, in item order.<br>2. The first and third requests are approved.<br>3. The second request is still pending and has no history and no notification.<br>4. Only the first and third requests' employees receive a notification. | Requests: 3 |
