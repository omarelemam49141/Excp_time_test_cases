# Month shortage and overtime (frontend) Test Cases

## Metadata
- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`, `/home`, `/my-requests`, `/admin-leader/subordinate-requests`
- APIs: `POST /api/system-work-schedule/update-admin-bundle`, `POST /api/AttendanceRecord/End-work`
- Related code: `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html`, `src/app/core/components/end-work-modal/end-work-modal.component.ts`, `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts`, `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.html`
- Related docs: `docs/frontend/technical/month-shortage-overtime.md`
- Automation: `-`

## Scope

Admin working-month day and overrides, the end-work and My Requests split between overtime and coverage, Shortage requests tab.

## Test scenarios

- Save start day and an override
- End-work split
- My Requests uses the same split control
- Leader shortage tab accept/refuse

## Test cases

### Admin and employee UI

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-MONTH-UI-ADMIN-001 | Verify Overtime & gaps has working-month start day and override list. | Main | - | 1. Open `/admin/system-work-schedule` Overtime & gaps.<br>2. Set start day 26.<br>3. Add October override start day 5.<br>4. Save. | 1. Field label is "Working month starts on day".<br>2. Hint includes the 26 Sep example.<br>3. Override row remains after reload. | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html` |
| TC-02 | EXCP-MONTH-UI-END-001 | Verify end-work at or above the gap offers the whole time split between overtime and coverage. | Main | EXCP-MONTH-UI-ADMIN-001, EXCP-ATT-ENDWORK-UI-002 | 1. Gap 30.<br>2. End work 50 minutes past shift end. | 1. Modal shows the split control with a 50 minute total.<br>2. Coverage and overtime always add up to 50 minutes. | `src/app/core/components/end-work-modal/end-work-modal.component.ts` |
| TC-03 | EXCP-MONTH-UI-END-002 | Verify My Requests has the same split control under the time range. | Main | EXCP-MONTH-UI-END-001 | 1. Open My Requests overtime dialog.<br>2. Enter a valid time range. | 1. The split control shows the requested net time.<br>2. Submitting sends coverage and overtime that add up to that time. | `src/app/features/attendance/components/request-overtime-dialog/request-overtime-dialog.component.ts` |
| TC-04 | EXCP-MONTH-UI-LEADER-001 | Verify Shortage requests tab lists shortage rows with accept and refuse. | Main | EXCP-MONTH-UI-END-001 | 1. Open subordinate requests.<br>2. Open "Shortage requests".<br>3. Open a pending shortage row. | 1. Tab sits next to "Over time requests".<br>2. Detail shows purpose and requested minutes.<br>3. Accept and Refuse use the current routing gate. | `src/app/features/admin-leader/shared/components/subordinate-requests/subordinate-requests.component.html` |
