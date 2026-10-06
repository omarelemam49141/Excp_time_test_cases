# EXCP Time — teammate setup (Cursor)

Use this after cloning the three git repos. Folder names and drive letters can differ; only **relative links** between repos must match your layout.

## 1. Clone repos (same parent folder recommended)

Put all three next to each other, for example:

```text
D:\dev\excp\
  EXCP_ANGULAR\          ← Azure DevOps
  EXCPTIME_MVC\          ← Azure DevOps (or EXCP_TIME_MVC — your folder name)
  Excp_time_test_cases\  ← GitHub (this repo)
```

Azure:

- `https://dev.azure.com/ExProtectionProduects/EXCP%20Time/_git/EXCP_ANGULAR`
- `https://dev.azure.com/ExProtectionProduects/EXCP%20Time/_git/EXCPTIME_MVC`

GitHub:

- `https://github.com/omarelemam49141/Excp_time_test_cases.git`

Checkout branch **`issues-new`** on Angular and MVC (unless your lead says otherwise).

## 2. Cursor workspace

**File → Add Folder to Workspace** — add all three clones. **File → Save Workspace As…** (any path you like).

Or open `excp-time.code-workspace` from this repo and fix each folder `path` if your clone names differ (right-click folder → wrong path → remove and re-add).

You do **not** clone the Testing-feature vendor repo. The test-case GUI is bundled in this repo.

## 3. `testing-feature.project.json` (paths to Angular + API)

At the root of **this** TestCases repo, edit `linkedRepos` so each `path` points from **this repo’s root** to your clones:

```json
"linkedRepos": [
  { "role": "frontend", "path": "../EXCP_ANGULAR" },
  { "role": "backend", "path": "../EXCPTIME_MVC" }
]
```

If your folders are not siblings, use the correct relative path (e.g. `../apps/EXCP_ANGULAR`). Commit this file only if your team agrees on one layout; otherwise keep local edits and do not push path-only changes.

## 4. Tools

| Tool | Version |
|------|---------|
| Node.js | 18+ |
| .NET SDK | 8 |
| Git | latest |
| Cursor | latest |

**Frontend** (from Angular clone):

```bash
npm install
npm start
```

**Backend**: open `Excp.HRSystem.sln`, run `Excp.HRSystem.Web`. Local API URL in Angular `src/environments/environment.ts` is usually `https://localhost:44384/api/`.

## 5. Test cases and QA status

- Specs: `test-cases/<feature>/frontend|backend/*-test-cases.md`
- Format: `docs/standards/test-case-format.md` (in this repo)
- Run status: `test-runs/current/status.json`
- GUI (from this repo root, Node 18+):

```powershell
npm install
npm run ui
```

Browser: `http://127.0.0.1:3847`

## 6. What syncs via git

Push/pull this repo for test cases, `test-runs`, `test-data`, `queries`, and `testing-feature.project.json`. Coordinate on `status.json` to avoid merge conflicts.

## 7. Cursor rules

Rules in each repo’s `.cursor/` and `.cursorrules` are in git. They refer to the **TestCases repo in your workspace**, not a fixed `O:\...` path.

**EXCP_ANGULAR** also ships shared agent behavior (pull latest `issues-new`):

- `.cursor/rules/ask-before-optional-steps.mdc` — no auto test-case / browser / build unless you ask
- `.cursor/skills/caveman/` + `.cursor/rules/caveman-priority.mdc` — terse reply tone (project skill; no copy to `~/.cursor/skills` needed if this repo is in the workspace)

If the agent still mentions an old absolute path, your lead may have unpushed rule updates — pull latest on all three repos.

## 8. Refresh the GUI bundle (team lead only)

Teammates never clone Testing-feature. After you change that tool, rebuild and replace `vendor/excp-tc-1.0.0.tgz` (pack `dist/` + `templates/` only, package name `excp-tc`), then commit the new tarball. Teammates pull and run `npm install` again.
