# Refresh Token - Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `authentication`
- Layer: `frontend`
- Routes: `/auth/login`, `Any authenticated page (e.g. `/attendance`, `/admin`)`
- APIs: -
- Related code: `src/app/core/interceptors/auth.interceptor.ts`, `src/app/auth/services/auth.service.ts`
- Related docs: `docs/frontend/technical/refresh-token-auth-flow.md`

## Scope

- Token refresh interceptor behavior (silent refresh, retry, queue, failure).
- Startup initialization when returning to the app after idle.
- Loader visibility during expired-session recovery.


## Test pages

- `/auth/login`
- Any authenticated page (e.g. `/attendance`, `/admin)


## Test scenarios

- Access token expires during normal API call — interceptor refreshes and retries.
- Refresh token also expired — user is logged out and redirected to login without hanging loader.
- Multiple concurrent 401 responses — single refresh call; all pending requests resume or terminate.
- App reopened after long idle — login page loads without infinite loader.
- Missing refresh token in storage — no refresh attempt; immediate logout.
- 401 from refresh/logout endpoints — no refresh recursion loop.
- Browser or server leaves an auth or attendance-registration call pending (first open, cold connection) — requests time out so the hourglass clears instead of staying forever.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-AUTH-REFRESH-TOKEN-001 | Verify silent refresh retries the original request | Main | User is logged in | 1. Keep app open until access token expires (about 15 minutes).<br>2. Click any page that calls a protected API. | 1. No logout occurs.<br>2. Page data loads normally.<br>3. New tokens appear in browser local storage. | - |
| TC-02 | EXCP-AUTH-REFRESH-TOKEN-002 | Verify logout when refresh token is invalid | Main | User is logged in, refresh token expired or revoked on server | 1. Wait for access token to expire.<br>2. Click any page that calls a protected API. | 1. App redirects to "/auth/login".<br>2. Local storage tokens are cleared.<br>3. No infinite loader is shown. | - |
| TC-03 | EXCP-AUTH-REFRESH-TOKEN-003 | Verify concurrent expired calls all resolve | Edge | User is logged in, access token expired, refresh token still valid | 1. Open a page that fires 2+ API calls simultaneously (e.g. dashboard). | 1. Only one call to "/api/account/refresh-token" appears in Network tab.<br>2. All failed requests are retried with the new token.<br>3. Page loads successfully. | - |
| TC-04 | EXCP-AUTH-REFRESH-TOKEN-004 | Verify missing refresh token triggers immediate logout | Edge | User is logged in | 1. Open browser DevTools, delete "refreshToken" from local storage.<br>2. Wait for access token to expire or trigger a protected call. | 1. App redirects to "/auth/login" immediately.<br>2. No refresh request appears in Network tab. | - |
| TC-05 | EXCP-AUTH-REFRESH-TOKEN-005 | Verify no refresh loop on auth endpoints | Edge | - | 1. Simulate a "401" response on "/api/account/refresh-token" (e.g. via DevTools network override).<br>2. Trigger any protected API call. | 1. App calls refresh endpoint once only.<br>2. App redirects to "/auth/login".<br>3. No recursive refresh calls appear. | - |
| TC-06 | EXCP-AUTH-REFRESH-TOKEN-006 | Verify token replacement after successful refresh | Main | User is logged in | 1. Note current "authToken" and "refreshToken" values in local storage.<br>2. Wait for access token to expire and trigger a refresh. | 1. Both "authToken" and "refreshToken" in local storage have new values.<br>2. Old values are no longer present. | - |

### Loader deadlock prevention (idle session recovery)

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-AUTH-REFRESH-TOKEN-007 | Verify no infinite loader after long idle with expired tokens | Main | User was logged in, then left tab open for hours until both tokens expired | 1. Return to the browser tab (do not refresh).<br>2. Observe the login page. | 1. Hourglass loader hides within a few seconds.<br>2. Login form is fully interactive.<br>3. No pending network requests stuck in "pending" state. | - |
| TC-08 | EXCP-AUTH-REFRESH-TOKEN-008 | Verify no premature API calls before refresh completes on startup | Edge | User has stored credentials but access token is expired | 1. Close the tab and reopen the app URL.<br>2. Watch the Network tab during initial load. | 1. No profile or notification API calls fire before "/api/account/refresh-token" completes.<br>2. If refresh succeeds, profile calls fire after with the new token.<br>3. If refresh fails, no profile calls fire at all. | - |
| TC-09 | EXCP-AUTH-REFRESH-TOKEN-009 | Verify queued requests terminate when refresh fails | Edge | User is logged in, both tokens expired | 1. Open a page that fires multiple API calls at once.<br>2. All calls return "401".<br>3. Refresh endpoint also returns "401". | 1. All pending requests complete (none stuck in "pending").<br>2. Loader disappears.<br>3. App redirects to "/auth/login". | - |
| TC-10 | EXCP-AUTH-REFRESH-TOKEN-010 | Verify page refresh recovers from stuck state | Regression | User sees the infinite loader (historical bug) | 1. Press F5 or click browser refresh. | 1. App reloads cleanly.<br>2. Login page shows without loader.<br>3. User can log in normally. | - |
| TC-11 | EXCP-AUTH-REFRESH-TOKEN-011 | Verify login succeeds when attendance status request never finishes | Edge | Valid account.<br>DevTools **Network** open | 1. Use DevTools to block or stall **only** the **Is-attendance-record-registered** request so it stays **pending** (do **not** block login).<br>2. Submit **"تسجيل الدخول"** with valid credentials.<br>3. Wait up to 30 seconds. | 1. Hourglass hides before or when about **25 seconds** pass.<br>2. App navigates to **Home** (or shows Home content).<br>3. No endless hourglass over **"تسجيل الدخول"**. | Test data: Use credentials that normally reach Home after login. |
| TC-12 | EXCP-AUTH-REFRESH-TOKEN-012 | Verify stalled silent refresh ends without endless hourglass | Edge | Stored session with expired access token and valid refresh token still on device | 1. Open DevTools **Network**.<br>2. Stall **only** **"/api/account/refresh-token"** so it stays **pending**.<br>3. Open the app root URL so guards run.<br>4. Wait up to 30 seconds. | 1. Hourglass hides before or when about **25 seconds** pass.<br>2. App reaches **"/auth/login"** or signed-out Home behavior.<br>3. No request stays **pending** forever without user action. | - |
