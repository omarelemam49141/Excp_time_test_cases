# Quick Entry correction cross-midnight overtime — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `backend`
- Routes: -
- APIs: `Quick Entry page with the **"From"** and **"To"** date pickers and the **"Apply quick entry range correction"** button.`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

Covers what happens when the tester runs **"Apply quick entry range correction"** on a day that has an evening overtime crossing midnight (for example `"22:00"` to `"00:00"` or `"22:00"` to `"01:00"`). After the correction, the employee's day must show valid overtime entries on the correct dates, the gap between attendance end and overtime start must stay empty, and any overtime break that crosses midnight must appear on both days.

## Test pages

- Quick Entry page with the **"From"** and **"To"** date pickers and the **"Apply quick entry range correction"** button.

## Test scenarios

- The correction keeps evening overtime that ends at midnight and shows two separate overtime entries on the same day (no entry covers the idle gap between attendance end and overtime start).
- When the evening overtime ends after midnight, the correction keeps one entry on the first day (up to end of day) and creates a short tail entry on the next day (from `"00:00:01"` to the real end time).
- When the evening overtime ends exactly at midnight, no next-day entry is created.
- When a day already has a later overtime entry, correction keeps that existing entry unchanged and adds only the missing overtime created by attendance adjustment.
- An overtime break that crosses midnight is shown on the first day up to end of day and on the next day starting at `"00:00:01"`.
- The correction always succeeds with no server error, and no overtime entry has an end time equal to or earlier than its start time.

## Test cases

### Evening overtime that crosses midnight

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-HRS-CORRECTION-CROSS-001 | Verify evening overtime entered as "22:00" to "00:00" is kept as two separate overtime entries on the same day | Main | The employee's shift is `"09:00"`–`"17:00"`.<br>On `"2026-05-06"` the employee has an attendance entry from `"09:00"` to `"21:00"`.<br>On `"2026-05-06"` the employee has one overtime entry from `"22:00"` to `"00:00"` (end equals start of day, which is invalid).<br>There is a one-hour gap between attendance end (`"21:00"`) and overtime start (`"22:00"`). | 1. Open the Quick Entry page for the employee.<br>2. Set **"From"** to `"2026-05-06"` and **"To"** to `"2026-05-06"`.<br>3. Click **"Apply quick entry range correction"** and wait for the confirmation. | 1. The correction finishes with a success message (no server error).<br>2. The day on `"2026-05-06"` shows exactly two overtime entries: `"17:00"`–`"21:00"` (after the shift ends until attendance ended) and `"22:00"`–`"23:59:59"` (evening overtime capped at end of day).<br>3. No overtime entry covers the gap between `"21:00"` and `"22:00"`.<br>4. No overtime entry has an end time equal to or earlier than its start time. | From: `"2026-05-06"`<br>To: `"2026-05-06"` |
| TC-02 | EXCP-QE-HRS-CORRECTION-CROSS-002 | Verify evening overtime entered as "22:00" to "01:00" is split into a first-day entry up to end of day and a short tail on the next day | Main | The employee's shift is `"09:00"`–`"17:00"`.<br>On `"2026-05-06"` the employee has an attendance entry from `"09:00"` to `"21:00"`.<br>On `"2026-05-06"` the employee has one overtime entry from `"22:00"` to `"01:00"` (end is before start, because it really crosses into the next day). | 1. Open the Quick Entry page for the employee.<br>2. Set **"From"** to `"2026-05-06"` and **"To"** to `"2026-05-06"` only.<br>3. Click **"Apply quick entry range correction"** and wait for the confirmation. | 1. The correction finishes with a success message (no server error).<br>2. The day on `"2026-05-06"` shows exactly two overtime entries: `"17:00"`–`"21:00"` and `"22:00"`–`"23:59:59"`.<br>3. The day on `"2026-05-07"` shows one short tail overtime entry from `"00:00:01"` to `"01:00"`.<br>4. No overtime entry covers the gap between `"21:00"` and `"22:00"`.<br>5. No overtime entry has an end time equal to or earlier than its start time. | From: `"2026-05-06"`<br>To: `"2026-05-06"` |
| TC-03 | EXCP-QE-HRS-CORRECTION-CROSS-003 | Verify no next-day tail is created when the evening overtime ends exactly at midnight | Edge | Same setup as TC-01 — on `"2026-05-06"` the employee has an attendance entry from `"09:00"` to `"21:00"` and one overtime entry from `"22:00"` to `"00:00"`. | 1. Open the Quick Entry page for the employee.<br>2. Set **"From"** to `"2026-05-06"` and **"To"** to `"2026-05-06"` only.<br>3. Click **"Apply quick entry range correction"** and wait for the confirmation. | 1. The correction finishes with a success message (no server error).<br>2. The day on `"2026-05-06"` shows the same two overtime entries as TC-01: `"17:00"`–`"21:00"` and `"22:00"`–`"23:59:59"`.<br>3. The day on `"2026-05-07"` shows **no** overtime entry starting at `"00:00:01"` (because midnight is the real end — there is nothing to carry over). | From: `"2026-05-06"`<br>To: `"2026-05-06"` |
| TC-05 | EXCP-QE-HRS-CORRECTION-CROSS-004 | Verify correction keeps an existing evening overtime unchanged and adds only the missing overtime from attendance adjustment | Regression | The employee's shift is `"09:00"`–`"17:00"`.<br>On `"2026-04-05"` the employee has an attendance entry from `"09:07"` to `"19:50"`.<br>The same day already has an overtime entry from `"21:05:07"` to `"22:37:36"`.<br>The employee has breaks that make the corrected attendance end become `"17:07"`.<br>The period in Quick Entry is set to `"2026-03-23"` through `"2026-04-21"`. | 1. Open the Quick Entry page for the employee.<br>2. Confirm the day `"2026-04-05"` already shows one overtime entry from `"21:05:07"` to `"22:37:36"`.<br>3. Click **"Apply quick entry range correction"** for the selected period and wait for the success message.<br>4. Reload the same period and open day `"2026-04-05"`. | 1. The correction finishes with a success message (no server error).<br>2. The existing overtime entry `"21:05:07"`–`"22:37:36"` is still present exactly once with the same start and end times.<br>3. A new overtime entry appears for the corrected gap from `"17:07"` to `"19:50"`.<br>4. The day shows no duplicated overtime entry with the same start and end times. | From: `"2026-03-23"`<br>To: `"2026-04-21"`<br>Date to verify: `"2026-04-05"` |


