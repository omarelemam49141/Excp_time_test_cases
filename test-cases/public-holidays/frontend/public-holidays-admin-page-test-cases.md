# Public Holidays Admin — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `public-holidays`
- Layer: `frontend`
- Routes: `/admin/public-holidays`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/public-holidays`


## Test scenarios

- **CRUD UX**: Create, edit, delete public holidays with validation and list refresh on **System work schedule → Holidays** tab (named holidays section).
- **Year filter**: Changing year reloads data from the API.
- **Merged tab**: Holidays tab shows named public holidays (API) and recurring month/day work policies (schedule bundle) on one page.
- **Legacy redirect**: `/admin/public-holidays` redirects to `/admin/system-work-schedule?tab=holidays` and opens the Holidays tab.
- **Leave policy redirect**: `/admin/leave-policy` redirects to `/admin/system-work-schedule?tab=leave-policy` and auto-opens Leave policy tab.
- **Localization**: EN/AR strings for section titles, toasts, and shared leave labels.
- **Recurring flag**: Checkbox state is sent on submit; month/day loaded from API on edit only.
- **Resilience**: Loading state, empty list, API error toasts (list/create/update/delete).


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-HOLIDAY-ADMIN-001 | Verify F-PH-01 — Holidays tab load | Main | - | 1. Navigate to `/admin/system-work-schedule` (unlocked), open **Holidays** tab | Intro text, year filter, named-holiday form, table area, and recurring-policy section visible | - |
| TC-02 | EXCP-HOLIDAY-ADMIN-002 | Verify F-PH-02 — Legacy redirect | Main | - | 1. Navigate to `/admin/public-holidays` as admin | Redirect to `/admin/system-work-schedule?tab=holidays`, Holidays tab active; query `tab` cleared after apply (replace) | - |
| TC-03 | EXCP-HOLIDAY-ADMIN-003 | Verify F-PH-03 — Year filter | Main | - | 1. Change year and trigger change | List reloads for selected year | - |
| TC-04 | EXCP-HOLIDAY-ADMIN-004 | Verify F-PH-04 — Create valid | Main | - | 1. Fill date, EN name, AR name; Save | Success toast (created key); row appears; form resets | - |
| TC-05 | EXCP-HOLIDAY-ADMIN-005 | Verify F-PH-05 — Edit | Main | - | 1. Click Edit on a row | Form prefilled; Save shows update toast; table refreshes | - |
| TC-06 | EXCP-HOLIDAY-ADMIN-006 | Verify F-PH-06 — Cancel edit | Main | - | 1. Edit then Cancel | Returns to create mode with cleared form | - |
| TC-07 | EXCP-HOLIDAY-ADMIN-007 | Verify F-PH-07 — Delete | Main | - | 1. Click Delete on a row | Success toast; row removed after refresh | - |

### Validation and form

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-HOLIDAY-ADMIN-008 | Verify F-PH-08 — Required names | Edge | - | 1. Clear name field; Save | Submit blocked; touched errors | - |
| TC-09 | EXCP-HOLIDAY-ADMIN-009 | Verify F-PH-09 — Required date | Edge | - | 1. Empty date; Save | Blocked | - |
| TC-10 | EXCP-HOLIDAY-ADMIN-010 | Verify F-PH-10 — Recurring checkbox | Main | - | 1. Toggle recurring; Save | Payload includes `isRecurringAnnually` | - |

### Edge / regression

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-HOLIDAY-ADMIN-011 | Verify F-PH-11 — List API error | Edge | - | 1. Simulate network failure for list | Error toast; table stable | - |
| TC-12 | EXCP-HOLIDAY-ADMIN-012 | Verify F-PH-12 — Save/delete API error | Edge | - | 1. Simulate failure on write | Error toast; no silent failure | - |
| TC-13 | EXCP-HOLIDAY-ADMIN-013 | Verify F-PH-13 — Long date display | Main | - | 1. Holiday with ISO date string | Column shows first 10 chars | - |
| TC-14 | EXCP-HOLIDAY-ADMIN-014 | Verify F-PH-14 — Edit row with recurring metadata | Main | - | 1. Backend returns `recurringMonth`/`recurringDay` | Form retains values on patch | - |
| TC-15 | EXCP-HOLIDAY-ADMIN-015 | Verify F-PH-15 — Sidebar | Main | - | 1. Open admin sidebar as admin | No separate “Public holidays” item; **Work schedule** opens merged page | - |
| TC-16 | EXCP-HOLIDAY-ADMIN-016 | Verify F-PH-16 — Recurring bundle save | Main | - | 1. Edit recurring rows; click main **Save updates** | Work schedule bundle saves; public holidays unchanged unless saved in their section | - |
| TC-17 | EXCP-HOLIDAY-ADMIN-017 | Verify F-PH-17 — Leave policy route redirect | Main | - | 1. Open `/admin/leave-policy` | Redirects to `/admin/system-work-schedule?tab=leave-policy`, Leave policy tab opens, then query param is cleared | - |
| TC-18 | EXCP-HOLIDAY-ADMIN-018 | Verify F-PH-18 — Non-admin access | Main | - | 1. Open `/admin/system-work-schedule without admin | Handled by guard policy | - |

### Localization

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-HOLIDAY-ADMIN-019 | Verify F-PH-19 — Arabic UI | Main | - | 1. Switch language to Arabic | Section and toast keys show Arabic; RTL acceptable | - |
