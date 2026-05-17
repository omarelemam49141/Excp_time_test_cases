# Get overtime by id — incomplete overtime — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `API base: attendance overtime controller (same host as other attendance APIs).`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance OverTimes/GetOverTimeByIdBuilder.cs`, `src/Excp.HRSystem.Application/Services/Attendance Overtime App/AttendanceOvertimeService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Attendance Overtime App Contracts/Dtos/AttendanceOverTimeLightDto.cs`
- Related docs: `docs/backend/technical/get-overtime-by-id-partial-times.md`

## Scope

- **GET** API that returns one overtime record by id (path includes **Get-overtime-by-id** and an `overTimeId` query parameter).
- Records where the overtime is still open (no end time) or start time is missing.

## Test pages

- API base: attendance overtime controller (same host as other attendance APIs).

## Test scenarios

- Open overtime does not return HTTP **500**; response includes duration **"00:00:00"`** (or equivalent zero display) and a clear status for the incomplete interval.
- Response allows the app to show the day in problem navigation without crashing.

## Test cases

### Successful responses for incomplete overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|-----------------|-------|----------|-----------|
| TC-01 | EXCP-OT-ANG-ATTENDANCE-ID-001 | Verify **Get-overtime-by-id** returns success when the overtime has no end time | Main | You have an `overTimeId` for an overtime that has started but not ended (same employee you can load in Quick Entry). You have a valid auth token. | 1. Call **GET** **Get-overtime-by-id** with `overTimeId` set to that id.<br>2. Read the HTTP status and JSON body. | 1. HTTP status is **200** (not **500**).<br>2. The body includes a success payload with overtime details.<br>3. **Duration** shows zero hours (for example **"00:00:00"** or the same zero pattern your client already uses for empty spans).<br>4. **End** time is empty or omitted in a way the client already treats as “no end yet”. | `overTimeId: a real pending overtime id from your test tenant |
| TC-02 | EXCP-OT-ANG-ATTENDANCE-ID-002 | Verify **Get-overtime-by-id** returns success when start time is missing but the row exists | Edge | A test overtime row exists with no start time (if your data allows); otherwise skip. | 1. Call **GET** **Get-overtime-by-id** with that id.<br>2. Read the JSON. | 1. HTTP status is **200**.<br>2. **Start** is empty or null in JSON if the business allows missing start; **Duration** is zero. | - |
