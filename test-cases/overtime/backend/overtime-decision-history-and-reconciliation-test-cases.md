# Overtime Decision History and Gap Reconciliation — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `overtime`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/attendance-overtime/Accept-overtime`, `POST /api/attendance-overtime/Refuse-overtime`, `POST /api/attendance-overtime/Request-overtime`, `POST /api/attendance-overtime/End-overtime`
- Related code: `src/Excp.HRSystem.Application/Builders/Shared/ChangeOverTimeStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Services/Attendance Overtime App/OvertimeGapDayReconciliationAppService.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestHistoryWriter.cs`
- Related docs: `docs/backend/technical/request-history-audit.md`
- Automation: `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/OvertimeDecisionSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/GapReconciliationSqliteTests.cs`

## Scope

This document covers the audit trail and the employee notification of an overtime decision, and the rule that the overtime gap reconciliation never overwrites or deletes a request that was already decided.

## Test pages

- `/admin-leader/list-requests`

## Test scenarios

- Refusing an overtime without a request is audited and the employee gets the reason.
- Refusing an overtime with a request rejects the request with the reason and audits both.
- A decided or cancelled request survives the gap reconciliation.

## Test cases

### Decision history

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-OT-HRS-HISTORY-001 | Verify refusing an overtime without a request is audited by overtime number and notifies the employee with the reason | Main | A pending overtime of 2026-05-06 with no request. The signed-in leader is its direct leader. | 1. Send `POST /api/attendance-overtime/Refuse-overtime` with the reason `"Work description missing"`.<br>2. Read the history and the employee's notifications. | 1. One history entry has no request and the overtime number, the leader as actor and the reason as comment.<br>2. The employee has one notification with the reason and the date "2026-05-06", linking to "/my-requests".<br>3. The employee's screen receives it after the decision is saved. | Overtime: 1 |
| TC-02 | EXCP-OT-HRS-HISTORY-002 | Verify refusing an overtime with a request rejects the request with the reason and audits both | Main | A pending overtime with a pending request; the leader is an actionable receiver. | 1. Send `Refuse-overtime` with the reason `"Not approved by plan"`.<br>2. Read the request, the history and the notification. | 1. The request is rejected with the reason and the leader as the person who rejected it.<br>2. The history entry has the request, the overtime number, "pending" to "rejected" and the reason.<br>3. The notification links to the request. | Overtime: 1 |
| TC-03 | EXCP-OT-HRS-HISTORY-003 | Verify a refusal without a reason writes nothing and sends nothing | Regression | A pending overtime. | 1. Send `Refuse-overtime` with a reason of only spaces. | 1. The call returns a bad request response.<br>2. No history entry, no notification and no screen push exist. | Overtime: 1 |
| TC-04 | EXCP-OT-HRS-HISTORY-004 | Verify accepting an overtime is audited without a comment and notifies the employee | Main | A pending overtime with a pending request. | 1. Send `POST /api/attendance-overtime/Accept-overtime`.<br>2. Read the history and the notification. | 1. The history entry is an approval by a leader without a comment.<br>2. The employee gets an "Overtime request approved" notification. | Overtime: 1 |

### Gap reconciliation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-OT-HRS-RECONCILE-001 | Verify a pending request of an overtime that falls inside the allowed gap is approved by the system and audited | Main | A pending overtime request whose overtime now falls inside the allowed gap. | 1. Run the day reconciliation for the employee.<br>2. Read the request and its history. | 1. The request is approved and final.<br>2. No person is shown as the approver.<br>3. One history entry says the system did it, with the comment "OvertimeWithinGap". | Overtime: 1 |
| TC-06 | EXCP-OT-HRS-RECONCILE-002 | Verify a decided or cancelled request is never overwritten by the reconciliation | Regression | Three overtimes inside the allowed gap whose requests are rejected, cancelled and approved. | 1. Run the day reconciliation for each employee day. | 1. Each request keeps its status.<br>2. No history entry is added. | Statuses: rejected, cancelled, approved |
| TC-07 | EXCP-OT-HRS-RECONCILE-003 | Verify a decided request is kept and no second request is created when the overtime becomes pending again | Regression | An overtime that became pending again whose request is approved or rejected. | 1. Run the day reconciliation. | 1. The original request still exists with its status.<br>2. No second request is created.<br>3. No history entry is added. | Statuses: approved, rejected |
