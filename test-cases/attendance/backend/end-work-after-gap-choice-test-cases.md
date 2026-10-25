# End work after-gap overtime choice (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/AttendanceRecord/End-work`, `POST /api/attendance-overtime/Request-overtime`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/EndWorkBuilder.cs`, `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs`
- Related docs: `docs/backend/technical/end-work-after-gap-overtime-choice.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Attendance/EndWorkPostShiftOvertimeRulesTests.cs`

## Scope

- The overtime gap is only a gate. Once the net time after shift end reaches the gap (exactly the gap counts), the employee is asked and the ENTIRE block is requested. Nothing is subtracted for the gap.
- The block is split between Overtime (reason required) and Shortage Coverage (reason optional).

## Test scenarios

- Gate below, at, and above the gap
- Whole block requested, no gap subtraction
- Split between overtime and coverage always adds up to the block
- Coverage larger than the block is clamped

## Test cases

### Wave 1 — Gate and split rules

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-ATT-ENDWORK-AG-001 | Verify time under the gap does not ask the employee. | Main | - | 1. Gap 30 min, net time after shift end 29 min.<br>2. Evaluate the gate. | 1. The popup is not required. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
| TC-02 | EXCP-ATT-ENDWORK-AG-002 | Verify exactly the gap asks the employee. | Edge | EXCP-ATT-ENDWORK-AG-001 | 1. Gap 30 min, net time after shift end exactly 30 min. | 1. The popup is required (the threshold is inclusive). | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
| TC-03 | EXCP-ATT-ENDWORK-AG-003 | Verify time over the gap asks the employee. | Main | EXCP-ATT-ENDWORK-AG-002 | 1. Gap 30 min, net time 50 min. | 1. The popup is required. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
| TC-04 | EXCP-ATT-ENDWORK-AG-004 | Verify the whole block is requested with no gap subtraction. | Main | EXCP-ATT-ENDWORK-AG-003 | 1. Gap 30 min, net time 50 min, no split typed. | 1. The request is for all 50 minutes as Overtime.<br>2. Coverage is 0. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs`, `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/EndWorkBuilder.cs` |
| TC-05 | EXCP-ATT-ENDWORK-AG-005 | Verify the split between overtime and coverage adds up to the block. | Main | EXCP-ATT-ENDWORK-AG-004 | 1. Net time 50 min, coverage 30 min, overtime 20 min. | 1. Overtime is 20 min and coverage is 30 min.<br>2. Together they are the whole 50 minutes. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
| TC-06 | EXCP-ATT-ENDWORK-AG-006 | Verify coverage larger than the block is clamped and overtime is never negative. | Edge | EXCP-ATT-ENDWORK-AG-005 | 1. Net time 50 min, coverage 80 min. | 1. Coverage becomes 50 min.<br>2. Overtime is 0. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
| TC-07 | EXCP-ATT-ENDWORK-AG-007 | Verify negative split parts are rejected. | Edge | EXCP-ATT-ENDWORK-AG-005 | 1. Overtime seconds -1. | 1. The split is rejected with `MonthExtraSecondsInvalid`. | `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs` |
