# Notification Click Routing And Structure Recipients — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `notifications`
- Layer: `frontend`
- Routes: `/my-requests`, `/admin-leader/list-requests`, `/admin/company-structure`
- APIs: `POST /api/Notifications/get-my-notifications`, `POST /api/Requests/create`, `POST /api/Requests/get-requests-paged-filtered-list`, `PUT /api/request-routing-settings`
- Related code: `src/app/core/utils/request-notification-link.util.ts`, `src/app/core/utils/notification-text.util.ts`, `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/pages/my-requests/my-requests.component.ts`
- Related docs: `docs/frontend/technical/notification-click-routing.md`
- Automation: -

## Scope

This document covers where each person lands when they click a request notification, that notification text is shown in Arabic in the Arabic app, that My Requests shows the right tab, and that the company structure routing settings decide who is notified. Test accounts: Admin "cs-test-admin", HR "cs-test-hr", Leader "cs-test-leader", Employee "cs-test-employee" (password "CsTest@2026!"). Hierarchy: Employee reports to Leader, Leader reports to Admin, HR has no leader.

## Test pages

- The notification bell on any page
- /my-requests
- /admin-leader/list-requests
- /admin/company-structure

## Test scenarios

- Requester, reviewer and HR each land on the right place.
- Notification text is Arabic in the Arabic app.
- My Requests lists pending, approved and rejected requests for every role that can submit.
- Routing settings change who is a receiver and who is only notified.
- Edit, reject and cancel send the right notifications.

## Test cases

### Click-through by role

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-NOTIF-NAV-001 | Verify the requester is taken to My Requests with the request opened | Main | The Employee's request was approved by the Leader | 1. Sign in as the Employee on the home page.<br>2. Open the bell.<br>3. Click the approval notification. | 1. The app moves to "/my-requests".<br>2. The "مقبول" tab is selected and the request is listed.<br>3. The request details open. | Employee: "cs-test-employee" | `src/app/core/utils/request-notification-link.util.ts`, `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/pages/my-requests/my-requests.component.ts` |
| TC-02 | EXCP-NOTIF-NAV-002 | Verify a Leader or Admin is taken to the review page | Main | The Employee submitted a pending request | 1. Sign in as the Admin on the attendance page.<br>2. Open the bell.<br>3. Click the "new request" notification. | 1. The app moves to "/admin-leader/list-requests".<br>2. The details of that request open with "قبول" and "رفض" buttons. | Admin: "cs-test-admin" | `src/app/core/utils/request-notification-link.util.ts`, `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` |
| TC-03 | EXCP-NOTIF-NAV-003 | Verify HR stays on the current page and sees read-only details | Edge | The Employee submitted a pending request | 1. Sign in as HR.<br>2. Open the bell.<br>3. Click the "new request" notification. | 1. The page does not change.<br>2. The request details open without approve or reject buttons. | HR: "cs-test-hr" | `src/app/core/utils/request-notification-link.util.ts`, `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` |
| TC-04 | EXCP-NOTIF-NAV-004 | Verify notification text is Arabic in the Arabic app | Main | The app language is Arabic | 1. Open the bell as the Admin.<br>2. Read the title and message of a "new request" notification. | 1. The text is Arabic, for example "قدّم CS Test Employee طلب طلبات الاستئذان".<br>2. No English fallback text is shown. | - | `src/app/core/utils/notification-text.util.ts` |

### My Requests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-05 | EXCP-NOTIF-MYREQ-001 | Verify a Leader sees their own pending request on My Requests | Main | The Leader submitted a "طلبات الاستئذان" request | 1. Sign in as the Leader.<br>2. Open "/my-requests".<br>3. Select "معلق". | 1. The Leader's own pending request is listed. | Leader: "cs-test-leader" | `src/app/pages/my-requests/my-requests.component.ts` |
| TC-06 | EXCP-NOTIF-MYREQ-002 | Verify HR can submit a request and see it on My Requests | Main | HR has no leader | 1. Sign in as HR.<br>2. Open "/my-requests" and add a "طلبات الاستئذان" request.<br>3. Select "معلق". | 1. The request is created.<br>2. It is listed under "معلق".<br>3. Only the Admin is notified, because HR has no leader. | HR: "cs-test-hr" | `src/app/pages/my-requests/my-requests.component.ts` |
| TC-07 | EXCP-NOTIF-MYREQ-003 | Verify a decided request moves to the right tab | Main | The Employee has a pending request | 1. Sign in as the Employee and note the request under "معلق".<br>2. As the Leader, approve it.<br>3. Reload the Employee's "/my-requests". | 1. "معلق" no longer lists the request.<br>2. "مقبول" lists it. | Employee: "cs-test-employee" | `src/app/pages/my-requests/my-requests.component.ts` |

