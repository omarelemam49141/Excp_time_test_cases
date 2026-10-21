# Request Decision Blockers — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/change-reqeust-status`, `POST /api/Requests/bulk-change-request-status`, `POST /api/AttendanceOverTime/Accept-overtime`, `POST /api/AttendanceOverTime/Refuse-overtime`, `POST /api/Requests/get-requests-paged-filtered-list`, `POST /api/AttendanceOverTime/Get-overtimes-By-LeaderId-and-status`, `GET /api/Requests/getById`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Requests/GetRequestByIdBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/GetRequestPagedFilteredListBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Controllers/Attendance OverTimes/GetOverTimesByLeaderIdAndStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/DecisionBlockers.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Domain.Shared/Localization/HRSystem/en.json`, `src/Excp.HRSystem.Domain.Shared/Localization/HRSystem/ar.json`
- Related docs: `docs/backend/technical/request-decision-blockers.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/DecisionBlockerMappingTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionServiceWiringTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/OvertimeDecisionEndpointTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/DecisionBlockerLocalizationTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/DecisionBlockerListTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestGetByIdDecisionFlagsTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestNotificationPolicyTests.cs`

## Scope

This document covers the reason a leader or administrator gets when an approve or reject is refused: a stable error code and a blocker list next to the localized message, on the single request, bulk and overtime decision calls.

Each case is covered by automated tests that run the real decision services with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rule.

## Test pages

- `/admin-leader/list-requests`

## Test scenarios

- Every refused decision names who has to act and why.
- Single and bulk give the same code for the same situation.
- Readiness refusals keep their data and gain a code.
- Messages are available in English and Arabic.

## Test cases

### Routing and fixed gates

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-BLOCKER-001 | Verify each routing refusal names its reason | Main | One pending request per situation: the leader is not a receiver; the leader is a notify-only receiver; an administrator is not a receiver; another user is the final approver and the leader is an actionable receiver. | 1. Sign in as the leader and send `POST /api/Requests/change-reqeust-status` with "Approved" for each of the first two and the fourth request.<br>2. Sign in as the administrator and send it for the third request.<br>3. As the leader of the fourth request, send "Rejected". | 1. The responses carry the error codes `NotActionableReceiver`, `NotifyOnlyReceiver` and `WaitingForFinalApprover`; the last one names the final approver.<br>2. The administrator receives `AdminNotOnRoutingChain`.<br>3. The rejection is not refused.<br>4. Each message is specific to its reason. | Requests: 4 |
| TC-02 | EXCP-REQ-HRS-BLOCKER-002 | Verify own request, locked, already decided and HR-step refusals carry their codes | Regression | A request the signed-in user submitted; a request locked by a named reviewer; an approved request; a leave request waiting for the HR step. | 1. Send `change-reqeust-status` for each as a leader (the leave request as a leader, not an administrator). | 1. The own request returns forbidden with `OwnRequest`.<br>2. The locked request returns `LockedByOtherReviewer` and the reviewer's name.<br>3. The approved request returns `AlreadyFinalized` with a translated message and not a resource key.<br>4. The leave request returns `HrStepRequired`. | Requests: 4 |

### Readiness

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-REQ-HRS-BLOCKER-003 | Verify readiness refusals map to a code and keep their data | Regression | Overtime days in these states: employee not under the leader, pending leave covering the day, attendance problems, corrected day with a changed queue. | 1. Send `POST /api/AttendanceOverTime/Accept-overtime` for each overtime. | 1. The codes are `OutsideLeaderScope`, `PendingLeaveAwaitingDecision`, `EmployeeMustFixAttendance` and `QueueChanged`.<br>2. Each response still contains the readiness result with its issues.<br>3. A ready day is not refused. | Overtimes: 4 |
| TC-04 | EXCP-REQ-HRS-BLOCKER-004 | Verify a refusal is the old response plus two fields | Regression | Any refused decision. | 1. Send a refused decision.<br>2. Read the response body. | 1. The body still has `status`, `code`, `message` and `data`.<br>2. It also has `errorCode` and a `blockers` list with `code`, `owner`, `messageKey`, `args`, `blockingUserName` and `actionHint`.<br>3. A refusal without a mapped reason has no `errorCode`. | - |

### Single, bulk and overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-REQ-HRS-BLOCKER-005 | Verify single and bulk request decisions give the same code | Main | A pending request the leader is not a receiver of; a request with a readiness refusal. | 1. Send `change-reqeust-status` for the request.<br>2. Send `bulk-change-request-status` with the same request.<br>3. Repeat for the readiness case. | 1. Single and bulk report the same code and message key.<br>2. The readiness refusal keeps its data and gains the code.<br>3. The requests stay pending. | Requests: 2 |
| TC-06 | EXCP-REQ-HRS-BLOCKER-006 | Verify bulk items carry codes and translated messages and do not leak server errors | Regression | Bulk items: overtime not ready, overtime of a request the leader cannot decide, the leader's own overtime, a locked overtime, an already decided overtime, an unknown overtime id, an item whose save fails. | 1. Send `bulk-change-request-status` with all of them.<br>2. Send it with no items, with status "Cancelled", and with an item that has no ids. | 1. Each failed item has its code (the unknown id has none) and a translated message.<br>2. The item whose save fails shows `"This item could not be processed. Please try again."` and no technical text.<br>3. The three bad inputs return translated messages. | Overtime ids: 101, 102, 103, 111, 113, 999 |
| TC-07 | EXCP-REQ-HRS-BLOCKER-007 | Verify Accept-overtime and Refuse-overtime refusals carry codes | Regression | An overtime of the leader's own; one whose request is approved; one the leader is not a receiver of; one where the leader is notify-only; one with pending leave; one with the fixed gap status; one locked by a named reviewer. | 1. Send `POST /api/AttendanceOverTime/Accept-overtime` (and Refuse for the approved case) for each. | 1. The codes are `OwnRequest`, `AlreadyFinalized`, `NotActionableReceiver`, `NotifyOnlyReceiver`, `PendingLeaveAwaitingDecision`, `AlreadyFinalized` and `LockedByOtherReviewer`.<br>2. The locked response names the reviewer.<br>3. Nothing is changed. | Overtimes: 7 |

