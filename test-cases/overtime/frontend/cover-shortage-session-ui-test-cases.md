# Cover hours session (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `frontend`
- Routes: `/home`, `/attendance/overtime-timer`
- APIs: `POST /api/attendance-overtime/Start-overtime`, `POST /api/attendance-overtime/End-overtime`, `GET /api/attendance-overtime/Cover-session-preview`, `GET /api/attendance-overtime/Month-shortage-balance`
- Related code: `src/app/pages/home/home.component.html`, `src/app/pages/home/home.component.ts`, `src/app/features/attendance/components/overtime-timer/overtime-timer.component.ts`, `src/app/core/components/end-cover-modal/end-cover-modal.component.ts`
- Related docs: `docs/frontend/technical/shortage-cover-session.md`

## Scope

- The two start buttons on Home (cover hours always shown), the cover timer, the end dialog with the three-way extra-time choice and mandatory reason, the split default in end work, and the Cover hours tab.

## Test scenarios

- Buttons layout and visibility
- Cover timer
- End dialog
- Add cover hours
- Extra-time choice defaults
- Mandatory cover reason

## Test cases

### Wave 1 — Home and timer

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-COVER-UI-001 | Verify the two start buttons share the row at half width each. | Main | - | 1. Sign in as an employee with month shortage on a finished day past the cutoff.<br>2. Open Home at 1440px. | 1. "Start overtime" and "Start cover hours" sit side by side at equal width.<br>2. The cover button hint shows the remaining shortage. | `src/app/pages/home/home.component.html` |
| TC-02 | EXCP-COVER-UI-002 | Verify the cover button stays visible without shortage with a generic hint. | Edge | EXCP-COVER-UI-001 | 1. Use an employee with no month shortage. | 1. Both buttons still show side by side.<br>2. The cover hint says extra time is kept for future shortage this month (or how much is already kept). | `src/app/pages/home/home.component.ts` |
| TC-03 | EXCP-COVER-UI-003 | Verify the buttons stack below 600px and drop the icon on a narrow pair. | Edge | EXCP-COVER-UI-001 | 1. Resize to 390px, then to 1024px. | 1. Stacked at 390px with full text.<br>2. At 1024px the icon tile is hidden and the text fits. | `src/app/pages/home/home.component.scss` |
| TC-04 | EXCP-COVER-UI-004 | Verify the cover timer is indigo, labeled and survives a refresh. | Main | EXCP-COVER-UI-001 | 1. Press "Start cover hours" and pick the work place.<br>2. Reload the timer page. | 1. The ring, digits and label are indigo and read "Start of cover hours".<br>2. After the reload it is still a cover session with the progress line. | `src/app/features/attendance/components/overtime-timer/overtime-timer.component.ts` |

### Wave 2 — End dialog

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-05 | EXCP-COVER-UI-005 | Verify a session longer than the shortage offers three choices with cover hours preselected. | Main | EXCP-COVER-UI-004 | 1. Work 45 minutes with 20 minutes of shortage left and press Finish. | 1. The dialog shows 45 worked, 20 covers the shortage, 25 extra.<br>2. "Keep it to cover future shortage" is selected; "Send it as overtime" and "Don't send it" are the other options.<br>3. Finish is disabled until the cover reason is filled. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-06 | EXCP-COVER-UI-006 | Verify choosing overtime requires both reasons and creates two requests. | Main | EXCP-COVER-UI-005 | 1. Choose "Send it as overtime", leave the reasons empty, then fill them.<br>2. Finish. | 1. Finish stays disabled until the cover reason and the overtime reason are valid.<br>2. A Cover hours request (20 min) and an Overtime request (25 min) are created; each approver gets one notification per request. | `src/app/core/components/end-cover-modal/end-cover-modal.component.html` |
| TC-07 | EXCP-COVER-UI-007 | Verify declining the extra time creates only the cover request. | Edge | EXCP-COVER-UI-005 | 1. Choose "Don't send it", fill the cover reason and Finish. | 1. Only the Cover hours request (20 min) exists and the extra time is not recorded. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-08 | EXCP-COVER-UI-008 | Verify a session inside the shortage skips the question. | Edge | EXCP-COVER-UI-004 | 1. Work 15 minutes with 20 minutes of shortage left and press Finish. | 1. No extra-time question, only the required cover reason.<br>2. One Cover hours request is created. | `src/app/core/components/end-cover-modal/end-cover-modal.component.html` |

