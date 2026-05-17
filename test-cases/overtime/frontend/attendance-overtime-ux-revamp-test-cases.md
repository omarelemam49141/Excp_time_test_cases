# Attendance & Overtime UX Revamp - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `frontend`
- Routes: `(Add the primary screen route or API path here.)`
- APIs: -
- Related code: `src/app/features/attendance/components/modify-attendance/`, `src/app/features/attendance/components/modify-overtime/`, `src/app/features/attendance/components/request-overtime-dialog/`, `src/app/pages/home/home.component.ts`, `src/app/core/services/attendance.service.ts`, `src/app/features/admin-leader/admin/components/system-work-schedule/`, `src/app/core/models/system-work-schedule.model.ts`
- Related docs: `docs/early-attendance-preshift-overtime.md`, `docs/frontend/technical/system-work-schedule-whatsapp-language.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Edit existing break inline | Main | Break start/end can be edited directly without deleting row |
- | Add/remove break rows | Main | New break rows are added and removable with correct payload mapping |
- | Keyboard-first time entry (attendance/overtime/request dialog) | Main | Users can type `HH:mm` manually and submit successfully |
- | Break range validation | Edge | End time before start time shows validation message |
- | Break overlap validation | Edge | Overlapping break rows show validation message |
- | In-progress day in attendance edit | Edge | End time remains locked with `inProgress` label and submit still works |
- | WhatsApp toggle controls visible in work schedule | Main | Four granular checkboxes appear and persist in payload |
- | Pre-shift no-attendance window | Main | Before `(shift start - early tolerance)`, home shows Start Overtime and hides Start Work |
- | Pre-shift backend flag refresh | Edge | Home updates pre-shift visibility from `Is-attendance-record-registered` polling without relying on device clock logic |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-ATTENDANCE-UX-REVAMP-001 | Verify Modify attendance break without delete/re-add | Main | - | 1. Open modify attendance page with existing breaks.<br>2. Change one break start/end time directly in the row.<br>3. Save updates.<br>4. Verify edited break is persisted and keeps its existing id. | - | - |
| TC-02 | EXCP-OT-ATTENDANCE-UX-REVAMP-002 | Verify Modify overtime break inline | Main | - | 1. Open modify overtime page for pending/within-gap overtime.<br>2. Edit break times directly in row inputs.<br>3. Save updates.<br>4. Verify API request contains updated breaks with expected ids and `HH:mm:ss` times. | - | - |
| TC-03 | EXCP-OT-ATTENDANCE-UX-REVAMP-003 | Verify Add break + overlap guard | Main | - | 1. Add a new break row from rest form.<br>2. Set overlapping time with another row.<br>3. Verify overlap warning appears and does not silently clear data. | - | - |
| TC-04 | EXCP-OT-ATTENDANCE-UX-REVAMP-004 | Verify Manual typing in time fields | Main | - | 1. On modify attendance, modify overtime, and request overtime dialog, type times manually (example: `09:12`).<br>2. Submit each form.<br>3. Verify submit succeeds and outbound payload times are normalized (`HH:mm:ss`). | - | - |
| TC-05 | EXCP-OT-ATTENDANCE-UX-REVAMP-005 | Verify Work schedule WhatsApp granular toggles | Main | - | 1. Open system work schedule -> WhatsApp tab.<br>2. Toggle each of:<br>3. attendance update<br>4. overtime update<br>5. attendance delete<br>6. overtime delete<br>7. Save, reload page, and verify persisted values are restored. | - | - |
| TC-06 | EXCP-OT-ATTENDANCE-UX-REVAMP-006 | Verify Home pre-shift overtime before early tolerance | Main | - | 1. Configure shift start `09:00` and early tolerance `30` minutes.<br>2. Ensure the selected current day has no attendance record (`DoesNotExist`).<br>3. Open home at `08:29` or earlier.<br>4. Verify **Start Overtime** is visible and **Start Work** is hidden.<br>5. Open home at `08:30`.<br>6. Verify **Start Work** is visible and pre-shift **Start Overtime** is not shown from the early-window rule. | - | - |
| TC-07 | EXCP-OT-ATTENDANCE-UX-REVAMP-007 | Verify Home pre-shift backend refresh while screen stays open | Main | - | 1. Configure shift start `09:00` and early tolerance `30` minutes.<br>2. Ensure current day is selected and no attendance exists.<br>3. Keep Home open while crossing the `08:30` earliest-allowed boundary.<br>4. Verify button visibility changes after backend status refresh (about 1 minute) even without page reload.<br>5. Verify behavior is driven by `isBeforeEarlyTolerance` from `Is-attendance-record-registered and not local fallback calculations. | - | - |
