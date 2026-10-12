# Request Delete Route — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `DELETE /api/Requests/deleteById`, `DELETE /api/Requests/cancel-my-request`, `PATCH /api/Requests/cancel-reqeust`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`
- Related docs: `docs/backend/technical/generic-delete-by-id-exposure.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestDeleteByIdRouteTests.cs`

## Scope

This document covers the removal of the direct "delete a request by id" route and the fact that the two real ways to remove a request still work. The direct route let any signed-in user delete any request without any check.

The automated tests prove that the code behind the route deletes nothing and is not marked as an API route. They cannot prove that the running API no longer lists the route, so TC-01 contains that check as a manual step on the running API.

## Test pages

- `/my-requests`

## Test scenarios

- The direct delete route is gone.
- An employee can still cancel their own pending request.
- An administrator can still cancel a pending request.

## Test cases

### Direct delete route

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-DELETE-001 | Verify the direct delete route no longer exists and cannot remove any request | Regression | The API runs the new version. Employee A has a pending request, and employee B and an approved request of someone else exist. | 1. Open the API description page and look for `/api/Requests/deleteById`.<br>2. Sign in as employee B and send `DELETE /api/Requests/deleteById` with the id of A's pending request.<br>3. Repeat with the id of the approved request, as employee B, as a leader and as an administrator.<br>4. Read each request. | 1. The API description has no `/api/Requests/deleteById` path.<br>2. Every call returns not found.<br>3. All requests are still readable by the people allowed to see them and keep their status. | Request id: "request-of-employee-a" |

### Real cancel paths

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-REQ-HRS-DELETE-002 | Verify an employee can still cancel their own pending request and an administrator can still cancel a pending request | Regression | Employee A has a pending request. Another pending request belongs to employee C. | 1. Sign in as employee A.<br>2. On the "My requests" page cancel the pending request.<br>3. Sign in as an administrator and send `PATCH /api/Requests/cancel-reqeust` for employee C's pending request. | 1. The page shows a success message and the request is removed from the list.<br>2. The administrator's call succeeds and the request is cancelled. | Request ids: "pending-request-of-a", "pending-request-of-c" |
