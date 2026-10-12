# Request Notifications — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `notifications`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/create`, `PUT /api/Requests/update`, `POST /api/Requests/change-reqeust-status`, `POST /api/attendance-overtime/Accept-overtime`, `POST /api/attendance-overtime/End-overtime`, `POST /api/attendance-overtime/Request-overtime`, `POST /api/attendance-overtime/Notify-employee-overtime-day-fix-required`
- Related code: `src/Excp.HRSystem.Application/Services/Users/Notifications/NotificationSenderService.cs`, `src/Excp.HRSystem.Application/Services/Users/Notifications/RequestNotificationTexts.cs`, `src/Excp.HRSystem.Application/Services/Requests/ApproverNotificationService.cs`, `src/Excp.HRSystem.Application/Services/Requests/PendingOvertimeNotifier.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs`, `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CreateRequestBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/UpdateRequestBuilder.cs`, `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeReviewReadinessAppService.cs`
- Related docs: `docs/backend/technical/request-notifications.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestNotificationPolicyTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/NotificationSenderSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/PendingOvertimeNotifierSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/CreateRequestSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/UpdateRequestSqliteTests.cs`

## Scope

This document covers who is told when something needs a reviewer (the routing hops that notify plus the final approver), the fallback to the branch administrators when nobody is configured, the translated notification texts, and the rule that a notification reaches a screen only after the change it describes is saved.

## Test pages

- `/admin-leader/list-requests`
- `/my-requests`

## Test scenarios

- The final approver is always told, even when their hop is request-only.
- A request with no leader tells the administrators of the employee's branch.
- A notification is stored with a translation key and arguments, and an English fallback.
- A rolled-back action sends nothing.
- The same overtime day does not notify the same reviewer twice.

## Test cases

### Recipients

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-NOTIF-HRS-REQ-001 | Verify the default settings tell only the direct leader about new overtime | Main | An employee, a direct leader and a parent-team leader. Direct leaders are "Both" and upper leaders are "Request only". No final approver. A pending overtime of 2026-05-06 without a request. | 1. End the overtime as the employee, or open the day in quick entry.<br>2. Read the notifications of both leaders. | 1. The direct leader has one notification.<br>2. The parent-team leader has none because "Request only" is silent by design.<br>3. The notification is from the employee. | Day: "2026-05-06" |
| TC-02 | EXCP-NOTIF-HRS-REQ-002 | Verify the final approver is told even when their hop is request-only | Main | Same chain with the final approver set to the top of the chain. | 1. Repeat TC-01.<br>2. Read the notifications. | 1. Both the direct leader and the parent-team leader have one notification. | Day: "2026-05-06" |
| TC-03 | EXCP-NOTIF-HRS-REQ-003 | Verify a notification-only direct leader and the final approver are both told | Regression | Direct leaders set to "Notification only", final approver set to the top of the chain. | 1. Repeat TC-01. | 1. Both leaders have one notification.<br>2. The direct leader can read but not decide the request. | Day: "2026-05-06" |
| TC-04 | EXCP-NOTIF-HRS-REQ-004 | Verify the same day does not notify a reviewer twice | Regression | TC-02 done. | 1. Notify the same day again (for example open the day in quick entry again). | 1. Each reviewer still has exactly one notification for that day. | Day: "2026-05-06" |
| TC-05 | EXCP-NOTIF-HRS-REQ-005 | Verify an employee with no leader tells the administrators of their branch only | Main | An employee in "Egypt" with no leader; an administrator in "Egypt"; an administrator in "Saudi". | 1. Submit overtime for the employee.<br>2. Read the administrators' notifications. | 1. Only the "Egypt" administrator is told.<br>2. The "Saudi" administrator and the employee are not told.<br>3. A warning is written to the server log. | Locations: "Egypt", "Saudi" |
| TC-06 | EXCP-NOTIF-HRS-REQ-006 | Verify every administrator is told when none shares the employee's branch | Edge | The same employee; the only administrator is in "Saudi". | 1. Submit overtime for the employee. | 1. The "Saudi" administrator has one notification. | Location: "Saudi" |

