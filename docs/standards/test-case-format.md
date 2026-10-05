# Unified Test-Case Format (Testing-feature)

## Purpose

All `*-test-cases.md` files in this repository use **one structure**, **stable keys**, and **one plain-English style** so that:

- QA can review cases quickly.
- The `tc` status CLI parses every file the same way.
- Test results can be tracked without moving the source test definition.
- Cursor agents generate consistent files.

## Repository layout

Each **product** has its own TestCases git repo with `testing-feature.project.json` at the root.

```text
<Product>.TestCases/
  testing-feature.project.json
  test-cases/<feature>/frontend/*.md
  test-cases/<feature>/backend/*.md
  test-runs/current/status.json
```

Examples:

- **ExcpTime.TestCases** — `test-cases/quick-entry/frontend/...`, `test-cases/quick-entry/backend/...`
- **Alforqan.TestCases** — `test-cases/halaqat/frontend/...` (all halaqat UI specs in one feature folder)

The **Testing-feature** vendor repo only contains tool self-tests:

```text
test-cases/testing-feature/<area>/cli|standards/*.md
```

Use feature folders, not page-only folders. A feature can span more than one page, API, backend service, or automation flow.

## Delivery waves (optional, recommended for multi-chunk features)

When a feature is delivered in **stages** (several PRs or agent tasks) or when **one test logically blocks** the next, use **delivery waves** so QA and agents do not run “everything in the file” at once.

- **Spec:** [`delivery-waves.md`](./delivery-waves.md) — definitions, gates, agent rules.
- **Enforcement:** Use the **`Requires`** column with stable `Key` values. `tc s <KEY> ok` refuses until every required key is `succeeded` (unless `--force`).
- **Markdown:** Optional `## Delivery waves` section (after `## Test scenarios` or before `## Test cases`) listing wave number, intent, and keys. Under `## Test cases`, prefer headings like `### Wave 2 — Batch validation` so groups stay readable.

Waves are a **process convention**; the parser still only requires valid tables under `## Test cases`. If you do not need staged testing, omit waves and leave `Requires` as `-`.

## File structure (required)

```markdown
# <Feature> — <Frontend|Backend> Test Cases

## Metadata
- Project: `excp-time`
- Feature: `<feature-folder>`
- Layer: `frontend` or `backend`
- Routes: `/route` or `-`
- APIs: `METHOD /api/path` or `-`
- Related code: `src/...` or `_Map concrete files during feature updates._`
- Related docs: `docs/...` or `_See the project documentation indexes for the owning feature._`
- Automation: repo-relative xUnit file for backend Keys (e.g. `test/MyApp.Tests/FeatureTests.cs`); use `-` for frontend or until tests exist

### Related code (for `tc impact`)

- **File default:** One **Metadata** line per file — used as the fallback for any row whose **Related code** column is `-` or omitted.
- **Per test case (recommended for large specs):** Optional table column **Related code** — comma-separated paths in backticks for that row’s `Key` only. `tc impact` marks **`needs-update`** only for succeeded keys whose effective paths match a changed file (not every key in the file).
- List paths relative to the linked app repo for that layer (e.g. `src/app/foo.ts`, `src/app/halaqat/`).
- Use a directory path (no extension) to match any file under that folder.
- Replace the placeholder `_Map concrete files...` before relying on `tc impact`; `project doctor` warns per key while effective mapping is missing.
- Run `tc project doctor --strict` before merge or in CI so unmapped or stale Related code fails the check.
- After code changes: with **`autoImpact`** enabled in `testing-feature.project.json` (default when `linkedRepos` exist), succeeded keys are marked **`needs-update`** automatically (Cursor stop hook + `tc ui` watcher). Manual fallback: `tc impact --git --apply`.

### Automation (backend xUnit)

- **Backend** (`Layer: backend`): list the xUnit test file under **Automation:** in Metadata (repo-relative to the linked backend app). Each `[Fact]` / `[Theory]` that covers a Key must include `[Trait("Key", "<KEY>")]`.
- **Frontend** (`Layer: frontend`): omit **Automation:** or use `-`. Manual Session / `tc ui` remains the contract.
- Agents must write xUnit and run `dotnet test` in the **same task** as backend API/helper changes. See `.cursor/rules/backend-automated-tests.mdc`.

## Scope
<short bullets or a paragraph: what this document covers>

## Test pages
- <route, screen, or API base path>

## Test scenarios
- <high-level scenario bullets>

## Test cases

### <Group name>

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-QE-UNSAVED-001 | Verify ... | Main | - | 1. ...<br>2. ... | ... | - |
```

### Required

- `#` title line.
- `## Metadata` section before `## Scope`.
- `## Test cases` section.
- Under **each** `###` group heading, **exactly one** markdown table.
- Table header row must include these columns (order may vary, names must match):

