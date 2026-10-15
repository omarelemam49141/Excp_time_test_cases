# Admin user by admin — test cases (backend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Services/Account/CustomAccountAppService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AddNewUserBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/GetUserForAdminEditBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/UpdateUserByAdminBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AdminEmployeeLeaderWrite.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/SetUserPasswordByAdminBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/CheckUserAvailabilityBuilder.cs`
- Related docs: `docs/backend/technical/admin-user-by-admin-api.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Account/AdminEmployeeLeaderWriteTests.cs`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- (Add high-level scenarios here.)


## Test cases

### get-user-for-admin-edit

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-USER-HRS-ADMIN-ADMIN-001 | Verify Valid `userId` → 200, `data` includes profile fields, `roleNames[]`, `leaderId`, `isActive`, `dateOfAppointment`, etc. | Main | - | 1. Valid `userId` → 200, `data` includes profile fields, `roleNames[]`, `leaderId`, `isActive`, `dateOfAppointment`, etc. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-USER-HRS-ADMIN-ADMIN-002 | Verify Invalid/missing user → **404** with localized **“User with this id not found!”** (`ResponseMessages:UserIdNotFound`) — business not-found after route matched. | Edge | - | 1. Invalid/missing user → **404** with localized **“User with this id not found!”** (`ResponseMessages:UserIdNotFound`) — business not-found after route matched. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-USER-HRS-ADMIN-ADMIN-003 | Verify Wrong URL (e.g. typo in path, missing `get-user-for-admin-edit` segment) → **404 from the host** (no app action); distinct from business 404 above. | Main | - | 1. Wrong URL (e.g. typo in path, missing `get-user-for-admin-edit` segment) → **404 from the host** (no app action); distinct from business 404 above. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-USER-HRS-ADMIN-ADMIN-004 | Verify Mixed persisted `LeaderId` representations (`Guid`, serialized JSON string, nullable/empty) still return 200; response normalizes to `leaderId: null` or valid GUID string without server 500. | Edge | - | 1. Mixed persisted `LeaderId` representations (`Guid`, serialized JSON string, nullable/empty) still return 200; response normalizes to `leaderId: null` or valid GUID string without server 500. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-05 | EXCP-USER-HRS-ADMIN-ADMIN-005 | Verify `get-user-for-admin-edit` returns `leaderUsername` and `leaderEmail` when leader exists, enabling UI review label `username - email`. | Main | - | 1. `get-user-for-admin-edit` returns `leaderUsername` and `leaderEmail` when leader exists, enabling UI review label `username - email`. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-06 | EXCP-USER-HRS-ADMIN-ADMIN-006 | Verify `GET api/app/custom-account/get-user-for-admin-edit` | Main | - | 1. `GET api/app/custom-account/get-user-for-admin-edit` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-07 | EXCP-USER-HRS-ADMIN-ADMIN-007 | Verify `PUT api/app/custom-account/update-user-by-admin/{userId}` | Main | - | 1. `PUT api/app/custom-account/update-user-by-admin/{userId}` | The result matches the scenario description when you follow the actions in the product. | - |
| TC-08 | EXCP-USER-HRS-ADMIN-ADMIN-008 | Verify `PUT api/app/custom-account/set-user-password-by-admin/{userId}` | Main | - | 1. `PUT api/app/custom-account/set-user-password-by-admin/{userId}` | The result matches the scenario description when you follow the actions in the product. | - |

