# Work plans and work-from-home request — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `work-plans`
- Layer: `frontend`
- Routes: `/admin-leader/work-plans`, `/my-requests`
- APIs: `POST /api/work-plans/set`, `POST /api/work-plans/review`, `POST /api/work-plans/list`, `GET /api/work-plans/current/{employeeId}`
- Automation: -
- Related code: `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts`
- Related docs: `docs/frontend/technical/work-place-dashboard-and-work-plans.md`

## Scope

- Setting, proposing, approving and rejecting weekly plans, and the work-from-home request type and request.

## Test pages

- `/admin-leader/work-plans`
- `/admin/request-types`
- `/my-requests`

## Test scenarios

- Verify HR and Admin plans apply at once and leader plans wait for HR.
- Verify a leader can plan only the direct team.
- Verify the work-from-home request type is validated and approved through the normal request flow.

## Test cases

### Plan setup

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-WORKPLAN-PLAN-001 | Verify HR can set a plan for many employees at once | Main | Signed in as HR. | 1. Open Work plans and click "New plan".<br>2. Select several employees.<br>3. Click the "Company Sun–Thu" preset, then set Tuesday to Home.<br>4. Click "Save plan". | 1. The summary shows 4 company days and 1 home day.<br>2. A success message appears.<br>3. In the "Approved" tab each employee has one new row with the chosen days. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-02 | EXCP-WORKPLAN-PLAN-002 | Verify the plan applies from its effective date | Main | A plan was saved with an effective date of next week. | 1. Open the Work place dashboard for a day before the effective date.<br>2. Open it for a day after. | 1. Before the date those employees show "No plan".<br>2. After the date they are counted as planned. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-03 | EXCP-WORKPLAN-PLAN-003 | Verify a plan needs at least one employee and one planned day | Edge | New plan dialog is open. | 1. Leave employees empty with days set.<br>2. Select employees with every day Off. | 1. The save button stays disabled in both cases. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.html` |
| TC-04 | EXCP-WORKPLAN-PLAN-004 | Verify a new plan replaces the old one without deleting history | Regression | An employee has an approved plan. | 1. Save a different plan for the same employee and the same effective date.<br>2. Open the "All" tab. | 1. The new plan is the one used by the dashboard.<br>2. The old row shows as "Replaced". | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |

### Leader proposal and HR review

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-05 | EXCP-WORKPLAN-PLAN-005 | Verify a leader sees only the team and sends the plan to HR | Main | Signed in as a Leader with direct reports. | 1. Open Work plans and click "New plan".<br>2. Open the employee list.<br>3. Select team members, set days, click "Send to HR". | 1. A note says only the direct team can be planned.<br>2. Only the leader's team is listed.<br>3. The message says the plan was sent to HR and the row shows "Waiting for HR". | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-06 | EXCP-WORKPLAN-PLAN-006 | Verify a pending plan does not affect the dashboard | Main | A leader plan is waiting for HR. | 1. Open the Work place dashboard as HR. | 1. The employee still shows the old plan, or "No plan".<br>2. The pending plan is not counted. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-07 | EXCP-WORKPLAN-PLAN-007 | Verify HR approves a proposal | Main | A leader plan is waiting. | 1. Sign in as HR and open Work plans.<br>2. Click "Approve" on the pending row and confirm. | 1. A success message appears.<br>2. The row leaves the Pending tab and shows as Approved.<br>3. The dashboard now uses the plan. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-08 | EXCP-WORKPLAN-PLAN-008 | Verify HR rejects a proposal with a reason | Main | A leader plan is waiting. | 1. Click "Reject" on the pending row.<br>2. Try to confirm with an empty reason.<br>3. Enter a reason and confirm. | 1. A reason is required.<br>2. The row shows Rejected with the reason.<br>3. The plan is not used by the dashboard. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-09 | EXCP-WORKPLAN-PLAN-009 | Verify a leader cannot approve plans | Edge | Signed in as a Leader. | 1. Open Work plans. | 1. No Approve or Reject buttons are shown.<br>2. Calling the review endpoint as a leader is refused. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.html` |

