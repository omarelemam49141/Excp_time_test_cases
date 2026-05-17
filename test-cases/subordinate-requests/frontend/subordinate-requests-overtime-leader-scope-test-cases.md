# Subordinate requests — overtime leader scope (frontend)

## Metadata

- Project: `excp-time`
- Feature: `subordinate-requests`
- Layer: `frontend`
- Routes: `/admin-leader/list-requests`
- APIs: -
- Related code: `src/app/features/admin-leader/shared/components/subordinate-requests/`, `src/app/features/admin-leader/shared/components/over-time-list/`, `src/app/auth/services/auth.service.ts`
- Related docs: `docs/frontend/technical/subordinate-requests-overtime-leader-scope.md`

## Scope

- Route `/admin-leader/list-requests` (**Requests** for team leads): **Overtime** tab, **All** tab, and other request-type tabs that load from the generic requests list.
- Ensures team leaders see only their **direct reports** in the **generic** requests API (leave and other types), not every request where they happen to be an extra approver; **Overtime** tab still uses the overtime-by-leader API; admins keep organization-wide views where applicable.

## Test pages

- /admin-leader/list-requests

## Test scenarios

- A user with **Leader** only gets a scoped overtime list and the outgoing request includes their account id.
- A user with **Admin** (with or without Leader) sees unscoped overtime on that tab.
- After an employee is reassigned on the company structure page, the **new** team lead sees that employee’s **pending** overtime on the Overtime tab; the **previous** team lead does not.
- On the **All** tab, a team lead sees **overtime-only** pending items together with other request types (not only rows from the generic requests API).
- Generic request tabs on the same page (**All**, leave, etc.) show only employees who **currently** report to that leader when the signed-in user is **Leader** without **Admin**; **Admin** users see the broader queues.
- The date header on generic request tabs and the overtime date header on the **Overtime** tab can be clicked to sort oldest-first or newest-first.
- Overtime corrected to `"WithinOvertimeGap"` is not shown in the leader pending list.

## Test cases

### Overtime tab and API request

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SUBREQ-OVERTIME-LEADER-001 | Verify a team leader sees only direct reports on the Overtime tab | Main | A test account has the Leader role and does not have the admin role.<br>The account has at least one direct report with a pending overtime request.<br>Another team has pending overtime you do not manage. | 1. Sign in as the team leader.<br>2. Open **Requests** (or navigate to /admin-leader/list-requests).<br>3. Open the **Overtime** tab.<br>4. Read each visible employee name or email in the list. | Every row shows an employee who reports to you.<br>No row shows an employee from the other team’s pending overtime. | - |
| TC-02 | EXCP-SUBREQ-OVERTIME-LEADER-002 | Verify the browser sends your account id when loading overtime as a leader | Main | Same leader-only account as TC-01.<br>Browser developer tools network capture is available. | 1. Sign in as the team leader.<br>2. Open /admin-leader/list-requests and select the **Overtime** tab.<br>3. In the network log, find the request whose address ends with **Get-overtimes-By-LeaderId-and-status**.<br>4. Open the request body. | The body includes a **leaderId** field.<br>The **leaderId** value equals your signed-in account id (same value as in profile or token). | - |
| TC-03 | EXCP-SUBREQ-OVERTIME-LEADER-003 | Verify an admin sees pending overtime from multiple teams on the Overtime tab | Main | A test account has the admin role.<br>At least two different leaders each have a direct report with pending overtime. | 1. Sign in as the admin.<br>2. Open /admin-leader/list-requests.<br>3. Open the **Overtime** tab.<br>4. Scroll or search until you see rows from both teams. | The list can show pending overtime tied to more than one leader (organization-wide view). | - |
| TC-04 | EXCP-SUBREQ-OVERTIME-LEADER-004 | Verify the browser does not send leaderId for admin on the Overtime tab | Regression | Admin account as in TC-03. | 1. Sign in as the admin.<br>2. Open /admin-leader/list-requests and the **Overtime** tab.<br>3. In the network log, open the **Get-overtimes-By-LeaderId-and-status** request body. | The body does **not** include **leaderId**, or it is empty/absent so the server treats the call as unscoped. | - |

### Consistency with other tabs

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-SUBREQ-OVERTIME-LEADER-005 | Verify leader-only filtering on non-overtime tabs shows only direct reports | Regression | Leader-only account with subordinates who have pending leave (or other) requests.<br>Another team has similar pending requests where you are only an extra approver. | 1. Sign in as the team leader.<br>2. On /admin-leader/list-requests, open a non-overtime tab (for example **All** or a leave type).<br>3. Read each visible employee name. | Every row is an employee who **currently** reports to you.<br>No row is for an employee who only belongs to the other team. | - |
| TC-06 | EXCP-SUBREQ-OVERTIME-LEADER-006 | Verify the generic requests call sends your account id as receiverId | Regression | Leader-only account.<br>Browser developer tools network capture is available. | 1. Sign in as the team leader.<br>2. Open /admin-leader/list-requests and a tab that uses the generic requests list (for example **All**).<br>3. In the network log, find **POST** `/api/Requests/get-requests-paged-filtered-list`.<br>4. Open the request body. | The JSON includes **`receiverId`**.<br>The value equals your signed-in account id. | - |

