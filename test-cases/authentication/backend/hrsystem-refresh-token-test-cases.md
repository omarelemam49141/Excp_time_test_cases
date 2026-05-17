# Refresh Token - Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `authentication`
- Layer: `backend`
- Routes: -
- APIs: `/api/account/login`
- Related code: `src/Excp.HRSystem.Application/Services/Users/RefreshTokens/Services/RefreshTokenService.cs`, `src/Excp.HRSystem.EntityFrameworkCore/Users/RefreshTokens/Repositories/RefreshTokenRepository.cs`, `src/Excp.HRSystem.Domain/Entities/Users/RefreshTokens/RefreshToken.cs`
- Related docs: `docs/backend/technical/refresh-token-auth-flow.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/api/account/login`


## Test scenarios

- | Case | Type | Expected |
- |---|---|---|
- | Valid refresh token | Main | New access token + new refresh token returned |
- | Reuse old refresh token after rotation | Main | Unauthorized |
- | Expired refresh token | Main | Unauthorized |
- | Revoked refresh token | Main | Unauthorized |
- | Missing/empty refresh token input | Edge | Unauthorized |
- | Logout revokes refresh token | Main | Token becomes unusable for refresh |


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-AUTH-HRS-REFRESH-TOKEN-001 | Verify Happy path refresh | Main | - | 1. Login through `/api/account/login`.<br>2. Use received `refreshToken` in `/api/account/refresh-token`.<br>3. Verify `200 OK`.<br>4. Verify response includes `token`, `refreshToken`, and `userId`.<br>5. Verify returned refresh token value is new. | - | - |
| TC-02 | EXCP-AUTH-HRS-REFRESH-TOKEN-002 | Verify Rotation replay protection | Edge | - | 1. Complete Test 1 and save old refresh token.<br>2. Call `/api/account/refresh-token` with old token.<br>3. Verify `401 Unauthorized`. | - | - |
| TC-03 | EXCP-AUTH-HRS-REFRESH-TOKEN-003 | Verify Expired token rejection | Edge | - | 1. Set token expiration in past (or wait until expired in test setup).<br>2. Call `/api/account/refresh-token`.<br>3. Verify `401 Unauthorized` and expired-token message. | - | - |
| TC-04 | EXCP-AUTH-HRS-REFRESH-TOKEN-004 | Verify Revoked token rejection | Edge | - | 1. Mark token as revoked in DB.<br>2. Call `/api/account/refresh-token`.<br>3. Verify `401 Unauthorized`. | - | - |
| TC-05 | EXCP-AUTH-HRS-REFRESH-TOKEN-005 | Verify Invalid payload variants | Edge | - | 1. Send null body.<br>2. Send body with empty `refreshToken`.<br>3. Send body with whitespace token.<br>4. Verify unauthorized behavior is consistent. | - | - |
| TC-06 | EXCP-AUTH-HRS-REFRESH-TOKEN-006 | Verify Logout revocation flow | Edge | - | 1. Login and capture refresh token.<br>2. Call `/api/account/logout` with token.<br>3. Attempt `/api/account/refresh-token` with same token.<br>4. Verify refresh fails (`401). | - | - |
| TC-07 | EXCP-AUTH-HRS-REFRESH-TOKEN-007 | Verify Claims preserved after refresh | Main | - | 1. Refresh token successfully.<br>2. Decode new access token.<br>3. Verify claims still include app identity and roles required by authorization. | - | - |