| Column | Required | Notes |
|--------|----------|--------|
| `ID` | Yes | `TC-01`, `TC-02`, … **consecutive integers per file** (see **ID ordering** below) |
| `Key` | Yes | Stable unique identity, max 32 characters, e.g. `EXCP-QE-UNSAVED-001` |
| `Case` | Yes | Short title; must start with **Verify** |
| `Steps` | Yes | Numbered steps; use `<br>` between lines inside the cell |
| `Expected` | Yes | User-visible outcome; put exact UI copy in **double quotes**. When more than one fact must hold, use a numbered list (`1. …<br>2. …`) — one observable fact per line. `tc project doctor` warns on dense single-paragraph Expected cells. |
| `Type` | No | e.g. `Main`, `Edge`, `Regression` |
| `Preconditions` | No | Use `-` if none |
| `Requires` | No | Comma-separated stable keys that must be `succeeded` first (e.g. `ALFQ-HAL-SES-001`). The `tc` CLI refuses `ok` until those keys are `succeeded` unless `--force`. Use this to **gate waves**: later cases list earlier wave keys so testers cannot mark a dependent case `ok` before its setup or prerequisite wave is green. See [`delivery-waves.md`](./delivery-waves.md). |
| `Related code` | No | Repo-relative paths in backticks for **this row only**; use `-` to inherit the file **Metadata** line. Prefer per-row paths when one spec covers multiple subsystems (e.g. range vs marking vs submit). |
| `Test data` | No | `Key: "value"` pairs; use `-` if none |

### ID ordering (mandatory)

- Within a single `*-test-cases.md` file, IDs must be **strictly sequential**: `TC-01`, `TC-02`, `TC-03`, … with **no gaps** and **no letter suffixes** (do not use `TC-06b`; use the next integer, e.g. `TC-07`).
- **Document order:** When reading the file from top to bottom under `## Test cases`, each table row’s ID must be exactly one greater than the previous row’s ID across **all** `###` groups. Reorder sections or merge tables if needed so numbering stays monotonic.
- **Cross-references** in Preconditions (e.g. “Same as TC-06”) must point to IDs that exist in the same file.

### Stable keys (mandatory)

- `Key` is the long-lived identity used by status tracking, future UI screens, automation runners, and code-change impact detection.
- Pattern: `<PROJECT>-<FEATURE>-<AREA>-NNN`.
- Use uppercase letters, numbers, and dashes only.
- Maximum length: **32 characters**.
- Keys must be unique across the repository, not only inside one file.
- Do not rename a key just because the test title, file path, or local `TC-01` order changes.
- When product code changes and a related case needs review, keep the same key and mark its status as `needs-update` / visible `"Needs update"`.

### Forbidden (CLI will reject)

- Numbered-bold blocks (`1. **Title**`) under `## Test cases`.
- `### TC-1 — Title` bullet blocks (old backend style).
- A markdown table **not** preceded by a `###` group heading inside `## Test cases`.
- Missing `## Test cases`, missing `Key`, invalid keys, duplicate keys, or empty tables.

## Status workflow

Test-case markdown files are the canonical test definitions. Execution state is stored separately under `test-runs/`.

Supported internal statuses:

- `new`
- `in-progress`
- `succeeded`
- `failed`
- `blocked`
- `needs-update`

The visible label for `needs-update` is `"Needs update"`.

Do **not** move markdown files into status folders. A case may pass in one run and fail later, so status belongs to the run record, not the definition folder.

## Language style (mandatory)

Style reference: `Massader.Web/auth-test-cases.csv` (clear steps, simple English).

### Plain-English rule (applies to every column, not just Steps)

The language bar used for the `Steps` column is the **minimum** bar for **every** other column (`Case`, `Preconditions`, `Expected`, `Test data`). Write as if you are handing the row to a tester who does not read code, schema, or SQL.

Core rules:

- Describe **what the tester can see or do**: visible UI labels, on-screen messages, API response shape. If a fact is only true in the database, translate it into business terms (for example say "the day shows two overtime entries" instead of "two `AttendanceOverTime` rows on date D").
- Put every exact UI string, label, error message, time, or date in **double quotes** (`"Apply quick entry range correction"`, `"22:00"`, `"2026-05-06"`).
- Prefer **human-readable times** in prose (`"10 PM"`, `"midnight"`, `"end of day"`). Keep `HH:MM` / `HH:MM:SS` only when the tester actually types or reads that exact format on screen, in an API field, or in a SQL verify script.
- Prefer **concrete example dates** (`"2026-05-06"`, `"2026-05-07"`) when the scenario is tied to a specific day. Only use abstract placeholders like `D` / `D+1` when the test is explicitly parameterized for any day.
- Break long `Expected` cells into a short numbered list separated by `<br>`, one observable fact per line, so a tester can tick them off one by one.
- If more than one observable fact must hold, list them; never combine several checks into one dense sentence.

