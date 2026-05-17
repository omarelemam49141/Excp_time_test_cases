# Quick Entry Problem Days Navigator — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: -
- Related code: `src/app/features/attendance/components/attendance-quick-entry`
- Related docs: `docs/frontend/technical/quick-entry-problem-days-navigator.md`

## Scope

- Auto-detect preloaded day data problems when `/attendance/quick-entry` opens.
- Show problem-day warning badges on day cards.
- Provide floating previous/next navigation for problem days.
- Validate detection for attendance, break, overtime, and overtime-break time issues.

## Test pages

- `/attendance/quick-entry`

## Test scenarios

- Problem days are detected on initial page load without clicking "Save".
- Floating problem-day navigator appears only when at least one day has a problem.
- Previous/next actions cycle through all problem days and expand/scroll the matching day card.
- Warning badge count and tooltip content align with the detected issues for each day.
- Weekend/public-holiday attendance checks are skipped, but overtime checks still apply.

## Test cases

### Load-time detection and navigator visibility

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-PROBLEM-DAYS-001 | Verify the problem-day navigator appears when the loaded range contains invalid pre-existing day data | Main | At least one day in the selected range is already saved with a time problem. | 1. Open `/attendance/quick-entry`.<br>2. Select a range that contains known invalid day data.<br>3. Wait for data loading to finish.<br>4. Check the bottom-right floating cards. | A floating problem-day navigator is shown automatically with a non-zero count, without pressing "Save". | Range from: "contains a known invalid day" |
| TC-02 | EXCP-QE-PROBLEM-DAYS-002 | Verify the problem-day navigator is hidden when there are no pre-existing problems | Main | Selected range has no invalid day data. | 1. Open `/attendance/quick-entry`.<br>2. Select a clean date range with valid saved data.<br>3. Wait for loading to finish. | No problem-day navigator is shown. | Range from: "clean period" |
| TC-03 | EXCP-QE-PROBLEM-DAYS-003 | Verify the problem-day navigator appears below the top navbar at the top-left and does not overlap bottom-right floating actions | Main | Selected range contains at least one problem day and page shows bottom-right floating actions. | 1. Open `/attendance/quick-entry` on a range with problem days.<br>2. Observe the problem-day navigator location relative to the top navbar.<br>3. Observe bottom-right floating actions. | The problem-day navigator appears below the top navbar at the top-left, and bottom-right floating actions remain visible and usable without overlap. | - |

### Navigator movement and focus behavior

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-QE-PROBLEM-DAYS-004 | Verify "next" moves to the next problem day and expands its card | Main | At least two problem days exist in the loaded range. | 1. Open `/attendance/quick-entry` with a range containing multiple problem days.<br>2. Click the problem-day navigator next button once.<br>3. Observe which day card is expanded and centered. | The next problem day card is expanded and scrolled into view. | Problem days count: "2+" |
| TC-05 | EXCP-QE-PROBLEM-DAYS-005 | Verify "previous" moves to the previous problem day and wraps cyclically | Edge | At least two problem days exist in the loaded range. | 1. Open `/attendance/quick-entry` with multiple problem days.<br>2. Click the problem-day navigator previous button repeatedly until wrap-around occurs. | Navigation wraps from the first problem day to the last problem day and keeps cycling correctly. | Problem days count: "2+" |

### Day badges and issue hints

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-QE-PROBLEM-DAYS-006 | Verify a warning badge appears on each day card that has at least one problem | Main | Range includes days with and without problems. | 1. Open `/attendance/quick-entry`.<br>2. Wait for rows to load.<br>3. Compare badges on rows with known issues vs clean rows. | Rows with problems show a warning badge count, and clean rows do not show that warning badge. | - |
| TC-07 | EXCP-QE-PROBLEM-DAYS-007 | Verify the warning badge tooltip lists the detected problem types for that day | Main | At least one row has multiple issue types. | 1. Open `/attendance/quick-entry` on a range with a multi-issue day.<br>2. Hover over the row warning badge. | Tooltip text lists the detected issue messages (for example missing time and time-order problems). | - |

### Problem type detection coverage

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-QE-PROBLEM-DAYS-008 | Verify attendance-level missing time and end-before-start problems are detected on load | Main | A saved row has attendance start without end, end without start, or end earlier than start. | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the known attendance-problem day. | The day appears in problem navigation and shows warning badge/issue hint for attendance problems. | Attendance sample: "start only", "end only", "end < start" |
| TC-09 | EXCP-QE-PROBLEM-DAYS-009 | Verify break-level missing time and end-before-start problems are detected on load | Main | A saved row has break entries with invalid time pairs/order. | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the day containing invalid break data. | The day is flagged as a problem day and break issue text appears in the warning hint. | Break sample: "start only", "end only", "end < start" |
| TC-10 | EXCP-QE-PROBLEM-DAYS-010 | Verify overtime missing start or end time is detected on load | Main | A saved row has overtime with start but no end, or end but no start. | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the day containing overtime with missing time. | The day is flagged as a problem day and overtime-related issue text appears in the warning hint. | OT sample: "start only", "end only" |
| TC-11 | EXCP-QE-PROBLEM-DAYS-011 | Verify cross-midnight overtime is NOT flagged as a problem | Edge | A saved row has overtime that crosses midnight (e.g., start 22:00, end 02:00). | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the day containing cross-midnight overtime. | The day is NOT flagged as a problem day because cross-midnight overtime is valid. | OT sample: "start 22:00, end 02:00" |
| TC-12 | EXCP-QE-PROBLEM-DAYS-012 | Verify midnight overtime start (00:00) is NOT flagged as missing | Edge | A saved row has overtime starting at midnight (00:00). | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the day containing overtime starting at 00:00. | The day is NOT flagged as a problem day because 00:00 is a valid midnight time for overtime. | OT sample: "start 00:00, end 01:00" |
| TC-13 | EXCP-QE-PROBLEM-DAYS-013 | Verify midnight overtime-break start (00:00) is NOT flagged as missing | Edge | A saved row has an overtime break with start at 00:00 and valid end time. | 1. Open `/attendance/quick-entry` for the target range.<br>2. Locate the day containing overtime break starting at 00:00.<br>3. Hover the warning badge if present. | The day is not flagged for "missing break start time" when the break starts at 00:00. | OT break sample: "start 00:00, end 00:30" |
| TC-14 | EXCP-QE-PROBLEM-DAYS-014 | Verify weekend/public-holiday attendance checks are ignored while overtime checks still apply | Edge | At least one weekend/public-holiday row contains attendance anomalies and a separate row contains overtime anomalies. | 1. Open `/attendance/quick-entry for a range that includes weekend/public-holiday rows.<br>2. Compare a weekend/public-holiday attendance anomaly row and an overtime anomaly row. | Weekend/public-holiday attendance-only anomalies do not create a problem flag, but overtime anomalies still create problem flags. | Day type: "weekend/public holiday" |
