# Cover hours session (backend) Test Cases (RETIRED)

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: `/attendance-overtime/Start-overtime`, `/attendance-overtime/End-overtime`, `/attendance-overtime/Cover-session-preview`, `/attendance-overtime/Month-shortage-balance`
- APIs: `POST /api/attendance-overtime/Start-overtime?purpose=1`, `POST /api/attendance-overtime/End-overtime`, `GET /api/attendance-overtime/Cover-session-preview`, `GET /api/attendance-overtime/Month-shortage-balance`
- Related code: `docs/backend/technical/shortage-cover-session.md`
- Related docs: `docs/backend/technical/shortage-cover-session.md`

## Scope

- **RETIRED.** Cover hours were removed as a request kind. Every case in this file is retired except `EXCP-COVER-BANK-002`, which still has an automated test as a legacy regression. Do not run the retired cases. They are kept for history. The replacement cases are in `test-cases/overtime/backend/automatic-shortage-test-cases.md` (keys `EXCP-AUTO-SHORTAGE-*`).

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
| TC-01 | EXCP-COVER-SESSION-001 | Verify a session shorter than the shortage is all cover (RETIRED: the cover-hours feature was removed). | Main | - | 1. 20 minutes worked, 30 minutes of shortage. | 1. Cover is 20 minutes and the surplus is 0. | - |
| TC-02 | EXCP-COVER-SESSION-002 | Verify a longer session covers the shortage and the rest is surplus (RETIRED: the cover-hours feature was removed). | Main | - | 1. 40 minutes worked, 30 minutes of shortage. | 1. Cover is 30 minutes and the surplus is 10 minutes. | - |
| TC-03 | EXCP-COVER-SESSION-003 | Verify empty or negative inputs never give negative cover (RETIRED: the cover-hours feature was removed). | Edge | - | 1. Zero work, no shortage, negative values. | 1. Cover and surplus are never negative. | - |
| TC-04 | EXCP-COVER-SESSION-010 | Verify a session inside the shortage stays one Shortage row (RETIRED: the cover-hours feature was removed). | Main | - | 1. End a 20 minute session with 30 minutes of shortage left. | 1. One Shortage row with 20 minutes covered. | - |
| TC-05 | EXCP-COVER-SESSION-011 | Verify the surplus becomes an Overtime row when chosen (RETIRED: the cover-hours feature was removed). | Main | - | 1. End a 40 minute session with 30 minutes left and choose overtime with a reason. | 1. A Shortage row of 30 minutes and a Pending Overtime row of 10 minutes with the reason, in one offer group. | - |
| TC-06 | EXCP-COVER-SESSION-012 | Verify a declined surplus is trimmed and never requested (RETIRED: the cover-hours feature was removed). | Edge | - | 1. Same session, choose not to send the extra time. | 1. One Shortage row ending at the cover boundary and no Overtime row. | - |
| TC-07 | EXCP-COVER-SESSION-013 | Verify breaks follow their part and net time decides the cut (RETIRED: the cover-hours feature was removed). | Edge | - | 1. A 60 minute session with two breaks, 30 minutes of shortage. | 1. The cut is at the 30th net minute and each break stays with its part. | - |
| TC-08 | EXCP-COVER-SESSION-014 | Verify nothing left to cover plus a declined surplus is the silent allowance (RETIRED: the cover-hours feature was removed). | Edge | - | 1. End a session when the remaining shortage is 0 and decline overtime. | 1. The row becomes `WithinOvertimeGap` and no request is created. | - |

### Wave 2 — Cover hours choice, reason and bank

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-09 | EXCP-COVER-SESSION-004 | Verify the surplus choice defaults to cover hours and the new field wins over the legacy bool (RETIRED: the cover-hours feature was removed). | Main | - | 1. Resolve the choice with no value, with the legacy bool, and with both. | 1. Nothing sent gives cover hours.<br>2. True gives overtime and false gives do not send.<br>3. The new field wins. | - |
| TC-10 | EXCP-COVER-SESSION-005 | Verify a normal overtime session still needs its reason (RETIRED: the cover-hours feature was removed). | Main | - | 1. Validate End-overtime with no choice and no reason, then with a reason. | 1. Invalid without the reason, valid with it. | - |
| TC-11 | EXCP-COVER-SESSION-006 | Verify a cover session that sends a choice leaves the overtime reason to the builder (RETIRED: the cover-hours feature was removed). | Main | - | 1. Validate with each choice and a cover reason. | 1. All three are valid. | - |
| TC-12 | EXCP-COVER-SESSION-007 | Verify a too short reason is refused when a choice is sent (RETIRED: the cover-hours feature was removed). | Edge | - | 1. Send a 1 character cover reason, then a 1 character overtime reason. | 1. Both are invalid. | - |
| TC-13 | EXCP-COVER-SESSION-008 | Verify the legacy bool still works for old clients (RETIRED: the cover-hours feature was removed). | Edge | - | 1. Send `SurplusAsOvertime` false, then true with no reason. | 1. False is valid. True is invalid without a reason. | - |
| TC-14 | EXCP-COVER-SESSION-015 | Verify extra time kept as cover hours leaves one whole cover row (RETIRED: the cover-hours feature was removed). | Main | - | 1. End a 40 minute session with 30 minutes left and keep the extra as cover hours. | 1. One Shortage row of 40 minutes covered, no Overtime row, status Pending. | - |
| TC-15 | EXCP-COVER-SESSION-016 | Verify with no shortage the whole session is cover hours (RETIRED: the cover-hours feature was removed). | Main | - | 1. End a 60 minute session when the remaining shortage is 0 and keep it as cover hours. | 1. One Shortage row of 60 minutes covered, status Pending. | - |
| TC-16 | EXCP-COVER-SESSION-017 | Verify with no shortage the overtime choice turns the session into overtime (RETIRED: the cover-hours feature was removed). | Edge | - | 1. End a 30 minute session when the remaining shortage is 0 and choose overtime with a reason. | 1. One Overtime row of 30 minutes paid with the reason. | - |
| TC-17 | EXCP-COVER-BANK-001 | Verify extra approved cover is banked and later days use it before any shortage shows (RETIRED: the cover-hours feature was removed). | Main | - | 1. Approve a very large cover. 2. Read the month balance on day 1 and 10 days later. | 1. No shortage on both. The bank shrinks by exactly the time the later days need. | - |
| TC-18 | EXCP-COVER-BANK-002 | Verify old approved cover hours do not reach the next working month (kept as a legacy regression). | Edge | - | 1. Read the balance two months later. | 1. Accepted cover and bank are 0. | `src/Excp.HRSystem.Application/Services/MonthHours/MonthHoursBalanceService.cs` |
