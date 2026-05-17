# Leave Balance Management API Test Cases 🧪

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `backend`
- Routes: -
- APIs: `/api/leave-balances`
- Related code: `src/Excp.HRSystem.Application/Services/Leave/EmployeeLeaveBalancesAppService.cs`, `src/Excp.HRSystem.Application/Services/Leave/LeaveBalanceService.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Leave/Dtos/BalanceManagementDtos.cs`, `src/Excp.HRSystem.Domain/Entities/Leave/EmployeeLeaveBalance.cs`, `src/Excp.HRSystem.Domain/Entities/Leave/LeaveBalanceChangeLog.cs`
- Related docs: `docs/backend/technical/leave-policy-carry-over-by-type.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/api/leave-balances`


## Test scenarios

- Single allocate for employee with no existing rows.
- Single allocate blocked for existing year/type.
- Bulk allocate to all active users and skip users with existing balances.
- Bulk allocate to selected users only.
- Edit existing balance with valid/invalid password.
- Undo history record once and reject second undo.
- Get change log by employee and year filter.
- Get employees without balance by year.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-ANG-BALANCE-001 | Verify Single allocate success | Main | - | 1. Given employee has no rows in year 2026.<br>2. When calling `POST /allocate`.<br>3. Then rows are created and `AdminSingleAllocate` logs are inserted. | - | - |
| TC-02 | EXCP-LEAVE-ANG-BALANCE-002 | Verify Single allocate reject existing | Edge | - | 1. Given employee already has type/year row.<br>2. When calling `POST /allocate`.<br>3. Then response is bad request and no new rows are created. | - | - |
| TC-03 | EXCP-LEAVE-ANG-BALANCE-003 | Verify Bulk allocate all success/skip mix | Main | - | 1. Given 10 active employees, 3 already have year rows.<br>2. When calling `POST /bulk-allocate` without `employeeIds`.<br>3. Then 7 allocated, 3 skipped with reasons. | - | - |
| TC-04 | EXCP-LEAVE-ANG-BALANCE-004 | Verify Bulk allocate selected only | Main | - | 1. Given specific `employeeIds`.<br>2. When calling `POST /bulk-allocate`.<br>3. Then only requested users are considered. | - | - |
| TC-05 | EXCP-LEAVE-ANG-BALANCE-005 | Verify Edit with correct password | Main | - | 1. Given admin password is valid.<br>2. When calling `PUT /{id}`.<br>3. Then `AllocatedDays` changes and `AdminEdit` log is added. | - | - |
| TC-06 | EXCP-LEAVE-ANG-BALANCE-006 | Verify Edit with wrong password | Edge | - | 1. When calling `PUT /{id}` with invalid password.<br>2. Then request fails and row remains unchanged. | - | - |
| TC-07 | EXCP-LEAVE-ANG-BALANCE-007 | Verify Undo success | Main | - | 1. Given an editable history record not yet undone.<br>2. When calling `POST /undo/{changeLogId}` with valid password.<br>3. Then balance is restored, original log marked undone, and `Undo` log created. | - | - |
| TC-08 | EXCP-LEAVE-ANG-BALANCE-008 | Verify Undo reject already-undone | Edge | - | 1. Given history record has `IsUndone = true`.<br>2. When calling undo endpoint.<br>3. Then request is rejected. | - | - |
| TC-09 | EXCP-LEAVE-ANG-BALANCE-009 | Verify Change log retrieval | Main | - | 1. When calling `GET /change-log/{employeeId}?year=2026`.<br>2. Then list is ordered by latest first and contains old/new/reason/user metadata. | - | - |
| TC-10 | EXCP-LEAVE-ANG-BALANCE-010 | Verify Employees without balance | Main | - | 1. When calling `GET /without-balance?year=2026.<br>2. Then response includes only active employees missing year rows. | - | - |
