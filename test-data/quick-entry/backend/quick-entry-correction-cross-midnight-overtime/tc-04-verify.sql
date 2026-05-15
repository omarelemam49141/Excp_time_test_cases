-- =================================================================
-- Test case:  TC-04
-- Feature:    Quick Entry correction — cross-midnight overtime break split
-- Doc:        test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md
-- Purpose:    Verify (run AFTER correction including day D)
-- Variables:  @TestDate (date), @Email (nvarchar) — must match tc-04-seed.sql
-- Expect:      (1) No invalid End <= Start on D.
--              (2) Attendance on D capped to shift 09:00–17:00.
--              (3) Exactly 2 valid OT rows on D: 17:00–21:00 and 22:00–end of day.
--              (4) Exactly 1 tail OT on D+1: 00:00:01–01:00:00.
--              (5) Break on D: 23:30 through end of day (intersection with evening OT).
--              (6) Break on D+1: 00:00:01–00:15:00 (intersection with tail OT).
-- =================================================================

SET NOCOUNT ON;

DECLARE @TestDate date = '2026-05-06'; -- must match seed
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
    THROW 52000, 'User not found for @Email.', 1;

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
    THROW 52001, 'Expected no overtime on D with End <= Start after correction.', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceRecords AS ar
    WHERE ar.IsDeleted = 0
      AND ar.UserId = @UserId
      AND ar.[Date] = @TestDate
      AND ar.[Start] = CAST('09:00:00' AS time(7))
      AND ar.[End] = CAST('17:00:00' AS time(7))
)
    THROW 52002, 'Expected attendance on D capped to 09:00:00–17:00:00 after correction.', 1;

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
    THROW 52003, 'Expected exactly 2 valid overtime rows on D after correction (post-shift + evening).', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @TestDate
      AND ot.[Start] = CAST('17:00:00' AS time(7))
      AND ot.[End] = CAST('21:00:00' AS time(7))
)
    THROW 52004, 'Expected post-shift overtime 17:00:00 to 21:00:00 on D.', 1;

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
    THROW 52005, 'Expected evening overtime from 22:00:00 through end of day on D.', 1;

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
    THROW 52006, 'Expected exactly 1 valid overtime row on D+1 (cross-midnight tail).', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.AttendanceOverTime AS ot
    WHERE ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ot.[Date] = @NextDate
      AND ot.[Start] = CAST('00:00:01' AS time(7))
      AND ot.[End] = CAST('01:00:00' AS time(7))
)
    THROW 52007, 'Expected tail overtime 00:00:01 to 01:00:00 on D+1.', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.OverTimeBreaks AS ob
    INNER JOIN dbo.AttendanceOverTime AS ot ON ot.Id = ob.AttendanceOverTimeId
    WHERE ob.IsDeleted = 0
      AND ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ob.[Date] = @TestDate
      AND ot.[Date] = @TestDate
      AND ob.[Start] = CAST('23:30:00' AS time(7))
      AND ob.[End] > CAST('23:59:00' AS time(7))
      AND ob.[End] > ob.[Start]
)
    THROW 52008, 'Expected overtime break on D from 23:30:00 through end of day.', 1;

IF NOT EXISTS (
    SELECT 1
    FROM dbo.OverTimeBreaks AS ob
    INNER JOIN dbo.AttendanceOverTime AS ot ON ot.Id = ob.AttendanceOverTimeId
    WHERE ob.IsDeleted = 0
      AND ot.IsDeleted = 0
      AND ot.EmployeeId = @UserId
      AND ob.[Date] = @NextDate
      AND ot.[Date] = @NextDate
      AND ob.[Start] = CAST('00:00:01' AS time(7))
      AND ob.[End] = CAST('00:15:00' AS time(7))
)
    THROW 52009, 'Expected overtime break on D+1 from 00:00:01 to 00:15:00.', 1;

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

SELECT
    N'Overtime breaks (D and D+1)' AS Info,
    ob.[Date] AS BreakDate,
    ob.[Start] AS BreakStart,
    ob.[End] AS BreakEnd,
    ot.[Date] AS OtDate,
    ot.[Start] AS OtStart,
    ot.[End] AS OtEnd
FROM dbo.OverTimeBreaks AS ob
INNER JOIN dbo.AttendanceOverTime AS ot
    ON ot.Id = ob.AttendanceOverTimeId
   AND ot.IsDeleted = 0
WHERE ob.IsDeleted = 0
  AND ot.EmployeeId = @UserId
  AND ob.[Date] IN (@TestDate, @NextDate)
ORDER BY ob.[Date], ob.Id;
