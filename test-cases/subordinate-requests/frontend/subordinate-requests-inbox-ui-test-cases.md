# Subordinate requests — inbox layout, filters, pagination and single refusal (frontend)

## Metadata

- Project: `excp-time`
- Feature: `subordinate-requests`
- Layer: `frontend`
- Routes: `/admin-leader/list-requests`
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`, `POST /api/AttendanceOverTime/Get-overtimes-By-LeaderId-and-status`, `POST /api/Requests/change-reqeust-status`
- Related code: `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.html`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.scss`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.html`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests-table/subordinate-requests-table.component.scss`, `src/app/features/admin-leader/shared/components/over-time-list/overtimes-header/overtimes-header.component.html`, `src/app/features/admin-leader/shared/components/over-time-list/overtimes-list-table/overtimes-list-table.component.html`, `src/app/features/admin-leader/shared/components/over-time-list/over-time-list.component.html`, `src/app/shared/styles/_requests-admin-ui.scss`, `src/app/core/components/main-pagination/main-pagination.component.html`, `src/app/core/components/main-pagination/main-pagination.component.scss`
- Related docs: `docs/frontend/technical/subordinate-requests-bulk-actions-and-navigation.md`
- Automation: -

## Scope

This document covers the screen layout of the leader/admin requests inbox after the 2026-10 visual redesign (correction panel, toolbar, tables, pagination), the status filters and search, single refusal with a reason from a row, and direction and narrow-screen behavior. It does not repeat the cases for bulk actions, blockers, notifications, or overtime readiness that already exist in this feature. Layout expectations are manual checks: the redesign has not been verified in a browser yet.

## Test pages

- /admin-leader/list-requests

## Test scenarios

- The toolbar groups the total count, the status filter, and the search box; the filter and search change the list and reset the page.
- Both the generic tabs and the Overtime tab use the same table look, and every existing button still works.
- A single refusal from a row needs a reason and is refused without one.
- Pagination and the page-size selector work on both tabs.
- Arabic (right-to-left) and English (left-to-right) layouts and a narrow screen keep every control reachable.

## Test cases

### Toolbar, filters and search

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SUBREQ-INBOX-UI-001 | Verify the status filter changes the list and shows the active state | Main | A leader or admin with pending, accepted and refused requests. | 1. Open /admin-leader/list-requests.<br>2. Select **Accepted**, then **Rejected**, then **Pending**.<br>3. Press Tab to reach the filter buttons and use Enter or Space. | 1. The selected filter is highlighted and the others are not.<br>2. Each selection loads only requests of that status and the total count follows.<br>3. The filter buttons are reachable by keyboard and show a visible focus ring.<br>4. The bulk checkbox column shows only on **Pending**. | Statuses: 3 |
| TC-02 | EXCP-SUBREQ-INBOX-UI-002 | Verify search narrows the list and the Overtime tab filter behaves the same | Main | Requests and overtimes from at least two different employees. | 1. Type part of one employee name in the search box and press **Search**.<br>2. Clear the box and search again.<br>3. Repeat on the **Overtime** tab with the status filter. | 1. Only matching rows remain and the total count updates.<br>2. Clearing the text restores the full list.<br>3. The Overtime tab shows the same toolbar look and the same filter and search behavior.<br>4. The page goes back to page 1 after a search. | Search: employee name |
| TC-03 | EXCP-SUBREQ-INBOX-UI-003 | Verify the empty result shows a clear message | Edge | A search text that matches nothing. | 1. Search for text that matches no one on a generic tab.<br>2. Do the same on the **Overtime** tab. | 1. The generic tab shows the no-requests message and no table or page controls.<br>2. The Overtime tab shows its no-overtime message.<br>3. The toolbar stays usable. | Search: "zzzz" |

