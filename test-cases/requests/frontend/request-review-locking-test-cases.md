# Request Review Locking — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `frontend`
- Routes: `/admin-leader/list-requests`, `/my-requests`, `/attendance/modify-overtime`, `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/core/models/request-review-lock.model.ts`, `src/app/core/services/request-review-lock.service.ts`, `src/app/core/services/Signal-R/attendance-hub.service.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/`, `src/app/features/admin-leader/shared/components/over-time-list/`, `src/app/pages/my-requests/`, `src/app/pages/my-requests/components/generic-request-dialog/`, `src/app/pages/my-requests/components/leave-request-dialog/`, `src/app/features/attendance/components/modify-overtime/`, `src/app/features/attendance/components/attendance-quick-entry/`
- Related docs: `docs/frontend/technical/request-review-locking.md`

## Scope

This document covers leader locking on `/admin-leader/list-requests`, changed-request warning behavior, and employee conflict handling from request and overtime edit screens.

## Test pages

- `/admin-leader/list-requests`
- `/my-requests`
- `/attendance/modify-overtime`
- `/attendance/quick-entry`

## Test scenarios

- Leader locks and unlocks one pending request or overtime entry from the visible leader inbox table.
- Leader locks and unlocks selected pending requests or overtime entries from the floating action bar.
- Employee save/delete actions are blocked while the leader lock is active.
- Leader sees a blocking warning when an unlocked pending request or overtime entry changes while the inbox is open.
- Leader reloads or reloads and locks the current filtered inbox view.

## Test cases

### Leader Lock Controls

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-REQUEST-REVIEW-001 | Verify a leader can lock one pending overtime request from the overtime tab | Main | A leader has one pending overtime request visible on `/admin-leader/list-requests`. | 1. Open `/admin-leader/list-requests` as the leader.<br>2. Click `"Over time requests"`.<br>3. Keep the status filter on `"Pending"`.<br>4. Click `"Lock"` on the pending overtime request. | 1. The overtime request shows `"Locked by you"`.<br>2. The overtime request keeps the `"Pending"` status.<br>3. The `"Unlock"` action is available for the same overtime request. | Employee: "Direct report"<br>Request type: "Overtime" |
| TC-02 | EXCP-REQ-REQUEST-REVIEW-002 | Verify a leader can unlock an overtime request they locked | Main | Same as TC-01 and the overtime request shows `"Locked by you"`. | 1. Click `"Unlock"` on the locked overtime request.<br>2. Wait for the overtime list to update. | 1. The lock badge disappears.<br>2. The `"Lock"` action is available again.<br>3. The leader can still approve or refuse the overtime request. | - |
| TC-03 | EXCP-REQ-REQUEST-REVIEW-003 | Verify selected pending overtime requests can be locked together | Main | At least two pending overtime requests are visible on the `"Over time requests"` tab. | 1. Select two pending overtime requests.<br>2. Click `"Lock selected"` in the floating action bar. | 1. Both selected overtime requests show `"Locked by you"`.<br>2. The selected count remains visible until the leader clears it or changes filters.<br>3. The floating action bar still shows `"Unlock selected"`, `"Approve marked"`, and `"Refuse marked"`. | - |
| TC-04 | EXCP-REQ-REQUEST-REVIEW-004 | Verify selected pending overtime requests can be unlocked together | Main | Same as TC-03 and the selected overtime requests show `"Locked by you"`. | 1. Click `"Unlock selected"` in the floating action bar.<br>2. Wait for the overtime list to update. | 1. The lock badges disappear from the selected overtime requests.<br>2. The overtime requests remain pending. | - |
| TC-05 | EXCP-REQ-REQUEST-REVIEW-005 | Verify selected pending generic requests can still be locked together | Regression | At least two pending generic requests are visible on `/admin-leader/list-requests`. | 1. Open any non-overtime request tab or the `"All"` tab.<br>2. Select two pending requests.<br>3. Click `"Lock selected"` in the floating action bar. | 1. Both selected requests show `"Locked by you"`.<br>2. The selected count remains visible until the leader clears it or changes filters. | - |
| TC-06 | EXCP-REQ-REQUEST-REVIEW-006 | Verify selected pending generic requests can still be unlocked together | Regression | Same as TC-05 and the selected requests show `"Locked by you"`. | 1. Click `"Unlock selected"` in the floating action bar.<br>2. Wait for the request list to update. | 1. The lock badges disappear from the selected requests.<br>2. The requests remain pending. | - |

