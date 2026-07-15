# Implementation Plan: Task #371

- **Task**: 371 - Completely revise the Bimodal Reference typst document to present all and only the bimodal logic
- **Status**: [NOT STARTED]
- **Effort**: 4 hours
- **Dependencies**: None
- **Research Inputs**: specs/371_revise_bimodal_reference_bimodal_only/reports/01_cut-parts-iii-iv-bimodal-only.md
- **Artifacts**: plans/01_two-part-bimodal-reference.md (this file)
- **Standards**:
  - .claude/context/formats/plan-format.md
  - .claude/rules/artifact-formats.md
  - .claude/rules/state-management.md
  - .claude/context/workflows/task-breakdown.md
- **Type**: typst
- **Lean Intent**: false

## Overview

Cut Part III (Counterfactual Logic) and Part IV (Constitutive Logic) from
`Theories/Bimodal/typst/BimodalReference.typ` entirely, leaving a focused two-part reference:
Part I (The Bimodal System, including the neighboring temporal-modal logics) and Part II
(Applications). Beyond mechanical deletion of 886 lines across two chapters, the abstract,
title-page Sources block, and `00-introduction.typ` roadmap/reading-guide are genuinely
**rewritten** so the manual reads as a self-contained bimodal-logic reference — not a four-part
book with two parts crudely excised. Bibliography, notation comments, sync tooling, and repo
docs are brought into agreement with the new two-part scope. Every phase leaves the document
typst-compilable; the final phase enforces the global green bar.

### Research Integration

The plan is grounded entirely in `reports/01_cut-parts-iii-iv-bimodal-only.md`, which is
authoritative. Key integrated findings:
- **Clean cut confirmed (report §3)**: ZERO dangling `@`-references from retained chapters into
  removed material. Every cross-reference into Parts III/IV originates *from* the removed
  chapters themselves or from `00-introduction.typ` (scheduled for rewrite). No "fix forward
  references in a retained chapter" work exists.
- **Exhaustive removal inventory (report §2)** with exact line regions per file is used verbatim
  for each phase's file/line targets.
- **Compile is the primary detector (report §5.3)**: an unresolved `@label` or an `#include` of a
  deleted file is a hard compile error, so `typst compile` exiting 0 is sufficient evidence of no
  dangling reference.
- **Two surfaced decision points (report §2.5, §3)**: (a) the two orphaned bib keys
  `brastmckie2025counterfactualworlds` / `brastmckie2021identity`, and (b) the dead
  `store`/`recall` notation helpers. Both are resolved in this plan toward strict "all and only"
  (delete), consistent with the user's "REMOVE III/IV entirely" scope decision.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consulted (no roadmap_path provided, roadmap_flag not set).

## Goals & Non-Goals

**Goals**:
- Produce a compiled manual containing only Parts I and II (no "PART III"/"PART IV" text).
- Rewrite the abstract, title-page Sources block, and `00-introduction.typ` roadmap/reading-guide
  into coherent two-part framing (clarity mandate, not just deletion).
- Delete `chapters/p5-counterfactual.typ`, `chapters/p5-constitutive.typ`, and
  `notation/constitutive-notation.typ`.
- Prune bibliography entries cited only by the removed parts (12-entry removed-only block, plus
  the two orphaned keys once the intro no longer cites them).
- Clean stale notation comments and dead `store`/`recall` code; sync `README.md`, `SYNC-MAP.md`
  (append-only historical note), and `sync-check-whitelist.txt`.
- Keep the document typst-compilable after every phase; end on a green build + sync-check + grep.

**Non-Goals**:
- Editing any retained Part I/II chapter content (`01-syntax.typ` … `p4-dual-verification.typ`,
  `06-notes.typ`, `ax-machine-appendix.typ`) beyond the single optional wording tweak in
  `p3-vlach-blstar.typ`.
- Rewriting `SYNC-MAP.md`'s historical per-chapter tables (append a dated note only — rewriting
  historical records would falsify them).
- Regenerating `generated/status.typ` / `generated/machine-appendix.*` (Lean-source-driven,
  independent of chapter structure — report §2.10, §5.3).
