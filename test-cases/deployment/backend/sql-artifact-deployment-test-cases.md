# SQL artifact deployment test cases

## Metadata

- Project: `excp-time`
- Feature: `deployment`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Automatic artifact deployment after EF migration.
- Idempotent behavior when no SQL content changed.
- Re-apply behavior when an artifact content hash changes.
- Fail-fast behavior when an artifact script is invalid.
- Coverage for `Scripts`, `StoredProcedures`, and `DbArtifacts` embedded sources.
- Startup guard blocks API boot on schema/artifact drift.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-001 | Verify TC-01: First run creates history and applies artifacts | Main | - | 1. *Preconditions**<br>2. Target DB does not contain `dbo.DbArtifactExecutionHistory`.<br>3. *Steps**<br>4. *Expected**<br>5. Table is created.<br>6. Rows exist for embedded SQL artifacts.<br>7. Publish/migration finishes successfully. | - | - |
| TC-02 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-002 | Verify TC-02: Second run with no SQL changes is idempotent | Main | - | 1. *Preconditions**<br>2. TC-01 completed.<br>3. *Steps**<br>4. *Expected**<br>5. No new rows are inserted.<br>6. Existing rows are not updated.<br>7. Migration succeeds. | - | - |
| TC-03 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-003 | Verify TC-03: Changed artifact re-applies with new hash | Main | - | 1. *Preconditions**<br>2. TC-01 completed.<br>3. *Steps**<br>4. *Expected**<br>5. Artifact executes again.<br>6. `ContentHash` changes to the new value.<br>7. `AppliedAtUtc` is updated. | - | - |
| TC-04 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-004 | Verify TC-04: New artifact in supported folders gets applied automatically | Main | - | 1. *Preconditions**<br>2. None.<br>3. *Steps**<br>4. `StoredProcedures`<br>5. `Scripts`<br>6. `DbArtifacts`<br>7. *Expected**<br>8. Each new artifact is applied once.<br>9. Each artifact appears in history with hash. | - | - |
| TC-05 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-005 | Verify TC-05: Invalid artifact blocks deployment (fail-fast) | Edge | - | 1. *Preconditions**<br>2. None.<br>3. *Steps**<br>4. *Expected**<br>5. Migration fails on the bad artifact.<br>6. Deployment does not continue silently.<br>7. Error is visible in logs for triage. | - | - |
| TC-06 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-006 | Verify TC-06: Startup fails when pending migrations exist | Edge | - | 1. *Preconditions**<br>2. `Database:RequireSchemaAndArtifactsInSyncOnStartup = true`.<br>3. At least one pending EF migration exists.<br>4. *Steps**<br>5. *Expected**<br>6. Startup fails before serving requests.<br>7. Error indicates pending EF migrations and requests running DbMigrator. | - | - |
| TC-07 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-007 | Verify TC-07: Startup fails when artifact hash/history mismatch exists | Edge | - | 1. *Preconditions**<br>2. `Database:RequireSchemaAndArtifactsInSyncOnStartup = true`.<br>3. Artifact history table exists.<br>4. *Steps**<br>5. *Expected**<br>6. Startup fails before serving requests.<br>7. Error indicates missing/mismatched SQL artifact history and requires DbMigrator run. | - | - |
| TC-08 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-008 | Verify TC-08: SQL Server function compatibility in scripts folder | Edge | - | 1. *Preconditions**<br>2. Environment uses SQL Server.<br>3. `AddAttendanceWorkSegmentsTable.sql` is embedded and executed by artifact deployer.<br>4. *Steps**<br>5. *Expected**<br>6. Script executes successfully without function-name errors.<br>7. No startup crash containing `'GETUTCNOW' is not a recognized built-in function name`.<br>8. Attendance work segment backfill inserts rows with UTC timestamp via `SYSUTCDATETIME()`. | - | - |
| TC-09 | EXCP-DEPLOY-HRS-SQL-ARTIFACT-009 | Verify TC-09: Brace-containing script compatibility (`System.FormatException` guard) | Main | - | 1. *Preconditions**<br>2. At least one embedded script contains braces in text (for example JSON path literal in a SQL string).<br>3. *Steps**<br>4. *Expected**<br>5. No `System.FormatException` with message `Input string was not in a correct format... Expected an ASCII digit.<br>6. Artifact executes and history upsert completes. | - | - |
