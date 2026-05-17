# Attendance & Overtime Update/Delete WhatsApp - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceRecords/AttendanceRecordAPIController.cs`, `src/Excp.HRSystem.HttpApi/Controllers/OverTimeBreaks/OverTimeBreakController.cs`, `src/Excp.HRSystem.Web/Services/WhatsAppAttendanceNotificationService.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/SystemWorkSchedule/Dtos/SystemWorkScheduleDto.cs`
- Related docs: `docs/backend/technical/whatsapp-attendance-notification-language.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Attendance update + toggle ON | Main | Update endpoint sends WhatsApp update message |
- | Attendance update + toggle OFF | Main | Update endpoint does not send WhatsApp |
- | Overtime update + toggle ON | Main | Overtime update endpoint sends WhatsApp update message |
- | Overtime update + toggle OFF | Main | Overtime update endpoint does not send WhatsApp |
- | Attendance delete + toggle ON | Main | Attendance delete endpoint sends WhatsApp delete message |
- | Overtime delete + toggle ON | Main | Overtime delete endpoint sends WhatsApp delete message |
- | Start/end/break existing flow | Regression | Existing start/end notifications remain unchanged |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-ANG-ATTENDANCE-001 | Verify Attendance update notification enabled | Main | - | 1. Set `WhatsAppNotifyAttendanceUpdate=true` in system work schedule defaults.<br>2. Call `POST /api/attendance-record/Update-attendance-record-with-breaks`.<br>3. Verify response succeeds and one update notification is sent. | - | - |
| TC-02 | EXCP-OT-ANG-ATTENDANCE-002 | Verify Attendance update notification disabled | Main | - | 1. Set `WhatsAppNotifyAttendanceUpdate=false`.<br>2. Repeat update call.<br>3. Verify response succeeds and no WhatsApp update notification is sent. | - | - |
| TC-03 | EXCP-OT-ANG-ATTENDANCE-003 | Verify Overtime update notification enabled/disabled | Main | - | 1. Toggle `WhatsAppNotifyOvertimeUpdate` ON then OFF.<br>2. Call `PUT /api/attendance-overtime/Update-overtime-with-breaks`.<br>3. Verify WhatsApp send behavior matches toggle state in each run. | - | - |
| TC-04 | EXCP-OT-ANG-ATTENDANCE-004 | Verify Attendance delete notification enabled | Main | - | 1. Set `WhatsAppNotifyAttendanceDelete=true`.<br>2. Call `DELETE /api/attendance-record/Delete-by-date`.<br>3. Verify delete notification message is sent once. | - | - |
| TC-05 | EXCP-OT-ANG-ATTENDANCE-005 | Verify Overtime delete notification enabled | Main | - | 1. Set `WhatsAppNotifyOvertimeDelete=true`.<br>2. Call `DELETE /api/attendance-overtime/Delete-overtime.<br>3. Verify delete notification message is sent once. | - | - |
| TC-06 | EXCP-OT-ANG-ATTENDANCE-006 | Verify Regression for existing event notifications | Main | - | 1. Trigger existing endpoints:<br>2. Start/End work<br>3. Start/End break<br>4. Start/End overtime<br>5. Start/End overtime break<br>6. Verify event templates and send behavior remain intact. | - | - |
