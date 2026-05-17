# Get requests paged filtered list — leader inbox scope (backend)

## Metadata

- Project: `excp-time`
- Feature: `subordinate-requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`
- Related code: `src/Excp.HRSystem.Application/Builders/Services/Requests/GetRequestPagedFilteredListBuilder.cs`, `src/Excp.HRSystem.EntityFrameworkCore/Requests/Repositories/RequestRepository.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`
- Related docs: `docs/backend/technical/get-requests-paged-filtered-list-leader-inbox.md`

## Scope

- HTTP **POST** path **`/api/Requests/get-requests-paged-filtered-list`** (authenticated).
- **Leader-only** callers are scoped to requests where they are a receiver **and** the employee who raised the request **currently** reports to them; **`receiverId`** in the body must match the signed-in account or be omitted, or the API returns **403**.
- **Admin** callers keep the previous behavior: filter by optional **`receiverId`** only, no extra “direct reports” rule.

## Test pages

- POST /api/Requests/get-requests-paged-filtered-list

## Test scenarios

- A **Leader** token returns only pending (or filtered) requests from **direct reports**, even when the same request lists many other approvers.
- A **Leader** token with **`receiverId`** set to **another** user’s id receives **403 Forbidden**.
- An **Admin** token still returns organization-wide (or receiver-filtered) results without applying the direct-report rule.
- After an employee is reassigned on the company structure page, **pending** requests for that employee follow the **new** team lead for this list (current manager on the user profile / org chart).
- The API can sort visible request results by the request date from oldest to newest or newest to oldest.
- An unknown sort value still returns a normal paged response without changing the caller's allowed scope.

## Test cases

### Leader scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-SUBREQ-HRS-PAGED-001 | Verify a leader receives only requests from employees who currently report to them | Main | A user has the **Leader** role and does **not** have the **Admin** role.<br>A valid access token for that user.<br>Pending requests exist where you are named as an approver: at least one from your direct report and at least one from an employee who reports to someone else (you still appear on the second request as an extra approver). | 1. Call **POST** `/api/Requests/get-requests-paged-filtered-list` with the leader’s token.<br>2. Send JSON with **`receiverId`** equal to your signed-in account id, status **Pending** (or your localized pending value), and normal paging fields.<br>3. Read **`items`** in the success response. | HTTP status indicates success (for example **200**).<br>Every listed request shows an employee who **currently** reports to you.<br>No item is for an employee who only reports to a different team lead. | **receiverId:** your account id<br>**requestStatus:** **"Pending"** (or the exact value your client sends)<br>**pageNumber:** **1**<br>**pageSize:** **10** |
| TC-02 | EXCP-SUBREQ-HRS-PAGED-002 | Verify a leader cannot open another user’s inbox by changing receiverId | Edge | Same leader-only token as TC-01.<br>You know another approver’s account id. | 1. Call the same endpoint with the leader’s token.<br>2. Set **`receiverId`** in the JSON to the **other** approver’s id (not yours).<br>3. Read the HTTP status and body. | HTTP status is **403** Forbidden.<br>The response shows the usual forbidden message your API returns (for example the localized **"Forbidden"** text your clients already see on other blocked actions). | **receiverId:** the other user’s id |
| TC-03 | EXCP-SUBREQ-HRS-PAGED-003 | Verify a leader may omit receiverId and still get a scoped inbox | Regression | Same leader-only token as TC-01. | 1. Call **POST** `/api/Requests/get-requests-paged-filtered-list` with the leader’s token.<br>2. Omit **`receiverId`** from the JSON (or send it empty if your client does that).<br>3. Compare results to TC-01. | HTTP success.<br>The list matches the same direct-report scope as when **`receiverId`** is your own id. | **requestStatus:** **"Pending"** |

### Admin scope

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-SUBREQ-HRS-PAGED-004 | Verify an admin still sees cross-team requests when receiverId is omitted | Main | A user has the **Admin** role.<br>Valid admin token.<br>Pending requests exist that involve different teams and multiple receivers. | 1. Call **POST** `/api/Requests/get-requests-paged-filtered-list` with the admin token.<br>2. Omit **`receiverId`** (or leave it empty).<br>3. Inspect **`items`** and totals. | HTTP success.<br>The result can include requests from **more than one** team (not limited to one lead’s direct reports). | **requestStatus:** **"Pending"** |
| TC-05 | EXCP-SUBREQ-HRS-PAGED-005 | Verify an admin can filter the list to one receiver | Regression | Admin token.<br>A known **`receiverId`** that has pending requests. | 1. Call the endpoint with **`receiverId`** set to that user’s id.<br>2. Check that returned requests are consistent with that receiver appearing on the request. | HTTP success.<br>Results match the chosen receiver filter (same behavior as before this change). | **receiverId:** chosen approver account id |

