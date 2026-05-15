# TestOnLive environment deployment — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `environments`
- Layer: `backend`
- Routes: -
- APIs: `HR API **8031** (TestOnLive) and **8043** (production).`, `EXCP Angular on **8018** when used as the test-on-live SPA host.`
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- TestOnLive HR API is served at **`https://dev.excp.sa:8031`** (or matching IIS site) with **`HRBasicTest`** and non-production WhatsApp settings.
- EXCP Angular test-on-live UI is typically hosted at **`https://dev.excp.sa:8018`** and must call the **8031** API, not production **8043**.
- Production API **`https://dev.excp.sa:8043`** remains on **`HRBasic`**.

## Test pages

- HR API **8031** (TestOnLive) and **8043** (production).
- EXCP Angular on **8018** when used as the test-on-live SPA host.

## Test scenarios

- TestOnLive API host loads **`TestOnLive`** configuration after publish.
- Database traffic for the TestOnLive API targets **`HRBasicTest`** only.
- WhatsApp attendance summaries from TestOnLive go to the non-production channel.
- **8043** production API continues to use **`HRBasic** and production messaging.

## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ENV-HRS-TESTONLIVE-001 | Verify the test-on-live API site loads TestOnLive settings after publish | Main | Test-on-live API site physical folder contains published build including **"appsettings.TestOnLive.json"** file. | 1. Open the published folder for the TestOnLive API site (for example the app behind **"https://dev.excp.sa:8031"**).<br>2. Confirm **"appsettings.TestOnLive.json"** is present next to the main application files. | File **"appsettings.TestOnLive.json"** is present. | - |
| TC-02 | EXCP-ENV-HRS-TESTONLIVE-002 | Verify the test-on-live IIS site uses the TestOnLive environment name | Main | Administrator access to IIS or **"web.config"** for the TestOnLive API site. | 1. Open IIS configuration for the TestOnLive API site (for example **"Excp-HR-V01 Test"**), or open **"web.config"** in its app folder.<br>2. Find **"ASPNETCORE_ENVIRONMENT"**. | Value is **"TestOnLive"** (or publish profile sets **"EnvironmentName"** so **"web.config"** contains **"TestOnLive"** after deploy). | - |
| TC-03 | EXCP-ENV-HRS-TESTONLIVE-003 | Verify DbMigrator can target the test database when TestOnLive is selected | Main | Server or build machine can run **"Excp.HRSystem.DbMigrator"** with environment **"TestOnLive"**. | 1. Set host environment to **"TestOnLive"**.<br>2. Run **"Excp.HRSystem.DbMigrator"** against the server.<br>3. Confirm connection uses the test database name from configuration. | Migration completes without connecting to production **"HRBasic"** catalog for this run. | Environment: **"TestOnLive"** |
| TC-04 | EXCP-ENV-HRS-TESTONLIVE-004 | Verify production site is not switched to TestOnLive by default | Regression | Production site **"Excp-HR-V01"** on **8043** is deployed from the usual production process. | 1. Check **"ASPNETCORE_ENVIRONMENT"** (or **"web.config"**) for **8043** app folder.<br>2. Confirm it is not **"TestOnLive"** unless intentionally changed. | Production remains **"Production"** (or your existing production value), not **"TestOnLive"**. | - |
| TC-07 | EXCP-ENV-HRS-TESTONLIVE-005 | Verify the test-on-live API allows browser requests from the test-on-live SPA origin | Main | Test-on-live API is deployed with **"appsettings.TestOnLive.json"** including **"Cors:AllowedOrigins"** for the SPA URL. | 1. Open the SPA (for example **"https://dev.excp.sa:8018"**).<br>2. Open developer tools **"Network"**.<br>3. Attempt sign-in or any API call to **"https://dev.excp.sa:8031"**. | No **"CORS error"** on the request; response includes **"Access-Control-Allow-Origin"** matching the SPA origin. | SPA: **"https://dev.excp.sa:8018"**<br>API: **"https://dev.excp.sa:8031"** |

### Edge and messaging

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-ENV-HRS-TESTONLIVE-006 | Verify attendance-related message from test-on-live does not use the production-only channel | Edge | You can see which group or channel receives the non-production messages. | 1. Open the test-on-live site (for example **"https://dev.excp.sa:8018"**).<br>2. Sign in.<br>3. Perform one action that sends an attendance summary message (for example start or end work, per your workflow).<br>4. Observe where the message appears. | Message appears only in the non-production channel configured for TestOnLive, not in the live production-only channel. | SPA: **"https://dev.excp.sa:8018"**<br>API: **"https://dev.excp.sa:8031"** |
| TC-06 | EXCP-ENV-HRS-TESTONLIVE-007 | Verify production URL still behaves as production after a test-on-live deploy | Regression | Two separate IIS sites and app folders as in production. | 1. Sign in on a build that uses the production API (**"https://dev.excp.sa:8043"**).<br>2. Repeat the same messaging-triggering action as in TC-05. | Message behavior matches production expectations (production channel only). | API base: **"https://dev.excp.sa:8043"** |
