# Realtime attendance sync — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `realtime-attendance`
- Layer: `backend`
- Routes: -
- APIs: `The same employee actions the web app uses under paths like `"attendance-record"`, `"attendance-break"`, overtime, and (where your environment allows it) bulk quick entry import or apply.`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

When an employee saves attendance through the normal APIs (start or end work, breaks, overtime, bulk quick entry, and similar), the server should send a **short live message** to every open session for **that same employee** so other tabs, browsers, or installed apps can refresh without waiting for the next slow poll.

This document covers how to check that **successful** saves trigger that message, and **failed** saves do **not** send a new message for that failed try.

## Test pages

- The same employee actions the web app uses under paths like `"attendance-record"`, `"attendance-break"`, overtime, and (where your environment allows it) bulk quick entry import or apply.

## Test scenarios

- After start work or end work succeeds, the employee’s other open sessions receive a live update they can use to refresh today’s state.
- After start break, end break, overtime start/end, and overtime break start/end succeed, the same live update pattern appears with the right kind of change in the message text.
- After a save is rejected (wrong state, validation error, or not allowed), the server returns an error and **does not** send a new live update for that rejected try.
- After a successful bulk quick entry apply or import that changes an employee’s day, that employee’s sessions receive a live update so they can refresh.

## Test cases

### Live message after successful attendance saves

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-RTATT-HRS-SYNC-001 | Verify start work sends a live update to the same employee | Main | One test employee is signed in.<br>The tester can see **live connection messages** for that employee (for example the browser **Network** tab on the live socket, or any small helper the team uses to watch messages). | 1. Sign in as the test employee.<br>2. Keep the live message list visible.<br>3. Call **start work** for today and wait until the server answers **success** (same as the app after tapping start work).<br>4. Look at the newest live messages right after the success answer. | 1. A new message appears with the name `"AttendanceStateChanged"`.<br>2. The message content shows it belongs to the **same** employee who just started work.<br>3. The message content clearly matches **starting work**, not ending work. | Employee sign-in: use your test account |
| TC-02 | EXCP-RTATT-HRS-SYNC-002 | Verify end work sends a live update to the same employee | Main | Same setup as TC-01 for watching live messages.<br>The employee is **currently working** (start work already succeeded). | 1. Call **end work** for today and wait until the server answers **success**.<br>2. Look at the newest live messages right after the success answer. | 1. A new message appears with the name `"AttendanceStateChanged"`.<br>2. The message content shows it belongs to the **same** employee.<br>3. The message content clearly matches **ending work**, not starting work. | - |
| TC-03 | EXCP-RTATT-HRS-SYNC-003 | Verify start break and end break each send a live update | Edge | Same live-message setup as TC-01.<br>The employee is **working** (not already on a break). | 1. Call **start break** and wait for **success**.<br>2. Check live messages.<br>3. Call **end break** and wait for **success**.<br>4. Check live messages again. | 1. After step 1, a new `"AttendanceStateChanged"` message appears and reads like a **break started** change for that employee.<br>2. After step 3, another new `"AttendanceStateChanged"` message appears and reads like a **break ended** change for that employee. | - |
| TC-04 | EXCP-RTATT-HRS-SYNC-004 | Verify overtime and overtime break steps send live updates | Edge | Same live-message setup as TC-01.<br>Overtime is **allowed** for this employee under your normal rules.<br>The employee is in a state where overtime actions are permitted. | 1. Complete **request overtime** or **start overtime** (whichever your product uses first) and wait for **success**.<br>2. Check live messages.<br>3. If your product uses an overtime break, call **start overtime break**, wait for **success**, then **end overtime break**, wait for **success**, and check messages after each success.<br>4. Call **end overtime** and wait for **success**.<br>5. Check live messages after the last success. | 1. After each successful step above, a new `"AttendanceStateChanged"` message appears for that employee.<br>2. Each message’s wording matches the step you just finished (overtime started, break started, break ended, overtime ended), so a second session would know what to refresh. | - |
| TC-05 | EXCP-RTATT-HRS-SYNC-005 | Verify a failed save does not send a new live update for that try | Edge | Same live-message setup as TC-01.<br>The tester knows one call that the server will **reject** (for example end work when the employee is not in a state that allows it). | 1. Note the time or scroll position of the live message list so you can spot **new** messages.<br>2. Send the **bad** request and confirm the server returns an **error** (not success).<br>3. Look for any **new** `"AttendanceStateChanged"` message tied exactly to that failed try. | 1. The bad request returns an error to the client (for example `"400"` or your usual error shape).<br>2. **No** new `"AttendanceStateChanged"` message appears for that failed try (older messages from earlier successful tries may still be visible — that is fine). | - |
| TC-06 | EXCP-RTATT-HRS-SYNC-006 | Verify bulk quick entry success sends a live update to the same employee | Edge | Your test environment allows **bulk quick entry** import or apply for an employee.<br>Same live-message setup as TC-01 for that employee. | 1. Run a **successful** bulk apply or import that clearly changes that employee’s attendance for a calendar day you can name (for example `"2026-05-06"`).<br>2. Watch live messages for that employee during and right after the success answer. | 1. The bulk action finishes with **success** from the server.<br>2. A new `"AttendanceStateChanged"` message appears for that employee.<br>3. The message content reads like a **bulk** or **import / correction** style change (so their other sessions know to refresh the day). | Calendar day: `"2026-05-06" (or any day you use in test) |
