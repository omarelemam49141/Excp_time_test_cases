# Users daily attendance roster — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `/admin/reports/users-attendance-report`
- APIs: `POST /api/Reports/users-daily-attendance-roster`
- Related code: `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts`, `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.html`, `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-header/users-attendance-report-list-header.component.html`, `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html`
- Related docs: `docs/frontend/technical/users-daily-attendance-roster-page.md`

## Scope

Attendance records tab: one work date plus required period start, all employees, start/end/net hours, punctuality after late/early allowance, cumulative payable overtime for the period, hide inactive. Totals/Excel stay on the legacy API.

## Test pages

- `/admin/reports/users-attendance-report`

## Test scenarios

- Page requires one work date and a period start before listing employees
- Hide/show inactive employees
- Leave row shows shift times and required hours
- Missing punch shows "—" and 0:00 net
- Punched site/home net matches hours-report start/end for that day
- Punctuality column shows On time / Late N min / Early N min / —
- Payable overtime column matches hours-report payable leftover with pending treated as accepted

## Delivery waves

| Wave | Intent | Keys |
|------|--------|------|
| 4 | Roster page | EXCP-REPORT-UAR-UI-001 … 006 |
| 7 | Punctuality column | EXCP-REPORT-UAR-UI-007 … 010 |
| 10 | Period start + payable overtime column | EXCP-REPORT-UAR-UI-011 … 015 |

## Test cases

