# Cancel Request — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `PATCH /api/Requests/cancel-reqeust`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CancelRequestBuilder.cs`
- Related docs: `docs/backend/technical/cancel-request-endpoint.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/CancelRequestServiceTests.cs`

## Scope

This document covers the server-side rules of the cancel-request API: the person cancelling is always the signed-in user, only the person who submitted the request or an administrator can cancel it, only a pending request can be cancelled, and a request that a leader is reviewing cannot be cancelled.

Each case is covered by an automated test that runs the real cancel service with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `PATCH /api/Requests/cancel-reqeust`

## Test scenarios

- Only the issuer or an administrator can cancel.
- The name sent in the request body cannot be used to act as someone else.
- Only pending requests can be cancelled.
- A request under review is protected from cancellation.
- Calls without a signed-in user are refused.

## Test cases

### Who may cancel

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-CANCEL-001 | Verify a user who did not submit the request and is not an administrator cannot cancel it | Regression | A pending request was submitted by employee A. Employee B and a leader who is not A's leader of record are signed in one after the other. | 1. Sign in as employee B.<br>2. Send the cancel API for A's request.<br>3. Repeat as the leader.<br>4. Read A's request. | 1. Both calls return a forbidden response.<br>2. The message is `"Only the person who submitted this request, or an administrator, can cancel it."`.<br>3. The request is still pending.<br>4. No history entry is added. | Request id: "pending-request-id" |
| TC-02 | EXCP-REQ-HRS-CANCEL-002 | Verify the name sent in the request body cannot be used to act as another user | Regression | A pending request was submitted by employee A. Employee B is signed in. | 1. Sign in as employee B.<br>2. Send the cancel API for A's request with A's id as the acting user in the body.<br>3. Sign in as A and cancel A's own request with another user's id in the body.<br>4. Read the request history. | 1. Step 2 returns a forbidden response and the request stays pending.<br>2. Step 3 succeeds.<br>3. The history entry shows A as the person who cancelled, not the id sent in the body. | Request id: "pending-request-id" |
| TC-03 | EXCP-REQ-HRS-CANCEL-003 | Verify the issuer can cancel their own pending leave request and the held leave days are given back | Main | Employee A has a pending leave request for 2 days. | 1. Sign in as employee A.<br>2. Send the cancel API for the request.<br>3. Read the request and A's leave balance. | 1. The call returns success.<br>2. The request is cancelled.<br>3. The 2 pending days are returned to A's leave balance once. | Leave days: "2" |
| TC-04 | EXCP-REQ-HRS-CANCEL-004 | Verify an administrator can cancel a pending request submitted by someone else | Main | A pending request was submitted by employee A. An administrator is signed in. | 1. Sign in as the administrator.<br>2. Send the cancel API for A's request.<br>3. Read the request history. | 1. The call returns success.<br>2. The request is cancelled.<br>3. The history entry shows the administrator as the person who cancelled. | Request id: "pending-request-id" |

### Request state

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-REQ-HRS-CANCEL-005 | Verify a request that is already approved, rejected or cancelled cannot be cancelled | Regression | Three leave requests are "Approved", "Rejected" and "Cancelled". An administrator is signed in. | 1. Sign in as the administrator.<br>2. Send the cancel API for each request.<br>3. Read each request and the leave balance. | 1. Every call returns a conflict response.<br>2. The message is `"Only a pending request can be cancelled."`.<br>3. The requests keep their status.<br>4. No leave days are given back. | Statuses: "Approved", "Rejected", "Cancelled" |
| TC-06 | EXCP-REQ-HRS-CANCEL-006 | Verify a request under review by a leader cannot be cancelled | Regression | A pending request is locked by a leader who is reviewing it. | 1. Sign in as the employee who submitted it and send the cancel API.<br>2. Sign in as an administrator and send the cancel API. | 1. The employee gets a conflict response with `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`.<br>2. The administrator gets a conflict response with `"This request is locked by another reviewer. Please reload before taking action."`.<br>3. The request is still pending. | Request id: "locked-request-id" |

### Authentication

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-REQ-HRS-CANCEL-007 | Verify the cancel API refuses a call without a signed-in user | Regression | A pending request exists. | 1. Send the cancel API without a sign-in token, with the issuer's id in the body. | 1. The call returns an unauthorized response.<br>2. The request is still pending. | Request id: "pending-request-id" |
