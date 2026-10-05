# System Work Schedule — Overtime gap home vs site (Frontend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`
- APIs: `POST /api/system-work-schedule/export-admin-settings`, `POST /api/system-work-schedule/import-admin-settings`
- Related code: `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/core/models/system-work-schedule.model.ts`
- Related docs: `docs/frontend/technical/system-work-schedule-admin-settings-json-transfer.md`

## Scope

- Admin Overtime tab: separate site and home overtime-gap minutes on defaults and schedule rules.
- JSON export/import round-trip includes both fields.

## Delivery waves

| Wave | Intent | Keys |
|------|--------|------|
| 1 | Home vs site gap settings | EXCP-SCHED-OT-GAP-001 … 005 |

## Test scenarios

- Save and reload distinct site vs home gap on defaults
- Rule override for home gap on a scoped rule
- JSON export/import preserves both gaps
- JSON export/import preserves explicit home gap `0`
- Legacy JSON without home gap copies site value on import

## Test cases

### Wave 1 — Home vs site overtime gap

| ID | Key | Case | Type | Steps | Expected |
|----|-----|------|------|-------|----------|
| TC-01 | EXCP-SCHED-OT-GAP-001 | Verify Admin can set different site and home overtime gap minutes on the Overtime defaults tab and both persist after save and reload. | Main | 1. Sign in as Admin.<br>2. Open `/admin/system-work-schedule` → Overtime tab.<br>3. Set "Overtime gap — on site" to `30`.<br>4. Set "Overtime gap — from home" to `15`.<br>5. Save.<br>6. Reload the page. | 1. Both fields show `30` and `15` after reload.<br>2. No validation error is shown. |
| TC-02 | EXCP-SCHED-OT-GAP-002 | Verify A schedule rule can override the home overtime gap independently from the site override. | Main | 1. On System work schedule, add or edit a rule with a known scope.<br>2. Set override site gap to `20` and override home gap to `10`.<br>3. Save and reload. | 1. The rule row shows site override `20` and home override `10` after reload. |
| TC-03 | EXCP-SCHED-OT-GAP-003 | Verify Export JSON includes `overtimeGapMinutesFromHome` and Import restores both site and home values. | Main | 1. Set site gap `25` and home gap `12`; save.<br>2. Export JSON.<br>3. Change both values; save.<br>4. Import the exported JSON and confirm. | 1. Exported `defaults` contains `overtimeGapMinutes` and `overtimeGapMinutesFromHome`.<br>2. After import, site shows `25` and home shows `12`. |
| TC-04 | EXCP-SCHED-OT-GAP-004 | Verify Legacy JSON without `overtimeGapMinutesFromHome` copies the site gap into home on import. | Edge | 1. Paste a schema v1 export that has `overtimeGapMinutes: 30` but no `overtimeGapMinutesFromHome` key on `defaults`.<br>2. Import and confirm. | 1. Import succeeds.<br>2. Home gap field shows `30` (same as site). |
| TC-05 | EXCP-SCHED-OT-GAP-005 | Verify Export/import round-trip preserves an explicit home overtime gap of `0` minutes. | Edge | 1. Set site gap `30` and home gap `0`; save.<br>2. Export JSON.<br>3. Change home gap to another value; save.<br>4. Import the exported JSON and confirm. | 1. Exported `defaults` contains `"overtimeGapMinutesFromHome": 0`.<br>2. After import, site shows `30` and home shows `0`. |
