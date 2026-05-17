# End-overtime cross-midnight reconciliation — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance OverTimes/EndOverTimeBuilder.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`, `src/Excp.HRSystem.Web/Services/WhatsAppAttendanceNotificationService.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Dtos/AttendanceOverTimeLightDto.cs`
- Related docs: `docs/backend/technical/end-overtime-cross-midnight-reconciliation.md`

## Scope

API:
- `POST api/attendance-overtime/End-overtime`

Focus:
- Split overtimes that end after midnight.
- Merge behavior with existing `WithinOvertimeGap` rows on day 1.
- Day-2 reconciliation and request creation.
- Combined EndOvertime WhatsApp summary for both days.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Existing short OT on day 1 + new OT ends after midnight | Main | Day-1 rows merge to one `Pending` OT with gap break; day-2 OT created and reconciled |
- | Split overtime request creation | Main | Request exists for day 1 pending OT and day 2 pending OT |
- | Match selection after day-1 reconciliation | Edge | End-overtime response references merged day-1 OT, not old short OT |
- | Day-2 reconciliation for short segment | Edge | Day-2 status follows allocator result (`WithinOvertimeGap` or `Pending`) |
- | WhatsApp summary for split case | Main | One EndOvertime message containing Day 1 + Day 2 sections |
- | Non-split end-overtime | Regression | Existing one-day behavior remains unchanged |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-END-CROSS-001 | Verify Merge old short OT with day-1 split segment | Main | - | 1. Given: OT1 exists on `2026-04-29` from `17:30` to `17:45` with `WithinOvertimeGap`.<br>2. And: Active OT2 started at `22:00` on `2026-04-29`.<br>3. When: User calls End-overtime at `01:00` on `2026-04-30`. | Then: Day-1 overtime becomes one merged row from `17:30` to `23:59:59` with break `17:45 -> 22:00`, status `Pending`. | - |
| TC-02 | EXCP-OT-HRS-END-CROSS-002 | Verify Day-2 row is created and reconciled | Main | - | 1. Given: TC-1 setup.<br>2. When: End-overtime executes.<br>3. And: Day-2 status equals allocator output after `ReconcileForEmployeeDayAsync(2026-04-30)`. | Then: Row exists on `2026-04-30` from `00:00:01` to `01:00:00`. | - |
| TC-03 | EXCP-OT-HRS-END-CROSS-003 | Verify Requests are linked for pending rows | Main | - | 1. Given: Split case where both day-1 and day-2 reconciled statuses are `Pending`.<br>2. When: End-overtime executes.<br>3. And: `Request` table contains request linked to day-2 overtime id.<br>4. And: `RequestReceiver` rows are created for both request ids. | Then: `Request` table contains request linked to day-1 overtime id. | - |
| TC-04 | EXCP-OT-HRS-END-CROSS-004 | Verify Response references the correct overtime for day 1 | Main | - | 1. Given: Same setup as TC-1.<br>2. When: End-overtime returns success payload.<br>3. And: It does not point to the old `17:30-17:45 row. | Then: Returned light DTO represents merged day-1 overtime window. | - |
| TC-05 | EXCP-OT-HRS-END-CROSS-005 | Verify WhatsApp combined summary includes both days | Main | - | 1. Given: Split end-overtime case.<br>2. When: End-overtime triggers WhatsApp notification.<br>3. And: Message contains day-1 summary block and day-2 summary block.<br>4. And: Message is not sent for an unrelated historical overtime row. | Then: One EndOvertime message is sent. | - |
| TC-06 | EXCP-OT-HRS-END-CROSS-006 | Verify Non-cross-midnight regression | Main | - | 1. Given: Active overtime starts and ends on the same calendar day.<br>2. When: End-overtime is called.<br>3. And: Existing request and notification behavior remains unchanged. | Then: No day-2 overtime is created. | - |
