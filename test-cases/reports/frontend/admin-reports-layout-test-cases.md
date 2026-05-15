# Admin reports layout — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `reports`
- Layer: `frontend`
- Routes: `/admin/reports/bulk-employee-hours-report`, `/admin/reports/employee-hours-report`, `/admin/reports/users-attendance-report`, `/admin/reports/budget-report`, `/admin/reports/payroll-report`
- APIs: -
- Related code: _Map concrete files during feature updates._
- Related docs: _See the project documentation indexes for the owning feature._

## Scope

This document covers the shared admin reports shell at `/admin/reports/*`: the top horizontal strip of report shortcuts (icons and labels) that appears above every report tab, and how that strip behaves when the page scrolls vertically.

## Test pages

- `/admin/reports/bulk-employee-hours-report`
- `/admin/reports/employee-hours-report`
- `/admin/reports/users-attendance-report`
- `/admin/reports/budget-report`
- `/admin/reports/payroll-report` (if reachable for the tester account)

## Test scenarios

- Verify the top report shortcut strip scrolls away with the page on long report screens so it does not stay covering the top of the window while reading lower content.

## Test cases

### Report shell scrolling

| ID | Key | Case | Type | Preconditions | Steps | Expected | Test data |
|----|-----|------|------|---------------|-------|----------|-----------|
| TC-01 | EXCP-REPORT-ADMIN-LAYOUT-001 | Verify the top report shortcut strip scrolls with the page on a long report screen | Main | Admin user is logged in; chosen report page shows enough content to scroll vertically. | 1. Open `/admin/reports/bulk-employee-hours-report`.<br>2. Scroll the window downward until the main page content moves up.<br>3. Observe whether the row of report shortcuts (for example `"Bulk Employee Hours Report" and the other report labels) stays glued to the top of the window or moves off screen with the scroll. | 1. The report shortcut row moves upward and eventually leaves the visible area together with the upper part of the page.<br>2. The row does not stay pinned at the top edge of the window while lower content slides underneath it. | - |
