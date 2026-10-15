# Update Request Ownership — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `PUT /api/Requests/update`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/UpdateRequestBuilder.cs`
- Related docs: `docs/backend/technical/update-request-ownership.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/UpdateRequestOwnershipTests.cs`

## Scope

This document covers the server-side rules of editing a request: only the person who submitted it can edit it, only a pending request can be edited, a request that a leader is reviewing cannot be edited, and the owner of a request cannot be changed by the edit form.

Each case is covered by automated tests that run the real update service with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `/my-requests`

## Test scenarios

- The issuer can still edit their own pending request.
- Nobody else can edit it, whatever their role.
- Approved, rejected and cancelled requests cannot be edited.
- A request under review cannot be edited.
- The edit form cannot hand the request to another person.

## Test cases

### Ownership

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-UPDATE-001 | Verify the issuer can edit their own pending request and cannot change its owner | Main | Employee A has a pending request that no leader is reviewing. | 1. Sign in as employee A.<br>2. On the "My requests" page open the request, change the notes and save.<br>3. Send `PUT /api/Requests/update` for the same request with another person's id as the issuer in the form.<br>4. Read the request. | 1. The page saves the change and shows a success message.<br>2. The second call succeeds.<br>3. The request still belongs to employee A. | Notes: "changed" |
| TC-02 | EXCP-REQ-HRS-UPDATE-002 | Verify nobody except the issuer can edit a request, whatever their role | Regression | A pending request was submitted by employee A. Employee B, a leader and an administrator are not the issuer. | 1. Sign in as employee B and send `PUT /api/Requests/update` for A's request.<br>2. Repeat as the leader and as the administrator.<br>3. Repeat as employee B with employee B's own id in the form as the issuer. | 1. Every call returns a forbidden response.<br>2. The message is `"Only the person who submitted this request can edit it."`.<br>3. The request is unchanged. | Request id: "request-of-employee-a" |

### Request state

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-REQ-HRS-UPDATE-003 | Verify an approved, rejected or cancelled request cannot be edited | Regression | Employee A has three requests: "Approved", "Rejected" and "Cancelled". | 1. Sign in as employee A.<br>2. Send `PUT /api/Requests/update` for each request.<br>3. Sign in as employee B and send it for the approved request. | 1. The calls from employee A return a conflict response.<br>2. The message is `"Only a pending request can be edited."`.<br>3. The call from employee B returns a forbidden response.<br>4. No request changes. | Statuses: "Approved", "Rejected", "Cancelled" |
| TC-04 | EXCP-REQ-HRS-UPDATE-004 | Verify a request under review cannot be edited | Regression | Employee A has a pending request that a leader is reviewing. | 1. Sign in as employee A.<br>2. Send `PUT /api/Requests/update` for the request. | 1. The call returns a conflict response.<br>2. The message is `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`.<br>3. The request is unchanged. | Request id: "locked-request-id" |
| TC-05 | EXCP-REQ-HRS-UPDATE-005 | Verify editing without a sign-in or for an unknown request is refused | Regression | A pending request exists. | 1. Send `PUT /api/Requests/update` without a sign-in token.<br>2. Sign in as an employee and send it for an id that does not exist. | 1. The first call is refused and nothing changes.<br>2. The second call returns not found. | Request id: "00000000-0000-0000-0000-000000000001" |
