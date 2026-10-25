# Shortage cover session (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: `/attendance-overtime/Start-overtime`, `/attendance-overtime/End-overtime`, `/attendance-overtime/Cover-session-preview`, `/attendance-overtime/Month-shortage-balance`
- APIs: `POST /api/attendance-overtime/Start-overtime?purpose=1`, `POST /api/attendance-overtime/End-overtime`, `GET /api/attendance-overtime/Cover-session-preview`, `GET /api/attendance-overtime/Month-shortage-balance`
- Related docs: `docs/backend/technical/shortage-cover-session.md`

## Scope

- A session that covers the month shortage first and splits the rest into an optional overtime request.

## Test scenarios

- Pure split rule
- Row split with breaks
- Declined surplus
- Nothing left to cover

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
