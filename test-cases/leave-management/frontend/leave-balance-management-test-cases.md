# Leave Balance Management Frontend Test Cases 🧪

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `frontend`
- Routes: `/admin/employee-leave-balances`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/leave-management/employee-leave-balances/`, `src/app/core/services/leave-management.service.ts`, `src/app/core/models/leave.model.ts`, `src/app/features/admin-leader/admin/components/employee-leave-balances-redirect/employee-leave-balances-redirect.component.ts`
- Related docs: `docs/frontend/technical/leave-balance-management-page.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/employee-leave-balances


## Test scenarios

- Single employee allocation with computed final type.
- Single allocation validation errors.
- Existing balance edit with password and reason.
- Bulk allocation for all users and selected users.
- Change history display and undo flow.
- Localization and RTL checks.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-BALANCE-001 | Verify Single allocation happy path | Main | - | 1. Select employee without balances for target year.<br>2. Enter total + first type value.<br>3. Verify last type auto-fills.<br>4. Submit and verify success message + table refresh. | - | - |
| TC-02 | EXCP-LEAVE-BALANCE-002 | Verify Single allocation sum mismatch | Edge | - | 1. Enter values that do not match total.<br>2. Verify validation error and submit blocked. | - | - |
| TC-03 | EXCP-LEAVE-BALANCE-003 | Verify Single allocation negative value | Edge | - | 1. Enter negative days in a type field.<br>2. Verify invalid control and no submission. | - | - |
| TC-04 | EXCP-LEAVE-BALANCE-004 | Verify Edit existing balance (valid password) | Main | - | 1. Click edit on row.<br>2. Fill new value + reason + correct password.<br>3. Save and verify row updates + history appends. | - | - |
| TC-05 | EXCP-LEAVE-BALANCE-005 | Verify Edit existing balance (invalid password) | Edge | - | 1. Use wrong password.<br>2. Verify update is rejected and value stays unchanged. | - | - |
| TC-06 | EXCP-LEAVE-BALANCE-006 | Verify Bulk allocate all | Main | - | 1. Switch to bulk mode, target all, fill allocations.<br>2. Confirm dialog.<br>3. Verify summary text appears with allocated/skipped counts. | - | - |
| TC-07 | EXCP-LEAVE-BALANCE-007 | Verify Bulk allocate selected | Main | - | 1. Choose selected mode and mark a subset.<br>2. Apply and verify only selected users are considered. | - | - |
| TC-08 | EXCP-LEAVE-BALANCE-008 | Verify Undo from history | Main | - | 1. Enter password in a history row.<br>2. Click undo and verify success + refreshed values. | - | - |
| TC-09 | EXCP-LEAVE-BALANCE-009 | Verify Undo disabled for already undone logs | Main | - | 1. Verify previously undone rows cannot be undone again. | - | - |
| TC-10 | EXCP-LEAVE-BALANCE-010 | Verify Localization check | Main | - | 1. Switch language EN/AR.<br>2. Verify new keys render and Arabic text appears correctly. | - | - |
