# Implementation Plan: Typst Display/Layout Defect Fixes

- **Task**: 506 - Fix all outstanding display/layout defects in the compiled typst documents
- **Status**: [IMPLEMENTING]
- **Effort**: 4.75 hours
- **Dependencies**: 586 (proof-automation chapter rewrite) — COMPLETED and archived; ordering
  note satisfied, this plan targets the post-586 tree
- **Research Inputs**: specs/506_fix_typst_display_defects_via_playwright_visual_loop/reports/01_typst-display-defects-catalog.md
- **Artifacts**: plans/01_typst-layout-defect-fixes.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: typst
- **Lean Intent**: false

## Overview

The research phase catalogued exactly six layout defects across the two compiled Typst documents,
each located by rendered page and source line, with every fix technique already compiled and
visually confirmed in an isolated scratch file against this Typst install (0.14.2). This plan
therefore spends no phase re-deriving Typst syntax: it stands up a reproducible screenshot +
bounding-box verification loop once (Phase 1), then applies the six fixes in four
territory-disjoint edit phases (Phases 2-5, one owner file each), and closes with a full
re-sweep of both documents plus the `scripts/typst-sync-check.sh` gate (Phase 6). Every edit is
whitespace, break-opportunity, page-break-eligibility, or column-width behavior — no
mathematical content changes anywhere, per the task's explicit constraint.

### Research Integration

Directly integrated from `reports/01_typst-display-defects-catalog.md`:

- The six defects, their file:line locations, rendered page numbers, and measured overflow
  magnitudes drive the phase decomposition one-for-one (Phase 2 = defects 1+2, Phase 3 =
  defect 3, Phase 4 = defects 6+4, Phase 5 = defect 5).
- The report's two shared root causes (a display-math/table block with no actual break token;
  an unbreakable dotted Lean identifier in `raw`) justify fixing defect 3 **systemically** in
  `typst/template.typ`'s `leansrc` helper rather than point-patching one call site.
- Each fix idiom below is the one the report empirically validated: `\` row breaks for display
  math, `show figure: set block(breakable: true)` scoped to a single `#figure` call, and
  `sym.zws`-after-`"."` break opportunities for dotted identifiers.
- The report's non-findings (no broken cross-references, no citation placeholders, no genuine
  orphaned headings, no significant overflow beyond the six) set Phase 6's acceptance bar: the
  final sweep must find nothing above the report's >8pt significance threshold.
- The report's baseline (`typst-sync-check.sh` PASS, both documents exit 0) is the state Phase 6
  must restore.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied with this dispatch and no roadmap flag is set; ROADMAP.md was not
consulted and is not modified by this plan.

## Goals & Non-Goals

**Goals**:

- Eliminate all six catalogued layout defects so no text, math, or table content overflows the
  declared text block (x in [126.0, 469.3] pt, y in [126.0, 715.9] pt) in either document.
- Close the recurring "unbreakable dotted Lean identifier" defect class at its source
  (`leansrc` helper) rather than at one call site.
- Establish a Playwright-driven screenshot loop plus a reproducible PyMuPDF bounding-box scan so
  each fix is visually confirmed before the next is applied.
- End with both documents compiling at exit 0 and `bash scripts/typst-sync-check.sh` PASS.

**Non-Goals**:

- Changing any mathematical content, statement, notation, or wording of a definition/theorem.
- Fixing the two pre-existing `unknown font family: new computer modern sans` warnings emitted
  by the `thmbox` package (font substitution, unrelated to layout, out of scope).
