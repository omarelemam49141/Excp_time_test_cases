# Subordinate requests — decision blockers (frontend)

## Metadata

- Project: `excp-time`
- Feature: `subordinate-requests`
- Layer: `frontend`
- Routes: `/admin-leader/list-requests`
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`, `POST /api/AttendanceOverTime/Get-overtimes-By-LeaderId-and-status`, `GET /api/Requests/getById`
- Related code: `src/app/core/components/decision-blocker-chip/decision-blocker-chip.component.ts`, `src/app/core/utils/decision-blocker.util.ts`, `src/app/core/models/decision-blocker.model.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html`, `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.html`, `src/app/pages/my-requests/components/request-details-modal/request-details-modal.component.ts`, `src/app/pages/my-requests/components/request-details-modal/request-details-modal.component.html`, `src/app/core/components/notifications/notification-bell/notification-bell.component.html`, `src/assets/i18n/en.json`, `src/assets/i18n/ar.json`
- Related docs: `docs/frontend/technical/subordinate-requests-decision-blockers.md`
- Automation: `src/app/core/utils/decision-blocker.util.spec.ts`, `src/app/core/components/decision-blocker-chip/decision-blocker-chip.component.spec.ts`, `src/app/pages/my-requests/components/request-details-modal/request-details-modal.component.spec.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.spec.ts`, `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.spec.ts`

## Scope

This document covers the short reason shown next to the disabled **Accept** and **Refuse** buttons when the signed-in leader or administrator cannot decide a pending request or overtime. The reason comes from the backend `decisionBlockers` list. The screen only displays it; the backend still refuses a decision that is not allowed.

## Test pages

- /admin-leader/list-requests
- /my-requests

## Test scenarios

- A pending row that the user cannot decide shows one reason chip and disabled buttons.
- A row the user can decide shows no chip.
- The request details window follows the same rule, including when it is opened from a notification.
- The reason text exists in English and Arabic and reads correctly in both directions.

## Test cases

### Rows and details window

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SUBREQ-BLOCKER-001 | Verify a pending request row the leader cannot decide shows its reason | Main | A leader account.<br>Pending requests: one the leader can decide; one the leader only gets notified about; one where another person gives the final approval. | 1. Sign in as the leader.<br>2. Open /admin-leader/list-requests on the **Pending** filter.<br>3. Read the **Actions** cell of each row. | 1. The row the leader can decide has enabled **Accept** and **Refuse** and no reason chip.<br>2. The notify-only row has the buttons disabled and a chip saying the leader is only notified.<br>3. The final-approver row shows a chip naming the final approver; **Refuse** follows what the backend allows.<br>4. Hovering a chip shows the same text as a tooltip.<br>5. Rows that are approved or refused show no chip. | Requests: 3 |
| TC-02 | EXCP-SUBREQ-BLOCKER-002 | Verify a pending overtime row the leader cannot decide shows its reason | Main | A leader account.<br>A pending overtime whose linked request lists another reviewer, and a pending overtime of the leader's own direct report. | 1. Sign in as the leader.<br>2. Open /admin-leader/list-requests and select the **Overtime** tab.<br>3. Read the **Actions** cell of both rows. | 1. The direct report's overtime has enabled buttons and no chip.<br>2. The other overtime has disabled buttons and a chip saying another reviewer decides it.<br>3. A row locked by another reviewer still shows the lock badge and disabled buttons. | Overtimes: 2 |
| TC-03 | EXCP-SUBREQ-BLOCKER-003 | Verify the details window hides or disables the decision buttons and gives the reason | Main | The same pending requests as TC-01. | 1. Open **Details** on the request the leader can decide.<br>2. Close it and open **Details** on the notify-only request.<br>3. Close it and open **Details** on the request waiting for the final approver. | 1. The first window shows **Refuse** and **Accept**, both enabled, and no chip.<br>2. The second window shows no decision buttons, only the reason chip.<br>3. The third window shows both buttons with **Accept** disabled and the reason chip beside them.<br>4. Clicking a disabled button does nothing. | Requests: 3 |
| TC-04 | EXCP-SUBREQ-BLOCKER-004 | Verify a request opened from a notification carries the same reason | Regression | A pending request the leader cannot approve; a notification that links to it. | 1. Sign in as the leader.<br>2. Open the notification bell and select the notification.<br>3. Read the details window. | 1. The window opens with the decision state of that request (not always both buttons).<br>2. For a request the leader cannot decide, the reason chip shows and no enabled **Accept** is offered.<br>3. For a request the leader can decide, both buttons work as before. | Notifications: 1 |

### Localization and direction

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-SUBREQ-BLOCKER-005 | Verify reasons read correctly in Arabic and English | Regression | A pending request the leader cannot approve because another person gives the final approval. | 1. Open /admin-leader/list-requests in Arabic and read the chip.<br>2. Switch to English and read the chip.<br>3. Check the row layout and the details window in both. | 1. The Arabic chip is fully Arabic, includes the approver's name and is aligned from the right.<br>2. The English chip is aligned from the left.<br>3. A long reason wraps inside the cell and does not overlap the buttons.<br>4. No raw key such as `requestDecision.blocker.` is shown. | Languages: "ar", "en" |
| TC-06 | EXCP-SUBREQ-BLOCKER-006 | Verify an older or empty response keeps the previous behavior | Regression | A response without `decisionBlockers` (for example from an older server). | 1. Load the pending list against a server that does not send `decisionBlockers`. | 1. Rows still show the old "waiting for approver" text when a final approver is known.<br>2. Buttons follow `currentUserCanApprove` and `currentUserCanReject` as before.<br>3. No error appears. | - |
