# Company structure — test cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`, `src/Excp.HRSystem.HttpApi/Controllers/CompanyStructure/CompanyStructureController.cs`, `src/Excp.HRSystem.Application.Contracts/Services/CompanyStructure/FluentValidations/SaveOrgStructureInputValidation.cs`
- Related docs: `docs/backend/technical/company-structure-org-chart.md`, `docs/backend/technical/company-structure-read-vs-save-authorization.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Any authenticated user may **read** the active graph (`POST Get-active-graph`); only **Admin** or **HR** may **save** (`POST Save-graph`).
- Save graph synchronizes Identity role with node `StructureKind`.
- Role change triggers forced logout (refresh tokens revoked, SignalR notification sent).
- Primary reporting line drives `LeaderId`; secondary lines do not.
- Validation rejects invalid graphs (cycle, employee as manager, duplicate user, bad primary flags).


## Test cases

### CS-BE-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ORG-HRS-ORG-CHART-001 | Verify Admin get graph | Edge | - | 1. Admin `POST /api/company-structure/Get-active-graph` `{}` | 200; `versionId` set; arrays may be empty on first run | - |

### CS-BE-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-ORG-HRS-ORG-CHART-002 | Verify Employee or Leader can read active graph | Main | Valid Bearer for user with role **Employee** or **Leader** (not Admin/HR). | 1. `POST /api/company-structure/Get-active-graph` with body `{}` | **200**; response includes **`versionId`** and **`nodes`** / **`edges`** arrays (may be empty). | - |

### CS-BE-02a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-ORG-HRS-ORG-CHART-003 | Verify HR allowed | Main | - | 1. User with Identity role `HR` and valid Bearer token calls `Get-active-graph` | 200 | - |

### CS-BE-02b

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-ORG-HRS-ORG-CHART-004 | Verify Admin allowed | Main | - | 1. Admin Bearer token | 200 | - |

### CS-BE-11

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-ORG-HRS-ORG-CHART-005 | Verify Save-graph JWT role + dynamic claims | Edge | - | 1. Admin or HR token uses JSON **`roles`** claim only; `POST /api/company-structure/Save-graph` with Bearer and a valid graph body | **200** — **`Save-graph`** uses `[JWTRoleAuthorize]` so roles are read from the JWT even when `UseDynamicClaims` replaces the principal | - |

### CS-BE-03

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-ORG-HRS-ORG-CHART-006 | Verify Save simple chain | Main | - | 1. Nodes: A (Leader), B (Employee). Edges: A→B primary | 200; B.`LeaderId` = A’s user id | - |

### CS-BE-03a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-ORG-HRS-ORG-CHART-007 | Verify Promote employee to leader updates Identity role | Main | - | 1. Existing user U currently has role `Employee`; set U node `StructureKind = Leader` and save graph | 200; U no longer has org-role `Employee`; U has org-role `Leader` | - |

### CS-BE-03b

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-ORG-HRS-ORG-CHART-008 | Verify Demote leader to employee updates Identity role | Main | - | 1. Existing user U currently has role `Leader`; set U node `StructureKind = Employee` and save graph | 200; U no longer has org-role `Leader`; U has org-role `Employee` | - |

### CS-BE-03c

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-ORG-HRS-ORG-CHART-009 | Verify Keep non-org custom roles | Main | - | 1. User U has custom role (non Employee/Leader/Admin/HR) plus an org role; change U `StructureKind` and save | Org role is updated to target role; custom role remains assigned | - |

### CS-BE-04

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-ORG-HRS-ORG-CHART-010 | Verify Root clears leader | Main | - | 1. Single node A, no edges | A’s `LeaderId` null after save | - |

### CS-BE-05

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-ORG-HRS-ORG-CHART-011 | Verify Multi-parent primary | Main | - | 1. B has edges from A and C; mark C primary | B.`LeaderId` = C’s user id | - |

### CS-BE-06

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-12 | EXCP-ORG-HRS-ORG-CHART-012 | Verify Multi-parent no primary | Edge | - | 1. Two parents, both `isPrimary: false` | 400 / user-friendly error | - |

### CS-BE-07

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-ORG-HRS-ORG-CHART-013 | Verify Employee as parent | Edge | - | 1. Edge from Employee to Leader | User-friendly error | - |

### CS-BE-08

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-ORG-HRS-ORG-CHART-014 | Verify Cycle | Edge | - | 1. A→B, B→A | User-friendly error | - |

### CS-BE-09

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-ORG-HRS-ORG-CHART-015 | Verify Duplicate user | Edge | - | 1. Two nodes same `userId` | User-friendly error | - |

### CS-BE-10

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-16 | EXCP-ORG-HRS-ORG-CHART-016 | Verify HR role seeded | Main | - | 1. New environment data seed | Identity role `HR` exists | - |

### CS-BE-12

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-17 | EXCP-ORG-HRS-ORG-CHART-017 | Verify Save same version twice | Main | - | 1. Save valid graph, then edit node title/position and save again with same node ids | Both calls return success; no `OrgStructureNode` duplicate tracking exception | - |

### CS-BE-13

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-18 | EXCP-ORG-HRS-ORG-CHART-018 | Verify Pending request direct leader swap | Main | - | 1. User U has pending request routed to old leader A; update org chart so U direct leader is B; save graph | Pending request receivers replace A with B; admin receivers stay unchanged | - |

### CS-BE-14

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-ORG-HRS-ORG-CHART-019 | Verify Pending request new leader already receiver | Main | - | 1. Pending request includes both old leader A and new leader B (for any reason); change U leader A -> B and save graph | Old leader A receiver is removed; B remains single receiver (no duplicates) | - |

### CS-BE-15

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-ORG-HRS-ORG-CHART-020 | Verify Pending request leader removed | Main | - | 1. Pending request routed to leader A; update graph so U has no direct leader and save graph | Old leader A receiver is removed from pending request | - |

### CS-BE-16

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-21 | EXCP-ORG-HRS-ORG-CHART-021 | Verify Finalized request immutable | Edge | - | 1. Request status is Approved/Rejected/Cancelled with old leader A receiver; change structure A -> B and save graph | Request receivers are unchanged | - |

### CS-BE-17

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-ORG-HRS-ORG-CHART-022 | Verify JWT reflects new role after refresh/login | Main | - | 1. Promote U from Employee to Leader in graph, then login or refresh token as U | Token `roles` contains `Leader`; frontend leader checks pass (`isUserAdminOrLeader` true) | - |

### CS-BE-18

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-ORG-HRS-ORG-CHART-023 | Verify Forced logout on role change — tokens revoked | Main | - | 1. User U is logged in as Employee; Admin promotes U to Leader via company structure save | All U's refresh tokens in database have `IsRevoked = true` | - |

### CS-BE-19

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-24 | EXCP-ORG-HRS-ORG-CHART-024 | Verify Forced logout on role change — SignalR event sent | Main | - | 1. User U is connected via SignalR as Employee; Admin promotes U to Leader via company structure save | U receives SignalR `ForceLogout` event | - |

### CS-BE-20

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-25 | EXCP-ORG-HRS-ORG-CHART-025 | Verify Frontend handles ForceLogout | Main | - | 1. U is logged in on frontend, connected via AttendanceHubService; backend sends `ForceLogout` | Frontend displays role change dialog and redirects to login | - |

### CS-BE-21

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-26 | EXCP-ORG-HRS-ORG-CHART-026 | Verify No forced logout when role unchanged | Main | - | 1. User U is already Leader; Admin saves graph keeping U as Leader | U's refresh tokens remain valid; no SignalR `ForceLogout` sent | - |

### CS-BE-22

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-27 | EXCP-ORG-HRS-ORG-CHART-027 | Verify Bulk role change forced logout | Main | - | 1. Multiple users (U1, U2) have roles changed in single graph save | All affected users receive `ForceLogout`; all their tokens are revoked | - |

### CS-BE-23

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-28 | EXCP-ORG-HRS-ORG-CHART-028 | Verify Save-graph forbidden for Employee or Leader | Edge | Valid Bearer for **Employee** or **Leader** (not Admin/HR).<br>A valid saved graph exists (use Admin once to obtain **`versionId`**, **`nodes`**, **`edges`** if needed). | 1. Call **`POST /api/company-structure/Save-graph** with the employee or leader token and a body that would be valid for an admin (same shape as a normal save). | **403** Forbidden.<br>No graph change is applied. | - |
