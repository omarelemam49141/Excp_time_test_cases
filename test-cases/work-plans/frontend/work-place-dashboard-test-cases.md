# Work place dashboard — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `work-plans`
- Layer: `frontend`
- Routes: `/admin/reports/daily-attendance-dashboard`, `/admin-leader/work-place-dashboard`
- APIs: `POST /api/work-place-dashboard/summary`, `POST /api/work-place-dashboard/employees`
- Automation: -
- Related code: `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts`
- Related docs: `docs/frontend/technical/work-place-dashboard-and-work-plans.md`

## Scope

- The Work place tab on the admin dashboard and the standalone leader/HR page: period, filters, KPI cards, violations, charts, employee table and export.

## Test pages

- `/admin/reports/daily-attendance-dashboard`
- `/admin-leader/work-place-dashboard`

## Test scenarios

- Verify planned and actual home/company numbers are shown and match the employees listed.
- Verify period and filters change the numbers.
- Verify access: admin sees all, HR sees all, leader sees only the team.
- Verify the page works in Arabic (RTL) and at laptop width.

## Test cases

### Tabs and access

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-WORKPLAN-UI-001 | Verify the admin dashboard opens on the Work place tab | Main | Signed in as Admin. | 1. Open `/admin/reports/daily-attendance-dashboard`. | 1. The "Work place" tab is selected.<br>2. The "Attendance and lateness" tab is available. | - | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` |
| TC-02 | EXCP-WORKPLAN-UI-002 | Verify the original attendance view still works under its tab | Regression | Signed in as Admin. | 1. Open the dashboard.<br>2. Select "Attendance and lateness". | 1. The original cards, late list and leave lists appear.<br>2. Today and Yesterday buttons still reload the data. | - | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` |
| TC-03 | EXCP-WORKPLAN-UI-003 | Verify HR and leaders can open the standalone page | Main | Signed in as HR, then as a Leader. | 1. Open the sidebar Team group.<br>2. Click "Work place". | 1. The page `/admin-leader/work-place-dashboard` opens with its own title.<br>2. An Employee user is sent back when opening the URL. | - | `src/app/features/admin-leader/shared/admin-leader.routes.ts`, `src/app/core/guards/core/guards/is-leader-hr-or-admin.guard.ts`, `src/app/core/components/sidebar/sidebar.component.ts` |
| TC-04 | EXCP-WORKPLAN-UI-004 | Verify a leader sees only the direct team | Main | Leader has direct reports and other employees exist. | 1. Sign in as the Leader.<br>2. Open the Work place page. | 1. The scope line counts only the leader's direct team.<br>2. The employee table lists only team members. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |

### Numbers and drill-down

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-05 | EXCP-WORKPLAN-UI-005 | Verify the four KPI cards show planned and worked numbers | Main | Plans exist and some employees checked in from home and from the company today. | 1. Open the Work place tab for today. | 1. "Must work from the company" and "Must work from home" show the planned counts.<br>2. "Worked from the company" and "Worked from home" show the check-in counts.<br>3. The worked cards show the percent of the plan followed. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.html` |
| TC-06 | EXCP-WORKPLAN-UI-006 | Verify clicking a card filters the employee table | Main | Numbers are shown. | 1. Click "Must work from home".<br>2. Click the same card again. | 1. The table lists only employees with home-planned days and the heading names the group.<br>2. The second click clears the group. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-07 | EXCP-WORKPLAN-UI-007 | Verify violations are counted and listed | Main | An employee planned for the company checked in from home without an approved work-from-home request. | 1. Open the Work place tab for that day.<br>2. Click the "Violations" card. | 1. The violations count includes the employee.<br>2. The employee row is highlighted and the violation date shows on hover. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.html` |
| TC-08 | EXCP-WORKPLAN-UI-008 | Verify an approved work-from-home request is not a violation | Edge | Same employee as above has an approved work-from-home request for that day. | 1. Open the Work place tab for that day. | 1. The employee counts as planned for home and worked from home.<br>2. The employee is not in the violations list. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-09 | EXCP-WORKPLAN-UI-009 | Verify weekends and holidays are not counted | Edge | A weekend day exists in the work schedule. | 1. Select Day and pick a weekend date. | 1. A notice says the period has no working days.<br>2. All counts are 0. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.html` |

### Period and filters

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-10 | EXCP-WORKPLAN-UI-010 | Verify Day, Week, Month and Custom ranges | Main | Data exists in the last month. | 1. Click Week.<br>2. Click the previous arrow.<br>3. Click Month.<br>4. Click Custom and pick two dates. | 1. The label shows Sunday to Saturday of the week.<br>2. The previous period loads.<br>3. The label shows the whole month and the trend chart appears.<br>4. The custom range loads. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-11 | EXCP-WORKPLAN-UI-011 | Verify a custom range over 93 days is refused | Edge | Custom mode is open. | 1. Pick a range longer than 93 days. | 1. An error says the range cannot exceed 93 days.<br>2. The range is cleared. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-12 | EXCP-WORKPLAN-UI-012 | Verify search, location and planned-place filters | Main | Employees in Egypt and Saudi exist. | 1. Type part of an employee name.<br>2. Clear it and pick a location.<br>3. Click "Home" in planned place.<br>4. Click "Clear filters". | 1. Only matching employees remain.<br>2. Only that location remains.<br>3. Only home-planned days are counted.<br>4. All filters reset. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-13 | EXCP-WORKPLAN-UI-013 | Verify empty state when no employee matches | Edge | - | 1. Search for a name that does not exist. | 1. An empty message appears.<br>2. A "Clear filters" button resets the page. | Search: "zzzz" | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.html` |

### Export and display

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-14 | EXCP-WORKPLAN-UI-014 | Verify the employee list exports to CSV | Main | Table has rows. | 1. Select a group.<br>2. Click "Export CSV". | 1. A CSV file downloads with the same employees as the selected group.<br>2. Arabic names open correctly in Excel. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-15 | EXCP-WORKPLAN-UI-015 | Verify Arabic layout and laptop width | Regression | Language set to Arabic. | 1. Open the Work place tab at 1366px width.<br>2. Switch to English. | 1. Layout is right-to-left, arrows point the correct way, no raw English text.<br>2. There is no page-level horizontal scroll in either language. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.scss` |
| TC-16 | EXCP-WORKPLAN-UI-016 | Verify the page explains empty numbers when no plan exists | Edge | No approved plan covers the selected period. | 1. Open the Work place tab. | 1. A banner says no work plans are set for this period.<br>2. The banner has a "Set work plans" button that opens Work plans.<br>3. The "plan followed" bars are hidden. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.html` |
| TC-17 | EXCP-WORKPLAN-UI-017 | Verify worked-from cards list the same employees they count | Regression | An employee worked from the company on a home day. | 1. Click "Worked from the company". | 1. The table lists every employee counted in the card, including the one who came on a home day. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
