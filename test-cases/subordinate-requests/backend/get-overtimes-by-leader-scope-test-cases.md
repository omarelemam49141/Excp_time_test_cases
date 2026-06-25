# Get overtimes by leader id and status — caller scope (backend)

## Metadata

- Project: `excp-time`
- Feature: `subordinate-requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status`
- Related code: `src/Excp.HRSystem.Application/Builders/Controllers/Attendance OverTimes/GetOverTimesByLeaderIdAndStatusBuilder.cs`, `src/Excp.HRSystem.EntityFrameworkCore/AttendanceOverTimes/Repositories/AttendanceOverTimeRepository.cs`, `src/Excp.HRSystem.HttpApi/Controllers/AttendanceOverTimes/AttendanceOverTimeController.cs`
- Related docs: `docs/backend/technical/get-overtimes-by-leader-id-and-status-scope.md`

## Scope

- HTTP `POST` path **/api/attendance-overtime/Get-overtimes-By-LeaderId-and-status** (authenticated).
- Validates that **Leader** callers are always scoped to their own id, **Admin** callers may omit leader id for an unscoped list, and other roles receive **403**.

## Test pages

- POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status

## Test scenarios

- Leader access token returns only overtimes whose approving leader matches the token subject, even when the JSON body omits leader id or names another leader id.
- **Pending** overtimes for a leader match employees who **currently** report to that leader (after a company structure move, inherited pending work appears without relying on the old snapshot on the overtime row).
- **Approved** or **Rejected** overtimes stay tied to the leader stored on the overtime when the decision was made.
- Admin access token with no leader id returns pending overtimes across leaders; with a valid leader id, results match that leader only.
- Employee (or other non-admin non-leader) token receives forbidden response.
- The API can sort visible overtime results by overtime date from oldest to newest or newest to oldest.
- An unknown sort value still returns a normal paged response without changing the caller's allowed scope.
- Overtime corrected to `"WithinOvertimeGap"` does not appear when a leader asks for `"Pending"` overtime.
- Optional body fields **`employeeId`**, **`from`**, and **`to`** narrow the leader overtime list to one direct report and an inclusive overtime-date range (used after period validation on the list-requests page).

## Test cases

### Leader scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SUBREQ-HRS-OVERTIMES-001 | Verify a leader receives only their team’s pending overtimes when leader id is omitted from the body | Main | A user has the **Leader** role and does not have the **Admin** role.<br>Obtain a valid access token for that user.<br>Known pending overtime exists for that leader’s direct report and for another leader’s direct report. | 1. Call **POST** /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status with the leader’s token.<br>2. Send JSON with **overTimeStatus** set to **Pending**, pagination fields, and **no** **leaderId** field.<br>3. Read **items** in the success response. | HTTP status is success (for example **200**).<br>Every returned item is for an employee who **currently** reports to you (same team as on the company structure / profile).<br>No item is for an employee who only reports to a different team lead. | overTimeStatus: **"Pending"**<br>pageNumber: **1**<br>pageSize: **10** |
| TC-02 | EXCP-SUBREQ-HRS-OVERTIMES-002 | Verify a leader cannot widen results by passing another leader’s id | Edge | Same leader token as TC-01.<br>You know another leader’s account id string. | 1. Repeat TC-01 but add **leaderId** to the JSON set to the **other** leader’s id.<br>2. Read **items**. | The response is still scoped to **your** id only (same as TC-01).<br>You do not see the other leader’s team’s overtimes. | leaderId: use the other leader’s id |

