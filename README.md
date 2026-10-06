# ExcpTime.TestCases

Manual test-case definitions and committed run status for **EXCP Time** (frontend + backend).

- Config: [`testing-feature.project.json`](testing-feature.project.json)
- Index: [`test-cases/README.md`](test-cases/README.md)
- Format: [test-case format](docs/standards/test-case-format.md)

Linked application repos (see `linkedRepos` in config):

- Frontend: [`../EXCP_ANGULAR`](../EXCP_ANGULAR)
- Backend: [`../../HRSystem/ABP-Basic/Excp.HRSystem`](../../HRSystem/ABP-Basic/Excp.HRSystem)

## How we test EXCP Time

| What | Where |
|------|--------|
| Test definitions | `test-cases/<feature>/frontend\|backend/*-test-cases.md` (this repo) |
| Run status | `test-runs/current/status.json` (committed; never move markdown for status) |
| Stable identity | **`Key`** column (`EXCP-...`), not `TC-01` alone |
| Tooling | Bundled `tc` in this repo (`npm install`, then `npm run ui`) |

Status values: `new`, `in-progress`, `succeeded`, `failed`, `blocked`, `needs-update`.

### Quality gate (before merge)

All `*-test-cases.md` files have **Related code** mapped to real paths in linked app repos. Run:

```powershell
npm run doctor -- --strict
```

Exit code **0** is required (no unmapped Related code, no stale paths). When you add or change a feature, update **Related code** and **Related docs** in the same task.

## Install the GUI

Node.js 18+. From **this repo root** (no Testing-feature clone):

```powershell
npm install
npm run ui
```

Open `http://127.0.0.1:3847`.

The CLI is the file `vendor/excp-tc-1.0.0.tgz` (built app only). After `npm install`, `npm run doctor` and `npx tc` work from this folder too.

## CLI (day one)

From this folder, after `npm install`:

```powershell
npx tc project doctor
npx tc t "test-cases/quick-entry/frontend/quick-entry-pending-leave-request-guard-test-cases.md"
npx tc next "test-cases/quick-entry/frontend/quick-entry-pending-leave-request-guard-test-cases.md"
npx tc s EXCP-QE-PENDING-LEAVE-013 ok
npx tc list --status succeeded
```

After code changes in linked repos (when **Related code** is mapped):

```powershell
npx tc impact --git              # dry-run
npx tc impact --git --apply      # mark succeeded keys needs-update
```

Bulk status: `npx tc sf`, `npx tc sm`, `npx tc sr`.

## Web UI

Browse cases, filter by status, view file todo lists by markdown `###` groups, and update status from the case detail panel (same rules as `tc s`, including **Requires**).

```powershell
npm run ui
```

Optional: `npx tc ui --port 3847 --open`

## Status metadata repair

If `sourceFile` paths drift after a layout change, run (does **not** change status values):

```powershell
node scripts/repair-status-metadata.mjs
```

Backup is kept at `test-runs/current/status.json.bak-adoption-2026-05-17` from adoption.

## Agent / QA closeout

When app code changes, update matching `*-test-cases.md` here in the **same task**, then end with **Test What Changed** and **Regression Re-Run** (see `.cursor/rules/test-case-closeout-list.mdc`).

## Cursor workspace

Open this repo alongside `EXCP_ANGULAR` and `EXCPTIME_MVC`. Example multi-root file: [`excp-time.code-workspace`](excp-time.code-workspace). Teammates do not need the Testing-feature source repo.
