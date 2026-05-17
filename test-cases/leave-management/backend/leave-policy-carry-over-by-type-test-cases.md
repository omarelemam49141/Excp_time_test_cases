# Leave Policy: Per-Type Carry-Over Toggle - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Services/Leave/LeavePolicyAppService.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Leave/Dtos/LeavePolicyDto.cs`, `src/Excp.HRSystem.Domain/Entities/Leave/LeavePolicy.cs`, `src/Excp.HRSystem.Application/Services/Leave/LeaveTypesAppService.cs`
- Related docs: `docs/backend/technical/leave-policy-carry-over-by-type.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Read policy | Main | `GET /api/leave-policy` returns `regularAllowCarryOver` and `casualAllowCarryOver` |
- | Save policy toggles | Main | `PUT /api/leave-policy` persists both booleans |
- | Update existing rows only | Edge | Only matching leave types (`ANNUAL_REGULAR` / `ANNUAL_CASUAL`) are updated |
- | Missing leave type row | Edge | API remains stable; fallback/default behavior is safe |
- | Authorization | Main | Non-admin cannot update policy |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-HRS-POLICY-CARRY-001 | Verify Test 1: GET contains carry-over toggles | Main | - | 1. Call `GET /api/leave-policy` as authenticated user.<br>2. Verify response includes:<br>3. `regularAllowCarryOver`<br>4. `casualAllowCarryOver` | - | - |
| TC-02 | EXCP-LEAVE-HRS-POLICY-CARRY-002 | Verify Test 2: PUT updates regular/casual carry-over | Main | - | 1. Call `PUT /api/leave-policy` with:<br>2. `regularAllowCarryOver = false`<br>3. `casualAllowCarryOver = true`<br>4. Verify success response.<br>5. Query DB `LeaveTypes` for codes `ANNUAL_REGULAR`, `ANNUAL_CASUAL`.<br>6. Verify `AllowCarryOver` values are updated accordingly. | - | - |
| TC-03 | EXCP-LEAVE-HRS-POLICY-CARRY-003 | Verify Test 3: Standard policy fields still saved | Main | - | 1. In same PUT request, also change one normal policy field (e.g., `regularAnnualDays`).<br>2. Verify singleton `LeavePolicy` row is updated as before. | - | - |
| TC-04 | EXCP-LEAVE-HRS-POLICY-CARRY-004 | Verify Test 4: Non-admin authorization | Edge | - | 1. Call `PUT /api/leave-policy with user lacking admin role.<br>2. Verify forbidden/unauthorized according to auth middleware. | - | - |
| TC-05 | EXCP-LEAVE-HRS-POLICY-CARRY-005 | Verify Test 5: Missing leave type rows | Main | - | 1. Temporarily remove one of the annual leave types in test environment (or seedless DB state).<br>2. Call GET/PUT.<br>3. Verify API does not crash; existing rows update normally and missing row is skipped. | - | - |
