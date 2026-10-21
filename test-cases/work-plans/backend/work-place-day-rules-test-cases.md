# Work place day rules — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `work-plans`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/work-place-dashboard/summary`, `POST /api/work-place-dashboard/employees`
- Automation: `test/Excp.HRSystem.Application.Tests/WorkPlans/WorkPlaceDayEvaluatorTests.cs`
- Related code: `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs`
- Related docs: `docs/backend/technical/work-plans-and-work-place-dashboard.md`

## Scope

- How one employee on one date is classified: planned place, status and compliance, from the plan, an approved work-from-home request, leave, check-in and the work-place value of the attendance record.

## Test pages

- `POST /api/work-place-dashboard/summary`
- `POST /api/work-place-dashboard/employees`

## Test scenarios

- Verify the planned place comes from the weekly plan, and an approved work-from-home request turns the day into a home day.
- Verify home on a company day without a request is a violation, while company on a home day is information only.
- Verify weekends, holidays, leave, absence, future days and unrecorded places are classified on their own.

## Test cases

### Planned vs actual

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-WORKPLAN-DASH-001 | Verify a home day worked from home is as planned | Main | Employee plan has Wednesday as home. | 1. Evaluate Wednesday 2026-10-21 with a check-in recorded as Home. | 1. Planned place is Home.<br>2. Compliance is as planned. | Date: "2026-10-21" | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-02 | EXCP-WORKPLAN-DASH-002 | Verify a company day worked at the company is as planned | Main | Employee plan has Wednesday as company. | 1. Evaluate Wednesday with a check-in recorded as Site. | 1. Planned place is Site.<br>2. Compliance is as planned. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-03 | EXCP-WORKPLAN-DASH-003 | Verify a company day worked from home without a request is a violation | Main | Employee plan has Wednesday as company, no approved work-from-home request. | 1. Evaluate Wednesday with a check-in recorded as Home. | 1. Compliance is violation.<br>2. Planned place is not from a request. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-04 | EXCP-WORKPLAN-DASH-004 | Verify an approved work-from-home request overrides a company day | Main | Plan has Wednesday as company and an approved work-from-home request covers Wednesday. | 1. Evaluate Wednesday with a check-in recorded as Home. | 1. Planned place is Home.<br>2. Planned by request is true.<br>3. Compliance is as planned, not violation. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-05 | EXCP-WORKPLAN-DASH-005 | Verify company on a home day is information, not a violation | Edge | Employee plan has Wednesday as home. | 1. Evaluate Wednesday with a check-in recorded as Site. | 1. Compliance is company on a home day.<br>2. It is not a violation. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |

### Other day statuses

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-06 | EXCP-WORKPLAN-DASH-006 | Verify a weekend or holiday is not counted | Edge | Day is marked non-working by the work schedule. | 1. Evaluate a planned home day flagged as non-working with a Home check-in. | 1. Status is non-working.<br>2. Compliance is none. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-07 | EXCP-WORKPLAN-DASH-007 | Verify leave, absence and not-yet-checked-in have their own status | Edge | Planned home day. | 1. Evaluate with approved leave and no check-in.<br>2. Evaluate a past day with no check-in.<br>3. Evaluate today with no check-in. | 1. First is on leave.<br>2. Second is absent.<br>3. Third is not checked in yet. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-08 | EXCP-WORKPLAN-DASH-008 | Verify a check-in without a recorded place is unknown | Edge | Company day. | 1. Evaluate a check-in whose work place is None. | 1. Status is present.<br>2. Compliance is unknown. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-09 | EXCP-WORKPLAN-DASH-009 | Verify a day with no plan has no planned place and no violation | Edge | Employee has no approved plan. | 1. Evaluate a day with a Home check-in and no plan. | 1. Planned place is none.<br>2. Compliance is none. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
| TC-10 | EXCP-WORKPLAN-DASH-010 | Verify a future day only reports the planned place | Edge | Planned home day after today. | 1. Evaluate a date after today with no check-in. | 1. Status is upcoming.<br>2. Planned place is Home. | - | `src/Excp.HRSystem.Application/Services/WorkPlans/WorkPlaceDayEvaluator.cs` |
