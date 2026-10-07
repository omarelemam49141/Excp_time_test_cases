# Request routing — backend test cases

## Metadata
- Project: `excp-time`
- Feature: `request-routing`
- Layer: `backend`
- Routes: `-`
- APIs: `GET /api/request-routing-settings`, `PUT /api/request-routing-settings`, `POST /api/Requests/create`, `POST /api/Requests/get-requests-paged-filtered-list`
- Related code: `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`
- Related docs: `docs/backend/technical/request-routing-settings.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestRoutingPolicyTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/SaveOrgStructureTeamRoutingValidationTests.cs`

## Scope

Global, team, and leader request routing modes; snapshots; final approver; leader inbox without direct-report-only filter.

## Test scenarios

- Default hop 1 is request + notification; hop 2+ is request only.
- Personal override wins over team and global.
- Notify-only hops cannot act.
- Final approver is forced to an actionable hop.
- Pick a specific person is team-only and must already sit on that team's leader chain.

## Test cases

### Policy

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQUEST-ROUTING-001 | Verify default modes | Main | - | 1. Resolve hop 1 and hop 2 with empty personal and team overrides. | 1. Hop 1 is "Both".<br>2. Hop 2 is "RequestOnly". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-02 | EXCP-REQUEST-ROUTING-002 | Verify unselected upper hops are skipped | Edge | - | 1. Set upper hops to "2" only.<br>2. Resolve hop 3. | Hop 3 is "None". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-03 | EXCP-REQUEST-ROUTING-003 | Verify personal override wins | Main | - | 1. Set hop 2 personal mode to NotificationOnly. | Hop 2 is "NotificationOnly". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-04 | EXCP-REQUEST-ROUTING-004 | Verify first-wins unless final | Main | - | 1. Approve as an actionable receiver with no final user.<br>2. Approve as a different user when a final user is set. | 1. First call is allowed.<br>2. Second call is refused. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-05 | EXCP-REQUEST-ROUTING-005 | Verify top of chain is forced actionable | Main | - | 1. Set FinalApproverMode to TopOfChain.<br>2. Set the last hop personal mode to None. | 1. Final user is the last hop.<br>2. That hop is still a request receiver. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-06 | EXCP-REQUEST-ROUTING-006 | Verify notify-only cannot act | Edge | - | 1. Check IsActionable for NotificationOnly and RequestOnly. | 1. NotificationOnly is not actionable.<br>2. RequestOnly is actionable. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-07 | EXCP-REQUEST-ROUTING-007 | Verify Admin or HR can GET and PUT global settings | Main | Admin or HR token | 1. GET `/api/request-routing-settings`.<br>2. PUT DirectMode Both and UpperMode RequestOnly. | 1. GET returns the singleton.<br>2. PUT returns the saved values. | `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingSettingsAppService.cs` | - |
| TC-08 | EXCP-REQUEST-ROUTING-008 | Verify a picked final person must already be on the issuer chain | Main | - | 1. Build resolution with SpecificUser set to a user not on the chain.<br>2. Build resolution with SpecificUser set to the last hop. | 1. Outsider is not added as a hop.<br>2. FinalApproverUserId is empty for the outsider.<br>3. Last hop is marked final when they are the picked person. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-09 | EXCP-REQUEST-ROUTING-009 | Verify PUT global settings rejects Pick a person | Main | Admin or HR token | 1. PUT `/api/request-routing-settings` with FinalApproverMode SpecificUser. | 1. Response is conflict.<br>2. Message says pick a person is only available on a team. | `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingSettingsAppService.cs`, `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-10 | EXCP-REQUEST-ROUTING-010 | Verify Save-graph rejects a final person who is not a leader on that team | Edge | Admin or HR token | 1. POST Save-graph with a team FinalApproverMode SpecificUser and FinalApproverUserId of a user who is not a Leader on that team. | 1. Save is refused. | `src/Excp.HRSystem.Application.Contracts/Services/CompanyStructure/FluentValidations/SaveOrgStructureInputValidation.cs` | - |
