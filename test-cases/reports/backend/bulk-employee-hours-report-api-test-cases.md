# Bulk employee hours report API — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Reports/employee-hours-report/bulk`
- Related code: `src/Excp.HRSystem.Application/Services/Reports/EmployeeHoursReports/EmployeeHoursReportService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Reports/EmployeeHoursReports/GenerateEmployeeHoursReportBuilder.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Reports/EmployeeHoursReports/Fluent Validations/BulkEmployeeHoursReportInputValidation.cs`
- Related docs: `docs/backend/technical/bulk-employee-hours-report-api.md`

## Scope

- `POST /api/Reports/employee-hours-report/bulk` input validation and optional shortage fields that map into the shared employee-hours metrics pipeline. The bulk **Angular** page no longer offers **Gap only** (`shortageCompensationMode` value `2`); the API may still accept `2` for legacy callers.

## Test pages

- `POST /api/Reports/employee-hours-report/bulk`

## Test scenarios

- Verify bulk input accepts optional shortage multiplier overrides and optional deduction priority when other required fields are valid.
- Verify invalid `shortageDeductionPriority` values are rejected by validation.
- Verify bulk input still accepts `shortageCompensationMode` value `2` (Gap only) when other required fields are valid (legacy API use).
- Verify changing `shortageDeductionPriority` changes the payable split even with mixed shortage-capacity overrides (weekday 1:1, weekend pay-rate) when business data has both overtime rate buckets and shortage.
- Verify `useRefusedOvertimeForShortage` true reduces effective pay shortage when refused OT and attendance shortage exist (before gap/accepted consumption).

## Test cases

### Input validation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REPORT-HRS-BULK-001 | Verify bulk input accepts optional shortage multiplier and priority fields | Regression | Caller can send JSON to the bulk endpoint. | 1. Build a valid bulk body with dates, `includeAllEmployees` true, and add `"shortageAcceptedOtWeekdayUsesPayMultiplier": false`, `"shortageAcceptedOtWeekendUsesPayMultiplier": true`, and `"shortageDeductionPriority": 2`.<br>2. Send the request. | 1. The server accepts the body (no validation error for those fields).<br>2. Response is success when other data is valid. | - |
| TC-02 | EXCP-REPORT-HRS-BULK-002 | Verify bulk input rejects unknown shortageDeductionPriority values | Edge | Caller can send JSON to the bulk endpoint. | 1. Build a body identical to a valid bulk call but set `"shortageDeductionPriority"` to an integer outside 0, 1, and 2.<br>2. Send the request. | 1. The server returns a client error describing invalid input.<br>2. No successful bulk report data is returned for that call. | Invalid priority: 99 |
| TC-03 | EXCP-REPORT-HRS-BULK-003 | Verify bulk input still accepts legacy Gap only mode value | Regression | Caller can send JSON to the bulk endpoint. | 1. Build a valid bulk body with dates and `includeAllEmployees` true.<br>2. Set `"shortageCompensationMode"` to integer `2` (Gap only).<br>3. Send the request. | 1. The server does not reject the body for that field alone.<br>2. When other data is valid, the response is success or the same outcome class as the same call with mode `0` (no new validation error introduced for value `2`). | - |
| TC-04 | EXCP-REPORT-HRS-BULK-004 | Verify deduction-order override affects payable split in mixed-capacity mode | Regression | Dataset exists where the same bulk call can return shortage plus accepted overtime in both overtime-rate buckets. | 1. Build a valid bulk request with fixed date range and users, set `"shortageAcceptedOtWeekdayUsesPayMultiplier": false`, `"shortageAcceptedOtWeekendUsesPayMultiplier": true`, and `"shortageCompensationMode"` to `0` or `3`.<br>2. Send with `"shortageDeductionPriority": 0` and note one row’s `"payableAcceptedOvertimeWeekdayRate"` and `"payableAcceptedOvertimeWeekendRate"`.<br>3. Repeat the same request with `"shortageDeductionPriority": 1` only.<br>4. Repeat the same request with `"shortageDeductionPriority": 2` only.<br>5. Compare the two payable overtime fields across the three responses. | 1. All three requests succeed when other fields are valid.<br>2. At least one payable overtime field changes when only `shortageDeductionPriority changes.<br>3. Split direction matches requested priority (lower-first vs higher-first). | Use one fixed user set and period that contains shortage and accepted overtime in both overtime-rate buckets |

### Refused overtime for shortage

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-REPORT-HRS-BULK-005 | Verify useRefusedOvertimeForShortage true is accepted and increases payable accepted OT when refused gap and excess accepted exist | Edge | Employee/date range with attendance shortage, refused overtime, within-gap overtime, and accepted overtime large enough to cover remaining shortage. | 1. Build a valid bulk body with `"shortageCompensationMode": 0`, `"useRefusedOvertimeForShortage": false`, and fixed users/dates.<br>2. Send and note `"payableAcceptedOvertimeWeekdayRate"`, `"payableAcceptedOvertimeWeekendRate"`, and `"shortageHours"` for one row.<br>3. Repeat with `"useRefusedOvertimeForShortage": true` only.<br>4. Compare the same fields. | 1. Both requests succeed (no validation error for the new field).<br>2. `"shortageHours"` is unchanged between runs.<br>3. Sum of payable accepted OT fields is higher in step 3 by approximately the refused OT seconds consumed for shortage.<br>4. `"rejectedOvertimeHours"` on the row still reflects gross refused time. | User with refused OT + gap OT + shortage + excess accepted OT |
