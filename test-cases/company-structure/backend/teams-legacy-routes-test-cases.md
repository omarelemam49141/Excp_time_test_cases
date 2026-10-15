# Teams Legacy Routes — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: -
- APIs: `PUT /api/Teams/update`, `POST /api/Teams/add-team-member`, `POST /api/Teams/remove-team-member`
- Related code: `src/Excp.HRSystem.Application/Services/Teams/TeamService.cs`, `src/Excp.HRSystem.Application/Services/Teams/TeamManagementRules.cs`, `src/Excp.HRSystem.Application/Services/Teams/TeamManagementAccessService.cs`
- Related docs: `docs/backend/technical/teams-legacy-routes-access.md`
- Automation: `test/Excp.HRSystem.Application.Tests/Teams/TeamManagementRulesTests.cs`, `test/Excp.HRSystem.Application.Tests/Teams/TeamLegacyRoutesServiceTests.cs`

## Scope

This document covers who can change a team or its members through the older team routes. An administrator keeps full access. A leader can change the team they lead and, where the leader rights allow it, the teams below it. A leader cannot touch another leader's branch, cannot change where a team sits in the tree, and cannot change administrators or HR members. Employees and HR cannot use these routes.

Being allowed to manage a team gives no right to read or approve the requests of its members. Those rights come only from the people listed on each request.

The automated tests run the real team service and the real access checks with the data layer replaced by test doubles. The steps below are the end-to-end API check for the same rules and have not been run yet.

## Test pages

- `/admin/company-structure`

## Test scenarios

- A leader updates their own team and the teams below it, but only with the right to do so.
- A leader cannot reach another leader's branch.
- A leader cannot change the team tree; nobody can create a loop in it.
- A leader adds and removes members only inside their own area.
- Administrators keep full access; employees and HR are refused.
- Managing a team does not open the requests of its members.

## Test cases

### Updating a team

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-TEAMS-LEGACY-001 | Verify a leader can update the team they lead and, with the child-team right, the teams below it | Main | Leader A leads team "Sales" with child team "Sales North". The leader may rename teams. | 1. Sign in as leader A.<br>2. Send `PUT /api/Teams/update` for "Sales" with a new name.<br>3. Send it for "Sales North" with a new name.<br>4. Switch the child-team right off and send step 3 again. | 1. Steps 2 and 3 succeed.<br>2. Step 4 is refused with `"You can only manage the teams you lead and, where allowed, the teams below them."`. | Teams: "Sales", "Sales North" |
| TC-02 | EXCP-TEAMS-LEGACY-002 | Verify a leader cannot update another leader's branch | Regression | Leader A leads "Sales". Another leader leads "Support" with child team "Support North". | 1. Sign in as leader A.<br>2. Send `PUT /api/Teams/update` for "Support" and for "Support North".<br>3. Sign in as a person who leads no team and send it for "Sales". | 1. Every call is refused with `"You can only manage the teams you lead and, where allowed, the teams below them."`.<br>2. No team changes. | Teams: "Support", "Support North" |
| TC-03 | EXCP-TEAMS-LEGACY-003 | Verify a leader cannot change where a team sits in the tree, and an administrator can | Regression | Same as TC-02. | 1. Sign in as leader A.<br>2. Send `PUT /api/Teams/update` moving "Sales" under "Support".<br>3. Send it moving "Sales North" to the top level.<br>4. Send it changing the type of "Sales North".<br>5. Sign in as an administrator and move "Support North" under "Sales". | 1. Steps 2 to 4 are refused with `"Only an administrator can change where a team sits in the hierarchy."` and nothing changes.<br>2. Step 5 succeeds. | Teams: "Sales", "Sales North", "Support North" |
| TC-04 | EXCP-TEAMS-LEGACY-004 | Verify a team can never be placed below itself and a loop in the data does not break the company structure | Regression | An administrator is signed in. Team "Sales" has child "Sales North" and grandchild "Sales North East". | 1. Send `PUT /api/Teams/update` making "Sales" its own parent.<br>2. Make "Sales" a child of "Sales North East".<br>3. Open the company structure as leader A. | 1. Steps 1 and 2 are refused with `"This change would put the team below itself. Teams cannot form a loop."`.<br>2. The company structure opens normally. | Teams: "Sales", "Sales North", "Sales North East" |
| TC-05 | EXCP-TEAMS-LEGACY-006 | Verify the update route applies the team scope for a leader | Regression | Leader A leads "Sales" and may rename teams. | 1. Sign in as leader A and send `PUT /api/Teams/update` for a team in another branch.<br>2. Send it for "Sales" and for "Sales North" with a new name. | 1. Step 1 returns a forbidden response and nothing changes.<br>2. Step 2 succeeds for both teams. | Teams: "Sales", "Sales North" |
| TC-06 | EXCP-TEAMS-LEGACY-007 | Verify the update route refuses a hierarchy change from a leader | Regression | Same as TC-06. | 1. Sign in as leader A.<br>2. Send `PUT /api/Teams/update` moving "Sales" under another branch, moving "Sales North" to the top level, and changing the type of "Sales North". | 1. Every call is refused with `"Only an administrator can change where a team sits in the hierarchy."`.<br>2. The team tree is unchanged. | Teams: "Sales", "Sales North" |
| TC-07 | EXCP-TEAMS-LEGACY-008 | Verify the update route rejects a loop for an administrator and keeps valid moves | Regression | An administrator is signed in. | 1. Send `PUT /api/Teams/update` making "Sales" a child of its own child "Sales North".<br>2. Send a valid move of "Support North" under "Sales". | 1. Step 1 returns a conflict response with `"This change would put the team below itself. Teams cannot form a loop."` and nothing changes.<br>2. Step 2 succeeds. | Teams: "Sales", "Sales North", "Support North" |

