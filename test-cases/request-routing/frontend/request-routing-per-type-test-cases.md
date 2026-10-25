# Request routing per request type (frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `request-routing`
- Layer: `frontend`
- Routes: `/admin/company-structure`
- APIs: `GET /api/request-routing-type-overrides`, `PUT /api/request-routing-type-overrides`, `DELETE /api/request-routing-type-overrides`
- Related code: `src/app/features/admin-leader/admin/components/company-structure/request-routing-dialog.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/services/request-routing-type-overrides.service.ts`
- Related docs: `docs/frontend/technical/request-routing-per-request-type.md`

## Scope

- Request type picker in the global and team routing dialog; per-type settings are saved immediately.

## Test scenarios

- Picker shows all types and active types only
- Per-type override for global and for a team
- Inherit removes the override

## Test cases

### Wave 1 — Routing dialog

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-REQ-ROUTE-TYPE-UI-001 | Verify the picker lists "All types (default)" and the active request types. | Main | EXCP-REQ-ROUTE-TYPE-010 | 1. Sign in as Admin.<br>2. Open Company structure, the global routing settings. | 1. The first option is "All types (default)".<br>2. Every active request type is listed and the list is searchable. |
| TC-02 | EXCP-REQ-ROUTE-TYPE-UI-002 | Verify a global per-type override saves and reloads. | Main | EXCP-REQ-ROUTE-TYPE-UI-001 | 1. Pick a request type.<br>2. Uncheck "Use the default routing for this type".<br>3. Set direct leaders to notification only and apply.<br>4. Reopen and pick the same type. | 1. A success message is shown.<br>2. The type shows notification only and the other types are unchanged. |
| TC-03 | EXCP-REQ-ROUTE-TYPE-UI-003 | Verify a team per-type override is separate from the global one. | Main | EXCP-REQ-ROUTE-TYPE-UI-002 | 1. Open a team's routing settings and pick the same type.<br>2. Override direct leaders to request only and apply. | 1. The team shows request only for that type.<br>2. The global dialog still shows notification only. |
| TC-04 | EXCP-REQ-ROUTE-TYPE-UI-004 | Verify checking "Use the default routing" removes the override. | Edge | EXCP-REQ-ROUTE-TYPE-UI-002 | 1. Pick the type again, check the box and apply.<br>2. Reopen the type. | 1. The box is checked after reopening and the type follows the defaults. |
| TC-05 | EXCP-REQ-ROUTE-TYPE-UI-005 | Verify "All types" still saves the old way. | Edge | EXCP-REQ-ROUTE-TYPE-UI-001 | 1. Keep "All types (default)", change a mode and apply. | 1. The default saves as before and per-type overrides stay. |
