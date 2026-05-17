# Company structure — frontend test cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/**`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/company-structure`, `src/app/features/admin-leader/admin/services/company-structure.service.ts`, `src/app/core/guards/core/guards/admin-section.guard.ts`
- Related docs: `docs/frontend/technical/company-structure-org-chart.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/**`


## Test scenarios

- **Admin** or **HR** can open the company structure page, edit the tree (add / edit / move / remove), mark primary reporting lines, save, and reload.
- Any other signed-in user can open **only** `/admin/company-structure` in **read-only** mode (no save or structure edits); see also `company-structure-employee-view-test-cases.md`.
- Only **Admin** can open other `/admin/**` routes; **HR** and other roles are blocked from those URLs by `adminSectionGuard` (except company structure).
- Validation messages show for missing user/title/duplicate user; move requires a parent when options exist.
- User picker loads users once and caches them; subsequent searches filter client-side without API calls.
- Background attendance refresh does not force navigation away from `/admin/company-structure`.
- When there are unsaved structure edits, leaving the page shows a three-option confirmation: save and leave, leave without saving, or stay.


## Test cases

### CS-FE-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ORG-ORG-CHART-001 | Verify Admin navigation | Edge | - | 1. Admin opens sidebar → Company structure | Page loads without error | - |

### CS-FE-01a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-ORG-ORG-CHART-002 | Verify HR navigation | Main | - | 1. HR opens sidebar → Company structure | Page loads; link visible for HR | - |

### CS-FE-01c

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-32 | EXCP-ORG-ORG-CHART-003 | Verify any employee can open company structure | Main | Signed-in user is **not** admin and **not** HR. | 1. Open the sidebar.<br>2. Tap **"Company structure"** (or Arabic equivalent). | The page loads at **"/admin/company-structure"**.<br>No **"Save structure"** button appears. | - |

### CS-FE-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-ORG-ORG-CHART-004 | Verify Non-privileged blocked | Edge | - | 1. Employee navigates to `/admin/reports/...` | Guard prevents access | - |

### CS-FE-02a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-ORG-ORG-CHART-005 | Verify HR blocked from other admin | Edge | - | 1. HR navigates to `/admin/document-types` | Guard prevents access (back) | - |

### CS-FE-02b

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-ORG-ORG-CHART-006 | Verify HR company structure | Main | - | 1. HR navigates to `/admin/company-structure` | Page loads | - |

### CS-FE-03

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-ORG-ORG-CHART-007 | Verify Empty CTA | Edge | Signed-in as **Admin** or **HR**.<br>Chart has no nodes. | 1. On empty chart, tap the large **"Tap to pick your first teammate"** action. | The add-person dialog opens. | - |

### CS-FE-04

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-ORG-ORG-CHART-008 | Verify Add root | Main | - | 1. Complete add dialog; save | Success toast; tree shows card | - |

### CS-FE-05

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-ORG-ORG-CHART-009 | Verify Add report | Main | - | 1. On non-employee card, Add report | Child row appears deeper (indent) | - |

### CS-FE-06

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-ORG-ORG-CHART-010 | Verify Primary toggle | Main | - | 1. Two parents on a child; tap star | Only one primary highlighted | - |

### CS-FE-07

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-ORG-ORG-CHART-011 | Verify Employee leaf | Main | - | 1. Node kind Employee | No Add report button | - |

### CS-FE-08

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-ORG-ORG-CHART-012 | Verify Duplicate user | Edge | - | 1. Add same user twice | Error toast `companyStructure.duplicateUser` | - |

### CS-FE-09

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-12 | EXCP-ORG-ORG-CHART-013 | Verify Missing title | Edge | - | 1. Add without display title | Error toast `companyStructure.titleRequired` | - |

### CS-FE-10

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-ORG-ORG-CHART-014 | Verify Reload | Main | - | 1. Change local tree; Reload | Server state replaces draft | - |

### CS-FE-11

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-ORG-ORG-CHART-015 | Verify i18n | Main | - | 1. Switch AR/EN | Labels translate | - |

