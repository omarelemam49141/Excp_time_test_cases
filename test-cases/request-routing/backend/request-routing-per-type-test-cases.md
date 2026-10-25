# Request routing per request type (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `request-routing`
- Layer: `backend`
- Routes: `-`
- APIs: `GET /api/request-routing-type-overrides`, `PUT /api/request-routing-type-overrides`, `DELETE /api/request-routing-type-overrides`
- Related code: `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs`, `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingTypeOverridesAppService.cs`
- Related docs: `docs/backend/technical/request-routing-per-request-type.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestRoutingTypeOverrideMergeTests.cs`, `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/RequestRoutingTypeOverrideSqliteTests.cs`

## Scope

- Routing per request type, globally and per team. Order: team + type, global + type, team default, global default. Field by field.

## Test scenarios

- No override uses the global default
- Each level beats the lower ones
- Fields merge independently
- A global type override does not change other types
- A removed override stops applying

## Test cases

### Wave 1 — Merge order

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-REQ-ROUTE-TYPE-001 | Verify no override uses the global default. | Main | - | 1. No type or team override. | 1. Direct Both, upper RequestOnly, no final approver. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
| TC-02 | EXCP-REQ-ROUTE-TYPE-002 | Verify team + type beats global + type and the team default. | Main | EXCP-REQ-ROUTE-TYPE-001 | 1. Set direct mode on all three levels. | 1. The team + type value wins. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
| TC-03 | EXCP-REQ-ROUTE-TYPE-003 | Verify global + type beats the team default. | Main | EXCP-REQ-ROUTE-TYPE-001 | 1. Set upper mode on global + type and on the team default. | 1. The global + type value wins. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
| TC-04 | EXCP-REQ-ROUTE-TYPE-004 | Verify fields merge independently across levels. | Edge | EXCP-REQ-ROUTE-TYPE-002 | 1. Each level sets a different field. | 1. Every field takes its own highest set level. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
| TC-05 | EXCP-REQ-ROUTE-TYPE-005 | Verify the final approver user travels with the level that set the mode. | Edge | EXCP-REQ-ROUTE-TYPE-002 | 1. Team + type sets a specific user; global + type sets None. | 1. Mode is the specific user and the user is the team one. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |
| TC-06 | EXCP-REQ-ROUTE-TYPE-006 | Verify an empty hops string means all upper hops and is not inherited. | Edge | EXCP-REQ-ROUTE-TYPE-001 | 1. Default has hops "2"; override has "". | 1. Hops stay "" (all upper hops). | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` |

### Wave 2 — Resolver on a database

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-07 | EXCP-REQ-ROUTE-TYPE-010 | Verify a global override of one type does not change other types. | Main | EXCP-REQ-ROUTE-TYPE-001 | 1. Global override of Leave: notification only.<br>2. Resolve for Leave, Advance and no type. | 1. Leave is notification only.<br>2. Advance and no type stay Both. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` |
| TC-08 | EXCP-REQ-ROUTE-TYPE-011 | Verify a global override of a type beats the team default. | Main | EXCP-REQ-ROUTE-TYPE-010 | 1. Team default RequestOnly.<br>2. Add global override of Leave: notification only. | 1. Leave is notification only.<br>2. Other types still follow the team default. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` |
| TC-09 | EXCP-REQ-ROUTE-TYPE-012 | Verify a team override of a type beats the global override of that type. | Main | EXCP-REQ-ROUTE-TYPE-010 | 1. Global override notification only.<br>2. Team override RequestOnly. | 1. The team member's Leave routing is RequestOnly. | `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs` |
| TC-10 | EXCP-REQ-ROUTE-TYPE-013 | Verify a removed override stops applying. | Edge | EXCP-REQ-ROUTE-TYPE-010 | 1. Add an override, then soft delete it. | 1. Routing goes back to the default. | `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingTypeOverridesAppService.cs` |