### update-user-by-admin

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-USER-HRS-ADMIN-ADMIN-009 | Verify Admin updates core fields, roles replaced (add/remove), and `isActive` toggled without changing stored `LeaderId`. | Main | Employee has `LeaderId` set via company structure | 1. Call `PUT update-user-by-admin` with changed name, job, roles, and `isActive`, and include a different `leaderId` or empty `leaderId` in the body | 1. Response is 200.<br>2. Profile, roles, and active flag match the request.<br>3. Stored `LeaderId` on the user is unchanged. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/UpdateUserByAdminBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AdminEmployeeLeaderWrite.cs` |
| TC-10 | EXCP-USER-HRS-ADMIN-ADMIN-010 | Verify Username/email change blocked when another user already owns the value (409 conflict messages). | Edge | - | 1. Username/email change blocked when another user already owns the value (409 conflict messages). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-11 | EXCP-USER-HRS-ADMIN-ADMIN-011 | Verify Invalid roles list → 400 with validation. | Edge | - | 1. Invalid roles list → 400 with validation. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-12 | EXCP-USER-HRS-ADMIN-ADMIN-012 | Verify Non-admin token → 401/403 (JWTRoleAuthorize). | Edge | - | 1. Non-admin token → 401/403 (JWTRoleAuthorize). | The result matches the scenario description when you follow the actions in the product. | - |

### new-user

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-USER-HRS-ADMIN-ADMIN-013 | Verify Valid payload with `leaderId` as GUID creates user successfully (200) but does not persist `LeaderId`. | Main | Admin token | 1. POST `new-user` with a valid body and `leaderId` set to an existing leader GUID | 1. Response is 200.<br>2. New user has no `LeaderId` in `ExtraProperties` (assign leader via company structure). | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AddNewUserBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AdminEmployeeLeaderWrite.cs` |
| TC-14 | EXCP-USER-HRS-ADMIN-ADMIN-014 | Verify Valid payload with `leaderId` empty string (`""`) or whitespace creates user successfully (200) with no `LeaderId`. | Edge | Admin token | 1. POST `new-user` with `leaderId` as `""` or whitespace | 1. Response is 200.<br>2. New user has no `LeaderId` stored. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AddNewUserBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AdminEmployeeLeaderWrite.cs` |
| TC-15 | EXCP-USER-HRS-ADMIN-ADMIN-015 | Verify Invalid non-empty non-GUID `leaderId` still returns 400 with localized validation error (`InvalidLeaderIdFormat` / "تنسيق معرف المشرف غير صالح"). | Edge | - | 1. Invalid non-empty non-GUID `leaderId` still returns 400 with localized validation error (`InvalidLeaderIdFormat` / "تنسيق معرف المشرف غير صالح"). | The result matches the scenario description when you follow the actions in the product. | - |

### set-user-password-by-admin

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-16 | EXCP-USER-HRS-ADMIN-ADMIN-016 | Verify Valid `newPassword` + valid `adminPassword` (current admin) → 200, target password changed; reset-code extra fields cleared if present. | Main | - | 1. Valid `newPassword` + valid `adminPassword` (current admin) → 200, target password changed; reset-code extra fields cleared if present. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-17 | EXCP-USER-HRS-ADMIN-ADMIN-017 | Verify Wrong `adminPassword` → 400, password not changed. | Main | - | 1. Wrong `adminPassword` → 400, password not changed. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-18 | EXCP-USER-HRS-ADMIN-ADMIN-018 | Verify Invalid `newPassword` (policy) → 400; identity errors surfaced via generic error payload. | Edge | - | 1. Invalid `newPassword` (policy) → 400; identity errors surfaced via generic error payload. | The result matches the scenario description when you follow the actions in the product. | - |

### Edge cases

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-USER-HRS-ADMIN-ADMIN-019 | Verify Admin updates self vs other user: both allowed; password endpoint always requires admin password. | Main | - | 1. Admin updates self vs other user: both allowed; password endpoint always requires admin password. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-20 | EXCP-USER-HRS-ADMIN-ADMIN-020 | Verify Target user without prior password: `RemovePasswordAsync` + `AddPasswordAsync` path still succeeds. | Main | - | 1. Target user without prior password: `RemovePasswordAsync` + `AddPasswordAsync` path still succeeds. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-21 | EXCP-USER-HRS-ADMIN-ADMIN-021 | Verify Concurrent role updates: single transactional UoW in `UpdateUserByAdminBuilder` (verify no deadlocks under load in staging). | Main | - | 1. Concurrent role updates: single transactional UoW in `UpdateUserByAdminBuilder` (verify no deadlocks under load in staging). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-22 | EXCP-USER-HRS-ADMIN-ADMIN-022 | Verify User record with `LeaderId` previously changed by company-structure flow loads successfully in edit API (regression for `Object must implement IConvertible`). | Main | - | 1. User record with `LeaderId` previously changed by company-structure flow loads successfully in edit API (regression for `Object must implement IConvertible`). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-23 | EXCP-USER-HRS-ADMIN-ADMIN-023 | Verify User created with empty/whitespace `leaderId` must not break login/get-profile/get-user-for-admin-edit paths that read leader from `ExtraProperties`; expect no `Guid` conversion exception. | Edge | - | 1. User created with empty/whitespace `leaderId` must not break login/get-profile/get-user-for-admin-edit paths that read leader from `ExtraProperties`; expect no `Guid` conversion exception. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-24 | EXCP-USER-HRS-ADMIN-ADMIN-024 | Verify Leaders lookup endpoint (`leaders-names-and-ids`) includes `leaderEmail` along with id/username for display-only usage. | Main | - | 1. Leaders lookup endpoint (`leaders-names-and-ids`) includes `leaderEmail along with id/username for display-only usage. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-30 | EXCP-USER-HRS-ADMIN-ADMIN-030 | Verify `update-user-by-admin` with empty `leaderId` does not clear a leader set by company structure. | Edge | Employee `LeaderId` set only via company structure save | 1. PUT `update-user-by-admin` with `leaderId` empty or omitted and another field changed | 1. Response is 200.<br>2. `LeaderId` on the user is unchanged. | `src/Excp.HRSystem.Application/Builders/Services/Custom Account/UpdateUserByAdminBuilder.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/AdminEmployeeLeaderWrite.cs` |

### check-user-availability

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-25 | EXCP-USER-HRS-ADMIN-ADMIN-025 | Verify `check-user-availability` reports a taken username and a taken email as unavailable (`isUsernameAvailable=false`, `isEmailAvailable=false`). | Main | - | 1. `check-user-availability` reports a taken username and a taken email as unavailable (`isUsernameAvailable=false`, `isEmailAvailable=false`). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-26 | EXCP-USER-HRS-ADMIN-ADMIN-026 | Verify `check-user-availability` reports a free username and a free email as available. | Main | - | 1. `check-user-availability` reports a free username and a free email as available. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-27 | EXCP-USER-HRS-ADMIN-ADMIN-027 | Verify `check-user-availability` with `excludeUserId` of the owner treats that user's own username/email as available (edit mode). | Edge | - | 1. `check-user-availability` with `excludeUserId` of the owner treats that user's own username/email as available (edit mode). | The result matches the scenario description when you follow the actions in the product. | - |
| TC-28 | EXCP-USER-HRS-ADMIN-ADMIN-028 | Verify `check-user-availability` checks only the supplied field; the other field is `null` in the response. | Edge | - | 1. `check-user-availability` checks only the supplied field; the other field is `null` in the response. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-29 | EXCP-USER-HRS-ADMIN-ADMIN-029 | Verify `check-user-availability` returns 400 when neither username nor email is supplied or `excludeUserId` is not a GUID, and is admin-only (`JWTRoleAuthorize`). | Edge | - | 1. `check-user-availability` returns 400 when neither username nor email is supplied or `excludeUserId` is not a GUID, and is admin-only (`JWTRoleAuthorize`). | The result matches the scenario description when you follow the actions in the product. | - |
