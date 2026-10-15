# Company structure — default Admin/HR bootstrap (frontend)

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/company-structure`, `/admin-leader/users`
- APIs: `-`
- Related code: `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-board.component.html`, `src/app/features/admin-leader/shared/components/list-users/list-users-info-table/list-users-info-table.component.ts`
- Related docs: `docs/backend/technical/company-structure-default-admin-hr.md`

## Scope

- Empty company structure board shows Admin/HR users returned from Get-active-graph.
- System admin chip has no remove control; other admins can still be removed.
- Users list hides delete for system admin.

## Test scenarios

- Admin opens company structure on a fresh chart → Admin/HR strip populated.
- Protected admin cannot be removed from chart or users list.

## Test cases

### Company structure UI

| ID | Key | Case | Steps | Expected | Related code |
|----|-----|------|-------|----------|--------------|
| TC-01 | EXCP-ORG-BOOTSTRAP-FE-001 | Verify Admin/HR strip on empty board | 1. Sign in as Admin.<br>2. Open `/admin/company-structure` when backend has Admin/HR users and no teams. | 1. **Admin/HR** section lists those users (not empty).<br>2. No teams required to see the strip. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-board.component.html` |
| TC-02 | EXCP-ORG-BOOTSTRAP-FE-002 | Verify system admin chip has no remove button | 1. Open company structure.<br>2. Find the user marked `isSystemAdmin` on their node. | 1. No trash/remove control on that chip.<br>2. Another non-system Admin chip still shows remove when editor. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-board.component.html` |
| TC-03 | EXCP-ORG-BOOTSTRAP-FE-003 | Verify users list hides delete for system admin | 1. Sign in as Admin.<br>2. Open users list.<br>3. Locate system admin row (`isSystemAdmin` true). | 1. No **Delete** action on that row.<br>2. Bulk select does not include that row. | `src/app/features/admin-leader/shared/components/list-users/list-users-info-table/list-users-info-table.component.ts` |
