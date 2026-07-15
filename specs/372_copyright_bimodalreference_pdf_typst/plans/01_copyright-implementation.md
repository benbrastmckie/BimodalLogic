# Implementation Plan: Task #372

- **Task**: 372 - Ensure Theories/Bimodal/BimodalReference.pdf and its source Typst file are appropriately copyrighted
- **Status**: [IMPLEMENTING]
- **Effort**: 1 hour
- **Dependencies**: None
- **Research Inputs**: specs/372_copyright_bimodalreference_pdf_typst/reports/01_copyright-research.md
- **Artifacts**: plans/01_copyright-implementation.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Add an "All rights reserved" copyright notice to the Bimodal reference manual in two
complementary places: a `//` comment header in the git-tracked Typst source
`Theories/Bimodal/typst/BimodalReference.typ`, and a visible copyright line on the rendered
title page so the notice propagates into the regenerated PDF. Then rebuild the PDF from source
and copy it to the git-tracked location `Theories/Bimodal/BimodalReference.pdf`. The notice is a
plain all-rights-reserved copyright by Benjamin Brast-McKie, dated 2026 — no reuse license
(this decision is fixed; do not plan for CC BY, GPL, or any open license). Definition of done:
the source carries both notices and a freshly rebuilt PDF visibly shows the copyright line.

### Research Integration

Key findings from `reports/01_copyright-research.md` integrated into this plan:
- Canonical source entry point is `Theories/Bimodal/typst/BimodalReference.typ` (git-tracked);
  its `template.typ`/`chapters/`/`notation/` includes are pulled in via `#include`/`#import` and
  are not standalone-compilable, so they do NOT each need their own copyright header.
- No copyright/license text exists anywhere in the `.typ` tree today — this is a net-new
  addition, not an extension of an existing convention.
- Existing source header is a plain `//` comment block at `BimodalReference.typ:1-8`; the new
  notice should follow the same `//` style, placed immediately after it.
- Title page spans `BimodalReference.typ:89-120`; author name block is at `:102-104`, the date
  line is at `:106`. A small visible copyright line placed just after the date line is the
  least-disruptive placement (no interaction with existing page-numbering footer).
- Author name to use: **Benjamin Brast-McKie** (matches `#set document(author:)` at `:26`).
- The git-tracked PDF is a build artifact; it must be regenerated from source, never hand-edited.
  Rebuild is manual (no Makefile/CI). Local `typst 0.14.2` is available.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted for this task (roadmap flag not set).

## Goals & Non-Goals

**Goals**:
- Add a plain all-rights-reserved copyright comment header to the top of the source
  `BimodalReference.typ`, naming the work and the author, dated 2026.
- Add a visible "© 2026 Benjamin Brast-McKie. All rights reserved." line to the rendered title
  page so the notice reaches PDF-only readers.
- Rebuild the PDF from source and update the git-tracked `Theories/Bimodal/BimodalReference.pdf`.
- Verify the notice appears in both the source and the rebuilt PDF.

**Non-Goals**:
- No open/reuse license (CC BY, CC BY-SA, CC BY-NC-ND, GPL) — decision is fixed on
  "all rights reserved".
- Do NOT modify the repo-root `LICENSE` file or its 2025 year (out of scope; flagged in research
  only).
- Do NOT add per-file headers to `template.typ`, chapter, or notation includes (a single optional
  one-line pointer comment in `template.typ` is permitted but not required).
- Do NOT hand-edit the PDF binary; it is regenerated from source.
- Do NOT change the running page-number footer or introduce a per-page copyright footer.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Visible line disrupts title-page layout/spacing | L | M | Implementer reads `:89-120` before editing; use a small `#text(size: 9pt)` line after the date line (`:106`) with a modest `#v()` spacer, matching existing title-page idiom |
| `©` glyph not rendered by document fonts | L | L | Prefer the literal `©` (Typst/default fonts support it); fall back to `Copyright (c)` text form if compile warns of a missing glyph |
| Rebuilt PDF not copied to git-tracked path | M | L | Explicit `cp build/BimodalReference.pdf ../BimodalReference.pdf` step plus verification that the tracked file's mtime/size changed |
| Hardcoded year drifts in future rebuilds | L | L | Hardcode `2026` literally in both notices (do not derive from `datetime.today()`), per research recommendation |
| typst binary or build dir issues | M | L | Confirm `typst --version` and that `build/` exists (create if missing) before compiling |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |

Phases within the same wave can execute in parallel.

### Phase 1: Add copyright notices to Typst source [COMPLETED]

**Goal**: Insert the source-comment copyright header and the visible title-page copyright line
into `Theories/Bimodal/typst/BimodalReference.typ`, so both the source and the eventual render
carry an all-rights-reserved notice.

**Tasks**:
- [ ] Read `Theories/Bimodal/typst/BimodalReference.typ` lines 1-120 to confirm current header
      (`:1-8`), `#set document` (`:24-27`), and title-page structure (`:89-120`, author at
      `:102-104`, date line at `:106`) before editing.
- [ ] Add a `//` comment block immediately after the existing header block (after line 8), e.g.:
      ```typst
      // Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
      // Bimodal TM Logic: A Reference Manual.
      ```
      Keep it minimal, matching the file's existing `//` comment style.