### Company structure

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-SUBREQ-HRS-PAGED-006 | Verify a new team lead sees a moved employee’s pending request in this list | Main | Employee **E** has a **Pending** request where **NewLead** is among approvers.<br>**E** was moved under **NewLead** on **/admin/company-structure** and changes were saved. | 1. Sign in as **NewLead** and call **POST** `/api/Requests/get-requests-paged-filtered-list` with **`receiverId`** = **NewLead**’s id and **Pending** status.<br>2. Find **E**’s request in **`items`**. | **E**’s pending request appears for **NewLead**.<br>HTTP success. | - |
| TC-07 | EXCP-SUBREQ-HRS-PAGED-007 | Verify the previous team lead no longer sees that pending request after the move | Regression | Same move as TC-06.<br>**OldLead** was **E**’s manager before the move. | 1. Sign in as **OldLead** and call the endpoint with **`receiverId`** = **OldLead**’s id.<br>2. Search **`items`** for **E**’s request. | **E**’s pending request does **not** appear for **OldLead** unless **E** still reports to **OldLead**. | - |

### Search and status counts

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-SUBREQ-HRS-PAGED-008 | Verify status counts respect the leader scope when search is used | Edge | Leader-only token.<br>Your environment returns **`requestStatusCounts`** when the client sends a **search** string (non-empty). | 1. Call the endpoint as a leader with **`receiverId`** = your id, a non-empty **search** that matches some request types, and the same date filters you use in the app.<br>2. Compare pending **count** in **`requestStatusCounts** to the number of **Pending** rows you get when you call again with the same filters and **search**. | Counts line up with the scoped list (no extra pending from other teams). | **search:** a short string that matches a visible request type name |

### Date sorting

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-SUBREQ-HRS-PAGED-009 | Verify requests can be sorted by date from oldest to newest | Main | A leader-only token can see at least three requests with visible dates such as "2026-05-01", "2026-05-02", and "2026-05-03". | 1. Call "POST /api/Requests/get-requests-paged-filtered-list" with the leader token.<br>2. Send normal paging fields, "requestStatus" set to "Pending", "sorting" set to "date", and "sortingDirection" set to "1".<br>3. Read the dates in "items" from top to bottom. | 1. HTTP status indicates success.<br>2. The listed requests are ordered from the oldest visible date to the newest visible date.<br>3. Running the same call again keeps the same order for requests with the same visible date. | sorting: "date"<br>sortingDirection: "1" |
| TC-10 | EXCP-SUBREQ-HRS-PAGED-010 | Verify requests can be sorted by date from newest to oldest | Main | Same visible requests as TC-09. | 1. Call the same endpoint with "sorting" set to "date" and "sortingDirection" set to "-1".<br>2. Read the dates in "items" from top to bottom. | 1. HTTP status indicates success.<br>2. The listed requests are ordered from the newest visible date to the oldest visible date.<br>3. The caller only sees requests allowed by their normal leader or admin scope. | sorting: "date"<br>sortingDirection: "-1" |
| TC-11 | EXCP-SUBREQ-HRS-PAGED-011 | Verify date sorting stays stable across pages | Regression | The caller can see more requests than the chosen page size, and the requests have different visible dates. | 1. Call the endpoint with "sorting" set to "date", "sortingDirection" set to "1", "pageSize" set to "2", and "pageNumber" set to "1".<br>2. Call again with the same fields but "pageNumber" set to "2".<br>3. Compare the returned request identifiers and dates. | 1. HTTP status indicates success for both calls.<br>2. The same request does not appear on both pages.<br>3. The combined results stay ordered from oldest visible date to newest visible date. | pageSize: "2"<br>sorting: "date"<br>sortingDirection: "1" |
| TC-12 | EXCP-SUBREQ-HRS-PAGED-012 | Verify an unknown sort value returns a normal scoped response | Edge | A leader-only token can see at least one request. | 1. Call the endpoint with normal paging fields and "sorting" set to "not-a-real-sort".<br>2. Read the HTTP status and "items". | 1. HTTP status indicates success, not a server error.<br>2. The response includes the normal paging fields.<br>3. The caller only sees requests allowed by their normal leader or admin scope. | sorting: "not-a-real-sort" |
