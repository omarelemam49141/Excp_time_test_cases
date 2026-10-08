# Company structure — leader permissions (backend)

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: -
- APIs: `GET/PUT /api/company-structure-leader-permissions`, `GET/PUT /api/company-structure-leader-permissions/team/{teamId}`, `POST /api/company-structure/Get-active-graph`, `POST /api/company-structure/Save-graph`
- Related code: `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureLeaderPermissionsAppService.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureLeaderSaveAuthorizer.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureLeaderPermissionResolver.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs`
- Related docs: `docs/backend/technical/company-structure-leader-permissions.md`, `docs/backend/technical/company-structure-read-vs-save-authorization.md`
- Automation: `test/Excp.HRSystem.Application.Tests/CompanyStructure/OrgStructureLeaderPermissionResolverTests.cs`

## Scope

- Global leader permission pack (all flags default false).
- HR may configure only when Admin enables `hrCanConfigureLeaderPermissions`.
- Per-team whole-pack inherit or override (not via Save-graph).
- Get-active-graph returns `viewerCapabilities`.
- Leader Save-graph allowed only within pack and scope; Employee Save-graph forbidden.

## Test scenarios

- Admin updates global pack and HR configure flag.
- HR blocked from PUT global when HR flag is false.
- Team override inherit clears custom JSON.
- Leader with enabled flag can save allowed member change.
- Leader without flag gets rejection on forbidden graph change.
- Employee Save-graph returns 403.

## Test cases

### Global settings

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ORG-LEADER-PERM-001 | Verify Admin can read global leader permissions | Main | Admin token | 1. `GET /api/company-structure-leader-permissions` | **200**; `pack` object with all flags false by default | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureLeaderPermissionsAppService.cs` |
| TC-02 | EXCP-ORG-LEADER-PERM-002 | Verify HR cannot update global when HR flag is false | Edge | HR token; `hrCanConfigureLeaderPermissions` is false | 1. `PUT /api/company-structure-leader-permissions` with any body | **403** | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureLeaderPermissionsAppService.cs` |
| TC-03 | EXCP-ORG-LEADER-PERM-003 | Verify Get-active-graph includes viewerCapabilities for Leader | Main | Leader on chart; at least one pack flag enabled for their team | 1. `POST Get-active-graph` `{}` | **200**; `viewerCapabilities.canSaveAsLeader` is true when a flag is on | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` |

### Leader save

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-04 | EXCP-ORG-LEADER-PERM-004 | Verify Employee Save-graph forbidden | Edge | Employee token | 1. `POST Save-graph` with valid admin-shaped body | **403** | `src/Excp.HRSystem.HttpApi/Controllers/CompanyStructure/CompanyStructureController.cs` |
| TC-05 | EXCP-ORG-LEADER-PERM-005 | Verify Leader cannot add a team | Edge | Leader token; `addFreeMember` false | 1. `POST Save-graph` with an extra team id not in DB | User-friendly error or **403**; DB unchanged | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureLeaderSaveAuthorizer.cs` |
