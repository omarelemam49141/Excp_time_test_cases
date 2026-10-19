# Install banner — space under page content — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `platform`
- Layer: `frontend`
- Routes: all signed-in pages
- APIs: -
- Related code: `src/app/core/components/pwa-install-banner/pwa-install-banner.component.ts`, `src/app/app.component.scss`
- Related docs: `docs/frontend/technical/home-page.md`
- Automation (Karma, optional): `src/app/core/components/pwa-install-banner/pwa-install-banner.component.spec.ts`

## Scope

- The fixed "Install ExcpTime" banner must never hide the end of a page: the page reserves room for it while it is showing.

## Test pages

- `/home`
- `/all-attendance`

## Test scenarios

- Scrolling to the bottom of a page leaves the last content clear of the banner.
- Dismissing the banner gives the space back.

## Test cases

### Reserved space

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-PWA-BANNER-001 | Verify the last content of a page can be scrolled clear of the install banner. | Main | A browser that shows the install banner (HTTPS, not installed). Widths 1366px and 390px. | 1. Open `/home` and scroll to the bottom.<br>2. Repeat on `/all-attendance`. | 1. The last card or button is fully visible above the banner.<br>2. The extra space equals the banner height plus a small margin on phone and laptop. | `src/app/core/components/pwa-install-banner/pwa-install-banner.component.ts`, `src/app/app.component.scss` |
| TC-02 | EXCP-PWA-BANNER-002 | Verify dismissing the banner removes the reserved space. | Edge | The banner is visible. | 1. Press the close (×) button on the banner.<br>2. Scroll to the bottom of the page. | 1. The banner disappears.<br>2. The page no longer has the extra space under its content. | `src/app/core/components/pwa-install-banner/pwa-install-banner.component.ts` |