- Promoting the task-scoped overflow-scan script into the repository's `scripts/` directory or
  wiring it into CI (a separate decision, not this task's scope).
- Re-styling, re-flowing, or otherwise improving pages that carry no catalogued defect.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Phase 4's breakable-figure fix adds a page to BimodalReference, shifting every later page number (including defect 5's "page 76") | M | H | Phase 5 depends on Phase 4 and locates its target by content search (grep the source line, then find the rendered page by text match), never by the pre-fix page number; Phase 6 re-screenshots a neighborhood, not a fixed page index |
| `show figure: set block(breakable: true)` applied too broadly makes every figure in the chapter splittable | M | M | Scope the show-rule block-local around the single `#figure` call at `03-proof-theory.typ:71`, exactly as the research validated; Phase 4 verification explicitly checks that other figures in the same chapter still render atomically |
| The `leansrc` change in `typst/template.typ` is a shared-helper edit affecting ~70 call sites across both documents | M | M | Phase 3 is tiered `interface`: compile BOTH documents and re-screenshot a sample of short call sites (FF lines 160, 987, 1290, 1518) plus the long one (1301) to confirm short cases are visually unchanged (`sym.zws` is invisible and only acts as a break point when a line actually overflows) |
| Phase 5 edits a backticked span that `typst-sync-check.sh` Check 1 (name resolution) validates; bare `deductionTheorem` might not resolve or might need whitelisting | M | L | Phase 5 is tiered `full` and runs `scripts/typst-sync-check.sh` in-phase; `deductionTheorem` is confirmed present in `FormalSystem/Metalogic/Core/MaximalConsistent.lean`. If Check 1 nonetheless fails, fall back to keeping the fully-qualified name and applying the `sym.zws` break-opportunity technique instead of shortening |
| A fix resolves its own defect but pushes content onto a new page and crowds something else | M | L | Phase 6 re-runs the exhaustive bounding-box scan over ALL pages of both documents, not just the six fixed pages, against the report's >8pt significance threshold |
| Playwright MCP loop cannot reach the rendered pages (no server / headless issue) | L | M | Phase 1 stands the loop up and proves it end-to-end before any edit; documented fallback is direct PNG image reads, which the research phase already established are pixel-identical to a browser screenshot of the same PNG |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3, 4 | 1 |
| 3 | 5 | 4 |
| 4 | 6 | 2, 3, 4, 5 |

Phases within the same wave can execute in parallel. Wave 2's three phases are
territory-disjoint by construction: Phase 2 owns `typst/FormalFoundations.typ`, Phase 3 owns
`typst/template.typ`, Phase 4 owns `typst/chapters/03-proof-theory.typ`. No file is written by
more than one phase.

---

### Phase 1: Baseline Capture and Visual Verification Loop [COMPLETED]

**Goal**: Stand up the reproducible fix-recompile-rescreenshot loop and record the pre-fix
baseline, so every later phase has an unambiguous before/after comparison and an exhaustive
mechanical check.

**Tasks**:

- [x] Compile both documents fresh to PDF and confirm exit 0:
      `typst compile typst/FormalFoundations.typ` and `typst compile typst/BimodalReference.typ`
      (note the two expected `thmbox` font warnings; they are out of scope). Both exited 0.
- [x] Render PNG pages for both documents into the session scratchpad (NOT into the repo):
      `typst compile --format png typst/<doc>.typ <scratch>/<doc>-{p}.png`.
- [x] Write the bounding-box overflow scan as a task-scoped script at
      `specs/506_fix_typst_display_defects_via_playwright_visual_loop/scripts/overflow-scan.py`
      (PyMuPDF; already confirmed importable). It must take a PDF path, use the documents'
      shared text block (A4 595.276 x 841.890 pt, `margin: 1.75in` -> x in [126.0, 469.3],
      y in [126.0, 715.9]), report every text span and drawing exceeding it, and apply the
      research report's >8pt significance threshold with a flag to lower it.