### Stored texts and delivery

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-NOTIF-HRS-REQ-007 | Verify a notification keeps its translation key, arguments and English fallback | Main | A refusal with an Arabic reason. | 1. Refuse a request with the reason `"السبب: المستند ناقص"`.<br>2. Read the notification as it is stored and as it arrives on the screen. | 1. The English title is "Request rejected" and the English message contains the reason.<br>2. The notification has the keys for the rejected title and message.<br>3. The arguments contain the reason in readable Arabic and the request number. | Reason: "السبب: المستند ناقص" |
| TC-08 | EXCP-NOTIF-HRS-REQ-008 | Verify a notification reaches the screen only after the change is saved | Main | A decision that notifies the employee. | 1. Run the decision and watch the employee's screen while it is being saved. | 1. Nothing arrives before the change is saved.<br>2. After it is saved the notification and the new unread count arrive. | - |
| TC-09 | EXCP-NOTIF-HRS-REQ-009 | Verify a rolled-back action stores and sends no notification | Regression | A decision that fails after the notification was prepared. | 1. Run the decision and make the save fail. | 1. No notification is stored.<br>2. Nothing arrives on any screen. | - |
| TC-10 | EXCP-NOTIF-HRS-REQ-010 | Verify oversized arguments are dropped but the notification is still saved | Edge | A reason longer than the stored limit for arguments. | 1. Send a notification whose arguments are longer than 2000 characters. | 1. The notification is saved with its English text and keys.<br>2. The arguments are empty. | - |
| TC-11 | EXCP-NOTIF-HRS-REQ-011 | Verify overtime with a pending request uses the request text and is notified once | Regression | A pending overtime with a request. | 1. Notify the day twice. | 1. One notification exists, saying a request was submitted.<br>2. It links to the request in the reviewer inbox. | Day: "2026-05-06" |

### Submit and edit

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-12 | EXCP-NOTIF-HRS-REQ-012 | Verify an edit tells the reviewers who can act once and not the notify-only one | Main | A pending request with an actionable leader and a notify-only parent-team leader. | 1. Edit the request twice in a row as the employee.<br>2. Read the notifications and the history. | 1. Only the actionable leader has a notification saying the request was updated.<br>2. The second quick edit adds no second notification.<br>3. Two history entries exist, one per edit. | Request: 1 |
| TC-13 | EXCP-NOTIF-HRS-REQ-013 | Verify submitting tells the leader and the final approver and writes the submitted history | Main | A chain with the final approver at the top of the chain. | 1. Submit a request as the employee.<br>2. Read the notifications and the history. | 1. The leader and the top-of-chain final approver each have one notification linking to the request.<br>2. One history entry says it was submitted by the employee. | Request: 1 |
| TC-14 | EXCP-NOTIF-HRS-REQ-014 | Verify submitting with no leader tells the branch administrators that no approver is configured | Main | An employee with no leader and one administrator in the same branch. | 1. Submit a request as the employee. | 1. The administrator has one notification saying no approver is configured.<br>2. It links to the request. | Location: "Egypt" |

### Recipient rule details

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-NOTIF-HRS-REQ-015 | Verify the default settings notify the direct leader only | Main | Default routing settings. | 1. Work out who is notified for a two-level chain. | 1. Only the direct leader is notified. | - |
| TC-16 | EXCP-NOTIF-HRS-REQ-016 | Verify the top-of-chain final approver is notified | Main | Final approver set to the top of the chain. | 1. Work out who is notified for a three-level chain. | 1. The direct leader and the top of the chain are notified. | - |
| TC-17 | EXCP-NOTIF-HRS-REQ-017 | Verify a notification-only final approver keeps the notification and can act | Regression | Upper leaders "Notification only", final approver at the top. | 1. Work out the final approver's mode and who is notified. | 1. The final approver can act and is notified.<br>2. A "None" mode becomes "Request only" so they can act. | - |
| TC-18 | EXCP-NOTIF-HRS-REQ-018 | Verify a notification-only direct leader is notified but cannot act | Regression | Direct leaders set to "Notification only". | 1. Work out the receivers. | 1. The direct leader is notified.<br>2. They are stored as notify-only. | - |
| TC-19 | EXCP-NOTIF-HRS-REQ-019 | Verify an empty chain has no recipients and the issuer is never one | Edge | An employee with no leader; a chain that contains the employee. | 1. Work out the recipients in each case. | 1. The empty chain has no recipients.<br>2. The employee is never a recipient. | - |

### Texts

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-NOTIF-HRS-REQ-020 | Verify each text has title and message keys, an English fallback and its arguments | Regression | - | 1. Build the rejected text for "Omar", request "1007" and reason "Missing document". | 1. The keys are the rejected title and message keys.<br>2. The English text names Omar, the request number and the reason.<br>3. The arguments hold the same three values. | Request: "1007" |
| TC-21 | EXCP-NOTIF-HRS-REQ-021 | Verify the fix-day text names the sender role and lists the issues | Main | A leader and an administrator ask an employee to fix a day. | 1. Build the text for each sender with and without issue codes. | 1. The leader's text says "team leader" and the administrator's says "HR admin".<br>2. The issue codes are listed when there are any.<br>3. The two titles older apps translate by exact text stay unchanged. | Date: "2026-05-06" |
| TC-22 | EXCP-NOTIF-HRS-REQ-022 | Verify the overtime-submitted text carries the employee id that de-duplicates it | Regression | - | 1. Build the overtime-submitted text. | 1. The arguments contain the employee id and the date. | Date: "2026-05-06" |
| TC-23 | EXCP-NOTIF-HRS-REQ-023 | Verify the fix-day throttle ignores the list of problem days | Regression | A fix-day notification sent for several problem days within the last 6 hours. | 1. Ask to notify the same employee about the same day again. | 1. The second request is throttled and no second notification is sent. | Window: "6 hours" |
