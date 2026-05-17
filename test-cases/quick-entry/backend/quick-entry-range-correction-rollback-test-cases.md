# Quick Entry range correction & rollback — backend test cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Services/AttendanceBulk/AttendanceBulkQuickEntryAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceRecords/AttendanceRecordAPIController.cs`, `src/Excp.HRSystem.EntityFrameworkCore/Scripts/FixAttendanceOver8Hours_CreateOvertime_ByDateRange.sql`, `src/Excp.HRSystem.EntityFrameworkCore/AttendanceQuickEntry/QuickEntryCorrectionRepository.cs`, `src/Excp.HRSystem.Domain/Entities/AttendanceQuickEntry`, `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Record App Contracts/Dtos/APIs/CorrectionDiffResultDto.cs`, `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursPaidDayCreditCalculator.cs`
- Related docs: `docs/backend/technical/quick-entry-correction-diff-cumulative-totals.md`, `docs/backend/technical/quick-entry-copy-import-api.md`

## Scope

APIs under `api/attendance-record`:
- `Apply-quick-entry-range-correction`
- `Get-quick-entry-range-correction-history`
- `Rollback-quick-entry-range-correction`

Related: `Get-bulk-details-in-range`, `Export-quick-entry-transfer`, `Import-quick-entry-transfer`, `Bulk-apply-attendance-changes` (admin optional target user).


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- (Add high-level scenarios here.)


## Test cases

### M8 — Save endpoint parity (bulk apply triggers correction for attendance dates)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-HRS-RANGE-CORRECTION-001 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-01 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — shift `09:00-17:00` | Main | - | 1. shift `09:00-17:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-QE-HRS-RANGE-CORRECTION-002 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-02 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — early tolerance `60` | Main | - | 1. early tolerance `60` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-QE-HRS-RANGE-CORRECTION-003 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-03 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — late tolerance after shift start `30` | Main | - | 1. late tolerance after shift start `30` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-QE-HRS-RANGE-CORRECTION-004 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-04 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — overtime gap `30` | Main | - | 1. overtime gap `30` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-05 | EXCP-QE-HRS-RANGE-CORRECTION-005 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-05 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — `startTime=09:06`, `endTime=21:00` | Main | - | 1. `startTime=09:06`, `endTime=21:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-06 | EXCP-QE-HRS-RANGE-CORRECTION-006 | Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — TC-06 — Verify Save endpoint parity (bulk apply triggers correction for attendance dates) — no explicit overtime request for this split. | Main | - | 1. no explicit overtime request for this split. | The result matches the scenario description when you follow the actions in the product. | - |

### M9 — Late arrival shift extension uses actual late minutes (capped by late tolerance)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-QE-HRS-RANGE-CORRECTION-007 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-07 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — shift `09:00-17:00` | Main | - | 1. shift `09:00-17:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-08 | EXCP-QE-HRS-RANGE-CORRECTION-008 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-08 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — early tolerance `60` minutes | Main | - | 1. early tolerance `60` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-09 | EXCP-QE-HRS-RANGE-CORRECTION-009 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-09 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — late tolerance `30` minutes | Main | - | 1. late tolerance `30` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-10 | EXCP-QE-HRS-RANGE-CORRECTION-010 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-10 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — `startTime=09:07`, `endTime=20:10` | Main | - | 1. `startTime=09:07`, `endTime=20:10` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-11 | EXCP-QE-HRS-RANGE-CORRECTION-011 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-11 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — Attendance: `09:07 -> 17:07` (17:00 + 7 min late, NOT 17:00 + 60 min) | Main | - | 1. Attendance: `09:07 -> 17:07` (17:00 + 7 min late, NOT 17:00 + 60 min) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-12 | EXCP-QE-HRS-RANGE-CORRECTION-012 | Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — TC-12 — Verify Late arrival shift extension uses actual late minutes (capped by late tolerance) — Overtime: `17:07 -> 20:10` | Main | - | 1. Overtime: `17:07 -> 20:10` | The result matches the scenario description when you follow the actions in the product. | - |