### Wave 3 — Cover hours tab

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-09 | EXCP-COVER-UI-009 | Verify the Cover hours tab has its own Add button and a cover-only dialog with a required reason. | Main | - | 1. Open the Cover hours tab and press "Add cover hours".<br>2. Enter the times and leave the reason empty, then fill it. | 1. The dialog is titled for cover hours, has no split section and shows the "all of this time is cover hours" note.<br>2. Submit is disabled without a reason and enabled with one. | `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts` |

### Wave 4 — Defaults, mandatory reason and bank

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-10 | EXCP-COVER-UI-010 | Verify the cover timer shows a note when there is no shortage. | Edge | EXCP-COVER-UI-004 | 1. Start cover hours with no month shortage. | 1. The timer shows the note that the time is kept as cover hours for future shortage this month. | `src/app/features/attendance/components/overtime-timer/overtime-timer.component.html` |
| TC-11 | EXCP-COVER-UI-011 | Verify with no shortage the whole session is extra time kept as cover hours by default. | Main | EXCP-COVER-UI-010 | 1. Work 30 minutes with no shortage and press Finish. | 1. The dialog lists the 30 minutes as time kept for later.<br>2. Cover hours is preselected and the cover reason is required. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-12 | EXCP-COVER-UI-012 | Verify "Don't send it" with no shortage needs no reason. | Edge | EXCP-COVER-UI-011 | 1. Choose "Don't send it". | 1. No reason field shows and Finish is enabled.<br>2. Nothing is recorded. | `src/app/core/components/end-cover-modal/end-cover-modal.component.ts` |
| TC-13 | EXCP-COVER-UI-013 | Verify the end-work split starts with the whole block as cover hours. | Main | - | 1. End work 50 minutes after shift end with the gap reached. | 1. The split shows overtime 00:00 and cover hours 00:50.<br>2. Only the cover reason is required.<br>3. Moving the slider adds an overtime part and the overtime reason becomes required. | `src/app/shared/components/extra-time-split/extra-time-split.component.ts` |
| TC-14 | EXCP-COVER-UI-014 | Verify the end-work cover reason is required. | Main | EXCP-COVER-UI-013 | 1. Leave the cover reason empty and press Send request. | 1. Send request is disabled until the cover reason is valid. | `src/app/core/components/end-work-modal/end-work-modal.component.ts` |
| TC-15 | EXCP-COVER-UI-015 | Verify the manual overtime form requires a reason for any split. | Edge | - | 1. Open My Requests, Add request, Overtime requests and enter times without a reason. | 1. Submit is disabled.<br>2. The label reads "Cover hours reason" while the whole block is cover hours. | `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts` |
| TC-16 | EXCP-COVER-UI-016 | Verify the report shows cover hours not needed in the month. | Edge | - | 1. Generate the report for an employee with more approved cover than shortage. | 1. A pill "Cover hours not needed this month" shows the unused time. | `src/app/features/admin-leader/admin/components/reports/employee-hours-report/employee-hours-report.component.html` |
| TC-17 | EXCP-COVER-UI-017 | Verify the Arabic UI uses the new name everywhere. | Edge | - | 1. Switch to Arabic and open Home, the timer, the end dialogs and the Cover hours tab. | 1. The texts say تغطية الساعات and no text says تغطية النقص or تغطية نقص. | `src/app/pages/home/home.component.ts` |
| TC-18 | EXCP-COVER-UI-018 | Verify the home month card counts cover hours. | Main | - | 1. Sign in as an employee with a month shortage and approved or pending cover hours.<br>2. Open Home. | 1. A "Cover hours" row shows the credited time.<br>2. "Missed until today" and "Remaining until month end" are lower by the cover hours and never negative.<br>3. The meter has an indigo part between worked and missed. | `src/app/pages/home/home.component.ts` |
