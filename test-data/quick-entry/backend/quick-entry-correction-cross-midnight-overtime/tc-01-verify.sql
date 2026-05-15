-- =================================================================
-- Test case:  TC-01
-- Feature:    Quick Entry correction — cross-midnight overtime
-- Doc:        test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md
-- Purpose:    Verify (run AFTER "Apply quick entry range correction" for range D..D)
-- Variables:  @TestDate (date), @Email (nvarchar)
-- Expect:      (1) No overtime on D with End <= Start (invalid cross-midnight storage).
--              (2) Exactly 2 valid overtime rows on D.
--              (3) Post-shift row 17:00:00–21:00:00 on D.
--              (4) Evening row from 22:00:00 through end of day on D (gap 21:00–22:00 preserved).
-- =================================================================

SET NOCOUNT ON;

DECLARE @TestDate date = '2026-05-06'; -- must match seed
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

SELECT
    N'Invalid cross-midnight rows on D (expect 0)' AS CheckName,
    COUNT(*) AS InvalidCount
FROM dbo.AttendanceOverTime AS ot
WHERE ot.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ot.[Date] = @TestDate
  AND ot.[End] IS NOT NULL
  AND ot.[End] <= ot.[Start];

DECLARE @OtCount int =
(
    SELECT COUNT(*)
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[End] IS NOT NULL
      AND ot.[End] > ot.[Start]
);

IF @OtCount <> 2
    THROW 51001, 'Expected exactly 2 valid overtime rows on D after correction (post-shift + evening).', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[Start] = CAST('17:00:00' AS time(7))
      AND ot.[End] = CAST('21:00:00' AS time(7))
)
    THROW 51002, 'Expected post-shift overtime 17:00:00 to 21:00:00 on D.', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[Start] = CAST('22:00:00' AS time(7))
      AND ot.[End] > CAST('23:59:00' AS time(7))
      AND ot.[End] > ot.[Start]
)
    THROW 51003, 'Expected evening overtime from 22:00:00 through end of day on D.', 1;

SELECT
    N'Overtime rows on D after correction' AS Info,
    ot.Id,
    ot.[Date],
    ot.[Start],
    ot.[End],
    ot.[Status]
FROM dbo.AttendanceOverTime AS ot
WHERE ot.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ot.[Date] = @TestDate
ORDER BY ot.[Start], ot.Id;
