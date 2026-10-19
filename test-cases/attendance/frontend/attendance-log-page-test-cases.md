# My attendance (attendance log) — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/all-attendance`
- APIs: `POST /api/attendance-record/get-in-range-with-user-id`, `POST /api/attendance-record/Get-details-by-date`
- Related code: `src/app/pages/attendance-page/attendance-page.component.ts`, `src/app/pages/attendance-page/attendance-page.component.html`
- Related docs: `docs/frontend/technical/attendance-log-page.md`
- Automation (Karma, optional): `src/app/pages/attendance-page/attendance-page.component.spec.ts`, `src/app/pages/attendance-page/attendance-card/attendance-card.component.spec.ts`

## Scope

- The signed-in user's own attendance log: title and Quick entry action, date picker, newest-first daily rows, loading and empty states, pagination, and opening one day.
- Arabic and English, laptop and phone widths.

## Test pages

- `/all-attendance`

## Test scenarios

- The list is newest first and each row shows the right variant (worked, rest day, not recorded).
- Loading shows skeleton rows, never a false "No records available".
- Pagination appears only when it is useful.
- Opening a day shows a way back to the list.
- The page works in Arabic (RTL) and English and never scrolls sideways.

## Test cases

### Daily records

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-LOG-001 | Verify the page shows the title, a Quick entry button and the daily records newest first. | Main | Signed in; the current month has at least 3 days of records. | 1. Open `/all-attendance`. | 1. The title "My attendance" is shown with a "Quick entry" outline button beside it.<br>2. "Daily records" shows a count chip equal to the number of days.<br>3. The first row is the most recent day and the last row the oldest. | `src/app/pages/attendance-page/attendance-page.component.html`, `src/app/pages/attendance-page/attendance-page.component.ts` |
| TC-02 | EXCP-ATT-LOG-002 | Verify a worked day shows labelled times and a Worked duration, red when the day is short. | Main | A day with start, end and worked time; another with fewer hours than required. | 1. Find both days in the list. | 1. Each shows "Attendance Time", "Break Time", "Dismissal Time" and "Worked" with values.<br>2. The short day's Worked value is red. | `src/app/pages/attendance-page/attendance-card/attendance-card.component.html`, `src/app/pages/attendance-page/attendance-card/attendance-card.component.ts` |
| TC-03 | EXCP-ATT-LOG-003 | Verify a rest day shows a quiet "Weekend" label and no times. | Edge | The month includes a weekly rest day. | 1. Find the rest day row. | 1. The row shows a muted "Weekend" label.<br>2. No attendance, break or dismissal values are shown.<br>3. The row is visually quieter than a worked day. | `src/app/pages/attendance-page/attendance-card/attendance-card.component.html` |
| TC-04 | EXCP-ATT-LOG-004 | Verify a working day with no record shows a clear "Not recorded" notice. | Edge | A past working day with no attendance record. | 1. Find that day in the list and in the day picker. | 1. The row shows "Not recorded." followed by the explanation.<br>2. The day chip in the picker has a red dot. | `src/app/pages/attendance-page/attendance-card/attendance-card.component.html`, `src/app/core/components/day-picker/day-picker.component.html` |
| TC-05 | EXCP-ATT-LOG-005 | Verify the today row is marked and an open shift has no Worked value. | Edge | Today has a start time and no end time. | 1. Open the page and read today's row. | 1. The row has a "Today" badge.<br>2. No "Worked" value is shown.<br>3. Dismissal time shows `--:--`. | `src/app/pages/attendance-page/attendance-card/attendance-card.component.ts` |

### Loading, empty and paging

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-06 | EXCP-ATT-LOG-006 | Verify skeleton rows show while loading and "No records available" never flashes. | Main | Throttle the network to slow 3G. | 1. Open `/all-attendance`. | 1. Three skeleton rows are shown until the data arrives.<br>2. "No records available" is not shown during loading. | `src/app/pages/attendance-page/attendance-page.component.ts`, `src/app/pages/attendance-page/attendance-page.component.html` |
| TC-07 | EXCP-ATT-LOG-007 | Verify the empty state says what will appear and the loading state ends if the request fails. | Edge | A month with no records; then the API offline. | 1. Open the page for the empty month.<br>2. Go offline and reload. | 1. The empty state shows "No records available" and "Days you check in will appear here."<br>2. When the request fails the skeleton rows disappear and the error dialog is shown once. | `src/app/pages/attendance-page/attendance-page.component.html`, `src/app/pages/attendance-page/attendance-page.component.ts` |
| TC-08 | EXCP-ATT-LOG-008 | Verify pagination appears once, only for more than 5 days. | Main | One month with 4 days and one with 8 or more days. | 1. Open the 4-day month.<br>2. Open the longer month. | 1. The 4-day month shows no pagination.<br>2. The longer month shows a single pagination control below the list, none above. | `src/app/pages/attendance-page/attendance-page.component.html`, `src/app/pages/attendance-page/attendance-page.component.ts` |

### Opening a day

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-09 | EXCP-ATT-LOG-009 | Verify opening a day shows its details, a "Showing" label and a way back. | Main | At least two days in the list. | 1. Press "Show details" on a day.<br>2. Press "Show All Days". | 1. The list is replaced by the Attendance / Overtimes tabs for that day.<br>2. A chip "Showing <date>" and a "Show All Days" button are shown, and the picker marks that day.<br>3. "Show All Days" returns to the full list. | `src/app/pages/attendance-page/attendance-page.component.html`, `src/app/pages/attendance-page/attendance-page.component.ts` |

### Language and size

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-10 | EXCP-ATT-LOG-010 | Verify the page is correct in Arabic and English on laptop and phone widths. | Edge | Browser widths 1366px and 390px. | 1. Open `/all-attendance` in Arabic, then English, at each width. | 1. All text is translated and the layout mirrors in Arabic (chevrons point along the reading direction).<br>2. The page never scrolls sideways.<br>3. On the phone each row stacks and its button fills the width.<br>4. The title is below the fixed navbar. | `src/app/pages/attendance-page/attendance-page.component.scss`, `src/app/pages/attendance-page/attendance-card/attendance-card.component.scss` |
