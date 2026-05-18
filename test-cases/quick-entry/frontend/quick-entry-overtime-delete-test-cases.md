# Quick Entry Overtime Delete — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: `DELETE /api/attendance-overtime/Delete-overtime`, `POST /api/attendance-record/Get-bulk-details-in-range`
- Related code: `src/app/features/attendance/components/attendance-quick-entry`, `src/app/core/services/attendance.service.ts`
- Related docs: `docs/frontend/technical/quick-entry-overtime-delete.md`

## Scope

- Single and bulk delete of editable overtime on a Quick Entry day card.
- Confirmation dialogs for single delete, bulk delete, and unsaved draft discard.
- Net overtime chip and period cumulative overtime refresh after server delete.

## Test pages

- `/attendance/quick-entry`

## Test scenarios

- Single pending overtime delete shows confirmation and updates net overtime totals.
- Bulk select and delete multiple pending overtime segments on one day.
- Select all deletable selects only pending / within-gap / draft rows, not approved overtime.
- Unsaved overtime draft delete uses discard confirmation without API call.

## Test cases

### Overtime delete and totals

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-OT-DELETE-001 | Verify single overtime delete shows confirmation and updates net overtime | Main | A day in the loaded range has at least two pending overtime segments.<br>Note the day **"Net overtime (after OT breaks)"** value and the period cumulative overtime chip. | 1. Open `/attendance/quick-entry` for the range containing the day.<br>2. Expand the day and find a pending overtime block.<br>3. Click **"Delete"** on one segment.<br>4. Read the confirmation popup and confirm.<br>5. Wait for the UI to finish updating. | 1. A Quick Entry styled warning popup asks whether to delete the overtime.<br>2. The deleted segment disappears from the list.<br>3. **"Net overtime (after OT breaks)"** decreases to match the remaining segments.<br>4. The period cumulative overtime chip updates to the same reduced total when only that day has overtime. | Date: `"2026-04-10"`<br>Delete one of three pending segments |
| TC-02 | EXCP-QE-OT-DELETE-002 | Verify bulk delete removes multiple selected overtime entries after one confirmation | Main | Same as TC-01 with at least two deletable pending segments on one day. | 1. On the same day, select two pending overtime rows using the row checkboxes.<br>2. Click **"Delete selected (2)"** (or the current count).<br>3. Confirm the bulk delete popup.<br>4. Wait for the UI to finish updating. | 1. One bulk confirmation mentions deleting the selected count for that day.<br>2. Both selected segments are removed.<br>3. **"Net overtime (after OT breaks)"** reflects only the remaining segment(s).<br>4. Selection clears after a successful delete. | Date: `"2026-04-10"` |
| TC-03 | EXCP-QE-OT-DELETE-003 | Verify select all deletable ignores approved overtime | Regression | One day has at least one approved (non-editable) overtime and at least one pending overtime. | 1. Expand the day overtime section.<br>2. Click **"Select all deletable"**.<br>3. Review which rows are selected. | 1. Only pending or within-gap editable rows are selected.<br>2. The approved overtime row has no checkbox and is not selected.<br>3. **"Delete selected"** count matches editable rows only. | - |
| TC-04 | EXCP-QE-OT-DELETE-004 | Verify unsaved overtime draft discard uses draft confirmation | Edge | The day has a new unsaved overtime draft (not yet saved). | 1. Add a new overtime request on the day without saving.<br>2. Select the draft row or click **"Delete"** on it.<br>3. Confirm the discard dialog. | 1. The confirmation asks to discard the unsaved draft, not to delete a saved record.<br>2. The draft row is removed locally.<br>3. No error appears from the delete API. | - |
