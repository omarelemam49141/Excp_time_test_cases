# Admin user wizard — test cases (frontend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `frontend`
- Routes: `/admin-leader/users/create`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin-leader/users/create`


## Test scenarios

- ### Create (admin)
- Open `/admin-leader/users/create` as admin: wizard loads, lookups (roles, locations, leaders) populate.
- Complete steps 0–4 with valid data: submit calls `new-user` API; success toast; redirect to `list-users`; list refresh fires.
- Validation: step 0 missing required fields blocks **Next**; step 1 phone rule matches location (Egypt/Saudi) like legacy register.
- Validation visibility: when **Next** is blocked on any step, user sees inline banner + field-level errors without submitting the full wizard.
- `auth/register` redirects to `/admin-leader/users/create` (old bookmarks still work).
- ### Edit (admin)
- From list, **Edit** opens `/admin-leader/users/{id}/edit`; `get-user-for-admin-edit` fills the form.
- **Leader** and **roles** can be changed; **Active** switch only in edit; save calls `update-user-by-admin`.
- **Security step**: if **new password** is empty → only profile update; if **new password** is filled → both `confirmNewPassword` and `adminPassword` are required; success runs `set-user-password-by-admin` after update when valid and matching.
- Eye icon behavior: each password field (`newPassword`, `confirmNewPassword`, `adminPassword`) toggles visible/hidden text independently.
- Wrong admin password: error toast, user stays on flow.
- ### Authorization / UX
- Non-admin cannot open create/edit routes (guards).
- Step pills: completed steps clickable to go back; future steps disabled.
- English/Arabic: all new labels resolve via i18n keys.


## Test cases

### Create (admin)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-USER-ADMIN-WIZARD-001 | Verify Open `/admin-leader/users/create` as admin: wizard loads, lookups (roles, locations, leaders) populate. | Main | - | 1. Open `/admin-leader/users/create` as admin: wizard loads, lookups (roles, locations, leaders) populate. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-USER-ADMIN-WIZARD-002 | Verify Complete steps 0–4 with valid data: submit calls `new-user` API; success toast; redirect to `list-users`; list refresh fires. | Main | - | 1. Complete steps 0–4 with valid data: submit calls `new-user` API; success toast; redirect to `list-users`; list refresh fires. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-USER-ADMIN-WIZARD-003 | Verify Validation: step 0 missing required fields blocks **Next**; step 1 phone rule matches location (Egypt/Saudi) like legacy register. | Main | - | 1. Validation: step 0 missing required fields blocks **Next**; step 1 phone rule matches location (Egypt/Saudi) like legacy register. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-USER-ADMIN-WIZARD-004 | Verify Validation visibility: when **Next** is blocked on any step, user sees inline banner + field-level errors without submitting the full wizard. | Edge | - | 1. Validation visibility: when **Next** is blocked on any step, user sees inline banner + field-level errors without submitting the full wizard. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-05 | EXCP-USER-ADMIN-WIZARD-005 | Verify `auth/register` redirects to `/admin-leader/users/create` (old bookmarks still work). | Main | - | 1. `auth/register` redirects to `/admin-leader/users/create` (old bookmarks still work). | The result matches the scenario description when you follow the actions in the product. | - |

### Edit (admin)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-USER-ADMIN-WIZARD-006 | Verify From list, **Edit** opens `/admin-leader/users/{id}/edit`; `get-user-for-admin-edit` fills the form. | Main | - | 1. From list, **Edit** opens `/admin-leader/users/{id}/edit`; `get-user-for-admin-edit` fills the form. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-07 | EXCP-USER-ADMIN-WIZARD-007 | Verify **Leader** and **roles** can be changed; **Active** switch only in edit; save calls `update-user-by-admin`. | Main | - | 1. *Leader** and **roles** can be changed; **Active** switch only in edit; save calls `update-user-by-admin`. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-08 | EXCP-USER-ADMIN-WIZARD-008 | Verify **Security step**: if **new password** is empty → only profile update; if **new password** is filled → both `confirmNewPassword` and `adminPassword` are required; success runs `set-user-password-by... | Edge | - | 1. *Security step**: if **new password** is empty → only profile update; if **new password** is filled → both `confirmNewPassword` and `adminPassword` are required; success runs `set-user-password-by-admin` after update when valid and matching. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-09 | EXCP-USER-ADMIN-WIZARD-009 | Verify Eye icon behavior: each password field (`newPassword`, `confirmNewPassword`, `adminPassword`) toggles visible/hidden text independently. | Main | - | 1. Eye icon behavior: each password field (`newPassword`, `confirmNewPassword`, `adminPassword`) toggles visible/hidden text independently. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-10 | EXCP-USER-ADMIN-WIZARD-010 | Verify Wrong admin password: error toast, user stays on flow. | Edge | - | 1. Wrong admin password: error toast, user stays on flow. | The result matches the scenario description when you follow the actions in the product. | - |