### After company structure change

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-SUBREQ-OVERTIME-LEADER-007 | Verify the new team lead sees pending overtime for a moved employee | Main | Employee **E** has **Pending** overtime from before **E** reported to team lead **NewLead**.<br>An admin moved **E** under **NewLead** on /admin/company-structure and saved. | 1. Sign in as **NewLead**.<br>2. Open /admin-leader/list-requests and the **Overtime** tab. | A row appears for **E**’s pending overtime. | - |
| TC-08 | EXCP-SUBREQ-OVERTIME-LEADER-008 | Verify the previous team lead no longer sees that pending overtime | Regression | Same scenario as TC-07.<br>**OldLead** was **E**’s manager before the move. | 1. Sign in as **OldLead**.<br>2. Open /admin-leader/list-requests and the **Overtime** tab. | No row for **E**’s pending overtime appears (unless **E** is still in **OldLead**’s team). | - |

### All tab includes overtime-only rows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-SUBREQ-OVERTIME-LEADER-009 | Verify the All tab lists pending overtime that has no separate request record | Main | A team lead has **only** pending overtime from direct reports and no other pending request types (overtime entries do not appear in the generic requests list for that lead). | 1. Sign in as the team lead.<br>2. Open /admin-leader/list-requests.<br>3. Stay on or open the **All** tab with status **Pending**. | At least one row appears for overtime (type label matches your overtime wording, for example **"Overtime"** or your Arabic equivalent).<br>The **All** tab is not empty while the **Overtime** tab still shows pending rows. | - |

### Date sorting

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-SUBREQ-OVERTIME-LEADER-010 | Verify the generic requests date header sorts from oldest to newest | Main | Signed-in user can open "/admin-leader/list-requests".<br>A generic request tab such as "All" or a leave type shows at least three entries with different visible dates. | 1. Open "/admin-leader/list-requests".<br>2. Open a tab that uses the generic requests table, such as "All" or a leave type.<br>3. Click the "date" table header once.<br>4. Read the visible dates from top to bottom. | 1. The "date" header shows an active sort indicator.<br>2. The visible entries are ordered from oldest date to newest date.<br>3. Browser network tools show the request includes "sorting" with value "date" and "sortingDirection" with value "1". | sorting: "date"<br>sortingDirection: "1" |
| TC-11 | EXCP-SUBREQ-OVERTIME-LEADER-011 | Verify clicking the generic requests date header again sorts from newest to oldest | Main | Same page and tab as TC-10, with the date header already clicked once. | 1. Click the "date" table header again.<br>2. Read the visible dates from top to bottom.<br>3. Open the matching network request. | 1. The sort indicator changes direction.<br>2. The visible entries are ordered from newest date to oldest date.<br>3. Browser network tools show "sortingDirection" with value "-1". | sorting: "date"<br>sortingDirection: "-1" |
| TC-12 | EXCP-SUBREQ-OVERTIME-LEADER-012 | Verify the overtime date header sorts overtime from oldest to newest | Main | Signed-in user can open "/admin-leader/list-requests".<br>The "Overtime" tab shows at least three overtime entries with different dates. | 1. Open "/admin-leader/list-requests".<br>2. Open the "Overtime" tab.<br>3. Click the "Over time date" table header once.<br>4. Read the visible dates from top to bottom. | 1. The "Over time date" header shows an active sort indicator.<br>2. The visible overtime entries are ordered from oldest date to newest date.<br>3. Browser network tools show the request includes "sorting" with value "date" and "sortingDirection" with value "1". | sorting: "date"<br>sortingDirection: "1" |
| TC-13 | EXCP-SUBREQ-OVERTIME-LEADER-013 | Verify clicking the overtime date header again sorts overtime from newest to oldest | Main | Same "Overtime" tab as TC-12, with the overtime date header already clicked once. | 1. Click the "Over time date" table header again.<br>2. Read the visible dates from top to bottom.<br>3. Open the matching network request. | 1. The sort indicator changes direction.<br>2. The visible overtime entries are ordered from newest date to oldest date.<br>3. Browser network tools show "sortingDirection" with value "-1". | sorting: "date"<br>sortingDirection: "-1" |
| TC-14 | EXCP-SUBREQ-OVERTIME-LEADER-014 | Verify date sorting is preserved while changing pages | Regression | A generic request tab or the "Overtime" tab has enough entries for more than one page after date sorting is active. | 1. Click the date header once so the list sorts oldest-first.<br>2. Use the page controls to move to the next page.<br>3. Open the matching network request after the page change.<br>4. Read the visible dates on the new page. | 1. The date header still shows the same active sort direction after the page changes.<br>2. Browser network tools still show "sorting" with value "date" and "sortingDirection" with value "1".<br>3. The visible entries on the new page continue the same oldest-first order. | sorting: "date"<br>sortingDirection: "1" |

### Corrected within-gap overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-SUBREQ-OVERTIME-LEADER-015 | Verify within-gap overtime does not appear in the leader pending list after quick-entry correction | Regression | A direct report has overtime corrected to `"WithinOvertimeGap"` by `"Apply quick entry range correction"`.<br>The same team lead has at least one other direct report with real `"Pending"` overtime. | 1. Sign in as the team lead.<br>2. Open `"/admin-leader/list-requests"`.<br>3. Open the `"Overtime"` tab and keep the status filter on `"Pending"`.<br>4. Search for the corrected direct report or the corrected overtime date. | 1. The corrected `"WithinOvertimeGap"` overtime is not shown in the pending list.<br>2. The real `"Pending"` overtime is still shown when it matches the current filters.<br>3. Browser network tools show the overtime request uses `"overTimeStatus"` with value `"Pending"`. | overTimeStatus: `"Pending" |
