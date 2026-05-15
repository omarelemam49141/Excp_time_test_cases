# HTTP error handling (global SweetAlert) — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `platform`
- Layer: `frontend`
- Routes: `/home`, `Any authenticated page that loads several APIs on first paint (for example `/home` after login)`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

Global HTTP error interceptor behavior for **browser transport failures** (when the request does not receive an HTTP status from the API, often shown as **failed** in browser tools with a **net::ERR_** style reason), including a single user-facing **Fail** dialog on pages such as **Home** when many calls fail together, without showing Angular’s internal **Http failure response for** line.

## Test pages

- `/home`
- Any authenticated page that loads several APIs on first paint (for example `/home` after login)

## Test scenarios

- Verify when the device cannot reach the API, the user sees one **Fail** dialog with plain language, not a technical URL line, and is not forced through many identical modals for each failed call.

## Test cases

### Network unreachable

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-PLATFORM-HTTP-ERROR-001 | Verify the app shows one friendly **Fail** dialog when the API cannot be reached | Main | User is logged in; UI language is English; browser **Offline** mode is available in tools (or the API host is stopped). | 1. Open `/home`.<br>2. Turn **Offline** on (or ensure the API host is unreachable).<br>3. Reload the page or navigate away and back to `/home` so several data requests run.<br>4. Wait until loading indicators stop or the page settles. | 1. At most one **Fail** modal appears without opening another on top before you dismiss the first.<br>2. The modal title reads `"Fail"`.<br>3. The modal body explains that the app **cannot reach the server** and suggests checking the network or that the service is running (wording may match the English product copy exactly).<br>4. The modal body does not show a line that starts with `"Http failure response for". | - |
