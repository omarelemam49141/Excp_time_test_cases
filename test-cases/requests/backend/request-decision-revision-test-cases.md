# Request decision correction (reverse approval / approve again) — backend test cases

## Metadata
- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/Requests/revise-request-decision`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs`
- Related docs: `docs/backend/technical/request-decision-revision.md`
- Automation: `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/ReviseRequestDecisionSqliteTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestDecisionRevisionPolicyTests.cs`

## Scope

An authorized approver can reverse an approval (Approved to Pending, reason required) or approve a rejected request again. The server enforces the same routing and final-approver rules as approving, valid status transitions, blocked leave and system decisions, linked overtime state, history and notifications.

## Test scenarios

- Reversing an approval returns the request to Pending, writes history and tells the employee and the other reviewer.
- Approving a rejected request again approves it, writes history and tells the employee.
- A repeated call is refused and does not duplicate history or notifications.
- A reason is required to reverse and is length-limited; an unknown action is refused.
- Strangers, Admin off the chain, the request owner and notification-only receivers cannot correct a decision.
- With a final approver only that user can correct it.
- Wrong status, leave requests, system-made approvals and a mismatching overtime are refused.
- The linked overtime follows the request; the readiness gate still applies to approving again.

## Test cases

### Successful corrections

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQ-HRS-REVISE-001 | Verify reversing an approval returns the request to Pending with history and notifications | Main | Approved request; two actionable receivers | 1. As the leader, send ReverseApproval with a reason. | 1. Status is Pending and workflow state WaitingForManagerApproval; approver fields cleared.<br>2. One history row: actor, Approved to Pending, ApprovalReversed, reason as comment, time.<br>3. The employee gets "approval reversed" with the reason.<br>4. The other reviewer gets "pending again".<br>5. The acting leader gets nothing. | `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs`, `src/Excp.HRSystem.Application/Services/Users/Notifications/RequestNotificationTexts.cs` | - |
| TC-02 | EXCP-REQ-HRS-REVISE-002 | Verify approving a rejected request again | Main | Rejected request with a reason | 1. As a receiver, send ApproveAgain with no reason. | 1. Status Approved, state FinalApproved, approver is the actor, refusal fields cleared.<br>2. History row RejectionOverturned from Rejected to Approved.<br>3. The employee gets "approved after it was refused". | `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs` | - |
| TC-03 | EXCP-REQ-HRS-REVISE-003 | Verify a repeated correction is refused and does not duplicate history or notifications | Edge | Request already reversed once | 1. Send the same ReverseApproval again. | 1. Conflict with code RevisionNotAllowed.<br>2. No new history row and no new notification. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |

### Validation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-04 | EXCP-REQ-HRS-REVISE-004 | Verify reversing without a reason is refused | Main | Approved request | 1. Send ReverseApproval with no, empty or blank reason. | 1. Bad request "A reason is required to reverse an approval."<br>2. Nothing changed, no history, no notification. | `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs` | null, empty, spaces |
| TC-05 | EXCP-REQ-HRS-REVISE-005 | Verify a too long reason and an unknown action are refused | Edge | Approved request | 1. Send a 501-character reason.<br>2. Send action "Delete". | 1. Both are bad requests.<br>2. Nothing changed. | `src/Excp.HRSystem.Application.Contracts/Entities/Requests/FluentValidations/ReviseRequestDecisionValidation.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs` | - |

