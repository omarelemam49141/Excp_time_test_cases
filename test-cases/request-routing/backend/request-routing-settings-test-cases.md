# Request routing — backend test cases

## Metadata
- Project: `excp-time`
- Feature: `request-routing`
- Layer: `backend`
- Routes: `-`
- APIs: `GET /api/request-routing-settings`, `PUT /api/request-routing-settings`, `POST /api/Requests/create`, `POST /api/Requests/get-requests-paged-filtered-list`
- Related code: `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs`
- Related docs: `docs/backend/technical/request-routing-settings.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/RequestRoutingPolicyTests.cs`, `test/Excp.HRSystem.Application.Tests/Requests/SaveOrgStructureTeamRoutingValidationTests.cs`, `test/Excp.HRSystem.Application.Tests/CompanyStructure/OrgStructureTeamChainTests.cs`

## Scope

Global, team, and leader request routing modes; snapshots; final approver; leader inbox without direct-report-only filter.

## Test scenarios

- Default hop 1 is request + notification; hop 2+ is request only.
- Personal override wins over team and global.
- Notify-only hops cannot act.
- Final approver is forced to an actionable hop.
- Pick a specific person is team-only and must sit on the team routing chain after stop-at is applied; configured SpecificUser is forced onto the request as final approver.

## Test cases

### Policy

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-01 | EXCP-REQUEST-ROUTING-001 | Verify default modes | Main | - | 1. Resolve hop 1 and hop 2 with empty personal and team overrides. | 1. Hop 1 is "Both".<br>2. Hop 2 is "RequestOnly". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-02 | EXCP-REQUEST-ROUTING-002 | Verify stop at hop 2 includes hop 1 and 2 only | Main | - | 1. Set upper hops to "2".<br>2. Resolve hop 1, 2, and 3. | 1. Hop 1 uses direct mode.<br>2. Hop 2 uses upper mode.<br>3. Hop 3 is "None". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-11 | EXCP-REQUEST-ROUTING-049 | Verify stop at hop 1 is direct leader only | Main | - | 1. Set upper hops to "1".<br>2. Resolve hop 1 and 2. | 1. Hop 1 uses direct mode.<br>2. Hop 2 is "None". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-12 | EXCP-REQUEST-ROUTING-051 | Verify final approver is still forced when past stop-at | Edge | TopOfChain with stop at 1 | 1. Build resolution for a three-hop chain. | 1. Final user is the last hop on the chain.<br>2. That user remains a final receiver. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-03 | EXCP-REQUEST-ROUTING-003 | Verify personal override wins | Main | - | 1. Set hop 2 personal mode to NotificationOnly. | Hop 2 is "NotificationOnly". | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-04 | EXCP-REQUEST-ROUTING-004 | Verify recommend vs final approve | Main | Pending request with final approver snapshotted | 1. Accept as non-final actionable receiver.<br>2. Accept as final approver. | 1. Request stays Pending; workflow is WaitingForFinalApprover; receiver HasRecommended is true.<br>2. Request becomes Approved. | `src/Excp.HRSystem.Application/Builders/Services/Requests/ChangeRequestStatusBuilder.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingApplyHelper.cs` | - |
| TC-05 | EXCP-REQUEST-ROUTING-005 | Verify top of chain is forced actionable | Main | - | 1. Set FinalApproverMode to TopOfChain.<br>2. Set the last hop personal mode to None. | 1. Final user is the last hop.<br>2. That hop is still a request receiver. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-06 | EXCP-REQUEST-ROUTING-006 | Verify notify-only cannot act | Edge | - | 1. Check IsActionable for NotificationOnly and RequestOnly. | 1. NotificationOnly is not actionable.<br>2. RequestOnly is actionable. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-07 | EXCP-REQUEST-ROUTING-007 | Verify Admin or HR can GET and PUT global settings | Main | Admin or HR token | 1. GET `/api/request-routing-settings`.<br>2. PUT DirectMode Both and UpperMode RequestOnly. | 1. GET returns the singleton.<br>2. PUT returns the saved values. | `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingSettingsAppService.cs` | - |
| TC-08 | EXCP-REQUEST-ROUTING-008 | Verify a picked final person must already be on the issuer chain | Main | - | 1. Build resolution with SpecificUser set to a user not on the chain.<br>2. Build resolution with SpecificUser set to the last hop. | 1. Outsider is not added as a hop.<br>2. FinalApproverUserId is empty for the outsider.<br>3. Last hop is marked final when they are the picked person. | `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-09 | EXCP-REQUEST-ROUTING-009 | Verify PUT global settings rejects Pick a person | Main | Admin or HR token | 1. PUT `/api/request-routing-settings` with FinalApproverMode SpecificUser. | 1. Response is conflict.<br>2. Message says pick a person is only available on a team. | `src/Excp.HRSystem.Application/Services/RequestRouting/RequestRoutingSettingsAppService.cs`, `src/Excp.HRSystem.Domain/RequestRouting/RequestRoutingPolicy.cs` | - |
| TC-10 | EXCP-REQUEST-ROUTING-010 | Verify Save-graph rejects a final person who is not a leader on that team | Edge | Admin or HR token | 1. POST Save-graph with a team FinalApproverMode SpecificUser and FinalApproverUserId of a user who is not a Leader on that team. | 1. Save is refused. | `src/Excp.HRSystem.Application.Contracts/Services/CompanyStructure/FluentValidations/SaveOrgStructureInputValidation.cs` | - |
