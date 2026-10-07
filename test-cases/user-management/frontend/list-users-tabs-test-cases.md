# Users list — tabs (frontend)

## Metadata

- Project: `excp-time`
- Feature: `user-management`
- Layer: `frontend`
- Routes: `/admin-leader/list-users`
- APIs: -
- Related code: `src/app/features/admin-leader/shared/components/list-users/`, `src/app/dynamic/components/dynamic-filter/`, `src/app/core/services/custom-account.service.ts`, `src/app/core/services/attendance.service.ts`
- Related docs: `docs/frontend/technical/admin-user-wizard.md`

## Scope

- Route: /admin-leader/list-users (and equivalent for leader view).
- Components involved: users list screen, two tabs (today/attendance and profile/roles), the filter header, the two employee tables, and the user details dialog.
- Covers the reworked table layout (employee cell with username + email, start/end cells with times and platforms), the platform states, filter behavior, list states (loading, error, empty, no match), live refresh, and dialog/localization behavior.

## Test pages

- /admin-leader/list-users

## Test scenarios

- The **Today & attendance** tab shows an employee column (username + email), Start and End cells with times and platforms, attendance status, work place, leader (admin), and actions.
- The **Profile & roles** tab shows an employee column, roles, leader (admin), location/job, account status, and actions.
- Switching tabs keeps the same page URL, filters, and pagination.
- **Details** opens the same details dialog from either tab; **Edit** (admin only) navigates to the user edit screen from either tab.
- A start or end without a captured platform shows "Platform unavailable"; a missing start or end shows "Not registered".
- Filters emit the typed value they represent, and option labels do not toggle a different filter.
- The list shows distinct loading, error, empty, and "no filter match" states.
- The list refreshes live when the server reports an attendance change, preserving tab, filters, search, and page.
- Role names, location options, and work-place labels follow the active language; employee-entered data stays as entered.
- Tab buttons expose correct accessibility roles and selected state; animations respect reduced motion.

## Test cases

### Tab switcher

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-USER-USERS-TABS-001 | Verify the Today & attendance tab shows the attendance table columns | Main | - | 1. Open the app as an admin or leader.<br>2. Navigate to the users list at /admin-leader/list-users.<br>3. Click the tab named "Today & attendance" (or the English equivalent). | 1. An employee column shows username and email.<br>2. Start and End cells show the times with their platforms.<br>3. Attendance status, work place, actions, and (for an admin) leader columns are present. | - |
| TC-02 | EXCP-USER-USERS-TABS-002 | Verify the Profile & roles tab shows profile and role fields | Main | - | 1. Open the app as an admin or leader.<br>2. Navigate to the users list at /admin-leader/list-users.<br>3. Click the tab named "Profile & roles" (or the English equivalent). | 1. An employee column shows username and email.<br>2. Roles, location/job, and account status columns are present.<br>3. Actions are present, and the leader column appears for an admin. | - |
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

### Platform and attendance cells

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-10 | EXCP-USER-USERS-TABS-010 | Verify Start and End show the captured platform next to the time | Main | An employee started today from the web browser and ended the day from the web browser. | 1. Open the users list at /admin-leader/list-users.<br>2. On "Today & attendance" find that employee. | 1. The Start cell shows the start time together with the chip "Web".<br>2. The End cell shows the end time together with the chip "Web". | - |
| TC-11 | EXCP-USER-USERS-TABS-011 | Verify an end time without a known platform shows "Platform unavailable" | Edge | An employee has an end time today but the platform for that end was never captured (for example the day was corrected by an admin). | 1. Open the users list at /admin-leader/list-users.<br>2. Find that employee on "Today & attendance". | 1. The End cell shows the end time.<br>2. Under the time the label "Platform unavailable" appears.<br>3. No platform value is guessed for that end. | - |
| TC-12 | EXCP-USER-USERS-TABS-012 | Verify a missing start or end shows "Not registered" without a platform chip | Main | One employee has no attendance today; another has a start but no end yet. | 1. Open the users list at /admin-leader/list-users.<br>2. Find those employees on "Today & attendance". | 1. A missing start or end cell shows "Not registered".<br>2. No platform chip is shown next to a missing start or end.<br>3. Yesterday's platform does not appear on today's empty cells. | - |