### CS-FE-12

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-ORG-ORG-CHART-016 | Verify Add manager above | Main | - | 1. Click Add manager above on a node; complete dialog | New parent row above child in tree | - |

### CS-FE-13

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-16 | EXCP-ORG-ORG-CHART-017 | Verify Edit | Main | - | 1. Edit title/kind; save | Card reflects changes | - |

### CS-FE-14

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-17 | EXCP-ORG-ORG-CHART-018 | Verify Move | Main | - | 1. Move under…; pick parent; apply | Node reparented; levels consistent | - |

### CS-FE-15

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-18 | EXCP-ORG-ORG-CHART-019 | Verify Move validation | Edge | - | 1. Move with no parent selected | Error `companyStructure.movePickParent | - |

### CS-FE-16

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-ORG-ORG-CHART-020 | Verify User picker loading | Main | - | 1. Open add dialog first time | Loading spinner shown; users load once | - |

### CS-FE-17

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-ORG-ORG-CHART-021 | Verify User picker cache | Main | - | 1. Close and reopen add dialog | Users appear instantly (no spinner/API call) | - |

### CS-FE-18

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-21 | EXCP-ORG-ORG-CHART-022 | Verify User search instant | Main | - | 1. Type in search field | Results filter instantly without API call | - |

### CS-FE-19

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-ORG-ORG-CHART-023 | Verify User search by name | Main | - | 1. Search "john" | Users with "john" in name shown | - |

### CS-FE-20

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-ORG-ORG-CHART-024 | Verify User search by username | Main | - | 1. Search "@admin" | Users with "@admin" in username shown | - |

### CS-FE-21

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-24 | EXCP-ORG-ORG-CHART-025 | Verify User search clear | Main | - | 1. Clear search field | First 50 users shown (no filter) | - |

### CS-FE-22

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-25 | EXCP-ORG-ORG-CHART-026 | Verify User search no results | Main | - | 1. Search "xyznonexistent" | "No users found" message shown | - |

### CS-FE-23

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-26 | EXCP-ORG-ORG-CHART-027 | Verify Initial load identity mapping across pages | Main | - | 1. Load graph that contains users not returned in first users page | Node cards show user name/email (no raw uuid fallback) | - |

### CS-FE-24

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-27 | EXCP-ORG-ORG-CHART-028 | Verify Zoom connector alignment | Main | - | 1. On populated graph, zoom out/in several times and scroll | Connector start/end points remain aligned with parent/child cards | - |

### CS-FE-25

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-28 | EXCP-ORG-ORG-CHART-029 | Verify no forced navigation after background refresh | Main | User is on "/admin/company-structure".<br>There is at least one background attendance refresh event while this page is open. | 1. Open "/admin/company-structure".<br>2. Wait for at least one background refresh cycle.<br>3. Continue interacting with the org chart page. | 1. The app stays on "/admin/company-structure".<br>2. The page is not redirected to "home" or attendance timer pages. | - |

### CS-FE-26

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-29 | EXCP-ORG-ORG-CHART-030 | Verify unsaved changes prompt offers stay option | Main | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page from the sidebar.<br>3. In the prompt, click "Stay on page". | 1. A warning prompt appears with three actions.<br>2. After clicking "Stay on page", user remains on "/admin/company-structure".<br>3. Unsaved edits are still visible. | - |

### CS-FE-27

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-30 | EXCP-ORG-ORG-CHART-031 | Verify unsaved changes prompt allows leave without saving | Edge | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page.<br>3. In the prompt, click "Leave without saving". | 1. Navigation proceeds immediately to the selected page.<br>2. If user returns to "/admin/company-structure", the unsaved edits are not applied. | - |

### CS-FE-28

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-31 | EXCP-ORG-ORG-CHART-032 | Verify unsaved changes prompt saves then navigates | Main | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page.<br>3. In the prompt, click "Save and leave". | 1. Save completes successfully with the normal success feedback.<br>2. Navigation proceeds to the selected page after save.<br>3. Returning to "/admin/company-structure" shows the saved edit. | - |
