# Modify attendance → list users status (frontend)

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/attendance/modify-attendance`, `/admin-leader/list-users`
- APIs: `POST /api/attendance-record/Update-attendance-record-with-breaks`, get-users-list
- Related code: `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`, `src/app/features/admin-leader/shared/components/list-users/list-users-table/list-users-table.component.html`
- Related docs: `docs/frontend/technical/list-users-attendance-status-sync.md`, `docs/backend/technical/attendance-status-sync-from-record.md`

## Scope

- After modify-attendance changes times, admin list-users status badge matches the employee working state.
- Arabic and English status labels on the list table.

## Test scenarios

- Clear end time → list shows present, not ended shift.
- Set both times → list shows ended shift.
- Clear both times → list shows absent.

## Test cases

### End-to-end status

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-UI-STATUS-001 | Verify list-users shows present after end time is cleared via modify-attendance. | Main | Employee ended work earlier. Admin or employee can open modify-attendance for today. | 1. Open modify-attendance for today.<br>2. Set start time and clear end time; save.<br>3. As admin/leader, open `/admin-leader/list-users` (Today & attendance tab).<br>4. Find that employee. | 1. Save succeeds.<br>2. End time column shows "Not registered" / "غير مسجل".<br>3. Status badge shows "In" / "حاضر", not "EndShift" / "أنهى الدوام". | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`, `src/app/features/admin-leader/shared/components/list-users/list-users-table/list-users-table.component.html` |
| TC-02 | EXCP-ATT-UI-STATUS-002 | Verify list-users shows ended shift when both times are set. | Main | Employee has an open day or modify-attendance access for today. | 1. Set start and end times in modify-attendance; save.<br>2. Open list-users for that employee. | Status badge shows "EndShift" / "أنهى الدوام". End time column shows the saved time. | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`, `src/app/features/admin-leader/shared/components/list-users/list-users-table/list-users-table.component.html` |
| TC-03 | EXCP-ATT-UI-STATUS-003 | Verify list-users shows absent when both times are cleared. | Edge | Modify-attendance allowed for today. | 1. Clear start and end in modify-attendance; save.<br>2. Open list-users. | 1. Start and end columns show "Not registered".<br>2. Status shows "Out" / "غائب". | `src/app/features/attendance/components/modify-attendance/modify-attendance.component.ts`, `src/app/features/admin-leader/shared/components/list-users/list-users-table/list-users-table.component.html` |
