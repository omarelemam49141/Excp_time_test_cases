# ExcpTime.TestCases

Manual test-case definitions and committed run status for **EXCP Time** (frontend + backend).

- Config: [`testing-feature.project.json`](testing-feature.project.json)
- Index: [`test-cases/README.md`](test-cases/README.md)
- Format: [Testing-feature standard](O:/Company work/Company projects/ExcpTime/Testing-feature/docs/standards/test-case-format.md)

## CLI

From this folder:

```bash
node ../Testing-feature/dist/cli.js project doctor
node ../Testing-feature/dist/cli.js t "test-cases/quick-entry/frontend/quick-entry-unsaved-changes-test-cases.md"
node ../Testing-feature/dist/cli.js s EXCP-QE-UNSAVED-004 ok
```

Linked code repos: `EXCP_ANGULAR`, `Excp.HRSystem` (see `linkedRepos` in config).
