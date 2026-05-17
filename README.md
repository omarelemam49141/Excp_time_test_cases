# ExcpTime.TestCases

Manual test-case definitions and committed run status for **EXCP Time** (frontend + backend).

- Config: [`testing-feature.project.json`](testing-feature.project.json)
- Index: [`test-cases/README.md`](test-cases/README.md)
- Format: [Testing-feature standard](O:/Company work/Company projects/ExcpTime/Testing-feature/docs/standards/test-case-format.md)

Linked application repos (see `linkedRepos` in config):

- Frontend: [`../EXCP_ANGULAR`](../EXCP_ANGULAR)
- Backend: [`../../HRSystem/ABP-Basic/Excp.HRSystem`](../../HRSystem/ABP-Basic/Excp.HRSystem)

## How we test EXCP Time

| What | Where |
|------|--------|
| Test definitions | `test-cases/<feature>/frontend\|backend/*-test-cases.md` (this repo) |
| Run status | `test-runs/current/status.json` (committed; never move markdown for status) |
| Stable identity | **`Key`** column (`EXCP-...`), not `TC-01` alone |
| Tooling | [`tc` CLI](../Testing-feature) from **this repo root** |

Status values: `new`, `in-progress`, `succeeded`, `failed`, `blocked`, `needs-update`.  
`tc project doctor --strict` is **not** required yet — map **Related code** in Metadata when you touch a feature.

## Install `tc`

From [Testing-feature](../Testing-feature):

```powershell
npm install
npm run link:dev
```

Or without a global link, from this folder:

```powershell
node "../Testing-feature/dist/cli.js" project doctor
```

## CLI (day one)

From this folder:

```powershell
tc project doctor
tc t "test-cases/quick-entry/frontend/quick-entry-pending-leave-request-guard-test-cases.md"
tc next "test-cases/quick-entry/frontend/quick-entry-pending-leave-request-guard-test-cases.md"
tc s EXCP-QE-PENDING-LEAVE-013 ok
tc list --status succeeded
```

After code changes in linked repos (when **Related code** is mapped):

```powershell
tc impact --git              # dry-run
tc impact --git --apply      # mark succeeded keys needs-update
```

Bulk status: `tc sf`, `tc sm`, `tc sr` — see [CLI guide](../Testing-feature/docs/technical/cli.md).

## Web UI (`tc ui`)

Browse cases, filter by status, view file todo lists by markdown `###` groups, and update status from the case detail panel (same rules as `tc s`, including **Requires**).

```powershell
tc ui
# optional: tc ui --port 3847 --open
```

Requires a built Testing-feature (`npm run build` includes `dist/ui/`).  
UX standards: [ui-ux-standards.md](../Testing-feature/docs/technical/ui-ux-standards.md).

## Status metadata repair

If `sourceFile` paths drift after a layout change, run (does **not** change status values):

```powershell
node scripts/repair-status-metadata.mjs
```

Backup is kept at `test-runs/current/status.json.bak-adoption-2026-05-17` from adoption.

## Agent / QA closeout

When app code changes, update matching `*-test-cases.md` here in the **same task**, then end with **Test What Changed** and **Regression Re-Run** (see `.cursor/rules/test-case-closeout-list.mdc`).

## Cursor workspace

Open this repo alongside `EXCP_ANGULAR`, `Excp.HRSystem`, and `Testing-feature` so agents run `tc` from the correct root. Example multi-root file: [`excp-time.code-workspace`](excp-time.code-workspace).
