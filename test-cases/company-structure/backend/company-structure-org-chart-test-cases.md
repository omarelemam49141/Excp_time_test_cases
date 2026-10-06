# Company structure — test cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/company-structure/Get-active-graph`, `POST /api/company-structure/Save-graph`, `POST /api/company-structure/Get-snapshots`, `POST /api/company-structure/Restore-from-snapshot`
- Related code: `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`
- Related docs: `docs/backend/technical/company-structure-org-chart.md`, `docs/backend/technical/company-structure-read-vs-save-authorization.md`, `docs/backend/technical/company-structure-data-protection.md`
- Automation: `test/Excp.HRSystem.Application.Tests/CompanyStructure/OrgStructureTeamRulesTests.cs`, `test/Excp.HRSystem.Application.Tests/CompanyStructure/OrgStructureDestructiveSaveRulesTests.cs`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Any authenticated user may **read** the active graph (`POST Get-active-graph`); only **Admin** or **HR** may **save** (`POST Save-graph`).
- Save graph synchronizes Identity role with node `StructureKind`.
- Role change triggers forced logout (refresh tokens revoked, SignalR notification sent).
- HR-only JWT (`roles` contains `"HR"`) can use standard workforce APIs (for example notification unread count) without **403**.
- Primary reporting line drives `LeaderId`; secondary lines do not.
- Validation rejects invalid graphs (cycle, employee as manager, duplicate user, bad primary flags).
- Save-graph blocks a payload that drops all reporting lines (or under half) unless `confirmDestructiveChange` is true.
- Restore of an empty or zero-line snapshot over a live chart with lines requires `confirmWipe`.
- While `IsTeamLayout` is false, Get-active-graph hides the old person chart and returns empty `teams`, plus `legacyNodeCount` / `legacyEdgeCount`.
- `OrgStructureTeamRules` rejects duplicate team names, bad membership, bad badges, two parents, team cycles, missing/extra outside supervisors, employee-as-parent, and person cycles.
- Save-graph runs team rules, upserts teams and membership, sets `IsTeamLayout`, and includes `teams` in snapshot JSON.
- First confirmed save replaces old people and old team rows. Second save still returns those teams on Get-active-graph.
- Restore-from-snapshot rejects a snapshot with no teams. Empty editor must send `expectedExistingNodeCount` = `legacyNodeCount`.


## Delivery waves

| Wave | Intent | Keys |
|------|--------|------|
| 5 | Empty Get-active-graph + team graph rules (save still old) | `EXCP-ORG-HRS-ORG-CHART-040` … `EXCP-ORG-HRS-ORG-CHART-052` |
| 6 | Save writes teams; restore rejects old snapshots | `EXCP-ORG-HRS-ORG-CHART-053` … `EXCP-ORG-HRS-ORG-CHART-056` |


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

### CS-BE-02c

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03b | EXCP-ORG-HRS-ORG-CHART-035 | Verify HR user can load notification unread count | Main | User has Identity role **HR** only; JWT `roles` claim is `["HR"]`. | 1. `GET /api/Notifications/unread-count` with Bearer token | **200** with numeric `data` (not **403** `/Error?httpStatusCode=403`) | - |

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

### CS-BE-24 — Data protection

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-29 | EXCP-ORG-HRS-ORG-CHART-029 | Verify destructive save blocked without confirm | Main | DB has **10+** active nodes for the version. | 1. Admin `POST Save-graph` with only **2** nodes and **no** `confirmDestructiveChange`. | **400** user-friendly error; DB still has original node count. | - |
| TC-30 | EXCP-ORG-HRS-ORG-CHART-030 | Verify destructive save allowed with confirm | Main | Same as TC-29. | 1. Repeat with `confirmDestructiveChange: true`. | **200**; DB node count matches payload; a new row exists in `OrgStructureGraphSnapshots`. | - |
| TC-31 | EXCP-ORG-HRS-ORG-CHART-031 | Verify expected node count mismatch | Edge | DB has N nodes; client sends `expectedExistingNodeCount` not equal to N. | 1. Admin save with valid graph but wrong `expectedExistingNodeCount`. | **400** reload message; no graph change. | - |
| TC-32 | EXCP-ORG-HRS-ORG-CHART-032 | Verify pre-save snapshot and restore | Main | Graph with at least 5 nodes saved once (creates snapshot). | 1. `POST Get-snapshots` for version.<br>2. Save a smaller graph with confirm.<br>3. `POST Restore-from-snapshot` with prior snapshot id. | Snapshots list non-empty; after restore, node count matches snapshot `nodeCount`. | - |
| TC-33 | EXCP-ORG-HRS-ORG-CHART-033 | Verify removed nodes are soft-deleted | Main | Graph had user U; save graph without U (with confirm if mass shrink). | 1. Query `OrgStructureNodes` for U's row. | Row exists with `IsDeleted = 1` (not physically deleted). | - |
| TC-34 | EXCP-ORG-HRS-ORG-CHART-034 | Verify Save-graph audited | Main | Auditing enabled on environment. | 1. Admin save graph.<br>2. Query `AbpAuditLogs` for `Save-graph`. | Row exists with `UserId` of admin and recent `ExecutionTime`. | - |

