# Employee Hours Tour Guide — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `Employee Hours Report (admin leader reports area).`, `/attendance/quick-entry`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- Floating call-to-action on **Employee Hours Report** after a report is generated.
- **Tour mode** on **Attendance Quick Entry** for the same date range: step-by-step day navigation, optional autoplay (~5 seconds), cumulative dock metrics, completion modal.
- **Direct tour mode** from Quick Entry (no report context): same dock experience with **Exit tour** instead of return-to-report.
- Session snapshot in **sessionStorage** plus query params (`tourGuide`, `tourCtx`, `from`, `to`, `restoreTour`) for round-trip restore; snapshot carries **`targetUserId`** when an admin generated the report for a selected employee so Quick Entry loads that employee’s attendance.

## Test pages

- Employee Hours Report (admin leader reports area).
- `/attendance/quick-entry`

## Test scenarios

- Report-generated flow: CTA visible, tour opens with locked period; header shows dates, employee context, and cumulative summary chips after load; dock controls work; completion choices work; return restores report.
- Admin on Employee Hours Report: tour opens Quick Entry for the **same selected employee** as the report, not the signed-in admin.
- Direct-from-quick-entry flow: CTA visible after data load, tour opens without report snapshot, exit ends tour only.
- Draggable report floating button stays inside viewport; drag does not accidentally start the tour.
- Cumulative totals animate correctly (increase / decrease); autoplay uses chained delays (no burst at end).
- Weekend, public holiday, and leave days contribute scheduled regular time as documented; overtime follows real rows.
- English and Arabic strings for tour labels and buttons.

## Test cases

### Report page — floating tour button

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REPORT-EMPLOYEE-HOURS-001 | Verify the tour floating button stays hidden until a report is generated | Main | - | 1. Open Employee Hours Report.<br>2. Do not generate a report yet.<br>3. Look at the report work area. | The tour floating button is not shown. | - |
| TC-02 | EXCP-REPORT-EMPLOYEE-HOURS-002 | Verify the tour floating button appears after the report is generated | Main | - | 1. Open Employee Hours Report.<br>2. Fill required inputs and generate the report.<br>3. Look at the report work area. | The tour floating button is visible and is not shown in print layout. | - |
| TC-03 | EXCP-REPORT-EMPLOYEE-HOURS-003 | Verify clicking the tour floating button opens Quick Entry in tour mode with the same range | Main | - | 1. Generate an Employee Hours report.<br>2. Click the tour floating button (for example **How is this calculated? Take me on a tour** in English). | Quick Entry opens with **tour** mode active and the same **from** and **to** dates as the report. | - |
| TC-04 | EXCP-REPORT-EMPLOYEE-HOURS-004 | Verify the tour snapshot token is stored and appears in the URL | Main | - | 1. Generate a report and start the tour from the floating button.<br>2. Inspect the browser address bar on Quick Entry. | The URL includes `tourGuide=1`, `tourCtx`, `from`, and `to` as described in the technical guide. | - |
| TC-05 | EXCP-REPORT-EMPLOYEE-HOURS-005 | Verify the user can drag the report tour floating button without leaving the viewport | Main | - | 1. Generate a report so the floating button is visible.<br>2. Drag the button to another corner of the window.<br>3. Resize the browser window. | The button moves with the pointer and stays fully inside the viewport after drag and after resize. | - |
| TC-06 | EXCP-REPORT-EMPLOYEE-HOURS-006 | Verify dragging the report floating button does not start the tour by mistake | Edge | - | 1. Generate a report.<br>2. Drag the floating button and release without a normal click.<br>3. Confirm Quick Entry did not open in tour mode unless you clicked to start. | Quick Entry does not open in tour mode from drag alone. | - |

### Quick Entry — tour mode (from report)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-REPORT-EMPLOYEE-HOURS-007 | Verify tour mode shows the locked-period banner and hides main save and correction actions | Main | - | 1. Start the tour from the report as in TC-03.<br>2. Read the banner at the top of Quick Entry.<br>3. Look for save, schedule correction, and import controls. | A clear **tour guide** banner is shown and the main save / correction / import entry points are hidden as designed. | - |
| TC-08 | EXCP-REPORT-EMPLOYEE-HOURS-008 | Verify the dock shows cumulative totals starting at zero before the first step | Main | - | 1. Enter tour mode from the report.<br>2. Before pressing **Next**, read the dock totals. | Cumulative metrics show **00:00:00** (or equivalent) before the first day is applied. | - |
| TC-09 | EXCP-REPORT-EMPLOYEE-HOURS-009 | Verify **Next** applies the current day, updates totals, and highlights the correct day | Main | - | 1. Enter tour mode.<br>2. Click **Next** once.<br>3. Watch the grid highlight and the dock numbers. | The guided day advances, the outline matches the active day, and totals increase with the expected positive animation. | - |
| TC-10 | EXCP-REPORT-EMPLOYEE-HOURS-010 | Verify **Previous** removes the last applied day and moves the highlight back | Main | - | 1. Enter tour mode and press **Next** at least twice.<br>2. Press **Previous** once. | Totals decrease with the expected negative animation and the highlight returns to the previous day. | - |
| TC-11 | EXCP-REPORT-EMPLOYEE-HOURS-011 | Verify **Play** advances about every five seconds and **Pause** stops mid-run | Main | - | 1. Enter tour mode.<br>2. Click **Play**.<br>3. Wait for at least one automatic step.<br>4. Click **Pause** before the next automatic step finishes. | Steps advance on a short delay chain (about five seconds) and **Pause** stops further automatic steps. | - |
| TC-12 | EXCP-REPORT-EMPLOYEE-HOURS-012 | Verify the last day opens the completion modal and stops autoplay | Main | - | 1. Enter tour mode.<br>2. Step forward until you reach the last day in the range (use **Next** or **Play**). | A completion modal opens and autoplay does not continue past the last day. | - |
| TC-13 | EXCP-REPORT-EMPLOYEE-HOURS-013 | Verify weekend, holiday, or leave days use full scheduled regular contribution in the tour math | Edge | - | 1. Start a tour on a range that includes a weekend, a public holiday, or a leave day.<br>2. Step to such a day and read dock **Required work** and regular totals. | Regular contribution matches a full scheduled day for those day types; overtime still follows real overtime rows. | - |