### Authorization

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-06 | EXCP-REQ-HRS-REVISE-006 | Verify a non-receiver and an Admin off the chain cannot correct a decision | Main | Approved request; a stranger leader and an Admin who are not receivers | 1. Stranger sends ReverseApproval.<br>2. Admin sends ReverseApproval. | 1. Conflict NotActionableReceiver for the stranger.<br>2. Conflict AdminNotOnRoutingChain for the Admin.<br>3. Nothing changed. | `src/Excp.HRSystem.Application/Services/Requests/DecisionBlockers.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-07 | EXCP-REQ-HRS-REVISE-007 | Verify the owner and a notification-only receiver cannot correct a decision | Main | Rejected request; the leader is notification-only | 1. The employee sends ApproveAgain.<br>2. The notification-only leader sends ApproveAgain. | 1. 403 OwnRequest.<br>2. Conflict NotifyOnlyReceiver.<br>3. Nothing changed. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-08 | EXCP-REQ-HRS-REVISE-008 | Verify only the final approver may correct when one is configured | Edge | Approved request whose final approver is leader B | 1. Leader A sends ReverseApproval.<br>2. Leader B sends ReverseApproval. | 1. Conflict WaitingForFinalApprover for A.<br>2. B succeeds and the request is Pending. | `src/Excp.HRSystem.Application/Services/Requests/DecisionBlockers.cs` | - |
| TC-09 | EXCP-REQ-HRS-REVISE-009 | Verify the endpoint is restricted to Admin and Leader roles | Main | - | 1. Inspect the endpoint authorization. | 1. The role filter is present on the endpoint. | `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs` | - |

### Invalid status and blocked requests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-10 | EXCP-REQ-HRS-REVISE-010 | Verify a correction that does not match the status is refused | Main | Requests in Pending, Cancelled, Rejected, Approved | 1. Send ReverseApproval on Pending, Cancelled, Rejected.<br>2. Send ApproveAgain on Pending, Cancelled, Approved. | 1. Each is a conflict RevisionNotAllowed with the status message.<br>2. Nothing changed. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | six combinations |
| TC-11 | EXCP-REQ-HRS-REVISE-011 | Verify a leave decision cannot be changed | Main | Approved and Rejected leave requests | 1. Send ReverseApproval on the approved leave.<br>2. Send ApproveAgain on the rejected leave. | 1. Both are refused with "A leave decision cannot be changed here…".<br>2. Status unchanged, no history. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-12 | EXCP-REQ-HRS-REVISE-012 | Verify an approval made by the system cannot be reversed | Main | Approved request without an approver (system) | 1. Send ReverseApproval. | 1. Refused with the "approved automatically by the system" message.<br>2. Nothing changed. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |

### Linked overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-13 | EXCP-REQ-HRS-REVISE-013 | Verify the linked overtime follows the correction | Main | Approved request with an Approved overtime | 1. Reverse the approval.<br>2. Refuse the request, then approve it again. | 1. The overtime becomes Pending after the reversal.<br>2. The overtime becomes Approved after approving again. | `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs` | - |
| TC-14 | EXCP-REQ-HRS-REVISE-014 | Verify approving overtime again is blocked by the readiness gate | Edge | Rejected request with a Rejected overtime; employee must fix the attendance day | 1. Send ApproveAgain. | 1. Conflict with the readiness result.<br>2. Request and overtime stay Rejected; no history. | `src/Excp.HRSystem.Application/Builders/Services/Requests/ReviseRequestDecisionBuilder.cs` | - |
| TC-15 | EXCP-REQ-HRS-REVISE-015 | Verify a correction is blocked when the overtime is not in the matching status | Edge | Approved request whose overtime is within the gap | 1. Send ReverseApproval. | 1. Refused with the "linked overtime is no longer in the status this change needs" message.<br>2. Request stays Approved; overtime unchanged. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |

### Pure policy and advisory flags

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-16 | EXCP-REQ-HRS-REVISE-016 | Verify an actionable receiver may reverse and approve again | Main | - | 1. Check both actions for actionable receivers. | 1. Both allowed. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-17 | EXCP-REQ-HRS-REVISE-017 | Verify a status that does not match the action is refused | Main | - | 1. Check the six non-matching status and action pairs. | 1. Each is refused with RevisionNotAllowed and not forbidden. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-18 | EXCP-REQ-HRS-REVISE-018 | Verify strangers, Admin off the chain, notification-only and the owner are refused | Main | - | 1. Check each user type. | 1. Codes NotActionableReceiver, AdminNotOnRoutingChain, NotifyOnlyReceiver and OwnRequest (forbidden). | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-19 | EXCP-REQ-HRS-REVISE-019 | Verify a configured final approver is the only one who may correct the decision | Edge | - | 1. Check the final approver and another receiver. | 1. The final approver is allowed.<br>2. The other receiver gets WaitingForFinalApprover. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
| TC-20 | EXCP-REQ-HRS-REVISE-020 | Verify leave, system decisions and a mismatching overtime are never corrected | Edge | - | 1. Check a leave request, a system approval, an auto-approved request and overtime states. | 1. All refused except an Approved overtime, which is allowed. | `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionRevisionPolicy.cs` | - |
