-- =================================================================
-- Test case:  TC-01
-- Feature:    Quick Entry correction — cross-midnight overtime
-- Doc:        test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md
-- Purpose:    Cleanup — remove seeded attendance + overtime on @TestDate only
-- Variables:  @TestDate (date), @Email (nvarchar)
-- =================================================================

SET NOCOUNT ON;
SET XACT_ABORT ON;

BEGIN TRAN;

DECLARE @TestDate date = '2026-05-06';
DECLARE @Email  nvarchar(256) = N'omar.elemam.elmghawry@gmail.com'; -- default AbpUsers test account; override if needed

DECLARE @UserId uniqueidentifier =
(
    SELECT TOP (1) u.Id
    FROM dbo.AbpUsers AS u
    WHERE u.IsDeleted = 0
      AND (u.Email = @Email OR u.NormalizedEmail = UPPER(@Email))
);

IF @UserId IS NULL
    THROW 51000, 'User not found for @Email.', 1;

DECLARE @OtIdTable TABLE (Id int PRIMARY KEY);
INSERT INTO @OtIdTable (Id)
SELECT ot.Id
FROM dbo.AttendanceOverTime AS ot
WHERE ot.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ot.[Date] = @TestDate;

DELETE rr
FROM dbo.RequestReceivers AS rr
WHERE EXISTS (
    SELECT 1 FROM dbo.Requests AS r
    INNER JOIN @OtIdTable AS x ON x.Id = r.OverTimeId
    WHERE r.Id = rr.RequestId AND r.IsDeleted = 0);

DELETE n
FROM dbo.Notifications AS n
WHERE EXISTS (
    SELECT 1 FROM dbo.Requests AS r
    INNER JOIN @OtIdTable AS x ON x.Id = r.OverTimeId
    WHERE r.Id = n.RequestId AND r.IsDeleted = 0);

DELETE r
FROM dbo.Requests AS r
WHERE EXISTS (SELECT 1 FROM @OtIdTable AS x WHERE x.Id = r.OverTimeId)
  AND r.IsDeleted = 0;

DELETE ob
FROM dbo.OverTimeBreaks AS ob
WHERE EXISTS (SELECT 1 FROM @OtIdTable AS x WHERE x.Id = ob.AttendanceOverTimeId)
  AND ob.IsDeleted = 0;

DELETE ot
FROM dbo.AttendanceOverTime AS ot
WHERE EXISTS (SELECT 1 FROM @OtIdTable AS x WHERE x.Id = ot.Id)
  AND ot.IsDeleted = 0;

DECLARE @ArIds TABLE (Id bigint PRIMARY KEY);
INSERT INTO @ArIds (Id)
SELECT ar.Id
FROM dbo.AttendanceRecords AS ar
WHERE ar.IsDeleted = 0
  AND ar.UserId = @UserId
  AND ar.[Date] = @TestDate;

DELETE ws
FROM dbo.AttendanceWorkSegments AS ws
WHERE EXISTS (SELECT 1 FROM @ArIds AS a WHERE a.Id = ws.AttendanceRecordId)
  AND ws.IsDeleted = 0;

DELETE b
FROM dbo.AttendanceBreak AS b
WHERE EXISTS (SELECT 1 FROM @ArIds AS a WHERE a.Id = b.AttendanceRecordId)
  AND b.IsDeleted = 0;

DELETE ar
FROM dbo.AttendanceRecords AS ar
WHERE EXISTS (SELECT 1 FROM @ArIds AS a WHERE a.Id = ar.Id)
  AND ar.IsDeleted = 0;

COMMIT TRAN;

SELECT N'Cleanup complete for user on @TestDate' AS Message;