### Overtime break that crosses midnight

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-QE-HRS-CORRECTION-CROSS-005 | Verify an overtime break entered as "23:30" to "00:15" is split across the two days after the correction runs | Main | The employee's shift is `"09:00"`–`"17:00"`.<br>On `"2026-05-06"` the employee has an attendance entry from `"09:00"` to `"21:00"`.<br>On `"2026-05-06"` the employee has one overtime entry from `"22:00"` to `"01:00"` (crosses midnight).<br>Inside that overtime, there is one break entered as `"23:30"` to `"00:15"`. | 1. Open the Quick Entry page for the employee.<br>2. Set **"From"** to `"2026-05-06"` and **"To"** to `"2026-05-06"`.<br>3. Click **"Apply quick entry range correction"** and wait for the confirmation. | 1. The correction finishes with a success message (no server error).<br>2. The day on `"2026-05-06"` shows the evening overtime as `"22:00"`–`"23:59:59"` with a break from `"23:30"` to `"23:59:59"` (capped at end of day).<br>3. The day on `"2026-05-07"` shows the tail overtime from `"00:00:01"` to `"01:00"` with a break from `"00:00:01"` to `"00:15"`.<br>4. No overtime entry or break has an end time equal to or earlier than its start time. | Break start: `"23:30"`<br>Break end: `"00:15"`<br>From: `"2026-05-06"`<br>To: `"2026-05-06"` |


## Test data scripts

Set `@TestDate` and `@Email` at the top of each script. Conventions: `[test-data/README.md](../../../../test-data/README.md)`.


| TC    | Script                                                                                                                    | Purpose                                                                                          |
| ----- | ------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------ |
| TC-01 | [tc-01-seed.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-01-seed.sql)       | Seed attendance + overtime 22:00→00:00 same date before correction                               |
| TC-01 | [tc-01-verify.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-01-verify.sql)   | After correction: full **Expected** checks via `THROW` (invalid OT on **D**, two OT windows on **D**, gap preserved) |
| TC-01 | [tc-01-cleanup.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-01-cleanup.sql) | Remove seeded rows on **D** only                                                                 |
| TC-02 | [tc-02-seed.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-02-seed.sql)       | Seed overtime 22:00→01:00 same date (tail scenario)                                              |
| TC-02 | [tc-02-verify.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-02-verify.sql)   | After correction: full **Expected** via `THROW` (invalid OT on **D**, two OT on **D**, tail **D+1**) |
| TC-02 | [tc-02-cleanup.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-02-cleanup.sql) | Remove overtime on **D** and **D+1** + attendance on **D**                                       |
| TC-03 | [tc-01-seed.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-01-seed.sql)       | Same seed as TC-01 (attendance + OT 22:00→00:00 same date)                                       |
| TC-03 | [tc-03-verify.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-03-verify.sql)   | After correction: same **D** checks as TC-01 via `THROW` plus **no** valid overtime on **D+1**   |
| TC-03 | [tc-01-cleanup.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-01-cleanup.sql) | Same cleanup as TC-01 (remove seeded rows on **D** only)                                       |
| TC-04 | [tc-04-seed.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-04-seed.sql)       | Seed OT crossing midnight + break 23:30→00:15                                                    |
| TC-04 | [tc-04-verify.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-04-verify.sql)   | After correction: full **Expected** via `THROW (OT on **D**/**D+1**, break split, capped attendance) |
| TC-04 | [tc-02-cleanup.sql](../../../../test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/tc-02-cleanup.sql) | Same as TC-02 cleanup (clears **D+1** overtime from tail/break split)                            |


