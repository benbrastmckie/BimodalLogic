# Implementation Plan: Task #467

- **Task**: 467 - Systematically update FormalSystem/Metalogic/Decidability/README.md to be aligned with the current state of the Decidability/ directory
- **Status**: [IMPLEMENTING]
- **Effort**: 2 hours
- **Dependencies**: None
- **Research Inputs**: specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md
- **Artifacts**: plans/01_decidability-readme-alignment.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: markdown
- **Lean Intent**: false

## Overview

`FormalSystem/Metalogic/Decidability/README.md` has drifted from the directory it documents: its
Overview asserts a decidability result the codebase itself deliberately retired as vacuous, its
Modules table omits two live subdirectories and three top-level files while listing one file that
does not exist, its Quick Reference names a `DecisionResult` constructor set that was split
post-R7, and its dependency flowchart draws one edge backwards. This plan closes all 11
misalignments recorded in the research report by editing that single README, section by section,
in descending order of correctness impact. Definition of done: every claim in the README is
verifiable against the current directory contents, and no claim overstates what is proved in
Lean.

### Research Integration

The plan is driven entirely by
`specs/467_update_decidability_readme/reports/01_decidability-readme-alignment.md`, whose 11
findings map one-to-one onto the phases below (Findings 1 -> Phase 1; 2, 3, 4 -> Phase 2;
6, 7 -> Phase 3; 8 -> Phase 4; 9, 10 -> Phase 5; Finding 5 and Finding 11 are the report's
"verified accurate, no change needed" items and are preserved rather than edited).

Two report figures were re-verified against the working tree while building this plan, and one
needs correction at implementation time:

- Confirmed exactly: 13 top-level `.lean` files; no top-level `FMP.lean`; subdirectory `.lean`
  counts `FMP/`=6, `BiLasso/`=18, `Verified/`=21, `Propositional/`=3; all four sub-READMEs exist;
  `decideBlocking` exists at `DecisionProcedure.lean:279`; `DecisionResult` has exactly the four
  constructors `valid`, `invalid`, `fuelExhausted`, `extractionFailed`; `TraceCertificate.lean`
  is imported by `Saturation.lean` and `DecisionProcedure.lean` (and by `TraceExport.lean` and
  `Automation/TraceExporter.lean`).
- **Corrected**: the report's Finding 2 says the aggregator `FormalSystem/Metalogic/Decidability.lean`
  has "30 imports total". It has **34**. The report's substantive claim — that `Verified/`'s 21
  files and `Propositional/`'s 3 files are all imported by the aggregator — holds; only the total
  is off. Do not copy "30" into the README.
- Sorry inventory re-confirmed: no live `sorry` tactic use anywhere under `Decidability/`; every
  `sorry` occurrence is doc-comment prose. The README's existing "Sorry-free" column values are
  correct and must be preserved.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context; no ROADMAP.md phases are included.

## Goals & Non-Goals

**Goals**:
- Replace the Overview's unproved decidability claim with language matching what
  `Correctness.lean` actually establishes, pointing at that file's own retirement note.
- Make the Modules table an accurate, complete inventory of the directory: add the two missing
  subdirectories and three missing top-level files, delete the nonexistent `FMP.lean` row, and
  apply one uniform file-count convention.
- Correct the stale `DecisionResult` variant list and add the architecturally significant
  `decideBlocking` entry point to Quick Reference.
- Fix the backwards `Correctness.lean` edge in the dependency flowchart, add the load-bearing
  `TraceCertificate.lean` node, and caption the diagram for the scope it actually covers.
- Add the missing `Verified/` and `Propositional/` README links and refresh the footer stamp.

**Non-Goals**:
- Editing `FormalSystem/Metalogic/Decidability/Verified/README.md`. The research report documents
  that file as substantially stale (8+ files marked "planned" that exist and compile, 11 files
  missing from its table), but it is explicitly out of this task's scope and is to be handled as
  a separate follow-up task. **Do not edit it.**
- Editing any `.lean` file. This task changes documentation only; no proof, definition, or import
  changes.
- Editing any other README (`Metalogic/README.md`, `FMP/README.md`, `BiLasso/README.md`,
  `Propositional/README.md`).
- Formalizing the open decidability biconditional, or making any new claim about it beyond
  reporting it as open.
