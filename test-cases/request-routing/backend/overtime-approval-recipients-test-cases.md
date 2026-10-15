# Overtime approval recipients — backend test cases

## Metadata
- Project: `excp-time`
- Feature: `request-routing`
- Layer: `backend`
- Routes: `-`
- APIs: `-`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs`
- Related docs: `docs/backend/technical/request-routing-settings.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestRoutingOrgParentPolicyTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/OvertimeApprovalRoutingSqliteTests.cs`

## Scope

Every Pending overtime request gets the issuer's direct `LeaderId` leader and the issuer's primary organizational-structure parent as independent approval recipients. Either actionable recipient can approve or reject alone. Covers the shared routing method, every overtime-request creation path, notifications for requests created by reconciliation, and the read-only repair preview.

## Test scenarios

- The direct leader is a recipient even with no organizational-structure data (the request 517 shape).
- A different primary organizational-structure parent is added next to the direct leader.
- The same user from both sources is one recipient.
- A missing or deleted org node never blocks the direct leader. A RoutingMode stored on the org parent is ignored, so None on that person does not drop them.
- A null personal mode follows the configured direct mode.
- A notification-only recipient cannot act and is upgraded in place when routing requires it to act; an actionable one is never downgraded or duplicated.
- With no final approver either leader decides alone; a configured final approver keeps the restricted approval.
- Requests created by end work, reconciliation and full rebuild have their receivers, and the reviewers are notified once.
- The repair preview shows the proposed recipients and writes nothing.

## Test cases

### Recipients

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQUEST-ROUTING-020 | Verify the direct leader is added when the issuer has no org-structure node | Main | Pending overtime request with no receivers; issuer has `LeaderId`; no org-structure data; no routing settings | 1. Ensure routing for the request. | 1. One actionable receiver: the direct leader.<br>2. The final approver stays empty. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` | Request 517 shape |
| TC-02 | EXCP-REQUEST-ROUTING-021 | Verify a different primary org-structure parent is added next to the direct leader | Main | Issuer has a primary org parent that differs from the direct leader | 1. Ensure routing for the request. | 1. Two actionable level-1 receivers: the direct leader and the org parent. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs`, `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-03 | EXCP-REQUEST-ROUTING-022 | Verify one user from both sources is one actionable receiver | Edge | The org parent is the direct leader | 1. Ensure routing for the request. | 1. One receiver row, actionable. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs`, `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-04 | EXCP-REQUEST-ROUTING-023 | Verify a soft-deleted org node does not block the direct leader | Edge | The issuer's org node is soft-deleted | 1. Ensure routing for the request. | 1. Only the direct leader is a receiver. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` | - |
| TC-05 | EXCP-REQUEST-ROUTING-024 | Verify a null personal mode follows the configured direct mode | Edge | Global direct mode is NotificationOnly; org parent has no personal mode | 1. Ensure routing for the request. | 1. The org parent receiver is notification-only. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` | - |
| TC-06 | EXCP-REQUEST-ROUTING-025 | Verify a stored None mode on the org parent does not drop that person | Edge | The org parent node has RoutingMode None; company direct mode is the default Both | 1. Ensure routing for the request. | 1. The direct leader is a receiver.<br>2. The org parent is also a receiver.<br>3. The stored None mode is ignored. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs` | - |
| TC-07 | EXCP-REQUEST-ROUTING-026 | Verify a notification-only receiver is upgraded in place | Main | The direct leader is an existing notification-only receiver | 1. Ensure routing for the request. | 1. The same row becomes actionable.<br>2. No second row. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
| TC-08 | EXCP-REQUEST-ROUTING-027 | Verify an existing actionable receiver is not duplicated or downgraded and a second run changes nothing | Edge | Direct mode is NotificationOnly; the leader is already actionable | 1. Ensure routing twice. | 1. Still one actionable row.<br>2. Nothing added the second time. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |

### Approval

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-09 | EXCP-REQUEST-ROUTING-028 | Verify either actionable leader can approve and reject alone and a notification-only one cannot | Main | Request with two actionable leaders; another with one notification-only receiver | 1. Check approve and reject for each leader.<br>2. Check the notification-only receiver. | 1. Both actionable leaders can approve and reject; no blocker.<br>2. The notification-only receiver cannot. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs`, `src/Excp.HRSystem.Application/Services/Requests/DecisionBlockers.cs` | - |
| TC-10 | EXCP-REQUEST-ROUTING-029 | Verify a configured final approver keeps the restricted approval | Edge | Global final approver mode is TopOfChain; org parent also present | 1. Ensure routing.<br>2. Check approve and reject for each user. | 1. Only the final approver can approve.<br>2. The other recipients can reject. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs` | - |