### CS-BE-25 — Wave 3 edge wipe

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-35 | EXCP-ORG-HRS-ORG-CHART-036 | Verify zero-edge save blocked without confirm | Main | DB has people **and** reporting lines for the version. | 1. Admin `POST Save-graph` with the same nodes and **zero** edges, without `confirmDestructiveChange`. | **400** user-friendly error.<br>DB node and edge counts are unchanged. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureDestructiveSaveRules.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |
| TC-36 | EXCP-ORG-HRS-ORG-CHART-037 | Verify zero-edge save allowed with confirm | Main | Same as TC-35. | 1. Repeat with `confirmDestructiveChange: true`. | **200**.<br>Saved graph has the same people and zero edges. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureDestructiveSaveRules.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |

### CS-BE-26 — Wave 4 restore wipe

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-37 | EXCP-ORG-HRS-ORG-CHART-038 | Verify zero-line restore blocked without confirmWipe | Main | Live chart has reporting lines. A snapshot exists with 0 edges (or 0 nodes). | 1. Admin `POST Restore-from-snapshot` with that snapshot id and `confirmWipe: false`. | **400** user-friendly error.<br>Live graph is unchanged. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureDestructiveSaveRules.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |
| TC-38 | EXCP-ORG-HRS-ORG-CHART-039 | Verify zero-line restore allowed with confirmWipe | Main | Same as TC-37. | 1. Repeat with `confirmWipe: true`. | **200**.<br>Graph matches the snapshot. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureDestructiveSaveRules.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |

### Wave 5 — Empty read + team rules

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-39 | EXCP-ORG-HRS-ORG-CHART-040 | Verify Get-active-graph hides the old chart while IsTeamLayout is false | Main | Version has live `OrgStructureNodes` / `OrgStructureEdges`. `OrgStructureVersions.IsTeamLayout` is 0. Migration applied (`ParentUserId`, `IsTeamLayout`). | 1. Any authenticated user `POST /api/company-structure/Get-active-graph` with `{}`.<br>2. Query `OrgStructureNodes` and `OrgStructureEdges` for the version. | 1. **200**.<br>2. `nodes`, `edges`, and `teams` are empty arrays.<br>3. `legacyNodeCount` equals the live node count.<br>4. `legacyEdgeCount` equals the live edge count.<br>5. Live rows are still in the database (`IsDeleted = 0`). | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-40 | EXCP-ORG-HRS-ORG-CHART-041 | Verify Get-active-graph returns teams when IsTeamLayout is true | Main | Set `OrgStructureVersions.IsTeamLayout = 1` for the active version. At least one `Teams` row and matching `AbpUsers.TeamId`. | 1. `POST /api/company-structure/Get-active-graph` `{}`. | 1. **200**.<br>2. `teams` includes that team `id`, `name`, `leaderUserId`, `parentTeamId`, `parentUserId`.<br>3. Member nodes include `teamId` from `AbpUsers.TeamId`. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |
| TC-41 | EXCP-ORG-HRS-ORG-CHART-042 | Verify duplicate team names fail the team rules | Edge | - | 1. Build a graph payload with teams named `"Backend"` and `" backend "`.<br>2. Run `OrgStructureTeamRules.Validate` (or Save after it is wired). | Validation includes the duplicate-name error. Names that differ only by case or spaces are treated as the same. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-42 | EXCP-ORG-HRS-ORG-CHART-043 | Verify Employee or Leader without a team fails | Edge | - | 1. Node kind Employee or Leader with `teamId` null. | Validation includes the must-belong-to-a-team error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-43 | EXCP-ORG-HRS-ORG-CHART-044 | Verify Admin or HR with a team fails | Edge | - | 1. Node kind Admin or HR with a non-empty `teamId`. | Validation includes the must-sit-above-teams error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-44 | EXCP-ORG-HRS-ORG-CHART-045 | Verify team badge must be a Leader in that team | Edge | - | 1. Set `leaderUserId` to an Employee in the team, or to a Leader in another team. | Validation includes the badge error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-45 | EXCP-ORG-HRS-ORG-CHART-046 | Verify a team cannot have both parents | Edge | - | 1. Set both `parentTeamId` and `parentUserId` on one team. | Validation includes the one-parent error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-46 | EXCP-ORG-HRS-ORG-CHART-047 | Verify team parent cycle fails | Edge | - | 1. Team A parent is B, team B parent is A. | Validation includes the team cycle error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-47 | EXCP-ORG-HRS-ORG-CHART-048 | Verify a person with no in-team manager needs one outside supervisor | Edge | - | 1. Leader in a team has no in-team parent and no outside parent edge. | Validation includes the missing-supervisor error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-48 | EXCP-ORG-HRS-ORG-CHART-049 | Verify outside supervisor must be a Leader in another team or Admin/HR | Edge | - | 1. Person with no in-team manager reports to an Employee. | Validation includes the invalid-supervisor error and the employee-cannot-be-parent error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-49 | EXCP-ORG-HRS-ORG-CHART-050 | Verify an in-team manager cannot also have an outside supervisor | Edge | - | 1. Employee already reports to a Leader in the same team.<br>2. Add a second incoming edge from Admin. | Validation includes the extra-outside-supervisor error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-50 | EXCP-ORG-HRS-ORG-CHART-051 | Verify person reporting cycle fails | Edge | - | 1. Leader → Employee and Employee → Leader. | Validation includes the person-cycle error. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-51 | EXCP-ORG-HRS-ORG-CHART-052 | Verify a valid team graph passes the team rules | Main | - | 1. One Admin above a team, badge Leader in the team, Employee under that Leader, Admin is the Leader's outside supervisor. | `OrgStructureTeamRules.Validate` returns no errors. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |

