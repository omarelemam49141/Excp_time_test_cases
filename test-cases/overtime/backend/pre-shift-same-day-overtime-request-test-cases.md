# Pre-shift same-day overtime request — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/attendance-record/Bulk-apply-attendance-changes`, `POST /api/attendance-over-time/Request-overtime`
- Related code: `src/Excp.HRSystem.Application/Services/Attendance Overtime App/RequestOvertimeWorkflowAppService.cs`, `src/Excp.HRSystem.Domain.Shared/WorkSchedule/OvertimeRequestPreShiftEvaluator.cs`, `src/Excp.HRSystem.Application/Services/AttendanceBulk/AttendanceBulkQuickEntryAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`
- Related docs: `docs/backend/technical/pre-shift-overtime-request-validation.md`

## Scope

- Same calendar day overtime that ends at or before the official shift start time (early morning on a weekday) can be saved through Quick Entry bulk apply, the overtime request dialog, and All Attendance flows.
- Mid-shift or future-in-shift overtime on today still fails validation when the business rules say it should.

## Test pages

- Web: `https://dev.excp.sa:8022/attendance/quick-entry`
- Web: `https://dev.excp.sa:8022/my-requests`
- Web: `https://dev.excp.sa:8022/all-attendance`
- API: `POST https://dev.excp.sa:8043/api/attendance-record/Bulk-apply-attendance-changes`
- API: `POST https://dev.excp.sa:8043/api/attendance-over-time/Request-overtime`

## Test scenarios

- Early morning overtime on **today** (weekday) succeeds from Quick Entry when the rest of the day is valid.
- The same pattern succeeds from **My requests** and from **All attendance** when opening the overtime request flow.
- A future window that sits **inside** the normal working day still shows the same blocking behavior as before.

## Test cases

### Weekday pre-shift and in-shift

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-PRE-SHIFT-SAME-001 | Verify Quick Entry saves early morning overtime for today on a weekday | Main | Today is a weekday for the test user.<br>The user’s official shift start is later than the overtime end (for example shift starts at `"09:00"`).<br>The day row has valid attendance times that do not overlap the overtime window. | 1. Open **Quick Entry** for the employee.<br>2. On **today’s** date row, add a new overtime from `"00:00"` to `"00:25"` (or the same range shown as `"00:00:00"`–`"00:25:00"`).<br>3. Save the grid. | 1. Save completes with a normal success message (no server error).<br>2. The screen does **not** show the Arabic message **"لا يمكن طلب الوقت الإضافي إلا بعد انتهاء ساعات العمل العادية."** for this overtime.<br>3. The day shows the new early morning overtime in a pending state like the other overtime rows. | Today date: `"2026-05-04"`<br>Overtime: `"00:00:00"` to `"00:25:00"` |
| TC-02 | EXCP-OT-HRS-PRE-SHIFT-SAME-002 | Verify My requests overtime dialog accepts pre-shift times for today | Main | Same weekday and shift idea as TC-01.<br>The user is allowed to request overtime. | 1. Open **My requests**.<br>2. Open the overtime request form for **today**.<br>3. Enter start `"00:00"` and end `"00:25"` (or the same with seconds if the form shows them).<br>4. Submit with a valid reason and work place. | 1. The app shows a success confirmation (not an error about waiting until after work).<br>2. The new request appears in the list in a pending state. | Overtime date: today<br>Times: `"00:00"`–`"00:25"` |
| TC-03 | EXCP-OT-HRS-PRE-SHIFT-SAME-003 | Verify All attendance overtime tab accepts pre-shift times for today | Main | Same as TC-01 for weekday and shift.<br>The user can open the day from All attendance. | 1. Open **All attendance**.<br>2. Open **today** for the user and go to the overtime tab.<br>3. Add or request overtime from `"00:00"` to `"00:25"` for **today**.<br>4. Confirm save or submit. | 1. The action finishes without the blocking Arabic message from TC-01.<br>2. The day shows the early morning overtime as pending (or equivalent visible status). | Same times as TC-01 |
| TC-04 | EXCP-OT-HRS-PRE-SHIFT-SAME-004 | Verify bulk API accepts pre-shift overtime request for today | Regression | Same weekday; caller sends a bulk body with an empty `attendanceDays` array or valid days per environment rules; one `overtimeRequests` item for today with early times. | 1. Call **Bulk-apply-attendance-changes** with `overtimeRequests` containing today’s date and `"00:00:00"` / `"00:25:00"` (and valid `userId`, `workPlace`, and any required fields).<br>2. Inspect the HTTP status and body. | 1. Response is not **409** with phase `"overtime_request_apply"` for **OverTimeRequestOnlyAfterWorkHours**.<br>2. If the rest of the payload is valid, the call ends in success like other successful bulk saves. | `overTimeDate`: today in `"yyyy-MM-dd"`<br>`overTimeStartTime`: `"00:00:00"`<br>`overTimeEndTime`: `"00:25:00"` |
| TC-05 | EXCP-OT-HRS-PRE-SHIFT-SAME-005 | Verify mid-shift future overtime on today is still blocked | Edge | Today is a weekday.<br>Current wall clock is **after** official shift start and **before** official shift end (for example afternoon). | 1. From Quick Entry or the request dialog, try to add **today** overtime from a start time **after** the current clock time and **before** official shift end (for example `"15:00"` to `"16:00" if that lies inside working hours for the user).<br>2. Submit or save. | 1. The system still refuses the request with a clear validation outcome (for example the same Arabic message about overtime only after regular work hours, or the message about the start time being after the current time).<br>2. No new overtime row is created for that attempt. | Times inside the user’s normal working day and after **now** |
