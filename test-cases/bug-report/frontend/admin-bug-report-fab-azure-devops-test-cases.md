# Admin bug report FAB test cases

## Metadata

- Project: `excp-time`
- Feature: `bug-report`
- Layer: `frontend`
- Routes: `(Add the primary screen route or API path here.)`
- APIs: -
- Related code: `src/app/core/components/bug-report-fab`, `src/app/features/admin-leader/admin/components/bug-report-allowlist`, `src/app/features/Azure/services/azure-work-items.service.ts`
- Related docs: `docs/frontend/technical/admin-bug-report-fab-azure-devops.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Floating button visibility for allowlisted vs non-allowlisted users.
- Structured description fields (page URL, expected result, actual result, steps to reproduce).
- Modal validation and submission behavior.
- Attachment list add/remove constraints, manual upload, and clipboard image paste.
- Admin allowlist CRUD behavior.
- Bug-report modal/FAB redesign consistency and localization.
- FAB drag behavior and drag-vs-click interaction.


## Test cases

### Bug report FAB

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-BUG-ADMIN-FAB-AZURE-001 | Verify Allowlisted user sees the floating bug report button | Main | - | 1. Login with allowlisted email. | floating bug button is visible. | - |
| TC-02 | EXCP-BUG-ADMIN-FAB-AZURE-002 | Verify Non-allowlisted user does not see the floating bug report button | Main | - | 1. Login with a user not in allowlist. | button is hidden. | - |
| TC-03 | EXCP-BUG-ADMIN-FAB-AZURE-003 | Verify Allowlisted user sees the floating bug report button immediately after login redirect | Main | - | 1. Login with allowlisted user and let app redirect to Home. | FAB appears without needing manual browser refresh. | - |
| TC-04 | EXCP-BUG-ADMIN-FAB-AZURE-004 | Verify the floating bug report button can be dragged | Main | - | 1. Press and hold the FAB, drag it to another area of the screen. | FAB follows pointer/finger and remains within viewport bounds. | - |
| TC-05 | EXCP-BUG-ADMIN-FAB-AZURE-005 | Verify Dragging the floating bug report button does not open modal | Main | - | 1. Drag the FAB and release pointer/finger. | modal does not open after drag release. | - |
| TC-06 | EXCP-BUG-ADMIN-FAB-AZURE-006 | Verify Required validation | Edge | - | 1. Open modal and submit without title/steps to reproduce/severity/priority. | inline field-level validation messages appear under invalid controls and no API submit is sent. | - |
| TC-07 | EXCP-BUG-ADMIN-FAB-AZURE-007 | Verify Page URL auto-fills on open | Main | - | 1. Navigate to any page and open bug modal. | the page URL field is pre-filled with the current browser URL. | - |
| TC-08 | EXCP-BUG-ADMIN-FAB-AZURE-008 | Verify Page URL is editable | Main | - | 1. Open bug modal and modify the pre-filled page URL. | the edited URL is included in the submitted description. | - |
| TC-09 | EXCP-BUG-ADMIN-FAB-AZURE-009 | Verify Structured description sent as formatted HTML | Main | - | 1. Fill page URL, expected result, actual result, and steps to reproduce, then submit. | description sent to API contains bold headings (`Page URL:`, `Expected Result:`, `Actual Result:`, `Steps to Reproduce:`) with line breaks between sections. | - |
| TC-10 | EXCP-BUG-ADMIN-FAB-AZURE-010 | Verify Optional fields can be left empty | Edge | - | 1. Fill only title, steps to reproduce, severity, and priority (leave page URL, expected result, and actual result empty). | submit succeeds and only the Steps to Reproduce section appears in the description. | - |
| TC-11 | EXCP-BUG-ADMIN-FAB-AZURE-011 | Verify Attachment add/remove | Main | - | 1. Add multiple files, remove one. | list updates correctly before submit. | - |
| TC-12 | EXCP-BUG-ADMIN-FAB-AZURE-012 | Verify Successful bug submit | Main | - | 1. Fill required fields and submit. | success notification, modal closes, form resets. | - |
| TC-13 | EXCP-BUG-ADMIN-FAB-AZURE-013 | Verify Paste screenshot with Ctrl+V | Main | - | 1. Copy a screenshot image to the clipboard using Windows Snipping Tool or Print Screen flow.<br>2. Open bug modal and press `Ctrl+V`. | one image file is added to the attachments list. | - |
| TC-14 | EXCP-BUG-ADMIN-FAB-AZURE-014 | Verify Paste screenshot with dedicated button (no Ctrl+V) | Main | - | 1. Copy a screenshot image to the clipboard using Windows Snipping Tool or Print Screen flow.<br>2. Open bug modal and click **Paste image from clipboard**. | one image file is added to the attachments list without using keyboard paste. | - |
| TC-15 | EXCP-BUG-ADMIN-FAB-AZURE-015 | Verify Paste screenshot while focus is in text input | Main | - | 1. Copy a screenshot image to the clipboard.<br>2. Focus the title or actual result field and press `Ctrl+V`. | screenshot is attached and normal text editing remains usable. | - |
| TC-16 | EXCP-BUG-ADMIN-FAB-AZURE-016 | Verify Paste screenshot while focus is on modal chrome | Main | - | 1. Copy a screenshot image to the clipboard.<br>2. Click the attachment area or modal background, then press `Ctrl+V`. | native paste handler reads the image and adds it as an attachment. | - |
| TC-17 | EXCP-BUG-ADMIN-FAB-AZURE-017 | Verify Paste with non-image clipboard content | Main | - | 1. Copy plain text to the clipboard and press `Ctrl+V` in the modal. | no attachment is added and the modal remains stable. | - |
| TC-18 | EXCP-BUG-ADMIN-FAB-AZURE-018 | Verify Removed browser screenshot buttons | Main | - | 1. Open bug modal. | no Full page, Select area, or Screen share capture buttons are shown. | - |
| TC-19 | EXCP-BUG-ADMIN-FAB-AZURE-019 | Verify Submit with pasted screenshot does not fail with broken blob | Edge | - | 1. Copy a screenshot image, paste with `Ctrl+V`, then submit a valid bug report. | request completes without browser `net::ERR_BLOB_REFERENCED_BLOB_BROKEN` error and bug is created with attachment. | - |
| TC-20 | EXCP-BUG-ADMIN-FAB-AZURE-020 | Verify Clipboard payload path avoids browser blob memory errors | Edge | - | 1. Paste an image using `Ctrl+V` and submit immediately. | submit succeeds without browser blob memory errors (`net::ERR_BLOB_OUT_OF_MEMORY`) because pasted screenshot is sent through `clipboardAttachmentsJson` payload path. | - |
| TC-21 | EXCP-BUG-ADMIN-FAB-AZURE-021 | Verify Mixed attachments (manual + pasted) | Main | - | 1. Add one file using Choose Files, then paste one screenshot with `Ctrl+V`, then submit. | both attachments appear on the created bug; manual file uses multipart `attachments` and pasted image uses clipboard JSON payload. | - |

### Allowlist admin page

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-BUG-ADMIN-FAB-AZURE-022 | Verify Allowlist add via user selection | Main | - | 1. Admin selects a user from the dropdown and clicks add. | tester card appears in the list with active status. | - |
| TC-23 | EXCP-BUG-ADMIN-FAB-AZURE-023 | Verify Allowlist searchable dropdown | Main | - | 1. Type part of name/email/username in the user picker search field. | dropdown filters matching users and allows selecting the intended one quickly. | - |
| TC-24 | EXCP-BUG-ADMIN-FAB-AZURE-024 | Verify User dropdown excludes existing testers | Main | - | 1. Admin has already added some testers. | dropdown only shows users not already in the allowlist. | - |
| TC-25 | EXCP-BUG-ADMIN-FAB-AZURE-025 | Verify Stat chips update correctly | Main | - | 1. Admin adds/activates/deactivates testers. | total/active/inactive counts update in real-time. | - |
| TC-26 | EXCP-BUG-ADMIN-FAB-AZURE-026 | Verify Allowlist activate/deactivate | Main | - | 1. Admin toggles tester status using the toggle button. | status badge updates and impacts FAB visibility after reload. | - |
| TC-27 | EXCP-BUG-ADMIN-FAB-AZURE-027 | Verify Allowlist delete | Main | - | 1. Admin deletes tester using the delete button. | tester card removed and tester can no longer see FAB. | - |
| TC-28 | EXCP-BUG-ADMIN-FAB-AZURE-028 | Verify Empty state display | Edge | - | 1. No testers in the allowlist. | empty state message with icon is displayed. | - |
| TC-29 | EXCP-BUG-ADMIN-FAB-AZURE-029 | Verify Loading skeleton display | Main | - | 1. While fetching allowlist data. | skeleton loading animation is shown. | - |
| TC-30 | EXCP-BUG-ADMIN-FAB-AZURE-030 | Verify User display name resolution | Main | - | 1. Tester card shows user's name (not just email). | card displays full name alongside email. | - |

### Localization

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-31 | EXCP-BUG-ADMIN-FAB-AZURE-031 | Verify English localization | Main | - | 1. Switch to English language. | all page text appears in English. | - |
| TC-32 | EXCP-BUG-ADMIN-FAB-AZURE-032 | Verify Arabic localization | Main | - | 1. Switch to Arabic language. | all page text appears in Arabic with RTL layout. | - |

### Design consistency

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-33 | EXCP-BUG-ADMIN-FAB-AZURE-033 | Verify Quick-entry style design (the floating bug report button + modal) | Main | - | 1. Open any page as allowlisted user and launch bug modal. | FAB has teal gradient/glow/shimmer and modal uses quick-entry themed header/body/buttons. | - |
| TC-34 | EXCP-BUG-ADMIN-FAB-AZURE-034 | Verify Dropdown visual parity with quick-entry inputs | Main | - | 1. Open the allowlist page and inspect the searchable user dropdown (default/focus/open states). | pill-style radius and compact input height, teal focus ring, and themed dropdown panel/filter input consistent with quick-entry identity. | - |
| TC-35 | EXCP-BUG-ADMIN-FAB-AZURE-035 | Verify 401 on the floating bug report button visibility check does not logout | Edge | - | 1. Force `GET /api/azure-work-items/can-current-user-report-bug to return 401 (expired/invalid token simulation). | app does not redirect to login because of this optional check; FAB remains hidden and normal session flow continues. | - |