### Structure settings recipients

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-08 | EXCP-NOTIF-ROUTE-001 | Verify the direct leader mode decides what the Leader receives | Main | Upper mode is "الإشعار فقط" | 1. As the Admin, open the global routing settings on "/admin/company-structure" and choose a direct mode.<br>2. Submit a request as the Employee.<br>3. Check the Leader's bell and "/admin-leader/list-requests". | 1. "الطلب والإشعار": the Leader is notified and can decide.<br>2. "الطلب فقط": the Leader can decide but is not notified.<br>3. "الإشعار فقط": the Leader is notified but cannot decide. | Employee: "cs-test-employee" | `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.ts` |
| TC-09 | EXCP-NOTIF-ROUTE-002 | Verify "لا شيء" as the global direct mode is refused when there is no final approver | Edge | The final approver is "أي شخص استلم الطلب" | 1. Open the global routing settings.<br>2. Choose "لا شيء" as the direct mode and apply. | 1. A popup with the title "فشل" and the message "تعذر حفظ توجيه الطلبات." appears.<br>2. The previous mode stays saved. | - | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/assets/i18n/ar.json` |
| TC-10 | EXCP-NOTIF-ROUTE-003 | Verify Admin and HR are always told about every new request | Main | Any routing mode is saved | 1. Submit a request as the Employee.<br>2. Check the bell of the Admin and HR. | 1. Both receive the "new request" notification.<br>2. The Admin is a receiver at level 2 whatever the upper mode is. | - | `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.ts` |

### Edit, reject and cancel

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-11 | EXCP-NOTIF-LIFE-001 | Verify editing a pending request notifies the reviewers again | Main | The Employee has a pending request | 1. Edit the request as the Employee.<br>2. Check the bell of the Leader, Admin and HR. | 1. Each receives an "updated request" notification.<br>2. Each link opens "/admin-leader/list-requests" for that request. | - | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` |
| TC-12 | EXCP-NOTIF-LIFE-002 | Verify a rejection reaches the Employee with the reason | Main | The Employee has a pending request | 1. As the Leader, reject it with a reason.<br>2. Open the Employee's bell and click the notification. | 1. The Employee is notified.<br>2. The app opens "/my-requests" on the "مرفوض" tab with the request details. | - | `src/app/pages/my-requests/my-requests.component.ts` |
| TC-13 | EXCP-NOTIF-LIFE-003 | Verify cancelling sends each person a link they can open | Main | The Employee has a pending request | 1. Cancel it as the Employee, then check the reviewers' bells.<br>2. Cancel another one as the Admin, then check the Employee's bell and click it. | 1. Reviewers are notified with the review page link.<br>2. The Employee's notification opens "/my-requests". | - | `src/app/core/utils/request-notification-link.util.ts` |
| TC-14 | EXCP-NOTIF-NAV-005 | Verify a decided request opens from its link on the review page | Edge | The Employee's request was already approved | 1. Sign in as the Admin.<br>2. Open the link "/admin-leader/list-requests?requestId=" with that request id. | 1. The "مقبول" tab is selected and the request is listed.<br>2. The request details stay open. | Employee: "cs-test-employee" | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.ts` |
| TC-15 | EXCP-NOTIF-NAV-006 | Verify popup titles are Arabic in the Arabic app | Main | The app language is Arabic | 1. As the Admin, open the global routing settings.<br>2. Choose "لا شيء" as the direct mode and apply. | 1. The popup title is "فشل", not "Fail". | - | `src/assets/i18n/ar.json`, `src/app/shared/services/swal.service.ts` |