### Wave 6 — Save teams and restore

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-52 | EXCP-ORG-HRS-ORG-CHART-053 | Verify first team save replaces old people and old teams | Main | `IsTeamLayout` is 0. Live org-chart nodes/edges exist. At least one old `Teams` row is not in the new payload. Admin or HR token. | 1. `POST Get-active-graph` `{}` and read `legacyNodeCount`.<br>2. `POST Save-graph` with a valid team graph (`teams`, node `teamId`, supervisor edges), `confirmDestructiveChange: true`, and `expectedExistingNodeCount` equal to `legacyNodeCount`. | 1. **200**.<br>2. Active nodes/edges match the payload (removed people are `IsDeleted = 1`).<br>3. Payload teams exist; teams missing from the payload are `IsDeleted = 1`.<br>4. `OrgStructureVersions.IsTeamLayout` is 1.<br>5. Member `AbpUsers.TeamId` matches node `teamId`. Admin/HR `TeamId` is null. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |
| TC-53 | EXCP-ORG-HRS-ORG-CHART-054 | Verify second save reloads the same teams | Main | TC-52 succeeded. | 1. `POST Get-active-graph` `{}`.<br>2. `POST Save-graph` with the same teams/nodes/edges (`confirmDestructiveChange` as required). | 1. Get returns those `teams` and member `teamId` values.<br>2. After the second save, Get still returns the same team `id`, `name`, `leaderUserId`, `parentTeamId`, `parentUserId`. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` | - |
| TC-54 | EXCP-ORG-HRS-ORG-CHART-055 | Verify restore of a snapshot with no teams fails | Edge | A snapshot payload has empty or missing `teams` (old person-only backup). Live chart already has a team layout, or use any live version. | 1. Admin `POST Restore-from-snapshot` with that snapshot id (`confirmWipe` true or false). | 1. **400** with the no-teams backup message.<br>2. Live graph is unchanged. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureTeamRules.cs` | - |
| TC-55 | EXCP-ORG-HRS-ORG-CHART-056 | Verify empty editor still sends legacy node counts | Edge | `IsTeamLayout` is 0. Live node count N is greater than 0. | 1. `POST Get-active-graph` `{}`. Confirm empty `nodes` and `legacyNodeCount` = N.<br>2. `POST Save-graph` with a valid small team graph, `confirmDestructiveChange: true`, and `expectedExistingNodeCount: 0`. | 1. **400** expected-count mismatch.<br>2. Live rows unchanged.<br>3. Repeat with `expectedExistingNodeCount` = N and the save is not rejected for count mismatch. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureDestructiveSaveRules.cs` | - |