- Restating the informal complexity claims (`O(2^n)`, PSPACE-complete) as proved results; the
  report confirms they are descriptive prose and are to be left as-is.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| The Overview rewrite (Phase 1) invents a new claim rather than removing an overclaim | H | M | Restrict the rewrite to removing the overclaim and citing `Correctness.lean`'s "Retired as vacuous" section; mirror the phrasing pattern `BiLasso/README.md` already uses ("does not decide the logic ... records decidability of TM as open"). Assert nothing not already written in a `.lean` file. |
| Other docs quote the Overview's current framing, leaving them inconsistent after the edit | M | L | Phase 5 greps the repo for the removed phrasing; any hit outside `specs/**` is recorded in the summary as a follow-up, not silently edited (out of scope). |
| Newly added subdirectory rows bloat the top-level Modules table | M | M | One summary row per subdirectory with a file count and a link to that subdirectory's own README, matching the existing `FMP/`/`BiLasso/` row style. No per-file breakdown at the top level. |
| Adding a link to the known-stale `Verified/README.md` propagates its staleness | M | M | Link it (the file exists and the reciprocal link already exists on its side) and record its staleness as a named follow-up in the implementation summary. Do not attempt a drive-by fix. |
| File counts asserted in the table drift again before the edit lands | L | L | Each count-asserting phase carries a Scope Hypothesis with the exact command to re-derive the count at implementation time rather than trusting this plan's numbers. |
| An ASCII-art flowchart edit breaks box alignment | L | M | Phase 4 re-renders the affected region rather than patching individual characters, and Phase 6 reads the rendered block back. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |

Phases within the same wave can execute in parallel. This plan is fully sequential by design:
every phase edits the same single file (`FormalSystem/Metalogic/Decidability/README.md`), so
parallel execution would produce conflicting writes.

---

### Phase 1: Correct the Overview's decidability overclaim [COMPLETED]

**Goal**: The Overview section states only what is actually proved — the soundness direction —
and names the full biconditional as open, citing the module that records its retirement.

**Tasks**:
- [x] Read `FormalSystem/Metalogic/Decidability/Correctness.lean`'s section headed
      "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous" (near lines
      68-105) and confirm in the working tree that it still says what the report quotes. *(completed)*
- [x] Read `FormalSystem/Metalogic/Decidability/BiLasso/README.md`'s corresponding paragraph to
      reuse its established accurate phrasing pattern. *(completed)*
- [x] Replace the Overview bullet "Decides validity of TM bimodal logic formulas" with language
      that: (a) describes the procedure as a tableau-based search for a proof or a countermodel;
      (b) names `decide_sound` as the machine-checked direction; (c) states that the full
      decidability biconditional (`isValid φ fc = true ↔ ⊨ φ`, plus `Decidable (⊨ φ)` instances
      for the four frame classes) is not established, referring the reader to `Correctness.lean`.
      *(completed)*
