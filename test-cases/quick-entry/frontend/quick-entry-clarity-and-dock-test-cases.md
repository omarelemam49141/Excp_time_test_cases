# Quick Entry clarity pass and floating dock test cases (frontend)

## Metadata

- Project: `excp-time`
- Feature: `quick-entry`
- Layer: `frontend`
- Routes: `/attendance/quick-entry`
- APIs: `POST /api/attendance-record/Get-bulk-details-in-range`
- Related code: `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts`
- Related docs: `docs/frontend/technical/quick-entry-clarity-and-floating-dock.md`

## Scope

Validate the plain-language header, the "how this page works" guide, the "More tools" section, the unsaved/saved status line, the labelled day fields, the single floating dock (no overlap with the install banner), and the inline load-error card with Retry.

## Test pages

- `/attendance/quick-entry`

## Test scenarios

- A new user understands the page from the title, subtitle, and three-step guide.
- The header shows two actions (Reload, Save changes); rare tools sit inside a collapsed "More tools" section.
- The status line always says whether anything is unsaved.
- Start, End, and Work place have visible labels and line up across rows in English and Arabic.
- The floating panels stack in one place and never cover each other or the install banner.
- A rate-limited or failed load shows one clear card with a Retry button, not stacked popups.

## Test cases

### Header, guide, and tools

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-01 | EXCP-QE-CLARITY-001 | Plain title and subtitle | Main | Logged in as an employee | 1. Open `/attendance/quick-entry` in English, then switch to Arabic | 1. Title reads "Edit attendance & overtime" in English<br>2. Title reads "تعديل الحضور والوقت الإضافي" in Arabic<br>3. A one-sentence subtitle sits under the title in both languages | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/assets/i18n/en.json`, `src/assets/i18n/ar.json` |
| TC-02 | EXCP-QE-CLARITY-002 | Guide shows once and can be reopened | Main | Browser storage cleared | 1. Open the page 2. Read the three numbered steps 3. Click "Got it, hide" 4. Reload the page 5. Click "How does this page work?" | 1. The three numbered steps are visible on the first visit<br>2. After "Got it, hide" the guide stays hidden when the page is reloaded<br>3. "How does this page work?" brings the three steps back | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-03 | EXCP-QE-CLARITY-003 | Header keeps two actions | Main | Logged in | 1. Open the page and look at the top-right buttons | 1. Only "Reload" and "Save changes" appear in the header<br>2. The report link, schedule correction, correction history, and copy/import are not in the header | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html` |
| TC-04 | EXCP-QE-CLARITY-004 | More tools holds the rare actions with descriptions | Main | Logged in | 1. Click "More tools" 2. Read each row | 1. "More tools" expands to four rows: report, schedule correction, history, copy period data<br>2. Each row has a one-line description and an action button<br>3. Clicking "More tools" again collapses the section | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |
| TC-05 | EXCP-QE-CLARITY-005 | Schedule correction waits for a save | Edge | Period loaded | 1. Change a start time without saving 2. Open "More tools" | 1. The Apply button is disabled while there are unsaved edits<br>2. The row tells the user to save their edits first<br>3. After saving, the Apply button is enabled again | A start time on any working day | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html` |
| TC-06 | EXCP-QE-CLARITY-006 | Status line reflects unsaved work | Main | Period loaded | 1. Look under the totals 2. Change a start time 3. Click "Save changes" | 1. Before any edit the line says "All changes are saved."<br>2. After an edit it says there are unsaved edits on 1 day(s)<br>3. After saving it returns to "All changes are saved." | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |

### Day cards

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-07 | EXCP-QE-CLARITY-007 | Labelled, aligned day fields | Main | Month with weekdays and weekend days | 1. Scroll through the day list in English 2. Repeat in Arabic | 1. Every row shows visible "Start", "End", and "Work place" labels<br>2. The three fields line up in the same columns on weekdays and rest days<br>3. The layout holds in both English and Arabic | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |
| TC-08 | EXCP-QE-CLARITY-008 | Unsaved badge wording | Main | Period loaded | 1. Change an end time | 1. The edited day shows an "Unsaved" ("غير محفوظ") badge<br>2. The edited day card is highlighted | - | `src/assets/i18n/en.json`, `src/assets/i18n/ar.json` |
| TC-09 | EXCP-QE-CLARITY-009 | Mobile day card is readable | Edge | 390 px wide screen | 1. Open the page on a phone-width window 2. Look at one weekday card | 1. Date, labelled fields, badges, and both net chips fit with no horizontal scroll<br>2. Reload and Save share one full-width row | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |

### Floating dock

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-10 | EXCP-QE-CLARITY-010 | Dock stacks without overlap (English) | Main | Install banner visible, days eligible for leave, a day with a problem, one unsaved edit | 1. Open the page on a desktop window in English 2. Look at the bottom of the screen | 1. Walk-through, leave navigator, problem navigator, and Save changes sit in one column at the bottom-right in that order<br>2. No floating panel covers another<br>3. The install banner stays at the bottom-left | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |
| TC-11 | EXCP-QE-CLARITY-011 | Dock mirrors in Arabic | Main | Same as TC-10 | 1. Switch to Arabic | 1. The dock moves to the bottom-left<br>2. The install banner moves to the bottom-right<br>3. Nothing overlaps | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |
| TC-12 | EXCP-QE-CLARITY-012 | Dock clears the install banner on mobile | Edge | 390 px wide screen, install banner visible | 1. Open the page 2. Make an unsaved edit | 1. The dock ends above the install banner<br>2. The walk-through button is hidden while other panels show<br>3. The last day card can be scrolled fully into view | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.scss` |

