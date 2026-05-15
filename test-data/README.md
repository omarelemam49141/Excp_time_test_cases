# Test data (SQL) — conventions

This folder holds **runnable SQL** linked from manual test-case markdown (test-cases/**/*.md`). Use it for **seed**, **verify**, and **cleanup** scripts when a scenario needs a known database state.

## Layout (mirror `test-cases/`)

For a test-case file:

`test-cases/<project>/<feature>/<layer>/<file>-test-cases.md`

create a mirrored folder:

`test-data/<project>/<feature>/<layer>/<file>/`

**Folder name** = the markdown basename **without** `-test-cases.md`.

Example:

| Test-case doc | SQL folder |
|---------------|------------|
| `test-cases/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime-test-cases.md` | `test-data/excp-time/quick-entry/backend/quick-entry-correction-cross-midnight-overtime/` |

## File naming

| Pattern | When to run |
|---------|-------------|
| `tc-NN-seed.sql` | Before executing the scenario (UI or API). |
| `tc-NN-verify.sql` | After executing the scenario (assert DB or copy/paste checks). |
| `tc-NN-cleanup.sql` | Tear down seeded rows (optional; use after verify or to reset). |

`NN` matches the test-case ID in the markdown table (`TC-01` → `tc-01-...`).

If **TC-B reuses** the same preconditions as **TC-A**, do **not** duplicate scripts: in the test-case doc, point TC-B to TC-A’s files (see example in `quick-entry-correction-cross-midnight-overtime-test-cases.md`).

## Script headers (required)

Every `.sql` file starts with a block like:

```sql
-- =================================================================
-- Test case:  TC-01
-- Feature:    <short name>
-- Doc:        test-cases/<project>/<feature>/<layer>/<file>-test-cases.md
-- Purpose:    Seed | Verify | Cleanup
-- Variables:  @TestDate (date), @Email (nvarchar) — set at top of script
-- Expect:      (verify scripts) numbered checklist matching each THROW/assertion
-- =================================================================
```

## Variables and idempotency

- Prefer **`@TestDate`** and **`@Email`** at the top of each script so testers can retarget without editing the whole file.
- **Seed** scripts must be **idempotent** for that slice of data: delete existing rows for the same user/date (and dependents) before `INSERT`, or use a dedicated test date nobody else uses.

## Verify scripts (mandatory completeness)

Every **`tc-NN-verify.sql`** must **prove** the same outcomes as **`TC-NN`** in the linked markdown: use the row’s **Expected** (and Preconditions that imply database shape) as the checklist.

1. **Map coverage** — Each distinct outcome in **Expected** should have at least one **machine check** (`IF … THROW`, `EXISTS`/`NOT EXISTS`, counts, forbidden rows, time windows). Do not rely on a single metric (for example “invalid row count”) unless that is the only acceptance criterion.
2. **Fail-fast** — Run **`THROW`** (or equivalent) **before** optional diagnostic `SELECT`s so failures stop with a clear message.
3. **Header** — The script header `-- Expect:` block should list the same checks (compact checklist) so reviewers can confirm parity with the markdown table.
4. **Diagnostics** — Optional `SELECT` result sets **after** all asserts succeed are fine for human inspection.
5. **SQL Server** — Avoid problematic result column aliases such as **`RowCount`**; use **`InvalidCount`**, **`MatchedCount`**, or bracketed identifiers.

Do **not** ship verify scripts that only “list rows for manual review” unless the test-case doc explicitly marks the scenario **manual-only** (rare).

## Linking (bidirectional)

1. **Doc → SQL:** In the test-case markdown, add an optional section **`## Test data scripts`** *after* **`## Test cases`** (see [test-case format](../docs/standards/test-case-format.md)). Use relative links into `test-data/`.
2. **SQL → Doc:** The header `Doc:` line must match the path to the markdown file (repo-relative from `Testing-feature/` root).

## Parser note

The `tc` parser only reads `## Test cases` tables up to the next top-level `##` heading. Content **after** that section, including `## Test data scripts, is ignored by status parsing and safe to add.
