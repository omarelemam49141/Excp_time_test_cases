# Company structure — frontend test cases

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/**`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-spotlight-tour.component.ts`, `src/app/core/guards/core/guards/admin-section.guard.ts`, `src/app/features/admin-leader/admin/services/company-structure.service.ts`
- Related docs: `docs/frontend/technical/company-structure-org-chart.md`

## Scope

- This document lists manual test cases for the feature.


## Test pages

- `/admin/**`


## Test scenarios

- **Admin** or **HR** can open the company structure page, add teams, add people **inside a team** (Employee/Leader), add **Admin or HR** above teams, set a **Team leader** badge (a Leader in that team), connect **team parents** (team or Admin/HR), set **outside supervisors** for members without an in-team manager (defaults on parent connect; custom picks stay if the parent later changes), draw **in-team** reporting lines (add report, move under, primary star), edit the tree (add / edit / move / remove), mark primary reporting lines, save, and reload.
- Any other signed-in user can open **only** `/admin/company-structure` in **read-only** mode (no save, no **Add team**, no **Add person**, no **Add Admin or HR**, no team name editing).
- Only **Admin** can open other `/admin/**` routes; **HR** and other roles are blocked from those URLs by `adminSectionGuard` (except company structure).
- Validation messages show for missing user/title/duplicate user; move requires a parent when options exist.
- User picker loads users once and caches them; subsequent searches filter client-side without API calls.
- Background attendance refresh does not force navigation away from `/admin/company-structure`.
- When there are unsaved structure edits, leaving the page shows a three-option confirmation: save and leave, leave without saving, or stay.
- Save is blocked until the graph has loaded once; destructive saves (fewer people **or** fewer reporting lines) require explicit confirmation; restore-from-backup is available for Admin/HR, lists only team-layout snapshots, opens each backup in a **read-only preview** first, and applies restore only after explicit confirmation (including the empty/zero-line second warning when needed).
- First save from a legacy person-only chart uses `legacyNodeCount` for destructive guards; `/admin-leader/teams` redirects to company structure.
- Remove asks for confirm and re-parents reports; the top person cannot be removed while they still have reports.
- Editing a person with reports to **Employee** is blocked until reports are moved. On the team layout, team members can only switch between **Employee** and **Leader**; Admin/HR chips can only switch between **Admin** and **HR**.
- **Save structure** stays disabled until every team has a valid **Team leader** badge and every Employee/Leader has an in-team manager or exactly one outside supervisor.


## Test cases

### CS-FE-01

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ORG-ORG-CHART-001 | Verify Admin navigation | Edge | - | 1. Admin opens sidebar → Company structure | Page loads without error | - |

### CS-FE-01a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-02 | EXCP-ORG-ORG-CHART-002 | Verify HR navigation | Main | - | 1. HR opens sidebar → Company structure | Page loads; link visible for HR | - |

### CS-FE-01c

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-32 | EXCP-ORG-ORG-CHART-003 | Verify any employee can open company structure | Main | Signed-in user is **not** admin and **not** HR. | 1. Open the sidebar.<br>2. Tap **"Company structure"** (or Arabic equivalent). | The page loads at **"/admin/company-structure"**.<br>No **"Save structure"** button appears. | - |

### CS-FE-02

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-03 | EXCP-ORG-ORG-CHART-004 | Verify Non-privileged blocked | Edge | - | 1. Employee navigates to `/admin/reports/...` | Guard prevents access | - |

### CS-FE-02a

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-ORG-ORG-CHART-005 | Verify HR blocked from other admin | Edge | - | 1. HR navigates to `/admin/document-types` | Guard prevents access (back) | - |

### CS-FE-02b

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-05 | EXCP-ORG-ORG-CHART-006 | Verify HR company structure | Main | - | 1. HR navigates to `/admin/company-structure` | Page loads | - |

### CS-FE-03

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-ORG-ORG-CHART-007 | Verify Empty CTA | Edge | Signed-in as **Admin** or **HR**.<br>Chart has no teams and no people. | 1. Open "/admin/company-structure".<br>2. Tap "Add team". | 1. A large button reads "Add team".<br>2. No person cards are shown.<br>3. A team card appears with a "Team name" field.<br>4. The add-person dialog does not open. | - |

### CS-FE-04

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-ORG-ORG-CHART-008 | Verify Add root | Main | - | 1. Complete add dialog; save | Success toast; tree shows card | - |

### CS-FE-05

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-ORG-ORG-CHART-009 | Verify Add report | Main | - | 1. On non-employee card, Add report | Child row appears deeper (indent) | - |

### CS-FE-06

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-09 | EXCP-ORG-ORG-CHART-010 | Verify Primary toggle | Main | - | 1. Two parents on a child; tap star | Only one primary highlighted | - |

### CS-FE-07

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-ORG-ORG-CHART-011 | Verify Employee leaf | Main | - | 1. Node kind Employee | No Add report button | - |

### CS-FE-08

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-11 | EXCP-ORG-ORG-CHART-012 | Verify Duplicate user | Edge | - | 1. Add same user twice | Error toast `companyStructure.duplicateUser` | - |

### CS-FE-09

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-12 | EXCP-ORG-ORG-CHART-013 | Verify Missing title | Edge | - | 1. Add without display title | Error toast `companyStructure.titleRequired` | - |

### CS-FE-10

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-ORG-ORG-CHART-014 | Verify Reload | Main | - | 1. Change local tree; Reload | Server state replaces draft | - |

### CS-FE-11

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-14 | EXCP-ORG-ORG-CHART-015 | Verify i18n | Main | - | 1. Switch AR/EN | Labels translate | - |

### CS-FE-12

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-15 | EXCP-ORG-ORG-CHART-016 | Verify Add manager above | Main | - | 1. Click Add manager above on a node; complete dialog | New parent row above child in tree | - |

### CS-FE-13

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-16 | EXCP-ORG-ORG-CHART-017 | Verify Edit | Main | - | 1. Edit title/kind; save | Card reflects changes | - |

### CS-FE-14

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-17 | EXCP-ORG-ORG-CHART-018 | Verify Move | Main | - | 1. Move under…; pick parent; apply | Node reparented; levels consistent | - |

### CS-FE-15

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-18 | EXCP-ORG-ORG-CHART-019 | Verify Move validation | Edge | - | 1. Move with no parent selected | Error `companyStructure.movePickParent | - |

### CS-FE-16

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-ORG-ORG-CHART-020 | Verify User picker loading | Main | - | 1. Open add dialog first time | Loading spinner shown; users load once | - |

### CS-FE-17

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-ORG-ORG-CHART-021 | Verify User picker cache | Main | - | 1. Close and reopen add dialog | Users appear instantly (no spinner/API call) | - |

### CS-FE-18

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-21 | EXCP-ORG-ORG-CHART-022 | Verify User search instant | Main | - | 1. Type in search field | Results filter instantly without API call | - |

### CS-FE-19

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-ORG-ORG-CHART-023 | Verify User search by name | Main | - | 1. Search "john" | Users with "john" in name shown | - |

### CS-FE-20

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-23 | EXCP-ORG-ORG-CHART-024 | Verify User search by username | Main | - | 1. Search "@admin" | Users with "@admin" in username shown | - |

### CS-FE-21

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-24 | EXCP-ORG-ORG-CHART-025 | Verify User search clear | Main | - | 1. Clear search field | First 50 users shown (no filter) | - |

### CS-FE-22

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-25 | EXCP-ORG-ORG-CHART-026 | Verify User search no results | Main | - | 1. Search "xyznonexistent" | "No users found" message shown | - |

### CS-FE-23

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-26 | EXCP-ORG-ORG-CHART-027 | Verify Initial load identity mapping across pages | Main | - | 1. Load graph that contains users not returned in first users page | Node cards show user name/email (no raw uuid fallback) | - |

### CS-FE-24

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-27 | EXCP-ORG-ORG-CHART-028 | Verify Zoom connector alignment | Main | - | 1. On populated graph, zoom out/in several times and scroll | Connector start/end points remain aligned with parent/child cards | - |

### CS-FE-25

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-28 | EXCP-ORG-ORG-CHART-029 | Verify no forced navigation after background refresh | Main | User is on "/admin/company-structure".<br>There is at least one background attendance refresh event while this page is open. | 1. Open "/admin/company-structure".<br>2. Wait for at least one background refresh cycle.<br>3. Continue interacting with the org chart page. | 1. The app stays on "/admin/company-structure".<br>2. The page is not redirected to "home" or attendance timer pages. | - |

### CS-FE-26

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-29 | EXCP-ORG-ORG-CHART-030 | Verify unsaved changes prompt offers stay option | Main | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page from the sidebar.<br>3. In the prompt, click "Stay on page". | 1. A warning prompt appears with three actions.<br>2. After clicking "Stay on page", user remains on "/admin/company-structure".<br>3. Unsaved edits are still visible. | - |

### CS-FE-27

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-30 | EXCP-ORG-ORG-CHART-031 | Verify unsaved changes prompt allows leave without saving | Edge | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page.<br>3. In the prompt, click "Leave without saving". | 1. Navigation proceeds immediately to the selected page.<br>2. If user returns to "/admin/company-structure", the unsaved edits are not applied. | - |

### CS-FE-28

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-31 | EXCP-ORG-ORG-CHART-032 | Verify unsaved changes prompt saves then navigates | Main | User has unsaved structure edits on "/admin/company-structure". | 1. Make a visible edit in the org chart.<br>2. Try to navigate to another page.<br>3. In the prompt, click "Save and leave". | 1. Save completes successfully with the normal success feedback.<br>2. Navigation proceeds to the selected page after save.<br>3. Returning to "/admin/company-structure" shows the saved edit. | - |

### CS-FE-29 — Data protection

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-32 | EXCP-ORG-ORG-CHART-033 | Verify Save disabled until graph loaded | Main | Admin opens company structure. | 1. Observe toolbar before load finishes.<br>2. After load completes. | 1. **"Save structure"** is disabled until the graph has loaded.<br>2. After load, it stays disabled if any team has no **Team leader** badge or any member is missing an outside supervisor.<br>3. It becomes enabled only when those rules are met. | - |
| TC-33 | EXCP-ORG-ORG-CHART-034 | Verify people-in-chart count visible | Main | Graph loaded with N people. | 1. Read subtitle under page title. | Text shows current count and server-loaded count (e.g. "N people in chart (loaded from server: N)"). | - |
| TC-34 | EXCP-ORG-ORG-CHART-035 | Verify destructive save confirmation | Main | Loaded graph with **10+** people. | 1. Remove most nodes locally (fewer than half remain).<br>2. Click "Save structure". | Danger dialog warns about saving fewer people than server; cancel keeps edits; confirm proceeds with save. | - |
| TC-35 | EXCP-ORG-ORG-CHART-036 | Verify Restore backup | Main | At least one snapshot exists (after a prior save). | 1. Click "Restore backup".<br>2. Tap a backup row to preview.<br>3. On the banner tap "Restore this backup" and confirm.<br>4. Confirm restore in the dialog. | 1. Preview banner appears and the chart matches the backup (read-only).<br>2. After restore, chart stays on the backup structure; success message shown. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/services/company-structure.service.ts` | - |

### CS-FE-30 — Wave 1 remove

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-36 | EXCP-ORG-ORG-CHART-037 | Verify cancel remove leaves the card | Main | Admin or HR. Chart has at least one person who is not the only root with reports. | 1. Hover a person card and tap the trash control.<br>2. In the prompt titled "Remove this person?", tap "Cancel". | 1. The confirm dialog appears.<br>2. The person card is still on the chart.<br>3. Reporting lines are unchanged. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-37 | EXCP-ORG-ORG-CHART-038 | Verify remove a middle person re-parents reports | Main | Chart has Manager A → Person B → Person C (at least three levels). | 1. Hover Person B and tap trash.<br>2. Confirm "Remove". | 1. Person B's card is gone.<br>2. Person C still appears and now reports under Manager A.<br>3. The reporting line from A to C is visible. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-38 | EXCP-ORG-ORG-CHART-039 | Verify top person with reports cannot be removed | Main | Chart has a top person with at least one report. | 1. Hover the top person and tap trash. | 1. An error says "Move or remove this person's reports first. You cannot remove the top person while others still report to them."<br>2. The chart is unchanged. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### CS-FE-31 — Wave 2 edit kind

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-39 | EXCP-ORG-ORG-CHART-040 | Verify Employee kind blocked when person has reports | Main | Admin or HR. A leader card has at least one report. | 1. Open Edit on that leader.<br>2. Select "Employee".<br>3. Tap "Save changes". | 1. An error says "Move or remove this person's reports first. Employees cannot have people reporting to them."<br>2. The card kind is still Leader (or Admin/HR as before).<br>3. Child cards and lines are unchanged. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-40 | EXCP-ORG-ORG-CHART-041 | Verify Employee kind allowed when person has no reports | Main | Admin or HR. A **Leader** inside a team has no in-team reports. | 1. Open Edit on that Leader.<br>2. Confirm role choices are only **"Employee"** and **"Leader"**.<br>3. Select "Employee".<br>4. Tap "Save changes". | 1. The card shows the "Employee" role pill on the chart (not saved to the server until "Save structure").<br>2. **"Admin"** and **"HR"** are not offered in that edit dialog. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### CS-FE-32 — Wave 3 line wipe save

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-41 | EXCP-ORG-ORG-CHART-042 | Verify save warns when all reporting lines are dropped | Main | Loaded chart with people and at least one reporting line. | 1. Break every reporting line locally while keeping the same people (for example by removing a middle manager after moving people, or by edits that leave everyone unconnected).<br>2. Tap "Save structure".<br>3. Tap "Cancel" on the danger dialog. | 1. A danger dialog warns about people and reporting lines compared to the server.<br>2. After cancel, no success toast appears.<br>3. Reload still shows the original lines from the server. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### CS-FE-33 — Wave 4 restore wipe

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-42 | EXCP-ORG-ORG-CHART-043 | Verify backup list shows people and lines | Main | At least one snapshot exists. Admin or HR. | 1. Tap "Restore backup". | Each backup row shows people count and lines count (label like "N people, M lines"). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-43 | EXCP-ORG-ORG-CHART-044 | Verify empty or zero-line restore needs a second warning | Main | Live chart has reporting lines. A backup with 0 people or 0 lines exists. | 1. Tap "Restore backup".<br>2. Tap the empty or zero-line backup to preview.<br>3. Tap "Restore this backup" on the banner.<br>4. Confirm the first restore prompt.<br>5. Tap "Cancel" on the second warning titled "Restore an empty or disconnected backup?".<br>6. Tap "Cancel preview" on the banner. | 1. After cancel on the second warning, preview stays open and live DB is unchanged.<br>2. After "Cancel preview", the chart returns to the structure before preview. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-43b | EXCP-ORG-ORG-CHART-076 | Verify cancel backup preview returns to live chart | Main | Live chart differs from an older backup (different team count or people). | 1. Tap "Restore backup".<br>2. Tap a backup row.<br>3. Confirm the preview shows the backup layout (read-only; no add/edit controls).<br>4. Tap "Cancel preview". | 1. Preview banner disappears.<br>2. Chart matches the live structure from before step 1 (not the backup). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html` | - |

### Team cards

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-44 | EXCP-ORG-ORG-CHART-045 | Verify duplicate team name is blocked | Edge | Signed-in as **Admin** or **HR**. Chart has no teams. | 1. Tap "Add team".<br>2. Type "Backend" in "Team name".<br>3. Tap "Add team" again.<br>4. Type " backend " in the second "Team name" field. | 1. The second card shows "This team name is already used."<br>2. "Save structure" is disabled.<br>3. The extra "Add team" button is disabled. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-name.ts` | - |
| TC-45 | EXCP-ORG-ORG-CHART-046 | Verify read-only user has no Add team button | Main | Signed-in user is not Admin and not HR. Chart has no teams. | 1. Open "/admin/company-structure". | 1. No button reads "Add team".<br>2. The page shows "No teams yet". | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html` | - |
| TC-46 | EXCP-ORG-ORG-CHART-047 | Verify read-only team cards have no edit controls | Main | Signed-in user is not Admin and not HR. The chart already has at least one team. | 1. Open "/admin/company-structure". | 1. Each team name is shown as text.<br>2. There is no "Team name" text box.<br>3. There is no "Add team" button.<br>4. There is no "Remove team" button. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-card.component.html` | - |

### Team members and Admin/HR

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-47 | EXCP-ORG-ORG-CHART-048 | Verify a person is added only inside a team | Main | Signed-in as **Admin** or **HR**. Chart has at least one team. | 1. On a team card, tap "Add person".<br>2. Pick a user who is not already on the chart.<br>3. Enter a title.<br>4. Choose "Employee" or "Leader".<br>5. Tap "Add". | 1. The dialog title is "Add to team".<br>2. Role choices are only "Employee" and "Leader".<br>3. The person card appears inside that team card.<br>4. The person is not shown in the "Admin and HR" strip. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-card.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-48 | EXCP-ORG-ORG-CHART-049 | Verify Admin or HR is added above teams | Main | Signed-in as **Admin** or **HR**. Chart has at least one team. | 1. Tap "Add Admin or HR" above the team cards.<br>2. Pick a user who is not already on the chart.<br>3. Enter a title.<br>4. Choose "Admin" or "HR".<br>5. Tap "Add". | 1. The dialog title is "Add Admin or HR".<br>2. Role choices are only "Admin" and "HR".<br>3. The person card appears in the "Admin and HR" strip above the teams.<br>4. The person is not shown inside any team card. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-board.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-49 | EXCP-ORG-ORG-CHART-050 | Verify remove person uses the same confirm in that area | Main | Signed-in as **Admin** or **HR**. One person is inside a team and one Admin or HR is above the teams. | 1. On the team member chip, tap trash.<br>2. Confirm "Remove" on the prompt titled "Remove this person?".<br>3. On the Admin or HR chip, tap trash.<br>4. Tap "Cancel" on "Remove this person?". | 1. After confirm, the member is gone from that team card only.<br>2. After cancel, the Admin or HR chip is still in the "Admin and HR" strip. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-person-chip.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### In-team reporting lines

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-50 | EXCP-ORG-ORG-CHART-051 | Verify two Leaders in one team can both have in-team reports | Main | Signed-in as **Admin** or **HR**. One team has two **Leader** members (no line between them yet). | 1. Hover the first Leader card inside the team.<br>2. Tap **"Add report"** and add an **Employee** under them.<br>3. Hover the second Leader card.<br>4. Tap **"Add report"** and add another **Employee** under them. | 1. Each Leader shows an **"Add report"** control.<br>2. Connector lines stay inside that team card only.<br>3. Both Employees appear under their respective Leaders with visible lines. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-in-team-tree.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-51 | EXCP-ORG-ORG-CHART-052 | Verify Employee cannot receive an in-team report line | Edge | Signed-in as **Admin** or **HR**. One team has a **Leader** and an **Employee** with no line between them. | 1. Hover the **Employee** card inside the team.<br>2. Look for **"Add report"** on that card. | 1. **"Add report"** is not shown on the Employee card.<br>2. Only edit, add manager above, move, and remove actions appear (when editing is allowed). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-in-team-tree.component.html` | - |
| TC-52 | EXCP-ORG-ORG-CHART-053 | Verify move under cannot target another team | Edge | Signed-in as **Admin** or **HR**. Two teams each have at least one **Leader**. | 1. On team A, hover a member and tap **"Move under…"**.<br>2. Open the parent picker. | 1. The list shows only **Leaders from team A** (not team B members, not Admin/HR).<br>2. No error about cross-team lines is needed because other teams are not offered. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### Team parent and outside supervisors

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-53 | EXCP-ORG-ORG-CHART-054 | Verify default outside supervisor when team gets a parent team | Main | Signed-in as **Admin** or **HR**. Team **Parent** has a **Leader** badge. Team **Child** has one **Employee** with no in-team manager. | 1. On **Child**, tap **"Set parent"**.<br>2. Pick team **Parent** and apply.<br>3. Open the **Employee** card on **Child**. | 1. **Child** shows **Reports up to** **Parent**.<br>2. The **Employee** shows **Outside supervisor** with the **Parent** badge Leader’s name.<br>3. **Save structure** is enabled (all members have a supervisor path). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-outside-supervisor-rules.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-54 | EXCP-ORG-ORG-CHART-055 | Verify change outside supervisor to another Leader | Main | Same as TC-53; default supervisor already applied. Another team has a **Leader**. | 1. On the **Employee** on **Child**, tap **"Change supervisor"**.<br>2. Pick the **Leader** from the other team.<br>3. Apply. | 1. **Outside supervisor** label updates to the chosen Leader.<br>2. **Save structure** stays enabled if every team also has a **Team leader** badge. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-in-team-tree.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-55 | EXCP-ORG-ORG-CHART-056 | Verify save blocked when outside supervisor missing | Edge | Signed-in as **Admin** or **HR**. One team has an **Employee** with no in-team manager and no team parent. | 1. Observe toolbar.<br>2. Tap **Save structure**. | 1. Amber text says every person without an in-team manager needs an outside supervisor.<br>2. **Save structure** is disabled.<br>3. Tapping save does not call the API (button disabled). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html` | - |
| TC-56 | EXCP-ORG-ORG-CHART-057 | Verify team under Admin or HR person | Main | Signed-in as **Admin** or **HR**. At least one **Admin** or **HR** is in the strip above teams. A team has no parent. | 1. On the team, tap **"Set parent"**.<br>2. Pick **Admin/HR: …** and apply. | 1. **Reports up to** shows that Admin/HR name.<br>2. Members without an in-team manager show that Admin/HR as **Outside supervisor** (default). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-card.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-57 | EXCP-ORG-ORG-CHART-058 | Verify in-team manager clears outside supervisor | Main | **Employee** on a child team has an outside supervisor and no in-team manager. | 1. Use **Add manager above** (or **Move under…**) to add an in-team **Leader** above the **Employee**.<br>2. Check the **Employee** card. | 1. The **Outside supervisor** row disappears for that **Employee**.<br>2. **Save structure** stays enabled if every other member is valid. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-outside-supervisor-rules.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### Save, leave guard, and retired teams route

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-58 | EXCP-ORG-ORG-CHART-059 | Verify first team save warns when legacy chart exists | Main | Database still has a **legacy** person-only org chart (`isTeamLayout` false). Signed-in as **Admin** or **HR**. | 1. Open "/admin/company-structure" (empty editor).<br>2. Add a valid team with members and supervisors.<br>3. Tap **Save structure**.<br>4. Tap **Cancel** on the danger dialog.<br>5. Tap **Save structure** again and confirm the danger dialog. | 1. The danger dialog compares your draft to the **legacy** people count (not zero).<br>2. After cancel, no success toast.<br>3. After confirm, save succeeds and teams appear after reload. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-59 | EXCP-ORG-ORG-CHART-060 | Verify reload after save shows saved teams | Main | Signed-in as **Admin** or **HR**. A team layout was saved at least once. | 1. Open "/admin/company-structure".<br>2. Note team names.<br>3. Reload the browser tab. | 1. The same team cards and members load from the API.<br>2. No empty **Add team**-only state unless the chart is truly empty. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-60 | EXCP-ORG-ORG-CHART-061 | Verify /admin-leader/teams redirects to company structure | Main | Signed-in user can open admin routes. | 1. Navigate to "/admin-leader/teams".<br>2. Navigate to "/admin-leader/teams/list". | 1. The URL ends on "/admin/company-structure".<br>2. The company structure page is shown (not the old teams list). | `src/app/features/admin-leader/shared/admin-leader.routes.ts` | - |
| TC-61 | EXCP-ORG-ORG-CHART-062 | Verify legacy-only backups are not restorable from the list | Edge | Only automatic backups exist from **before** team layout (no `teams` in snapshot). Admin or HR. | 1. Tap **Restore backup**. | 1. No legacy backup rows appear, **or** the dialog shows text that only old person-only backups exist and cannot be restored.<br>2. If a legacy backup is forced via API, the error explains the backup has no teams. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html` | - |
| TC-62 | EXCP-ORG-ORG-CHART-063 | Verify unsaved team edits trigger leave guard | Main | Signed-in as **Admin** or **HR**. | 1. Change a team name or add a team without saving.<br>2. Navigate away (sidebar link).<br>3. Choose **Stay on page**. | 1. A three-option leave dialog appears.<br>2. After **Stay on page**, you remain on company structure with unsaved changes intact. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |

### Team leader badge and edit kinds

| ID | Key | Case | Type | Preconditions | Steps | Expected | Requires | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|----------|--------------|-----------|
| TC-63 | EXCP-ORG-ORG-CHART-064 | Verify first Leader in a team gets the Team leader badge | Main | Signed-in as **Admin** or **HR**. A named team has no members. | 1. On the team card, tap **"Add person"**.<br>2. Add a **Leader**.<br>3. Look at that person’s card. | 1. A teal chip reads **"Team leader"**.<br>2. **"Save structure"** is no longer blocked for a missing badge on that team. | - | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-badge.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-in-team-tree.component.html` | - |
| TC-64 | EXCP-ORG-ORG-CHART-065 | Verify another Leader can take the Team leader badge | Main | Signed-in as **Admin** or **HR**. One team has two **Leader** members. The first added shows **"Team leader"**. | 1. Hover the second Leader.<br>2. Tap the bookmark control titled **"Set as team-leader badge"**.<br>3. Look at both cards. | 1. The second Leader shows **"Team leader"**.<br>2. The first Leader no longer shows **"Team leader"**. | EXCP-ORG-ORG-CHART-064 | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-in-team-tree.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-65 | EXCP-ORG-ORG-CHART-066 | Verify removing the badge Leader moves the badge | Main | Signed-in as **Admin** or **HR**. One team has two **Leaders**. The first has **"Team leader"**. | 1. Remove the badge Leader (confirm **"Remove this person?"**).<br>2. Look at the remaining Leader. | 1. The remaining Leader shows **"Team leader"**.<br>2. No amber text says **"Each team needs a Leader badge before save."** | EXCP-ORG-ORG-CHART-064 | `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-badge.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-66 | EXCP-ORG-ORG-CHART-067 | Verify save stays disabled without a Team leader badge | Edge | Signed-in as **Admin** or **HR**. A named team has only an **Employee** (no Leader). | 1. Observe the toolbar.<br>2. Try to tap **"Save structure"**. | 1. Amber text says **"Each team needs a Leader badge before save."**<br>2. **"Save structure"** is disabled. | - | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-badge.ts` | - |
| TC-67 | EXCP-ORG-ORG-CHART-068 | Verify team member edit does not offer Admin or HR | Edge | Signed-in as **Admin** or **HR**. A team has an **Employee**. | 1. Open **Edit** on that Employee. | Role choices are only **"Employee"** and **"Leader"** (no **"Admin"**, no **"HR"**). | - | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-68 | EXCP-ORG-ORG-CHART-069 | Verify Admin or HR edit does not offer Employee or Leader | Edge | Signed-in as **Admin** or **HR**. An **Admin** or **HR** chip sits above the teams. | 1. Open **Edit** on that chip. | Role choices are only **"Admin"** and **"HR"** (no **"Employee"**, no **"Leader"**). | - | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-69 | EXCP-ORG-ORG-CHART-070 | Verify changing team parent keeps a custom outside supervisor | Main | Signed-in as **Admin** or **HR**. **Child** team Employee has a **custom** outside supervisor (not the parent badge). A third team **Other** has a Leader. | 1. On **Child**, tap **"Change parent"**.<br>2. Pick team **Other** and apply.<br>3. Open the **Employee** card. | 1. **Reports up to** shows **Other**.<br>2. **Outside supervisor** still shows the custom Leader (not **Other**’s badge Leader). | EXCP-ORG-ORG-CHART-055 | `src/app/features/admin-leader/admin/components/company-structure/company-structure-outside-supervisor-rules.ts` | - |
| TC-70 | EXCP-ORG-ORG-CHART-071 | Verify changing the badge Leader to Employee moves the badge | Main | Signed-in as **Admin** or **HR**. One team has two **Leaders** with no in-team reports. The first shows **"Team leader"**. | 1. Edit the badge Leader.<br>2. Select **"Employee"**.<br>3. Tap **"Save changes"**. | 1. The edited card shows **"Employee"**.<br>2. The other Leader shows **"Team leader"**. | EXCP-ORG-ORG-CHART-064 | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-team-badge.ts` | - |

### Interactive guided tour

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code | Test data |
|----|-----|------|------|---------------|-------|----------|--------------|-----------|
| TC-71 | EXCP-ORG-ORG-CHART-072 | Verify Admin can start the spotlight guided tour from the user guide | Main | Signed-in as **Admin** or **HR**. On `/admin/company-structure`. | 1. Tap **"User guide"** (or Arabic **"دليل الاستخدام"**).<br>2. Tap **"Start guided tour"** (or Arabic **"ابدأ الجولة التفاعلية"**). | 1. The reference dialog closes.<br>2. A spotlight overlay appears with step counter **"1 / …"**.<br>3. A teal pulse highlights a region of the page and a coach card shows **Next** and **Skip tour**. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-spotlight-tour.component.ts` | - |
| TC-72 | EXCP-ORG-ORG-CHART-073 | Verify guided tour advances and finishes without changing data | Main | Signed-in as **Admin** or **HR**. Spotlight tour is open (from TC-71). Chart already has at least one team. | 1. Tap **Next** through several steps.<br>2. Tap **Back** once.<br>3. Continue to the last step and tap **Finish**. | 1. The highlight moves to different controls (e.g. **Add Admin or HR**, **Add team**, **Save structure** when visible).<br>2. **Back** returns to the previous step text.<br>3. After **Finish**, the overlay closes and no save API call runs unless you saved yourself. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-spotlight-tour.component.html`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts` | - |
| TC-72a | EXCP-ORG-ORG-CHART-075 | Verify empty chart tour waits for Add team then continues the full path | Main | Signed-in as **Admin** or **HR**. Org chart is **empty** (mega **Add team** only). | 1. Open **User guide** → **Start guided tour**.<br>2. Go to the **Add team** step.<br>3. Confirm **Next** is disabled.<br>4. Tap the highlighted **Add team** CTA and name the team.<br>5. Continue **Next** through later steps (Admin/HR, leader, routing, save). | 1. The step counter is the **full** tour (not a 5-step short tour).<br>2. On **Add team**, **Next** stays disabled until a team card exists.<br>3. After adding a team, the tour continues (auto or **Next**) to the team card and later steps.<br>4. Starting the tour does **not** maximize a team card by itself. | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.ts`, `src/app/features/admin-leader/admin/components/company-structure/company-structure-spotlight-tour.component.ts` | - |
| TC-73 | EXCP-ORG-ORG-CHART-074 | Verify read-only user does not get Start guided tour | Edge | Signed-in as a normal **Employee** (not Admin/HR). | 1. Open `/admin/company-structure`.<br>2. Tap **"User guide"**. | 1. The four reference steps appear.<br>2. Footer shows **Close** only (no **Start guided tour**). | `src/app/features/admin-leader/admin/components/company-structure/company-structure-page.component.html` | - |
