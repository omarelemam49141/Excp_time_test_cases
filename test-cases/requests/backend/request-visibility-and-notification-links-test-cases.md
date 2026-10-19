# Request Visibility And Notification Links — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`, `GET /api/Requests/getById`, `PATCH /api/Requests/cancel-reqeust`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestReadAccess.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CancelRequestBuilder.cs`
- Related docs: `docs/backend/technical/requests-list-leader-own-and-hr-access.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestReadAccessTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/CancelRequestServiceTests.cs`

## Scope

This document covers three server-side rules found while testing the request notification flow: a Leader can list the requests they submitted themselves, the HR role can call the requests API (so an HR notification link opens), and a request cancelled by someone else sends the requester a link they can open.

## Test pages

- `POST /api/Requests/get-requests-paged-filtered-list`
- `GET /api/Requests/getById`
- `PATCH /api/Requests/cancel-reqeust`

## Test scenarios

- A Leader's own submitted requests appear in their own list.
- A Leader still cannot widen the list to other people's requests.
- HR can read requests but cannot approve or reject them.
- The requester and the reviewers each get a notification link to a page they can open.

## Test cases

### Visibility and access

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-REQ-HRS-READ-007 | Verify a Leader can list the requests they submitted | Main | A Leader has one pending request they submitted | 1. Sign in as the Leader.<br>2. Call the paged list with the Leader's own id as the issuer and no receiver.<br>3. Call it again with another user's id as the issuer. | 1. The first call returns the Leader's own pending request.<br>2. The second call stays inside the Leader's own review inbox and never shows other people's requests. | Leader: "cs-test-leader" | `src/Excp.HRSystem.Application/Services/Requests/RequestReadAccess.cs` |
| TC-02 | EXCP-REQ-HRS-ACCESS-001 | Verify HR can use the requests API but cannot approve or reject | Main | An HR user exists | 1. Sign in as HR.<br>2. Open a request by id.<br>3. Try to approve a pending request. | 1. Opening the request succeeds.<br>2. Approving is refused because only Admin and Leader can decide. | HR: "cs-test-hr" | `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs` |

### Cancel notification links

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-03 | EXCP-REQ-HRS-CANCEL-008 | Verify a request cancelled by an Admin sends each person a link they can open | Main | An Employee has a pending request with a Leader as reviewer | 1. Sign in as an Admin.<br>2. Cancel the Employee's pending request.<br>3. Read the notifications of the Leader and of the Employee. | 1. The Leader's notification opens "/admin-leader/list-requests" for that request.<br>2. The Employee's notification opens "/my-requests" for that request. | Employee: "cs-test-employee"<br>Leader: "cs-test-leader" | `src/Excp.HRSystem.Application/Builders/Services/Requests/CancelRequestBuilder.cs` |
