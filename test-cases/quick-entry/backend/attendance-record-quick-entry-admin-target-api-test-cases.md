# Attendance Record API — Quick Entry admin target (JWT roles)

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `backend`
- Routes: -
- APIs: `API base (for example `https://localhost:44384/api/attendance-record/...`).`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

`POST` endpoints under `api/attendance-record` that accept an optional **other employee** user id when the caller is an **Admin**:

- Path ending **`Get-bulk-details-in-range`**
- **`Bulk-apply-attendance-changes`**
- **`Export-quick-entry-transfer`**
- **`Import-quick-entry-transfer`**

Admin status must match the **`roles`** claim on the JWT (JSON array including **`Admin`**), consistent with other secured APIs.

## Test pages

- API base (for example `https://localhost:44384/api/attendance-record/...`).

## Test scenarios

- Admin token with **`Admin`** in **`roles`** can load or act on another employee when the body supplies that employee’s user id.
- Employee (non-admin) token receives **403** when the body targets another employee’s user id.

## Test cases

### Admin recognition from JWT roles claim

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-HRS-ATTENDANCE-001 | Verify an admin can call bulk details for another employee when the token lists Admin inside roles | Main | Valid admin access token; JWT **`roles`** claim is a JSON array that includes **`Admin`**; a second employee id exists; valid **`from`** and **`to`** dates for that employee. | 1. Send **`POST`** to **`Get-bulk-details-in-range`** with **`Authorization`** Bearer admin token.<br>2. Set body **`sourceUserId`** to the second employee’s user id, **`from`** and **`to`** to an inclusive range allowed by validation.<br>3. Read the HTTP status and response body. | 1. HTTP status is **200**.<br>2. Response **`data.days`** (or equivalent) reflects that employee’s attendance for the range, not the admin’s own attendance. | from: `"2026-03-23"`<br>to: `"2026-04-21"` |
| TC-02 | EXCP-QE-HRS-ATTENDANCE-002 | Verify a non-admin receives forbidden when bulk details target another employee | Main | Valid employee token without **`Admin`** in **`roles`**; another employee’s user id. | 1. Send **`POST`** to **`Get-bulk-details-in-range`** with Bearer employee token.<br>2. Set **`sourceUserId`** to the other employee’s user id and valid **`from`** / **`to**.<br>3. Read the HTTP status. | HTTP status is **403**. | Same date range as TC-01 |
