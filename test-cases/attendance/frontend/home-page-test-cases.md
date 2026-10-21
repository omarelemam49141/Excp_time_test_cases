# Home page — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`
- APIs: `POST /api/attendance-record/Get-details-by-date`, `POST /api/attendance-record/get-in-range-with-user-id`, `POST /api/attendance-record/Get-work-progress`
- Related code: `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.html`
- Related docs: `docs/frontend/technical/home-page.md`
- Automation (Karma, optional): `src/app/pages/home/home.component.spec.ts`, `src/app/core/components/attendance-card-data/attendance-card-data.component.spec.ts`

## Scope

- The employee landing screen: the main work action, the selected day's summary, the month progress panel and the day details tabs.
- Arabic and English, laptop, tablet and phone widths.

## Test pages

- `/home`

## Test scenarios

- There is one clear primary action, and overtime stays secondary.
- The summary heading and values follow the selected day.
- The month panel shows a skeleton while loading, then the numbers, and the meter matches them.
- The layout is two columns on a laptop and one column on a phone in the right order.
- The day details tabs show attendance and overtime requests correctly.

## Test cases

### Actions and summary

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-HOME-001 | Verify the start / continue-work button is the single primary action and starts work. | Main | Employee whose day has not started (or is continuing). | 1. Open `/home`.<br>2. Press the "start working" (or "continue working") button. | 1. One prominent deep-teal button with an icon, a title and a hint is shown.<br>2. Pressing it starts work exactly as before (work place choice, then the day updates). | `src/app/pages/home/home.component.html`, `src/app/pages/home/home.component.ts` |
| TC-02 | EXCP-HOME-002 | Verify the overtime action is secondary and only shows when overtime is allowed. | Edge | Employee after the end of the shift. | 1. Open `/home` after shift end. | 1. The overtime button is an outline button below the primary one (or alone when there is no primary action).<br>2. Before overtime is allowed the button is not shown. | `src/app/pages/home/home.component.html`, `src/app/pages/home/home.component.ts` |
| TC-03 | EXCP-HOME-003 | Verify the summary heading and state chip follow the selected day. | Main | A finished past day and today. | 1. Open `/home` (today selected).<br>2. Pick a past day in the day picker. | 1. Today shows "Today at a glance".<br>2. A past day shows "Summary for <date>".<br>3. The state chip shows the day's state (working, on break, finished, weekend or not started).<br>4. The start / end / remaining values belong to the selected day. | `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.html` |
| TC-04 | EXCP-HOME-004 | Verify a weekend day shows the rest-day note instead of times. | Edge | A weekly rest day in the strip. | 1. Pick the rest day. | 1. The summary shows the weekend state and the weekend note, with no start or end values.<br>2. No start-work button is shown. | `src/app/pages/home/home.component.html` |

### Month progress

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-05 | EXCP-HOME-005 | Verify the month panel shows a skeleton while loading and then correct numbers. | Main | Slow network. | 1. Open `/home` with the network throttled. | 1. A skeleton is shown in the "This month's work" panel instead of zeros.<br>2. The rows (required, worked, missed, remaining month end, plus "catch up" only when it differs from missed) then show hours that match the work-progress API.<br>3. If the request fails the skeleton disappears and the error dialog is shown once. | `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.html` |
| TC-06 | EXCP-HOME-006 | Verify the meter shows worked, then missed, then the rest of the month. | Main | A month with worked and missed hours. | 1. Read the meter and the rows. | 1. A teal part (worked) is followed by a red part (missed) and the remaining length is grey.<br>2. The worked and missed rows carry a matching colour dot and are also written in words.<br>3. The red part never has a negative length. | `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.scss` |

### Layout and language

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-07 | EXCP-HOME-007 | Verify the layout is two columns on a laptop and ordered on a phone. | Main | Widths 1366px, 820px and 390px. | 1. Open `/home` at each width. | 1. At 1366px the month panel sits beside the main column.<br>2. At 820px and 390px it is one column in the order: action, summary, month, day details.<br>3. The page never scrolls sideways at any width. | `src/app/pages/home/home.component.scss` |
| TC-08 | EXCP-HOME-008 | Verify the page mirrors correctly in Arabic and all text is translated. | Edge | Arabic, then English. | 1. Open `/home` in each language. | 1. In Arabic the main column is on the right (beside the sidebar) and the chevrons point along the reading direction.<br>2. No English text appears in the Arabic page, except text typed by users.<br>3. Times and hours keep a readable order. | `src/app/pages/home/home.component.html`, `src/app/pages/home/home.component.scss` |

### Day details

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-09 | EXCP-HOME-009 | Verify the Attendance tab shows the worked chip, labelled times and the right variant for the day. | Main | A worked day, an open shift, a rest day and a day without a record. | 1. Pick each day and read the Attendance tab. | 1. A worked day shows a "Worked" chip (red when short), attendance, break and dismissal times and an outline "Update" button.<br>2. An open shift says "no end time" in words.<br>3. A rest day shows a quiet rest-day chip and no Update button.<br>4. A day without a record shows the "Not recorded." notice. | `src/app/core/components/attendance-card-data/attendance-card-data.component.html`, `src/app/core/components/attendance-card-data/attendance-card-data.component.ts` |
| TC-10 | EXCP-HOME-010 | Verify the Overtimes tab shows request cards with a written status and the right actions. | Main | A day with a pending, an approved and a rejected overtime request. | 1. Open the Overtimes tab. | 1. Each request is a white card with its number, status chip (Pending / Accepted / Rejected), date and time.<br>2. No coloured bar is on the side of the cards.<br>3. Only the pending request has "Edit" and "Delete request" buttons.<br>4. An "Add overtime" button is shown and is disabled when overtime is not allowed for the day.<br>5. A request reason typed in English reads correctly inside the Arabic page. | `src/app/features/attendance/components/day-details-tabs/day-details-tabs.component.html`, `src/app/features/attendance/components/day-details-tabs/day-details-tabs.component.scss` |

### Month progress — missed vs catch-up hours

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-11 | EXCP-HOME-011 | Verify only one row is shown when the missed hours and the catch-up hours are the same. | Main | An employee who worked less than required so far this month, for example required "220 h 10 min" and worked "109 h 40 min". | 1. Open `/home`.<br>2. Read the rows in the "This month's work" panel. | 1. One row "Missed until today" is shown with "110" hours.<br>2. No second row for the hours needed to catch up with today is shown.<br>3. "Remaining until month end" is still shown below it. | `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.html` |
| TC-12 | EXCP-HOME-012 | Verify two clearly named rows are shown when the missed hours and the catch-up hours differ. | Edge | An employee whose missed hours from the server differ from the hours still needed to reach today's requirement. | 1. Open `/home` in English.<br>2. Read the rows in the "This month's work" panel.<br>3. Switch to Arabic and read them again. | 1. A row "Hours you are behind so far" is shown in red.<br>2. A row "Hours to work to catch up with today" is shown below it.<br>3. Both rows are translated in Arabic with no English text.<br>4. The two values are never off by one hour only because of rounding. | `src/app/pages/home/home.component.ts`, `src/app/pages/home/home.component.html`, `src/assets/i18n/en.json`, `src/assets/i18n/ar.json` |
