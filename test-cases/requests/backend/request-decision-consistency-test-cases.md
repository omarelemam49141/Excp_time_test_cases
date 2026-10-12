# Request Decision Consistency — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/change-reqeust-status`, `POST /api/Requests/bulk-change-request-status`, `POST /api/AttendanceOverTime/Accept-overtime`, `POST /api/AttendanceOverTime/Refuse-overtime`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`
- Related docs: `docs/backend/technical/request-decision-consistency.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionServiceWiringTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/OvertimeDecisionEndpointTests.cs`

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
