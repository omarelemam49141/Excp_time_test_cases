# Quick Entry — range correction & rollback (frontend)

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/features/attendance/components/attendance-quick-entry`, `src/app/core/services/attendance.service.ts`
- Related docs: `docs/frontend/technical/quick-entry-correction-diff-cumulative-totals.md`

## Scope

`/attendance/quick-entry`: apply schedule correction, history modal, rollback, admin target user id field.


## Test pages

- `/attendance/quick-entry`


## Test scenarios

- (Add high-level scenarios here.)


## Test cases

### M5 — Diff totals parity with quick-entry summary

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-RANGE-CORRECTION-001 | Verify Diff totals parity with quick-entry summary — TC-01 — Verify Diff totals parity with quick-entry summary — `إجمالي صافي العمل` | Main | - | 1. `إجمالي صافي العمل` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-QE-RANGE-CORRECTION-002 | Verify Diff totals parity with quick-entry summary — TC-02 — Verify Diff totals parity with quick-entry summary — `إجمالي صافي الإضافي` | Main | - | 1. `إجمالي صافي الإضافي` | The result matches the scenario description when you follow the actions in the product. | - |

### M7 — Overtime status sync (attendance + request)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-QE-RANGE-CORRECTION-003 | Verify Overtime status sync (attendance + request) — TC-03 — Verify Overtime status sync (attendance + request) — `Attendance overtime status` | Main | - | 1. `Attendance overtime status` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-QE-RANGE-CORRECTION-004 | Verify Overtime status sync (attendance + request) — TC-04 — Verify Overtime status sync (attendance + request) — `Request status` | Main | - | 1. `Request status` | The result matches the scenario description when you follow the actions in the product. | - |

### M8 — Save button parity with correction logic (late arrival + long day)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-QE-RANGE-CORRECTION-005 | Verify Save button parity with correction logic (late arrival + long day) — TC-05 — Verify Save button parity with correction logic (late arrival + long day) — Shift start: `09:00` | Main | - | 1. Shift start: `09:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-06 | EXCP-QE-RANGE-CORRECTION-006 | Verify Save button parity with correction logic (late arrival + long day) — TC-06 — Verify Save button parity with correction logic (late arrival + long day) — Shift end: `17:00` | Main | - | 1. Shift end: `17:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-07 | EXCP-QE-RANGE-CORRECTION-007 | Verify Save button parity with correction logic (late arrival + long day) — TC-07 — Verify Save button parity with correction logic (late arrival + long day) — Overtime gap: `30` minutes | Main | - | 1. Overtime gap: `30` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-08 | EXCP-QE-RANGE-CORRECTION-008 | Verify Save button parity with correction logic (late arrival + long day) — TC-08 — Verify Save button parity with correction logic (late arrival + long day) — Late tolerance after shift start: `30` minutes | Main | - | 1. Late tolerance after shift start: `30` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-09 | EXCP-QE-RANGE-CORRECTION-009 | Verify Save button parity with correction logic (late arrival + long day) — TC-09 — Verify Save button parity with correction logic (late arrival + long day) — Early tolerance before shift start: `60` minutes (pre-shift rule only) | Main | - | 1. Early tolerance before shift start: `60` minutes (pre-shift rule only) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-10 | EXCP-QE-RANGE-CORRECTION-010 | Verify Save button parity with correction logic (late arrival + long day) — TC-10 — Verify Save button parity with correction logic (late arrival + long day) — Late tolerance after shift start: `30` minutes (this is the cap for late extension) | Main | - | 1. Late tolerance after shift start: `30` minutes (this is the cap for late extension) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-11 | EXCP-QE-RANGE-CORRECTION-011 | Verify Save button parity with correction logic (late arrival + long day) — TC-11 — Verify Save button parity with correction logic (late arrival + long day) — Attendance segment becomes `09:07 -> 17:07` (17:00 + **actual 7 min late**, capped by late tolerance). | Main | - | 1. Attendance segment becomes `09:07 -> 17:07` (17:00 + **actual 7 min late**, capped by late tolerance). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-12 | EXCP-QE-RANGE-CORRECTION-012 | Verify Save button parity with correction logic (late arrival + long day) — TC-12 — Verify Save button parity with correction logic (late arrival + long day) — Overtime segment becomes `17:07 -> 20:10`. | Main | - | 1. Overtime segment becomes `17:07 -> 20:10`. | The result matches the scenario description when you follow the actions in the product. | - |

### M9 — Late arrival edge case: extension capped at late tolerance

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-QE-RANGE-CORRECTION-013 | Verify Late arrival edge case: extension capped at late tolerance — TC-13 — Verify Late arrival edge case: extension capped at late tolerance — Shift: `09:00-17:00` | Main | - | 1. Shift: `09:00-17:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-14 | EXCP-QE-RANGE-CORRECTION-014 | Verify Late arrival edge case: extension capped at late tolerance — TC-14 — Verify Late arrival edge case: extension capped at late tolerance — Early tolerance: `60` minutes | Main | - | 1. Early tolerance: `60` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-15 | EXCP-QE-RANGE-CORRECTION-015 | Verify Late arrival edge case: extension capped at late tolerance — TC-15 — Verify Late arrival edge case: extension capped at late tolerance — Late tolerance: `30` minutes | Main | - | 1. Late tolerance: `30` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-16 | EXCP-QE-RANGE-CORRECTION-016 | Verify Late arrival edge case: extension capped at late tolerance — TC-16 — Verify Late arrival edge case: extension capped at late tolerance — Attendance: `10:30 -> 17:30` (17:00 + 30 min cap, not 17:00 + 90 min) | Main | - | 1. Attendance: `10:30 -> 17:30` (17:00 + 30 min cap, not 17:00 + 90 min) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-17 | EXCP-QE-RANGE-CORRECTION-017 | Verify Late arrival edge case: extension capped at late tolerance — TC-17 — Verify Late arrival edge case: extension capped at late tolerance — Late extension is capped at `LateToleranceMinutes` when actual lateness exceeds it. | Main | - | 1. Late extension is capped at `LateToleranceMinutes` when actual lateness exceeds it. | The result matches the scenario description when you follow the actions in the product. | - |