### Admin scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-SUBREQ-HRS-OVERTIMES-003 | Verify an admin can list pending overtimes without a leader id | Main | A user has the **Admin** role.<br>Valid admin token.<br>Multiple leaders have pending overtimes. | 1. Call the endpoint with the admin token and JSON without **leaderId** (same status and pagination as TC-01).<br>2. Inspect **items** and **totalItemsCount**. | HTTP success.<br>The list can include overtimes tied to **more than one** leader value.<br>**totalItemsCount** is at least as large as any single leader’s queue. | - |
| TC-04 | EXCP-SUBREQ-HRS-OVERTIMES-004 | Verify an admin can filter to one leader when leader id is provided | Main | Admin token.<br>A valid leader account id that has pending overtimes. | 1. Call the endpoint with the admin token and JSON including **leaderId** set to that leader’s id.<br>2. Read **items**. | HTTP success.<br>Every item’s leader field matches the **leaderId** you sent. | leaderId: known leader account id |

### Forbidden

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-SUBREQ-HRS-OVERTIMES-005 | Verify a plain employee receives forbidden for this endpoint | Main | A user has neither **Admin** nor **Leader** (for example **Employee** only).<br>Valid token for that user. | 1. Call the endpoint with that token and the same JSON shape as TC-01.<br>2. Read the HTTP status. | The HTTP status is **403** Forbidden. | - |

### Pending overtime after moving an employee (company structure)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-SUBREQ-HRS-OVERTIMES-006 | Verify a new team lead sees inherited pending overtime after an employee is moved | Main | Two team lead accounts **A** and **B**.<br>An employee **E** has **Pending** overtime that was created while **E** reported to **A** (or had no team lead).<br>**E** is moved under **B** using **Save** on the company structure screen at /admin/company-structure. | 1. Sign in as **B** and call **POST** /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status with **overTimeStatus** **"Pending"** and **B**’s token.<br>2. Find the overtime for **E** in **items**. | The list includes **E**’s pending overtime.<br>HTTP success (**200**). | overTimeStatus: **"Pending"** |
| TC-07 | EXCP-SUBREQ-HRS-OVERTIMES-007 | Verify an old team lead does not keep pending overtime for an employee who was moved away | Regression | Same move as TC-06: **E** moved from **A** to **B**.<br>**E** still has only **Pending** overtime (not approved). | 1. Sign in as **A** and call the same endpoint with **overTimeStatus** **"Pending"**.<br>2. Search **items** for **E**. | **E**’s pending overtime does **not** appear for **A**. | overTimeStatus: **"Pending"** |
| TC-08 | EXCP-SUBREQ-HRS-OVERTIMES-008 | Verify approved overtime stays visible to the lead who finalized it after **E** moves to another team | Main | **E** has **Approved** overtime from when **E** reported to **A**.<br>**E** is then moved under **B** on the company structure screen. | 1. Sign in as **A** and call the endpoint with **overTimeStatus** **"Approved"** (or filter that shows finalized items).<br>2. Sign in as **B** and repeat. | **A** still sees that approved overtime for **E**.<br>**B** does **not** see that approved overtime as their own finalized item unless business rules say otherwise. | overTimeStatus: **"Approved"** |

### Company structure save updates pending overtime rows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-SUBREQ-HRS-OVERTIMES-009 | Verify saving the company structure updates pending overtime ownership for moved employees | Edge | **E** has pending overtime while reporting to **A**.<br>Move **E** under **B** and **Save** the graph. | 1. After save, inspect the pending overtime record for **E** (admin tools or API that exposes the stored team lead on the overtime).<br>2. Confirm **B** is the stored team lead on that pending overtime when **B** is assigned. | The pending overtime for **E** shows **B** as the team lead on the record after save (when **B** is the new manager). | - |