- [ ] Add a small visible copyright line to the title page just after the date line (`:106`),
      inside the title-page block, e.g.:
      ```typst
      #v(0.3cm)
      #text(size: 9pt)[© 2026 Benjamin Brast-McKie. All rights reserved.]
      ```
      Choose the least-disruptive spacing consistent with the surrounding title-page layout the
      implementer reads first.
- [ ] (Optional, low-cost) Add a one-line pointer comment to `template.typ` only if trivially
      safe: `// Part of BimodalReference.typ; see that file for copyright.` Skip if it risks any
      layout/compile change.
- [ ] Confirm the year is hardcoded as `2026` in both notices (not derived from
      `datetime.today()`).

**Timing**: 25 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` - add source comment header (after `:8`) and
  visible title-page copyright line (after `:106`)
- `Theories/Bimodal/typst/template.typ` - (optional) single pointer comment only

**Verification**:
- `grep -n -i "all rights reserved" Theories/Bimodal/typst/BimodalReference.typ` returns the
  source-comment line and the title-page line (2 matches).
- The source-comment block sits immediately after the existing `:1-8` header and uses `//` style.
- The visible line is inside the title-page block near the date line, using `#text(...)`.

---

### Phase 2: Rebuild the PDF and verify [COMPLETED]

**Goal**: Regenerate the PDF from the updated source, publish it to the git-tracked location, and
verify the copyright notice is present in both source and the compiled PDF.

**Tasks**:
- [ ] Confirm `typst --version` (expect `typst 0.14.2` or compatible) and that
      `Theories/Bimodal/typst/build/` exists (create it if missing).
- [ ] Compile from source:
      ```bash
      cd Theories/Bimodal/typst
      typst compile BimodalReference.typ build/BimodalReference.pdf
      ```
      Resolve any compile error/warning (e.g., missing-glyph warning on `©` -> fall back to
      `Copyright (c)` text form) before proceeding.
- [ ] Copy the build output to the git-tracked artifact:
      ```bash
      cp build/BimodalReference.pdf ../BimodalReference.pdf
      ```
- [ ] Verify the visible notice is in the rendered PDF: extract text from the title page (e.g.
      `pdftotext -f 1 -l 2 Theories/Bimodal/BimodalReference.pdf - | grep -i "all rights reserved"`)
      or open the first page; confirm the copyright line renders.
- [ ] Confirm `git status` shows `Theories/Bimodal/BimodalReference.pdf` and
      `Theories/Bimodal/typst/BimodalReference.typ` as modified (the `build/` copy is gitignored
      and expected to be untracked).

**Timing**: 20 minutes

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/typst/build/BimodalReference.pdf` - build output (gitignored)
- `Theories/Bimodal/BimodalReference.pdf` - git-tracked published PDF (overwritten via copy)

**Verification**:
- The `typst compile` command exits 0 with no unresolved errors.
- `Theories/Bimodal/BimodalReference.pdf` mtime/size changed from the pre-build state.
- Title-page text extraction from the tracked PDF contains "All rights reserved".
- `git status` lists the tracked `.typ` and `.pdf` as the intended modified files.

## Testing & Validation

- [x] `grep -c -i "all rights reserved" Theories/Bimodal/typst/BimodalReference.typ` >= 2
      (source header + visible line).
- [x] `typst compile BimodalReference.typ build/BimodalReference.pdf` completes without error.
- [x] Title-page text of the regenerated `Theories/Bimodal/BimodalReference.pdf` contains
      "© 2026 Benjamin Brast-McKie. All rights reserved." (or the `Copyright (c)` fallback form).
- [x] Author name in both notices reads exactly "Benjamin Brast-McKie".
- [x] Year is 2026 (hardcoded) in both notices.
- [x] No open-license text (CC/GPL) was introduced.

## Artifacts & Outputs

- `Theories/Bimodal/typst/BimodalReference.typ` - source with copyright comment header and
  visible title-page notice.
- `Theories/Bimodal/BimodalReference.pdf` - regenerated PDF carrying the visible copyright line.
- `specs/372_copyright_bimodalreference_pdf_typst/plans/01_copyright-implementation.md` - this plan.
- `specs/372_copyright_bimodalreference_pdf_typst/summaries/01_copyright-implementation-summary.md`
  - implementation summary (produced by /implement).

## Rollback/Contingency

- Both changes are localized and reversible via `git checkout -- Theories/Bimodal/typst/BimodalReference.typ`
  and `git checkout -- Theories/Bimodal/BimodalReference.pdf` (only if the working tree is
  otherwise clean or after snapshotting per git-workflow rules).
- If the `©` glyph fails to render, revert to the `Copyright (c) 2026 Benjamin Brast-McKie.
  All rights reserved.` text form in the title-page line and rebuild.
- If the title-page layout is disrupted, remove the `#v()` spacer / reduce font size, or relocate
  the line directly beneath the author block (`:104`), and rebuild.
- The gitignored `build/BimodalReference.pdf` can be regenerated at any time from source; no
  manual cleanup needed.
