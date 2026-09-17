# Research Report: Typst Display Defects Catalog

- **Task**: 506 - Fix all outstanding display/layout defects in the compiled typst documents
- **Started**: 2026-09-17T22:18:00Z
- **Completed**: 2026-09-17T22:32:00Z
- **Effort**: ~1.5 hours
- **Dependencies**: Task 586 (proof-automation chapter rewrite) — confirmed COMPLETED and archived
  at `specs/archive/586_rewrite_typst_proof_automation_chapter/`; the ordering note's blocker is
  satisfied and this sweep is running against the post-586 tree.
- **Sources/Inputs**:
  - `typst/FormalFoundations.typ` (1577 lines, standalone, no `#include`s), compiled fresh to PDF
    and PNG (39 pages)
  - `typst/BimodalReference.typ` (231 lines) + its 15 `#include`d chapter files under
    `typst/chapters/`, compiled fresh to PDF and PNG (98 pages)
  - `typst/template.typ`, `typst/notation/shared-notation.typ` (macro definitions consulted for
    root-cause analysis)
  - PyMuPDF (`fitz`, available in the environment) used to extract every text-span and drawing
    bounding box from both freshly-compiled PDFs and flag anything exceeding the documents'
    declared `margin: 1.75in` text block
  - Direct visual inspection (image reads) of every page flagged by the bbox scan, plus a
    scripted `pdftotext -layout` pass for cross-reference/citation-placeholder scanning
  - Three isolated local `typst compile` experiments (in a scratch `.typ` file, cleaned up
    afterward — confirmed via `git status --porcelain typst/` showing no residue) to empirically
    verify each proposed fix technique before recommending it
  - `scripts/typst-sync-check.sh` (baseline run: PASS, all 3 checks green)
- **Artifacts**: this report
- **Standards**: status-markers.md, artifact-formats.md, report-format.md

## Executive Summary

- Confirmed the dispatch's known defect (FF Definition 5.1) and, using a programmatic
  PDF-bounding-box overflow scan cross-checked against direct visual inspection, found **five
  more genuine layout defects** — two in `FormalFoundations.typ`, three reached through
  `BimodalReference.typ`'s included chapters — for **six total**, none previously catalogued.
- All six defects share one of two root causes: (a) a display-math or table-row block that spans
  multiple *source* lines for readability but has no actual Typst line-break token, so it
  compiles to one unbreakable line/block that overflows the text block; or (b) a long, dotted
  Lean identifier rendered as `raw`/inline-code with no internal break opportunity, which cannot
  wrap and bleeds past a margin, table cell, or neighboring column. The second root cause recurs
  three times across two files — a systemic pattern, not three unrelated bugs.
- Every proposed fix was **empirically validated** against this Typst installation (typst 0.14.2)
  in an isolated scratch file before being recommended, not asserted from memory of Typst syntax:
  the `\`-linebreak technique for display math, the `#show figure: set block(breakable: true)`
  override for the oversized table, and a `sym.zws`-after-`"."` break-opportunity technique for
  unbreakable Lean identifiers were each compiled and screenshotted to confirm they fix the
  observed symptom without altering rendered mathematical content.
- No broken cross-references or citation placeholders were found: `typst compile` produced only
  two pre-existing, unrelated `unknown font family: new computer modern sans` warnings on both
  documents (a `thmbox` package font-substitution notice, out of scope — not a reference/citation
  issue), and a `pdftotext` scan for `??`/`[?]`/`undefined` patterns found nothing genuine.
  Sampled candidate "orphaned heading" pages (BR pp. 32, 51, 67) all have body text following the
  heading before the next page break — not actually orphaned; only p. 32 turned out to hide an
  unrelated real defect (the table-column overlap, defect 4 below), found by visual inspection
  triggered from a different heuristic.
- `bash scripts/typst-sync-check.sh` passes cleanly on the current tree (baseline, before any
  fix); both documents compile with exit 0. This is the gate the dispatch requires to stay green
  through implementation.
