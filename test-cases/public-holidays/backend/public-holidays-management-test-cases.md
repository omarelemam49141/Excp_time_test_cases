# Public Holidays Management — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `public-holidays`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- **Happy path**: Admin creates, lists, updates, and deletes public holidays; authenticated user can list.
- **Authorization**: Mutations restricted to admin role.
- **List filtering**: Optional `year` query includes fixed holidays in that year and all recurring rows.
- **Leave integration**: Fixed and recurring holidays exclude dates from chargeable leave days when policy says so.
- **Edge cases**: Invalid recurring calendar day, missing recurring fields with flag set, duplicate dates, deleted rows excluded from calculator.


## Test cases

### CRUD and list

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-HOLIDAY-HRS-MANAGEMENT-001 | Verify B-PH-01 — List without year | Main | - | 1. GET `api/public-holidays/list` as authenticated user | `200`, array of non-deleted holidays ordered by date | - |
| TC-02 | EXCP-HOLIDAY-HRS-MANAGEMENT-002 | Verify B-PH-02 — List with year | Main | - | 1. GET `api/public-holidays/list?year=2026` | Includes holidays with `Date` in 2026 and any row with `IsRecurringAnnually == true` | - |
| TC-03 | EXCP-HOLIDAY-HRS-MANAGEMENT-003 | Verify B-PH-03 — Create holiday (admin) | Main | - | 1. POST `api/public-holidays` with valid `PublicHolidayDto` as admin | `200`, response contains created data with assigned `Id` | - |
| TC-04 | EXCP-HOLIDAY-HRS-MANAGEMENT-004 | Verify B-PH-04 — Create holiday (non-admin) | Edge | - | 1. POST as non-admin | `403` Forbidden | - |
| TC-05 | EXCP-HOLIDAY-HRS-MANAGEMENT-005 | Verify B-PH-05 — Update holiday (admin) | Main | - | 1. PUT `api/public-holidays/{id}` with changed names/date | `200`, message indicates update | - |
| TC-06 | EXCP-HOLIDAY-HRS-MANAGEMENT-006 | Verify B-PH-06 — Update holiday (non-admin) | Edge | - | 1. PUT as non-admin | `403` | - |
| TC-07 | EXCP-HOLIDAY-HRS-MANAGEMENT-007 | Verify B-PH-07 — Delete holiday (admin) | Main | - | 1. DELETE `api/public-holidays/{id}` | `200`, holiday no longer returned in list (per soft-delete behavior) | - |
| TC-08 | EXCP-HOLIDAY-HRS-MANAGEMENT-008 | Verify B-PH-08 — Delete holiday (non-admin) | Edge | - | 1. DELETE as non-admin | `403` | - |
| TC-09 | EXCP-HOLIDAY-HRS-MANAGEMENT-009 | Verify B-PH-09 — Get non-existent id | Edge | - | 1. PUT/DELETE invalid id | Appropriate error (not found) | - |

### Data semantics and edges

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-HOLIDAY-HRS-MANAGEMENT-010 | Verify B-PH-10 — Duplicate same date | Main | - | 1. POST two holidays with same `Date`, non-recurring | Both accepted (no server-side duplicate check); document behavior for product | - |
| TC-11 | EXCP-HOLIDAY-HRS-MANAGEMENT-011 | Verify B-PH-11 — Recurring without month/day | Edge | - | 1. POST `IsRecurringAnnually: true`, null month/day | Accepted; recurrence logic in calculator ignores invalid/insufficient recurring config | - |
| TC-12 | EXCP-HOLIDAY-HRS-MANAGEMENT-012 | Verify B-PH-12 — Recurring invalid day | Edge | - | 1. Recurring Feb 30 | Calculator skips invalid `DateOnly` construction; no crash | - |
| TC-13 | EXCP-HOLIDAY-HRS-MANAGEMENT-013 | Verify B-PH-13 — Soft delete vs calculator | Main | - | 1. Delete holiday then compute leave overlapping that date | Deleted row excluded (`!IsDeleted` in calculator query) | - |

### Leave policy coupling

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-HOLIDAY-HRS-MANAGEMENT-014 | Verify B-PH-14 — Exclude holidays on | Main | - | 1. Leave policy `ExcludePublicHolidaysFromCalculation: true`, leave range includes a public holiday | Holiday dates not counted in chargeable days | - |
| TC-15 | EXCP-HOLIDAY-HRS-MANAGEMENT-015 | Verify B-PH-15 — Exclude holidays off | Main | - | 1. Policy flag `false | Public holidays counted like normal workdays for leave duration | - |
| TC-16 | EXCP-HOLIDAY-HRS-MANAGEMENT-016 | Verify B-PH-16 — Recurring applies across years | Main | - | 1. Recurring month/day set, leave range in two calendar years | Both year instances excluded when in range | - |
