# Team overtime gap (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/company-structure`
- APIs: `GET /api/company-structure-team-overtime-gap/team/{teamId}`, `PUT /api/company-structure-team-overtime-gap/team/{teamId}`
- Related code: `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/services/company-structure-team-overtime-gap.service.ts`
- Related docs: `docs/frontend/technical/team-overtime-gap.md`

## Scope

- Overtime gap tab in the team settings dialog: site and home inputs with an "Inherit global value" toggle.

## Test scenarios

- Tab visible for a team
- Inherit and override
- Saved value used at end work

## Test cases

### Wave 1 — Team settings

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-OT-GAP-TEAM-UI-001 | Verify the Overtime gap tab appears in a team's settings dialog and shows the global value. | Main | EXCP-OT-GAP-TEAM-001 | 1. Sign in as Admin or HR.<br>2. Open Company structure and a team's settings.<br>3. Open the **Overtime gap** tab. | 1. Site and home show **Inherit global value** checked with the global minutes.<br>2. The tab is not shown in the global settings dialog. |
| TC-02 | EXCP-OT-GAP-TEAM-UI-002 | Verify an override saves and reloads. | Main | EXCP-OT-GAP-TEAM-UI-001 | 1. Uncheck inherit for site, enter 45.<br>2. Apply and reopen the tab. | 1. A success message is shown.<br>2. Site shows 45 and home still inherits. |
| TC-03 | EXCP-OT-GAP-TEAM-UI-003 | Verify the team gap is the gate at end work for a team member. | Main | EXCP-OT-GAP-TEAM-UI-002, EXCP-ATT-ENDWORK-UI-002 | 1. Team site gap 45, global 30.<br>2. A team member on site works 40 minutes past shift end.<br>3. Tap **End work**. | 1. No split question is shown (40 is under 45). |
