# End work overtime choice popup (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`
- APIs: `POST /api/AttendanceRecord/End-work`, `POST /api/AttendanceRecord/Get-shift-and-reminder-config`
- Related code: `src/app/core/components/end-work-modal/end-work-modal.component.ts`, `src/app/features/attendance/components/working-timer/working-timer.component.ts`, `src/app/features/attendance/utils/end-work-after-gap.util.ts`
- Related docs: `docs/frontend/technical/end-work-overtime-choice-popup.md`

## Scope

- End-work modal Yes/No, confirm on No, reason on Yes, silent band without question.

## Test scenarios

- No popup within silent band
- Popup when after-gap exceeds ask-after
- Decline confirm and Yes reason path

## Test cases

### Wave 4 — Employee popup

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-ATT-ENDWORK-UI-001 | Verify end work within silent band shows only Finish (no Yes/No). | Main | EXCP-SCHED-OT-ASK-UI-001, EXCP-ATT-ENDWORK-AG-002 | 1. Set gap 30, ask-after 15.<br>2. Work past shift end but stay within 45 min extra (e.g. end 17:45).<br>3. Tap **End work**. | 1. Modal does not show Yes/No buttons.<br>2. **Finish** ends the day without overtime reason field. |
| TC-02 | EXCP-ATT-ENDWORK-UI-002 | Verify end work past silent band shows Yes/No and extra-after-gap duration. | Main | EXCP-ATT-ENDWORK-UI-001 | 1. End at least 16 minutes after gap boundary (e.g. 18:00 with 17:00 shift end).<br>2. Tap **End work**. | 1. Modal shows question and **Yes** / **No**.<br>2. Timer label shows extra time after the allowance. |
| TC-03 | EXCP-ATT-ENDWORK-UI-003 | Verify No shows confirm then ends work without reason field. | Edge | EXCP-ATT-ENDWORK-UI-002 | 1. On Yes/No step tap **No**.<br>2. Confirm in the dialog. | 1. Confirm dialog text matches localized decline message.<br>2. User returns home without entering an overtime reason. |
| TC-04 | EXCP-ATT-ENDWORK-UI-004 | Verify Yes shows reason field and Finish stays disabled until reason is valid. | Main | EXCP-ATT-ENDWORK-UI-002 | 1. Tap **Yes**.<br>2. Leave reason empty and tap **Finish**. | 1. **Purpose of overtime** field is visible.<br>2. **Finish** is disabled until reason has at least 3 characters. |
| TC-05 | EXCP-ATT-ENDWORK-UI-005 | Verify popup past ask-after shows month hole and extra after the gap. | Main | EXCP-ATT-ENDWORK-UI-002 | 1. Set working month start day 26.<br>2. End work past ask-after with a remaining month hole.<br>3. Open the end-work modal. | 1. Modal shows working-month start, required, credited, remaining shortage, and extra after the allowance.<br>2. Allowed choices include shortage cover. |
| TC-06 | EXCP-ATT-ENDWORK-UI-006 | Verify extra that covers the hole offers shortage plus leftover overtime. | Main | EXCP-ATT-ENDWORK-UI-005 | 1. End work with extra larger than the remaining hole and leftover greater than ask-after.<br>2. Open the modal. | 1. Choice "Cover the shortage and send leftover overtime" is visible.<br>2. Overtime minutes field can be typed smaller than ask-after. |
| TC-07 | EXCP-ATT-ENDWORK-UI-007 | Verify cancel confirmation finishes with no shortage or overtime request. | Edge | EXCP-ATT-ENDWORK-UI-005 | 1. Choose "Do not send a request".<br>2. Confirm. | 1. Confirm dialog is shown.<br>2. Day ends with the gap row only and no Pending request. |