### Load errors

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-13 | EXCP-QE-CLARITY-013 | Rate-limited load shows an inline card | Negative | Server (or a browser tool) returns HTTP 429 for the bulk details request | 1. Open the page | 1. One card reads "Too many requests in a short time"<br>2. The card shows a wait-and-retry hint and a Retry button<br>3. No popup opens | HTTP 429 on `Get-bulk-details-in-range` | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html`, `src/app/core/services/attendance.service.ts` |
| TC-14 | EXCP-QE-CLARITY-014 | Retry recovers the page | Main | TC-13 state, then the server answers normally | 1. Click Retry | 1. The error card disappears<br>2. The day cards load | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-15 | EXCP-QE-CLARITY-015 | Other load failures show one popup only | Negative | Server returns HTTP 500 for the bulk details request | 1. Open the page | 1. One translated "couldn't load data" popup appears<br>2. No second generic popup stacks on it<br>3. The card with Retry is visible behind the popup | HTTP 500 on `Get-bulk-details-in-range` | `src/app/core/services/attendance.service.ts`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |

### Day order

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data | Related code |
|----|-----|------|------|---------------|-------|----------|-----------|--------------|
| TC-16 | EXCP-QE-CLARITY-016 | Days are listed newest first | Main | A month with at least 10 days loaded | 1. Open `/attendance/quick-entry` 2. Read the dates from the top of the list to the bottom | 1. The first card is the latest day of the period<br>2. Dates decrease down the page<br>3. The last card is the first day of the period | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts`, `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.html` |
| TC-17 | EXCP-QE-CLARITY-017 | Jump buttons still start from day 1 | Main | At least two days eligible for leave or with problems | 1. Click "Jump to next" on the leave (or problem) panel twice | 1. The first jump opens the earliest matching day of the period<br>2. The second jump opens the next later date<br>3. The page scrolls up the list between jumps, while the list itself stays newest first | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-18 | EXCP-QE-CLARITY-018 | Guided tour stays oldest to newest | Edge | Period loaded | 1. Click "Walk through your attendance" | 1. Day cards appear oldest first<br>2. Totals build up day by day as before | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-19 | EXCP-QE-CLARITY-019 | Opening the page lands on the newest day | Main | Period loaded | 1. Click "Quick entry" in the sidebar | 1. The page opens at the top<br>2. The first visible card is the latest day of the period<br>3. The page does not jump to day 1 | - | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-20 | EXCP-QE-CLARITY-020 | Range link lands on the newest flagged day | Main | A leader-flagged attendance-fix notification whose link has `from` and `to` but no `focusDate` | 1. Click the notification | 1. The period switches to the range<br>2. The flagged days are expanded<br>3. The view stays on the newest day of the range at the top, not the first day | Link `?from=2026-10-01&to=2026-10-12` | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
| TC-21 | EXCP-QE-CLARITY-021 | Explicit focus date still wins | Edge | Notification link with `focusDate` inside the range | 1. Click the notification | 1. The page scrolls to the `focusDate` day<br>2. That day is visible and highlighted | Link `?from=2026-10-01&to=2026-10-12&focusDate=2026-10-05` | `src/app/features/attendance/components/attendance-quick-entry/attendance-quick-entry.component.ts` |
