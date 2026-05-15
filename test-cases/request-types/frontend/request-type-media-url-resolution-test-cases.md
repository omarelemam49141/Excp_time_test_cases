# Request Type Media URL Resolution Test Cases

## Metadata

- Project: `excp-time`
- Feature: `request-types`
- Layer: `frontend`
- Routes: `//`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

Validate that request type media (icons and document samples) loads correctly using environment-based URL resolution instead of hardcoded localhost URLs.


## Test pages

- `//`


## Test scenarios

- Relative icon path resolves correctly in live/dev environment.
- Absolute icon URL is used as-is.
- Missing icon path uses fallback icon.
- Relative document sample path resolves correctly.
- Absolute document sample URL is used as-is.
- Leading/trailing slash normalization does not create malformed URLs.


## Test cases

### Main flows

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQTYPE-TYPE-MEDIA-URL-001 | Verify Relative request type icon path | Main | - | 1. Precondition: A request type has `iconUrl = "images/RequestTypes/a.png"`.<br>2. Steps:<br>3. Open `My Requests` page.<br>4. Check request type chips and add-request type selector.<br>5. Image request target starts with `environment.apiDownloadUrl`.<br>6. Icon displays successfully (HTTP 200). | - | - |
| TC-02 | EXCP-REQTYPE-TYPE-MEDIA-URL-002 | Verify Absolute request type icon URL | Main | - | 1. Precondition: A request type has `iconUrl = "https://example.com/icon.png"`.<br>2. Steps:<br>3. Open `My Requests` page.<br>4. Frontend uses URL unchanged.<br>5. Icon renders if remote host is reachable. | - | - |
| TC-03 | EXCP-REQTYPE-TYPE-MEDIA-URL-003 | Verify Missing request type icon | Edge | - | 1. Precondition: A request type has empty/null `iconUrl`.<br>2. Steps:<br>3. Open `My Requests` page.<br>4. Fallback icon `assets/images/icons/notExisted.svg` is shown. | - | - |
| TC-04 | EXCP-REQTYPE-TYPE-MEDIA-URL-004 | Verify Relative document sample path | Main | - | 1. Precondition: A required document has `documentFileSample = "documents/samples/sample.pdf"`.<br>2. Steps:<br>3. Open a generic request dialog for that request type.<br>4. Click/open sample link.<br>5. Sample URL starts with `environment.apiDownloadUrl`.<br>6. File opens/downloads successfully. | - | - |
| TC-05 | EXCP-REQTYPE-TYPE-MEDIA-URL-005 | Verify Absolute document sample URL | Main | - | 1. Precondition: `documentFileSample = "https://example.com/sample.pdf"`.<br>2. Steps:<br>3. Open generic request dialog.<br>4. URL is used unchanged.<br>5. File opens/downloads successfully. | - | - |
| TC-06 | EXCP-REQTYPE-TYPE-MEDIA-URL-006 | Verify Slash normalization | Main | - | 1. Precondition:<br>2. `apiDownloadUrl` may end with or without `/`.<br>3. Relative media path may start with or without `/`.<br>4. Steps:<br>5. Test combinations in dev/local config.<br>6. Resulting URL always contains one slash between host and path.<br>7. No double slash (`//) path breakage after host. | - | - |
