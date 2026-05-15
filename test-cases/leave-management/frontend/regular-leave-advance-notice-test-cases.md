# Regular Leave Advance Notice Policy - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `frontend`
- Routes: `/my-requests`, `/admin/system-work-schedule`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- My Requests leave dialog: regular annual (`ANNUAL_REGULAR`) advance notice, empty-day preview, and half-day conflict.
- System work schedule: notice tier fields used by the dialog.

## Test pages

- `/my-requests`
- `/admin/system-work-schedule`


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Regular leave, short duration (tier1) | Main | Start-date calendar disables dates before required tier1 notice |
- | Regular leave, medium duration (tier2) | Main | Calendar min date shifts to tier2 notice window |
- | Regular leave, long duration (tier3) | Main | Calendar min date shifts to tier3 notice window |
- | Non-regular leave type | Edge | Notice-based date restriction is not applied |
- | Admin changes notice settings | Main | Dialog applies updated values without code changes |
- | Manual invalid date submission attempt | Edge | Submit guard shows validation error and blocks request |
- | All counted leave days empty in range | Main | Teal notice-bypass hint appears; earlier start allowed when server agrees |
- | Range includes a worked day | Main | Advance notice still blocks early start |
- | Half-day when every counted day is empty | Edge | Submit blocked with half-day not allowed message |
- | Quick Entry-created leave appears in My Requests | Regression | Newest pending leave appears in All and the matching leave request type tab |
- | Team leader finalizes leave while My Requests is open | Regression | My Requests shows a blocking refresh popup and does not keep stale pending details open |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-REGULAR-ADVANCE-001 | Verify Tier1 calendar disable | Main | - | 1. Open leave dialog with regular leave category.<br>2. Select date range totaling <= tier1 max days (default <=2).<br>3. Verify start-date minDate is `today + tier1NoticeDays`.<br>4. Verify earlier dates are disabled/unselectable. | - | - |
| TC-02 | EXCP-LEAVE-REGULAR-ADVANCE-002 | Verify Tier2 calendar disable | Main | - | 1. Select range that results in > tier1 max and <= tier2 max days.<br>2. Verify minDate updates to `today + tier2NoticeDays`. | - | - |
| TC-03 | EXCP-LEAVE-REGULAR-ADVANCE-003 | Verify Tier3 calendar disable | Main | - | 1. Select range > tier2 max days.<br>2. Verify minDate updates to `today + tier3NoticeDays`. | - | - |
| TC-04 | EXCP-LEAVE-REGULAR-ADVANCE-004 | Verify Half-day behavior | Main | - | 1. Enable half-day toggle.<br>2. Verify end date stays aligned with start date.<br>3. Verify notice calculation still uses selected duration logic safely. | - | - |
| TC-05 | EXCP-LEAVE-REGULAR-ADVANCE-005 | Verify Non-regular leave | Main | - | 1. Switch to non-regular leave category.<br>2. Verify tier-based minDate restriction is not applied. | - | - |
| TC-06 | EXCP-LEAVE-REGULAR-ADVANCE-006 | Verify Admin setting update reflection | Main | - | 1. Change notice tiers in `/admin/system-work-schedule`.<br>2. Reopen leave dialog.<br>3. Verify calendar restrictions use new values. | - | - |
| TC-07 | EXCP-LEAVE-REGULAR-ADVANCE-007 | Verify Submit guard | Edge | - | 1. Force/select start date earlier than computed minDate (if possible via manual input tooling).<br>2. Submit request.<br>3. Verify dialog shows error and request is not sent/succeeds. | - | - |
| TC-08 | EXCP-LEAVE-REGULAR-ADVANCE-008 | Verify All counted leave days empty shows bypass hint | Main | - | 1. Open leave dialog with regular annual category.<br>2. Pick start and end dates so every working day in the range has no attendance times, no breaks, no overtime, and no pending leave on that day in the product.<br>3. Pick a start date earlier than `today + required notice days` for the selected length.<br>4. Wait until the small spinner near the summary badges stops. | 1. Teal hint appears: "All charged leave days in this range have no attendance — advance notice may not apply."<br>2. Submit succeeds when balance and overlap allow (no error about advance notice). | - |
| TC-09 | EXCP-LEAVE-REGULAR-ADVANCE-009 | Verify Worked day in range keeps advance notice | Main | - | 1. Open leave dialog with regular annual category.<br>2. Include at least one working day that already shows attendance, a break, or overtime.<br>3. Choose a start date earlier than `today + required notice days.<br>4. Submit. | 1. Error text includes "This leave request must be submitted at least" and the number of days.<br>2. Request is not created. | - |
| TC-10 | EXCP-LEAVE-REGULAR-ADVANCE-010 | Verify Half-day blocked when preview says all empty | Edge | Leave policy allows half day. | 1. Set a range where every working day in the range is empty as in TC-08.<br>2. Wait for preview (spinner stops).<br>3. Turn on half day.<br>4. Submit. | Message shows: "Half-day leave is not allowed when every charged day in the range is an empty attendance day." | - |
| TC-11 | EXCP-LEAVE-REGULAR-ADVANCE-011 | Verify My Requests refreshes when team leader finalizes leave | Regression | The employee has a pending leave request visible in `/my-requests`.<br>The direct team leader can approve or refuse the leave request.<br>The employee keeps the leave request details modal open. | 1. Open `/my-requests` as the employee.<br>2. Open the pending leave request details.<br>3. As the direct team leader, approve or refuse the leave request in another session.<br>4. Return to the employee page.<br>5. Click `"Refresh My Requests"` in the blocking popup. | 1. The employee sees a blocking popup explaining that the leave request was updated by the team leader.<br>2. The details modal closes so stale pending actions are not visible.<br>3. The current request list refreshes after confirmation.<br>4. The leave balance widget refreshes. | Date: `"2026-05-03"` |
| TC-12 | EXCP-LEAVE-REGULAR-ADVANCE-012 | Verify Quick Entry-created regular annual leave appears in My Requests | Regression | The employee has a normal empty workday that can be marked as regular annual leave from Quick Entry. | 1. Open `"/attendance/quick-entry"` as the employee.<br>2. Mark `"2026-05-06"` as regular annual leave.<br>3. Open `"/my-requests"`.<br>4. Select the `"Pending"` status filter.<br>5. Open the `"All"` request type tab.<br>6. Open the regular annual leave request type tab. | 1. The new pending leave request appears on page 1 in the `"All"` tab.<br>2. The same request appears under the regular annual leave request type tab.<br>3. The request is sorted above older pending requests.<br>4. The request type matches the regular annual leave request type, not another leave-like request type. | Date: `"2026-05-06"` |
