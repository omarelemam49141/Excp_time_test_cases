# Overtime Review Scope Follows Routing — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/attendance-overtime/Check-overtime-review-readiness`, `POST /api/AttendanceOverTime/Accept-overtime`, `POST /api/AttendanceOverTime/Refuse-overtime`, `POST /api/request-review-locks/lock-items`, `POST /api/request-review-locks/lock-current-view`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/ReviewScopeRules.cs`, `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeReviewReadinessAppService.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestReviewLockService.cs`
- Related docs: `docs/backend/technical/overtime-review-readiness-guard.md`, `docs/backend/technical/request-review-locking.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/ReviewScopeRulesTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/ReviewScopeSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/TopOfChainOvertimeApprovalSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/SqlServerLocalDbReadinessSmokeTests.cs`

## Scope

This document covers who may open a pending overtime for review (readiness check and review lock): the same people the request routing lets decide it, at any level of the team chain.

The automated tests cover the scope rule and the readiness result; the database-backed cases (TC-05 to TC-10) run against a real SQLite database. The steps below are the end-to-end API check on a real chain.

## Test pages

- `/admin-leader/list-requests`

## Test scenarios

- The direct leader, the parent-team leader and the final approver can review an overtime that has a linked request.
- A leader outside the routing chain, and a notify-only hop, cannot.
- An overtime with no linked request is reviewed only by the direct leader.
- A refused reviewer is told it is a reviewer-side problem and is never asked to notify the employee.

## Test cases

### Review scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-REVIEW-READINESS-038 | Verify the direct leader and upper-chain leaders can check and lock a linked overtime | Main | An employee in a child team; a pending overtime linked to a pending request whose receivers are the direct leader (level 1), the parent-team leader (level 2) and the grandparent-team leader (level 3, final approver); all three actionable. | 1. Sign in as each of the three leaders in turn.<br>2. Send `Check-overtime-review-readiness` for the overtime.<br>3. Send `POST /api/request-review-locks/lock-items` for the overtime. | 1. The readiness result is not refused for scope for any of the three.<br>2. Each lock call succeeds when no other reviewer holds the lock. | Overtime id: "90" |
| TC-02 | EXCP-OT-HRS-REVIEW-READINESS-039 | Verify leaders outside the chain and notify-only hops cannot review a linked overtime | Main | Same overtime as TC-01. A leader of a sibling team. A second case where the direct leader and parent-team leader are configured as notify-only. | 1. Sign in as the sibling-team leader and send the readiness check and the lock call.<br>2. Make the direct leader notify-only, sign in as them and repeat.<br>3. Open an overtime with no linked request as its direct leader and as the parent-team leader. | 1. The sibling-team leader is refused and the lock message is `"You cannot approve or reject this request."` (not a raw key).<br>2. The notify-only direct leader is refused.<br>3. For the unlinked overtime only the direct leader is allowed. | Overtime ids: "90", "91" |
| TC-03 | EXCP-OT-HRS-REVIEW-READINESS-040 | Verify a refused reviewer gets a reviewer-side status | Regression | A leader outside the chain of a pending linked overtime. | 1. Sign in as that leader.<br>2. Send `Check-overtime-review-readiness` for the overtime. | 1. The status is `ReviewerActionRequired`, not `EmployeeActionRequired`.<br>2. The issue code is `EmployeeOutsideLeaderScope` and the decision refusal carries the code `OutsideLeaderScope`.<br>3. No notify-employee action is offered. | Overtime id: "90" |
| TC-04 | EXCP-OT-HRS-REVIEW-READINESS-041 | Verify the lock scope for requests matches routing and the admin role check is case-insensitive | Regression | A pending request whose receivers are the direct leader and a parent-team leader; an administrator whose role claim is spelled in lower case. | 1. Sign in as the parent-team leader and call `lock-current-view`.<br>2. Sign in as the lower-case-role administrator and lock the request. | 1. The parent-team leader's current view includes the request and the lock succeeds.<br>2. The administrator can lock it. | Request id: "req-90" |