- Any Lean source changes.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A `#include` of a deleted file is left behind | H | L | Phase 1 removes both `#include` lines *before* Phase 2 deletes the files; compile after each phase catches a stray include as a hard error |
| Bib entry deleted while still cited → compile error | H | L | Phase 4 depends on Phases 1 and 3, which remove every citation site (deleted chapters' includes + intro sentences) *before* the entries are pruned |
| Intro rewrite leaves "four parts" prose above two items, reading as broken | M | M | Phase 3 treats Outline/How-to-Read as full restructures per report §4, not item deletions; verification greps intro for residual "four"/III/IV framing |
| Whitelist / backtick-comment desync fails sync-check Check 1 | M | L | Phase 5 deletes the `constitutive-notation.typ` whitelist line and the backtick comment reference together (report §2.9 option 1) |
| New warnings introduced by edits masked as pre-existing | L | L | Phase 5 diffs compile warnings against the report §5.1 baseline (font-substitution + two `angle.l`/`angle.r` deprecations only) |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 3 | -- |
| 2 | 2, 4 | 1 (Phase 2); 1, 3 (Phase 4) |
| 3 | 5 | 1, 2, 3, 4 |

Phases within the same wave can execute in parallel. Standard orchestration executes phases
sequentially by scanning for the next `[NOT STARTED]` heading; the wave table documents the
available parallelism and the true prerequisite chain.

### Phase 1: Reframe `BimodalReference.typ` into a two-part document [NOT STARTED]

**Goal**: Turn the main file into a coherent two-part reference — remove the Part III/IV dividers
and `#include` lines, and rewrite the abstract, title-page Sources block, and header comment so
the front matter genuinely describes a two-part bimodal manual. Removing the two `#include`s here
(before the files are deleted in Phase 2) keeps the compile green throughout.

**Tasks**:
- [ ] Header comment (lines 162-164): rewrite "Four-Part Textbook" / "Order: bimodal system → applications → counterfactual → constitutive" to two-part framing (bimodal system → applications).
- [ ] Sources block (lines 111-119): remove item 2 ("Counterfactual Worlds") and item 3 ("Identity and Aboutness"); renumber so item 4 (ProofChecker repo) becomes item 2. Reframe the block as "two papers + the Lean repo" per report §4.2.
- [ ] Abstract (lines 135-141): delete the Part III/IV sentence (line 141); keep/lightly edit the Part I/II sentence (139-140) so paragraphs read as a clean two-part close (report §4.3 — the easy case).
- [ ] Delete the Part III divider block (lines 215-224) and its `#include "chapters/p5-counterfactual.typ"` (line 226).
- [ ] Delete the Part IV divider block (lines 228-239) and its `#include "chapters/p5-constitutive.typ"` (line 241).
- [ ] Confirm the Part I divider (173-185) and Part II divider (200-209) scope paragraphs are untouched (already self-contained, no III/IV leakage — report §1.1).

**Timing**: 0.75 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/BimodalReference.typ` — header comment (162-164), Sources block (111-119), abstract (135-141), Part III divider+include (215-226), Part IV divider+include (228-241).

**Verification**:
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 with only the report §5.1 baseline warnings (the two `p5-*` files still exist but are no longer included, so no error).
- `pdftotext build/BimodalReference.pdf - | grep -i "PART III\|PART IV"` returns empty.
- `grep -n "p5-counterfactual\|p5-constitutive" BimodalReference.typ` returns empty.

---

### Phase 2: Delete the removed chapters and constitutive notation [NOT STARTED]

**Goal**: Physically remove the two chapter files and the notation file they exclusively import,
now that Phase 1 has removed every `#include` reference to them.

**Tasks**:
- [ ] Delete `Theories/Bimodal/typst/chapters/p5-counterfactual.typ` (504 lines).
- [ ] Delete `Theories/Bimodal/typst/chapters/p5-constitutive.typ` (382 lines).
- [ ] Delete `Theories/Bimodal/typst/notation/constitutive-notation.typ` (67 lines) — imported ONLY by the two chapters just deleted (report §2.3, grep-confirmed), so no live import remains.

**Timing**: 0.25 hours

**Depends on**: 1

**Files to modify**:
- Delete `chapters/p5-counterfactual.typ`, `chapters/p5-constitutive.typ`, `notation/constitutive-notation.typ`.

**Verification**:
- The three files no longer exist (`ls` / `test ! -e`).
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` still exits 0 (nothing references the deleted files at compile time; the `sync-check-whitelist.txt` entry still covers the yet-to-be-cleaned backtick comment, so no premature sync-check dependency).

---

### Phase 3: Rewrite `00-introduction.typ` roadmap and reading guide to two parts [NOT STARTED]

**Goal**: The substantial rewrite. Restructure the introduction from four-part to two-part
framing so the roadmap and reading guide read coherently, and remove the last two citation sites
for the orphaned bib keys. This is a genuine restructure per report §4.1, not sentence deletion.

**Tasks**:
- [ ] Opening paragraph (line 15): remove the "Two further extensions … tensed counterfactual logic @brastmckie2025counterfactualworlds … constitutive structure @brastmckie2021identity" sentence; replace with a bimodal-only closing sentence (or drop cleanly) so the paragraph still flows.
- [ ] Figure caption (line 91): remove/reword the dangling clause "…cross-history counterfactual structure is the subject of Part III"; per report §4.4, state it is out of scope for this book or drop the clause entirely.
- [ ] `== Outline` (lines 113-120): rewrite "The book proceeds in four parts" + 4 numbered items down to "two parts" + 2 items (Part I: The Bimodal System; Part II: Applications). Restructure the prose, do not just delete items 3-4.
- [ ] `== How to Read This Book` (lines 124-130): delete the "*The philosophical extensions.* Parts III and IV develop…" bullet (line 130); keep the other 4 bullets verbatim (spine, metatheory, comparative positioning, applications — all Part I/II, report §4.1).
- [ ] Confirm no other `brastmckie2025counterfactualworlds` / `brastmckie2021identity` citation survives in this file (these were the last two retained-document sites — report §2.2).

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/typst/chapters/00-introduction.typ` — line 15, line 91, Outline (113-120), How to Read (124-130).

**Verification**:
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 (the two bib entries still exist, so the now-removed citations do not break anything).
- `grep -niI "counterfactual\|constitutive\|four parts\|Part III\|Part IV" chapters/00-introduction.typ` returns empty.
- `grep -n "brastmckie2025counterfactualworlds\|brastmckie2021identity" chapters/00-introduction.typ` returns empty.

---

### Phase 4: Prune bibliography [NOT STARTED]

**Goal**: Remove all bibliography entries cited only by the removed parts, now that Phases 1 and 3
have eliminated every citation site. Resolve the surfaced decision toward strict "all and only".

**Tasks**:
- [ ] Delete the self-labeled removed-only block (lines 429-563): the "% Entries below imported for the Part III/IV …" comment header plus its 12 entries (`fine1975critical`, `fine2012counterfactuals`, `fine2012difficulty`, `fine2017truthmakercontent1`, `fine2017truthmakersemantics`, `lewis1973counterfactuals`, `lewis1979timesarrow`, `stalnaker1968theory`, `jackson1977causal`, `kripke1963semantical`, `goodman1947problem`) — grep-confirmed removed-only (report §2.5).
- [ ] Delete the two now-orphaned entries `brastmckie2025counterfactualworlds` (lines 21-30) and `brastmckie2021identity` (lines 33-43), which became uncited once Phase 3 removed the intro citations. Rationale: the user's scope says REMOVE III/IV "entirely," so drop the companion-paper citations too (report §2.5 decision point, resolved to delete).
- [ ] Leave `brastmckie2026possibleworlds` and all LTL/CTL/hybrid-logic/model-checking entries untouched (shared/retained — report §2.5).

**Timing**: 0.5 hours

**Depends on**: 1, 3

**Files to modify**:
- `Theories/Bimodal/typst/bibliography.bib` — remove lines 429-563 block, plus entries at lines 21-30 and 33-43.

**Verification**:
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 (removing uncited entries cannot break the compile; `ieee` non-`full` style prints only cited entries).
- `grep -n "brastmckie2025counterfactualworlds\|brastmckie2021identity\|fine2012counterfactuals\|lewis1973counterfactuals" bibliography.bib` returns empty.
- Rendered References section still contains the retained citations (visual/`pdftotext` spot-check unchanged for Part I/II refs).

---

### Phase 5: Notation cleanup, sync/docs, and final verification pass [NOT STARTED]

**Goal**: Finish the long tail of small mechanical edits (stale notation comments, dead code,
whitelist, repo docs) and enforce the global green bar. Grouped into one phase per the standard
budget; all edits here reference material already removed in Phases 1-4.

**Tasks**:
- [ ] `notation/bimodal-notation.typ` comments: reword/remove the stale references to `constitutive-notation.typ` (lines 13, 17-18) and the "Logos triangle usage in constitutive/counterfactual chapters" note (lines 22-25); reword the `store`/`recall` comment (lines 89-92) that mentions "Part III's tensed-counterfactual section" (report §2.4).
- [ ] `notation/bimodal-notation.typ` dead code: delete the `#let store(i) = …` / `#let recall(i) = …` definitions (lines 95-96) — fully dead after the cut (their only call sites were in the deleted `p5-counterfactual.typ`; `p3-vlach-blstar.typ` writes glyphs directly — report §3). Resolves the decision point toward strict "all and only".
- [ ] `sync-check-whitelist.txt`: delete line 34 (`notation/constitutive-notation.typ` whitelist entry) together with the backtick reference in the `bimodal-notation.typ` comment above (report §2.9 option 1 — delete both together so Check 1 stays clean).
- [ ] `README.md` (typst/): rewrite four-part framing to two-part — intro sentence (line 5), the 4-part table (lines 30-35, drop the III/IV rows), directory-tree listing (lines 44, 69-70, drop the `p5-*` entries). Mark the Follow-Up Tasks table task-317 row (line 116) as superseded/closed by task 371 rather than silently deleting (preserve audit trail — report §4.5).
- [ ] `SYNC-MAP.md`: append a short dated note at the top (matching the existing banner convention) stating task 371 cut Parts III/IV and the per-chapter tables below describe a now-superseded structure. Do NOT rewrite the historical tables (report §2.8).
- [ ] Optional wording tweak: `chapters/p3-vlach-blstar.typ` line 27 incidental "counterfactual … discourse" — reword only if desired for topical cleanliness; not a correctness requirement (report §2.6). If left, note it as an intentionally-retained grep hit.
- [ ] Run the full verification suite below and confirm the green bar.

**Timing**: 1 hour

**Depends on**: 1, 2, 3, 4

**Files to modify**:
- `Theories/Bimodal/typst/notation/bimodal-notation.typ` — comments (13, 17-18, 22-25, 89-92) and `store`/`recall` defs (95-96).
- `Theories/Bimodal/typst/sync-check-whitelist.txt` — remove line 34.
- `Theories/Bimodal/typst/README.md` — lines 5, 30-35, 44, 69-70, 116.
- `Theories/Bimodal/typst/SYNC-MAP.md` — prepend dated note only.
- `Theories/Bimodal/typst/chapters/p3-vlach-blstar.typ` — optional line 27 wording.

**Verification** (global green bar for the task):
- `cd Theories/Bimodal/typst && typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 with only the pre-existing font-substitution + two `angle.l`/`angle.r` deprecation warnings (report §5.1 baseline); no new warnings/errors.
- `bash scripts/typst-sync-check.sh` (from repo root) exits 0 — all 3 checks pass.
- `grep -rniI "counterfactual\|constitutive" Theories/Bimodal/typst/` returns only intentionally-retained hits (e.g. the dated `SYNC-MAP.md` note, and — if not reworded — `p3-vlach-blstar.typ:27`), never structural/roadmap/divider/include/bib hits.
- `pdftotext build/BimodalReference.pdf - | grep -i "PART III\|PART IV"` returns empty.

---

## Testing & Validation

- [ ] `typst compile BimodalReference.typ build/BimodalReference.pdf` exits 0 after every phase, with warning set matching the report §5.1 baseline.
- [ ] Compiled PDF outline/table-of-contents contains only Parts I and II.
- [ ] `bash scripts/typst-sync-check.sh` passes (all 3 checks) after Phase 5.
- [ ] `grep -rniI "counterfactual\|constitutive" Theories/Bimodal/typst/` returns only intentionally-retained hits.
- [ ] The three deleted files (`p5-counterfactual.typ`, `p5-constitutive.typ`, `constitutive-notation.typ`) are absent.
- [ ] No orphaned bib keys (`brastmckie2025counterfactualworlds`, `brastmckie2021identity`, the 12-entry block) remain in `bibliography.bib`.

## Artifacts & Outputs

- Revised `Theories/Bimodal/typst/BimodalReference.typ` (two-part front matter, no III/IV dividers/includes).
- Rewritten `Theories/Bimodal/typst/chapters/00-introduction.typ` (two-part roadmap + reading guide).
- Pruned `Theories/Bimodal/typst/bibliography.bib`.
- Cleaned `Theories/Bimodal/typst/notation/bimodal-notation.typ`, `sync-check-whitelist.txt`.
- Synced `Theories/Bimodal/typst/README.md`, `SYNC-MAP.md` (append-only note).
- Deleted: `chapters/p5-counterfactual.typ`, `chapters/p5-constitutive.typ`, `notation/constitutive-notation.typ`.
- Compiled `build/BimodalReference.pdf` containing only Parts I and II.
- Execution summary at `summaries/01_*.md` (written by the implementer).

## Rollback/Contingency

All changes are confined to `Theories/Bimodal/typst/` and are tracked in git. If a phase leaves
the document non-compilable and cannot be repaired quickly, `git restore` / `git checkout` the
affected files (or the whole `Theories/Bimodal/typst/` subtree) to the last green commit. Because
each phase ends on a verified green compile and is committed per the commit-per-green-substep
mandate, rollback granularity is per-phase. The deletions (Phase 2) are recoverable from git
history if the cut needs to be partially reversed.