- [x] Run the scan on both baseline PDFs and save the output as the baseline inventory in the
      scratchpad; confirm it reproduces exactly the six catalogued defects and nothing else
      above threshold.
      **Deviation (annotated, not silently skipped)**: the raw scan initially flagged a
      systematic false positive on every single page (the auto-numbering page-number footer,
      which Typst places in the bottom margin band by design under
      `#set page(numbering: "1", ...)`) — filtered out by an explicit, documented exclusion in
      the script (digit-only span, ~47.4pt bottom overflow). After that filter, the scan
      reproduces 5 of the 6 catalogued defects as above-threshold margin-overflow findings
      (FF p.28 = Defect 1, FF p.29 = Defect 2, FF p.31 = Defect 3, BR p.27 = Defect 6, BR p.76 =
      Defect 5) with no unexpected 7th finding. Defect 4 (`03-proof-theory.typ:327-328`, BR
      page 32) is structurally invisible to a margin-vs-page-edge bounding-box scan: per the
      research report, its symptom is two text spans overlapping *each other* inside the text
      block (a wrapped table-cell label interleaving with an adjacent unbreakable identifier),
      not either span individually crossing the page margin. This is confirmed, not merely
      assumed, by visual inspection in Phase 4 rather than by extending the scanner with a
      separate span-overlap heuristic (which risks false positives from ordinary character
      kerning in justified text) — the scan's role for Defect 4 is the recompiled-page
      Playwright screenshot, not the bbox tool.
- [x] Stand up the Playwright loop: serve the scratchpad PNG directory
      (`python3 -m http.server` bound to localhost, run in background), then
      `mcp__playwright__browser_navigate` to a known defect page and
      `mcp__playwright__browser_take_screenshot` it. Prove the loop end-to-end on FF page 28
      (defect 1) and BR page 27 (defect 6) before any edit is made. Confirmed: both screenshots
      visually show the catalogued symptom (overflowing derived-operator equation on FF p.28;
      Table 8 overlapping its caption/footer on BR p.27). Screenshots saved to
      `.playwright-mcp/baseline-FF-28.png` and `.playwright-mcp/baseline-BR-27.png`
      (`.playwright-mcp/` added to `.gitignore` — the Playwright MCP tool is sandboxed to write
      only inside the repo or its own default output directory, so this directory, not the
      scratchpad, is where its screenshots land; it must never be committed).
- [x] Record the baseline `bash scripts/typst-sync-check.sh` result (expected: PASS, all 3
      checks green) and the baseline page counts (FF 39, BR 98). Confirmed: PASS, all 3 checks
      green; FF = 39 pages, BR = 98 pages — both match the plan's baseline exactly.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: the research report asserts exactly six above-threshold defects, FF = 39
pages, BR = 98 pages, and `typst-sync-check.sh` = PASS on the unmodified tree. Confirm all four
by running the scan and the gate in this phase before editing anything; if the scan surfaces a
seventh above-threshold defect or the page counts differ, stop and record the delta in the
progress file rather than silently proceeding on the report's numbers.

**Files to modify**:

- `specs/506_fix_typst_display_defects_via_playwright_visual_loop/scripts/overflow-scan.py` -
  new task-scoped verification tool (under `specs/**`, not a repository script).
- No `typst/**` file is edited in this phase.

**Verification**:

- Both documents compile with exit 0.
- `overflow-scan.py` runs on both PDFs and its above-threshold findings match the six
  catalogued defects one-for-one.
- A Playwright screenshot of FF p.28 and BR p.27 is captured and visually shows the catalogued
  symptom (overflowing math row; table overlapping its caption/footer).
- `bash scripts/typst-sync-check.sh` exits 0.

---

### Phase 2: Break the Two Overflowing Display Equations [COMPLETED]

**Goal**: Fix defects 1 and 2 — both display-math blocks in `FormalFoundations.typ` that span
multiple source lines with no Typst row-break token and therefore compile as one unbreakable,
overflowing math row.

**Tasks**:

- [x] At `typst/FormalFoundations.typ:1205-1207` (Definition 5.1, TM-algebra derived operators),
      insert `\` row-break tokens at the two clause boundaries already implied by the existing
      3-line source formatting, so the six derived operators render as three left-aligned rows.
      Do not add, remove, reorder, or rename any operator or definition. Verified via an
      isolated scratch compile that `\` inside a Typst display-math block produces exactly this
      row-break behavior before touching the real file.
- [x] At `typst/FormalFoundations.typ:1255-1256` (Definition 5.2, complex algebra), insert a `\`
      row break at the boundary between the `square.stroked X := cases(...)` clause and the
      `X #until Y := {...}` clause.
