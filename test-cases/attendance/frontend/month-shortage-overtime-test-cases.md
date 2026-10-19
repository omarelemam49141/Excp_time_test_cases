# Month shortage and overtime (frontend) Test Cases

## Metadata
- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`, `/home`, `/my-requests`, `/admin-leader/subordinate-requests`
- APIs: `POST /api/system-work-schedule/update-admin-bundle`, `POST /api/attendance-overtime/Preview-month-extra-offer`, `POST /api/AttendanceRecord/End-work`
- Related code: `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html`, `src/app/core/components/end-work-modal/end-work-modal.component.ts`, `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.html`
- Related docs: `docs/frontend/technical/month-shortage-overtime.md`
- Automation: `-`

## Scope

Admin working-month day and overrides, end-work and My Requests choices, Shortage requests tab.

## Test scenarios

- Save start day and an override
- End-work choice matrix
- My Requests uses the same offer
- Leader shortage tab accept/refuse

## Test cases

### Admin and employee UI

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-MONTH-UI-ADMIN-001 | Verify Overtime & gaps has working-month start day and override list. | Main | - | 1. Open `/admin/system-work-schedule` Overtime & gaps.<br>2. Set start day 26.<br>3. Add October override start day 5.<br>4. Save. | 1. Field label is "Working month starts on day".<br>2. Hint includes the 26 Sep example.<br>3. Override row remains after reload. | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html` |
| TC-02 | EXCP-MONTH-UI-END-001 | Verify end-work past ask-after shows shortage choice when the month is still short. | Main | EXCP-MONTH-UI-ADMIN-001, EXCP-ATT-ENDWORK-UI-002 | 1. Employee is short for the open month.<br>2. End work past ask-after. | 1. Modal shows remaining shortage and extra after the allowance.<br>2. "Send as shortage cover" is available. | `src/app/core/components/end-work-modal/end-work-modal.component.ts` |
| TC-03 | EXCP-MONTH-UI-END-002 | Verify My Requests shows the same choices after the time range is valid. | Main | EXCP-MONTH-UI-END-001 | 1. Open My Requests overtime dialog.<br>2. Enter a valid time range and continue. | 1. Offer summary is shown.<br>2. A plain overtime submit is not available when the offer is shortage or split. | `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts` |
| TC-04 | EXCP-MONTH-UI-LEADER-001 | Verify Shortage requests tab lists shortage rows with accept and refuse. | Main | EXCP-MONTH-UI-END-001 | 1. Open subordinate requests.<br>2. Open "Shortage requests".<br>3. Open a pending shortage row. | 1. Tab sits next to "Over time requests".<br>2. Detail shows purpose, requested minutes, and month hole.<br>3. Accept and Refuse use the current routing gate. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.html` |
