# Modify attendance work place — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/attendance/modify-attendance`
- APIs: `POST /api/attendance-record/Update-attendance-record-with-breaks`
- Related code: `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`
- Related docs: `docs/frontend/technical/modify-attendance-work-place.md`

## Scope

- Day work-place dropdown on modify attendance when work segments exist.
- Copying day Home/Site onto all segments before save.
- Success after a location-only change (no 304 error dialog).

## Test pages

- `/attendance/modify-attendance`

## Test scenarios

- Day with a work segment still shows the day work-place dropdown.
- Changing the day dropdown updates every segment and saves.
- Changing only a segment location saves without a 304 error.

## Test cases

### Work place on modify attendance

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-MOD-WP-001 | Verify the day "Work place" dropdown is visible when the day has work segments. | Main | The selected date has an attendance record with at least one work segment. | 1. Open `/attendance/modify-attendance` for that date. | 1. The page shows a "Work place" dropdown above the work segments list.<br>2. Each segment also has its own Home/Site dropdown. | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.html` |
| TC-02 | EXCP-ATT-MOD-WP-002 | Verify changing day "Work place" copies Home/Site onto every segment and saves. | Main | Same as TC-01. Segment location is "Site". Day dropdown may already show "Home". | 1. Open `/attendance/modify-attendance` for that date.<br>2. Set "Work place" to "Home".<br>3. Confirm every segment dropdown shows "Home".<br>4. Save. | 1. The save succeeds (success popup, not a 304 error).<br>2. After reload, day and segment dropdowns still show "Home". | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`, `src/app/features/attendance/components/modify-attendance/modify-attendance.component.html` |
| TC-03 | EXCP-ATT-MOD-WP-003 | Verify changing only the last segment location saves without a 304 error. | Edge | Same as TC-01. Last segment is "Site". | 1. Open `/attendance/modify-attendance` for that date.<br>2. Change only the last segment dropdown to "Home".<br>3. Do not change start, end, or breaks.<br>4. Save. | 1. The day "Work place" dropdown updates to "Home".<br>2. The save succeeds (success popup, not a 304 error). | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts` |
