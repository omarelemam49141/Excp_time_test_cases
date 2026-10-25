# Month shortage and overtime (backend) Test Cases

## Metadata
- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/AttendanceRecord/End-work`, `POST /api/attendance-overtime/Request-overtime`, `POST /api/attendance-overtime/Accept-overtime`
- Related code: `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs`
- Related docs: `docs/backend/technical/month-shortage-overtime.md`
- Automation: `test/Excp.HRSystem.Application.Tests/WorkSchedule/MonthShortageOvertimeTests.cs`

## Scope

Working-month period used for the monthly overtime and coverage balances.

## Test scenarios

- Period start from default day and override

## Test cases

### Period

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-MONTH-PERIOD-001 | Verify open period starts on the previous default day when today is before this month’s start day. | Main | - | 1. Default start day 26, as-of 18 Oct 2026, no override. | 1. Period start is 26 Sep 2026. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs` |
| TC-02 | EXCP-MONTH-PERIOD-002 | Verify an already-occurred month override becomes the open period start. | Main | EXCP-MONTH-PERIOD-001 | 1. Default day 26, October override 5 Oct 2026, as-of 18 Oct 2026. | 1. Period start is 5 Oct 2026. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs` |