#### Forbidden words / phrases in any column

Treat this list as **examples, not exhaustive**. If a word is developer jargon or names an internal artifact, rewrite it.

- Implementation / storage terms: `row`, `stored row`, `same-row window`, `segment`, `tail row`, `end-of-day cap`, `stored calendar date`, `post-shift through attendance end`.
- Process / code terms: `normalize`, `normalization`, `reconcile`, `reconciled status`, `allocator`, `light DTO`, `payload`, `selector`, `FAB`, `DTO`.
- Raw comparisons: `end <= start`, `End <= Start` — say `"an overtime entry whose end time is not after its start time"` or `"an overtime entry where the end time equals or comes before the start time"` instead.
- Table, column, and stored-procedure names (`AttendanceOverTime`, `sp_FixAttendanceOvertimeByDateRange`, `Request`, `RequestReceiver`, `AbpUsers`). These belong in the technical doc or the SQL verify script, not in the test-case `Case` / `Preconditions` / `Expected`.
- Parameterization noise without context (`date D`, `D+1`, `source day`) — replace with a concrete date unless the case is intentionally generic.

#### Allowed (and encouraged)

- Visible UI labels in quotes: `"Apply quick entry range correction"`, `"From"`, `"To"`, `"Save"`.
- Business nouns: `overtime entry`, `attendance entry`, `break`, `the employee's day`, `the day view`, `the correction`.
- Plain outcomes: `"the correction finishes with a success message (no server error)"`, `"the day shows exactly two overtime entries"`, `"no overtime entry covers the gap between "21:00" and "22:00""`.

#### Before / after example

Before (developer-flavored; **do not** write like this):

> Exactly **two** overtime rows on date **D**: one from shift end through attendance end (for example **"17:00:00"** to **"21:00:00"** when shift is **"09:00:00"**–**"17:00:00"** and attendance ended **"21:00:00"**), and one from **"22:00:00"** through end of day **"23:59:59"** (or end-of-day cap). No overtime row remains with end on or before start on date **D**. No single overtime row spans the idle gap between attendance end and **"22:00:00"**. API returns success without a database error.

After (tester-flavored; **write like this**):

> 1. The correction finishes with a success message (no server error).<br>2. The employee's day on `"2026-05-06"` shows exactly two overtime entries: `"17:00"`–`"21:00"` and `"22:00"`–`"23:59:59"`.<br>3. No overtime entry covers the gap between `"21:00"` and `"22:00"`.<br>4. No overtime entry has an end time equal to or earlier than its start time.

### Case (`Case` column)

- Always starts with **`Verify`**.
- Describes **what** is being checked in tester language (not component names).

Good:

- `Verify the user can register when all required fields are valid`
- `Verify the email field shows an error when it is left empty`

Bad:

- `Allowlisted user sees FAB` (jargon, no “Verify”)
- `TC-01` as the whole Case title

### Steps (`Steps` column)

- Use `1.`, `2.`, `3.` … each step **one** user action.
- Separate steps with `<br>` inside the table cell.
- Prefer verbs: **Open**, **Navigate to**, **Click**, **Enter**, **Select**, **Submit**.
- Refer to UI by **visible labels** in double quotes (`Click "Save"`).

Bad:

- `Click submitFormBtn`
- Internal names: `FAB`, `DTO`, `selector`, `NgRx`

Replace with plain words, for example:

- `FAB` → `the floating bug report button` (or the real label shown in UI)
- `DTO` → `the request body` / `the API response`

### Preconditions (`Preconditions` column)

- Describe **what the tester can see or check** before running the steps, in plain English.
- Use concrete values in double quotes (times, dates, labels, names). Split multi-fact preconditions into separate lines with `<br>`.
- Never use schema / stored-procedure / column names or implementation jargon (see the forbidden list above). Use `-` when there are no meaningful preconditions.

Good:

- `The employee has an attendance entry on "2026-05-06" that ended at "21:00".<br>The same day has an evening overtime entered as "22:00" to "00:00".<br>The shift is "09:00"–"17:00".`

Bad:

- `Overtime on date D shows start "22:00:00" and end "00:00:00" on the same calendar date.` (says "calendar date", uses abstract `D`, uses `HH:MM:SS` when the tester sees `HH:MM` on screen).

### Expected (`Expected` column)

