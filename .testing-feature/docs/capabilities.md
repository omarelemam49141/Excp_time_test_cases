# Testing-feature capabilities (EXCP Time)

Synced by **`tc project sync`**. Update with **`tc project update`** when the vendor CLI or templates change.

## Stay current

```bash
tc project check-updates    # or: tc project updates
tc project update           # applies rules + this doc folder (--force)
```

After pulling **Testing-feature** vendor changes, rebuild the CLI once per machine:

```bash
cd /path/to/Testing-feature && npm run link:dev
```

## Core workflow

| Capability | How to use |
|------------|------------|
| Status CLI | `tc s <KEY> <status>` from this TestCases repo |
| Tester UI | `tc ui` — browse cases, Session, blockers, impact review |
| Session queue | **Session** view: feature queue, Start, status write-back, Next runnable |
| Impact | `tc impact --git` / auto-impact when linked app code changes |
| Blockers | `tc blockers` / **Blockers** tab — failed cases + agent fix messages |
| Guided run | `tc run <KEY>` / `tc run --file` (terminal parity with Session) |
| Backend xUnit | `.cursor/rules/backend-automated-tests.mdc` — backend Keys need xUnit + `dotnet test` in linked API repo |

## Session screen recording (fix-proof video)

Optional clips in **Session** for Azure DevOps / bug attachments.

- **Doc:** [session-recording.md](./session-recording.md)
- **UI:** `tc ui` → **Session** → **Fix-proof recording** (Chrome/Edge)
- **Storage:** `test-runs/current/evidence/<KEY>/` + metadata in `status.json`
- **Limit:** 5 clips per Key (delete to record again)
- **CLI:** `tc recording password`, `tc evidence list <KEY>`

When **EXCP Time** product behavior around manual testing changes, add or update product QA rows under `test-cases/**/frontend/` (or backend). Vendor self-tests for `tc` itself live only in the **Testing-feature** repo.

## Adding the next capability

Vendor checklist (Testing-feature repo):

1. Ship code in `tc` / `tc ui`.
2. Add `templates/sync-docs/<name>.md` and list it in `manifest.json`.
3. Add a row in this file and in `testing-feature-capabilities.mdc`.
4. Bump `templates/sync-manifest.json` version.
5. Document in `docs/technical/` (vendor).

Product checklist (this repo):

```bash
tc project update
tc project doctor
```
