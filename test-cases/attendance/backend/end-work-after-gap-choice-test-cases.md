# End work after-gap overtime choice (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/AttendanceRecord/End-work`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/EndWorkBuilder.cs`, `src/Excp.HRSystem.Application/Attendance/EndWorkPostShiftOvertimeRules.cs`
- Related docs: `docs/backend/technical/end-work-after-gap-overtime-choice.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Attendance/EndWorkPostShiftOvertimeRulesTests.cs`

## Scope

- Post-shift overtime with gap 30 and ask-after 15 (shift 9–17, end at regular boundary).

## Test scenarios

- Silent within gap + ask-after band
- Popup threshold strictly greater than ask-after
- Request split and Decline drop after-gap

## Test cases

### Wave 3 — End work API

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-ATT-ENDWORK-AG-001 | Verify end work at 17:30 creates only WithinOvertimeGap post-shift (30 min) and no leader request. | Main | EXCP-SCHED-OT-ASK-API-002 | 1. Set gap 30, ask-after 15.<br>2. Employee works 9–17:30, ends work with `afterGapOvertimeChoice` NotAsked.<br>3. Inspect overtime for the day. | 1. One post-shift overtime row status is WithinOvertimeGap.<br>2. No Pending leader request for that slice. |
| TC-02 | EXCP-ATT-ENDWORK-AG-002 | Verify end work at 17:45 stays silent (45 min net) without choice. | Main | EXCP-ATT-ENDWORK-AG-001 | 1. Same settings.<br>2. End at 17:45 with NotAsked. | 1. Post-shift overtime is WithinOvertimeGap only.<br>2. No Pending request. |
| TC-03 | EXCP-ATT-ENDWORK-AG-003 | Verify end work at 18:00 with Request creates WithinOvertimeGap 30 min + Pending 30 min with reason. | Main | EXCP-ATT-ENDWORK-AG-002 | 1. End at 18:00 with Request and valid reason. | 1. Two post-shift rows: first WithinOvertimeGap (gap portion), second Pending (after-gap portion).<br>2. Leader sees Pending request for after-gap slice. |
| TC-04 | EXCP-ATT-ENDWORK-AG-004 | Verify end work at 18:00 with Decline keeps gap WithinOvertimeGap and drops after-gap. | Edge | EXCP-ATT-ENDWORK-AG-003 | 1. End at 18:00 with Decline. | 1. Only WithinOvertimeGap row for gap portion exists.<br>2. No Pending row for 17:30–18:00. |
| TC-05 | EXCP-ATT-ENDWORK-AG-005 | Verify end work at 18:00 with NotAsked returns conflict. | Edge | EXCP-ATT-ENDWORK-AG-002 | 1. End at 18:00 without choice. | 1. API returns conflict.<br>2. Attendance end time is not updated. |
