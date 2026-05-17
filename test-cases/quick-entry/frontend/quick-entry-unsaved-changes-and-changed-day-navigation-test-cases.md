# Quick Entry floating save, unsaved-exit protection, and period persistence test cases (frontend)

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/features/attendance/components/attendance-quick-entry`
- Related docs: `docs/frontend/technical/quick-entry-unsaved-changes-and-changed-day-navigation.md`

## Scope

Covers `/attendance/quick-entry` save controls, unsaved-change prompts, editable overtime saves for existing overtime entries, and restoring the last selected period.

## Test pages

- `/attendance/quick-entry`

## Test scenarios

- Floating `"Save changes"` from the bottom of a long quick-entry page saves edits without returning to the page header.
- The leave-page prompt can save, discard, or keep unsaved edits.
- Browser refresh or tab close warns when the page has unsaved edits.
- A clean page does not show save controls or leave prompts.
- Existing editable overtime with `"Within overtime gap"` status can be saved after a time edit.
- Existing editable overtime with `"Within overtime gap"` status shows the within-gap label/color, not the pending label/color.
- A selected `"From day to day"` period remains selected after browser refresh.
- Returning to quick entry from another page restores the last selected period.

## Test cases

### Save controls

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-UNSAVED-CHANGES-001 | Verify the floating save control saves edits from the bottom of a long quick-entry page | Main | The `/attendance/quick-entry` page is loaded for a period with enough days to scroll.<br>At least one visible day can be edited. | 1. Scroll near the bottom of the page.<br>2. Change one editable attendance or overtime value.<br>3. Click the floating `"Save changes"` button.<br>4. Reload the same period. | 1. A success message appears.<br>2. The edited value remains visible after reload.<br>3. The floating `"Save changes"` button is hidden after the save finishes. | - |
| TC-02 | EXCP-QE-UNSAVED-CHANGES-002 | Verify saving a within-gap overtime time edit does not show the no-changes message | Regression | The `/attendance/quick-entry` page is loaded for an employee who has an editable overtime entry on `"2026-02-01"` with status `"Within overtime gap"`.<br>The overtime end time is `"05:50 PM"`. | 1. Change the overtime end time from `"05:50 PM"` to `"05:51 PM"`.<br>2. Click `"Save changes"`.<br>3. Reload the same period. | 1. The page does not show `"No changes to save."`.<br>2. A success message appears.<br>3. The overtime entry shows end time `"05:51 PM"` after reload. | Date: `"2026-02-01"`<br>End time before edit: `"05:50 PM"`<br>End time after edit: `"05:51 PM"` |
| TC-03 | EXCP-QE-UNSAVED-CHANGES-003 | Verify within-gap overtime shows within-gap status while remaining editable | Regression | The `/attendance/quick-entry` page is loaded for an employee who has an editable overtime entry on `"2026-02-01"` with status `"Within overtime gap"`. | 1. Open the day `"2026-02-01"`.<br>2. Look at the overtime entry title and card color.<br>3. Confirm the time inputs and delete button are still available. | 1. The overtime entry title shows `"Within overtime gap"` or the localized equivalent.<br>2. The title does not show `"Pending overtime (editable)"` or the localized pending equivalent.<br>3. The card uses the within-gap/teal visual style instead of the pending/amber style.<br>4. The overtime remains editable. | Date: `"2026-02-01"` |
| TC-04 | EXCP-QE-UNSAVED-CHANGES-004 | Verify no save control appears when the quick-entry page has no edits | Edge | The `/attendance/quick-entry` page is loaded with no unsaved edits. | 1. Do not change any values.<br>2. Check the top and floating save controls.<br>3. Navigate to another page. | 1. The floating `"Save changes"` button is not visible.<br>2. No unsaved-change prompt appears.<br>3. Navigation continues normally. | - |

### Leave protection

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-QE-UNSAVED-CHANGES-005 | Verify choosing save and leave saves edits before navigation | Main | The `/attendance/quick-entry` page is loaded and at least one visible day can be edited. | 1. Change one editable value.<br>2. Navigate to another page.<br>3. In the unsaved-change prompt, choose `"Save and leave"`. | 1. A save is attempted.<br>2. Navigation continues after the save succeeds.<br>3. Returning to quick entry shows the edited value. | - |
| TC-06 | EXCP-QE-UNSAVED-CHANGES-006 | Verify choosing discard and leave navigates away without saving edits | Main | The `/attendance/quick-entry` page is loaded and at least one visible day can be edited. | 1. Change one editable value.<br>2. Navigate to another page.<br>3. In the unsaved-change prompt, choose `"Discard and leave"`.<br>4. Return to the same quick-entry period. | 1. Navigation continues.<br>2. The edited value is not saved.<br>3. The page shows the previous value after reload. | - |
| TC-07 | EXCP-QE-UNSAVED-CHANGES-007 | Verify choosing stay on page keeps the current unsaved edits visible | Main | The `/attendance/quick-entry` page is loaded and at least one visible day can be edited. | 1. Change one editable value.<br>2. Navigate to another page.<br>3. In the unsaved-change prompt, choose `"Stay on page"`. | 1. Navigation is cancelled.<br>2. The user remains on `/attendance/quick-entry`.<br>3. The unsaved edit is still visible. | - |
| TC-08 | EXCP-QE-UNSAVED-CHANGES-008 | Verify browser refresh warns when quick entry has unsaved edits | Edge | The `/attendance/quick-entry` page is loaded and at least one visible day can be edited. | 1. Change one editable value.<br>2. Refresh the browser tab or attempt to close it. | 1. The browser shows its native unsaved-changes warning.<br>2. If the user cancels the browser warning, the quick-entry page remains open with the unsaved edit visible. | - |

### Period persistence

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-QE-UNSAVED-CHANGES-009 | Verify refreshing quick entry keeps a selected date range | Main | The `/attendance/quick-entry` page is loaded with no unsaved edits. | 1. Click `"From day to day"`.<br>2. Select `"2026-05-01"` in `"From"`.<br>3. Select `"2026-05-13"` in `"To"`.<br>4. Wait until the period data loads.<br>5. Refresh the browser tab. | 1. The page opens with `"From day to day"` still selected.<br>2. `"From"` shows `"01/05/2026"`.<br>3. `"To"` shows `"13/05/2026"`.<br>4. The visible days match the selected period. | From: `"2026-05-01"`<br>To: `"2026-05-13"` |
| TC-10 | EXCP-QE-UNSAVED-CHANGES-010 | Verify returning to quick entry restores the last selected date range | Main | The `/attendance/quick-entry` page is loaded with no unsaved edits. | 1. Click `"From day to day"`.<br>2. Select `"2026-05-01"` in `"From"`.<br>3. Select `"2026-05-13"` in `"To"`.<br>4. Wait until the period data loads.<br>5. Navigate to another page, such as `"Home"`.<br>6. Open `/attendance/quick-entry` again. | 1. The page opens with `"From day to day"` still selected.<br>2. `"From"` shows `"01/05/2026"`.<br>3. `"To"` shows `"13/05/2026"`.<br>4. The visible days match the selected period without choosing the dates again. | From: `"2026-05-01"`<br>To: `"2026-05-13" |
