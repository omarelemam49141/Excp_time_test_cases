# Quick Entry tour — Gregorian dates and tour UX — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/admin/reports/employee-hours-report`, `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/features/attendance/components/attendance-quick-entry`, `src/app/features/admin-leader/admin/components/reports/employee-hours-report`, `src/app/features/admin-leader/admin/models/employee-hours-tour-snapshot.model.ts`, `src/app/core/services/attendance.service.ts`
- Related docs: `docs/frontend/technical/employee-hours-tour-guide.md`, `docs/frontend/technical/quick-entry-problem-days-navigator.md`

## Scope

- Employee Hours report → Quick Entry guided tour (`tourGuide=1`, `from` / `to` query params).
- Attendance Quick Entry tour mode: expanding day cards, problem-days floating navigator, read-only fields during tour.

## Test pages

- `/admin/reports/employee-hours-report`
- `/attendance/quick-entry` (tour mode from report or direct tour)

## Test scenarios

- Tour opens with Gregorian calendar dates in the address bar and in the bulk-details request body.
- In tour mode, the tester can expand a day, use the problem-days navigator when problems exist, and cannot change time fields (tour is view-only for edits).

## Test cases

### Gregorian handoff and tour navigation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|-----------------|-------|----------|-----------|
| TC-01 | EXCP-QE-TOUR-GREGORIAN-001 | Verify the tour opens with Gregorian year digits in the address bar | Main | You are signed in as an admin. An employee is selected and a report period is chosen with years in the `"2000"`–`"2100"` range (for example `"2026-05-01"` to `"2026-05-12"`). | 1. Open **Employee Hours Report**.<br>2. Fill the period and employee, then generate the report.<br>3. Click **"How is this calculated? Take me on a tour"** (or the equivalent floating tour control).<br>4. Inspect the browser address bar on the Quick Entry page. | 1. The Quick Entry page loads in tour mode.<br>2. The `from` and `to` query parameters show years like `"2026"` (four digits in the usual Gregorian range), not a Hijri-only year such as `"1447"`. | From: `"2026-05-01"`<br>To: `"2026-05-12"` |
| TC-02 | EXCP-QE-TOUR-GREGORIAN-002 | Verify **Get-bulk-details-in-range** uses the same Gregorian dates as the tour | Main | Same as TC-01; DevTools **Network** tab is open before starting the tour. | 1. Repeat steps 1–3 from TC-01.<br>2. In **Network**, find the **POST** call whose path ends with **Get-bulk-details-in-range**.<br>3. Open the request **Payload** / body. | 1. The request body includes `"from"` and `"to"` strings.<br>2. Both strings use a Gregorian year (for example starting with `"2026-"), matching the tour query dates. | - |
| TC-03 | EXCP-QE-TOUR-GREGORIAN-003 | Verify a day card can expand in tour mode | Main | You are on Quick Entry in tour mode after data has loaded (from report or direct tour). | 1. Click the summary row (date and weekday line) of a weekday that is not a future day.<br>2. Observe the card below the summary. | 1. The day expands to show details (rest periods / overtime section appears).<br>2. No browser error or frozen UI. | - |
| TC-04 | EXCP-QE-TOUR-GREGORIAN-004 | Verify the problem-days floating bar appears in tour mode when a day has problems | Edge | Tour mode is on and at least one loaded day shows the problem warning badge (exclamation) on the summary row. | 1. Look at the bottom of the viewport.<br>2. If the orange problem-days bar is visible, tap **next** until the page scrolls to another problem day. | 1. A floating bar for problem days is visible (label matches your language for problem days).<br>2. Tapping next moves focus to another problem day and that day expands. | - |
| TC-05 | EXCP-QE-TOUR-GREGORIAN-005 | Verify time and workplace controls are disabled during tour | Regression | Tour mode is on; a weekday day card is expanded. | 1. Expand a weekday card.<br>2. Try to change **start** time, **end** time, workplace, rest times, or overtime fields. | 1. Summary time inputs and workplace select on the summary row cannot be edited (disabled or equivalent).<br>2. Expanded **rest** and **overtime** fields cannot be edited.<br>3. **Add** / **remove** break and **add** overtime / **delete** overtime actions are not usable. | - |
