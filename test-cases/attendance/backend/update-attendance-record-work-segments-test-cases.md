# Update attendance record work segments — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/attendance-record/Update-attendance-record-with-breaks`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs`
- Related docs: `docs/backend/technical/update-attendance-record-work-segments.md`

## Scope

- 304 vs 200 when only `workSegments[].workPlace` changes.
- Copying last segment `WorkPlace` onto the attendance record.

## Test pages

- `POST /api/attendance-record/Update-attendance-record-with-breaks`

## Test scenarios

- Segment-only location change is persisted.
- Last segment location updates the record `WorkPlace`.
- Identical payload still returns 304.

## Test cases

### Work segment work place

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-UPD-SEG-001 | Verify a segment-only work-place change does not return 304. | Main | Attendance record date has one work segment. Record `WorkPlace` is Home. Segment `WorkPlace` is Site. Times and breaks stay the same. | 1. POST `Update-attendance-record-with-breaks` with the same start, end, and breaks.<br>2. Send `workPlace` `1` and the existing segment with `workPlace` `1`. | 1. HTTP status is success (not 304).<br>2. Response message is the updated-successfully text, not the no-changes text. | `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceRecords/AttendanceRecordAPIController.cs` |
| TC-02 | EXCP-ATT-UPD-SEG-002 | Verify the last segment work place is stored on the attendance record. | Main | Same as TC-01 after changing the segment to Home, or POST with last segment `workPlace` `2` while record is Home. | 1. POST with last segment `workPlace` `2` and unchanged times/breaks. | 1. The work segment row is Site.<br>2. The attendance record `WorkPlace` is Site. | `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs` |
| TC-03 | EXCP-ATT-UPD-SEG-003 | Verify an unchanged payload still returns 304. | Edge | Record, breaks, and segments already match the request body. | 1. POST the same times, breaks, record `workPlace`, and segment `workPlace` that are stored. | 1. Response `code` is `304`.<br>2. Message is the no-changes attendance text. | `src/Excp.HRSystem.Application/Builders/Controllers/Attendance Record/UpdateAttendanceRecordWithBreaksBuilder.cs` |
