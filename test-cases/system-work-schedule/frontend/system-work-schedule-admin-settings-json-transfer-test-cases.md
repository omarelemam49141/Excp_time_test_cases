# System Work Schedule Admin Settings JSON Transfer - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/system-work-schedule`


## Test scenarios

- Export full admin settings JSON from `/admin/system-work-schedule`
- Import valid JSON and apply full settings bundle
- Validate error handling for empty/invalid/schema-mismatch payloads
- Verify localization for transfer panel actions and messages


## Test cases

### General

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SCHED-ADMIN-SETTINGS-001 | Verify Export full admin settings JSON from `/admin/system-work-schedule` | Main | - | 1. Export full admin settings JSON from `/admin/system-work-schedule | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-SCHED-ADMIN-SETTINGS-002 | Verify Import valid JSON and apply full settings bundle | Main | - | 1. Import valid JSON and apply full settings bundle | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-SCHED-ADMIN-SETTINGS-003 | Verify Validate error handling for empty/invalid/schema-mismatch payloads | Edge | - | 1. Validate error handling for empty/invalid/schema-mismatch payloads | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-SCHED-ADMIN-SETTINGS-004 | Verify localization for transfer panel actions and messages | Main | - | 1. Verify localization for transfer panel actions and messages | The result matches the scenario description when you follow the actions in the product. | - |