### Wave 4 — Users attendance report page

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-01 | EXCP-REPORT-UAR-UI-001 | Verify The attendance tab shows Username, "Start time", "End time", "Work duration without breaks", "Punctuality", and "Payable overtime" after a valid search. | Main | Admin is logged in. | 1. Open `/admin/reports/users-attendance-report`.<br>2. Pick a "Period start" on or before the work date.<br>3. Click "Search".<br>4. Look at the Attendance records table. | 1. A work date is selected (today by default).<br>2. The table shows one row per employee, not only people who punched.<br>3. Columns are "Username", "Start time", "End time", "Work duration without breaks", "Punctuality", and "Payable overtime".<br>4. Breaks and overtime duration columns are not shown. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-API-001 |
| TC-02 | EXCP-REPORT-UAR-UI-002 | Verify Search without a work date is blocked. | Edge | Page is open. | 1. Clear the work date if possible, or open the page and click "Search" after reset without picking a date only if the calendar is empty.<br>2. Prefer: open Network and confirm each table load sends `workDate`. | 1. Roster requests include a `workDate` value.<br>2. The page does not call the API with an empty date. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts` | EXCP-REPORT-UAR-UI-001 |
| TC-03 | EXCP-REPORT-UAR-UI-003 | Verify "Hide inactive employees" removes inactive rows and "Show inactive employees" brings them back. | Main | At least one inactive employee exists. Period start and work date are set. | 1. Search so an inactive row with badge "Inactive" is visible (default includes them).<br>2. Click "Hide inactive employees".<br>3. Click "Show inactive employees". | 1. After hide, inactive rows are gone.<br>2. After show, the inactive employee returns with the "Inactive" badge. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-header/users-attendance-report-list-header.component.html` | EXCP-REPORT-UAR-API-005, EXCP-REPORT-UAR-UI-001 |
| TC-04 | EXCP-REPORT-UAR-UI-004 | Verify An approved leave day with no punch shows shift times, a "Leave" badge, and required-hours net. | Main | Known leave day with no punch. | 1. Set the work date to that leave day and a valid period start.<br>2. Click "Search".<br>3. Find the employee. | 1. "Leave" badge is visible.<br>2. "Start time" and "End time" match the day's shift.<br>3. "Work duration without breaks" matches required work hours. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-API-003, EXCP-REPORT-UAR-UI-001 |
| TC-05 | EXCP-REPORT-UAR-UI-005 | Verify A missing punch (not leave) shows "—" for start and end and 0:00 net. | Main | Employee with no punch and no leave on the selected day. | 1. Open the date with a valid period start.<br>2. Find the employee. | 1. Start and end cells show "—".<br>2. Net duration shows 0:00 (or `"00:00:00"` formatted). | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-API-004, EXCP-REPORT-UAR-UI-001 |
| TC-06 | EXCP-REPORT-UAR-UI-006 | Verify For a punched day, start and end match the employee hours report "Actual start" and "Actual end" for that employee and date. | Regression | Same employee punched that day (site or home). | 1. Note start, end, and net on this page.<br>2. Open `/admin/reports/employee-hours-report` for the same employee and date.<br>3. Compare the day line Actual start / Actual end. | 1. Start time matches Actual start.<br>2. End time matches Actual end.<br>3. Net on this page uses the gap formula (home gap if Home or None workplace). | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts` | EXCP-REPORT-UAR-API-001, EXCP-REPORT-UAR-UI-001 |

### Wave 7 — Punctuality column

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-07 | EXCP-REPORT-UAR-UI-007 | Verify A punch start inside late grace shows the "On time" chip in the Punctuality column. | Main | Shift 09:00, late tolerance 15, employee punched 09:05. | 1. Open `/admin/reports/users-attendance-report` for that date with a valid period start.<br>2. Find the employee row. | 1. The Punctuality cell shows "On time".<br>2. The chip is teal, not amber. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-PUNC-API-001, EXCP-REPORT-UAR-UI-001 |
| TC-08 | EXCP-REPORT-UAR-UI-008 | Verify A punch start beyond late grace shows "Late {n} min" with the penalizable minutes. | Main | Shift 09:00, late tolerance 15, employee punched 09:20. | 1. Open the roster for that date with a valid period start.<br>2. Find the employee row. | 1. The Punctuality cell shows "Late 5 min".<br>2. The chip is amber. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-PUNC-API-002, EXCP-REPORT-UAR-UI-007 |
| TC-09 | EXCP-REPORT-UAR-UI-009 | Verify A punch start beyond early grace shows "Early {n} min". | Edge | Shift 09:00, early tolerance 10, employee punched 08:40. | 1. Open the roster for that date with a valid period start.<br>2. Find the employee row. | 1. The Punctuality cell shows "Early 10 min".<br>2. The chip is teal and distinct from the late chip. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-PUNC-API-003, EXCP-REPORT-UAR-UI-008 |
| TC-10 | EXCP-REPORT-UAR-UI-010 | Verify Leave and absent rows show "—" in the Punctuality column. | Main | One approved-leave employee and one employee with no punch. | 1. Open the roster for that date with a valid period start.<br>2. Find both employees. | 1. The leave row Punctuality cell shows "—".<br>2. The absent row Punctuality cell shows "—".<br>3. Neither row shows "On time". | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-PUNC-API-004, EXCP-REPORT-UAR-PUNC-API-005, EXCP-REPORT-UAR-UI-001 |

### Wave 10 — Period start and payable overtime column

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-11 | EXCP-REPORT-UAR-UI-011 | Verify Search without a period start is blocked and does not call the roster API. | Main | Admin is logged in. Work date is today. | 1. Open `/admin/reports/users-attendance-report`.<br>2. Leave "Period start" empty.<br>3. Click "Search". | 1. An error shows "Period start is required" / "بداية الفترة مطلوبة".<br>2. No `POST` to `users-daily-attendance-roster` is sent. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts` | EXCP-REPORT-UAR-OT-API-001 |
| TC-12 | EXCP-REPORT-UAR-UI-012 | Verify Search is blocked when period start is after the work date. | Main | Page is open. | 1. Set "Period start" to a day after the work date.<br>2. Click "Search". | 1. An error shows "Period start must be on or before the work date" / "يجب أن تكون بداية الفترة في تاريخ العمل أو قبله".<br>2. No roster request is sent. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts` | EXCP-REPORT-UAR-UI-011 |
| TC-13 | EXCP-REPORT-UAR-UI-013 | Verify Opening the page does not auto-load the roster until Search. | Main | Admin is logged in. | 1. Open `/admin/reports/users-attendance-report`.<br>2. Watch Network before clicking Search. | 1. The filter header is visible with today's work date and empty period start.<br>2. No roster API call is sent on first visit. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report.component.ts` | EXCP-REPORT-UAR-UI-011 |
| TC-14 | EXCP-REPORT-UAR-UI-014 | Verify The "Payable overtime" cell matches hours-report "Payable overtime hours" with pending treated as accepted. | Main | Same employee and dates as Wave 9 API compare. | 1. Search the roster with that period start and work date.<br>2. Note the "Payable overtime" cell.<br>3. Open `/admin/reports/employee-hours-report` for the same employee and dates with "What if pending overtime was accepted?" on. | 1. The roster cell clock equals hours-report "Payable overtime hours". | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-OT-API-003, EXCP-REPORT-UAR-UI-001 |
| TC-15 | EXCP-REPORT-UAR-UI-015 | Verify An employee with no leftover overtime shows `0:00:00` in "Payable overtime". | Main | Employee with no payable leftover in the range. | 1. Search the roster.<br>2. Find the employee. | 1. The "Payable overtime" cell shows `0:00:00`. | `src/app/features/admin-leader/admin/components/reports/users-attendance-report/users-attendance-report-list-table/users-attendance-report-list-table.component.html` | EXCP-REPORT-UAR-OT-API-004, EXCP-REPORT-UAR-UI-014 |
