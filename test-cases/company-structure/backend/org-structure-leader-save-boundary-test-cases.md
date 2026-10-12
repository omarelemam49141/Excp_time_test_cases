# Company Structure — Leader Save Boundary — Backend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: `/admin/company-structure`
- APIs: `POST /api/company-structure/Save-graph`
- Related code: `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureLeaderSaveAuthorizer.cs`, `src/Excp.HRSystem.Application/Services/CompanyStructure/OrgStructureLeaderPermissionResolver.cs`
- Related docs: `docs/backend/technical/team-membership-authorization-review.md`
- Automation: `test/Excp.HRSystem.Application.Tests/CompanyStructure/OrgStructureLeaderSaveBoundaryTests.cs`

## Scope

This document covers what a Leader can and cannot change when saving the company structure. A Leader manages their own team and the teams below it, and cannot manage another Leader's branch. Every change to who reports to whom also changes who approves that person's requests, so these limits matter for request approval.

Two cases (TC-02) describe the correct behavior that the current system does not yet have. Their automated tests exist but are switched off with the reason "known gap" until the save check is fixed. Do not mark TC-02 as succeeded before that fix.

## Test pages

- `/admin/company-structure`

## Test scenarios

- A leader can make allowed changes inside their own team.
- A leader cannot change who reports to whom inside another leader's branch.
- A leader cannot change the team tree or move people into another leader's teams.
- A leader's editable area is their own team and the teams below it.

## Test cases

### Own branch

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ORG-LEADER-SAVE-001 | Verify a leader can change a reporting line inside their own team, but needs the outside-supervisor right to link across teams | Main | Leader A leads a team with a child team. The leader may edit members and reporting lines but has no outside-supervisor right. | 1. Sign in as leader A and open the company structure.<br>2. Change only the display order of a reporting line inside A's team and save.<br>3. Link a person of A's child team under A and save. | 1. Step 2 saves.<br>2. Step 3 is refused with `"You are not allowed to change this part of the organization chart."`. | Teams: "Sales", "Sales North" |

### Another leader's branch

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-ORG-LEADER-SAVE-002 | Verify a leader cannot change or remove reporting lines inside another leader's branch | Regression | Leader B leads another team with employees B1 and B2 who report to B. Leader A is signed in with member-level rights. | 1. Sign in as leader A.<br>2. Send a save in which B2 now reports to B1 instead of B.<br>3. Send a save in which B1 no longer reports to anyone.<br>4. Read the direct leader of B1 and B2. | 1. Both saves are refused with `"You are not allowed to change this part of the organization chart."`.<br>2. B1 and B2 still report to B.<br>3. Their pending requests still go to B. | Employees: "B1", "B2" |
| TC-03 | EXCP-ORG-LEADER-SAVE-003 | Verify a leader cannot move their own member under another leader without the outside-supervisor right | Regression | Leader A has member A1. Leader B leads another team. Leader A has no outside-supervisor right. | 1. Sign in as leader A.<br>2. Send a save in which A1 reports to B.<br>3. Read the direct leader of A1. | 1. The save is refused.<br>2. A1 still reports to A. | Member: "A1" |

### Team tree and membership

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-ORG-LEADER-SAVE-004 | Verify a leader cannot change the team tree | Regression | Leader A leads team "Sales" with child team "Sales North". Another leader leads team "Support". | 1. Sign in as leader A.<br>2. Send a save that moves "Sales" under "Support".<br>3. Send a save that moves "Sales North" under "Support".<br>4. Send a save that moves "Support" under "Sales". | 1. Every save is refused.<br>2. The team tree is unchanged. | Teams: "Sales", "Sales North", "Support" |
| TC-05 | EXCP-ORG-LEADER-SAVE-005 | Verify a leader cannot use the people or the settings of another leader's team | Regression | Same as TC-04. | 1. Sign in as leader A.<br>2. Send a save that moves A's member into "Support".<br>3. Send a save that adds a new person to "Support".<br>4. Send a save that sets leader A as the final approver of "Support".<br>5. Send a save that gives leader A the leader badge of "Support". | 1. Every save is refused.<br>2. "Support" keeps its people, its final approver and its badge leader. | Team: "Support" |
| TC-06 | EXCP-ORG-LEADER-SAVE-006 | Verify a leader's editable area is their own team and the teams below it, and only with the child-team right | Regression | Leader A leads "Sales" with child team "Sales North". Another leader leads "Support". | 1. Open the company structure as leader A with the child-team right on.<br>2. Note which teams and people can be edited.<br>3. Switch the child-team right off and open it again. | 1. With the right on, "Sales" and "Sales North" can be edited and "Support" cannot.<br>2. With the right off, only "Sales" can be edited. | Rights: "child teams" on and off |
