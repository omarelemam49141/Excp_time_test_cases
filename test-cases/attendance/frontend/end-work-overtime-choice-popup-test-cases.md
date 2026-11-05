# End work overtime choice popup (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`
- APIs: `POST /api/AttendanceRecord/End-work`, `POST /api/AttendanceRecord/Get-shift-and-reminder-config`
- Related code: `src/app/core/components/end-work-modal/end-work-modal.component.ts`, `src/app/core/components/end-work-modal/end-work-modal.component.html`, `src/app/features/attendance/components/working-timer/working-timer.component.ts`, `src/app/features/attendance/utils/end-work-after-gap.util.ts`
- Related docs: `docs/frontend/technical/end-work-overtime-choice-popup.md`

## Scope

- End-work modal: the gap is only a gate; once reached the employee chooses Send request (the whole extra time becomes one overtime request, reason required) or Cancel (only the first gap minutes are kept). The old split slider and the cover hours part were removed.

## Test scenarios

- No question under the gap
- Question at exactly the gap and above it
- Whole time as one request, reason required
- Decline confirm
- Retired: the split slider

## Test cases

### Wave 1 — Employee popup

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-ATT-ENDWORK-UI-001 | Verify end work under the gap shows only Finish. | Main | EXCP-ATT-ENDWORK-AG-001 | 1. Set the overtime gap to 30 minutes.<br>2. Work 20 minutes past shift end.<br>3. Tap "End work". | 1. No choice question is shown.<br>2. "Finish" ends the day without a reason field. |
| TC-02 | EXCP-ATT-ENDWORK-UI-002 | Verify exactly the gap shows the Send request and Cancel choice with the whole time. | Main | EXCP-ATT-ENDWORK-AG-002 | 1. Set the overtime gap to 30 minutes.<br>2. Work exactly 30 minutes past shift end.<br>3. Tap "End work". | 1. The question about the extra time is shown with two options.<br>2. The extra time is shown as 30 minutes (the gap is not subtracted).<br>3. One line explains "Send request" and one line explains "Cancel". |
| TC-03 | EXCP-ATT-ENDWORK-UI-003 | Verify 50 minutes with a 30-minute gap offers all 50 minutes as one request. | Main | EXCP-ATT-ENDWORK-UI-002 | 1. Work 50 minutes past shift end with the gap at 30 minutes.<br>2. Open the end work window. | 1. The question names 50 minutes of extra time and the 30 minute gap.<br>2. No slider or split between overtime and cover is shown. |
| TC-04 | EXCP-ATT-ENDWORK-UI-004 | Verify the split slider between overtime and coverage (RETIRED: the cover hours part was removed). | Main | - | 1. Retired: the old slider no longer exists. | 1. Not run. The replacement check is EXCP-AUTO-UI-013. |
| TC-05 | EXCP-ATT-ENDWORK-UI-005 | Verify the reason is required before Send request. | Main | EXCP-ATT-ENDWORK-UI-003 | 1. Open the end work window with the choice question shown.<br>2. Leave the reason empty and look at "Send request".<br>3. Type a reason of 3 characters. | 1. "Send request" stays disabled while the reason is empty.<br>2. "Send request" becomes enabled with 3 or more characters.<br>3. A reason longer than 400 characters is refused. |
| TC-06 | EXCP-ATT-ENDWORK-UI-006 | Verify Cancel asks for confirmation and sends no request. | Edge | EXCP-ATT-ENDWORK-UI-002 | 1. Tap the Cancel button, which names the kept gap minutes.<br>2. Read the confirm window.<br>3. Confirm. | 1. A confirm window says only the first gap minutes are kept and the rest is dropped.<br>2. The day ends with no Pending overtime request. |