### Date sorting

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-SUBREQ-HRS-OVERTIMES-010 | Verify overtime can be sorted by date from oldest to newest | Main | A leader token can see at least three overtime entries with dates such as "2026-05-01", "2026-05-02", and "2026-05-03". | 1. Call "POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status" with the leader token.<br>2. Send normal paging fields, "overTimeStatus" set to "Pending", "sorting" set to "date", and "sortingDirection" set to "1".<br>3. Read the dates in "items" from top to bottom. | 1. HTTP status indicates success.<br>2. The listed overtime entries are ordered from the oldest overtime date to the newest overtime date.<br>3. Overtime entries with the same date keep a consistent start-time order when the call is repeated. | overTimeStatus: "Pending"<br>sorting: "date"<br>sortingDirection: "1" |
| TC-11 | EXCP-SUBREQ-HRS-OVERTIMES-011 | Verify overtime can be sorted by date from newest to oldest | Main | Same visible overtime entries as TC-10. | 1. Call the same endpoint with "sorting" set to "date" and "sortingDirection" set to "-1".<br>2. Read the dates in "items" from top to bottom. | 1. HTTP status indicates success.<br>2. The listed overtime entries are ordered from the newest overtime date to the oldest overtime date.<br>3. The caller only sees overtime entries allowed by their normal leader or admin scope. | sorting: "date"<br>sortingDirection: "-1" |
| TC-12 | EXCP-SUBREQ-HRS-OVERTIMES-012 | Verify overtime date sorting stays stable across pages | Regression | The caller can see more overtime entries than the chosen page size, and the entries have different dates. | 1. Call the endpoint with "sorting" set to "date", "sortingDirection" set to "1", "pageSize" set to "2", and "pageNumber" set to "1".<br>2. Call again with the same fields but "pageNumber" set to "2".<br>3. Compare the returned overtime identifiers and dates. | 1. HTTP status indicates success for both calls.<br>2. The same overtime entry does not appear on both pages.<br>3. The combined results stay ordered from oldest overtime date to newest overtime date. | pageSize: "2"<br>sorting: "date"<br>sortingDirection: "1" |
| TC-13 | EXCP-SUBREQ-HRS-OVERTIMES-013 | Verify an unknown overtime sort value returns a normal scoped response | Edge | A leader token can see at least one overtime entry. | 1. Call the endpoint with normal paging fields and "sorting" set to "not-a-real-sort".<br>2. Read the HTTP status and "items". | 1. HTTP status indicates success, not a server error.<br>2. The response includes the normal paging fields.<br>3. The caller only sees overtime entries allowed by their normal leader or admin scope. | sorting: "not-a-real-sort" |

### Within-gap overtime

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-SUBREQ-HRS-OVERTIMES-014 | Verify within-gap overtime is not returned when the leader asks for pending overtime | Regression | A team lead has a direct report with overtime status `"WithinOvertimeGap"` after quick-entry correction.<br>The same team lead has at least one other direct report with real `"Pending"` overtime. | 1. Sign in as the team lead.<br>2. Call `"POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status"` with `"overTimeStatus"` set to `"Pending"`.<br>3. Read `"items"` in the response. | 1. HTTP status indicates success.<br>2. The `"WithinOvertimeGap"` overtime entry is not included in `"items"`.<br>3. The real `"Pending"` overtime entry is still included when it matches the normal leader scope. | overTimeStatus: `"Pending"` |

### Optional employee and date filters

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-SUBREQ-HRS-OVERTIMES-015 | Verify leader overtime list can filter by employee and inclusive date range | Main | A team lead has two direct reports **E1** and **E2**.<br>**E1** has pending overtime on `"2026-01-01"` and `"2026-01-05"`.<br>**E2** has pending overtime on `"2026-01-02"`. | 1. Sign in as the team lead.<br>2. Call `"POST /api/attendance-overtime/Get-overtimes-By-LeaderId-and-status"` with `"overTimeStatus"` `"Pending"`, `"employeeId"` set to **E1**'s id, `"from"` `"2026-01-01"`, and `"to"` `"2026-01-02"`.<br>3. Read `"items"`.<br>4. Repeat without `"employeeId"` / `"from"` / `"to"`. | 1. HTTP status indicates success.<br>2. Every item belongs to **E1** only.<br>3. Only overtime dated `"2026-01-01"` is returned (not `"2026-01-05"` or **E2**'s row).<br>4. The unfiltered call returns overtime for both employees in the leader's scope. | employeeId: **E1**<br>from: `"2026-01-01"`<br>to: `"2026-01-02"` |
