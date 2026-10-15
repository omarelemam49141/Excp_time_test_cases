# Reverse approval / Approve again — frontend test cases

## Metadata
- Project: `excp-time`
- Feature: `requests`
- Layer: `frontend`
- Routes: `/admin-leader/list-requests`, `/my-requests`
- APIs: `POST /api/Requests/revise-request-decision`, `POST /api/Requests/get-requests-paged-filtered-list`, `POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status`
- Related code: `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.ts`
- Related docs: `docs/frontend/technical/request-decision-revision.md`
- Automation: `-`

## Scope

The Actions column of the Requests tab and the Overtime tab: Pending rows keep Accept and Refuse; Approved rows can offer "Reverse approval"; Rejected rows can offer "Approve again". Confirmation dialogs, the mandatory reversal reason, Arabic and English texts, notifications and the cases where the action must not appear or must be refused.

Use two browsers for two leaders. Names: **Emp** (employee), **LeaderA** and **LeaderB** (both receive Emp's requests), **Stranger** (unrelated leader), **Admin**.

## Test scenarios

- Approved and Rejected rows show the right correction action; Pending rows do not.
- A confirmation dialog explains the consequence before anything is sent.
- Reversing needs a reason; approving again does not.
- The employee and the other reviewer are notified once, in the app language.
- Users who cannot decide do not see the actions; a refused call shows a clear localized message.
- Leave requests and system approvals are never offered for correction.
- Final approver restrictions apply.
- Overtime follows its request.

## Test cases

### Requests tab

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQ-REVISE-UI-001 | Verify Approved rows offer "Reverse approval" and Pending rows do not | Main | LeaderA approved a generic (not leave) request of Emp | 1. As LeaderA open `/admin-leader/list-requests`, Requests tab, the Accepted filter.<br>2. Look at the Actions column.<br>3. Switch to the Pending filter. | 1. The approved row shows Details and "Reverse approval".<br>2. Pending rows show Accept and Refuse only, with no correction action. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html` | Emp, LeaderA |
| TC-02 | EXCP-REQ-REVISE-UI-002 | Verify the reversal confirmation and mandatory reason | Main | TC-01 | 1. Click "Reverse approval".<br>2. Read the dialog and click Continue.<br>3. Try to confirm the reason box empty.<br>4. Type a reason and confirm. | 1. The dialog says the request returns to Pending, the employee is notified and the request waits for a decision again.<br>2. The reason box blocks an empty reason with "A reason is required".<br>3. After confirming, a success message says the approval was reversed.<br>4. The row leaves the Accepted list and appears under Pending. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.ts`, `src/app/shared/services/swal.service.ts` | - |
| TC-03 | EXCP-REQ-REVISE-UI-003 | Verify cancelling at either step changes nothing | Edge | An approved row | 1. Click "Reverse approval" and close the dialog.<br>2. Click it again, continue, then cancel the reason box. | 1. The request stays Accepted.<br>2. No notification is sent. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.ts` | - |
| TC-04 | EXCP-REQ-REVISE-UI-004 | Verify Rejected rows offer "Approve again" and it needs no reason | Main | LeaderA rejected a generic request of Emp | 1. Open the Rejected filter.<br>2. Click "Approve again".<br>3. Read the dialog and confirm. | 1. The row shows "Approve again".<br>2. The dialog says the status changes to Approved and the employee is notified.<br>3. No reason is requested.<br>4. A success message appears and the row moves to Accepted. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.ts` | Emp, LeaderA |
| TC-05 | EXCP-REQ-REVISE-UI-005 | Verify the second approver can correct and the employee is notified | Main | Emp's request approved by LeaderA; LeaderB is also an approver | 1. As LeaderB reverse the approval with a reason.<br>2. As Emp open the notification bell.<br>3. As LeaderA open the notification bell. | 1. LeaderB succeeds.<br>2. Emp sees "Approval reversed" with the reason and it opens the request in `/my-requests`.<br>3. LeaderA sees "Request is pending again".<br>4. LeaderB sees no notification about their own action. | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` | Emp, LeaderA, LeaderB |
| TC-06 | EXCP-REQ-REVISE-UI-006 | Verify the employee is notified once and sees the new status | Main | TC-04 done | 1. As Emp open the bell and `/my-requests`. | 1. One notification says the request was approved after it was refused.<br>2. The request shows Accepted.<br>3. No duplicate notification. | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` | Emp |

### Who must not see or use it

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-07 | EXCP-REQ-REVISE-UI-007 | Verify unrelated users and the request owner get no correction action | Main | An approved request of Emp | 1. As Stranger open the lists.<br>2. As Admin who is not an approver of the request open the lists.<br>3. As Emp open `/my-requests`. | 1. Stranger does not see the request in the leader inbox.<br>2. Admin sees the request without "Reverse approval".<br>3. Emp sees no correction action for their own request. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.ts` | Stranger, Admin, Emp |
| TC-08 | EXCP-REQ-REVISE-UI-008 | Verify a notification-only leader gets no action | Edge | LeaderA is notification-only for Emp; LeaderB is an approver | 1. As LeaderA open the Accepted filter. | 1. The request is not in LeaderA's inbox and has no correction action. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.ts` | LeaderA, LeaderB |
| TC-09 | EXCP-REQ-REVISE-UI-009 | Verify final approver restrictions | Edge | Company routing has a final approver (Head); Head approved Emp's request | 1. As LeaderA (not the final approver) open the Accepted filter.<br>2. As Head open the same list. | 1. LeaderA has no "Reverse approval".<br>2. Head sees "Reverse approval" and can use it. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html` | LeaderA, Head |
| TC-10 | EXCP-REQ-REVISE-UI-010 | Verify leave requests are never offered for correction | Main | An approved and a rejected leave request of Emp | 1. As the approver open the Accepted and Rejected filters. | 1. Leave rows show Details only. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html` | Leave requests |
| TC-11 | EXCP-REQ-REVISE-UI-011 | Verify a system-approved overtime request is not offered for reversal | Edge | An overtime request approved automatically (within the allowed gap) | 1. Open the Accepted filter on the Requests and Overtime tabs. | 1. The row shows no "Reverse approval". | `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.html` | - |
| TC-12 | EXCP-REQ-REVISE-UI-012 | Verify a stale row shows the server's reason in the app language | Edge | An approved row open in two windows | 1. In window 1 reverse the approval.<br>2. In window 2 (not refreshed) click "Reverse approval" and confirm with a reason. | 1. An error message says the request is not in a status that allows this change and to reload.<br>2. The message is Arabic when the language is Arabic.<br>3. The list is unchanged. | `src/app/core/utils/decision-error.util.ts` | - |

### Overtime tab

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-13 | EXCP-REQ-REVISE-UI-013 | Verify an approved overtime can be reversed from the Overtime tab | Main | An approved overtime with a request, approved by LeaderA | 1. As LeaderA open the Overtime tab, Accepted filter.<br>2. Click "Reverse approval", confirm and give a reason. | 1. The action is offered.<br>2. The overtime returns to Pending in the Overtime tab and the request to Pending in the Requests tab.<br>3. Emp is notified and the overtime is no longer counted as approved in Emp's reports. | `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.ts` | Emp, LeaderA |
| TC-14 | EXCP-REQ-REVISE-UI-014 | Verify a rejected overtime can be approved again | Main | A rejected overtime with a request; the employee's attendance for that day is complete | 1. Open the Overtime tab, Rejected filter.<br>2. Click "Approve again" and confirm. | 1. The overtime becomes Approved in both tabs.<br>2. If the attendance day needs a fix, a message explains it and nothing changes. | `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.ts` | Emp, LeaderA |

### Language

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-15 | EXCP-REQ-REVISE-UI-015 | Verify all texts are Arabic and right-to-left in Arabic | Main | Language is Arabic | 1. Open the Accepted and Rejected filters.<br>2. Go through both flows, including the dialogs, the reason box, the success messages and the notifications. | 1. Buttons read "التراجع عن الموافقة" and "الموافقة مرة أخرى".<br>2. Dialogs, reason box and messages are Arabic with no English text.<br>3. The layout is right-to-left and the buttons do not overlap. | `src/assets/i18n/ar.json`, `src/app/shared/services/swal.service.ts` | - |
