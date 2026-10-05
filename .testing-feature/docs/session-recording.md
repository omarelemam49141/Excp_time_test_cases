# Session screen recording

Fix-proof video clips for manual testing in **Session** (`tc ui`). Clips are stored under this TestCases repo and linked to stable **Key** values for upload to Azure DevOps or similar trackers.

## Storage

```
test-runs/current/
  status.json
  .recording-unlock.json    # hashed password (local only)
  evidence/
    platform-host/frontend/host-auth-test-cases/
      1-PLAT-HOST-AUTH-001/
        1- 2026-06-17T12-00-00-000Z.webm
      2-PLAT-HOST-AUTH-002/
        1- 2026-06-17T12-10-00-000Z.webm
    sard/frontend/sard-checkpoints-test-cases/
      7-ALFQ-SARD-PLAN-001/
        1- 2026-06-26T11-56-21-221Z.webm
```

Evidence is grouped **by spec file** (feature folder), then **by case order within that file**:

- **Feature group:** path under `test-cases/` without `.md` (e.g. `platform-host/frontend/host-auth-test-cases`).
- **Case folder:** `{n}-{Key}` where `n` is row order in that file (TC-01 → `1`, TC-02 → `2`).
- **Clip files:** per-key clip order (`{n}- {timestamp}…`).

Legacy flat folders (`evidence/{globalOrder}-{Key}`) are still read; run `tc evidence renumber` to migrate into the nested layout.


`status.json` stores structured `evidence` per key (path, duration, bytes, source).

All paths under `test-runs/` are local only (never commit or push).

## Session UI

1. **Start** a case (`in-progress`).
2. **Fix-proof recording** (optional): **Record** → share the **product app tab** → **Stop & save**.
   - Optional: **Include microphone (your voice)** before **Record**.
3. Up to **5 clips per Key** — delete one to record again.
4. On **Succeeded**, if no clip this session, a soft prompt offers continue / record / cancel.

## Capture modes

| Mode | Default | Gate |
|------|---------|------|
| Chrome tab | Yes | Share picker |
| Window | No | Risk confirm + repo unlock password |
| Full screen | No | Risk confirm + repo unlock password |

- Chrome/Edge only; video only by default. Optional **Include microphone (your voice)** — not tab/system audio.
- No upload size cap — clips stream to disk. Long recordings (10+ minutes) supported with upload progress; ffmpeg may optimize in the background.

## CLI

```bash
tc recording password 'your-secret' --set --cwd .
tc evidence list EXCP-EXAMPLE-001 --cwd .
tc evidence renumber --cwd .
```

Run from this TestCases repo root.

## Privacy

- Share the **product app tab**, not the `tc ui` tab.
- Window/full screen may capture sensitive content — use tab mode when possible.
