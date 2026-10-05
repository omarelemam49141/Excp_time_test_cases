# Delivery waves (formal testing approach)

## Purpose

A **delivery wave** is one planned chunk of product change (one PR, one agent task, or one release slice) together with the **manual test keys** that prove that chunk works. Waves stop testers and agents from stacking several plans at once: finish wave *N* before treating wave *N+1* as done.

This document is the **canonical standard**. Product repos do not fork the definition; they apply it in `*-test-cases.md` using `###` headings, optional `## Delivery waves` mapping, and the **`Requires`** column (enforced by `tc`).

## Definitions

| Term | Meaning |
|------|---------|
| **Wave** | One delivery chunk + its tests (e.g. “batch validate UI”, “range notify”). |
| **Gate** | A stable `Key` that must be `succeeded` in `status.json` before other keys may be marked `ok` (via **`Requires`**). |
| **Blocker** | A failed case that makes other cases meaningless until fixed; mark dependents `blocked` in `tc` and fix the blocker first. |

## How waves map to `tc`

1. **`Requires` column** — Comma-separated stable keys. `tc s MY-KEY ok` **refuses** until every required key is `succeeded` (unless `--force`). This is the machine-enforced gate between waves or between setup and dependent cases.

2. **`###` group headings** — Name the wave in the heading, e.g. `### Wave 2 — Batch validation`, so the markdown file stays readable. You may keep one table per `###` as today; if a wave spans many cases, one table under one `###` is fine.

3. **`## Delivery waves`** (optional) — A short section (table or bullets) listing wave number, intent, and which `Key` values belong to that wave. Use this when execution order is not obvious from `Requires` alone.

4. **Status** — Use `tc s KEY block "reason"` for cases waiting on a fix elsewhere. Do not move markdown into status folders.

5. **Structured failure** — When you fail or block a case, capture *why* with the `failure` block (kind + actual + fix hint) so the next agent can act:

   - **UI (`tc ui`)** — clicking **Failed** or **Blocked** opens a small modal asking for *kind*, *actual*, and *fix hint*. The block is stored in `status.json` under `cases[<key>].failure` and the panel shows it under the status pill afterwards.
   - **CLI** — `tc s <KEY> fail --failure-kind product-bug --actual "Only first date shown" --fix-hint "Wave 4 only — fix i18n + multi-day focus"`. The same flags work on `tc sf`, `tc sm`, and `tc sr`. Moving the case to any non-failure status clears the block automatically.
   - **Agent input** — Run `tc blockers --json` (or `GET /api/blockers`) to fetch all current blockers with wave label, dependents (from `Requires`), and a pre-rendered fix message. Filter with `--wave <n>`, `--file <path>`, `--feature <name>`, `--layer <frontend|backend>`, or `--kind <product-bug|test-out-of-date|environment|unknown>`.
   - **Wave headings** — `--wave N` matches any heading whose numbers cover `N`. Both single (`### Wave 4 — Range notify`) and multi-wave forms (`### Waves 2–4 — Batch validation, notify throttle, and range notify`, `### Waves 1, 3 — Edges`) are supported; ranges (`Waves 2-4`, `Waves 2–4`) expand to all numbers in between.

   This is what lets you tell the next agent “*Please fix the Wave 4 blocker.*” instead of repeating the long template by hand.

## Rules for authors and agents

1. **One agent task → one primary wave** — The closeout lists **Test What Changed** only for keys in that wave (plus a small regression slice). Do not dump the entire file.

2. **Prefer `Requires` over prose** — If TC-18 always needs TC-09’s setup, set `Requires: EXCP-…-007` instead of only writing “Complete TC-09” in Steps.

3. **Do not create circular `Requires`** — Keys must form a DAG. If A requires B and B requires A, split or remove one edge.

4. **Cross-file `Requires`** — Allowed when keys are unique repo-wide (e.g. frontend case requires a backend setup key).

5. **Optional waves** — Not every file needs numbered waves. Use waves when a feature shipped in multiple chunks or when QA asked for clearer staging.

## Example (conceptual)

| Wave | Intent | Representative keys | Typical `Requires` |
|------|--------|----------------------|--------------------|
| 1 | Baseline modal | `…-001`, `…-004` | `-` |
| 2 | Batch screen | `…-007` | `-` |
| 3 | Throttle / skip | `…-022` | `…-007` |
| 4 | Range notify | `…-023`, `…-018` | `…-007`; `…-018` also requires `…-023` if TC-18 must run after the focused two-day case |

## Failure kinds (used by the modal, CLI, and `tc blockers`)

| Kind | When to choose it | Typical follow-up |
|------|-------------------|-------------------|
| `product-bug` | The product code is wrong. | Agent fixes product code in the linked app repo. |
| `test-out-of-date` | The test case is stale (product changed, test did not). | Agent updates the markdown test case in this repo. |
| `environment` | Failure is outside the product (data, env, setup). | Fix the environment / fixture, retry. |
| `unknown` | Not yet triaged — refine later. | Re-classify before asking an agent to fix. |

## See also

- [Unified test-case format](./test-case-format.md) — `Requires` column and table rules.
- [Test management system](../test-management-system.md) — where status lives.
- Cursor rule template: [`templates/cursor-rules/delivery-waves.mdc`](../../templates/cursor-rules/delivery-waves.mdc) — installed with `tc project install-rules` for product TestCases repos, or copy manually into `.cursor/rules/`.
