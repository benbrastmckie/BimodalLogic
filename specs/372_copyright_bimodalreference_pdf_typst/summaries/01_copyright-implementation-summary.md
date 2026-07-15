# Implementation Summary: Task #372

- **Task**: 372 - Ensure Theories/Bimodal/BimodalReference.pdf and its source Typst file are
  appropriately copyrighted
- **Status**: COMPLETED
- **Plan**: `specs/372_copyright_bimodalreference_pdf_typst/plans/01_copyright-implementation.md`
- **Phases Completed**: 2/2

## What Was Done

### Phase 1: Add copyright notices to Typst source

Added two copyright notices to `Theories/Bimodal/typst/BimodalReference.typ`:

1. A `//` comment header immediately after the existing `:1-8` header block (now at `:10-11`):
   ```
   // Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
   // Bimodal TM Logic: A Reference Manual.
   ```
2. A visible title-page line after the date line (now at `:109-110`):
   ```
   #v(0.3cm)
   #text(size: 9pt)[© 2026 Benjamin Brast-McKie. All rights reserved.]
   ```

Both notices hardcode the year `2026` (not derived from `datetime.today()`), per the fixed
"all rights reserved" decision. No open/reuse license (CC BY, GPL, etc.) was introduced.
`template.typ` was left unchanged — the plan's optional pointer comment was not added since it
provided no meaningful benefit for this minimal-risk task.

### Phase 2: Rebuild the PDF and verify

- Compiled `BimodalReference.typ` with `typst 0.14.2` — exit 0, no errors, no missing-glyph
  warning for `©` (only two pre-existing, unrelated font-family warnings from the `thmbox`
  package).
- Copied the build output to the git-tracked `Theories/Bimodal/BimodalReference.pdf`
  (mtime/size changed, confirming a fresh rebuild).
- Verified with `pdftotext` that the title page of the rebuilt PDF renders "© 2026 Benjamin
  Brast-McKie. All rights reserved." exactly.

## Verification

- `grep -c -i "all rights reserved" Theories/Bimodal/typst/BimodalReference.typ` -> 2 matches.
- `typst compile` exit 0.
- `pdftotext` extraction of the rebuilt PDF's title page contains the exact copyright line.
- `git status` shows `Theories/Bimodal/typst/BimodalReference.typ` (committed in the Phase 1
  commit) and `Theories/Bimodal/BimodalReference.pdf` (committed in this phase's commit) as the
  only source/PDF files touched; `build/BimodalReference.pdf` remains gitignored/untracked.

## Plan Deviations

- None (implementation followed plan).

## Files Modified

- `Theories/Bimodal/typst/BimodalReference.typ` - copyright comment header + visible
  title-page notice.
- `Theories/Bimodal/BimodalReference.pdf` - regenerated PDF carrying the visible copyright
  line.