### Authorization / UX

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-USER-ADMIN-WIZARD-011 | Verify Non-admin cannot open create/edit routes (guards). | Main | - | 1. Non-admin cannot open create/edit routes (guards). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-12 | EXCP-USER-ADMIN-WIZARD-012 | Verify Step pills: completed steps clickable to go back; future steps disabled. | Main | - | 1. Step pills: completed steps clickable to go back; future steps disabled. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-13 | EXCP-USER-ADMIN-WIZARD-013 | Verify English/Arabic: all new labels resolve via i18n keys. | Main | - | 1. English/Arabic: all new labels resolve via i18n keys. | The result matches the scenario description when you follow the actions in the product. | - |

### Edge cases

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-USER-ADMIN-WIZARD-014 | Verify Leader cleared (empty): allowed if API accepts null/omit (dropdown clear). | Edge | - | 1. Leader cleared (empty): allowed if API accepts null/omit (dropdown clear). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-15 | EXCP-USER-ADMIN-WIZARD-015 | Verify Very long usernames/emails: client validators + server 409/400 handled via Swal. | Main | - | 1. Very long usernames/emails: client validators + server 409/400 handled via Swal. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-16 | EXCP-USER-ADMIN-WIZARD-016 | Verify Network failure on load: error toast, no partial orphan state beyond empty form. | Edge | - | 1. Network failure on load: error toast, no partial orphan state beyond empty form. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-17 | EXCP-USER-ADMIN-WIZARD-017 | Verify Step 1 with empty `phoneNumber`/`job`/`location`/`dateOfAppointment`: wizard stays on step and renders explicit errors for each invalid control. | Edge | - | 1. Step 1 with empty `phoneNumber`/`job`/`location`/`dateOfAppointment`: wizard stays on step and renders explicit errors for each invalid control. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-18 | EXCP-USER-ADMIN-WIZARD-018 | Verify User whose leader is not in the `leaders-names-and-ids` list: leader is injected from loaded profile so dropdown shows correct selection. | Main | - | 1. User whose leader is not in the `leaders-names-and-ids` list: leader is injected from loaded profile so dropdown shows correct selection. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-19 | EXCP-USER-ADMIN-WIZARD-019 | Verify Dropdown clear button: visible but does not overlap the selected text label. | Main | - | 1. Dropdown clear button: visible but does not overlap the selected text label. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-20 | EXCP-USER-ADMIN-WIZARD-020 | Verify Review step leader row shows `leaderUsername - leaderEmail` when available, and never shows raw GUID as the primary label. | Main | - | 1. Review step leader row shows `leaderUsername - leaderEmail` when available, and never shows raw GUID as the primary label. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-21 | EXCP-USER-ADMIN-WIZARD-021 | Verify Security step mismatch: `confirmNewPassword` different from `newPassword` blocks moving to the review step and shows mismatch validation message. | Main | - | 1. Security step mismatch: `confirmNewPassword` different from `newPassword blocks moving to the review step and shows mismatch validation message. | The result matches the scenario description when you follow the actions in the product. | - |
