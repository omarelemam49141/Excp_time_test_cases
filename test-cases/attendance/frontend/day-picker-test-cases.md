# Day picker (shared by Home and My attendance) — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `attendance`
- Layer: `frontend`
- Routes: `/home`, `/all-attendance`
- APIs: -
- Related code: `src/app/core/components/day-picker/day-picker.component.ts`, `src/app/core/components/day-picker/day-picker.component.html`
- Related docs: `docs/frontend/technical/home-page.md`
- Automation (Karma, optional): `src/app/core/components/day-picker/day-picker.component.spec.ts`

## Scope

- The month label, previous / next, jump-to-date calendar and the strip of day chips used on both pages.

## Test pages

- `/home`
- `/all-attendance`

## Test scenarios

- Picking a day, moving by week and jumping to a date behave the same on both pages.
- The chips are keyboard accessible and never allow a future day.
- Today, the selected day and problem days are clearly marked.

## Test cases

### Using the picker

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-ATT-PICKER-001 | Verify picking a day selects it and loads that day on both pages. | Main | Signed in; a few past days in the strip. | 1. Open `/home` and press a past day chip.<br>2. Repeat on `/all-attendance`. | 1. The chip shows a selection ring and `aria-pressed` is true.<br>2. Home shows "Summary for <date>"; My attendance shows "Showing <date>" and the day tabs. | `src/app/core/components/day-picker/day-picker.component.ts`, `src/app/pages/home/home.component.ts`, `src/app/pages/attendance-page/attendance-page.component.ts` |
| TC-02 | EXCP-ATT-PICKER-002 | Verify future days cannot be chosen. | Edge | The strip shows days after today (Home). | 1. Press a future day chip.<br>2. Tab to it with the keyboard. | 1. The chip is dimmed and disabled.<br>2. Nothing is loaded and the selection does not change. | `src/app/core/components/day-picker/day-picker.component.ts`, `src/app/core/components/day-picker/day-picker.component.html` |
| TC-03 | EXCP-ATT-PICKER-003 | Verify previous and next move the week window and the month label follows. | Main | Any month with data. | 1. Press Previous, then Next. | 1. The days shown move by one window and the month label updates when the month changes.<br>2. Previous points to earlier days in both languages (the chevron mirrors in Arabic). | `src/app/core/components/day-picker/day-picker.component.html` |
| TC-04 | EXCP-ATT-PICKER-004 | Verify the jump-to-date calendar opens from the month label and loads the chosen date. | Main | Signed in. | 1. Press the month label.<br>2. Choose a past date in the calendar. | 1. A calendar opens with future dates disabled.<br>2. The strip re-centres on the chosen date and that day is selected and loaded. | `src/app/core/components/day-picker/day-picker.component.ts` |
| TC-05 | EXCP-ATT-PICKER-005 | Verify today, a problem day and the keyboard are handled. | Edge | A month with a missing day and a long strip. | 1. Look at today's chip and the missing day's chip.<br>2. Focus the strip and press the arrow keys; use the mouse wheel over it. | 1. Today is the deep-teal chip with white text.<br>2. A day without a record has a red dot (and a text alternative for screen readers).<br>3. Arrow keys and the wheel scroll the strip sideways. | `src/app/core/components/day-picker/day-picker.component.scss`, `src/app/core/components/day-picker/day-picker.component.ts` |