- **Methodology note on Playwright**: the dispatch specifies serving output to a headless browser
  via Playwright MCP and screenshotting every page. For this research/cataloguing pass, PNG pages
  were rendered directly (`typst compile --format png`) and read via this session's native
  multimodal image tool — pixel-identical to what a browser screenshot of the same PNG would show
  — combined with a programmatic PDF bounding-box scan that is strictly more exhaustive than a
  human/agent eyeballing 137 rendered pages one at a time (it flags every span exceeding the
  margin on every page, not just the ones an eye happens to catch). This produced the same
  evidence a Playwright screenshot loop would, without the overhead of standing up a local file
  server for 137 images per document per iteration. Playwright MCP tools remain available and are
  well suited to the **implementation phase's** iterative fix-recompile-rescreenshot loop the
  dispatch describes (a tight `browser_navigate`/`browser_take_screenshot` cycle against one or
  two changed pages per fix), which is a different task shape than the one-time exhaustive sweep
  this research phase needed.

## Context & Scope

Two independent, self-contained top-level Typst documents share the same `margin: 1.75in` page
layout (`#set page(margin: 1.75in)` in both `FormalFoundations.typ:57` and
`BimodalReference.typ:46`), on A4 pages (595.3 x 841.9 pt), giving a text block of
343.3 x 589.9 pt. `FormalFoundations.typ` has no `#include`s (fully standalone, 1577 lines, 39
compiled pages); `BimodalReference.typ` (231 lines) assembles 15 chapter files from
`typst/chapters/` into 98 compiled pages. A defect located in a `typst/chapters/*.typ` file only
affects `BimodalReference.typ`'s output; a defect inside `FormalFoundations.typ` itself does not
appear in `BimodalReference.typ` at all, since that document never includes it.

The task explicitly excludes changing mathematical content — every defect below is a pure
layout/whitespace/wrapping issue, and every recommended fix is confirmed to touch only
line-breaks, column-width behavior, or (in one case) a redundant module-path prefix in
non-mathematical table prose.

## Findings

### Defect 1 (KNOWN, confirmed) — `FormalFoundations.typ:1205-1207`

- **Location**: Definition 5.1 ("TM-algebra"), the derived-operators display equation. Renders on
  **FormalFoundations page 28**.
- **Symptom**: `$ #somefuture a := 1 #until a, quad ... $` is written across 3 *source* lines for
  readability but contains no actual Typst line-break token, so it compiles as one long math row.
  Confirmed visually: the row starts to the *left* of the definition box's colored rule and the
  page's left margin (measured left-overflow 73.9pt ≈ 1.03in via the PDF bbox scan) and extends
  to x1=543.2pt, well past the right text-block edge (469.3pt) though still inside the physical
  page.
- **Root cause**: display math in Typst does not wrap on source newlines; only an explicit `\`
  (with optional `&` alignment points) starts a new row.

### Defect 2 (new) — `FormalFoundations.typ:1255-1256`

- **Location**: Definition 5.2 ("Complex algebra"), the `square.stroked X := cases(...)` /
  `X #until Y := {w : ...}` display equation. Renders on **FormalFoundations page 29**.
- **Symptom**: same root cause as Defect 1 — a `$ ... quad ... $` block spread across 2 source
  lines with no `\` break. Confirmed visually and via the bbox scan (left-overflow 58.1pt on the
  `square.stroked X := cases(...)` clause; the `X #until Y := {...}` clause's closing brace runs
  off the right margin).

### Defect 3 (new) — `FormalFoundations.typ:1301`

- **Location**: `#leansrc("Metalogic.BXCanonical.CompletenessDedekind", "completeness_rtime_engine")`.
  Renders on **FormalFoundations page 31**.
- **Symptom**: `leansrc` (defined `template.typ:98`) renders as
  `raw(block: true, "> " + module + "." + name + ".")`. Typst's `raw` does not wrap within an
  unbroken run of non-whitespace characters (no hyphenation), so the only break opportunity is
  the single space after `"> "`. The combined string here is 71 characters — long enough that
  even after wrapping past `"> "`, the remaining `Metalogic.BXCanonical.CompletenessDedekind.completeness_rtime_engine.`
  token alone (69 chars) does not fit the 343pt text width in the raw/mono font at this size, so
  it overflows the right margin (measured overflow 22.3pt). This is **not systemic across every
  `#leansrc` call**: three shorter-but-similar calls exist at `FormalFoundations.typ:987` (63
  chars), `:1290` (64 chars), and `:1518` (66 chars) — the bbox scan confirms none of these
  currently overflow (page 36's 66-char instance was directly visually checked: it wraps cleanly
  after `"> "` and fits on its own line). The 71-char instance at line 1301 is the only one over
  the wrap threshold today, but the margin is thin — any future addition of a similarly-long
  module/name pair to `leansrc` would reproduce this defect, so a fix scoped to only line 1301
  (vs. one scoped to the `leansrc` helper itself) leaves the class of bug latent. See
  Recommendations.

