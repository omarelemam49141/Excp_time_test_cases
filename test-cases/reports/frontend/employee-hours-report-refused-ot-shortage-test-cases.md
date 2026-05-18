# Employee hours report — refused OT for shortage (Frontend Test Cases)

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `/admin/reports/employee-hours-report`
- APIs: `POST /api/Reports/employee-hours-report`
- Related code: `src/app/features/admin-leader/admin/components/reports/employee-hours-report/`, `src/app/features/admin-leader/admin/models/employee-hours-report-input.model.ts`
- Related docs: `docs/frontend/technical/employee-hours-report-refused-ot-shortage.md`

## Scope

Single employee hours report (admin): optional **Use refused overtime to cover shortage first** checkbox, apply/recalculate flow, API payload `useRefusedOvertimeForShortage`, and overtime breakdown rows when refused hours are consumed against shortage.

## Test pages

- `/admin/reports/employee-hours-report`

## Test scenarios

- Verify the refused-OT checkbox appears on admin report after generate when shortage is not fully waived.
- Verify checking the box and applying sends `useRefusedOvertimeForShortage` and updates effective shortage / breakdown when refused OT exists.

## Test cases

### Refused overtime for shortage

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REPORT-EH-REFUSED-OT-001 | Verify the refused-OT shortage section appears after generate on the admin report | Main | Admin is logged in; employee with refused OT and shortage in the chosen range. | 1. Open `/admin/reports/employee-hours-report`.<br>2. Pick the employee and a valid date range; click `"Generate report"`.<br>3. Scroll to the section titled `"Refused overtime vs shortage"`. | 1. The section is visible.<br>2. The checkbox labeled `"Use refused overtime to cover shortage first"` is unchecked by default. | Employee with refused OT + shortage |
| TC-02 | EXCP-REPORT-EH-REFUSED-OT-002 | Verify applying the refused-OT checkbox sends the flag and updates shortage outcomes | Edge | Same as TC-01 after a successful generate. | 1. Note `"Shortage hours"` and `"Effective shortage hours"` (or salary applied shortage if salary is on).<br>2. Check `"Use refused overtime to cover shortage first"`.<br>3. Click `"Apply & recalculate"`.<br>4. Inspect the generate POST body.<br>5. Read the same shortage fields and the overtime breakdown row `"Refused overtime used for shortage"`. | 1. POST body includes `"useRefusedOvertimeForShortage": true`.<br>2. Effective shortage (or applied shortage deduction) is lower than in step 1 when refused hours cover part of the gap.<br>3. Breakdown shows non-zero `"Refused overtime used for shortage"` when refused time was consumed. | - |
