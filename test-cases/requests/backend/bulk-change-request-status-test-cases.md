# Bulk Change Request Status — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/bulk-change-request-status`, `POST /api/Requests/change-reqeust-status`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionGuards.cs`
- Related docs: `docs/plans/excptime-requests-workflow-improvements.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionAuthorizationTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionServiceWiringTests.cs`

## Scope

This document covers the server-side rules of the bulk approve/refuse API: only "Approved" and "Rejected" are accepted, every request and every overtime entry goes through the same who-may-decide rules as the single approve/refuse API, and an overtime entry whose linked request is already decided or cancelled is refused as a whole, so neither the overtime entry nor the request is changed.

Each case is covered by automated tests that run the real bulk and single approve/refuse services with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `POST /api/Requests/bulk-change-request-status`

## Test scenarios

- Bulk accepts only the two decision statuses.
- A leader who is not allowed to decide a request cannot decide it through bulk either.
- The designated final approver rule is the same in bulk and single.
- A leader who is only notified cannot decide in bulk.
- Overtime entries with a linked request follow the same decision rules in bulk.
- Nobody can approve or refuse their own request or overtime, one by one or in bulk.
- An overtime entry whose linked request is no longer pending is refused as a whole in bulk (nothing is changed).

## Test cases

### Status validation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-BULK-STATUS-001 | Verify bulk refuses any status other than "Approved" or "Rejected" | Regression | A pending request exists and the signed-in leader is allowed to decide it. | 1. Sign in as the leader.<br>2. Send `POST /api/Requests/bulk-change-request-status` with the pending request and the new status `"Cancelled"`.<br>3. Repeat with `"Pending"`, `"1"` and `"Whatever"`.<br>4. Read the request again. | 1. Every call returns a bad request response.<br>2. The message is `"NewStatus must be Approved or Rejected."`.<br>3. The request is still pending. | Request id: "pending-request-id"<br>New status: "Cancelled" |

### Who may decide

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-REQ-HRS-BULK-STATUS-002 | Verify a leader who is not a receiver of the request cannot approve or reject it in bulk | Regression | A pending request belongs to another team. The signed-in leader is not a receiver of it. | 1. Sign in as the leader.<br>2. Send the bulk API with this request and the new status `"Approved"`.<br>3. Send it again with `"Rejected"`.<br>4. Send the single approve API for the same request and compare. | 1. The bulk response is success with `"failedCount": 1` for each call.<br>2. The item message is `"You cannot approve or reject this request."`.<br>3. The single API gives the same message.<br>4. The request is still pending. | Request id: "other-team-request-id" |
| TC-03 | EXCP-REQ-HRS-BULK-STATUS-003 | Verify the final approver rule is the same in bulk and single | Regression | A pending request has a designated final approver. The direct leader is a receiver but is not the final approver. | 1. Sign in as the direct leader.<br>2. Send the bulk API with the request and the new status `"Approved"`.<br>3. Send the bulk API with `"Rejected"`.<br>4. Sign in as the final approver and send the bulk API with `"Approved"`. | 1. Step 2 fails for the item with `"Only the designated final team leader can approve this request."`.<br>2. Step 3 succeeds and the request is rejected.<br>3. Step 4 succeeds on a different pending request and it becomes approved. | Request id: "final-approver-request-id" |
| TC-04 | EXCP-REQ-HRS-BULK-STATUS-004 | Verify a leader who is only notified cannot approve or reject in bulk | Regression | A pending request lists the signed-in leader as notify-only. | 1. Sign in as the notified leader.<br>2. Send the bulk API with the request and `"Approved"`.<br>3. Send it again with `"Rejected"`. | 1. Both calls report the item as failed.<br>2. The item message is `"You cannot approve or reject this request."`.<br>3. The request is still pending. | Request id: "notify-only-request-id" |
| TC-05 | EXCP-REQ-HRS-BULK-STATUS-005 | Verify a leader who may decide a request, and an overtime entry linked to it, can still be decided in bulk | Main | A pending request and its pending overtime entry. The signed-in leader is an allowed receiver and there is no other final approver. | 1. Sign in as the leader.<br>2. Send the bulk API with the request and `"Approved"`.<br>3. Send the bulk API with the overtime entry only, for a second similar pair, and `"Approved"`. | 1. Both calls return `"successCount": 1`.<br>2. Both requests are approved.<br>3. Both overtime entries are approved. | Request id: "allowed-request-id"<br>Overtime id: "allowed-overtime-id" |

### Linked request protection

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-REQ-HRS-BULK-STATUS-006 | Verify bulk refuses an overtime entry whose linked request is already decided or cancelled, and changes nothing | Regression | Three pending overtime entries are each linked to a request that is "Cancelled", "Rejected" and "Approved". The signed-in leader is an allowed receiver of all three. A fourth pending overtime entry is linked to a pending request. | 1. Sign in as the leader.<br>2. Send the bulk API with all four overtime entries only and `"Approved"`.<br>3. Read the three decided requests, the four overtime entries and the review locks. | 1. The response shows `"successCount": 1` and `"failedCount": 3`.<br>2. Each of the three refused items has the message `"This request was already decided and cannot be approved or rejected again."`.<br>3. The three refused overtime entries are still pending.<br>4. The three requests keep their status.<br>5. The fourth overtime entry and its request are approved. | Overtime ids: "101", "102", "103", "104" |

### Overtime routing

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-REQ-HRS-BULK-STATUS-007 | Verify a leader who may not decide the linked request cannot decide its overtime entry in bulk | Regression | A pending overtime entry is linked to a pending request. The signed-in leader is not an allowed receiver of that request, or another person is its final approver. | 1. Sign in as the leader.<br>2. Send the bulk API with the overtime entry only and `"Approved"`.<br>3. Send it again with `"Rejected"`.<br>4. Read the overtime entry and the request. | 1. Each call reports the item as failed.<br>2. The message is `"You cannot approve or reject this request."`, or `"Only the designated final team leader can approve this request."` when another person is the final approver and the status is `"Approved"`.<br>3. The overtime entry and the request are still pending. | Overtime id: "201" |

### Own request

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-REQ-HRS-BULK-STATUS-008 | Verify nobody can approve or refuse their own request or overtime, one by one or in bulk | Regression | A pending request was submitted by the signed-in administrator, who is also listed as an allowed receiver of it. A pending overtime entry belongs to the same administrator. | 1. Sign in as the administrator.<br>2. Send the single approve API, then the single refuse API, for the own request.<br>3. Send the bulk API with the own request and `"Approved"`, then `"Rejected"`.<br>4. Send the bulk API with the own overtime entry only and `"Approved"`. | 1. The single calls return a forbidden response.<br>2. The bulk items are reported as failed.<br>3. Every message is `"You cannot approve or reject your own request."`.<br>4. The request and the overtime entry are still pending. | Request id: "own-request-id"<br>Overtime id: "13" |
