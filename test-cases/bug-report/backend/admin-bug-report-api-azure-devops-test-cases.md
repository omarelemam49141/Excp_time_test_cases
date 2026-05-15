# Admin bug report API test cases

## Metadata

- Project: `excp-time`
- Feature: `bug-report`
- Layer: `backend`
- Routes: -
- APIs: `/{project}/_apis/wit/attachments?...&api-version=...`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/{project}/_apis/wit/attachments?...&api-version=...`


## Test scenarios

- Allowlist authorization checks.
- Bug creation payload mapping to Azure fields.
- Attachment upload and relation linking (multipart + clipboard JSON payload).
- Admin CRUD operations for allowlist.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-BUG-HRS-ADMIN-AZURE-001 | Verify Can-report endpoint allowed | Main | - | 1. Authenticated user exists in allowlist with `IsActive = true`. | `data = true`. | - |
| TC-02 | EXCP-BUG-HRS-ADMIN-AZURE-002 | Verify Can-report endpoint denied | Edge | - | 1. Authenticated user not in allowlist or inactive. | `data = false`. | - |
| TC-03 | EXCP-BUG-HRS-ADMIN-AZURE-003 | Verify Create bug success | Edge | - | 1. Submit valid multipart payload with title/description/severity/priority (optional `SystemInfo`, `Discipline`, `Teams`, `Source`; defaults applied when omitted). | Azure bug created and assigned to `o.emam@excp.sa`; submitted description appears in both Description and Repro Steps sections; required process fields (`Microsoft.VSTS.TCM.SystemInfo`, `Microsoft.VSTS.Common.Discipline`, `Custom.Teams`, `Custom.Source`) are populated so TF401320 rule validation does not fail. | - |
| TC-04 | EXCP-BUG-HRS-ADMIN-AZURE-004 | Verify Create bug denied for non-allowlisted user | Edge | - | 1. Submit valid payload from non-allowlisted user. | forbidden response. | - |
| TC-05 | EXCP-BUG-HRS-ADMIN-AZURE-005 | Verify Attachment linking | Main | - | 1. Submit payload with one or more files. | files are uploaded through `/{project}/_apis/wit/attachments?...&api-version=...` and linked to bug relations; no `VssVersionNotSpecifiedException` occurs. | - |
| TC-06 | EXCP-BUG-HRS-ADMIN-AZURE-006 | Verify Clipboard attachment payload success | Main | - | 1. Submit `create-bug-report` with valid `ClipboardAttachmentsJson` (one or more image items with base64 content) and no multipart files. | endpoint accepts payload, decodes bytes, uploads attachments, and links them to created bug. | - |
| TC-07 | EXCP-BUG-HRS-ADMIN-AZURE-007 | Verify Mixed multipart + clipboard payload | Main | - | 1. Submit `create-bug-report` with both `Attachments` files and `ClipboardAttachmentsJson`. | all attachments from both channels are uploaded and linked to the same bug. | - |
| TC-08 | EXCP-BUG-HRS-ADMIN-AZURE-008 | Verify Clipboard payload invalid JSON rejected | Edge | - | 1. Submit malformed `ClipboardAttachmentsJson`. | `400 BadRequest` with parse/validation error; no attachment upload attempt. | - |
| TC-09 | EXCP-BUG-HRS-ADMIN-AZURE-009 | Verify Clipboard payload invalid base64 rejected | Edge | - | 1. Submit `ClipboardAttachmentsJson` with non-base64 `base64Content`. | `400 BadRequest`; no attachment upload attempt. | - |
| TC-10 | EXCP-BUG-HRS-ADMIN-AZURE-010 | Verify Clipboard payload unsupported content type rejected | Edge | - | 1. Submit `ClipboardAttachmentsJson` item with non-image `contentType`. | `400 BadRequest`; no attachment upload attempt. | - |
| TC-11 | EXCP-BUG-HRS-ADMIN-AZURE-011 | Verify Clipboard payload oversize item rejected | Edge | - | 1. Submit `ClipboardAttachmentsJson` item whose decoded bytes exceed attachment size limit. | `400 BadRequest`; no attachment upload attempt. | - |
| TC-12 | EXCP-BUG-HRS-ADMIN-AZURE-012 | Verify Allowlist add | Main | - | 1. Admin adds new email. | record saved and unique-email rule enforced. | - |
| TC-13 | EXCP-BUG-HRS-ADMIN-AZURE-013 | Verify Allowlist add duplicate (already active) | Main | - | 1. Admin adds an email that already exists with `IsActive = true`. | API returns success without duplicate-key DB exception; existing record remains active. | - |
| TC-14 | EXCP-BUG-HRS-ADMIN-AZURE-014 | Verify Allowlist add duplicate (inactive record) | Main | - | 1. Admin adds an email that already exists with `IsActive = false`. | existing record is reactivated (`IsActive = true`) and API returns success. | - |
| TC-15 | EXCP-BUG-HRS-ADMIN-AZURE-015 | Verify Allowlist update | Main | - | 1. Admin updates `IsActive`. | status changes and affects `can-current-user-report-bug`. | - |
| TC-16 | EXCP-BUG-HRS-ADMIN-AZURE-016 | Verify Allowlist delete | Main | - | 1. Admin deletes tester by id. | record is soft-deleted (ABP `DeleteAsync` on `FullAuditedEntity`); row remains for audit but disappears from default allowlist queries. | - |
| TC-17 | EXCP-BUG-HRS-ADMIN-AZURE-017 | Verify Allowlist re-add after delete (same email) | Edge | - | 1. Tester exists only as a soft-deleted row with that email (after scenario 10).<br>2. Admin POSTs the same normalized email again. | no duplicate-key error; row is undeleted, `IsActive = true`, API returns success with same id. | - |
| TC-18 | EXCP-BUG-HRS-ADMIN-AZURE-018 | Verify Can-report with missing `CurrentUser.Email` but valid JWT email claim | Edge | - | 1. Simulate request where ABP `CurrentUser.Email` is empty but bearer token includes `email` / `upn` / `unique_name`. | endpoint reads fallback claim/JWT email and returns `data = true` for allowlisted user (no false `401`). | - |
| TC-19 | EXCP-BUG-HRS-ADMIN-AZURE-019 | Verify Bug report options for project with space in name | Main | - | 1. `GET /api/azure-work-items/bug-report-options/EXCP%20Time` | returns severity and priority options (200). Backend reads fields from `/{project}/_apis/wit/workitemtypes/Bug/fields` with `$expand=allowedValues. | - |
