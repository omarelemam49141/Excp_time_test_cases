# SSMS LeaveTypes verification and leave-types DB diagnostic — test cases

## Metadata

- Project: `excp-time`
- Feature: `leave-management`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: `src/Excp.HRSystem.Application/Services/Leave/LeaveTypesAppService.cs`, `src/Excp.HRSystem.Application.Contracts/Entities/Leave/Dtos/LeaveTypesDbContextDiagnosticDto.cs`
- Related docs: `docs/backend/technical/ssms-leavetypes-verification-and-api-db-alignment.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- SSMS operators verify data using query windows instead of a stale table designer.
- Admins can confirm which SQL catalog the live API uses when list endpoint is empty.
- Non-admin users cannot read database context diagnostics.


## Test cases

### TC-SSMS-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-LEAVE-HRS-SSMS-001 | Verify Query window vs designer | Edge | - | 1. Insert or select rows in a query tab; leave “Edit Top 200 Rows” open without refresh | Designer may show empty until closed/reopened; `SELECT COUNT(*) FROM dbo.LeaveTypes` in query window shows truth | - |

### TC-SSMS-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-LEAVE-HRS-SSMS-002 | Verify Partial execution | Main | - | 1. Highlight only middle of a script; Execute | Only highlighted statements run; user checks Messages for partial inserts | - |

### TC-API-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-LEAVE-HRS-SSMS-003 | Verify List with data | Main | - | 1. Seed `LeaveTypes` with active non-deleted rows; `GET /api/leave-types/list` with auth | `data` contains rows ordered by `sortOrder` | - |

### TC-API-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-LEAVE-HRS-SSMS-004 | Verify Admin diagnostic | Main | - | 1. Admin token; `GET /api/leave-types/diagnostics/db-context` | `200`, body includes `databaseName`, `dataSource`, `leaveTypesActiveNonDeletedRows` consistent with DB | - |

### TC-API-03

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-LEAVE-HRS-SSMS-005 | Verify Diagnostic forbidden | Edge | - | 1. Employee (or non-admin) token; `GET /api/leave-types/diagnostics/db-context` | `403 Forbidden | - |

### TC-API-04

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-LEAVE-HRS-SSMS-006 | Verify Align DB | Main | - | 1. Admin diagnostic shows DB A; SSMS was editing DB B | Change connection string or insert into DB A; list populates | - |
