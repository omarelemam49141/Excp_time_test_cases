# Refresh Token - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `authentication`
- Layer: `backend`
- Routes: -
- APIs: `/api/account/login`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/api/account/login`


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Valid refresh token | Main | New access token + new refresh token returned |
- | Reuse old refresh token after rotation | Main | Request rejected as unauthorized |
- | Expired refresh token | Main | Request rejected as unauthorized |
- | Revoked refresh token | Main | Request rejected as unauthorized |
- | Missing or empty refresh token payload | Edge | Unauthorized response |
- | Logout with refresh token | Main | Token is revoked and cannot refresh again |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-AUTH-ANG-REFRESH-TOKEN-001 | Verify Valid refresh token rotation | Main | - | 1. Login via `/api/account/login` and get `refreshToken`.<br>2. Call `/api/account/refresh-token` with that token.<br>3. Verify response is `200`.<br>4. Verify response contains new `token`, new `refreshToken`, and `userId`.<br>5. Verify returned refresh token value differs from the previous one. | - | - |
| TC-02 | EXCP-AUTH-ANG-REFRESH-TOKEN-002 | Verify Old refresh token cannot be reused | Edge | - | 1. Perform Test 1 and keep the old refresh token.<br>2. Call `/api/account/refresh-token` again using the old token.<br>3. Verify response is `401` unauthorized. | - | - |
| TC-03 | EXCP-AUTH-ANG-REFRESH-TOKEN-003 | Verify Expired refresh token | Edge | - | 1. Create/force refresh token older than expiration limit.<br>2. Call `/api/account/refresh-token`.<br>3. Verify response is `401` unauthorized. | - | - |
| TC-04 | EXCP-AUTH-ANG-REFRESH-TOKEN-004 | Verify Revoked refresh token | Edge | - | 1. Revoke a refresh token (`IsRevoked = true`) in storage.<br>2. Call `/api/account/refresh-token` with that token.<br>3. Verify response is `401` unauthorized. | - | - |
| TC-05 | EXCP-AUTH-ANG-REFRESH-TOKEN-005 | Verify Missing/empty payload | Edge | - | 1. Call `/api/account/refresh-token` with empty body, null body, and empty string token.<br>2. Verify unauthorized response for all invalid variants. | - | - |
| TC-06 | EXCP-AUTH-ANG-REFRESH-TOKEN-006 | Verify Logout revocation | Edge | - | 1. Login and obtain refresh token.<br>2. Call `/api/account/logout` with that refresh token.<br>3. Call `/api/account/refresh-token with same token.<br>4. Verify refresh request fails as unauthorized. | - | - |
| TC-07 | EXCP-AUTH-ANG-REFRESH-TOKEN-007 | Verify Refreshed JWT contains claims | Main | - | 1. Login and refresh token successfully.<br>2. Decode refreshed access token.<br>3. Verify required claims still exist (username, email, roles).<br>4. Verify auth-protected endpoint behavior is unchanged after refresh. | - | - |