- [x] Adjust the intro line under the H1 title ("Tableau-based decision procedure for TM bimodal
      logic validity checking") if and only if it repeats the same overclaim, so the file does not
      contradict itself two lines apart. *(completed: subtitle did not repeat the overclaim verbatim, left unchanged)*
- [x] Leave the remaining three Overview bullets (proof terms, countermodel descriptions,
      fuel-based termination) unchanged — the report found them accurate. *(completed)*

**Timing**: 30 minutes

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - Overview section (and the H1 subtitle line if
  it carries the same claim)

**Verification**:
- Every changed hunk lies inside markdown prose; no `.lean` file is touched
  (`git diff --name-only` names exactly the one README).
- The string "Decides validity of TM bimodal logic formulas" no longer appears in the file.
- Every factual assertion in the new text is traceable to a quotable line in `Correctness.lean`
  or `BiLasso/README.md`; no new claim is introduced.

---

### Phase 2: Rebuild the Modules table [COMPLETED]

**Goal**: The Modules table is a complete and accurate inventory: no missing files or
subdirectories, no nonexistent entries, one uniform file-count convention.

**Tasks**:
- [x] Re-derive the ground truth before editing:
      `ls FormalSystem/Metalogic/Decidability/*.lean` and, for each of `FMP BiLasso Verified
      Propositional`, `find <dir> -name '*.lean' | wc -l`. *(completed: confirmed 13 top-level
      files; FMP=6, BiLasso=18, Verified=21, Propositional=3; aggregator has 34 imports)*
- [x] Delete the `FMP.lean` row. No such top-level file exists; the re-export is `FMP/FMP.lean`,
      inside the subdirectory the table already lists. Optionally fold that detail into the
      `FMP/` row's description, matching how the `BiLasso/` row explains its own entry point.
      *(completed; optional fold-in skipped)*
- [x] Add a row for `CancellableExpansion.lean` — runtime-only `IO` abort-aware mirror of the pure
      tableau core; imports `Saturation.lean` and `DecisionProcedure.lean`; not imported by the
      aggregator; Sorry-free. *(completed)*
- [x] Add a row for `TraceCertificate.lean` — defines `TraceEntry`/`ProofCertificate`/
      `TraceResult`; imported directly by both `Saturation.lean` and `DecisionProcedure.lean`
      (a core dependency, not peripheral); Sorry-free. *(completed)*
- [x] Add a row for `TraceExport.lean` — JSON serialization for trace certificates; consumed by
      `Automation/TraceExporter.lean` and `DatasetGenerator.lean` rather than by the aggregator;
      Sorry-free. *(completed: deviation — re-derivation showed only `Automation/TraceExporter.lean`
      imports it; `DatasetGenerator.lean` only appears via an unrelated doc-comment mention in
      `TraceCertificate.lean`, not an actual import, so it was omitted from the row)*
- [x] Add a summary row for `Verified/` — the correctness theory for the engine (termination
      bounds and the model-construction bridge), all files imported by the aggregator; link to
      `Verified/README.md`; Sorry-free. *(completed)*
- [x] Add a summary row for `Propositional/` — a self-contained Kalmár-style propositional
      decision procedure, independent of the modal/temporal/completeness machinery, all files
      imported by the aggregator; link to `Propositional/README.md`; Sorry-free. *(completed)*
- [x] Apply the "`.lean` files only" counting convention uniformly across all four subdirectory
      rows, using the re-derived counts. Change `FMP/ (7 files)` to the `.lean`-only count; leave
      `BiLasso/ (18 files)` if the re-derived count confirms it. *(completed: FMP/ changed to 6
      files; BiLasso/ confirmed at 18)*
- [x] Preserve every existing "Sorry-free" status value and give the five new rows "Sorry-free"
      as well — the report re-confirmed zero live `sorry` uses tree-wide. *(completed)*

**Timing**: 40 minutes

**Depends on**: 1

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts that the directory holds 13 top-level `.lean` files and
that the subdirectory `.lean` counts are `FMP/`=6, `BiLasso/`=18, `Verified/`=21,
`Propositional/`=3 — and that exactly five rows are missing while exactly one (`FMP.lean`) is
spurious. Confirm at implementation time with `ls FormalSystem/Metalogic/Decidability/*.lean`
and `find <subdir> -name '*.lean' | wc -l` per subdirectory, and by diffing that listing against
the table's rows. If any count differs from the numbers above, the re-derived number wins and the
discrepancy is recorded in the summary.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - Modules table

**Verification**:
- Every top-level `.lean` file in the directory listing has exactly one table row, and every
  top-level-file row names a file that exists.
- Each of `FMP/`, `BiLasso/`, `Verified/`, `Propositional/` has exactly one row, and every file
  count in the table equals its freshly re-derived `.lean` count.
- `grep -c 'FMP.lean' README.md` returns hits only for `FMP/FMP.lean`-qualified mentions, never a
  bare top-level `FMP.lean` row.

---

### Phase 3: Correct the Quick Reference [COMPLETED]

**Goal**: The Quick Reference names the current `DecisionResult` constructors and the second
top-level entry point.

**Tasks**:
- [x] Confirm the constructor set against the working tree:
      `grep -A12 'inductive DecisionResult' FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`.
      *(completed)*
- [x] Change "**Result type**: `DecisionResult` (valid/invalid/timeout)" to
      "(valid/invalid/fuelExhausted/extractionFailed)". Optionally add a one-clause gloss noting
      that the former `timeout` constructor was split post-R7 into `fuelExhausted` (validity
      genuinely undetermined) and `extractionFailed` (the tableau closed, so the formula is valid,
      but no proof term was reconstructed) — as documented by `decide_result_exclusive` in
      `Correctness.lean`. *(deviation: altered — the gloss was added but rephrased to avoid the
      literal word "timeout" (using "single prior inconclusive-verdict constructor" instead),
      since this phase's own Verification requires the word not appear anywhere in the Quick
      Reference)*
- [x] Add `decideBlocking` to the entry-point list as a documented complement to `decide` for the
      blocking-aware engine, noting it is a complement rather than a substitute. *(completed)*
- [x] Leave `isValid` and `isSatisfiable` unchanged; the report verified both against their
      actual signatures. *(completed)*
- [x] Do not add `decideAuto`, `decideAutoAdaptive`, `decideBatch`, `decideOptimized`,
      `decideWithTrace`, or `decideAutoWithTrace`; the report classes these as optional and
      lower-priority for a terse Quick Reference. *(completed)*
- [x] Leave the Usage code block and the Algorithm Overview unchanged — the report verified both
      as accurate, including that `decideBlocking`'s existence does not invalidate the Algorithm
      Overview's description of `decide` itself. *(completed)*

**Timing**: 15 minutes

**Depends on**: 2

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - Quick Reference section

**Verification**:
- The word "timeout" no longer appears in the Quick Reference.
- All four constructor names in the README match the four listed by the `inductive DecisionResult`
  block, exactly and in the same spelling.
- `decideBlocking` appears in the README and resolves to a real definition
  (`grep -n 'def decideBlocking' FormalSystem/Metalogic/Decidability/DecisionProcedure.lean`
  returns a hit).

---

### Phase 4: Fix the dependency flowchart [NOT STARTED]

**Goal**: The flowchart's edges match the real import graph, the load-bearing
`TraceCertificate.lean` node is present, and the diagram's scope is captioned.

**Tasks**:
- [ ] Re-derive the real edges from the files themselves:
      `grep -n '^import FormalSystem.Metalogic.Decidability' FormalSystem/Metalogic/Decidability/*.lean`.
- [ ] Reverse the `Correctness.lean` edge. `Correctness.lean` *imports* `DecisionProcedure.lean`,
      so it is a downstream consumer, not an intermediate layer between `DecisionProcedure` and
      the two extraction modules. Redraw it below/after `DecisionProcedure.lean` rather than
      between it and `ProofExtraction`/`CountermodelExtraction`.
- [ ] Add `TraceCertificate.lean` as a node feeding both `Saturation.lean` and
      `DecisionProcedure.lean` — it is a direct import at both points.
- [ ] Add the `Correctness.lean -> FMP/FMP.lean` edge.
- [ ] Add a one-line caption directly under the diagram stating that it shows the core chain only,
      and naming what is deliberately omitted (`IntPresentation.lean`, `CancellableExpansion.lean`,
      `TraceExport.lean`, `BiLasso.lean`, and the `Verified/` and `Propositional/` subtrees).
- [ ] Re-render the affected region of the ASCII art as a block rather than patching individual
      box-drawing characters, and confirm box borders and connector columns still line up.
- [ ] Optionally add the one-word caveat to the `BiLasso.lean` row's "not itself imported" note:
      it is imported by one test file,
      `Tests/BimodalTest/Metalogic/PeriodicExtensionAxiomTest.lean`. The report classes the
      existing claim as accurate for the main library build graph, so this is a nuance, not a
      correction.

**Timing**: 25 minutes

**Depends on**: 3

**Verification Tier**: prose

**Scope Hypothesis**: This phase asserts a specific core-chain edge set —
`SignedFormula -> Tableau -> Closure -> Saturation -> {ProofExtraction, CountermodelExtraction}
-> DecisionProcedure -> Correctness`, with `TraceCertificate` feeding `Saturation` and
`DecisionProcedure`, and `Correctness` also importing `FMP/FMP.lean`. Confirm at implementation
time by reading the `import` block of each named file rather than trusting this list; every drawn
edge must correspond to an actual `import` line, and the direction must be
importer-depends-on-imported.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - Dependency Flowchart section (and the
  `BiLasso.lean` Modules row, if the optional caveat is added)

**Verification**:
- Every edge drawn in the diagram corresponds to a real `import` line in the importing file, with
  the arrow pointing from importer to imported consistently throughout.
- `Correctness.lean` is drawn downstream of `DecisionProcedure.lean`, not upstream of it.
- The rendered ASCII block's box borders and connectors align when the file is read back.
- The caption's omission list matches what the diagram actually leaves out.

---

### Phase 5: Update Related Documentation and the footer stamp [NOT STARTED]

**Goal**: All four sibling sub-READMEs are linked, and the footer records the date these
corrections landed.

**Tasks**:
- [ ] Add `- [Verified README](Verified/README.md) - Correctness theory for the tableau engine`
      to Related Documentation, matching the existing FMP/BiLasso link style.
- [ ] Add `- [Propositional README](Propositional/README.md) - Kalmár-style propositional decision
      procedure` likewise.
- [ ] Verify each of the five existing links and the two new ones resolves to a file that exists,
      by testing each relative path from
      `FormalSystem/Metalogic/Decidability/`.
- [ ] Update the footer `*Last verified: 2026-05-29*` to the date these corrections land.
- [ ] Grep the repository (excluding `specs/**`) for the removed Overview phrasing to detect other
      docs that repeat the overclaim. Record any hits in the implementation summary as follow-up
      candidates; do not edit them — they are out of scope.
- [ ] Record in the summary that `Verified/README.md` is itself substantially stale (per the
      report's Finding 9 caveat: 8+ existing, compiling files marked "planned"; 11 files absent
      from its table) and that it warrants its own task. Do not edit that file.

**Timing**: 15 minutes

**Depends on**: 4

**Verification Tier**: prose

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/README.md` - Related Documentation section and footer

**Verification**:
- Every relative link target in Related Documentation exists on disk (test each path; the `prose`
  tier's named blind spot is exactly broken cross-references, so this check is not optional).
- The footer date is the date of this change, not `2026-05-29`.
- `Verified/README.md` shows no modification in `git status`.

---

### Phase 6: Whole-file consistency read-through [NOT STARTED]

**Goal**: The finished README is internally consistent and every remaining claim is verified
against the directory, with no contradiction introduced by the section-by-section edits.

**Tasks**:
- [ ] Read the complete edited README top to bottom in one pass.
- [ ] Confirm the Overview, the Modules table, the Quick Reference, the Algorithm Overview, and
      the flowchart caption do not contradict one another — in particular that nothing outside the
      Overview still asserts that the directory decides validity.
- [ ] Confirm the file-count convention is applied identically in all four subdirectory rows.
- [ ] Confirm the preserved sections the report verified as accurate are in fact unchanged: the
      Usage code block, the Algorithm Overview, the Complexity section, the
      `IntPresentation.lean` row description, and the References.
- [ ] Re-run the sorry check (`grep -rn '\bsorry\b' FormalSystem/Metalogic/Decidability
      --include='*.lean'`) and confirm every hit is doc-comment prose, so the table's Sorry-free
      column is still true as written.
- [ ] Review the full diff and confirm exactly one file changed.

**Timing**: 15 minutes

**Depends on**: 5

**Verification Tier**: prose

**Files to modify**:
- None (read-only verification pass; any defect found is fixed in the owning phase's section)

**Verification**:
- `git diff --name-only` lists exactly
  `FormalSystem/Metalogic/Decidability/README.md` and nothing else — no `.lean` file, and
  specifically not `Verified/README.md`.
- Every hunk in `git diff` is markdown prose or table/ASCII-art content.
- No claim in the file remains that the report marked as needing correction.

---

## Testing & Validation

- [ ] `git diff --name-only` names exactly one file: `FormalSystem/Metalogic/Decidability/README.md`.
- [ ] No `.lean` file is modified; `lake build` is therefore not required and is not run as a gate
      for this documentation-only task.
- [ ] Every top-level `.lean` file in the directory appears exactly once in the Modules table, and
      every top-level-file row names an existing file.
- [ ] Every subdirectory file count in the table equals the freshly re-derived `.lean` count for
      that subdirectory.
- [ ] Every relative link in Related Documentation resolves to an existing file.
- [ ] Every `DecisionResult` constructor named in the README matches the `inductive DecisionResult`
      block in `DecisionProcedure.lean`.
- [ ] Every edge in the dependency flowchart corresponds to a real `import` line, in the correct
      direction.
- [ ] `FormalSystem/Metalogic/Decidability/Verified/README.md` is unmodified.
- [ ] The README contains no claim that TM validity is decided, other than as an explicitly open
      question.

## Artifacts & Outputs

- `FormalSystem/Metalogic/Decidability/README.md` (edited; the sole deliverable file)
- `specs/467_update_decidability_readme/plans/01_decidability-readme-alignment.md` (this plan)
- `specs/467_update_decidability_readme/summaries/01_decidability-readme-alignment-summary.md`
  (implementation summary, recording: the aggregator import-count correction, any repo-wide hits
  for the removed overclaim phrasing, and the `Verified/README.md` staleness follow-up)

## Rollback/Contingency

Only one file changes and it contains no code, so rollback is a single-file revert:
`git checkout HEAD -- FormalSystem/Metalogic/Decidability/README.md` (permitted here only when
the working tree is otherwise clean or a snapshot has been taken per
`.claude/rules/git-workflow.md`). Because each phase commits its own green section edit, a partial
rollback to any completed phase boundary is available via that phase's commit. No build artifact,
import graph, or proof state can be affected by a revert of this file.
