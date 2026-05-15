# Request Review Locking API — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/request-review-locks/states`, `POST /api/request-review-locks/lock-items`, `POST /api/request-review-locks/unlock-items`, `POST /api/request-review-locks/renew-items`, `POST /api/request-review-locks/lock-current-view`, `Generic request update/cancel APIs`, `Overtime update/delete APIs`, `Quick entry save API`, `Request and overtime approve/refuse APIs`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

This document covers the backend APIs and server-side guards that lock pending requests during leader review, block employee changes while locked, release locks after decisions, and expire stale locks.

## Test pages

- `POST /api/request-review-locks/states`
- `POST /api/request-review-locks/lock-items`
- `POST /api/request-review-locks/unlock-items`
- `POST /api/request-review-locks/renew-items`
- `POST /api/request-review-locks/lock-current-view`
- Generic request update/cancel APIs
- Overtime update/delete APIs
- Quick entry save API
- Request and overtime approve/refuse APIs

## Test scenarios

- Leader reads, creates, renews, and removes review locks.
- Locked requests reject employee edit and delete attempts.
- Locked overtime rejects employee quick-entry and overtime edit/delete attempts.
- Leader decisions release locks.
- Stale locks expire and no longer block employee changes.

## Test cases

### Lock API

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-REQUEST-REVIEW-001 | Verify an unlocked pending request returns an unlocked state | Main | A pending request exists for a leader and has no active review lock. | 1. Sign in as the leader.<br>2. Send `POST /api/request-review-locks/states` for the pending request. | 1. API returns success.<br>2. The response for the request has `"isLocked": false`. | Request id: "pending-request-id" |
| TC-02 | EXCP-REQ-HRS-REQUEST-REVIEW-002 | Verify a leader can lock a selected pending request | Main | Same as TC-01. | 1. Sign in as the leader.<br>2. Send `POST /api/request-review-locks/lock-items` for the pending request.<br>3. Send `POST /api/request-review-locks/states` for the same request. | 1. The lock call returns success.<br>2. The state response has `"isLocked": true`.<br>3. The state response has `"isLockedByCurrentUser": true`. | Request id: "pending-request-id" |
| TC-03 | EXCP-REQ-HRS-REQUEST-REVIEW-003 | Verify a leader can unlock a selected pending request | Main | Same as TC-02 and the request is locked by the signed-in leader. | 1. Send `POST /api/request-review-locks/unlock-items` for the pending request.<br>2. Send `POST /api/request-review-locks/states` for the same request. | 1. The unlock call returns success.<br>2. The state response has `"isLocked": false`. | Request id: "pending-request-id" |
| TC-04 | EXCP-REQ-HRS-REQUEST-REVIEW-004 | Verify lock renewal keeps a selected request locked | Edge | A pending request is locked by the signed-in leader. | 1. Send `POST /api/request-review-locks/renew-items` for the locked request.<br>2. Send `POST /api/request-review-locks/states` for the same request. | 1. The renewal call returns success.<br>2. The state response still has `"isLocked": true`.<br>3. The expiry time is later than the time returned before renewal. | Request id: "pending-request-id" |
| TC-05 | EXCP-REQ-HRS-REQUEST-REVIEW-005 | Verify current-view locking locks pending requests that match the leader filter | Main | The leader has multiple pending requests visible with the same search text. | 1. Sign in as the leader.<br>2. Send `POST /api/request-review-locks/lock-current-view` with the same status and search text used by the leader inbox.<br>3. Send `POST /api/request-review-locks/states` for the matching requests. | 1. API returns success.<br>2. Matching pending requests have `"isLocked": true`.<br>3. Requests outside the filter do not become locked by this call. | Status: "Pending"<br>Search: "direct report" |

### Mutation Guards

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-REQ-HRS-REQUEST-REVIEW-006 | Verify employee generic request update is blocked while locked | Regression | A pending generic request is locked by the leader and belongs to the employee. | 1. Sign in as the employee.<br>2. Send the normal request update API for the locked request. | 1. API returns a conflict response.<br>2. The response message is `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`<br>3. A later read shows the request details did not change. | Request id: "pending-request-id" |
| TC-07 | EXCP-REQ-HRS-REQUEST-REVIEW-007 | Verify employee request cancel is blocked while locked | Regression | A pending request is locked by the leader and belongs to the employee. | 1. Sign in as the employee.<br>2. Send the normal request cancel API for the locked request. | 1. API returns a conflict response.<br>2. The response message is `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`<br>3. A later read still shows the request as pending. | Request id: "pending-request-id" |
| TC-08 | EXCP-REQ-HRS-REQUEST-REVIEW-008 | Verify employee overtime update is blocked while locked | Regression | A pending overtime entry is locked by the leader and belongs to the employee. | 1. Sign in as the employee.<br>2. Send the normal overtime update API for the locked overtime. | 1. API returns a conflict response.<br>2. The response message is `"This request is currently being reviewed by your leader. Please try again after it is unlocked."`<br>3. A later read shows the overtime times did not change. | Overtime id: "123"<br>Start: "18:00"<br>End: "20:00" |
| TC-09 | EXCP-REQ-HRS-REQUEST-REVIEW-009 | Verify quick entry save is blocked for a locked overtime entry | Regression | A pending overtime entry is locked by the leader and belongs to the employee. | 1. Sign in as the employee.<br>2. Send the quick entry save API with a changed start or end time for the locked overtime. | 1. API returns a validation conflict.<br>2. The response includes a lock conflict message for the overtime entry.<br>3. A later read shows the overtime times did not change. | Date: "2026-05-06"<br>Overtime id: "123" |

### Decision And Expiry

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-REQ-HRS-REQUEST-REVIEW-010 | Verify a leader can approve a request locked by the same leader | Main | A pending request is locked by the signed-in leader. | 1. Sign in as the same leader.<br>2. Send the normal approve API for the locked request.<br>3. Send `POST /api/request-review-locks/states` for the same request. | 1. The approve API returns success.<br>2. A later read shows the request as approved.<br>3. The lock state has `"isLocked": false`. | Request id: "pending-request-id" |
| TC-11 | EXCP-REQ-HRS-REQUEST-REVIEW-011 | Verify a different reviewer cannot decide a request locked by another reviewer | Edge | A pending request is locked by one reviewer and another authorized reviewer can access the same request. | 1. Sign in as the second reviewer.<br>2. Send the normal approve or refuse API for the locked request. | 1. API returns a conflict response.<br>2. The response message is `"This request is locked by another reviewer. Please reload before taking action."`<br>3. A later read shows the request is still pending. | Request id: "pending-request-id" |
| TC-12 | EXCP-REQ-HRS-REQUEST-REVIEW-012 | Verify stale locks expire and no longer block employee changes | Edge | A pending request is locked and renewal has stopped. | 1. Wait longer than the review lock lifetime.<br>2. Sign in as the employee.<br>3. Send the normal request update API for the same request. | 1. API does not reject the change because of the old lock.<br>2. The update succeeds when all normal request validation passes.<br>3. A later lock state call has `"isLocked": false. | Request id: "pending-request-id" |
