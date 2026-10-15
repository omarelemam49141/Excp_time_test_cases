# Company structure — default Admin/HR bootstrap (backend)

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: `-`
- APIs: `POST /api/company-structure/Get-active-graph`, `POST /api/company-structure/Save-graph`, `PUT /api/app/custom-account/update-user-by-admin/{userId}`
- Related code: `src/Excp.HRSystem.Domain/Data/Users/UsersSeeding.cs`, `src/Excp.HRSystem.Application/Builders/Services/Custom Account/UpdateUserByAdminBuilder.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureAdminHrPlacement.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs`
- Related docs: `docs/backend/technical/company-structure-default-admin-hr.md`
- Automation: `test/Excp.HRSystem.Application.Tests/CompanyStructure/DefaultAdminHrBootstrapTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/RequestRoutingPolicyTests.cs`

## Scope

- Seeded system admin when no Admin exists; protected from Admin role removal and chart removal.
- Get-active-graph places missing Admin/HR users on the chart.
- Request routing adds Admin/HR chart users as **Both** for every issuer (except self).

## Test scenarios

- Fresh environment with no Admin → seed creates `admin` account.
- Environment with an existing Admin → no second seed.
- System admin cannot be demoted via update-user-by-admin.
- Get-active-graph returns Admin/HR nodes for role holders without duplicating users already on a team node.
- Save-graph rejects removing the system admin node.
- Issuer with no leader still routes to all Admin/HR on the chart.

## Test cases

### System admin seed and guards

| ID | Key | Case | Steps | Expected |
|----|-----|------|-------|----------|
| TC-01 | EXCP-ORG-BOOTSTRAP-ADMIN-001 | Verify system admin seed when no Admin exists | 1. Use a database with no user in Admin role.<br>2. Run data seed.<br>3. Sign in as username `admin` with password `Admin7476386#`. | 1. User `admin` exists with Admin role.<br>2. Extra property `IsSystemAdmin` is true.<br>3. Login succeeds. |
| TC-02 | EXCP-ORG-BOOTSTRAP-ADMIN-002 | Verify seed skipped when an Admin already exists | 1. Ensure at least one non-seed Admin user exists.<br>2. Run data seed again. | 1. No additional `admin@excp.local` user is created.<br>2. Existing Admin accounts are unchanged. |
| TC-03 | EXCP-ORG-BOOTSTRAP-ADMIN-003 | Verify system admin cannot lose Admin role | 1. As Admin, call `PUT update-user-by-admin` for the system admin user with roles that omit **Admin**. | 1. **400** with message key `SystemAdminRoleCannotBeRemoved`.<br>2. User still has Admin role. |

### Chart placement and save

| ID | Key | Case | Steps | Expected | Related code |
|----|-----|------|-------|----------|--------------|
| TC-04 | EXCP-ORG-BOOTSTRAP-PLACE-001 | Verify existing Admin appears in Get-active-graph Admin/HR strip | 1. User A has Admin role and no org node.<br>2. `POST Get-active-graph` `{}`. | 1. **200**.<br>2. Response `nodes` includes A with `structureKind` Admin and no `teamId`. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureAdminHrPlacement.cs` |
| TC-05 | EXCP-ORG-BOOTSTRAP-PLACE-002 | Verify existing HR appears on chart | 1. User H has HR role only and no org node.<br>2. `POST Get-active-graph` `{}`. | 1. **200**.<br>2. Response includes H with `structureKind` HR. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureAdminHrPlacement.cs` |
| TC-06 | EXCP-ORG-BOOTSTRAP-PLACE-003 | Verify user already on a team is not moved | 1. User U is Leader on a team node.<br>2. U also has Admin role.<br>3. `POST Get-active-graph` `{}`. | 1. U appears only on the team (existing node).<br>2. No duplicate Admin/HR node for U is inserted. | `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureAdminHrPlacement.cs` |
| TC-07 | EXCP-ORG-BOOTSTRAP-PLACE-004 | Verify Save-graph cannot drop system admin | 1. Load graph including system admin node.<br>2. `POST Save-graph` with that node removed from `nodes`. | 1. **400** user-friendly error `CompanyStructureCannotRemoveSystemAdminFromChart`. | `src/Excp.HRSystem.Application/Services/CompanyStructure/CompanyStructureAppService.cs` |

### Request routing broadcast

| ID | Key | Case | Steps | Expected | Related code |
|----|-----|------|-------|----------|--------------|
| TC-08 | EXCP-ROUTE-ADMIN-HR-001 | Verify employee with no leader still notifies all Admin and HR on chart | 1. Chart has Admin A and HR H in Admin/HR strip.<br>2. Employee E has no `LeaderId` and submits a request. | 1. A and H are request receivers and notification targets (mode Both). | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` |
| TC-09 | EXCP-ROUTE-ADMIN-HR-002 | Verify Admin issuer does not receive own broadcast | 1. Admin A on chart submits a request. | 1. A is not added as a receiver solely from Admin/HR broadcast. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` |
| TC-10 | EXCP-ROUTE-ADMIN-HR-003 | Verify chain hop upgraded to Both when also Admin broadcast | 1. Leader L is also on chart as Admin.<br>2. Employee under L submits a request. | 1. L receives at least **Both** (not RequestOnly-only from chain when broadcast applies). | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