### M10 — Late tolerance cap scenario (10:00 -> 20:10)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-QE-HRS-RANGE-CORRECTION-013 | Verify Late tolerance cap scenario (10:00 -> 20:10) — TC-13 — Verify Late tolerance cap scenario (10:00 -> 20:10) — shift `09:00-17:00` | Main | - | 1. shift `09:00-17:00` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-14 | EXCP-QE-HRS-RANGE-CORRECTION-014 | Verify Late tolerance cap scenario (10:00 -> 20:10) — TC-14 — Verify Late tolerance cap scenario (10:00 -> 20:10) — late tolerance `30` minutes | Main | - | 1. late tolerance `30` minutes | The result matches the scenario description when you follow the actions in the product. | - |
| TC-15 | EXCP-QE-HRS-RANGE-CORRECTION-015 | Verify Late tolerance cap scenario (10:00 -> 20:10) — TC-15 — Verify Late tolerance cap scenario (10:00 -> 20:10) — `startTime=10:00`, `endTime=20:10` | Main | - | 1. `startTime=10:00`, `endTime=20:10` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-16 | EXCP-QE-HRS-RANGE-CORRECTION-016 | Verify Late tolerance cap scenario (10:00 -> 20:10) — TC-16 — Verify Late tolerance cap scenario (10:00 -> 20:10) — Attendance: `10:00 -> 17:30` (17:00 + 30 min cap) | Main | - | 1. Attendance: `10:00 -> 17:30` (17:00 + 30 min cap) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-17 | EXCP-QE-HRS-RANGE-CORRECTION-017 | Verify Late tolerance cap scenario (10:00 -> 20:10) — TC-17 — Verify Late tolerance cap scenario (10:00 -> 20:10) — Overtime: `17:30 -> 20:10` | Main | - | 1. Overtime: `17:30 -> 20:10` | The result matches the scenario description when you follow the actions in the product. | - |

### E1 — No-op range

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-18 | EXCP-QE-HRS-RANGE-CORRECTION-018 | Verify No-op range — TC-18 — Verify No-op range — Range where no working day needs correction. | Main | - | 1. Range where no working day needs correction. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-19 | EXCP-QE-HRS-RANGE-CORRECTION-019 | Verify No-op range — TC-19 — Verify No-op range — **Expect** UserFriendly “No days…” (no DB run). | Main | - | 1. *Expect** UserFriendly “No days…” (no DB run). | The result matches the scenario description when you follow the actions in the product. | - |

### E2 — Invalid period

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-QE-HRS-RANGE-CORRECTION-020 | Verify Invalid period — TC-20 — Verify Invalid period — `to` &lt; `from` → error. | Edge | - | 1. `to` &lt; `from` → error. | The result matches the scenario description when you follow the actions in the product. | - |

### E3 — Range &gt; 31 days

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-21 | EXCP-QE-HRS-RANGE-CORRECTION-021 | Verify Range &gt; 31 days — TC-21 — Verify Range &gt; 31 days — Same validation as bulk details → error. | Edge | - | 1. Same validation as bulk details → error. | The result matches the scenario description when you follow the actions in the product. | - |

### E4 — Rollback wrong tenant/user

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-QE-HRS-RANGE-CORRECTION-022 | Verify Rollback wrong tenant/user — TC-22 — Verify Rollback wrong tenant/user — Non-admin rollback run for another employee’s target → forbidden / UserFriendly. | Edge | - | 1. Non-admin rollback run for another employee’s target → forbidden / UserFriendly. | The result matches the scenario description when you follow the actions in the product. | - |

### E5 — Corrupt snapshot

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-QE-HRS-RANGE-CORRECTION-023 | Verify Corrupt snapshot — TC-23 — Verify Corrupt snapshot — Manually corrupt `SnapshotJson` in DB → rollback **Expect** “invalid or unsupported”. | Edge | - | 1. Manually corrupt `SnapshotJson` in DB → rollback **Expect** “invalid or unsupported”. | The result matches the scenario description when you follow the actions in the product. | - |

### Regression

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-24 | EXCP-QE-HRS-RANGE-CORRECTION-024 | Verify Existing export/import still works for self; admin can pass `sourceUserId` / `targetUserId` where documented. | Main | - | 1. Existing export/import still works for self; admin can pass `sourceUserId` / `targetUserId` where documented. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-25 | EXCP-QE-HRS-RANGE-CORRECTION-025 | Verify Bulk apply with only overtime updates/requests (no `attendanceDays`) must not create an extra correction run. | Main | - | 1. Bulk apply with only overtime updates/requests (no `attendanceDays`) must not create an extra correction run. | The result matches the scenario description when you follow the actions in the product. | - |

### B2 — Break below/equal gap

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-26 | EXCP-QE-HRS-RANGE-CORRECTION-026 | Verify Break below/equal gap — TC-26 — Verify Break below/equal gap — 10-minute break -> `Used=600`, `Remaining=1200` | Main | - | 1. 10-minute break -> `Used=600`, `Remaining=1200` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-27 | EXCP-QE-HRS-RANGE-CORRECTION-027 | Verify Break below/equal gap — TC-27 — Verify Break below/equal gap — 30-minute break -> `Used=1800`, `Remaining=0` | Main | - | 1. 30-minute break -> `Used=1800`, `Remaining=0` | The result matches the scenario description when you follow the actions in the product. | - |

### B4 — Employee hours report parity

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-28 | EXCP-QE-HRS-RANGE-CORRECTION-028 | Verify Employee hours report parity — TC-28 — Verify Employee hours report parity — `TotalOvertimeGapAllowanceUsedSeconds` | Main | - | 1. `TotalOvertimeGapAllowanceUsedSeconds` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-29 | EXCP-QE-HRS-RANGE-CORRECTION-029 | Verify Employee hours report parity — TC-29 — Verify Employee hours report parity — `TotalOvertimeGapAllowanceRemainingSeconds` | Main | - | 1. `TotalOvertimeGapAllowanceRemainingSeconds` | The result matches the scenario description when you follow the actions in the product. | - |

### B5 — Correction diff cumulative totals parity (after)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-30 | EXCP-QE-HRS-RANGE-CORRECTION-030 | Verify Correction diff cumulative totals parity (after) — TC-30 — Verify Correction diff cumulative totals parity (after) — `CumulativeNetWorkTimeAfterBreaks` | Main | - | 1. `CumulativeNetWorkTimeAfterBreaks` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-31 | EXCP-QE-HRS-RANGE-CORRECTION-031 | Verify Correction diff cumulative totals parity (after) — TC-31 — Verify Correction diff cumulative totals parity (after) — `CumulativeNetOvertimeTimeAfterBreaks` | Main | - | 1. `CumulativeNetOvertimeTimeAfterBreaks` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-32 | EXCP-QE-HRS-RANGE-CORRECTION-032 | Verify Correction diff cumulative totals parity (after) — TC-32 — Verify Correction diff cumulative totals parity (after) — `AfterCumulativeNetWorkTimeAfterBreaks == CumulativeNetWorkTimeAfterBreaks` | Main | - | 1. `AfterCumulativeNetWorkTimeAfterBreaks == CumulativeNetWorkTimeAfterBreaks` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-33 | EXCP-QE-HRS-RANGE-CORRECTION-033 | Verify Correction diff cumulative totals parity (after) — TC-33 — Verify Correction diff cumulative totals parity (after) — `AfterCumulativeNetOvertimeTimeAfterBreaks == CumulativeNetOvertimeTimeAfterBreaks` | Main | - | 1. `AfterCumulativeNetOvertimeTimeAfterBreaks == CumulativeNetOvertimeTimeAfterBreaks` | The result matches the scenario description when you follow the actions in the product. | - |

