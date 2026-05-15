-- =================================================================
-- Test case:  TC-03
-- Feature:    Quick Entry correction — cross-midnight overtime (no tail at midnight)
-- Doc:        test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md
-- Purpose:    Verify (run AFTER correction for range D..D) — same seed as TC-01; assert no D+1 tail.
-- Variables:  @TestDate (date), @Email (nvarchar) — must match tc-01-seed.sql
-- Expect:      (1) No invalid End <= Start on D.
--              (2) Exactly 2 valid OT rows on D (post-shift + evening to end of day).
--              (3) No valid overtime row on D+1 (logical end exactly midnight → no tail segment).
-- =================================================================

SET NOCOUNT ON;

DECLARE @TestDate date = '2026-05-06'; -- must match tc-01-seed.sql
DECLARE @Email  nvarchar(256) = N'omar.elemam.elmghawry@gmail.com'; -- default AbpUsers test account; override if needed
DECLARE @NextDate date = DATEADD(DAY, 1, @TestDate);

DECLARE @UserId uniqueidentifier =
(
    SELECT TOP (1) u.Id
    FROM dbo.AbpUsers AS u
    WHERE u.IsDeleted = 0
      AND (u.Email = @Email OR u.NormalizedEmail = UPPER(@Email))
);

IF @UserId IS NULL
    THROW 53000, 'User not found for @Email.', 1;

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
    THROW 53001, 'Expected no overtime on D with End <= Start after correction.', 1;

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
    THROW 53002, 'Expected exactly 2 valid overtime rows on D after correction (post-shift + evening).', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[Start] = CAST('17:00:00' AS time(7))
      AND ot.[End] = CAST('21:00:00' AS time(7))
)
    THROW 53003, 'Expected post-shift overtime 17:00:00 to 21:00:00 on D.', 1;

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
    THROW 53004, 'Expected evening overtime from 22:00:00 through end of day on D.', 1;

DECLARE @OtOnNext int =
(
    SELECT COUNT(*)
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @NextDate
      AND ot.[End] IS NOT NULL
      AND ot.[End] > ot.[Start]
);

IF @OtOnNext <> 0
    THROW 53005, 'TC-03: expected no valid overtime rows on D+1 (no cross-midnight tail when logical end is midnight).', 1;

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
    N'Overtime rows on D+1 (expect none)' AS Info,
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
