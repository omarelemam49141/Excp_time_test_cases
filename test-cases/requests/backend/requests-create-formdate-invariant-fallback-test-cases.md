# Requests Create Form-Date Invariant Fallback Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `(Add the primary screen route or API path here.)
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestsService.cs`, `src/Excp.HRSystem.Application/Builders/Services/Requests/CreateRequestBuilder.cs`
- Related docs: `docs/backend/technical/requests-create-formdate-invariant-fallback.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- (Add the primary screen route or API path here.)


## Test scenarios

- Multipart leave create request with ISO date-only strings binds correctly in production-like culture.
- Update request path uses the same fallback logic.
- Invalid or missing date values continue returning validation/conflict responses.
- Existing successful local behavior is unchanged.


## Test cases

### General

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-CREATE-FORMDATE-001 | Verify Multipart leave create request with ISO date-only strings binds correctly in production-like culture. | Main | - | 1. Multipart leave create request with ISO date-only strings binds correctly in production-like culture. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-02 | EXCP-REQ-HRS-CREATE-FORMDATE-002 | Verify Update request path uses the same fallback logic. | Main | - | 1. Update request path uses the same fallback logic. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-03 | EXCP-REQ-HRS-CREATE-FORMDATE-003 | Verify Invalid or missing date values continue returning validation/conflict responses. | Edge | - | 1. Invalid or missing date values continue returning validation/conflict responses. | The result matches the scenario description when you follow the actions in the product. | - |
| TC-04 | EXCP-REQ-HRS-CREATE-FORMDATE-004 | Verify Existing successful local behavior is unchanged. | Main | - | 1. Existing successful local behavior is unchanged. | The result matches the scenario description when you follow the actions in the product. | - |
