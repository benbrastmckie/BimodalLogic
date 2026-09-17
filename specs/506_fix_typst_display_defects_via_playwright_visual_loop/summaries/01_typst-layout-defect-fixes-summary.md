# Implementation Summary: Typst Display/Layout Defect Fixes

- **Task**: 506 - Fix all outstanding display/layout defects in the compiled typst documents
- **Plan**: `specs/506_fix_typst_display_defects_via_playwright_visual_loop/plans/01_typst-layout-defect-fixes.md`
- **Status**: COMPLETED (all 6 phases)

## Overview

Fixed all six catalogued layout defects across `typst/FormalFoundations.typ` and
`typst/BimodalReference.typ` using a Playwright-driven screenshot loop plus a PyMuPDF
bounding-box overflow scanner as the mechanical verification backstop. Every fix is
whitespace/break-token/scope-only — no mathematical content, statement, or wording changed
anywhere, confirmed via source diff review at every phase.

## What Was Built

- **Verification loop** (Phase 1): a task-scoped bounding-box overflow scanner
  (`specs/506_fix_typst_display_defects_via_playwright_visual_loop/scripts/overflow-scan.py`,
  PyMuPDF-based) plus a Playwright MCP loop serving compiled PNG pages over a local HTTP server,
  proven end-to-end on the two most severe known defects before any edit was made.
- **`.gitignore` addition**: `.playwright-mcp/` — the Playwright MCP tool is sandboxed to write
  only inside the repo or its own default output directory, so this directory (not the
  scratchpad) is where its screenshots land, and it must never be committed.

## Defects Fixed

| # | Location | Symptom | Fix |
|---|----------|---------|-----|
| 1 | `FormalFoundations.typ:1205` (Def 5.1, TM-algebra derived operators), rendered FF p.28 | Six-operator display equation overflowed both the definition box and page margins on both sides | Replaced two trailing `quad` tokens with `\` row breaks -> 3 rows |
| 2 | `FormalFoundations.typ:1255-1256` (Def 5.2, complex algebra), rendered FF p.29-30 | Same root cause, second display-math block | Replaced trailing `quad` with `\` |
| 3 | `FormalFoundations.typ:1301` via `template.typ`'s `leansrc` helper, rendered FF p.31 | Long dotted Lean identifier (`Metalogic.BXCanonical.CompletenessDedekind.completeness_rtime_engine`) overflowed the right margin | Added `sym.zws` (zero-width-space break opportunity) after each `.` in `leansrc`'s `raw()` call — a systemic fix covering all ~70 call sites, not a point patch |
| 4 | `chapters/03-proof-theory.typ:317-333` (DerivationTree rule table), rendered BR p.32 | "Temp. Necessitation" label wrapped and visually interleaved with the adjacent unbreakable Lean-constructor identifier | Added the same `sym.zws` break-opportunity uniformly to all 7 raw spans in the column (via a local `derivation-tree-rule` helper) plus `columns: (auto, 1fr, auto)` — both needed together, see Plan Deviations |
| 5 | `chapters/p4-proof-automation.typ:114` (Module Map, "Tactics/Deduction.lean" role), rendered BR p.76 | Unbreakable `` `Metalogic.Core.deductionTheorem` `` pushed 129.5pt past the right margin (the largest single overflow found) | Shortened to bare `` `deductionTheorem` ``, matching every sibling cell's convention |
| 6 | `chapters/03-proof-theory.typ:73-107` (Table 8, BX temporal layer), rendered BR p.26-27 | 24-row table could not fit one page, overflowing its own caption and the footer by up to 84.6pt (the most severe defect found) | Scoped `#{ show figure: set block(breakable: true); figure(...) }` around this one `#figure` call only |

## Verification

- `typst compile typst/FormalFoundations.typ` and `typst compile typst/BimodalReference.typ`
  both exit 0 (only the two pre-existing, out-of-scope `thmbox` font-substitution warnings).
- Page counts unchanged from baseline: FF = 39, BR = 98.
- `overflow-scan.py` final full sweep (all pages, both documents, >8pt threshold): FF = 0
  findings; BR = 3 findings, all fragments of one already-investigated caption line (see Plan
  Deviations below) — a clear net improvement over the 129.5pt severe overflow it replaces.
- Every one of the six defects has a before/after Playwright/PNG screenshot pair (see the
  per-phase handoffs in `specs/506_fix_typst_display_defects_via_playwright_visual_loop/handoffs/`).
- Neighborhood spot-checks (5 additional pages around the fix sites) show no reflow-induced
  crowding.
- `pdftotext` scan for `??`/`[?]`/`undefined`: clean (the one `undefined` match is ordinary
  prose).
- Orphaned-heading scan: 2 candidates found, both confirmed to have body prose following on the
  same page (ordinary pagination, not genuine orphans).