- [x] Drop the now-redundant trailing `quad` spacing where a `\` replaces it, keeping inter-clause
      spacing within a row unchanged.
- [x] Recompile `FormalFoundations.typ`, re-render pages 28-29 to PNG, screenshot both via the
      Playwright loop, and compare against the Phase 1 baseline screenshots. Confirmed: both
      equations now render as multi-row math fully inside the definition box's colored rule,
      with no left/right overflow. (Definition 5.2's block reflowed slightly and now spans
      FF p.29/p.30 instead of fitting entirely on p.29 — expected consequence of the taller
      3-row block, not a defect; both pages checked, no overflow on either.)

**Note on the mandatory element-placement lint**: `bash .claude/scripts/typst-element-lint.sh
--verbose typst/FormalFoundations.typ` reports 14 pre-existing `[FAIL]` findings (a `#definition`
or `#theorem` opening immediately after a section heading with no intervening prose), at heading
locations throughout the whole document unrelated to lines 1202-1256. Confirmed via a byte-for-
byte lint run against the pre-Phase-2 committed version (`git show HEAD:typst/FormalFoundations.typ`)
that all 14 are identical in count and location before and after this phase's edit — this phase
neither introduces nor worsens any of them. Fixing them requires authoring new opening prose for
14 separate sections, which is content authorship, not layout: explicitly out of scope per this
plan's Non-Goals ("Changing any mathematical content, statement, notation, or wording...") and
per the Typst extension's own scope boundary (content-creation work routes to `lean4`/`formal`/
`general`, not `typst`). Treated as a pre-existing, documented, out-of-scope condition rather
than a phase blocker — not silently dropped, and not force-fixed outside this task's charter.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the fix is confined to two display-math blocks in one
file and that no third overflowing display equation exists in either document. Confirm by
re-running `overflow-scan.py` on the recompiled `FormalFoundations.pdf` and checking that both
defect-1 and defect-2 findings are gone and no new math-span overflow appears.

**Files to modify**:

- `typst/FormalFoundations.typ` - insert `\` row breaks in the two display-math blocks at
  lines ~1205-1207 and ~1255-1256 (whitespace/break tokens only).

**Verification**:

- `typst compile typst/FormalFoundations.typ` exits 0.
- Playwright screenshots of the recompiled pages 28-29 show every math row starting at or right
  of the text-block left edge and ending at or left of the right edge, fully inside the
  definition box's colored rule.
- `overflow-scan.py` reports zero above-threshold findings on those pages.
- A source diff confirms only `\` tokens, whitespace, and redundant `quad` removals changed — no
  symbol, operator, or identifier in the math content differs.

---

### Phase 3: Systemic Break Opportunity in the `leansrc` Helper [NOT STARTED]

**Goal**: Fix defect 3 at its root by giving `leansrc`-rendered dotted Lean identifiers an
invisible break opportunity at each module-path dot, closing the whole defect class for every
present and future call site instead of only the one instance currently long enough to overflow.

**Tasks**:

- [ ] In `typst/template.typ` (the `leansrc` definition, currently line 98), insert a
      zero-width-space break opportunity after each `"."` in the module+name string before
      passing it to `raw(block: true, ...)` — the research-validated idiom:
      `raw(block: true, "> " + (module + "." + name).replace(".", "." + sym.zws) + ".")`.
      Preserve the surrounding `block(above: 1.0em, below: 1.0em, ...)` wrapper unchanged.
- [ ] Recompile BOTH documents (the helper is shared: ~67 call sites in
      `FormalFoundations.typ`, 3 in `typst/chapters/`).
- [ ] Screenshot the long instance (`FormalFoundations.typ:1301`,
      `Metalogic.BXCanonical.CompletenessDedekind.completeness_rtime_engine`, baseline FF p.31)
      and confirm it now wraps at a module-boundary dot and sits inside the right margin.
- [ ] Screenshot a sample of short call sites (FF lines 160, 987, 1290, 1518) and confirm they
      are visually identical to the Phase 1 baseline — `sym.zws` is invisible and must only act
      as a break point when a line actually overflows.
- [ ] Confirm the rendered characters are unchanged: no visible extra dot, space, or glyph.

**Timing**: 0.75 hours

**Depends on**: 1

**Verification Tier**: interface

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts ~70 `#leansrc` call sites (67 in `FormalFoundations.typ`
+ 3 under `typst/chapters/`) and exactly one currently-overflowing instance (line 1301). Confirm
at implementation time with `grep -c '#leansrc(' typst/FormalFoundations.typ` and
`grep -rn '#leansrc(' typst/chapters/`, and confirm the single-overflow claim from the Phase 1
baseline scan output rather than from the report. If the scan shows a second overflowing
`leansrc` line, this same fix should cover it — verify that it does.

