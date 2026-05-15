# Test-on-live Angular environment — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `environments`
- Layer: `frontend`
- Routes: `Any screen that calls the HR API (for example **"/attendance/working-time"**).`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

- **`ng build --configuration testonlive`** bakes **`https://dev.excp.sa:8031`** as the API base instead of production **8043**.
- SPA may be hosted at **`https://dev.excp.sa:8018`** (or another URL); **`appUrl** must match where users open the app.

## Test pages

- Any screen that calls the HR API (for example **"/attendance/working-time"**).

## Test scenarios

- Network requests from the test-on-live bundle use port **8031**.
- Production build still uses port **8043** for the API.

## Test cases

### Build and network

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ENV-TESTONLIVE-001 | Verify testonlive build targets the test-on-live API port | Main | Project **"excp-time"** builds successfully. | 1. Run **"ng build --configuration testonlive"**.<br>2. Open a built JavaScript bundle under **"dist"** and search for the production API host string **"dev.excp.sa:8043"**.<br>3. Search for **"dev.excp.sa:8031"**. | Built output contains **"dev.excp.sa:8031"** for API calls and does not rely on **"dev.excp.sa:8043"** as the configured **"apiUrl"** for this configuration. | Configuration: **"testonlive"** |
| TC-02 | EXCP-ENV-TESTONLIVE-002 | Verify the browser calls the test-on-live API when using the test-on-live bundle | Main | Test-on-live SPA is deployed from the **"testonlive"** build. | 1. Open the app at **"https://dev.excp.sa:8018"** (or your deployed test-on-live URL).<br>2. Open developer tools **"Network"** tab.<br>3. Trigger any API request (for example open attendance working time). | Request URL uses host **"dev.excp.sa"** and port **"8031"** for the API, not **"8043"**. | SPA URL: **"https://dev.excp.sa:8018"** |
| TC-03 | EXCP-ENV-TESTONLIVE-003 | Verify production build still targets the live API port | Regression | Default production pipeline unchanged. | 1. Run **"ng build --configuration production"** (or your CI production step).<br>2. Search built output for **"dev.excp.sa:8043"**. | Production build still references **"https://dev.excp.sa:8043"** as the API base. | Configuration: **"production"** |
