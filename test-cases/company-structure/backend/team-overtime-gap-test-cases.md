# Team overtime gap (backend) Test Cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `backend`
- Routes: `-`
- APIs: `GET /api/company-structure-team-overtime-gap/team/{teamId}`, `PUT /api/company-structure-team-overtime-gap/team/{teamId}`
- Related code: `src/Excp.HRSystem.Application/Services/WorkSchedule/OvertimeGapResolver.cs`, `src/Excp.HRSystem.Domain/Entities/Teams/Team.cs`
- Related docs: `docs/backend/technical/team-overtime-gap.md`
- Automation: `test/Excp.HRSystem.EntityFrameworkCore.Tests/Integration/OvertimeGapResolverSqliteTests.cs`

## Scope

- A team can override the site and home overtime gap. Null means the team uses the global value.
- Resolution: team override, otherwise global. Site and home are separate. No parent-team inheritance.

## Test scenarios

- Team override wins
- One override set, the other inherits
- No team or no override uses global

## Test cases

### Wave 1 — Gap resolution

| ID | Key | Case | Type | Requires | Steps | Expected | Related code |
|----|-----|------|------|----------|-------|----------|--------------|
| TC-01 | EXCP-OT-GAP-TEAM-001 | Verify the team override wins over the global gap for site and home. | Main | - | 1. Team site 45, home 20; global site 30, home 10.<br>2. Resolve for a team member. | 1. Site is 45.<br>2. Home is 20. | `src/Excp.HRSystem.Application/Services/WorkSchedule/OvertimeGapResolver.cs` |
| TC-02 | EXCP-OT-GAP-TEAM-002 | Verify a team that sets only one gap inherits global for the other. | Main | EXCP-OT-GAP-TEAM-001 | 1. Team site 45, home not set; global home 10. | 1. Site is 45.<br>2. Home is 10. | `src/Excp.HRSystem.Application/Services/WorkSchedule/OvertimeGapResolver.cs` |
| TC-03 | EXCP-OT-GAP-TEAM-003 | Verify an employee without a team override uses the global gap. | Edge | EXCP-OT-GAP-TEAM-001 | 1. Employee in a team with no override, and an employee with no team. | 1. Both resolve to the global value.<br>2. An invalid user id also resolves to global. | `src/Excp.HRSystem.Application/Services/WorkSchedule/OvertimeGapResolver.cs` |