### Members and roles

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-TEAMS-LEGACY-005 | Verify the membership rules for a leader | Regression | Leader A leads "Sales" with child team "Sales North". The leader may add and remove members. Employee E is in no team. Employee F is in "Support North" of another leader. Administrator Z and a leader badge holder Y exist. | 1. Sign in as leader A.<br>2. Add E to "Sales" and add a person from "Sales North" to "Sales".<br>3. Add F to "Sales".<br>4. Add E to "Support".<br>5. Add administrator Z to "Sales".<br>6. Remove the leader of "Sales" from "Sales" without the remove-leader right.<br>7. Add leader Y to "Sales North" without the add-leader right. | 1. Step 2 succeeds.<br>2. Step 3 is refused with `"You can only add people who are not in a team yet or who are in teams you manage."`.<br>3. Step 4 is refused with `"You can only manage the teams you lead and, where allowed, the teams below them."`.<br>4. Step 5 is refused with `"Administrators and HR members can only be changed by an administrator."`.<br>5. Steps 6 and 7 are refused with the first message above. | People: "E", "F", "Z", "Y" |
| TC-09 | EXCP-TEAMS-LEGACY-009 | Verify the add and remove member routes apply the same limits through the API | Regression | Same as TC-05. | 1. Sign in as leader A.<br>2. Send `POST /api/Teams/add-team-member` for E into "Sales".<br>3. Send it for F into "Sales".<br>4. Send `POST /api/Teams/remove-team-member` for a member of another leader's team.<br>5. Send both routes for an administrator and an HR member. | 1. Step 2 succeeds.<br>2. Steps 3 to 5 are refused as in TC-05 and nothing changes. | People: "E", "F" |
| TC-10 | EXCP-TEAMS-LEGACY-010 | Verify administrators keep full access and employees and HR are refused | Regression | An employee, an HR user, a leader and an administrator exist. | 1. Sign in as the employee and as the HR user and send the three routes.<br>2. Sign in as the administrator and send the three routes for any team or person.<br>3. Sign in as a leader and send the three routes for a team the leader manages. | 1. The employee and the HR user get a forbidden response for every route.<br>2. The administrator succeeds everywhere.<br>3. The leader succeeds inside the managed area only. | Roles: "Employee", "HR" |

### Requests stay separate

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-TEAMS-LEGACY-011 | Verify managing a team gives no right on the requests of its members | Regression | Leader A may manage "Sales North". Employee E is in "Sales North" and has a pending request that is routed to another leader, not to leader A. | 1. Sign in as leader A.<br>2. Remove E from "Sales North" with `POST /api/Teams/remove-team-member`.<br>3. Open E's request with `GET /api/Requests/getById` and send the approve and refuse APIs for it. | 1. Step 2 succeeds.<br>2. Step 3 is refused: the request cannot be opened and cannot be decided. | Request: "request-of-e" |