### E1 — No changes

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-18 | EXCP-QE-RANGE-CORRECTION-018 | Verify No changes — TC-18 — Verify No changes — Range with no correctable days → error message from API (no silent success). | Edge | - | 1. Range with no correctable days → error message from API (no silent success). | The result matches the scenario description when you follow the actions in the product. | - |

### E2 — Admin empty target

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-QE-RANGE-CORRECTION-019 | Verify Admin empty target — TC-19 — Verify Admin empty target — Clear admin user id → operations apply to admin’s own account. | Edge | - | 1. Clear admin user id → operations apply to admin’s own account. | The result matches the scenario description when you follow the actions in the product. | - |

### E3 — History empty

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-QE-RANGE-CORRECTION-020 | Verify History empty — TC-20 — Verify History empty — Period with no runs → empty state string shown. | Edge | - | 1. Period with no runs → empty state string shown. | The result matches the scenario description when you follow the actions in the product. | - |

### E4 — Backward compatibility fallback

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-21 | EXCP-QE-RANGE-CORRECTION-021 | Verify Backward compatibility fallback — TC-21 — Verify Backward compatibility fallback — Connect frontend to backend build that does not include new cumulative fields in correction diff response. | Main | - | 1. Connect frontend to backend build that does not include new cumulative fields in correction diff response. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-22 | EXCP-QE-RANGE-CORRECTION-022 | Verify Backward compatibility fallback — TC-22 — Verify Backward compatibility fallback — **Expect** modal totals still render from existing per-day minute fallback (no blank/NaN/error). | Edge | - | 1. *Expect** modal totals still render from existing per-day minute fallback (no blank/NaN/error). | The result matches the scenario description when you follow the actions in the product. | - |

### E5 — Save surfaces post-save correction failure (409 bulk envelope)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-QE-RANGE-CORRECTION-023 | Verify Save surfaces post-save correction failure (409 bulk envelope) — TC-23 — Verify Save surfaces post-save correction failure (409 bulk envelope) — When bulk save triggers correction and correction fails after writes: | Edge | - | 1. When bulk save triggers correction and correction fails after writes: | The result matches the scenario description when you follow the actions in the product. | - |
| TC-24 | EXCP-QE-RANGE-CORRECTION-024 | Verify Save surfaces post-save correction failure (409 bulk envelope) — TC-24 — Verify Save surfaces post-save correction failure (409 bulk envelope) — **Expect** HTTP **409** response with bulk `errors[]` containing phase **`post_save_correction`** (same handling path as other bulk validation rows). | Edge | - | 1. *Expect** HTTP **409** response with bulk `errors[]` containing phase **`post_save_correction`** (same handling path as other bulk validation rows). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-25 | EXCP-QE-RANGE-CORRECTION-025 | Verify Save surfaces post-save correction failure (409 bulk envelope) — TC-25 — Verify Save surfaces post-save correction failure (409 bulk envelope) — **Expect** UI shows save failure/first-day navigation similar to other bulk errors (not silent success). | Edge | - | 1. *Expect** UI shows save failure/first-day navigation similar to other bulk errors (not silent success). | The result matches the scenario description when you follow the actions in the product. | - |