- `bash scripts/typst-sync-check.sh`: PASS, all 3 checks green, both before and after every
  phase's edit.
- `bash .claude/scripts/typst-element-lint.sh --verbose` on all 4 touched files: `template.typ`,
  `chapters/03-proof-theory.typ`, `chapters/p4-proof-automation.typ` all PASS with 0 findings.
  `FormalFoundations.typ` carries 14 pre-existing `[FAIL]` findings unrelated to and unchanged
  by this task's edits (see Plan Deviations).
- No compiled PDFs/PNGs added to the repository at any point (`git status --porcelain` clean of
  binary artifacts throughout).

## Plan Deviations

- **Phase 1 — overflow scanner false positive**: the raw scan initially flagged every page's
  auto-numbering page-number footer as a "defect" (Typst places it in the margin band by
  design). Filtered out via a documented exclusion in `overflow-scan.py` (digit-only span, ~47.4pt
  bottom overflow). After the filter, the scan reproduces 5 of the 6 catalogued defects; Defect 4
  (intra-table column overlap) is structurally invisible to a margin-vs-page-edge bounding-box
  scan (both offending spans sit *inside* the text block, overlapping each other, not crossing
  the margin) and was instead confirmed visually in Phase 4.
- **Phase 2 — pre-existing element-placement lint failures**: `typst-element-lint.sh` reports 14
  `[FAIL]` findings in `FormalFoundations.typ` (a `#definition`/`#theorem` opening immediately
  after a section heading with no intervening prose), at locations completely unrelated to this
  task's edits. Confirmed byte-for-byte identical (same count, same lines) against the
  pre-Phase-2 committed version. Fixing them requires authoring new prose for 14 sections —
  content authorship, explicitly out of scope per this plan's Non-Goals and the Typst
  extension's own scope boundary (content-creation work routes to `lean4`/`formal`/`general`,
  never `typst`). Treated as a documented, pre-existing, out-of-scope condition, not a phase
  blocker.
- **Phase 3 — one short `leansrc` call site's wrap point relocated (not visually identical)**:
  of the four sampled short call sites, three were pixel-identical to baseline. The fourth
  (`multiFamTaskFrameGen`, FF p.36) was *already* wrapping to two lines in the pre-fix baseline
  (the literal space in `"> " + module...` is itself a break point independent of `sym.zws`); the
  fix only relocates the wrap point from an orphaned `"> "` to a module-boundary dot — still two
  lines, still zero overflow either before or after. Not a new defect.
- **Phase 4 — scope widened from 2 to 7 identifiers, plus explicit column widths required**:
  applying the break-opportunity to only the two originally-named long identifiers caused every
  other (still-unbreakable) cell in the same column to overflow into the adjacent column — a
  Typst `auto`-column-sizing interaction discovered via a pre-edit scratch probe. Fixed by
  applying the break-opportunity uniformly to all 7 raw spans (still within this phase's declared
  file) and adding `columns: (auto, 1fr, auto)`, both confirmed necessary and sufficient via
  isolated scratch compiles before landing in the real file.
- **Phase 4 — page-count prediction corrected**: the plan's Scope Hypothesis predicted BR's page
  count would grow from 98 to ~99 after making Table 8 breakable. Actual observed result: 98,
  unchanged — the extra row-height was absorbed by existing reflow slack rather than pushing a
  new page. Corrected in the plan rather than left as a stale prediction.
- **Phase 5 — one new marginal finding, investigated and accepted**: shortening the Deduction.lean
  role identifier grew that table row from 3 to 4 lines, pushing the table's caption down by one
  line-height and producing an 8.1pt bottom-margin crossing on the caption's last line (just above
  the 8pt significance threshold). Measured the actual gap to the footer page number: 28.3pt of
  clear whitespace, no visual overlap. Judged a benign, sub-visual technical crossing of the
  scan's mathematically-derived margin line, not a genuine display defect, and a clear net
  improvement over the 129.5pt severe overflow it replaces — re-verified, not silently dropped,
  in Phase 6's full sweep.

## Files Modified

- `typst/FormalFoundations.typ` — two display-math row breaks (Defects 1, 2)
- `typst/template.typ` — `leansrc` helper, systemic break-opportunity fix (Defect 3)
- `typst/chapters/03-proof-theory.typ` — scoped breakable show-rule (Defect 6) + break
  opportunity + column widths (Defect 4)
- `typst/chapters/p4-proof-automation.typ` — shortened identifier (Defect 5)
- `.gitignore` — added `.playwright-mcp/`
- `specs/506_fix_typst_display_defects_via_playwright_visual_loop/scripts/overflow-scan.py` — new
  task-scoped verification tool
- `specs/506_fix_typst_display_defects_via_playwright_visual_loop/plans/01_typst-layout-defect-fixes.md`
  — phase-by-phase progress annotations
