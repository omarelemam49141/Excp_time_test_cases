# Employee display order (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: `-`
- APIs: `GET /api/user-display-order`, `PUT /api/user-display-order`, `POST /api/Reports/employee-hours-report/bulk`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Custom Account/SaveUserDisplayOrderBuilder.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Account/Fluent validations/SaveUserDisplayOrderInputValidation.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportService.cs`
- Related docs: `docs/backend/technical/user-display-order-api.md`, `docs/backend/technical/bulk-employee-hours-report-api.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Account/UserDisplayOrderTests.cs`

## Scope

- One company-wide employee order, saved by an Admin or HR user and used to order the bulk hours report rows.
- Other roles (Leader, Employee) get 403 on both order endpoints.
- Employees without a saved position come last, sorted by name.

## Test scenarios

- Input validation
- Positions follow the order sent
- Users not sent keep their relative order
- Unknown ids are rejected
- Report row sort
- Roles allowed to order

## Test cases

### Wave 1 — Saving the order

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-USER-ORDER-001 | Verify empty, invalid and duplicate id lists are rejected. | Negative | - | 1. Send an empty list.<br>2. Send a non-GUID id.<br>3. Send the same id twice.<br>4. Send two valid distinct ids. | 1. The first three are invalid.<br>2. The last one is valid. | `src/Excp.HRSystem.Application.Contracts/Entities/Account/Fluent validations/SaveUserDisplayOrderInputValidation.cs` |
| TC-02 | EXCP-USER-ORDER-002 | Verify positions are assigned 1..N in the order sent. | Main | - | 1. Save the order c, a, b. | 1. c is 1, a is 2, b is 3. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/SaveUserDisplayOrderBuilder.cs` |
| TC-03 | EXCP-USER-ORDER-003 | Verify users not sent keep their relative order after the sent ones and never-ordered users stay without a position. | Edge | EXCP-USER-ORDER-002 | 1. Users with positions 1 and 2, one never ordered, one new.<br>2. Save only the new user. | 1. The new user is 1, the old ones become 2 and 3 in the same relative order.<br>2. The never-ordered user stays empty and is not updated. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/SaveUserDisplayOrderBuilder.cs` |
| TC-04 | EXCP-USER-ORDER-004 | Verify an unknown user id returns bad request and writes nothing. | Negative | EXCP-USER-ORDER-002 | 1. Save a list that contains one id that is not a user. | 1. The response is 400.<br>2. No user is updated. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/SaveUserDisplayOrderBuilder.cs` |

### Wave 2 — Report ordering

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-05 | EXCP-USER-ORDER-005 | Verify the report sort puts ordered users first and the rest by name. | Main | EXCP-USER-ORDER-002 | 1. Users: zed (2), bob (1), amy and carl without a position.<br>2. Sort with the report rule. | 1. Ordered users come first: bob, then zed.<br>2. Users without a position follow by name: amy, then carl. | `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportService.cs` |