### Database-backed scope checks

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-OT-HRS-REVIEW-READINESS-042 | Verify an upper-chain receiver can lock a request they are not the direct leader of | Main | A pending request whose receivers are the direct leader (level 1) and the parent-team leader (level 2, final approver), both actionable. | 1. Sign in as the parent-team leader.<br>2. Send `POST /api/request-review-locks/lock-items` for the request. | 1. The request is locked.<br>2. The lock belongs to the signed-in leader. | Request id: "req-90" |
| TC-06 | EXCP-OT-HRS-REVIEW-READINESS-043 | Verify a notify-only receiver and an unrelated leader cannot lock a request | Main | The same request with the direct leader set to notify-only; a leader of another team. | 1. Sign in as the notify-only direct leader and lock the request.<br>2. Sign in as the unrelated leader and lock it. | 1. Neither lock is taken.<br>2. Both get the message `"You cannot approve or reject this request."`. | Request id: "req-90" |
| TC-07 | EXCP-OT-HRS-REVIEW-READINESS-044 | Verify a linked overtime is lockable by its actionable receivers at any level | Main | A pending overtime with a linked request as in TC-05. | 1. Sign in as the parent-team leader and lock the overtime.<br>2. Sign in as the direct leader and lock the same overtime.<br>3. Sign in as the unrelated leader and lock it. | 1. The parent-team leader holds the lock.<br>2. The direct leader sees that it is locked by the parent-team leader's name.<br>3. The unrelated leader is refused with the routing message and no lock is read. | Overtime id: "90" |
| TC-08 | EXCP-OT-HRS-REVIEW-READINESS-045 | Verify an overtime without a request is lockable only by its direct leader | Regression | A pending overtime with no linked request. | 1. Sign in as the parent-team leader and lock it.<br>2. Sign in as the direct leader and lock it. | 1. The parent-team leader cannot lock it.<br>2. The direct leader locks it. | Overtime id: "91" |
| TC-09 | EXCP-OT-HRS-REVIEW-READINESS-046 | Verify an administrator can lock outside the chain and the role check ignores letter case | Regression | An administrator whose role claim is written as `"admin"`. | 1. Sign in as that administrator and lock a request and an overtime they are not routed to. | 1. Both locks are taken. | Request id: "req-90" |
| TC-10 | EXCP-OT-HRS-REVIEW-READINESS-047 | Verify the readiness scope check passes actionable receivers at any level and refuses the rest | Main | The linked overtime of TC-05 with the direct leader notify-only; an overtime with no linked request. | 1. Run the readiness check as the parent-team leader, an administrator, the notify-only direct leader and an unrelated leader for the linked overtime.<br>2. Run it as the direct leader and as the parent-team leader for the unlinked overtime. | 1. The parent-team leader and the administrator pass the scope check.<br>2. The notify-only direct leader and the unrelated leader get the issue code `EmployeeOutsideLeaderScope`.<br>3. For the unlinked overtime only the direct leader passes. | Overtime ids: "90", "91" |
| TC-11 | EXCP-OT-HRS-REVIEW-READINESS-048 | Verify the direct leader waits for the top-of-chain final approver, who then completes the overtime approval | Main | A leader-only chain: employee, direct leader, parent leader as final approver; a pending overtime with a pending request; both leaders are actionable receivers. | 1. Sign in as the direct leader and approve the request.<br>2. Sign in as the parent leader and approve it. | 1. The direct leader is refused because the final approver must approve.<br>2. The parent leader's approval succeeds.<br>3. The request and its overtime are approved. | Request: 1 |
| TC-12 | EXCP-OT-HRS-REVIEW-READINESS-049 | Verify the day-correction procedure deploys and previews on SQL Server | Regression | A throw-away LocalDB database built from the current model; an employee with a 12-hour attendance day. | 1. Deploy the table type and the procedure.<br>2. Run the procedure in preview mode for that day. | 1. The procedure deploys and returns its summary.<br>2. Preview mode leaves no overtime entry behind. | Day: "2026-05-05" |
