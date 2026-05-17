# Company structure — employee read-only view (frontend)

## Metadata

- Project: `excp-time`
- Feature: `company-structure`
- Layer: `frontend`
- Routes: `/admin/company-structure`
- APIs: -
- Related code: `src/app/features/admin-leader/admin/components/company-structure`, `src/app/core/guards/core/guards/admin-section.guard.ts`
- Related docs: `docs/frontend/technical/company-structure-employee-view.md`

## Scope

- Route `/admin/company-structure for users who are **not** admin and **not** HR: read-only chart, sidebar entry, optional **Find me** when the signed-in person appears on the chart.
- Same route for **Admin** and **HR**: full edit behavior unchanged; **Find me** when their account matches a node.

## Test pages

- /admin/company-structure

## Test scenarios

- Any signed-in employee opens the chart from the sidebar and sees the org tree without save or per-card edit actions.
- A user who appears on the chart lands with the view scrolled to their card and a short visible emphasis; **Reload** then repeats the jump once after load.
- **Find me** (or Arabic equivalent) scrolls to the same card again with the same short emphasis.
- Users not on the chart do not see **Find me**; empty chart shows the read-only empty message instead of the “add first person” action.
- Admin or HR still sees **Save structure** and all card actions.

## Test cases

### Access and read-only UI

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-ORG-EMPLOYEE-VIEW-001 | Verify a regular employee can open the company structure page from the menu | Main | Test account is signed in.<br>Account is **not** admin and **not** HR.<br>Published chart has at least one person. | 1. Open the main menu.<br>2. Tap **"Company structure"** (or **"الهيكل التنظيمي"** in Arabic). | 1. The address shows **"/admin/company-structure"**.<br>2. The page title area shows **"Company structure"** (or Arabic equivalent).<br>3. The subtitle explains you can search and explore and that only admins and HR can edit.<br>4. Person cards show names and profile images (no blank cards or error messages).<br>5. No **403** or permission error appears in the browser console. | - |
| TC-02 | EXCP-ORG-EMPLOYEE-VIEW-002 | Verify a regular employee does not see save or tree edit controls | Main | Same as TC-01.<br>Chart has several cards. | 1. Stay on **"/admin/company-structure"**.<br>2. Look at the top toolbar.<br>3. Move the pointer over any person card. | No **"Save structure"** button appears.<br>No pencil, add-above, add-below, move, or trash icons appear on cards.<br>No **"Add person (root)"** strip appears under the chart.<br>**"Reload"** is still available. | - |
| TC-03 | EXCP-ORG-EMPLOYEE-VIEW-003 | Verify an empty chart shows the read-only message for a regular employee | Edge | Test account is **not** admin and **not** HR.<br>Environment shows an empty chart (no people). | 1. Open **"/admin/company-structure"**. | A panel shows **"No organization chart yet"** (or Arabic equivalent) and a short hint to contact the admin.<br>No large **"Tap to pick your first teammate"** button appears. | - |

### Find me and highlight

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-04 | EXCP-ORG-EMPLOYEE-VIEW-004 | Verify the chart scrolls to the signed-in user’s card once after load | Main | Test account is **not** admin and **not** HR.<br>The same account appears as one person on the chart (large enough tree that the card is not already centered). | 1. Open **"/admin/company-structure"** and wait until loading finishes.<br>2. Watch the scroll position and the card that represents you. | The view scrolls so your card is near the center.<br>Your card shows a clear emphasis (outline or glow) for a few seconds, then returns to normal. | - |
| TC-05 | EXCP-ORG-EMPLOYEE-VIEW-005 | Verify **Find me** scrolls to the same card again | Main | Same account as TC-04.<br>After load, zoom or scroll away from your card. | 1. Tap **"Find me"** (or **"اعثر على موقعي"**).<br>2. Optionally hover the control to read the tooltip **"Scroll to my position in the chart"** (or Arabic equivalent). | The view scrolls back to your card.<br>The same short emphasis appears on your card. | - |
| TC-06 | EXCP-ORG-EMPLOYEE-VIEW-006 | Verify **Find me** is hidden when the signed-in user is not on the chart | Edge | Test account is **not** on the published chart. | 1. Open **"/admin/company-structure"**. | No **"Find me"** button appears in the toolbar.<br>The chart still loads for browsing and search. | - |

### Admin and HR unchanged

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-07 | EXCP-ORG-EMPLOYEE-VIEW-007 | Verify admin still sees full edit controls | Regression | Test account has admin role.<br>Chart has at least one card. | 1. Open **"/admin/company-structure"**. | **"Save structure"** appears.<br>Hovering a card shows edit, add, move, and remove actions.<br>**"Add person (root)"** appears when applicable.<br>Subtitle matches the playful “build your org” hint for editors, not the read-only line. | - |
