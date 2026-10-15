# Request notifications — localized text, refusal reason and deep links (frontend)

## Metadata

- Project: `excp-time`
- Feature: `notifications`
- Layer: `frontend`
- Routes: `/my-requests`, `/admin-leader/list-requests`
- APIs: `GET /api/Notifications/get-my-notifications`, `GET /api/Requests/getById`, `POST /api/Requests/change-reqeust-status`, `POST /api/attendance-overtime/Refuse-overtime`
- Related code: `src/app/core/utils/notification-text.util.ts`, `src/app/core/components/notifications/notification-dropdown/notification-dropdown.component.ts`, `src/app/core/components/notifications/notification-detail-modal/notification-detail-modal.component.ts`, `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/pages/my-requests/my-requests.component.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.ts`, `src/assets/i18n/en.json`, `src/assets/i18n/ar.json`
- Related docs: `docs/frontend/technical/request-notifications.md`
- Automation: -

## Scope

This document covers how a request or overtime notification is shown in English and Arabic, how the refusal reason reaches the employee, and how a notification link opens the right request.

## Test pages

- The notification bell on any page
- /my-requests
- /admin-leader/list-requests

## Test scenarios

- A notification with a text key is shown in the app language, with its reason and dates.
- An older notification without a key still shows its stored text.
- A refusal from the bell always asks for a reason.
- A notification link opens the request details window.

## Test cases

### Localized notification text

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-NOTIF-REQ-UI-001 | Verify a refused request notification shows the reason in Arabic | Main | The app language is Arabic.<br>A leader refused the employee's request with the reason "المرفقات ناقصة". | 1. Sign in as the employee.<br>2. Open the bell.<br>3. Open the new notification. | 1. The list line and the detail window are in Arabic.<br>2. The text names the leader and the request number.<br>3. The reason "المرفقات ناقصة" appears in the text.<br>4. Switching the app to English shows the English wording of the same notification. | Request: 1 | `src/app/core/utils/notification-text.util.ts`, `src/app/core/components/notifications/notification-detail-modal/notification-detail-modal.component.ts`, `src/app/core/components/notifications/notification-dropdown/notification-dropdown.component.ts`, `src/assets/i18n/ar.json` |
| TC-02 | EXCP-NOTIF-REQ-UI-002 | Verify an older notification without a text key still shows its stored text | Regression | A notification created before localization existed, with only English title and message. | 1. Open the bell.<br>2. Open that notification. | 1. The stored English text is shown.<br>2. The two known English titles are still translated as before.<br>3. No empty line or raw key appears. | Notifications: 1 | `src/app/core/utils/notification-text.util.ts`, `src/app/core/components/notifications/notification-dropdown/notification-dropdown.component.ts` |
| TC-03 | EXCP-NOTIF-REQ-UI-003 | Verify the fix-attendance notification lists the issues in the app language | Main | A leader asked the employee to fix an overtime day with two problems.<br>App language is Arabic. | 1. Sign in as the employee.<br>2. Open the notification. | 1. The text says who asked (team leader or HR admin) in Arabic.<br>2. Each problem is named in Arabic, separated by the Arabic comma.<br>3. The date is shown. | Issues: 2 | `src/app/core/utils/notification-text.util.ts`, `src/assets/i18n/ar.json` |
| TC-04 | EXCP-NOTIF-REQ-UI-004 | Verify a new notification pushed live is rendered from its key | Edge | The employee keeps the app open while a leader approves their overtime. | 1. Wait for the live notification.<br>2. Open it from the bell. | 1. The bell count rises.<br>2. The text is in the app language and names the date.<br>3. Selecting it opens the linked request details. | Overtime: 1 | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/core/utils/notification-text.util.ts` |

### Refusal from the bell and deep links

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-05 | EXCP-NOTIF-REQ-UI-005 | Verify refusing from a notification asks for a reason | Main | A leader opens a pending request from a notification and can decide it. | 1. Tap **Refuse** in the details window.<br>2. Confirm with an empty reason.<br>3. Enter a reason and confirm. | 1. The reason window opens.<br>2. An empty reason is blocked.<br>3. The request is refused with the reason and the employee sees it in their notification.<br>4. Cancelling the window leaves the request pending. | Request: 1 | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/shared/services/swal.service.ts` |
| TC-06 | EXCP-NOTIF-REQ-UI-006 | Verify the my-requests link opens the request details | Main | A notification link of the form /my-requests?requestId=<id> for the employee's own request. | 1. Open the link in the app.<br>2. Close the details window. | 1. The request details window opens for that request.<br>2. The address no longer keeps the request id after the window opens.<br>3. The list stays usable after closing. | Request: 1 | `src/app/pages/my-requests/my-requests.component.ts`, `src/app/core/services/requests.service.ts` |
| TC-07 | EXCP-NOTIF-REQ-UI-007 | Verify a link to a request the user may not read shows one clear message | Edge | A link /my-requests?requestId=<id> for another employee's request. | 1. Open the link. | 1. One window says the request details could not be loaded, in the app language.<br>2. No raw backend text and no second window.<br>3. The page works normally afterwards. | Request: 1 | `src/app/pages/my-requests/my-requests.component.ts`, `src/assets/i18n/ar.json` |
| TC-08 | EXCP-NOTIF-REQ-UI-008 | Verify the leader inbox link opens the request details | Main | A link /admin-leader/list-requests?requestId=<id> for a pending request the leader can see. | 1. Open the link as the leader. | 1. The requests inbox loads and the details window opens for that request.<br>2. The decision buttons follow what the user is allowed to do. | Request: 1 | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.ts` |