### Table content and single refusal

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-SUBREQ-INBOX-UI-004 | Verify a pending row shows the same details, status badge and actions after the redesign | Regression | A pending request, a request locked by the signed-in leader, and a request locked by another reviewer. | 1. Open the **Pending** list.<br>2. Read the row of each request.<br>3. Open **Details**, then close it. | 1. Each row shows number, applicant, type, date, status badge and actions with the same data as before.<br>2. Rows have the same height and the date is not cut off.<br>3. A locked row shows the locked-by-you or locked-by-another badge next to its status; the other reviewer row has **Accept** and **Refuse** disabled.<br>4. The lock and unlock buttons appear only where they did before.<br>5. Status badges are tinted: pending grey, accepted green, refused red. | Requests: 3 |
| TC-05 | EXCP-SUBREQ-INBOX-UI-005 | Verify refusing one request from a row asks for a reason | Main | A pending request the leader may decide. | 1. Press **Refuse** on the row and confirm.<br>2. Leave the reason empty and try to confirm.<br>3. Enter a reason and confirm. | 1. The dialog asks for a reason.<br>2. An empty reason is not sent and a clear message shows.<br>3. With a reason the request becomes **Rejected** and leaves the pending list.<br>4. The applicant sees the reason in **My requests**.<br>5. **Accept** asks for confirmation as before. | Reason: "Missing attachment" |
| TC-06 | EXCP-SUBREQ-INBOX-UI-006 | Verify the Overtime tab rows keep the same actions and blockers | Regression | A pending overtime the leader can decide, one blocked by another reviewer, and one locked by another reviewer. | 1. Open the **Overtime** tab on **Pending**.<br>2. Compare the three rows.<br>3. Select **Details** on one row. | 1. The decidable row has enabled **Accept** and **Refuse**.<br>2. The blocked row has disabled buttons and a reason chip; the locked row shows a lock badge and disabled buttons.<br>3. As admin the **Leader** column is present; as leader it is not.<br>4. Date, start and end time align and an unregistered end time shows its text.<br>5. **Details** opens the same window as before. | Overtimes: 3 |

### Correction panel and pagination

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-SUBREQ-INBOX-UI-007 | Verify the overtime-period correction panel is compact and still works | Regression | A leader or admin with an employee who has attendance in the last month. | 1. Open /admin-leader/list-requests on a wide screen.<br>2. Read the correction panel.<br>3. Collapse and expand it, choose an employee and two dates, then press **Validate**. | 1. Employee and both dates sit in one row; the limits hint and the **Validate** button share one footer row.<br>2. The collapsed panel shows the summary text and hides the fields.<br>3. Validation returns the same result cards as before and filters the list below.<br>4. On a narrow screen the fields stack and **Validate** fills the width. | Period: up to 31 days |
| TC-08 | EXCP-SUBREQ-INBOX-UI-008 | Verify pagination and the page-size selector on both tabs | Main | More than 10 requests and more than 10 overtimes. | 1. Go to page 2 and page 3 with the number buttons, **Next** and **Previous**.<br>2. Change the page size to 5, then 20.<br>3. Repeat on the **Overtime** tab. | 1. The current page is highlighted and the text shows page X of Y.<br>2. **Previous** is hidden on page 1 and **Next** on the last page.<br>3. Changing the size reloads with that many rows.<br>4. Both tabs use the same compact page controls.<br>5. With the bulk bar open the controls are not covered. | Page sizes: 5, 20 |

### Direction and narrow screens

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-SUBREQ-INBOX-UI-009 | Verify Arabic and English layouts of the toolbar, tables and pagination | Regression | A list with several requests and overtimes. | 1. Open the page in Arabic and read the toolbar, both tables, the correction panel and the page controls.<br>2. Switch to English and compare. | 1. Arabic is right-to-left: columns, filter buttons and page controls run from the right; English runs from the left.<br>2. All texts are translated; no raw keys or English in the Arabic view.<br>3. Numbers and dates stay readable and aligned.<br>4. Nothing overlaps and no text is cut off in either direction. | Languages: "ar", "en" |
| TC-10 | EXCP-SUBREQ-INBOX-UI-010 | Verify the page stays usable on a narrow screen | Edge | A phone-width or narrow window (about 375 px). | 1. Open the page at the narrow width in Arabic and English.<br>2. Use the toolbar, scroll a table sideways, press row actions and use the page controls. | 1. The filter buttons share the width and the search box takes the full row.<br>2. The table scrolls sideways inside its card; the page itself does not scroll sideways.<br>3. Every row action and the checkbox can still be reached.<br>4. The correction panel fields stack and the bulk bar stays reachable. | Width: 375 px |
