# Overtime ask-after-gap admin UI Test Cases

## Metadata

- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`
- APIs: `POST /api/system-work-schedule/save-admin-bundle`
- Related code: `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html`, `src/app/core/models/system-work-schedule.model.ts`
- Related docs: `docs/frontend/technical/overtime-ask-after-gap-admin.md`

## Scope

- Overtime & gaps tab: defaults field and date-rule override for ask-after-gap minutes.

## Test scenarios

- Save and reload defaults on Overtime tab
- Rule override visible and persists

## Test cases

### Wave 2 — Admin UI

| ID | Key | Case | Type | Requires | Steps | Expected |
|----|-----|------|------|----------|-------|----------|
| TC-01 | EXCP-SCHED-OT-ASK-UI-001 | Verify Admin can set ask-after-gap on Overtime defaults and value persists after save and reload. | Main | EXCP-SCHED-OT-ASK-API-001 | 1. Sign in as Admin.<br>2. Open `/admin/system-work-schedule` → **Overtime & gaps**.<br>3. Set **Ask employee after gap (minutes)** to `15`.<br>4. Save.<br>5. Reload the page. | 1. Field shows `15` after reload.<br>2. No validation error is shown. |
| TC-02 | EXCP-SCHED-OT-ASK-UI-002 | Verify date rule override **Override ask after gap (minutes)** saves and reloads. | Edge | EXCP-SCHED-OT-ASK-API-003 | 1. On a schedule rule row, set **Override ask after gap (minutes)** to `20`.<br>2. Save and reload. | 1. Rule row still shows `20`. |
