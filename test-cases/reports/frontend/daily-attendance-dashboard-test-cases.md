# Daily attendance dashboard — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `/admin/reports/daily-attendance-dashboard`
- APIs: `POST /api/Reports/daily-attendance-dashboard`
- Related code: `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html`
- Related docs: `docs/frontend/technical/daily-attendance-dashboard.md`
- Automation: `-`

## Scope

Admin daily dashboard: KPI cards, four charts, branch table, top 10 late, full late list, leave today, upcoming leave.

## Test pages

- `/admin/reports/daily-attendance-dashboard`

## Test scenarios

- Reports bar opens the daily dashboard
- Formatted report date in the hero
- Late KPI shows count, percent, and total minutes
- Four charts: donut, branch status, late minutes, average late
- Top 10 late then full ranked list with aggregate footer
- Leave today shows expected back
- Upcoming leave this month
- Hide/show inactive employees
- Arabic labels

## Test cases

### Daily dashboard page

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Requires |
|----|-----|------|------|---------------|-------|----------|--------------|----------|
| TC-01 | EXCP-REPORT-DAD-UI-001 | Verify The reports bar has "Daily dashboard" and opens the page. | Main | Admin is logged in. | 1. Open `/admin/reports`.<br>2. Click "Daily dashboard". | 1. The bar shows "Daily dashboard" / "لوحة الحضور اليومية".<br>2. The URL is `/admin/reports/daily-attendance-dashboard`.<br>3. The title "Daily attendance performance" / "أداء الحضور اليومي" is visible. | `src/app/features/admin-leader/admin/components/reports/reports-layout/reports-layout.component.html` | - |
| TC-02 | EXCP-REPORT-DAD-UI-002 | Verify The hero shows the formatted report date for the selected day. | Main | Page loaded. | 1. Open `/admin/reports/daily-attendance-dashboard`.<br>2. Confirm today's date in the hero.<br>3. Pick another day in the calendar. | 1. The hero date matches the selected day (for example "14 September 2026" in English).<br>2. After changing the day, the hero date updates. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-001 |
| TC-03 | EXCP-REPORT-DAD-UI-003 | Verify KPI cards show workforce, present, late with total minutes, on leave, and absent. | Main | A day with at least one late person. | 1. Open the dashboard for that day.<br>2. Read the five KPI cards. | 1. Cards are "Workforce", "Present", "Late", "On leave", "Absent" (or Arabic).<br>2. Present, late, leave, and absent show a percent.<br>3. The Late card also shows total minutes and the unit "min" / "د".<br>4. Each card shows "vs previous day" / "مقارنة باليوم السابق". | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-001 |
| TC-04 | EXCP-REPORT-DAD-UI-004 | Verify Four charts are shown: attendance split, branch status, late minutes, and average lateness. | Main | Page loaded with at least one branch. | 1. Open the dashboard.<br>2. Scroll the chart panels. | 1. A chart titled "Attendance split" / "توزيع الحضور" is visible.<br>2. A chart titled "On time vs late vs leave, by branch" / "في الموعد مقابل التأخير والإجازة حسب الفرع" is visible.<br>3. A chart titled "Late minutes by branch" / "دقائق التأخير حسب الفرع" is visible.<br>4. A chart titled "Average lateness by branch" / "متوسط التأخير حسب الفرع" is visible. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.ts` | EXCP-REPORT-DAD-UI-001 |
| TC-05 | EXCP-REPORT-DAD-UI-005 | Verify "Lateness ranking — top 10" and "Every late arrival, ranked" both list late people, and the full list footer shows totals. | Main | A day with at least one late person. | 1. Open the dashboard for that day.<br>2. Read "Lateness ranking — top 10".<br>3. Read "Every late arrival, ranked".<br>4. Read the footer under the full list. | 1. Top 10 shows at most 10 late people, highest minutes first.<br>2. The full list includes every late person from top 10.<br>3. Columns include employee, branch, check-in, late from, minutes, and branch avg.<br>4. The footer matches "Total late employees: {count}. Aggregate lateness: {minutes} minutes." / "إجمالي المتأخرين: {count}. مجموع دقائق التأخير: {minutes}." | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-003 |
| TC-06 | EXCP-REPORT-DAD-UI-006 | Verify Late minutes above 30 appear under "Late by more than 30 minutes" and exactly 30 appears in the threshold note. | Main | A day with one person more than 30 minutes late and one person exactly 30 minutes late, if data exists. | 1. Open that day.<br>2. Read the red alerts panel. | 1. People over 30 minutes are listed under "Late by more than 30 minutes" / "تأخير أكثر من 30 دقيقة".<br>2. If someone is exactly 30 minutes late, they appear under "Exactly 30 minutes (at the threshold, not flagged critical):".<br>3. The 30-minute person is not in the over-30 list. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-005 |
| TC-07 | EXCP-REPORT-DAD-UI-007 | Verify "On authorised leave" lists each person and expected back when the leave has an end date. | Main | A day with at least one approved leave. | 1. Open that day.<br>2. Read "On authorised leave" / "في إجازة مصرّح بها". | 1. Each leave person is named.<br>2. When an end date exists, the line includes "expected back" / "العودة المتوقعة" and that date. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-001 |
| TC-08 | EXCP-REPORT-DAD-UI-008 | Verify "Leave later this month" lists approved leave that starts after the selected day. | Main | Selected day has upcoming approved leave in the same month, or none. | 1. Open that day.<br>2. Read "Leave later this month" / "إجازات لاحقة هذا الشهر". | 1. If none, the empty text is "No upcoming approved leave this month." / "لا توجد إجازات معتمدة قادمة هذا الشهر.".<br>2. If any, each line shows the person, leave type, start date, and end date. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.html` | EXCP-REPORT-DAD-UI-007 |
| TC-09 | EXCP-REPORT-DAD-UI-009 | Verify "Hide inactive employees" is the default and "Show inactive employees" reloads with inactive people in the workforce. | Main | At least one inactive employee with email. | 1. Open the dashboard (default).<br>2. Note the Workforce number.<br>3. Click "Show inactive employees".<br>4. Click "Hide inactive employees". | 1. First load uses the hide-inactive state.<br>2. After show, Workforce is higher if inactive people exist.<br>3. After hide, Workforce returns to the first number. | `src/app/features/admin-leader/admin/components/reports/daily-attendance-dashboard/daily-attendance-dashboard.component.ts` | EXCP-REPORT-DAD-UI-003 |
| TC-10 | EXCP-REPORT-DAD-UI-010 | Verify Arabic UI shows Arabic dashboard labels. | Main | Language is Arabic. | 1. Switch the app to Arabic.<br>2. Open `/admin/reports/daily-attendance-dashboard`. | 1. The title is "أداء الحضور اليومي".<br>2. The nav item is "لوحة الحضور اليومية".<br>3. KPI labels are Arabic (for example "متأخر", "حاضر"). | `src/assets/i18n/ar.json` | EXCP-REPORT-DAD-UI-001 |