### Regression

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-26 | EXCP-QE-RANGE-CORRECTION-026 | Verify Month mode and range mode still load within 31-day rule. | Main | - | 1. Month mode and range mode still load within 31-day rule. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-27 | EXCP-QE-RANGE-CORRECTION-027 | Verify Existing save/import/export flows unchanged aside from optional `targetUserId` / `sourceUserId`. | Main | - | 1. Existing save/import/export flows unchanged aside from optional `targetUserId` / `sourceUserId`. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-28 | EXCP-QE-RANGE-CORRECTION-028 | Verify Save with only overtime-request edits (no attendance-day edits) does not create an additional correction run. | Main | - | 1. Save with only overtime-request edits (no attendance-day edits) does not create an additional correction run. | The result matches the scenario description when you follow the actions in the product. | - |

### S1 — No breaks entered (no deduction)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-29 | EXCP-QE-RANGE-CORRECTION-029 | Verify No breaks entered (no deduction) — TC-29 — Verify No breaks entered (no deduction) — Setup: shift `09:00-17:00`, `overtimeGap = 30m`. | Main | - | 1. Setup: shift `09:00-17:00`, `overtimeGap = 30m`. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-30 | EXCP-QE-RANGE-CORRECTION-030 | Verify No breaks entered (no deduction) — TC-30 — Verify No breaks entered (no deduction) — Enter attendance day `09:00 -> 17:00` with no break rows. | Main | - | 1. Enter attendance day `09:00 -> 17:00` with no break rows. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-31 | EXCP-QE-RANGE-CORRECTION-031 | Verify No breaks entered (no deduction) — TC-31 — Verify No breaks entered (no deduction) — **Expect** Quick Entry day net work = `08:00:00` (no breaks, no deduction), and cumulative net reflects same. | Main | - | 1. *Expect** Quick Entry day net work = `08:00:00` (no breaks, no deduction), and cumulative net reflects same. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-32 | EXCP-QE-RANGE-CORRECTION-032 | Verify No breaks entered (no deduction) — TC-32 — Verify No breaks entered (no deduction) — **Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | Main | - | 1. *Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | The result matches the scenario description when you follow the actions in the product. | - |

### S2 — Break entered below overtime gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-33 | EXCP-QE-RANGE-CORRECTION-033 | Verify Break entered below overtime gap — TC-33 — Verify Break entered below overtime gap — Setup unchanged. | Main | - | 1. Setup unchanged. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-34 | EXCP-QE-RANGE-CORRECTION-034 | Verify Break entered below overtime gap — TC-34 — Verify Break entered below overtime gap — Enter one break `10:30 -> 10:40` (10m). | Main | - | 1. Enter one break `10:30 -> 10:40` (10m). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-35 | EXCP-QE-RANGE-CORRECTION-035 | Verify Break entered below overtime gap — TC-35 — Verify Break entered below overtime gap — **Expect** net work remains `08:00:00` (10m < 30m gap, breaks covered by allowance). | Main | - | 1. *Expect** net work remains `08:00:00` (10m < 30m gap, breaks covered by allowance). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-36 | EXCP-QE-RANGE-CORRECTION-036 | Verify Break entered below overtime gap — TC-36 — Verify Break entered below overtime gap — **Expect tooltip note**: `Allowance added = 00:10:00`, `Remaining allowance = 00:20:00`. | Main | - | 1. *Expect tooltip note**: `Allowance added = 00:10:00`, `Remaining allowance = 00:20:00`. | The result matches the scenario description when you follow the actions in the product. | - |

### S3 — Break equals overtime gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-37 | EXCP-QE-RANGE-CORRECTION-037 | Verify Break equals overtime gap — TC-37 — Verify Break equals overtime gap — Enter one break `10:30 -> 11:00` (30m). | Main | - | 1. Enter one break `10:30 -> 11:00` (30m). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-38 | EXCP-QE-RANGE-CORRECTION-038 | Verify Break equals overtime gap — TC-38 — Verify Break equals overtime gap — **Expect** net work = `08:00:00` (30m == 30m gap, no deduction). | Main | - | 1. *Expect** net work = `08:00:00` (30m == 30m gap, no deduction). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-39 | EXCP-QE-RANGE-CORRECTION-039 | Verify Break equals overtime gap — TC-39 — Verify Break equals overtime gap — **Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | Main | - | 1. *Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | The result matches the scenario description when you follow the actions in the product. | - |

