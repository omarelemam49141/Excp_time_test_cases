# Start/end work — platform source marker (frontend)

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`, `/attendance/working-time`
- APIs: `POST attendance-record/Start-work`, `POST attendance-record/End-work`
- Related code: `src/app/core/services/attendance.service.ts`
- Related docs: -

## Scope

- Every start-work and end-work request from the web app marks itself as coming from the web, so the server can record where each start and end happened and the users list can show the right platform next to today's times.
- Covers the request marker itself and the end-to-end result a tester can see on the users list.

## Test pages

- `/home` (start and end work actions)
- `/attendance/working-time`
- `/admin-leader/list-users` (result check)

## Test scenarios

- Start work and end work requests carry the web marker (`Source: 2`) in the browser's network view.
- After an employee starts and ends work from the web, the users list shows "Web" next to both times.

## Test cases

### Request marker

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ATT-SOURCE-001 | Verify start work is marked as a web action | Main | Signed in as an employee who has not started today. | 1. Open developer tools (Network tab, filter to Fetch/XHR).<br>2. Start work from the home action.<br>3. Open the `"Start-work"` request and inspect its request headers. | The `"Start-work"` request includes the header `"Source"` with the value `"2"`. | - |
| TC-02 | EXCP-ATT-SOURCE-002 | Verify end work is marked as a web action | Main | Signed in as an employee who is currently working. | 1. Open developer tools (Network tab, filter to Fetch/XHR).<br>2. End work from the working-time action.<br>3. Open the `"End-work"` request and inspect its request headers. | The `"End-work"` request includes the header `"Source"` with the value `"2"`. | - |

### End-to-end result

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-ATT-SOURCE-003 | Verify a fully worked day shows "Web" on both start and end | Main | An employee completes start work and end work today, both from the web browser. | 1. As that employee, start work and then end work from the browser.<br>2. Sign in as an admin and open /admin-leader/list-users.<br>3. Find that employee on "Today & attendance". | 1. The Start cell shows the start time with the chip "Web".<br>2. The End cell shows the end time with the chip "Web". | - |