### B6 — Correction diff cumulative totals parity (before baseline)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-34 | EXCP-QE-HRS-RANGE-CORRECTION-034 | Verify Correction diff cumulative totals parity (before baseline) — TC-34 — Verify Correction diff cumulative totals parity (before baseline) — `BeforeCumulativeNetWorkTimeAfterBreaks` equals bulk cumulative net-work on baseline state. | Main | - | 1. `BeforeCumulativeNetWorkTimeAfterBreaks` equals bulk cumulative net-work on baseline state. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-35 | EXCP-QE-HRS-RANGE-CORRECTION-035 | Verify Correction diff cumulative totals parity (before baseline) — TC-35 — Verify Correction diff cumulative totals parity (before baseline) — `BeforeCumulativeNetOvertimeTimeAfterBreaks` equals bulk cumulative net-overtime on baseline state. | Main | - | 1. `BeforeCumulativeNetOvertimeTimeAfterBreaks` equals bulk cumulative net-overtime on baseline state. | The result matches the scenario description when you follow the actions in the product. | - |

### L4 — Employee Hours Report parity with approved leave

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-36 | EXCP-QE-HRS-RANGE-CORRECTION-036 | Verify Employee Hours Report parity with approved leave — TC-36 — Verify Employee Hours Report parity with approved leave — 2 regular working days (actual attendance) | Main | - | 1. 2 regular working days (actual attendance) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-37 | EXCP-QE-HRS-RANGE-CORRECTION-037 | Verify Employee Hours Report parity with approved leave — TC-37 — Verify Employee Hours Report parity with approved leave — 1 approved leave day (no attendance) | Main | - | 1. 1 approved leave day (no attendance) | The result matches the scenario description when you follow the actions in the product. | - |
| TC-38 | EXCP-QE-HRS-RANGE-CORRECTION-038 | Verify Employee Hours Report parity with approved leave — TC-38 — Verify Employee Hours Report parity with approved leave — 1 weekend day | Main | - | 1. 1 weekend day | The result matches the scenario description when you follow the actions in the product. | - |

### Test cases (edge)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-39 | EXCP-QE-HRS-RANGE-CORRECTION-039 | Verify Changing `OvertimeGapMinutes` affects subsequent calculations without updating break rows in DB. | Main | - | 1. Changing `OvertimeGapMinutes` affects subsequent calculations without updating break rows in DB. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-40 | EXCP-QE-HRS-RANGE-CORRECTION-040 | Verify Net attendance never goes negative even if break duration exceeds gross attendance duration. | Main | - | 1. Net attendance never goes negative even if break duration exceeds gross attendance duration. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-41 | EXCP-QE-HRS-RANGE-CORRECTION-041 | Verify **Schedule** non-working (weekend or recurring MM-dd), approved leave, and `PublicHoliday` dates (including recurring annual public holidays): at least required shift in both quick-entry cumulative... | Main | - | 1. *Schedule** non-working (weekend or recurring MM-dd), approved leave, and `PublicHoliday` dates (including recurring annual public holidays): at least required shift in both quick-entry cumulative and report totals. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-42 | EXCP-QE-HRS-RANGE-CORRECTION-042 | Verify `Get-quick-entry-correction-diff` still returns day-level minute fields for UI details, but cumulative cards must consume API cumulative fields first. | Main | - | 1. `Get-quick-entry-correction-diff` still returns day-level minute fields for UI details, but cumulative cards must consume API cumulative fields first. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-43 | EXCP-QE-HRS-RANGE-CORRECTION-043 | Verify Approved leave day actual attendance > shift → actual value used (no cap at shift duration). | Main | - | 1. Approved leave day actual attendance > shift → actual value used (no cap at shift duration). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-44 | EXCP-QE-HRS-RANGE-CORRECTION-044 | Verify Overtime segment with no linked request still returns attendance overtime status, while `requestStatus` remains null/empty. | Edge | - | 1. Overtime segment with no linked request still returns attendance overtime status, while `requestStatus remains null/empty. | The result matches the scenario description when you follow the actions in the product. | - |