### S4 — Break above overtime gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-40 | EXCP-QE-RANGE-CORRECTION-040 | Verify Break above overtime gap — TC-40 — Verify Break above overtime gap — Enter one break `10:30 -> 11:15` (45m). | Main | - | 1. Enter one break `10:30 -> 11:15` (45m). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-41 | EXCP-QE-RANGE-CORRECTION-041 | Verify Break above overtime gap — TC-41 — Verify Break above overtime gap — **Expect** net work = `07:45:00` (45m - 30m = 15m deducted). | Main | - | 1. *Expect** net work = `07:45:00` (45m - 30m = 15m deducted). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-42 | EXCP-QE-RANGE-CORRECTION-042 | Verify Break above overtime gap — TC-42 — Verify Break above overtime gap — **Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | Main | - | 1. *Expect tooltip note**: `Allowance added = 00:30:00`, `Remaining allowance = 00:00:00`. | The result matches the scenario description when you follow the actions in the product. | - |

### S5 — Employee hours report parity

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-43 | EXCP-QE-RANGE-CORRECTION-043 | Verify Employee hours report parity — TC-43 — Verify Employee hours report parity — Use same day/range as Quick Entry scenarios. | Main | - | 1. Use same day/range as Quick Entry scenarios. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-44 | EXCP-QE-RANGE-CORRECTION-044 | Verify Employee hours report parity — TC-44 — Verify Employee hours report parity — Open `/my-reports/employee-hours` for that employee and range. | Main | - | 1. Open `/my-reports/employee-hours` for that employee and range. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-45 | EXCP-QE-RANGE-CORRECTION-045 | Verify Employee hours report parity — TC-45 — Verify Employee hours report parity — **Expect** `Total actual work hours without breaks` follows the same allowance rule and matches Quick Entry net aggregation for attendance hours. | Main | - | 1. *Expect** `Total actual work hours without breaks` follows the same allowance rule and matches Quick Entry net aggregation for attendance hours. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-46 | EXCP-QE-RANGE-CORRECTION-046 | Verify Employee hours report parity — TC-46 — Verify Employee hours report parity — **Expect tooltip note** on `Total actual work hours without breaks` showing cumulative added/remaining allowance for the selected range. | Main | - | 1. *Expect tooltip note** on `Total actual work hours without breaks` showing cumulative added/remaining allowance for the selected range. | The result matches the scenario description when you follow the actions in the product. | - |

### L2 — Employee Hours Report parity with leave

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-47 | EXCP-QE-RANGE-CORRECTION-047 | Verify Employee Hours Report parity with leave — TC-47 — Verify Employee Hours Report parity with leave — 2 regular working days with attendance | Main | - | 1. 2 regular working days with attendance | The result matches the scenario description when you follow the actions in the product. | - |
| TC-48 | EXCP-QE-RANGE-CORRECTION-048 | Verify Employee Hours Report parity with leave — TC-48 — Verify Employee Hours Report parity with leave — 1 approved leave day (no attendance) | Main | - | 1. 1 approved leave day (no attendance) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-49 | EXCP-QE-RANGE-CORRECTION-049 | Verify Employee Hours Report parity with leave — TC-49 — Verify Employee Hours Report parity with leave — 1 weekend day | Main | - | 1. 1 weekend day | The result matches the scenario description when you follow the actions in the product. | - |

### Test cases (edge)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-50 | EXCP-QE-RANGE-CORRECTION-050 | Verify Changing `overtimeGapMinutes` in admin settings changes subsequent computed net totals without rewriting stored break rows. | Main | - | 1. Changing `overtimeGapMinutes` in admin settings changes subsequent computed net totals without rewriting stored break rows. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-51 | EXCP-QE-RANGE-CORRECTION-051 | Verify Break rows stay exactly as entered after save/reload (calculation-only behavior). | Main | - | 1. Break rows stay exactly as entered after save/reload (calculation-only behavior). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-52 | EXCP-QE-RANGE-CORRECTION-052 | Verify Days with no attendance row still show no regular net-work credit (rule applies only when attendance duration exists, except for approved leave days). | Main | - | 1. Days with no attendance row still show no regular net-work credit (rule applies only when attendance duration exists, except for approved leave days). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-53 | EXCP-QE-RANGE-CORRECTION-053 | Verify Non-working days (weekend/holiday/approved leave) remain consistently credited across summary and diff totals under the same backend rules. | Main | - | 1. Non-working days (weekend/holiday/approved leave) remain consistently credited across summary and diff totals under the same backend rules. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-54 | EXCP-QE-RANGE-CORRECTION-054 | Verify Approved leave day with actual attendance > shift duration → actual value is used, not capped at shift. | Main | - | 1. Approved leave day with actual attendance > shift duration → actual value is used, not capped at shift. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-55 | EXCP-QE-RANGE-CORRECTION-055 | Verify Legacy payload compatibility: if only `status` is returned (without `attendanceOvertimeStatus`), UI still shows attendance status using the legacy field. | Main | - | 1. Legacy payload compatibility: if only `status` is returned (without `attendanceOvertimeStatus), UI still shows attendance status using the legacy field. | The result matches the scenario description when you follow the actions in the product. | - |
