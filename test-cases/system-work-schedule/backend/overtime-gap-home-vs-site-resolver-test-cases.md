# Overtime gap resolver (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `backend`
- Routes: `-`
- APIs: `-`
- Related code: `src/Excp.HRSystem.Application/Attendance/AttendanceNetDurations.cs`, `test/Excp.HRSystem.Application.Tests/Reports/AttendanceNetDurationsOvertimeGapTests.cs`
- Related docs: `docs/backend/technical/overtime-gap-home-vs-site.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Reports/AttendanceNetDurationsOvertimeGapTests.cs`

## Scope

- `AttendanceNetDurations.ResolveOvertimeGapMinutes` workplace truth table.

## Test scenarios

- Site → site gap; Home/None → home gap
- Negative gaps clamp to zero

## Test cases

### Wave 2 — Gap resolver

| ID | Key | Case | Type | Steps | Expected |
|----|-----|------|------|-------|----------|
| TC-01 | EXCP-SCHED-OT-GAP-006 | Verify `ResolveOvertimeGapMinutes` returns site gap when `WorkPlace` is Site. | Main | 1. Call resolver with `Site`, site `30`, home `15`. | 1. Result is `30`. |
| TC-02 | EXCP-SCHED-OT-GAP-007 | Verify `ResolveOvertimeGapMinutes` returns home gap when `WorkPlace` is Home or None. | Main | 1. Call with `Home`, site `30`, home `15`.<br>2. Call with `None`, same gaps. | 1. Both results are `15`. |
| TC-03 | EXCP-SCHED-OT-GAP-008 | Verify negative gap inputs are clamped to zero. | Edge | 1. Call with `Site` and site gap `-5`. | 1. Result is `0`. |
