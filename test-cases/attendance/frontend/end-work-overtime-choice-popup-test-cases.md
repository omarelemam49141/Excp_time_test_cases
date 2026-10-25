# End work overtime choice popup (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`
- APIs: `POST /api/AttendanceRecord/End-work`, `POST /api/AttendanceRecord/Get-shift-and-reminder-config`
- Related code: `src/app/core/components/end-work-modal/end-work-modal.component.ts`, `src/app/core/components/end-work-modal/end-work-modal.component.html`, `src/app/shared/components/extra-time-split/extra-time-split.component.ts`, `src/app/features/attendance/components/working-timer/working-timer.component.ts`, `src/app/features/attendance/utils/end-work-after-gap.util.ts`
- Related docs: `docs/frontend/technical/end-work-overtime-choice-popup.md`

## Scope

- End-work modal: the gap is only a gate; once reached the whole extra time is split between overtime and shortage coverage.

## Test scenarios

- No question under the gap
- Question at exactly the gap and above it
- Split slider, reason only for the overtime part
- Decline confirm

## Test cases

### Wave 1 — Employee popup

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-ATT-ENDWORK-UI-001 | Verify end work under the gap shows only Finish. | Main | EXCP-ATT-ENDWORK-AG-001 | 1. Set gap 30.<br>2. Work 20 minutes past shift end.<br>3. Tap **End work**. | 1. No split question is shown.<br>2. **Finish** ends the day without a reason field. |
| TC-02 | EXCP-ATT-ENDWORK-UI-002 | Verify exactly the gap shows the split question with the whole time. | Main | EXCP-ATT-ENDWORK-AG-002 | 1. Set gap 30.<br>2. Work exactly 30 minutes past shift end.<br>3. Tap **End work**. | 1. The split question is shown.<br>2. Total extra time is 30 minutes (the gap is not subtracted). |
| TC-03 | EXCP-ATT-ENDWORK-UI-003 | Verify 50 minutes with a 30-minute gap offers all 50 minutes. | Main | EXCP-ATT-ENDWORK-UI-002 | 1. Work 50 minutes past shift end with gap 30.<br>2. Open the modal. | 1. Total extra time is 50 minutes.<br>2. Overtime starts at 50 minutes and coverage at 0. |
| TC-04 | EXCP-ATT-ENDWORK-UI-004 | Verify moving the slider shifts time from overtime to coverage and the sum stays the total. | Main | EXCP-ATT-ENDWORK-UI-003 | 1. Move the coverage slider to 30 minutes. | 1. Coverage shows 30 minutes and overtime 20 minutes.<br>2. Together they are 50 minutes. |
| TC-05 | EXCP-ATT-ENDWORK-UI-005 | Verify the reason is required only when overtime is above zero. | Main | EXCP-ATT-ENDWORK-UI-004 | 1. Tap **Send request** with overtime above 0.<br>2. Repeat with all the time given to coverage. | 1. A reason field is shown and **Finish** is disabled until it has 3 characters.<br>2. With coverage only, the request is sent without a reason step. |
| TC-06 | EXCP-ATT-ENDWORK-UI-006 | Verify Cancel asks for confirmation and sends no request. | Edge | EXCP-ATT-ENDWORK-UI-002 | 1. Tap **Do not send a request**.<br>2. Confirm. | 1. A confirm dialog is shown.<br>2. The day ends with no Pending request. |
