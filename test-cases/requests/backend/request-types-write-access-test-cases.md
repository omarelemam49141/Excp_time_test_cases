# Request Types Write Access — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: `/admin/request-types`
- APIs: `POST /api/Request-types/create`, `PUT /api/Request-types/update`, `DELETE /api/Request-types/deleteById`, `GET /api/Request-types/getById`, `POST /api/Request-types/getAll`, `GET /api/Request-types/get-request-types-counts`
- Related code: `src/Excp.HRSystem.Application/Services/RequestTypes/RequestTypesService.cs`
- Related docs: `docs/backend/technical/request-types-write-access.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestTypesWriteGateTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestTypesCountsScopeTests.cs`

## Scope

This document covers who can change request types (the list of request kinds such as leave or advance, with their fields and documents) and who can only read them. Changing is for administrators only. Reading stays open to everyone who needs it to fill in or review a request.

The automated tests check the access rules on each route for every role. The steps below are the end-to-end check on the running API and screens.

## Test pages

- `/admin/request-types`
- `/my-requests`

## Test scenarios

- Only an administrator can add, change or delete a request type.
- Employees, leaders and HR can still read request types.
- The administrator screens keep working.

## Test cases

### Changing request types

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-RTYPES-001 | Verify only an administrator can add, change or delete a request type | Regression | An employee, a leader, an HR user and an administrator exist. A request type exists. | 1. Sign in as the employee and send `POST /api/Request-types/create`, `PUT /api/Request-types/update` and `DELETE /api/Request-types/deleteById` for the request type.<br>2. Repeat as the leader and as the HR user.<br>3. Sign in as the administrator and send the same three calls with valid data.<br>4. Read the request type list. | 1. Every call from the employee, the leader and the HR user returns a forbidden response and changes nothing.<br>2. The administrator's calls succeed.<br>3. The list shows the administrator's changes only. | Request type id: "1" |
| TC-02 | EXCP-REQ-HRS-RTYPES-003 | Verify the administrator screens for request types still work | Regression | An administrator is signed in. | 1. Open `/admin/request-types`.<br>2. Add a request type and save.<br>3. Edit the new request type and save.<br>4. Delete the new request type. | 1. The list opens.<br>2. Each action shows a success message.<br>3. The list reflects each change. | Name: "Test type" |

### Reading request types

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-REQ-HRS-RTYPES-002 | Verify employees, leaders and HR can still read request types | Regression | An employee, a leader and an HR user exist. | 1. Sign in as the employee and open the "My requests" page and the new request dialog.<br>2. Sign in as the leader and open the "Requests" page.<br>3. As each role, send `GET /api/Request-types/getById` and `POST /api/Request-types/getAll`. | 1. The request types appear in the dialog and in the filters.<br>2. The read calls succeed for every role. | Request type id: "1" |

### Counts scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-REQ-HRS-RTYPES-004 | Verify an employee only gets counts of their own requests | Regression | Employees A and B have requests of different types. Employee A is signed in. | 1. Send `GET /api/Request-types/get-request-types-counts` with no filters.<br>2. Send it again naming employee B as the issuer and a leader as the receiver.<br>3. Send it without a sign-in token. | 1. Steps 1 and 2 return counts for employee A's requests only.<br>2. Step 3 is refused. | Issuer id: "employee-b-id" |
| TC-05 | EXCP-REQ-HRS-RTYPES-005 | Verify a leader only gets counts of requests routed to them | Regression | Leaders L1 and L2 each have requests routed to them. Leader L1 is signed in. | 1. Send the counts call naming L1 as the receiver.<br>2. Send it naming employee B as the issuer.<br>3. Send it naming L2 as the receiver. | 1. Step 1 returns counts of the requests routed to L1.<br>2. Step 2 returns only those of employee B that are routed to L1.<br>3. Step 3 returns a forbidden response and no counts. | Receiver id: "leader-l2-id" |
| TC-06 | EXCP-REQ-HRS-RTYPES-006 | Verify an administrator keeps the full counts and the optional filters | Regression | An administrator is signed in. | 1. Send the counts call with no filters.<br>2. Send it naming a leader as the receiver.<br>3. Send it naming an employee as the issuer. | 1. Step 1 returns counts for everyone.<br>2. Steps 2 and 3 return counts for that leader and that employee. | Receiver id: "leader-l1-id" |
