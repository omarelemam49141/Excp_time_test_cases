# Teams And Request Authorization — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `requests`
- Layer: `backend`
- Routes: -
- APIs: `POST /api/Requests/get-requests-paged-filtered-list`, `GET /api/Requests/getById`, `POST /api/Requests/change-reqeust-status`
- Related code: `src/Excp.HRSystem.Application/Services/Requests/RequestReadAccess.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestDecisionGuards.cs`, `src/Excp.HRSystem.Application/Services/Requests/RequestRoutingResolver.cs`
- Related docs: `docs/backend/technical/team-membership-authorization-review.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Requests/TeamMembershipAuthorizationInteractionTests.cs`

## Scope

This document records how teams relate to who can read and approve a request today. Being the leader of a team, or of a team above it, gives no right on its members' requests. Only the person who submitted a request and the people listed as receivers on it have rights. A team's own routing settings and a person's team decide who is listed for that person's next requests.

These cases describe the current behavior so that a later change to team management cannot widen request rights by accident.

## Test pages

- `/admin-leader/list-requests`
- `/my-requests`

## Test scenarios

- Leading a team, or a team above it, gives no right on its members' requests.
- A team setting can only choose among the leaders above the person, it cannot add an approver.
- Moving a person to another team can change who approves their next request.

## Test cases

### Rights follow the request

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REQ-HRS-TEAMAUTH-001 | Verify leading a team or a team above it gives no right on a member's request | Regression | Employee E belongs to team "Sales North", which is below team "Sales". Leader A leads "Sales" but is not listed on E's request. Leader L is E's direct leader. | 1. Sign in as leader A and open E's request with `GET /api/Requests/getById`.<br>2. As leader A send the approve and refuse APIs for it.<br>3. Open the "Requests" page as leader A.<br>4. Sign in as leader L and repeat steps 1 and 2. | 1. For leader A the request is forbidden to open, the approve and refuse calls are refused, and E's request is not in the list.<br>2. For leader L the request opens and can be decided. | Teams: "Sales", "Sales North" |

### Team settings

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-REQ-HRS-TEAMAUTH-002 | Verify a team setting picks the final approver and moving a person to another team changes who approves | Regression | Employee E reports to leader L1, who reports to leader L2. Team "Plain" has no routing setting. Team "Upper" names L2 as the final approver. User U is not above E. | 1. Put E in "Plain" and submit a request. Check who can approve it.<br>2. Put E in "Upper" and submit a request. Check who can approve it.<br>3. Set U as the final approver of "Upper" and submit another request from E.<br>4. Make U the leader badge holder of E's team and submit another request. | 1. In step 1 leader L1 can approve.<br>2. In step 2 only leader L2 can approve and leader L1 can only refuse.<br>3. In step 3 U is kept as the final approver and added as the last approver, so U can approve and the leaders on the chain can only recommend or refuse.<br>4. In step 4 U is not listed as a receiver. | Teams: "Plain", "Upper" |
