-- =================================================================
-- Test case:  TC-02
-- Feature:    Quick Entry correction — cross-midnight overtime (next-day tail)
-- Doc:        test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md
-- Purpose:    Verify (run AFTER correction for range D..D)
-- Variables:  @TestDate (date), @Email (nvarchar) — must match tc-02-seed.sql
-- Expect:      (1) No overtime on D with End <= Start.
--              (2) Exactly 2 valid overtime rows on D (17:00–21:00 and 22:00–end of day).
--              (3) Exactly 1 tail overtime row on D+1 (00:00:01–01:00:00).
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

DECLARE @NextDate date = DATEADD(DAY, 1, @TestDate);

SELECT
    N'Invalid cross-midnight rows on D (expect 0)' AS CheckName,
    COUNT(*) AS InvalidCount
FROM dbo.AttendanceOverTime AS ot
WHERE ot.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ot.[Date] = @TestDate
  AND ot.[End] IS NOT NULL
  AND ot.[End] <= ot.[Start];

DECLARE @InvalidOnD int =
(
    SELECT COUNT(*)
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[End] IS NOT NULL
      AND ot.[End] <= ot.[Start]
);

IF @InvalidOnD <> 0
    THROW 51001, 'Expected no overtime on D with End <= Start after correction.', 1;

DECLARE @OtOnD int =
(
    SELECT COUNT(*)
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[End] IS NOT NULL
      AND ot.[End] > ot.[Start]
);

IF @OtOnD <> 2
    THROW 51004, 'Expected exactly 2 valid overtime rows on D after correction (post-shift + evening).', 1;

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

DECLARE @TailCount int =
(
    SELECT COUNT(*)
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @NextDate
      AND ot.[End] IS NOT NULL
      AND ot.[End] > ot.[Start]
);

IF @TailCount <> 1
    THROW 51005, 'Expected exactly 1 valid overtime row on D+1 (cross-midnight tail).', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @NextDate
      AND ot.[Start] = CAST('00:00:01' AS time(7))
      AND ot.[End] = CAST('01:00:00' AS time(7))
)
    THROW 51006, 'Expected tail overtime 00:00:01 to 01:00:00 on D+1.', 1;

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

SELECT
    N'Tail day D+1 overtime rows' AS Info,
    ot.Id,
    ot.[Date],
    ot.[Start],
    ot.[End],
    ot.[Status]
FROM dbo.AttendanceOverTime AS ot
WHERE ot.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ot.[Date] = @NextDate
ORDER BY ot.Id;
