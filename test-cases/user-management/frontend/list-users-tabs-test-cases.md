# Users list — tabs (frontend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `frontend`
- Routes: `/admin-leader/list-users
- APIs: -
- Related code: `src/app/features/admin-leader/shared/components/list-users/`
- Related docs: `docs/frontend/technical/admin-user-wizard.md`

## Scope

- Route: /admin-leader/list-users (and equivalent for leader view).
- Components involved: users list screen, two tabs (today/attendance and profile/roles), and the user details dialog.

## Test pages

- /admin-leader/list-users

## Test scenarios

- The **Today & attendance** tab shows times, attendance status, platforms, and work place.
- The **Profile & roles** tab shows username, email, roles, leader (admin), location/job, active status, and actions.
- Switching tabs keeps the same page URL, filters, and pagination.
- **Details** opens the same details dialog from either tab.
- **Edit** (admin only) navigates to the user edit screen from either tab.
- The **Roles** column on the profile tab shows role names when the server returns them.
- Tab labels and the tab list accessibility label work in English and Arabic.
- Tab buttons expose correct accessibility roles and selected state; animations respect reduced motion.

## Test cases

### Tab switcher

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-USER-USERS-TABS-001 | Verify the Today & attendance tab shows the legacy table columns | Main | - | 1. Open the app as an admin or leader.<br>2. Navigate to the users list at /admin-leader/list-users.<br>3. Click the tab named "Today & attendance" (or the English equivalent). | The table shows columns for times, attendance status, platforms, and work place. | - |
| TC-02 | EXCP-USER-USERS-TABS-002 | Verify the Profile & roles tab shows profile and role fields | Main | - | 1. Open the app as an admin or leader.<br>2. Navigate to the users list at /admin-leader/list-users.<br>3. Click the tab named "Profile & roles" (or the English equivalent). | The table shows username, email, roles, leader (admin), location/job, active status, and actions. | - |
| TC-03 | EXCP-USER-USERS-TABS-003 | Verify switching tabs keeps filters and pagination | Edge | - | 1. Open the users list at /admin-leader/list-users.<br>2. Apply filters and go to a page other than page 1.<br>3. Switch to the other tab.<br>4. Switch back. | The same filters and pagination values remain applied (shared list data). | - |

### Details and edit

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-USER-USERS-TABS-004 | Verify Details opens the same dialog from either tab | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. On the first tab, open **Details** for a row.<br>3. Close the dialog.<br>4. Switch tabs.<br>5. Open **Details** for a row on the second tab. | The same details dialog opens with the selected user in both cases. | - |
| TC-05 | EXCP-USER-USERS-TABS-005 | Verify Edit navigates to the user edit screen for admins | Main | - | 1. Sign in as an admin.<br>2. Open the users list at /admin-leader/list-users.<br>3. Click **Edit** on a row on either tab. | The browser navigates to /admin-leader/users/{id}/edit for that user. | - |

### Data and localization

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-06 | EXCP-USER-USERS-TABS-006 | Verify the Roles column shows names returned by the server | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. Switch to the profile tab.<br>3. Compare the **Roles** column with the API response that includes role names. | The **Roles** cell shows the comma-separated role names from the server when they exist. | - |
| TC-07 | EXCP-USER-USERS-TABS-007 | Verify tab labels resolve in English and Arabic | Regression | - | 1. Open the users list in English.<br>2. Note the tab labels and the tab list label read by a screen reader.<br>3. Switch the app language to Arabic.<br>4. Repeat. | Tab labels and the tab list label show the correct translated strings in both languages. | - |

### Accessibility

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-08 | EXCP-USER-USERS-TABS-008 | Verify tab buttons expose correct accessibility state | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. Inspect the tab buttons with browser accessibility tools. | Each tab button has role="tab" and the selected tab has a clear selected state (for example aria-selected="true"). | - |
| TC-09 | EXCP-USER-USERS-TABS-009 | Verify reduced motion is respected for tab animations | Edge | - | 1. Enable **prefers-reduced-motion** in the operating system or browser.<br>2. Switch between tabs on the users list. | Tab panel motion uses a reduced or non-animated path that is comfortable for reduced-motion users. | - |