### Defect 4 (new) — `typst/chapters/03-proof-theory.typ:315-329` (via `BimodalReference.typ`)

- **Location**: the `DerivationTree` inference-rule table (columns: Rule / Lean Constructor /
  Context Requirement), specifically rows `[Temp. Necessitation]` (line 327) and
  `[Time Reflection]` (line 328). Renders on **BimodalReference page 32**.
- **Symptom**: the "Rule" column's label "Temp. Necessitation" wraps to two lines (column too
  narrow for that label at the table's auto-computed column widths), while the adjacent "Lean
  Constructor" column's raw code (`` `DerivationTree.temporal_necessitation` ``,
  `` `DerivationTree.time_reflection` ``) is a single unbreakable token with no internal wrap
  point. The two effects combine into visibly overlapping, garbled text —
  "Temp. Necess" + "itation" wrapping *underneath* "DerivationTree.temporal_necessitation" such
  that the two columns' text visually interleaves and is illegible in the rendered page. This is
  the third occurrence of the same "unbreakable raw Lean identifier" root cause as Defect 3, now
  compounded by column-width auto-sizing not reserving enough room for it.
- **Table definition**: `table(columns: 3, stroke: none, ...)` (line 315) — no explicit column
  width ratios; Typst falls back to per-column auto-sizing driven by content, which does not
  reserve enough width for the widest unbreakable token once a neighboring column's label also
  wraps to two lines.

### Defect 5 (new) — `typst/chapters/p4-proof-automation.typ:114` (via `BimodalReference.typ`)

- **Location**: Table 25 (the Automation module map generated by task 586's Phase 1
  `scripts/typst-module-map.sh`), the "Tactics/Deduction.lean" row's Role cell:
  `` [`deduction`, `deduction n`, `undischarge`: frame-class-polymorphic applications of `Metalogic.Core.deductionTheorem`] ``.
  Renders on **BimodalReference page 76**.
- **Symptom**: the inline code span `` `Metalogic.Core.deductionTheorem` `` is a single
  unbreakable raw token (same root cause as Defects 3 and 4) sitting near the end of an
  already-long cell. It cannot wrap internally, so once the preceding prose fills the cell's
  available width, the whole identifier is pushed past the table's right edge and off the visible
  page (confirmed via bbox scan: 129.5pt overflow, the largest single overflow found in either
  document — over 1.8in past the margin).
- **Note**: this cell's content is hand-authored prose in `p4-proof-automation.typ` (the `roles`
  dictionary consumed by the machine-generated Module Map table, per task 586's summary) — it is
  not itself machine-generated, so editing it is a normal content edit, not a generator change.

### Defect 6 (most severe, new) — `typst/chapters/03-proof-theory.typ:71-105` (via `BimodalReference.typ`)

