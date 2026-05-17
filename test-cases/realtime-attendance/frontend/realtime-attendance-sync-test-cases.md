# Realtime attendance sync — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `realtime-attendance`
- Layer: `frontend`
- Routes: `/home`, `/attendance/working-time`, `/attendance/overtime-timer`, `/admin-leader/list-requests`
- APIs: -
- Related code: `src/app/core/services/Signal-R/attendance-hub.service.ts`, `src/app/core/services/attendance-realtime-sync.service.ts`, `src/app/core/models/attendance-state-changed.model.ts`, `src/app/pages/home/home.component.ts`, `src/app/features/attendance/components/working-timer/working-timer.component.ts`, `src/app/features/attendance/components/overtime-timer/overtime-timer.component.ts`
- Related docs: `docs/frontend/technical/realtime-attendance-sync.md`

## Scope

- Same user signed in on two sessions (two browsers, two tabs, or web + installed app) stays aligned for today's attendance: home actions, working timer, overtime timer, and automatic navigation when the other session changes state.
- SignalR reconnect and returning to a background tab trigger a safe refresh without duplicate noisy reloads.

## Test pages

- `/home`
- `/attendance/working-time`
- `/attendance/overtime-timer`
- `/admin-leader/list-requests`

## Test scenarios

- Start or end work in session A updates session B home and timer without full page reload.
- Start or end break in session A updates session B working timer state.
- Start or end overtime (and overtime break) in session A updates session B overtime screen and navigation.
- Session B regains network after SignalR reconnect and still shows correct status after a short delay.
- Session B returns from a long background and sees updated status after bringing the window forward.
- Session B's browser should not show the same attendance API name firing many times in a row for one action in the other session (no noisy duplicate calls).
- Quick alt-tab (under 30 seconds away) should not fire any attendance API calls.
- Non-attendance pages refresh attendance status in the background without automatic route changes.

## Test cases

### Multi-session sync

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-RTATT-SYNC-001 | Verify Start work in other session updates home without reload | Main | User has two signed-in sessions for the same account.<br>Session B is on "Home". | 1. In session A, start work for today using the normal home action.<br>2. In session B, wait a few seconds without manually refreshing the browser.<br>3. Observe home actions and any work-day progress area. | Session B shows the same "working" state as session A (start action no longer offered; end or break actions match the new state). | - |
| TC-02 | EXCP-RTATT-SYNC-002 | Verify End work in other session returns session B to home flow | Main | Same two sessions.<br>Session B is on "Working time". | 1. In session A, end work for today.<br>2. In session B, wait without manual full reload. | Session B leaves the working-time screen or shows a finished-day home state consistent with session A (no active work timer). | - |
| TC-03 | EXCP-RTATT-SYNC-003 | Verify Break start/end syncs working timer | Edge | Same two sessions.<br>User is actively working. | 1. In session A, start break.<br>2. Observe session B on working time.<br>3. In session A, end break.<br>4. Observe session B again. | Session B break state matches session A after each step (break running vs work running) without requiring a manual browser refresh. | - |
| TC-04 | EXCP-RTATT-SYNC-004 | Verify Overtime and overtime break sync | Edge | Same two sessions.<br>Overtime is allowed for the user. | 1. In session A, start overtime and confirm session B on overtime timer updates.<br>2. In session A, start overtime break; confirm session B.<br>3. In session A, end overtime break, then end overtime; confirm session B. | Session B overtime screen and navigation follow session A through each step without a manual full reload. | - |
| TC-05 | EXCP-RTATT-SYNC-005 | Verify Wrong route self-corrects when other session changes state | Edge | Session B is on "Home" while user is actually still working according to session A. | 1. In session A, start work if needed so the user is actively working.<br>2. In session B, open "Home" if not already there.<br>3. Wait a few seconds. | Session B automatically opens the working-time experience (or otherwise matches the active work state) without the user manually navigating to working time. | - |
| TC-06 | EXCP-RTATT-SYNC-006 | Verify Reconnect recovery | Edge | Same two sessions.<br>Session B can disable network briefly. | 1. Confirm both sessions show the same attendance state.<br>2. On session B only, turn off network for ~10 seconds, then turn it back on.<br>3. After the app reconnects, change attendance in session A.<br>4. Observe session B. | Session B returns to a connected state and then reflects session A's latest change within a short wait, without a full manual reload. | - |
| TC-07 | EXCP-RTATT-SYNC-007 | Verify Background tab refresh | Edge | Same two sessions. | 1. Put session B in a background tab for several minutes.<br>2. In session A, change attendance (start or end work).<br>3. Bring session B to the foreground and wait a few seconds. | Session B updates to match session A after the tab becomes visible (no stale "old" buttons that conflict with the real server state). | - |

### Network efficiency (regression)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-RTATT-SYNC-008 | Verify Passive home does not repeat the same attendance API many times for one remote action | Regression | Same two sessions.<br>Session B is on "Home" with developer tools **Network** open (filter to **Fetch/XHR** or **All**). | 1. Clear the network list on session B.<br>2. In session A, perform **one** clear action (for example start work **once**).<br>3. On session B, wait until the home UI has updated.<br>4. Count how many times `"Is-attendance-record-registered"` and `"Get-work-progress"` appear in the list for that single remote action. | 1. Session B's UI still matches session A after the update.<br>2. `"Is-attendance-record-registered"` appears **at most once** for that action (not three or more in a tight burst).<br>3. `"Get-work-progress"` appears **at most once** for that action (not two or more in a tight burst). | - |
| TC-09 | EXCP-RTATT-SYNC-009 | Verify Quick alt-tab does not trigger any attendance API calls | Regression | User is signed in on one session with developer tools **Network** open (filter to **Fetch/XHR**). | 1. Clear the network list.<br>2. Switch to another application window for less than 30 seconds.<br>3. Switch back to the browser.<br>4. Check the network list. | No new attendance API calls appear (no `"Is-attendance-record-registered"`, `"Get-work-progress"`, etc.). The page keeps its current state without any loading flash. | - |
| TC-10 | EXCP-RTATT-SYNC-010 | Verify Long background tab triggers one attendance refresh on return | Regression | User is signed in on one session with developer tools **Network** open (filter to **Fetch/XHR**). | 1. Clear the network list.<br>2. Switch away from the tab for at least 30 seconds (leave the browser minimized or on another tab).<br>3. Return to the tab.<br>4. Check the network list. | `"Is-attendance-record-registered" appears **exactly once**. No additional duplicate calls for the same endpoint. | - |

### Non-attendance pages

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-RTATT-SYNC-011 | Verify background attendance refresh does not redirect from requests page | Regression | User is signed in and can open "Subordinate requests".<br>User is on "/admin-leader/list-requests". | 1. Open "/admin-leader/list-requests".<br>2. Keep the page open while an attendance refresh happens in the background, such as returning after more than 30 seconds away or changing attendance in another session.<br>3. Wait a few seconds after the refresh. | 1. The browser remains on "/admin-leader/list-requests".<br>2. The page does not redirect to "Home", "Working time", or "Overtime timer". | - |
