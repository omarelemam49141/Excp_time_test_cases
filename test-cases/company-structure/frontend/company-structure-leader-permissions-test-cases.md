# Company structure — leader permissions (frontend)

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/company-structure`
- APIs: `GET/PUT /api/company-structure-leader-permissions`, `POST Get-active-graph`, `POST Save-graph`
- Related code: `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.ts`, `src/app/features/admin-leader/admin/services/company-structure-leader-permissions.service.ts`
- Related docs: `docs/frontend/technical/company-structure-org-chart.md`

## Scope

- Structure settings dialog: **Request routing** and **Leader permissions** tabs (Admin/HR routing; permissions when `canConfigureLeaderPermissions`).
- Leaders see Save and team edit only when `viewerCapabilities` allows.
- Employees remain read-only on the chart.

## Test cases

### Settings UI

| ID | Key | Case | Type | Preconditions | Steps | Expected |
|----|-----|------|------|---------------|-------|----------|
| TC-01 | EXCP-ORG-LEADER-PERM-FE-001 | Verify Admin opens structure settings with both tabs | Main | Admin on `/admin/company-structure` | 1. Tap **"Structure settings"**.<br>2. Switch to **"Leader permissions"**. | 1. Dialog opens.<br>2. Member and badge permission groups appear with toggles (all off by default).<br>3. "Edit leader personal routing" is not shown. |
| TC-02 | EXCP-ORG-LEADER-PERM-FE-002 | Verify team inherit whole pack | Main | Admin; team exists | 1. Open team routing/settings.<br>2. On **Leader permissions** tab, check **Use the company default**.<br>3. Apply. | Success toast; team uses global pack. |

### Leader edit

| ID | Key | Case | Type | Preconditions | Steps | Expected |
|----|-----|------|------|---------------|-------|----------|
| TC-03 | EXCP-ORG-LEADER-PERM-FE-003 | Verify badge leader sees Save when a flag is on | Main | Leader is team badge; Admin enabled `addFreeMember` for that team | 1. Open company structure as that leader. | **"Save structure"** is visible.<br>**"Add team"** is not visible. |
| TC-04 | EXCP-ORG-LEADER-PERM-FE-004 | Verify employee stays read-only | Regression | Employee not Admin/HR | 1. Open company structure. | No **Save structure**.<br>No add/remove on cards. |
