# Quick Entry copy/import test cases (frontend)

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/features/attendance/components/attendance-quick-entry`, `src/app/core/services/attendance.service.ts`
- Related docs: `docs/frontend/technical/quick-entry-copy-import.md`, `docs/backend/technical/quick-entry-copy-import-api.md`

## Scope

Validate that JSON export/import in Quick Entry has proper environment-based access control:
- Development mode: Both import and export available for all users
- Production mode: Export available for all users, import restricted to admins only


Note: the copy/import controls now sit inside the collapsed "More tools" section (row "Copy period data"); open it before running these cases.

## Test pages

- `/attendance/quick-entry`


## Test scenarios

- Transfer panel is visible for all users in both environments.
- Export button is always visible for all users.
- Import button visibility depends on environment and user role.
- Import textarea visibility depends on environment and user role.
- Admin export/import works for current period.
- Admin export/import works with `Admin target user id`.
- Invalid JSON and schema validation remain enforced.


## Test cases

### Development Mode Tests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-COPY-IMPORT-001 | Verify QECI-DEV-01 — Regular user panel visibility | Main | - | 1. Build with `ng serve` (dev mode), login as regular user, open `/attendance/quick-entry` | Transfer panel is visible | - |
| TC-02 | EXCP-QE-COPY-IMPORT-002 | Verify QECI-DEV-02 — Regular user export | Main | - | 1. As regular user in dev mode, click Export JSON | JSON is produced and success feedback appears | - |
| TC-03 | EXCP-QE-COPY-IMPORT-003 | Verify QECI-DEV-03 — Regular user import visible | Main | - | 1. As regular user in dev mode | Import button and textarea are visible | - |
| TC-04 | EXCP-QE-COPY-IMPORT-004 | Verify QECI-DEV-04 — Regular user import works | Main | - | 1. As regular user in dev mode, paste valid JSON, click Import JSON | Confirmation appears, import succeeds, rows reload | - |
| TC-05 | EXCP-QE-COPY-IMPORT-005 | Verify QECI-DEV-05 — Admin full access | Main | - | 1. As admin in dev mode | Both export and import are fully functional | - |

### Production Mode Tests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-QE-COPY-IMPORT-006 | Verify QECI-PROD-01 — Regular user panel visibility | Main | - | 1. Build with `ng build --configuration production`, login as regular user | Transfer panel is visible | - |
| TC-07 | EXCP-QE-COPY-IMPORT-007 | Verify QECI-PROD-02 — Regular user export only | Main | - | 1. As regular user in production | Export button visible, Import button hidden, Import textarea hidden | - |
| TC-08 | EXCP-QE-COPY-IMPORT-008 | Verify QECI-PROD-03 — Regular user export works | Main | - | 1. As regular user in production, click Export JSON | JSON is produced and success feedback appears | - |
| TC-09 | EXCP-QE-COPY-IMPORT-009 | Verify QECI-PROD-04 — Admin full access | Main | - | 1. As admin in production | Both export and import buttons are visible and functional | - |
| TC-10 | EXCP-QE-COPY-IMPORT-010 | Verify QECI-PROD-05 — Admin import works | Main | - | 1. As admin in production, paste valid JSON, click Import JSON | Confirmation appears, import succeeds, rows reload | - |

### Admin-Specific Tests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-QE-COPY-IMPORT-011 | Verify QECI-ADMIN-01 — Admin export with target user | Main | - | 1. Set `Admin target user id`, click Export JSON | Export request includes selected target user and succeeds | - |
| TC-12 | EXCP-QE-COPY-IMPORT-012 | Verify QECI-ADMIN-02 — Admin import with target user | Main | - | 1. Set `Admin target user id`, paste valid JSON, import | Import applies to selected user and succeeds | - |

### Validation Tests

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-QE-COPY-IMPORT-013 | Verify QECI-VAL-01 — Invalid JSON | Edge | - | 1. Paste malformed JSON and import | Validation warning appears; request not sent | - |
| TC-14 | EXCP-QE-COPY-IMPORT-014 | Verify QECI-VAL-02 — Invalid schema version | Edge | - | 1. Paste JSON with non-`1 schemaVersion | Validation warning appears; request not sent | - |