**Files to modify**:

- `typst/template.typ` - `leansrc` definition only: add `.replace(".", "." + sym.zws)` to the
  string passed to `raw`.

**Verification**:

- Both `typst compile typst/FormalFoundations.typ` and `typst compile typst/BimodalReference.typ`
  exit 0.
- `overflow-scan.py` on the recompiled `FormalFoundations.pdf` reports the defect-3 finding gone
  and no new overflow anywhere in the document.
- Side-by-side screenshots of the four sampled short call sites are visually unchanged from
  baseline.
- `bash scripts/typst-sync-check.sh` still exits 0 (the helper change touches no backticked span
  and no generated file, so Check 1/2/3 must be unaffected).

---

### Phase 4: Make Table 8 Breakable and De-overlap the DerivationTree Table [NOT STARTED]

**Goal**: Fix the two `03-proof-theory.typ` defects — defect 6 (the 24-row BX-temporal figure
that cannot fit one page, overflowing its own caption and the footer by up to 84.6pt: the most
severe defect found) and defect 4 (the DerivationTree rule table whose wrapped "Temp.
Necessitation" label visually interleaves with the unbreakable adjacent Lean constructor).

**Tasks**:

- [ ] Defect 6: wrap the single `#figure(...)` call beginning at
      `typst/chapters/03-proof-theory.typ:71` in a block-local show rule so only that figure
      becomes page-breakable — `{ show figure: set block(breakable: true); figure(...) }` or the
      equivalent local scoping construct. Do NOT place the show rule at file scope.
- [ ] Recompile `BimodalReference.typ` and confirm the table now splits across a page boundary
      with `table.header` repeating on the continuation page and the caption following the
      table's true final row.
- [ ] Confirm other figures in the same chapter still render atomically (spot-check at least
      the DerivationTree figure at line ~314 and one diagram/table figure elsewhere in the
      chapter) — i.e. the show rule did not leak.
- [ ] Defect 4: for the two long raw identifiers at `typst/chapters/03-proof-theory.typ:327-328`
      (`DerivationTree.temporal_necessitation`, `DerivationTree.time_reflection`), introduce the
      same dot break-opportunity so the Lean Constructor column wraps cleanly instead of
      overlapping the Rule column. If the wrap alone leaves the columns crowded, additionally
      give the 3-column table explicit width behavior (`columns: (auto, 1fr, auto)`).
- [ ] Recompile and screenshot the DerivationTree table's page; confirm the Rule and Lean
      Constructor columns are visually separated with no interleaved glyphs.
- [ ] Record the new BimodalReference page count and the new rendered page numbers for the two
      fixed tables (page numbers after the Table 8 split will shift by ~1 for all later pages).

**Timing**: 1.0 hours

**Depends on**: 1

**Verification Tier**: local

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts Table 8 has 24 data rows and that making it breakable
adds approximately one page to `BimodalReference.typ` (98 -> ~99). Confirm both at implementation
time: count the rows in the source and read the post-fix page count from the compiled PDF.
Record the actual new page count in the progress file, because Phase 5 and Phase 6 locate pages
by content, not by the baseline numbering.

**Files to modify**:

- `typst/chapters/03-proof-theory.typ` - block-local breakable show rule around the `#figure`
  at line ~71; dot break opportunities (and, if needed, `columns: (auto, 1fr, auto)`) for the
  DerivationTree table at lines ~313-329.

**Verification**:

- `typst compile typst/BimodalReference.typ` exits 0.
- Playwright screenshots of the two (now possibly renumbered) affected pages show: Table 8 split
  across a page boundary with a repeated header and a caption that follows the final row, no
  content overlapping the footer; the DerivationTree table with cleanly separated columns.
- `overflow-scan.py` on the recompiled `BimodalReference.pdf` reports defects 4 and 6 gone.
- A spot-check screenshot confirms at least two other figures in the chapter remain unsplit.

---

### Phase 5: Shorten the Overflowing Module-Map Role Text [NOT STARTED]

**Goal**: Fix defect 5 — the largest single measured overflow (129.5pt, over 1.8in past the
margin) — where the unbreakable inline code span `Metalogic.Core.deductionTheorem` is pushed off
the visible page inside a Module Map table cell.

**Tasks**:

- [ ] Locate the target by content, not by page number (Phase 4 shifted BimodalReference
      pagination): `typst/chapters/p4-proof-automation.typ`, the `roles` dictionary entry for
      `"Tactics/Deduction.lean"` (currently line ~114).
- [ ] Shorten the inline code span from `` `Metalogic.Core.deductionTheorem` `` to
      `` `deductionTheorem` ``, matching every sibling cell in the same table, which already
      uses bare identifiers (`deduction`, `deduction n`, `undischarge`). The module context is
      not lost: `04-metalogic.typ` already documents `deductionTheorem`'s location. This is the
      research report's primary recommendation and a stylistic-consistency win.
- [ ] Run `bash scripts/typst-sync-check.sh` and confirm Check 1 (backtick name resolution)
      still passes with the bare identifier. `deductionTheorem` is present in
      `FormalSystem/Metalogic/Core/MaximalConsistent.lean`, so it is expected to resolve.
- [ ] If Check 1 fails on the bare name, revert to the fully-qualified name and instead apply the
      dot break-opportunity technique (Phase 3's idiom) to that span; re-run the gate.
- [ ] Recompile `BimodalReference.typ`, find the Module Map table's current page by text match,
      and screenshot it via the Playwright loop.

**Timing**: 0.5 hours

**Depends on**: 4

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts the edited cell is hand-authored prose in the `roles`
dictionary (not machine-generated output of `scripts/typst-module-map.sh`) and therefore that
editing it does not desynchronize `typst/generated/automation-module-map.typ`. Confirm by
running the full `typst-sync-check.sh` in this phase — its Check 2 module-map sub-check
regenerates the map live and would flag a mismatch.

**Files to modify**:

- `typst/chapters/p4-proof-automation.typ` - the `"Tactics/Deduction.lean"` role text in the
  `roles` dictionary (line ~114).

**Verification**:

- `typst compile typst/BimodalReference.typ` exits 0.
- `bash scripts/typst-sync-check.sh` exits 0 with all three checks green (Check 1 name
  resolution is the direct risk gate for this edit).
- A Playwright screenshot of the Module Map table's page shows the full role cell text inside
  the table's right edge, with no content beyond the text block.
- `overflow-scan.py` reports the defect-5 finding gone.

---

### Phase 6: Full Re-sweep, Playwright Confirmation, and Final Gate [NOT STARTED]

**Goal**: Prove systematically that all six defects are gone, that no fix introduced a new one
anywhere across both documents, and that the repository's gates are green — the dispatch's
"repeat the full sweep until no display issues remain" acceptance condition.

**Tasks**:

- [ ] Recompile both documents from a clean state to PDF and to per-page PNG.
- [ ] Run `overflow-scan.py` over ALL pages of both PDFs at the >8pt significance threshold and
      confirm zero findings; then re-run at a lowered threshold (8-20pt band) and confirm every
      remaining item is ordinary justified-line-end / footer rendering, exactly as the research
      report's non-findings section characterized the baseline noise.
- [ ] Playwright-screenshot each of the six fixed locations at its post-fix page number and
      visually confirm the defect is resolved.
- [ ] Playwright-screenshot the immediate neighborhood of every fix (page before and after) to
      confirm nothing was newly crowded by reflow or repagination.
- [ ] Re-scan for the report's non-finding categories at the new pagination: heading spans within
      80pt of the bottom margin (orphaned headings) and a `pdftotext` pass for `??`, `[?]`, and
      `undefined` (broken references / citation placeholders). Confirm still clean.
- [ ] Run `bash scripts/typst-sync-check.sh` and confirm PASS, all three checks green.
- [ ] Confirm the working tree carries no compiled artifacts (`git status --porcelain typst/`
      shows only the intended `.typ` source edits; PDFs and PNGs live in the scratchpad).
- [ ] Record final page counts for both documents and the per-defect before/after evidence in
      the execution summary.

**Timing**: 1.0 hours

**Depends on**: 2, 3, 4, 5

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: this phase asserts that all six catalogued defects are the complete defect
set and that zero above-threshold findings remain. Confirm by the exhaustive all-pages scan of
both documents (not by re-checking only the six known pages); if a new above-threshold finding
appears, treat it as a regression from one of Phases 2-5, attribute it to the owning phase, and
fix it there before closing this phase.

**Files to modify**:

- None (verification-only phase). Any fix required by a regression discovered here is applied in
  the owning phase's file and re-verified.

**Verification**:

- `typst compile` exits 0 for both documents.
- `overflow-scan.py` reports zero above-threshold findings across all pages of both PDFs.
- All six fixed locations are visually confirmed by Playwright screenshot.
- `bash scripts/typst-sync-check.sh` exits 0, all three checks green.
- No compiled output is staged or committed.

## Testing & Validation

- [ ] `typst compile typst/FormalFoundations.typ` exits 0 (the two `thmbox` font warnings are
      pre-existing and out of scope).
- [ ] `typst compile typst/BimodalReference.typ` exits 0.
- [ ] `bash scripts/typst-sync-check.sh` exits 0 with all three checks green.
- [ ] Bounding-box scan reports zero >8pt overflows across all pages of both documents.
- [ ] Each of the six catalogued defects has a before/after Playwright screenshot pair.
- [ ] Source diff review confirms zero mathematical-content changes: only break tokens,
      whitespace, a show-rule scope, column-width behavior, and one module-path prefix removal
      in non-mathematical table prose.
- [ ] No compiled PDFs/PNGs added to the repository.

## Artifacts & Outputs

- Edited sources: `typst/FormalFoundations.typ`, `typst/template.typ`,
  `typst/chapters/03-proof-theory.typ`, `typst/chapters/p4-proof-automation.typ`.
- Task-scoped verification tool:
  `specs/506_fix_typst_display_defects_via_playwright_visual_loop/scripts/overflow-scan.py`.
- Execution summary at
  `specs/506_fix_typst_display_defects_via_playwright_visual_loop/summaries/01_*-summary.md`,
  recording per-defect before/after evidence, final page counts, and gate results.
- Scratchpad-only (not committed): compiled PDFs, per-page PNGs, baseline and final scan output,
  Playwright screenshots.

## Rollback/Contingency

- Every phase owns exactly one source file and commits per green sub-step, so any single fix can
  be reverted with `git revert` of that phase's commit without disturbing the others.
- If Phase 3's shared-helper change causes any visual regression at a short `leansrc` call site,
  revert `typst/template.typ` and apply the point fix at `FormalFoundations.typ:1301` instead
  (accepting that the defect class stays latent — record this in the summary).
- If Phase 4's breakable show rule leaks or splits Table 8 badly, revert it and fall back to
  reducing the figure's font size or splitting the table into two figures at a natural
  BX-numbering boundary (last resort — it changes presentation structure, not content).
- If Phase 5's shortened identifier fails the name-resolution gate, the in-phase fallback (keep
  the qualified name, add break opportunities) applies; if both fail, revert the cell and leave
  defect 5 open with a documented reason rather than weakening the gate.
- Contingency floor: `git checkout` of the four `typst/**` files restores the baseline state,
  which is known green (`typst-sync-check.sh` PASS, both documents exit 0).
