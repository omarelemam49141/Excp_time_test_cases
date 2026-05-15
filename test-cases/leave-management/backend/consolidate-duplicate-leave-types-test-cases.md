# Consolidate duplicate LeaveTypes — test cases

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Duplicate leave type IDs are fully consolidated to canonical IDs without losing request/balance history.
- `EmployeeLeaveBalances` merge logic preserves totals and avoids unique-index conflicts.
- `AutoApproveLeaveRanges.LeaveTypeIds` is normalized after ID mapping.
- Duplicate `LeaveTypes` rows are soft-deleted only after dependencies are moved.


## Test cases

### TC-LTC-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-HRS-CONSOLIDATE-001 | Verify Preview mode safety | Main | - | 1. Set `@PreviewOnly = 1`; execute script; re-check counts | Script runs successfully and rolls back; data remains unchanged | - |

### TC-LTC-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-LEAVE-HRS-CONSOLIDATE-002 | Verify Requests remap | Main | - | 1. Seed requests with `LeaveTypeId` in `15,23,16,24`; run commit mode | Old IDs are replaced with `12`/`13`; no old IDs remain in active requests | - |

### TC-LTC-03

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-LEAVE-HRS-CONSOLIDATE-003 | Verify RequestTypes remap | Main | - | 1. Seed request types with duplicate IDs; run commit mode | Old IDs replaced with canonical IDs in active request types | - |

### TC-LTC-04

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-LEAVE-HRS-CONSOLIDATE-004 | Verify Balance non-conflict remap | Main | - | 1. Employee/year has one old row only (no canonical row) | Row is preserved as keeper and canonical `LeaveTypeId` is applied | - |

### TC-LTC-05

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-LEAVE-HRS-CONSOLIDATE-005 | Verify Balance conflict merge | Main | - | 1. Employee/year has canonical row + one or more old rows | Keeper row totals equal sum of all rows; extra rows are soft-deleted | - |

### TC-LTC-06

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-LEAVE-HRS-CONSOLIDATE-006 | Verify BalanceId linkage preservation | Main | - | 1. `LeaveBalanceChangeLogs.BalanceId` points to merged-away balance row | Log `BalanceId` is re-pointed to keeper row; no orphaned linkage | - |

### TC-LTC-07

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-LEAVE-HRS-CONSOLIDATE-007 | Verify ChangeLog LeaveTypeId remap | Main | - | 1. Seed logs with `LeaveTypeId` in old IDs | `LeaveTypeId` values are remapped to `12`/`13` | - |

### TC-LTC-08

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-LEAVE-HRS-CONSOLIDATE-008 | Verify Auto-approve CSV normalization | Main | - | 1. Seed `AutoApproveLeaveRanges.LeaveTypeIds` with values like `15,23,12,24,16` | Stored value becomes canonical, de-duplicated, sorted (e.g. `12,13`) | - |

### TC-LTC-09

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-LEAVE-HRS-CONSOLIDATE-009 | Verify LeaveTypes soft delete | Main | - | 1. Run commit mode after all remaps | LeaveTypes `15,16,23,24` have `IsDeleted=1`; `12,13 remain active | - |

### TC-LTC-10

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-LEAVE-HRS-CONSOLIDATE-010 | Verify Post-flight integrity | Main | - | 1. Run all verification queries after commit | Zero active references to old IDs in affected tables; script reports success | - |