### Creation paths

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-11 | EXCP-REQUEST-ROUTING-030 | Verify an end-work-created request has both leaders as receivers and notifies them once | Main | Pending overtime with no request; leader and org parent differ | 1. Run the end-work reconciliation.<br>2. Run it again. | 1. One request with two actionable receivers.<br>2. Each reviewer is notified once, for that request.<br>3. The second run adds no request and no notification. | `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeGapDayReconciliationAppService.cs`, `src/Excp.HRSystem.Application/Services/Requests/PendingOvertimeNotifier.cs` | - |
| TC-12 | EXCP-REQUEST-ROUTING-031 | Verify a reconciliation-created request gets its receivers | Main | Overtime is Pending again and has no request | 1. Run the reconciliation sync. | 1. A request exists with the direct leader as an actionable receiver. | `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeGapDayReconciliationAppService.cs` | - |
| TC-13 | EXCP-REQUEST-ROUTING-032 | Verify a full rebuild replacement has the receivers and the cancelled request is not notified | Main | Two overtime segments that must merge; the old Pending request has receivers | 1. Run the day reconciliation. | 1. The old request is soft-deleted.<br>2. One new Pending request with both leaders as receivers.<br>3. Notifications only for the new request. | `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeGapDayReconciliationAppService.cs` | - |

### Repair preview

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-14 | EXCP-REQUEST-ROUTING-033 | Verify the repair preview of a request without receivers shows the recipients and writes nothing | Main | Fixture shaped like request 517 | 1. Preview by request number. | 1. The direct leader is proposed as actionable with source DirectLeaderChain.<br>2. The missing org version is listed as omitted.<br>3. The final approver would not change.<br>4. No receiver was written. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingRepairPreviewService.cs` | - |
| TC-15 | EXCP-REQUEST-ROUTING-034 | Verify the repair preview keeps an org parent whose stored mode is None | Edge | Org parent has RoutingMode None | 1. Preview by request number. | 1. The direct leader is proposed.<br>2. The org parent is proposed too.<br>3. The org parent is not omitted with reason "RoutingModeNone".<br>4. Nothing was written. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingRepairPreviewService.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` | - |
| TC-16 | EXCP-REQUEST-ROUTING-035 | Verify the repair preview of an unknown request reports not found | Edge | - | 1. Preview an unknown request number. | 1. The result says not found with no recipients. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingRepairPreviewService.cs` | - |

### Pure routing rules

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-17 | EXCP-REQUEST-ROUTING-036 | Verify the direct leader and a different org parent are two actionable level-1 recipients | Main | - | 1. Build the resolution. | 1. Two hops at level 1, both actionable and notified, with the right sources. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-18 | EXCP-REQUEST-ROUTING-037 | Verify the same user from both sources is one recipient with both sources | Edge | - | 1. Build the resolution. | 1. One hop carrying both source flags. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-19 | EXCP-REQUEST-ROUTING-038 | Verify the resolution without an org parent is exactly the leader chain | Edge | - | 1. Build the resolution with no org parent. | 1. Same hops as before.<br>2. Passed omissions are kept. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-20 | EXCP-REQUEST-ROUTING-039 | Verify an org parent with mode None is not a receiver and the direct leader stays | Edge | - | 1. Build the resolution. | 1. The org hop has mode None and creates no receiver. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
| TC-21 | EXCP-REQUEST-ROUTING-040 | Verify a null personal mode of the org parent follows the direct mode | Edge | - | 1. Build with and without a personal mode. | 1. Null follows the policy.<br>2. A personal mode wins. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-22 | EXCP-REQUEST-ROUTING-041 | Verify a notification-only recipient cannot approve or reject | Edge | - | 1. Build with the org parent notification-only. | 1. The org parent cannot approve or reject.<br>2. The direct leader can approve. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-23 | EXCP-REQUEST-ROUTING-042 | Verify either actionable leader decides alone when there is no final approver | Main | - | 1. Check approve and reject for both leaders and a stranger. | 1. Both leaders can approve and reject.<br>2. A stranger cannot. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-24 | EXCP-REQUEST-ROUTING-043 | Verify a configured final approver still restricts approval | Edge | Final approver mode TopOfChain | 1. Build with chain and org parent. | 1. Final approver is on the leader chain.<br>2. Only that user approves; the others can reject. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-25 | EXCP-REQUEST-ROUTING-044 | Verify an org parent already on the chain keeps every ability either source gives | Edge | - | 1. Build with the org parent equal to an upper chain user.<br>2. Merge modes. | 1. One hop with the combined mode.<br>2. Merging never removes an ability. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-26 | EXCP-REQUEST-ROUTING-045 | Verify the org parent's ancestors are never added | Edge | - | 1. Build with chain and org parent. | 1. Only the leader and the org parent are hops. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-27 | EXCP-REQUEST-ROUTING-046 | Verify the plan adds missing recipients and never duplicates existing ones | Main | - | 1. Plan with an existing leader receiver. | 1. Only the org parent is added. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
| TC-28 | EXCP-REQUEST-ROUTING-047 | Verify the plan upgrades a notification-only receiver and never downgrades | Main | - | 1. Plan an upgrade.<br>2. Plan a would-be downgrade. | 1. The existing row is updated to actionable.<br>2. The actionable row is kept. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
| TC-29 | EXCP-REQUEST-ROUTING-048 | Verify the final approver is filled only when the request has none | Edge | - | 1. Plan for a request without and with a final approver. | 1. Filled when empty.<br>2. Never overwritten. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
