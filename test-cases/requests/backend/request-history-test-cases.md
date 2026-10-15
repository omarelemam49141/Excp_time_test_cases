# Request History Coverage — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/create`, `PUT /api/Requests/update`, `POST /api/Requests/change-reqeust-status`, `POST /api/Requests/bulk-change-request-status`, `PATCH /api/Requests/cancel-reqeust`, `DELETE /api/Requests/cancel-my-request`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestHistoryWriter.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CreateRequestBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/UpdateRequestBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CancelRequestBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Controllers/Requests/CancelMyRequestBuilder.cs`, `src/Excp.HRSystem.Domain/Entities/History/RequestHistories/RequestHistory.cs`
- Related docs: `docs/backend/technical/request-history-audit.md`
- Automation: `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/RequestHistoryWriterSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/RequestDecisionSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/CreateRequestSqliteTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/UpdateRequestSqliteTests.cs`

## Scope

This document covers the audit trail of a request: who did what, when and why, for submitting, editing, deciding and cancelling. The actor is always the signed-in user, and the history is saved or rolled back together with the change it records.

The automated tests run the real services against a real SQLite database. The steps below are the end-to-end check on the live API.

## Test pages

- `/my-requests`
- `/admin-leader/list-requests`

## Test scenarios

- Every state change writes one history entry with the signed-in actor.
- An overtime that has no request is recorded by its overtime number.
- A rolled-back change leaves no history.

## Test cases

### History rows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-HISTORY-001 | Verify an overtime-only decision is saved with the overtime number and the reason | Main | A pending overtime with no request. | 1. Refuse it as its direct leader with the reason `"Missing work description"`.<br>2. Read the history of the overtime. | 1. One history entry exists with no request and the overtime number.<br>2. The actor is the leader.<br>3. The action is a refusal by a leader and the comment is the reason without extra spaces. | Overtime: 1 |
| TC-02 | EXCP-REQ-HRS-HISTORY-002 | Verify a history entry needs a request or an overtime and an actor | Regression | - | 1. Try to save a history entry with neither a request nor an overtime. | 1. The entry is refused.<br>2. Nothing is saved. | - |
| TC-03 | EXCP-REQ-HRS-HISTORY-003 | Verify an approval writes a history entry without a comment and tells the employee | Main | A pending request the signed-in leader can decide. | 1. Send `POST /api/Requests/change-reqeust-status` with "Approved".<br>2. Read the history and the notifications. | 1. One history entry exists with the action "approved by a leader" and no comment.<br>2. The employee has one "Request approved" notification. | Request: 1 |
