# Shortage cover session (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `frontend`
- Routes: `/home`, `/attendance/overtime-timer`
- APIs: `POST /api/attendance-overtime/Start-overtime`, `POST /api/attendance-overtime/End-overtime`, `GET /api/attendance-overtime/Cover-session-preview`, `GET /api/attendance-overtime/Month-shortage-balance`
- Related code: `src/app/pages/home/home.component.html`, `src/app/pages/home/home.component.ts`, `src/app/features/attendance/components/overtime-timer/overtime-timer.component.ts`, `src/app/core/components/end-cover-modal/end-cover-modal.component.ts`
- Related docs: `docs/frontend/technical/shortage-cover-session.md`

## Scope

- The two start buttons on Home, the cover timer and the end dialog with the surplus choice, and the Shortage cover tab.

## Test scenarios

- Buttons layout and visibility
- Cover timer
- End dialog
- Add shortage cover

## Test cases

### Wave 1 — Home and timer

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-COVER-UI-001 | Verify the two start buttons share the row at half width each. | Main | - | 1. Sign in as an employee with month shortage on a finished day past the cutoff.<br>2. Open Home at 1440px. | 1. "Start overtime" and "Start covering shortage" sit side by side at equal width.<br>2. The cover button hint shows the remaining shortage. | `src/app/pages/home/home.component.html` |
| TC-02 | EXCP-COVER-UI-002 | Verify the cover button is hidden without shortage and the overtime button keeps the full width. | Edge | EXCP-COVER-UI-001 | 1. Use an employee with no month shortage. | 1. Only "Start overtime" shows, full width. | `src/app/pages/home/home.component.ts` |
| TC-03 | EXCP-COVER-UI-003 | Verify the buttons stack below 600px and drop the icon on a narrow pair. | Edge | EXCP-COVER-UI-001 | 1. Resize to 390px, then to 1024px. | 1. Stacked at 390px with full text.<br>2. At 1024px the icon tile is hidden and the text fits. | `src/app/pages/home/home.component.scss` |
| TC-04 | EXCP-COVER-UI-004 | Verify the cover timer is indigo, labeled and survives a refresh. | Main | EXCP-COVER-UI-001 | 1. Press "Start covering shortage" and pick the work place.<br>2. Reload the timer page. | 1. The ring, digits and label are indigo and read "Start of shortage cover".<br>2. After the reload it is still a cover session with the progress line. | `src/app/features/attendance/components/overtime-timer/overtime-timer.component.ts` |

### Wave 2 — End dialog

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-05 | EXCP-COVER-UI-005 | Verify a session longer than the shortage asks about the extra time and blocks Finish until answered. | Main | EXCP-COVER-UI-004 | 1. Work 45 minutes with 20 minutes of shortage left and press Finish. | 1. The dialog shows 45 worked, 20 covers the shortage, 25 extra.<br>2. Finish is disabled until "send as overtime" or "do not send" is chosen. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-06 | EXCP-COVER-UI-006 | Verify choosing overtime requires a reason and creates two requests. | Main | EXCP-COVER-UI-005 | 1. Choose "send as overtime", leave the reason empty, then fill it.<br>2. Finish. | 1. Finish stays disabled until the overtime reason is valid; the coverage reason is optional.<br>2. A Shortage request (20 min) and an Overtime request (25 min) are created; each approver gets one notification per request. | `src/app/core/components/end-cover-modal/end-cover-modal.component.html` |
| TC-07 | EXCP-COVER-UI-007 | Verify declining the extra time creates only the shortage request. | Edge | EXCP-COVER-UI-005 | 1. Choose "do not send" and Finish. | 1. Only the Shortage request exists and the extra time is not recorded. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-08 | EXCP-COVER-UI-008 | Verify a session inside the shortage skips the question. | Edge | EXCP-COVER-UI-004 | 1. Work 15 minutes with 20 minutes of shortage left and press Finish. | 1. No overtime question, only the optional coverage reason.<br>2. One Shortage request is created. | `src/app/core/components/end-cover-modal/end-cover-modal.component.html` |

### Wave 3 — Shortage cover tab

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-09 | EXCP-COVER-UI-009 | Verify the Shortage cover tab has its own Add button and a cover-only dialog. | Main | - | 1. Open the Shortage cover tab and press "Add shortage cover".<br>2. Enter the times and leave the reason empty. | 1. The dialog is titled for shortage cover, has no split section and shows the "all of this time is shortage cover" note.<br>2. Submit is enabled without a reason. | `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts` |
