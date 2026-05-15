# Update Overtime with Null EndTime — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

APIs:
- `PUT api/attendance-overtime/Update-overtime-with-breaks`
- `POST api/attendance-record/Bulk-apply-attendance-changes` (when `overtimeUpdates` include breaks)

**Bug 1 (overtime in progress):** When an overtime is still in progress (`endTime = null`), updating its `startTime`
returned HTTP 500 because `_overTimePeriod` was never populated and two downstream builder
steps accessed it without a null guard.

**Bug 2 (break with null `End` in DTO):** `OverTimeBreakDTO.End` is `TimeOnly?`. If a stored or mapped
break has a null `End`, `_ConvertAttendanceBreakDtoToStartEndTimePeriodDto` used `.Value` and threw
`InvalidOperationException` during break duplicate checks (e.g. bulk apply with new breaks, id `0`).

Affected builder in `UpdateAttendanceOverTimeWithBreaksBuilder`:
- `CheckIfTheUpdatedOverTimeIntersectsWithTheAttendanceRecord` / `GetOtherAttendanceOverTimesThatIntersectWithTheUpdatedOverTime` (Bug 1)
- `_ConvertAttendanceBreakDtoToStartEndTimePeriodDto` — treat missing break `End` as `Start` for time-period conversion (Bug 2)


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Update startTime while overtime is still in progress (endTime = null) | Main | 200 OK — overtime updated successfully |
- | Update startTime on a completed overtime (endTime provided) | Regression | 200 OK — existing behaviour unchanged |
- | Update startTime + endTime on a completed overtime | Regression | 200 OK — intersection checks still execute |
- | Updated startTime intersects with attendance record (endTime provided) | Edge | 409 Conflict — intersection with work time |
- | Updated time period intersects with another overtime (endTime provided) | Edge | 409 Conflict — intersection with another overtime |
- | Update startTime while endTime is null and the new start equals the existing start | Edge | 304 Not Modified — no change detected |
- | Payload with endTime = null and non-empty breaks list | Edge | 409 Conflict — breaks validation requires a closed overtime period |
- | Bulk apply: `overtimeUpdates` with new breaks (`id: 0`) when an **existing** break row has null `End` in DTO | Main | 200/expected business outcome — no 500 on duplicate-break validation |
- | Bulk apply: mixed existing break id + new breaks | Regression | Success path unchanged; duplicate detection still works |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-UPDATE-NULL-001 | Verify Update startTime while overtime is in progress (main fix) | Main | - | 1. TC-1 — Update startTime while overtime is in progress (main fix) | - | - |
| TC-02 | EXCP-OT-HRS-UPDATE-NULL-002 | Verify Update startTime on a completed overtime (regression) | Main | - | 1. TC-2 — Update startTime on a completed overtime (regression) | - | - |
| TC-03 | EXCP-OT-HRS-UPDATE-NULL-003 | Verify No change while endTime is null | Main | - | 1. TC-3 — No change while endTime is null | - | - |
| TC-04 | EXCP-OT-HRS-UPDATE-NULL-004 | Verify Intersection with attendance record still blocked when endTime is provided | Edge | - | 1. TC-4 — Intersection with attendance record still blocked when endTime is provided | - | - |
| TC-05 | EXCP-OT-HRS-UPDATE-NULL-005 | Verify Intersection with another overtime still blocked when endTime is provided | Edge | - | 1. TC-5 — Intersection with another overtime still blocked when endTime is provided | - | - |
| TC-06 | EXCP-OT-HRS-UPDATE-NULL-006 | Verify Bulk apply overtime updates when a loaded break has null `End` (main fix for Bug 2) | Main | - | 1. TC-6 — Bulk apply overtime updates when a loaded break has null `End (main fix for Bug 2) | - | - |