### Work-from-home request

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-10 | EXCP-WORKPLAN-WFH-001 | Verify admin can mark a request type as Work from home | Main | Signed in as Admin. | 1. Open request types and create a type named "Work From Home".<br>2. Set "Special behavior" to "Work from home" and save.<br>3. Open the type again. | 1. The type is saved.<br>2. Special behavior still shows "Work from home". | - | `src/app/features/admin-leader/admin/modules/Request types/components/create-request-type/create-request-type.component.ts`, `src/app/features/admin-leader/admin/modules/Request types/components/update-request-type/update-request-type.component.ts` |
| TC-11 | EXCP-WORKPLAN-WFH-002 | Verify the work-from-home request date rules | Edge | The Work From Home type exists. | 1. Create a request starting yesterday.<br>2. Create one with end before start.<br>3. Create one longer than 31 days. | 1. Each is refused with a clear localized message.<br>2. No request is created. | - | `src/app/pages/my-requests/my-requests.component.ts` |
| TC-12 | EXCP-WORKPLAN-WFH-003 | Verify overlapping work-from-home requests are refused | Edge | The employee has a pending or approved work-from-home request. | 1. Create another request with overlapping dates. | 1. A message says there is already a request for those dates. | - | `src/app/pages/my-requests/my-requests.component.ts` |
| TC-13 | EXCP-WORKPLAN-WFH-004 | Verify an approved request makes the day a home day on the dashboard | Main | An employee planned for the company has an approved work-from-home request for today and checks in from home. | 1. Open the Work place dashboard for today. | 1. The employee counts under "Must work from home" and "Worked from home".<br>2. The employee is not a violation. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-14 | EXCP-WORKPLAN-WFH-005 | Verify a rejected or pending request does not change the day | Edge | A work-from-home request is pending, then rejected. | 1. Employee planned for the company checks in from home.<br>2. Open the dashboard. | 1. The employee is listed under violations while the request is pending or rejected. | - | `src/app/features/admin-leader/shared/components/work-place-overview/work-place-overview.component.ts` |
| TC-15 | EXCP-WORKPLAN-PLAN-010 | Verify the employee list only offers people the caller may plan | Edge | A Leader with one direct report and other employees exist. | 1. Sign in as the Leader, open "New plan" and open the employee list.<br>2. Sign in as HR and repeat. | 1. The Leader sees only direct reports.<br>2. HR sees all active employees.<br>3. Typing a username or a display name finds the employee. | - | `src/app/features/admin-leader/shared/components/work-plans/work-plans.component.ts` |
| TC-16 | EXCP-WORKPLAN-PLAN-011 | Verify a leader cannot plan outside the team or themselves | Edge | Signed in as a Leader. | 1. Call "set" with a team member plus a non-team employee.<br>2. Call "set" with the leader's own id.<br>3. Call "set" with a day marked both home and company. | 1. Only the team member gets a plan waiting for HR and the other id is returned as skipped.<br>2. Nothing is created and the id is skipped.<br>3. The call is refused with a clear message. | - | `src/app/features/admin-leader/shared/services/work-place.service.ts` |
| TC-17 | EXCP-WORKPLAN-PLAN-012 | Verify HR and Admin are notified of a leader proposal | Main | A Leader has a team member. | 1. Sign in as the Leader and send a plan to HR.<br>2. Sign in as HR and open the bell.<br>3. Click the notification. | 1. The newest notification says the leader proposed a weekly work plan for 1 employee, in the current language.<br>2. Clicking it opens Work plans. | - | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts`, `src/app/core/utils/request-notification-link.util.ts` |
| TC-18 | EXCP-WORKPLAN-PLAN-013 | Verify the leader and employee are told about the HR decision | Main | A proposal is waiting for HR. | 1. HR approves it.<br>2. Open the Leader bell, then the Employee bell.<br>3. Send another proposal and have HR reject it with a reason.<br>4. Open the Leader bell. | 1. The Leader sees the plan was approved.<br>2. The Employee sees that their weekly plan was updated.<br>3. After a rejection the Leader sees the plan was rejected for that employee. | - | `src/app/core/components/notifications/notification-bell/notification-bell.component.ts` |
| TC-19 | EXCP-WORKPLAN-PLAN-014 | Verify success dialogs use the Arabic button text | Regression | Language is Arabic. | 1. Save any work plan. | 1. The success dialog button reads "موافق", not "Okay". | - | `src/app/shared/services/swal.service.ts` |
| TC-20 | EXCP-WORKPLAN-WFH-006 | Verify the request type form defaults and labels | Edge | Signed in as Admin. | 1. Open the create request type page. | 1. "Special behavior" shows "بدون" by default.<br>2. The two multi-select labels read "الحقول المطلوبة" and "المستندات المطلوبة". | - | `src/app/features/admin-leader/admin/modules/Request types/components/create-request-type/create-request-type.component.ts`, `src/app/core/components/generic-crud/generic-create/generic-create.component.ts` |
