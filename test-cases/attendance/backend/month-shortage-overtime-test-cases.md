# Month shortage and overtime (backend) Test Cases

## Metadata
- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/attendance-overtime/Preview-month-extra-offer`, `POST /api/AttendanceRecord/End-work`, `POST /api/attendance-overtime/Request-overtime`, `POST /api/attendance-overtime/Accept-overtime`
- Related code: `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs`, `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs`, `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthApprovalReclassifier.cs`, `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/EndWorkBuilder.cs`
- Related docs: `docs/backend/technical/month-shortage-overtime.md`
- Automation: `test/Excp.HRSystem.Application.Tests/WorkSchedule/MonthShortageOvertimeTests.cs`

## Scope

Working-month period, offer matrix, end-work split rows, and final-approve reclassification.

## Test scenarios

- Period start from default day and override
- Silent, shortage-only, cross, overtime-only, partial, cancel
- Approve overtime fills hole first

## Test cases

### Period and offer

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-MONTH-PERIOD-001 | Verify open period starts on the previous default day when today is before this month’s start day. | Main | - | 1. Default start day 26, as-of 18 Oct 2026, no override. | 1. Period start is 26 Sep 2026. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs` |
| TC-02 | EXCP-MONTH-PERIOD-002 | Verify an already-occurred month override becomes the open period start. | Main | EXCP-MONTH-PERIOD-001 | 1. Default day 26, October override 5 Oct 2026, as-of 18 Oct 2026. | 1. Period start is 5 Oct 2026. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/WorkingMonthPeriodResolver.cs` |
| TC-03 | EXCP-MONTH-OFFER-SILENT-001 | Verify extra at or under ask-after is silent. | Main | - | 1. Hole 60 min, extra 10 min, ask-after 15 min. | 1. Offer kind is silent.<br>2. Shortage and overtime choices are off. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-04 | EXCP-MONTH-OFFER-SHORTAGE-001 | Verify hole larger than extra offers shortage only. | Main | EXCP-MONTH-OFFER-SILENT-001 | 1. Hole 60 min, extra 20 min, ask-after 15 min. | 1. Offer kind is shortage only.<br>2. Default shortage seconds equal the extra. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-05 | EXCP-MONTH-OFFER-CROSS-001 | Verify extra covering the hole with leftover over ask-after offers shortage plus overtime. | Main | EXCP-MONTH-OFFER-SHORTAGE-001 | 1. Hole 10 min, extra 30 min, ask-after 15 min. | 1. Offer kind is cross.<br>2. Shortage-and-overtime is allowed. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-06 | EXCP-MONTH-OFFER-OT-001 | Verify no hole offers overtime only. | Main | EXCP-MONTH-OFFER-CROSS-001 | 1. Hole 0, extra 30 min, ask-after 15 min. | 1. Offer kind is overtime only. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-07 | EXCP-MONTH-OFFER-PARTIAL-001 | Verify typed leftover overtime on a cross offer can be smaller than ask-after. | Edge | EXCP-MONTH-OFFER-CROSS-001 | 1. Cross offer leftover 20 min, typed overtime 5 min. | 1. Validation succeeds.<br>2. Shortage equals the hole and overtime equals 5 min. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-08 | EXCP-MONTH-OFFER-CANCEL-001 | Verify cancel stores no shortage or overtime seconds. | Edge | EXCP-MONTH-OFFER-CROSS-001 | 1. Validate cancel on a cross offer. | 1. Accepted shortage and overtime seconds are 0. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthExtraOfferCalculator.cs` |
| TC-09 | EXCP-MONTH-APPROVE-OT-001 | Verify approving overtime fills the hole first then pays the rest. | Main | EXCP-MONTH-OFFER-OT-001 | 1. Approve overtime of 30 min against a 10 min hole, ignoring other pending. | 1. Cover is 10 min.<br>2. Paid overtime is 20 min. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthApprovalReclassifier.cs` |
| TC-10 | EXCP-MONTH-APPROVE-OT-002 | Verify overtime that exactly fills the hole is stored as shortage. | Edge | EXCP-MONTH-APPROVE-OT-001 | 1. Approve overtime of 10 min against a 10 min hole. | 1. Purpose becomes Shortage.<br>2. Paid overtime is 0. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthApprovalReclassifier.cs` |
| TC-11 | EXCP-MONTH-APPROVE-SHORTAGE-001 | Verify approving shortage with no hole becomes paid overtime. | Edge | EXCP-MONTH-APPROVE-OT-001 | 1. Approve shortage of 20 min against a 0 hole. | 1. Purpose becomes Overtime.<br>2. Paid overtime is 20 min. | `src/Excp.HRSystem.Domain.Shared/WorkSchedule/MonthApprovalReclassifier.cs` |
