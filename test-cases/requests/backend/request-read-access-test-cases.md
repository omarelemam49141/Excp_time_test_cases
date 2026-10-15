# Request Read Access — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`, `GET /api/Requests/getById`, `POST /api/Requests/getAll`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestReadAccess.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/GetRequestPagedFilteredListBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/GetRequestByIdBuilder.cs`
- Related docs: `docs/backend/technical/get-requests-paged-filtered-list-leader-inbox.md`, `docs/backend/technical/request-read-access.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestReadAccessTests.cs`

## Scope

This document covers who can read which requests. What a person can see is decided by who they are (from their sign-in), never by the names or ids they send in the call.

Each case is covered by automated tests that run the real requests service and the real list and open-one steps with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `/my-requests`
- `/admin-leader/list-requests`

## Test scenarios

- An employee sees only their own requests, even if the call names someone else.
- A leader sees the requests that are routed to them, and cannot open another person's inbox.
- An administrator keeps the full view and the optional filters.
- Opening one request is allowed only for the person who submitted it, anyone listed on it, an administrator or HR.
- The generic "list all" route is for administrators only.

## Test cases

### Request list

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-READ-001 | Verify an employee only gets their own requests whatever the call asks for | Regression | Employees A and B each submitted requests. Employee A is signed in. | 1. Sign in as employee A.<br>2. Call the list API with no issuer and no receiver.<br>3. Call it again naming employee B as the issuer.<br>4. Call it again naming a leader as the receiver.<br>5. Open the "My requests" page. | 1. Every call returns only employee A's requests.<br>2. None of employee B's requests appear.<br>3. The "My requests" page shows employee A's requests as before. | Issuer id: "employee-b-id" |
| TC-02 | EXCP-REQ-HRS-READ-002 | Verify a leader only gets requests routed to them and cannot open another person's inbox | Regression | Leaders L1 and L2 each have requests routed to them. Leader L1 is signed in. | 1. Sign in as leader L1.<br>2. Call the list API naming L1 as the receiver, as the "Requests" page does.<br>3. Call it again naming employee B as the issuer.<br>4. Call it again naming leader L2 as the receiver. | 1. Step 2 returns the requests routed to L1.<br>2. Step 3 returns only the requests routed to L1 that employee B submitted.<br>3. Step 4 returns a forbidden response and no requests. | Receiver id: "leader-l2-id" |
| TC-03 | EXCP-REQ-HRS-READ-003 | Verify an administrator keeps the full list and the optional filters | Regression | An administrator is signed in. Several employees and leaders have requests. | 1. Sign in as the administrator.<br>2. Call the list API with no filters.<br>3. Call it again naming a leader as the receiver.<br>4. Call it again naming an employee as the issuer. | 1. Step 2 returns requests of everyone.<br>2. Step 3 returns the requests routed to that leader.<br>3. Step 4 returns the requests of that employee. | Receiver id: "leader-l1-id" |

### Open one request

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-REQ-HRS-READ-004 | Verify a person who is not on a request cannot open it | Regression | A request was submitted by employee A and routed to leader L1. Employee B and leader L2 are not on it. | 1. Sign in as employee B and open the request with `GET /api/Requests/getById`.<br>2. Sign in as leader L2 and open it.<br>3. Open an id that does not exist. | 1. Steps 1 and 2 return a forbidden response with no request details.<br>2. Step 3 returns not found. | Request id: "request-of-employee-a" |
| TC-05 | EXCP-REQ-HRS-READ-005 | Verify the issuer, anyone listed on the request, an administrator and HR can open it | Regression | A request was submitted by employee A. Leader L1 can act on it. Leader L3 is only notified about it. | 1. Open the request as employee A.<br>2. Open it as leader L1.<br>3. Open it as leader L3.<br>4. Open it as an administrator and as an HR user who are not on it.<br>5. Open it from a notification as a user who is only notified. | 1. Every call returns the request details.<br>2. The notification opens the request details. | Request id: "request-of-employee-a" |
| TC-06 | EXCP-REQ-HRS-READ-006 | Verify only an administrator can use the generic list-all route | Regression | An employee, a leader and an administrator account exist. | 1. Sign in as the employee and send `POST /api/Requests/getAll`.<br>2. Repeat as the leader.<br>3. Repeat as the administrator. | 1. The employee and the leader get a forbidden response.<br>2. The administrator gets the list. | Page: "1", size: "10" |