### Completion modal

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-REPORT-EMPLOYEE-HOURS-014 | Verify **Replay** resets the tour step and zeroes cumulative totals | Main | - | 1. Reach the completion modal on the last day.<br>2. Choose **Replay**. | The modal closes, the step counter resets, and cumulative totals return to zero before stepping again. | - |
| TC-15 | EXCP-REPORT-EMPLOYEE-HOURS-015 | Verify **Stay here** closes the modal but keeps tour mode | Main | - | 1. Reach the completion modal.<br>2. Choose **Stay here**. | The modal closes and you remain in tour mode on Quick Entry. | - |
| TC-16 | EXCP-REPORT-EMPLOYEE-HOURS-016 | Verify **Go to report** returns to the report and restores context when coming from the report | Main | - | 1. Start the tour from the report.<br>2. Complete the tour and choose **Go to report** (or the equivalent header control). | The app navigates back to Employee Hours Report and restores inputs and regenerates the report using the saved snapshot token. | - |

### Direct tour from Quick Entry

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-17 | EXCP-REPORT-EMPLOYEE-HOURS-017 | Verify the direct tour floating button appears after Quick Entry data is loaded | Main | - | 1. Open `/attendance/quick-entry` without tour query params.<br>2. Wait until attendance data is loaded.<br>3. Look at the bottom-right area. | The direct tour floating button is visible (for example **Walk through your attendance** in English). | - |
| TC-18 | EXCP-REPORT-EMPLOYEE-HOURS-018 | Verify direct tour shows **Exit tour** instead of **Back to report** in the dock | Main | - | 1. Start the tour from Quick Entry using the direct floating button.<br>2. Read the dock pill and header actions. | Controls show **Exit tour** (or Arabic equivalent) and do not offer **Back to report** because there is no report context. | - |
| TC-19 | EXCP-REPORT-EMPLOYEE-HOURS-019 | Verify **Exit tour** ends the tour and returns Quick Entry to normal mode | Main | - | 1. Start direct tour mode.<br>2. Click **Exit tour** from the dock or header.<br>3. Check that save and correction actions are available again when your role allows it. | Tour mode ends, the banner is removed, and normal Quick Entry actions are available again. | - |

### Localization and accessibility

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-REPORT-EMPLOYEE-HOURS-020 | Verify tour strings resolve in English and Arabic | Regression | - | 1. Run through TC-03 or TC-17 in English and note key labels.<br>2. Switch the application language to Arabic.<br>3. Repeat the same flow. | All visible tour labels (floating button, banner, dock, modal) show the correct translated text. | - |
| TC-21 | EXCP-REPORT-EMPLOYEE-HOURS-021 | Verify tour regions expose helpful accessibility names | Main | - | 1. Enter tour mode.<br>2. Use browser accessibility tools to inspect the banner and dock regions. | Important regions are exposed to assistive technology with sensible names (as implemented in the product). | - |
| TC-22 | EXCP-REPORT-EMPLOYEE-HOURS-022 | Verify reduced motion does not break the tour | Edge | - | 1. Enable **prefers-reduced-motion** in the OS or browser.<br>2. Enter tour mode and step through several days. | The tour remains usable; animations follow the reduced-motion path without hiding required information. | - |

### Admin — tour matches selected report employee

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-REPORT-EMPLOYEE-HOURS-023 | Verify starting the tour from an admin report for another employee loads that employee’s quick-entry days | Main | Admin user is logged in; Employee Hours Report shows the employee list; a second employee has attendance you can recognize in the chosen range. | 1. Open `/admin/reports/employee-hours-report`.<br>2. Choose an employee who is not yourself from the employee field.<br>3. Set **from** and **to** dates and generate the report.<br>4. Click the tour floating button (**How is this calculated? Take me on a tour**).<br>5. In browser tools, open the **`POST`** call whose path ends with **`Get-bulk-details-in-range** for this page load.<br>6. Compare loaded day cards to that employee’s attendance (not your own). | 1. The request body includes that employee’s user id (not yours).<br>2. Day cards match that employee’s attendance for the range. | Employee: another account you can recognize; Range: dates with known attendance for that employee |

### Tour header — employee context and period totals

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-24 | EXCP-REPORT-EMPLOYEE-HOURS-024 | Verify tour mode header shows who the attendance belongs to and the cumulative summary chips after load | Main | Tour mode from report with generated report (TC-03) or TC-23; wait until day cards are visible. | 1. Enter Quick Entry in tour mode from the report.<br>2. Wait until loading finishes and day cards appear.<br>3. Read the header below the title row (dates + employee line + summary chips). | 1. Text identifies the employee (for example a line **Attendance for:** with the report email, or **Employee user id:** when only an id is stored).<br>2. Three chips match normal Quick Entry for cumulative net work, cumulative net overtime, and cumulative required net work, with values filled from the loaded period (not left as **—**). | - |
