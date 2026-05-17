# Leave Policy: Per-Type Carry-Over Toggle - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `frontend`
- Routes: `/admin/leave-policy`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/leave-management/leave-policy/`, `src/app/core/services/leave-management.service.ts`, `src/app/core/models/leave.model.ts`
- Related docs: `docs/frontend/technical/leave-policy-carry-over-by-type.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/leave-policy`


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Load screen | Main | Both carry-over toggles are populated from API |
- | Save toggles | Main | Updated toggle values are sent and persist after reload |
- | Combined save | Main | Toggling carry-over with other policy fields still saves correctly |
- | Localization | Edge | Labels are translated in EN/AR |
- | Error handling | Edge | Save failure does not break form state |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-POLICY-CARRY-OVER-001 | Verify Test 1: Initial load | Main | - | 1. Open `/admin/leave-policy`.<br>2. Verify two new checkboxes are visible:<br>3. Allow carry-over for regular leave<br>4. Allow carry-over for casual leave<br>5. Verify their initial state matches backend response. | - | - |
| TC-02 | EXCP-LEAVE-POLICY-CARRY-OVER-002 | Verify Test 2: Toggle and save | Main | - | 1. Change both checkbox values.<br>2. Click Save.<br>3. Verify success toast appears.<br>4. Refresh page and verify values remain as saved. | - | - |
| TC-03 | EXCP-LEAVE-POLICY-CARRY-OVER-003 | Verify Test 3: Save with other fields | Main | - | 1. Update `regularAnnualDays` and one carry-over toggle in same submit.<br>2. Save and reload.<br>3. Verify all changed values persisted. | - | - |
| TC-04 | EXCP-LEAVE-POLICY-CARRY-OVER-004 | Verify Test 4: Arabic localization | Main | - | 1. Switch app language to Arabic.<br>2. Verify both new labels display Arabic translation text. | - | - |
| TC-05 | EXCP-LEAVE-POLICY-CARRY-OVER-005 | Verify Test 5: API error on save | Edge | - | 1. Simulate network/server error for `updatePolicy.<br>2. Click Save.<br>3. Verify form stays usable and values are not reset unexpectedly. | - | - |
