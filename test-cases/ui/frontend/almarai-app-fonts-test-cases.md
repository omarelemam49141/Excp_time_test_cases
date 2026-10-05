# Local Almarai app fonts — Frontend Test Cases

## Metadata

- Project: `excp-time`
- Feature: `ui`
- Layer: `frontend`
- Routes: `Any authenticated or public shell page (for example **"/login"** or **"/attendance/working-time"**).`
- APIs: -
- Related code: `src/styles/_variables.scss`, `src/styles.scss`
- Related docs: `docs/frontend/technical/almarai-app-fonts.md`

## Scope

- Local **Almarai** `.ttf` files under **`src/assets/fonts`** replace removed **AvenirArabic** files.
- **`Cfont-*`** family names remain; they map to Almarai weights.
- Arabic **`body`** uses **`"Almarai"`** at weight **400**; English **`body`** uses **`Cfont-Regular`**.

## Test pages

- Any page that renders the app shell (for example **"/login"** or **"/attendance/working-time"**).

## Test scenarios

- Arabic UI loads Almarai from local assets for body text.
- English UI loads Cfont-Regular (Almarai Regular) for body text.
- Heavy and black utility classes still show distinct bolder weights.
- No AvenirArabic font files are requested over the network.

## Test cases

### Font loading and language

| ID | Key | Case | Type | Preconditions | Steps | Expected | Related code |
|----|-----|------|------|---------------|-------|----------|--------------|
| TC-01 | EXCP-UI-FONTS-001 | Verify Arabic body text uses local Almarai Regular | Main | App is open. | 1. Switch the app language to Arabic.<br>2. Open developer tools **"Elements"**.<br>3. Select the **"body"** element.<br>4. In **"Computed"**, check **"font-family"** and **"font-weight"**. | 1. **"font-family"** lists **"Almarai"**.<br>2. **"font-weight"** is **400**. | `src/styles.scss` |
| TC-02 | EXCP-UI-FONTS-002 | Verify English body text uses Cfont-Regular | Main | App is open. | 1. Switch the app language to English.<br>2. Inspect **"body"** computed styles. | 1. **"font-family"** includes **"Cfont-Regular"**.<br>2. Body text renders with the regular (400) Almarai face, not a missing or fallback-only font. | `src/styles.scss` |
| TC-03 | EXCP-UI-FONTS-003 | Verify heavy and black utility classes use bolder Almarai weights | Main | A page shows headings or labels with classes **".f-w-heavy"** or **".f-w-black"** (for example navbar or section titles). | 1. Open Arabic or English UI.<br>2. Inspect an element with **".f-w-heavy"**.<br>3. Inspect an element with **".f-w-black"** if present. | 1. **".f-w-heavy"** uses **"Cfont-Heavy"** (Bold, 700).<br>2. **".f-w-black"** uses **"Cfont-Black"** (ExtraBold, 800).<br>3. Heavy/black text is visibly bolder than body text. | `src/styles.scss` |
| TC-04 | EXCP-UI-FONTS-004 | Verify no AvenirArabic font is loaded from the network | Main | App shell loaded after a hard refresh. | 1. Open developer tools **"Network"** tab.<br>2. Filter by **"font"** or search **"Avenir"** and **"Almarai"**.<br>3. Reload the page. | 1. One or more **"Almarai-*.ttf"** requests succeed from **`/assets/fonts/`**.<br>2. No request URL contains **"AvenirArabic"** or **"Avenir"**. | `src/styles/_variables.scss`, `src/styles.scss` |
