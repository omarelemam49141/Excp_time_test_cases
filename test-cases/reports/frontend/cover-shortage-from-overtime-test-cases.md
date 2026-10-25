# Cover shortage from the overtime balance (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `/admin/reports/employee-hours-report`
- APIs: `POST /api/Reports/employee-hours-report`
- Related code: `src/app/features/admin-leader/admin/components/reports/employee-hours-report/employee-hours-report.component.ts`, `src/app/features/admin-leader/admin/components/reports/employee-hours-report/employee-hours-report.component.html`
- Related docs: `docs/frontend/technical/employee-hours-report-accepted-and-pending-hours.md`

## Scope

- Admin covers an employee's shortage with accepted overtime hours, chosen per bucket (1.5x or 2.0x). Preview only.

## Test scenarios

- Panel visibility
- Per-bucket caps
- Apply and clear

## Test cases

### Wave 1 — Report panel

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-REPORT-COVER-UI-001 | Verify the panel shows for an employee with shortage, accepted overtime and no coverage request. | Main | EXCP-REPORT-COVER-SHORTAGE-001 | 1. Sign in as Admin.<br>2. Generate the report of an employee with shortage and accepted overtime but no shortage-coverage request. | 1. "Cover shortage from the overtime balance" shows the shortage hours and both buckets with their available hours. |
| TC-02 | EXCP-REPORT-COVER-UI-002 | Verify the panel is hidden when a coverage request exists or there is no shortage or no accepted overtime. | Edge | EXCP-REPORT-COVER-UI-001 | 1. Generate a report for an employee with a pending or accepted shortage-coverage request.<br>2. Generate one with no shortage. | 1. The panel is not shown in either case. |
| TC-03 | EXCP-REPORT-COVER-UI-003 | Verify the inputs are capped to each bucket and to the remaining shortage. | Edge | EXCP-REPORT-COVER-UI-001 | 1. Type more hours than a bucket holds.<br>2. Type hours in both buckets that together exceed the shortage. | 1. Each value is reduced to its bucket balance.<br>2. The total never exceeds the shortage and the remaining shortage never goes below 0. |
| TC-04 | EXCP-REPORT-COVER-UI-004 | Verify Apply covers the shortage one hour per hour and the report updates. | Main | EXCP-REPORT-COVER-UI-001 | 1. Enter 1 hour from the 1.5x bucket and Apply. | 1. Shortage drops by 1 hour and payable overtime drops by 1 hour.<br>2. Nothing is saved: reloading the report shows the original numbers. |
| TC-05 | EXCP-REPORT-COVER-UI-005 | Verify Clear restores the report. | Edge | EXCP-REPORT-COVER-UI-004 | 1. Press Clear. | 1. The fields empty and the shortage and payable overtime return to the original values. |