### Employee Conflict Handling

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-REQ-REQUEST-REVIEW-007 | Verify an employee cannot edit a locked generic request | Regression | A leader locked a pending generic request for the employee. | 1. Open `/my-requests` as the employee.<br>2. Open the locked pending request for editing.<br>3. Change any editable field.<br>4. Click `"Save"`. | 1. The save is rejected.<br>2. The employee sees `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`<br>3. The request remains unchanged after reload. | Request type: "Generic" |
| TC-08 | EXCP-REQ-REQUEST-REVIEW-008 | Verify an employee cannot save locked overtime from quick entry | Regression | A leader locked a pending overtime request for the employee from the `"Over time requests"` tab. | 1. Open `/attendance/quick-entry` as the employee.<br>2. Change the locked overtime start or end time.<br>3. Click `"Save changes"`. | 1. The save is rejected.<br>2. The employee sees one lock conflict message on the affected day, not a duplicated message.<br>3. The overtime values return to the server values after reload. | Date: "2026-05-06"<br>Start: "18:00"<br>End: "20:00" |
| TC-09 | EXCP-REQ-REQUEST-REVIEW-009 | Verify an employee can edit after the leader unlocks the request | Main | A locked pending request exists from TC-07 or TC-08. | 1. As the leader, click `"Unlock"` for the request.<br>2. As the employee, reload the edit screen.<br>3. Change an editable field.<br>4. Click `"Save"`. | 1. The save succeeds.<br>2. The updated value appears after reload.<br>3. The leader no longer sees a lock badge for that request. | - |

### Changed Request Warning

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-REQ-REQUEST-REVIEW-010 | Verify the leader sees a blocking warning when an unlocked pending generic request changes | Main | The leader has `/admin-leader/list-requests` open with a pending unlocked generic request visible. | 1. In another session, open the same pending request as the employee.<br>2. Change and save the request.<br>3. Return to the leader session. | 1. A blocking dialog appears with `"A pending request changed"`.<br>2. The dialog includes `"Reload"`.<br>3. The dialog includes `"Reload and lock current view"`. | - |
| TC-11 | EXCP-REQ-REQUEST-REVIEW-011 | Verify the leader sees a blocking warning when an unlocked pending overtime request changes | Main | The leader has the `"Over time requests"` tab open with a pending unlocked overtime request visible. | 1. In another session, open the same pending overtime request as the employee.<br>2. Change and save the overtime request.<br>3. Return to the leader session. | 1. A blocking dialog appears with `"A pending request changed"`.<br>2. The dialog includes `"Reload"`.<br>3. The dialog includes `"Reload and lock current view"`. | Request type: "Overtime" |
| TC-12 | EXCP-REQ-REQUEST-REVIEW-012 | Verify Reload refreshes the active leader request list after a pending change | Main | The blocking dialog from TC-10 or TC-11 is visible. | 1. Click `"Reload"` in the dialog. | 1. The dialog closes.<br>2. The active request list refreshes.<br>3. The leader sees the latest request details before deciding. | - |
| TC-13 | EXCP-REQ-REQUEST-REVIEW-013 | Verify Reload and lock current view refreshes then locks pending requests | Main | The blocking dialog from TC-10 or TC-11 is visible and the leader is using a specific tab or search filter. | 1. Click `"Reload and lock current view"`.<br>2. Wait for the page to finish loading. | 1. The dialog closes.<br>2. The current filtered pending requests show `"Locked by you".<br>3. Employees cannot save changes to those locked requests until the leader unlocks them or the locks expire. | Search: "direct report" |
