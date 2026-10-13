# Approval inbox visibility — backend test cases

## Metadata
- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status`, `POST /api/Requests/get-requests-paged-filtered-list`
- Related code: `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs`
- Related docs: `docs/backend/technical/get-overtimes-by-leader-id-and-status-scope.md`
- Automation: `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/ApprovalInboxVisibilitySqliteTests.cs`

## Scope

The leader approval inbox (pending overtime queue) lists only overtime the user can decide: an actionable receiver of the linked, still Pending request, or the current direct leader when the overtime has no request at all. Admin, the employee's own list, the generic request list, request details and approve/reject keep their own rules and server-side checks.

## Test scenarios

- An actionable receiver sees the row; an unrelated user does not.
- A leader who is only the employee's `LeaderId` does not see an overtime whose request routes to someone else or to nobody.
- A notification-only receiver does not see the row.
- Both leader sources see it; one user from both sources sees it once.
- A configured final approver keeps the restricted approval; other actionable receivers still see the row.
- A request that can no longer be decided hides its pending overtime.
- Legacy overtime without a request stays visible to the current direct leader only.
- Admin unscoped list, the employee's own list and the generic request list are unchanged; opening and deciding stay authorized on the server.

## Test cases

### Inbox rows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQ-HRS-INBOX-001 | Verify an actionable receiver sees the row and an unrelated user does not | Main | Pending overtime whose request has the leader as an actionable receiver | 1. List the pending queue for the leader.<br>2. List it for two unrelated leaders. | 1. The leader gets the overtime.<br>2. The unrelated users get nothing. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs`, `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/AttendanceOverTimeRepository.cs` | - |
| TC-02 | EXCP-REQ-HRS-INBOX-002 | Verify the LeaderId leader does not see an overtime routed to somebody else | Main | The employee's `LeaderId` is leader A; the request's only receiver is leader B | 1. List the pending queue for A.<br>2. List it for B. | 1. A gets nothing.<br>2. B gets the overtime. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | - |
| TC-03 | EXCP-REQ-HRS-INBOX-003 | Verify an overtime whose request has no receivers is in nobody's inbox | Main | Pending overtime with a request that has no receivers (the request 517 shape) | 1. List the pending queue for the `LeaderId` leader and another leader. | 1. Both lists are empty. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | Request 517 shape |
| TC-04 | EXCP-REQ-HRS-INBOX-004 | Verify a notification-only receiver does not see the row | Main | The `LeaderId` leader is a notification-only receiver; another leader is actionable | 1. List the pending queue for both. | 1. The notification-only leader gets nothing.<br>2. The actionable leader gets the overtime. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | - |
| TC-05 | EXCP-REQ-HRS-INBOX-005 | Verify both leader sources see the row and one user from both sources sees it once | Main | Two leaders as actionable receivers; a second request routed twice for the same user | 1. List the queue for each leader.<br>2. Ensure routing twice for a same-user case and list the queue. | 1. Each leader gets the overtime.<br>2. The same user gets exactly one row. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplier.cs` | - |

### Rules that must hold

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-06 | EXCP-REQ-HRS-INBOX-006 | Verify a final approver keeps the restricted approval while other actionable receivers still see the row | Edge | Request with a final approver and another actionable receiver | 1. List the queue for both.<br>2. Check approve and reject for both. | 1. Both see the row.<br>2. Only the final approver can approve.<br>3. The other receiver can reject.<br>4. A stranger sees nothing. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs`, `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | - |
| TC-07 | EXCP-REQ-HRS-INBOX-007 | Verify a pending overtime whose request is no longer Pending is not in the inbox | Edge | Pending overtime whose request is Approved, Rejected or Cancelled | 1. List the pending queue for the receiver. | 1. The list is empty. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | Approved, Rejected, Cancelled |
| TC-08 | EXCP-REQ-HRS-INBOX-008 | Verify a legacy overtime without a request is visible only to the current direct leader | Edge | Pending overtime with no linked request | 1. List the queue for the direct leader and two other leaders. | 1. Only the direct leader gets the overtime. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | - |
| TC-09 | EXCP-REQ-HRS-INBOX-009 | Verify the All-status inbox applies the same rule to pending rows and keeps decided rows by snapshot leader | Edge | One decidable pending overtime, one routed elsewhere, one decided overtime | 1. List the queue with status All for the leader. | 1. The decidable and the decided overtime are listed.<br>2. The pending one routed elsewhere is not. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/OvertimeApproverScope.cs` | - |

### Unchanged behavior

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-10 | EXCP-REQ-HRS-INBOX-010 | Verify the unscoped admin list and the employee's own list still show every overtime | Main | Overtime with no receivers and overtime routed to another leader | 1. List the queue without a leader filter.<br>2. List the employee's own pending overtime. | 1. Admin list contains both.<br>2. The employee's list contains both. | `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/AttendanceOverTimeRepository.cs` | - |
| TC-11 | EXCP-REQ-HRS-INBOX-011 | Verify the generic request list keeps its receiver scope and the unscoped list shows all | Main | Two pending requests routed to different leaders | 1. List with the leader as receiver.<br>2. List with an unrelated receiver.<br>3. List without a receiver filter. | 1. Only the leader's request is returned.<br>2. The unrelated receiver gets nothing.<br>3. The unscoped list returns both. | `src/Excp.HRSystem.EntityFrameworkCore/Requests/Repositories/RequestRepository.cs` | - |
| TC-12 | EXCP-REQ-HRS-INBOX-012 | Verify opening and deciding stay authorized on the server | Main | Request routed to leader B; the employee's `LeaderId` is leader A | 1. Check read access and approve routing for A.<br>2. Check the same for B and for an Admin. | 1. A cannot read and is refused as not actionable.<br>2. B can read and approve.<br>3. An Admin can read. | `src/Excp.HRSystem.Application/Services/Requests/RequestReadAccess.cs`, `src/Excp.HRSystem.Application/Services/Requests/DecisionBlockers.cs` | - |
