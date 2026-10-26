# Cover hours session (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: `/attendance-overtime/Start-overtime`, `/attendance-overtime/End-overtime`, `/attendance-overtime/Cover-session-preview`, `/attendance-overtime/Month-shortage-balance`
- APIs: `POST /api/attendance-overtime/Start-overtime?purpose=1`, `POST /api/attendance-overtime/End-overtime`, `GET /api/attendance-overtime/Cover-session-preview`, `GET /api/attendance-overtime/Month-shortage-balance`
- Related docs: `docs/backend/technical/shortage-cover-session.md`

## Scope

- A cover-hours session (formerly shortage cover) covers the month shortage first. The time beyond it is kept as cover hours by default, or sent as overtime, or not sent. The reason is mandatory. Extra cover is banked for later shortage in the same month.

## Test scenarios

- Pure split rule
- Row split with breaks
- Declined surplus
- Nothing left to cover
- Surplus choice and mandatory reason
- Same-month cover bank

## Test cases

### Wave 1 — Split of a finished session

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-COVER-SESSION-001 | Verify a session shorter than the shortage is all cover. | Main | - | 1. 20 minutes worked, 30 minutes of shortage. | 1. Cover is 20 minutes and the surplus is 0. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionRules.cs` |
| TC-02 | EXCP-COVER-SESSION-002 | Verify a longer session covers the shortage and the rest is surplus. | Main | - | 1. 40 minutes worked, 30 minutes of shortage. | 1. Cover is 30 minutes and the surplus is 10 minutes. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionRules.cs` |
| TC-03 | EXCP-COVER-SESSION-003 | Verify empty or negative inputs never give negative cover. | Edge | - | 1. Zero work, no shortage, negative values. | 1. Cover and surplus are never negative. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionRules.cs` |
| TC-04 | EXCP-COVER-SESSION-010 | Verify a session inside the shortage stays one Shortage row. | Main | - | 1. End a 20 minute session with 30 minutes of shortage left. | 1. One Shortage row with 20 minutes covered. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-05 | EXCP-COVER-SESSION-011 | Verify the surplus becomes an Overtime row when chosen. | Main | EXCP-COVER-SESSION-010 | 1. End a 40 minute session with 30 minutes left and choose overtime with a reason. | 1. A Shortage row of 30 minutes and a Pending Overtime row of 10 minutes with the reason, in one offer group. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-06 | EXCP-COVER-SESSION-012 | Verify a declined surplus is trimmed and never requested. | Edge | EXCP-COVER-SESSION-011 | 1. Same session, choose not to send the extra time. | 1. One Shortage row ending at the cover boundary and no Overtime row. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-07 | EXCP-COVER-SESSION-013 | Verify breaks follow their part and net time decides the cut. | Edge | EXCP-COVER-SESSION-011 | 1. A 60 minute session with two breaks, 30 minutes of shortage. | 1. The cut is at the 30th net minute and each break stays with its part. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-08 | EXCP-COVER-SESSION-014 | Verify nothing left to cover plus a declined surplus is the silent allowance. | Edge | EXCP-COVER-SESSION-012 | 1. End a session when the remaining shortage is 0 and decline overtime. | 1. The row becomes `WithinOvertimeGap` and no request is created. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |

### Wave 2 — Cover hours choice, reason and bank

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-09 | EXCP-COVER-SESSION-004 | Verify the surplus choice defaults to cover hours and the new field wins over the legacy bool. | Main | - | 1. Resolve the choice with no value, with the legacy bool, and with both. | 1. Nothing sent gives cover hours.<br>2. True gives overtime and false gives do not send.<br>3. The new field wins. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionRules.cs` |
| TC-10 | EXCP-COVER-SESSION-005 | Verify a normal overtime session still needs its reason. | Main | - | 1. Validate End-overtime with no choice and no reason, then with a reason. | 1. Invalid without the reason, valid with it. | `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Fluent Validations/EndOverTimeInputValidation.cs` |
| TC-11 | EXCP-COVER-SESSION-006 | Verify a cover session that sends a choice leaves the overtime reason to the builder. | Main | - | 1. Validate with each choice and a cover reason. | 1. All three are valid. | `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Fluent Validations/EndOverTimeInputValidation.cs` |
| TC-12 | EXCP-COVER-SESSION-007 | Verify a too short reason is refused when a choice is sent. | Edge | - | 1. Send a 1 character cover reason, then a 1 character overtime reason. | 1. Both are invalid. | `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Fluent Validations/EndOverTimeInputValidation.cs` |
| TC-13 | EXCP-COVER-SESSION-008 | Verify the legacy bool still works for old clients. | Edge | - | 1. Send `SurplusAsOvertime` false, then true with no reason. | 1. False is valid. True is invalid without a reason. | `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Fluent Validations/EndOverTimeInputValidation.cs` |
| TC-14 | EXCP-COVER-SESSION-015 | Verify extra time kept as cover hours leaves one whole cover row. | Main | EXCP-COVER-SESSION-010 | 1. End a 40 minute session with 30 minutes left and keep the extra as cover hours. | 1. One Shortage row of 40 minutes covered, no Overtime row, status Pending. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-15 | EXCP-COVER-SESSION-016 | Verify with no shortage the whole session is cover hours. | Main | - | 1. End a 60 minute session when the remaining shortage is 0 and keep it as cover hours. | 1. One Shortage row of 60 minutes covered, status Pending. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-16 | EXCP-COVER-SESSION-017 | Verify with no shortage the overtime choice turns the session into overtime. | Edge | EXCP-COVER-SESSION-016 | 1. End a 30 minute session when the remaining shortage is 0 and choose overtime with a reason. | 1. One Overtime row of 30 minutes paid with the reason. | `src/Excp.HRSystem.Application/Services/ShortageCover/ShortageCoverSessionService.cs` |
| TC-17 | EXCP-COVER-BANK-001 | Verify extra approved cover is banked and later days use it before any shortage shows. | Main | - | 1. Approve a very large cover. 2. Read the month balance on day 1 and 10 days later. | 1. No shortage on both. The bank shrinks by exactly the time the later days need. | `src/Excp.HRSystem.Application/Services/MonthHours/MonthHoursBalanceService.cs` |
| TC-18 | EXCP-COVER-BANK-002 | Verify cover hours do not reach the next working month. | Edge | EXCP-COVER-BANK-001 | 1. Read the balance two months later. | 1. Accepted cover and bank are 0. | `src/Excp.HRSystem.Application/Services/MonthHours/MonthHoursBalanceService.cs` |
