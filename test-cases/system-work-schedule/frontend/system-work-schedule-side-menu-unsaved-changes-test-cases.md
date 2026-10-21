# System work schedule — Side menu, single Save and unsaved changes — Frontend Test Cases

## Metadata
- Project: `excp-time`
- Feature: `system-work-schedule`
- Layer: `frontend`
- Routes: `/admin/system-work-schedule`, `/admin/system-work-schedule/:tab`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html`
- Related docs: `docs/frontend/technical/system-work-schedule-page-layout-and-unsaved-changes.md`
- Automation: -

## Scope
- The collapsed side menu that holds the sections and tools.
- The top bar with the save state and the single "Save Updates" button.
- The unsaved-changes label and the confirmation shown when leaving, refreshing or reloading.

## Test pages
- `/admin/system-work-schedule`
- `/admin/system-work-schedule/overtime`

## Test scenarios
- Moving between sections through the side menu keeps the page and its unsaved edits.
- The label and the Save button follow the real state of the page.
- Leaving the page, refreshing it or reloading with unsaved edits always asks first.

## Test cases

### Side menu

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-SCHED-MENU-001 | Verify the sections open from a collapsed side menu | Main | The user is an admin and the page is unlocked. | 1. Open "/admin/system-work-schedule".<br>2. Look at the right edge (left edge in Arabic) of the page.<br>3. Click the round menu button. | 1. No row of section tabs is shown on the page.<br>2. A panel slides in titled "Sections & tools".<br>3. The panel lists "Shift & reminders", "Weekend", "Overtime & gaps", "Holidays", "Leave policy", "Employee balances", "Rules" and "WhatsApp".<br>4. "Shift & reminders" is highlighted as the current section. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html`, `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.scss` |
| TC-02 | EXCP-SCHED-MENU-002 | Verify choosing a section opens it and closes the menu | Main | The side menu is open. | 1. Click "Overtime & gaps" in the panel. | 1. The panel closes.<br>2. The address ends with "/overtime".<br>3. The overtime settings are shown.<br>4. The top bar shows "Overtime & gaps" as the current section. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/admin.routes.ts` |
| TC-03 | EXCP-SCHED-MENU-003 | Verify the side menu closes with the Escape key and the close button | Edge | The side menu is open. | 1. Press the Escape key.<br>2. Open the menu again.<br>3. Click the close button (X) in the panel header. | 1. The panel closes after the Escape key.<br>2. The panel closes after the close button.<br>3. The round menu button shows again each time. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-04 | EXCP-SCHED-MENU-004 | Verify the Save button stays outside the menu and visible while scrolling | Main | The page is open on a section with enough content to scroll. | 1. Scroll down the page.<br>2. Look at the top of the page. | 1. The bar with the page title, the current section and "Save Updates" stays at the top.<br>2. "Save Updates" is not inside the side menu. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.scss` |
| TC-05 | EXCP-SCHED-MENU-005 | Verify the menu and the top bar work on a phone-sized screen and in Arabic | Edge | The browser window is about 390 pixels wide. | 1. Open "/admin/system-work-schedule".<br>2. Click the round menu button.<br>3. Switch the language to Arabic and repeat. | 1. The panel opens over a dimmed background and nothing is cut off.<br>2. The menu button sits at the bottom corner and does not cover the content.<br>3. In Arabic the layout is mirrored and the texts are in Arabic. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.scss`, `src/assets/i18n/ar.json` |

### Unsaved label and Save button

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-06 | EXCP-SCHED-DIRTY-001 | Verify a freshly opened page shows no unsaved changes | Main | - | 1. Open "/admin/system-work-schedule".<br>2. Visit every section from the side menu without changing anything. | 1. The bar shows "All changes saved".<br>2. "Save Updates" is disabled.<br>3. The label "Unsaved changes" never appears. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-07 | EXCP-SCHED-DIRTY-002 | Verify editing a value shows the unsaved label and enables Save | Main | The "Shift & reminders" section is open. | 1. Change "Minutes before shift end reminder" to "5".<br>2. Look at the top bar. | 1. The label "Unsaved changes" appears.<br>2. The bar turns amber.<br>3. "Save Updates" is enabled. | Minutes before shift end reminder: "5" | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html` |
| TC-08 | EXCP-SCHED-DIRTY-003 | Verify the unsaved label stays when moving to another section | Main | An edit has been made and not saved. | 1. Open the menu and choose "Weekend".<br>2. Choose "Shift & reminders" again. | 1. No confirmation is shown.<br>2. The label "Unsaved changes" is still shown.<br>3. The edited value is still there. | - | `src/app/features/admin-leader/admin/admin.routes.ts` |
| TC-09 | EXCP-SCHED-DIRTY-004 | Verify putting a value back removes the unsaved label | Edge | An edit has been made and not saved. | 1. Type the original value back into the changed field. | 1. The label "Unsaved changes" disappears.<br>2. The bar shows "All changes saved".<br>3. "Save Updates" is disabled. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-10 | EXCP-SCHED-DIRTY-005 | Verify one Save keeps the schedule settings and the leave policy together | Main | The "Leave policy" section was opened once. | 1. In "Shift & reminders" change a value.<br>2. In "Leave policy" change "Total annual days".<br>3. Look at the bar and click "Save Updates". | 1. The label "Unsaved changes" shows after both edits.<br>2. There is no separate save button inside "Leave policy".<br>3. After "Save Updates" a success message is shown.<br>4. The bar shows "All changes saved".<br>5. After reloading the page both new values are still there. | Total annual days: "22" | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.html` |
| TC-11 | EXCP-SCHED-DIRTY-006 | Verify Save is refused when a setting is invalid | Edge | - | 1. In "Rules" add a rule with the scope "Months" and select no month.<br>2. Click "Save Updates". | 1. An error message asks to fix the errors.<br>2. The reason is listed above the form.<br>3. The label "Unsaved changes" is still shown.<br>4. Nothing is saved. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |

### Leaving the page

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-12 | EXCP-SCHED-LEAVE-001 | Verify leaving to another page asks first when there are unsaved changes | Main | An edit has been made and not saved. | 1. Click "My requests" in the main sidebar. | 1. A message "Unsaved changes detected" appears.<br>2. It offers "Save and leave", "Leave without saving" and "Stay on page".<br>3. The page has not changed yet. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts`, `src/app/features/admin-leader/admin/admin.routes.ts` |
| TC-13 | EXCP-SCHED-LEAVE-002 | Verify "Stay on page" keeps the user and the edits | Main | The message from the previous case is shown. | 1. Click "Stay on page". | 1. The message closes.<br>2. The user is still on the work schedule page.<br>3. The edit and the label "Unsaved changes" are still there. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-14 | EXCP-SCHED-LEAVE-003 | Verify "Leave without saving" leaves and drops the edits | Main | The message is shown again. | 1. Click "Leave without saving".<br>2. Open the work schedule page again. | 1. The "My requests" page opens.<br>2. When the work schedule page is opened again the old saved value is shown, not the edit. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-15 | EXCP-SCHED-LEAVE-004 | Verify "Save and leave" saves and then leaves | Main | An edit has been made and not saved. | 1. Click "My requests" in the main sidebar.<br>2. Click "Save and leave". | 1. The "My requests" page opens.<br>2. When the work schedule page is opened again the new value is shown.<br>3. No extra success message blocks the screen. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-16 | EXCP-SCHED-LEAVE-005 | Verify "Save and leave" stays on the page when saving fails | Edge | An invalid setting exists as in the previous validation case. | 1. Click "My requests" in the main sidebar.<br>2. Click "Save and leave". | 1. An error message is shown.<br>2. The user stays on the work schedule page.<br>3. The edits are still there. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-17 | EXCP-SCHED-LEAVE-006 | Verify leaving a page with no changes does not ask | Main | The page shows "All changes saved". | 1. Click "My requests" in the main sidebar. | The "My requests" page opens with no confirmation. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-18 | EXCP-SCHED-LEAVE-007 | Verify refreshing or closing the tab with unsaved changes shows the browser warning | Main | An edit has been made and not saved. | 1. Press the browser refresh button.<br>2. Repeat and try to close the tab. | 1. The browser shows its own "leave site" warning each time.<br>2. Choosing to stay keeps the page and the edit. | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-19 | EXCP-SCHED-LEAVE-008 | Verify Reload asks before dropping unsaved changes | Main | An edit has been made and not saved. | 1. Open the side menu and click "Reload".<br>2. Click "Cancel".<br>3. Click "Reload" again and click "Discard and reload". | 1. A message "Discard unsaved changes?" appears.<br>2. After "Cancel" the edit is still there.<br>3. After "Discard and reload" the saved values are shown.<br>4. The bar shows "All changes saved". | - | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
| TC-20 | EXCP-SCHED-LEAVE-009 | Verify adding a public holiday marks the page as unsaved | Edge | The "Holidays" section is open. | 1. Add a public holiday named "Test day" for "10" "October".<br>2. Look at the top bar. | 1. The holiday appears in the list.<br>2. The label "Unsaved changes" is shown until "Save Updates" is clicked. | Month: "October"<br>Day: "10"<br>English name: "Test day"<br>Arabic name: "يوم تجريبي" | `src/app/features/admin-leader/admin/components/system-work-schedule/system-work-schedule.component.ts` |