### Localization

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-REQ-HRS-BLOCKER-008 | Verify every blocker message exists in English and Arabic | Regression | The English and Arabic resource files. | 1. Call a refused decision once with `Accept-Language: en` and once with `ar`.<br>2. Check the bulk limit message in both. | 1. Both languages return a readable message for the same refusal and never a raw key or English text in Arabic.<br>2. The limit message shows the number 200 in both. | Languages: "en", "ar" |

### List rows (P2.2)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-REQ-HRS-BLOCKER-009 | Verify pending request rows explain why the signed-in user cannot decide | Main | Pending requests in the leader's list: one where the leader is an actionable receiver; one where the leader is not a receiver; one where the leader is notify-only; one with another final approver where the leader is a non-final receiver. An approved request. | 1. Sign in as the leader and send `POST /api/Requests/get-requests-paged-filtered-list`.<br>2. Sign in as an administrator who is not on the chain of one request and send the same call. | 1. The actionable row has an empty `decisionBlockers` list.<br>2. The other rows carry one blocker each: `NotActionableReceiver`, `NotifyOnlyReceiver`, `WaitingForFinalApprover` (the last one names the final approver).<br>3. The approved row has no blockers.<br>4. The administrator gets `AdminNotOnRoutingChain` for the request they are not on.<br>5. `currentUserCanApprove` / `currentUserCanReject` are unchanged. | Requests: 5 |
| TC-10 | EXCP-REQ-HRS-BLOCKER-010 | Verify overtime rows resolve the linked request and carry blockers | Main | Pending overtimes: one linked to a request through `RequestId` where the leader is a receiver; one linked only through the request's `OverTimeId` where the leader is not a receiver; one with no linked request whose direct leader is the signed-in user; one with no linked request and another direct leader. | 1. Send `POST /api/AttendanceOverTime/Get-overtimes-By-LeaderId-and-status` as the leader. | 1. The first and third rows have no blockers and can be decided.<br>2. The second row is resolved through the request's `OverTimeId`, has `currentUserCanApprove = false` and a `NotActionableReceiver` blocker.<br>3. The fourth row has a `NotActionableReceiver` blocker.<br>4. Overtimes that are not pending have no blockers. | Overtimes: 4 |
| TC-11 | EXCP-REQ-HRS-BLOCKER-011 | Verify opening one request returns the same decision flags as the list | Regression | A pending request the leader is not a receiver of; a pending request the leader can decide; an approved request. | 1. Send `GET /api/Requests/getById` as the leader for each request. | 1. The first response has `currentUserCanApprove` and `currentUserCanReject` set to false and a `NotActionableReceiver` blocker.<br>2. The second response has both flags true and an empty `decisionBlockers`.<br>3. The approved request has no blockers.<br>4. Other people's requests are still refused as before. | Requests: 3 |

### Who can act (Admin blocker names)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-12 | EXCP-REQ-HRS-BLOCKER-012 | Verify the Admin blocker names everyone who can refuse, and an approval names the final approver | Main | A pending request routed to a leader (level 1) and a parent-team leader (level 2, final approver). An administrator who is not on the chain. | 1. Sign in as the administrator.<br>2. Send "Approved" for the request.<br>3. Send "Rejected" for the request. | 1. The approval is refused with the code `AdminNotOnRoutingChain` and the final approver's name.<br>2. The refusal is refused with the code `AdminNotOnRoutingChain` and both names in chain order.<br>3. The message says who can decide it. | Request: 1 |
| TC-13 | EXCP-REQ-HRS-BLOCKER-013 | Verify the Admin blocker lists the actionable receivers in chain order and skips notify-only ones | Regression | A pending request with no final approver; receivers at levels 1 and 2 are actionable and level 3 is notify-only. | 1. Sign in as an administrator who is not on the chain.<br>2. Send "Rejected". | 1. The code is `AdminNotOnRoutingChain`.<br>2. The names are the level 1 and level 2 receivers, in that order.<br>3. The notify-only receiver is not named. | Request: 1 |
| TC-14 | EXCP-REQ-HRS-BLOCKER-014 | Verify the Admin blocker falls back to the unnamed message when no name can be read | Regression | A pending request whose receivers cannot be named. | 1. Sign in as an administrator not on the chain.<br>2. Send "Approved". | 1. The code is `AdminNotOnRoutingChain` with no name.<br>2. The message is the general text without a name. | Request: 1 |