### Filters

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-13 | EXCP-USER-USERS-TABS-013 | Verify the account status filter returns the selected status | Main | The list contains active and inactive employees. | 1. Open the users list at /admin-leader/list-users.<br>2. Under "Account status" select "Inactive". | 1. The list refreshes showing only inactive employees.<br>2. The "Inactive" option stays selected after the refresh.<br>3. Selecting "Active" then "All" returns both kinds again. | - |
| TC-14 | EXCP-USER-USERS-TABS-014 | Verify choosing a filter option toggles that same option only | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. Under "Choose employee role" click the **label** of a role (for example "Employee").<br>3. Under "Existing Location" click the **label** of a location. | 1. After step 2 the role checkbox next to that role is checked and no other filter's option changed.<br>2. After step 3 the location checkbox next to that location is checked and the role choice is unchanged. | - |
| TC-15 | EXCP-USER-USERS-TABS-015 | Verify "All" is the default account status and shows everyone | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. Look at the "Account status" filter without touching it. | 1. The "All" option is selected by default.<br>2. The list shows employees regardless of account status. | - |

### List states

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-16 | EXCP-USER-USERS-TABS-016 | Verify a loading state appears while the list loads | Main | - | 1. Open the users list at /admin-leader/list-users (a slow network can help). | The list area shows "Loading employees…" until the data arrives, then replaces it with the table. | - |
| TC-17 | EXCP-USER-USERS-TABS-017 | Verify an error state offers a retry | Edge | The get-users-list request fails (offline or server error). | 1. Open the users list while the request fails. | 1. The list area shows "Could not load employees. Please try again."<br>2. A "Retry" button loads the list once the connection works again. | - |
| TC-18 | EXCP-USER-USERS-TABS-018 | Verify the no-match message when filters exclude everyone | Edge | Filters or search are applied that match no employee. | 1. Apply a filter combination with no matches (or search for a term no one matches). | The list area shows "No employees match the current filters." rather than the plain "No users available" message. | - |

### Live refresh

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-19 | EXCP-USER-USERS-TABS-019 | Verify the list refreshes live when attendance changes | Main | An admin or leader has the users list open; another session can start or end work for an employee in view. | 1. Keep /admin-leader/list-users open as an admin or leader.<br>2. In another session, start or end work for an employee visible in the list.<br>3. Watch the list for a few seconds without manually refreshing. | 1. The affected row updates within a few seconds.<br>2. The active tab, applied filters, search text, and page stay exactly as they were.<br>3. No full page reload happens. | - |

### Details dialog

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-20 | EXCP-USER-USERS-TABS-020 | Verify the details dialog groups fields into sections | Main | - | 1. Open the users list at /admin-leader/list-users.<br>2. Click "Details" on a row. | 1. The dialog shows the sections "Identity & contact", "Profile & account", and "Today's attendance".<br>2. "Identity & contact" shows username, email, and phone.<br>3. "Profile & account" shows job, leader, roles, and account status.<br>4. "Today's attendance" shows attendance status, start, end, and work place. | - |
| TC-21 | EXCP-USER-USERS-TABS-021 | Verify Escape closes the details dialog and returns focus | Edge | The details dialog is open. | 1. Open "Details" for a row.<br>2. Press Escape. | 1. The dialog closes.<br>2. Keyboard focus returns to the control that opened it. | - |

### Localization of labels

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-22 | EXCP-USER-USERS-TABS-022 | Verify location filter options show Arabic names in Arabic | Regression | Locations have Arabic names saved on the server. | 1. Open the users list in Arabic.<br>2. Open the location filter options.<br>3. Select a location and confirm the list filters. | 1. Each location option shows its Arabic name from the server.<br>2. Selecting it filters the list the same way as in English. | - |
| TC-23 | EXCP-USER-USERS-TABS-023 | Verify known role names are translated in the Roles column | Regression | Roles include known roles (for example "Admin", "Employee"). | 1. Open the users list in Arabic.<br>2. Switch to the "Profile & roles" tab.<br>3. Read the **Roles** cell. | 1. Known role names show their Arabic translation.<br>2. A custom role name that has no translation stays exactly as saved on the server. | - |