- Say what the **user sees**, what the **API returns**, or what the **screen now shows** — in plain English.
- Put exact UI strings, messages, times, and dates in **double quotes**.
- When more than one thing must hold, write a short numbered list separated by `<br>` so the tester can tick each fact off.
- Never use implementation or storage jargon (`row`, `segment`, `tail row`, `end-of-day cap`, `normalize`, `reconcile`, table names, stored-procedure names). Translate into what the tester actually observes (`the day shows two overtime entries`, `the correction succeeds with no error`).

Good:

- `The form is not submitted and the message "This field is required" appears under the email field.`
- `Returns "200 OK" with a JSON body that contains the new record "id".`
- `1. The correction finishes with a success message (no server error).<br>2. The day on "2026-05-06" shows exactly two overtime entries: "17:00"–"21:00" and "22:00"–"23:59:59".<br>3. No overtime entry covers the gap between "21:00" and "22:00".`

Bad:

- `Exactly two overtime rows on date D; no overtime row has end <= start; API returns success without a database error.` (uses `row`, `end <= start`, abstract `D`, jargon `database error`).

### Test data (`Test data` column)

- One line per value inside the cell, separated by `<br>`.
- Pattern: `Field label: "value"`

Example:

`First name: "Sara"<br>Email: "sara@example.com"<br>Password: "Test@123"`

Use `-` when no specific test data is needed.

## Agent authoring rules

When linked application code changes product behavior:

1. **Update or create** the matching `*-test-cases.md` in the product TestCases repo in the **same task** as the code change.
2. **Create when missing:** If no spec file exists yet for that feature/layer/step, **create one** — do not close the task with "no test-case file exists."
3. Populate **Related code** (and **Related docs** when available) in `## Metadata` and per-row where needed.
4. Run `tc project doctor` from the TestCases repo root before marking the task complete.

## Worked example (minimal)

```markdown
# Example — Frontend Test Cases

## Metadata
- Project: `excp-time`
- Feature: `example`
- Layer: `frontend`
- Routes: `/register`
- APIs: -
- Related code: `src/app/...`
- Related docs: `docs/frontend/technical/example.md`

## Scope
- Registration screen validation.

## Test pages
- `/register`

## Test scenarios
- Required field validation is enforced before submit.

## Test cases

### Happy path

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-EXAMPLE-REGISTER-001 | Verify successful registration with valid data | Main | - | 1. Open the app.<br>2. Navigate to "Register".<br>3. Enter valid values in all required fields.<br>4. Click "Register". | The account is created and the message "You Are Registered Successfully" is shown. | First name: "Sara"<br>Email: "sara@example.com"<br>Password: "Test@123" |

### Validation

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-EXAMPLE-REGISTER-002 | Verify the first name field shows an error when it is empty | Edge | - | 1. Open the app.<br>2. Navigate to "Register".<br>3. Leave "First name" empty.<br>4. Fill the other required fields.<br>5. Click "Register". | The form is not submitted and the message "This field is required" appears under the first name field. | First name: ""<br>Email: "sara@example.com"<br>Password: "Test@123" |
```

## Test data scripts (optional)

When a scenario needs **SQL Server** (or other) setup, verification, or teardown, store scripts under `test-data/` and link them from the test-case file.

- **Placement:** Add a `## Test data scripts` section **after** `## Test cases` (and after any `###` group tables). The `tc` parser stops at the next `##`, so this section is not parsed as test rows.
- **Conventions:** See [`test-data/README.md`](../../test-data/README.md) for folder layout, file naming (`tc-NN-seed.sql`, `tc-NN-verify.sql`, `tc-NN-cleanup.sql`), and required header comments inside each script.
- **Verify scripts:** When a **`tc-NN-verify.sql`** exists, its **`THROW`/assertions** must cover the full **`Expected`** (and Preconditions that imply database rows). The markdown **Expected** should be written so it is **machine-checkable** in SQL where possible; the verify script owns those DB checks. See *Verify scripts (mandatory completeness)* in [`test-data/README.md`](../../test-data/README.md).
- **Table (recommended):**

| TC | Script | Purpose |
|----|--------|---------|
| TC-01 | [tc-01-seed.sql](../../test-data/…/tc-01-seed.sql) | One-line description |
| TC-01 | [tc-01-verify.sql](…) | After scenario: assert full **Expected** via `THROW` in SQL |
| TC-01 | [tc-01-cleanup.sql](…) | Remove seeded rows |

Use **relative links** from the markdown file to the script. Each `.sql` file must include a header block pointing back to this test-case doc (`Doc:` line).

## CLI status verification

- `npm test` — parser and status tests must pass.
- `npm run build`
- `node dist/cli.js list --status new`
- `node dist/cli.js s EXCP-EXAMPLE-REGISTER-001 ip 2 "Started manual validation"` for a real key in this repository.

## Future automation note

Future UI screens, database storage, watched automation, and code-change impact detection must all use `Key` as the stable identity.