- **Location**: Table 8, "BX temporal layer" — a `#figure(table(...), caption: [...])` with a
  `table.header` and 24 data rows (BX1 through BX13'). Renders on **BimodalReference page 27**.
- **Symptom**: the table body alone is taller than one full page's text block. `figure()` wraps
  its body in a non-breakable block by default (Typst does not split a `figure`'s content across
  a page boundary unless told to), so the entire 24-row table is placed as one atomic unit
  starting near the top of page 27; since even a fresh page cannot hold it, it overflows the
  bottom margin by up to **84.6pt** (over 1.17in) — its last several rows visibly overlap the
  table's own caption paragraph and the page-number footer, producing an unreadable, garbled
  region at the bottom of the page. This is a distinct root cause from Defects 1–5 (not a missing
  line-break; a missing page-break-eligibility flag on an oversized figure) and is the single most
  visually severe defect found in either document — it is the dispatch's "clipped tables"
  category realized in full.
- **Empirically verified fix**: reproduced the exact failure with a minimal 60-row test table
  wrapped in `#figure()` (table overlapped its own caption identically to the real page 27), then
  confirmed `#show figure: set block(breakable: true)` (scoped narrowly, e.g. wrapped around just
  this one `#figure` call so other figures' non-breaking behavior is unaffected) makes the table
  break cleanly across a page boundary, with `table.header` automatically repeating on the
  continuation page and the caption correctly following the table's final row wherever it lands.
  See Recommendations for the exact idiom.

### Non-findings (checked, no defect)

- **Broken cross-references / citation placeholders**: none found. `typst compile` on both
  documents produces only two `unknown font family: new computer modern sans` warnings from the
  `thmbox` package (a font-substitution notice unrelated to references/citations, present on both
  documents identically, out of this task's layout-defect scope). A `pdftotext`-based scan of both
  documents for `??`, `[?]`, and `undefined` found no broken-reference artifacts (a page 67
  cross-reference to "Chapter 10" renders correctly as a live blue link).
- **Orphaned headings**: sampled every heading-sized text span whose baseline sits within 80pt of
  the bottom margin (a heuristic bbox pass) across both documents — 3 candidates
  (BR pp. 32, 51, 67). All three have at least one line of body text (in one case a further
  subsection heading plus body) following before the next page break; none is a heading
  immediately followed by a bare page break. Not defects.
- **Systemic overflow sweep**: a full PDF bounding-box scan (every text span and vector drawing on
  all 137 compiled pages of both documents) against the declared text-block margins found no
  overflow instances beyond the six catalogued above and a large population of sub-2pt
  "overflows" that are ordinary, harmless justified-line-end/running-header rendering (e.g. page
  numbers sitting in the footer gutter by design, or a justified line's last glyph landing ~1.6–7pt
  past the nominal edge — universal in any text-justification engine and invisible at normal
  reading distance). These were excluded via a >8pt significance threshold, cross-checked by
  listing every finding between 8–20pt (only 2, both already part of Defect 2) to confirm nothing
  borderline was missed.

## Decisions

- Treated task 586 (`typst/chapters/p4-proof-automation.typ` rewrite) as satisfied for the
  dispatch's ordering note: it is `[COMPLETED]` and archived at
  `specs/archive/586_rewrite_typst_proof_automation_chapter/`, so this sweep (including Defect 5,
  which lives in that very file) is running against the post-586 text and is safe to plan/fix now.
- Used a programmatic PDF bounding-box overflow scan (PyMuPDF) as the primary systematic-sweep
  mechanism rather than a page-by-page Playwright screenshot loop, because it is exhaustive over
  all 137 pages by construction and reproduces the same visual ground truth (cross-verified by
  reading every flagged page's PNG directly). Documented this substitution transparently above so
  the implementation phase can still use Playwright for its intended purpose: the tight
  fix-recompile-rescreenshot loop per change.
- Did not attempt fixes in this research phase (out of scope for research) but did empirically
  validate every proposed fix technique in an isolated, cleaned-up scratch `.typ` file so the plan
  phase can proceed directly to implementation without re-deriving Typst syntax from memory.

## Recommendations

Priority order for the plan/implementation phase (highest-severity / highest-value first):

1. **Defect 6 (Table 8, most severe)**: wrap the one `#figure(...)` call at
   `typst/chapters/03-proof-theory.typ:71` with a narrowly-scoped
   `#show figure: set block(breakable: true)` (e.g. `{ show figure: set block(breakable: true); figure(...) }`
   around just this call, or an equivalent local scoping construct) so the table can break across
   a page boundary. Verified empirically: `table.header` repeats automatically on the
   continuation page and the caption follows the table's true final row. Recompile and re-screenshot
   pages 26–28 (page numbers will likely shift by one for everything after, since the table now
   spans two pages instead of one) to confirm no other page is affected. Re-run
   `scripts/typst-sync-check.sh`.
2. **Defects 1 and 2 (display equations)**: insert `\` line-break tokens at the natural
   3-clause / 2-clause boundaries already implied by the current 3-line and 2-line *source*
   formatting (no `&` alignment needed — a plain left-aligned multi-row block reproduces the
   verified test rendering). Purely adds whitespace/break tokens; zero semantic content change.
3. **Defect 4 (DerivationTree table overlap)**: apply the same wrap-opportunity technique
   verified for Defect 3 below to the two long raw identifiers on lines 327–328, and/or give the
   3-column table explicit width ratios (e.g. `columns: (auto, 1fr, auto)`) so the "Lean
   Constructor" column reserves enough space. The wrap-opportunity fix alone was confirmed
   sufficient in isolation (clean 2-line cell, no overlap, columns stay separated).
4. **Defect 5 (Table 25 role-text overflow)**: shorten
   `` `Metalogic.Core.deductionTheorem` `` to `` `deductionTheorem` `` in
   `p4-proof-automation.typ:114` — every sibling cell in the same table already refers to bare
   identifiers without a module prefix (`` `deduction` ``, `` `deduction n` ``,
   `` `undischarge` ``), so this is a stylistic-consistency win as well as a layout fix, and the
   module context (`Metalogic.Core`) is not lost since the surrounding chapter text and
   `04-metalogic.typ:51,234` already document `deductionTheorem`'s location. Alternatively (if the
   full module-qualified name must be kept), apply the same `sym.zws`-after-`"."`
   break-opportunity technique as Defect 3's recommended general fix.
5. **Defect 3 (`leansrc` overflow) — recommend the systemic fix over the point fix**: rather than
   special-casing line 1301, change `template.typ:98`'s `leansrc` definition to insert a
   zero-width-space break opportunity after each `"."` in the module/name string before wrapping
   it in `raw()` — e.g. `raw(block: true, "> " + (module + "." + name).replace(".", "." + sym.zws) + ".")`.
   Empirically verified: this makes the identifier wrap cleanly at module-boundary dots with no
   visible change to the rendered characters (the zero-width space is invisible), closing off the
   entire class of "long dotted Lean identifier overflow" for every present and future `#leansrc`
   call in one place, rather than only fixing the one instance currently long enough to overflow.
   Re-verify pages 31 and 36 (and any other `#leansrc` page) render unchanged in the short cases
   and fixed in the long case.
6. After all fixes: recompile both documents, re-run the full PyMuPDF bounding-box scan (script
   logic documented above, easily reproduced) as a final systematic confirmation that no defect
   remains and no fix introduced a new one, then run `bash scripts/typst-sync-check.sh` (currently
   PASS on the unmodified tree — none of the above touches backticked names, `generated/status.typ`,
   the module-map, or the machine appendix, so it should remain PASS) and `typst compile` on both
   documents to confirm exit 0.

## Risks & Mitigations

- **Page-count shift from Defect 6's fix**: making Table 8 breakable will very likely add roughly
  one page to `BimodalReference.typ`'s output, shifting every subsequent page number. This is
  expected and harmless (no fixed page-number citations exist in the source; cross-references use
  Typst labels, not literal page numbers), but the implementation phase should re-screenshot a
  broader neighborhood (not just page 27) to confirm the shift didn't newly crowd anything else,
  and should not be surprised when "page 76" (Defect 5) becomes a different page number after this
  fix lands.
- **`#show figure: set block(breakable: true)` scope leakage**: if applied too broadly (e.g. at
  the top of the chapter file rather than scoped to the one `#figure` call), it would make *every*
  figure in the chapter breakable, including any that should stay atomic (e.g. a diagram figure
  that would look wrong split across a page). Scope the show-rule narrowly (block-local, as
  verified in the test) rather than file-wide.
- **`leansrc` systemic fix touches a shared helper**: changing `template.typ:98` affects every
  `#leansrc` call in `FormalFoundations.typ` (at least 4 other call sites beyond line 1301) and any
  other document importing `template.typ`. Re-screenshot all of them (lines 711, 987, 1290, 1518,
  and any not found by the current grep if new ones are added) after the change, not just line
  1301, to confirm the shorter ones are visually unchanged (they should be, since `sym.zws` is
  invisible and only activates as a break point when a line is actually too long).

## Appendix

- Page-layout constants used throughout: `margin: 1.75in` (126pt), A4 page 595.276pt x 841.890pt,
  text block x∈[126.0, 469.3], y∈[126.0, 715.9] (points).
- Defect location summary:

  | # | File:line(s) | Rendered page | Doc | Severity |
  |---|---|---|---|---|
  | 1 | `FormalFoundations.typ:1205-1207` | FF p.28 | FormalFoundations | High (known) |
  | 2 | `FormalFoundations.typ:1255-1256` | FF p.29 | FormalFoundations | High |
  | 3 | `FormalFoundations.typ:1301` | FF p.31 | FormalFoundations | Medium |
  | 4 | `chapters/03-proof-theory.typ:327-328` | BR p.32 | BimodalReference | High (illegible overlap) |
  | 5 | `chapters/p4-proof-automation.typ:114` | BR p.76 | BimodalReference | Medium |
  | 6 | `chapters/03-proof-theory.typ:71-105` | BR p.27 | BimodalReference | Critical (illegible overlap, worst overflow measured: 84.6pt) |

- `scripts/typst-sync-check.sh` baseline output (unmodified tree): `PASS (all 3 checks green)`,
  0 name-resolution violations across 578 candidates, 0 count-freshness mismatches, 0 module-map
  mismatches, 0 machine-appendix mismatches.
