# Implementation Plan: Triage the zero-occurrence declarations C17 reports

- **Task**: 588 - Triage the zero-occurrence declarations C17 reports
- **Status**: [IMPLEMENTING]
- **Effort**: 13.5 hours
- **Dependencies**: 585 (warning burn-down, completed), 591 (Automation export-name consolidation, archived), 594 (in-library smoke-test relocation, archived) -- all three have landed, so the census is measurable against a settled tree
- **Research Inputs**: `specs/588_triage_zero_occurrence_declarations/reports/02_c17-zero-occurrence-triage.md`; `specs/588_triage_zero_occurrence_declarations/reports/01_dead-declaration-triage.md`
- **Artifacts**: plans/02_c17-census-filter-and-triage.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

C17 reports a census of declarations whose base identifier occurs on no other line in the
repository. The number has grown to 1,020 and has never been triaged. Research measured the
census exactly (`tools/c17_triage.py` reproduces C17's 1,020) and established that the known
false-positive classes account for only 21% of it: 792 declarations survive every mechanism that
can defeat a textual scan, 704 of them plain unattributed theorems with no indirect-reachability
story at all. The deliverable is therefore a classification plus two durable changes to the
instrument, not a deletion spree: extend C17's counting rule so the number it prints is the
number that matters (1,020 -> 771 with a separate 47-row Boneyard-only sub-count), then execute
only the unambiguous deletion clusters (the 81 `def` survivors) and record a reasoned disposition
plus follow-up proposals for everything contentious. Done means: the harness is green with
C2/C14 baselines unmoved, C15 anchors unbroken and C21 intact; C17's drop is accounted for line
by line; and every one of the 771 post-filter survivors carries a recorded disposition.

### Research Integration

Findings carried directly into the phase structure:

- **F1/F3/F4** -- the tier stratification (T0 parse artifact 11, T1 `instance` 48, T2 `@[simp]`
  145, T3 custom simp set 12, T4 corpus-external 12, SURVIVOR 792) is the input to Phases 3, 4
  and 7. T4 is the safety finding: seven flagged names are pinned inside
  `scripts/check-module-invariants.sh` itself (the C2/C14 `#print axioms` heredocs) and five are
  cited in `typst/chapters/*.typ` -- corpora C17 does not scan. Phase 3 widens the corpus so this
  class stops being reported before any deletion phase runs.
- **F6/D1** -- the disputed `release_unfold` reading is resolved *against* the review by this
  plan: the Boneyard hypothesis is false (zero references to any of the 12 flagged
  `*_fold`/`*_unfold` names in `Boneyard/RetiredTactics/Normalization.lean`), and the 12/19 split
  inside the 31-member `formula_unfold`/`formula_fold` families tracks which members happen to
  have a `#check` row in `Tests/BimodalTest/Automation/NormalizationTest.lean`, not usage. The
  families are a deliberately maintained public API surface (`NormalizationAttr.lean` exists
  solely to register them, with a dedicated test file exercising both directions), so all 31 are
  kept. Deleting the 12 is an explicit Non-Goal.
- **F7/D3** -- C17's occurrence corpus is widened (`.typ`, `scripts/*.sh`) and never narrowed.
  A comment-stripped code-only corpus takes the census to 1,827; 818 declarations are held alive
  by prose alone, and a census that reports them would be less actionable, not more.
- **R5** -- excluding T2's 145 `@[simp]` rows hides a population that may contain genuinely
  unused simp lemmas. Phase 6 records the handoff to the unused-simp burn-down explicitly so
  neither effort assumes the other covers it.

**One research finding is corrected by this plan (verified by direct file read, not deferred):**
R2 recommends adding a new import-reachability check for the 10 orphan modules on the grounds
that "nothing currently reports it". That is not accurate. C6 already performs exactly this walk
-- it seeds reachability from every `lean_lib` and `lean_exe` root in `lakefile.toml`, fails when
an unreachable live module is absent from `scripts/module-invariants-manifest.txt`, fails on a
phantom or now-reachable entry, and compile-checks each manifested module in isolation. All ten
modules named in F5 are already listed in that manifest (verified: all ten match exactly; the
manifest holds 15 entries total). A new check would duplicate C6 and trip its own
stale-manifest branch. What is genuinely unmeasured is the *declaration count* behind those
modules -- roughly 91 declarations sit outside the build graph with no instrument reporting their
size. Phase 2 therefore reconciles the finding with C6 and adds that count to C6's existing INFO
line, instead of adding a check.

### Prior Plan Reference

No prior plan. Report `01_dead-declaration-triage.md` is a pre-research sweep, superseded by
`02_c17-zero-occurrence-triage.md` and used only as corroboration.

### Roadmap Alignment

No `roadmap_path` was supplied in this dispatch and no ROADMAP.md was consulted.

## Goals & Non-Goals

**Goals**:
- Extend C17's counting rule permanently so its headline number excludes the six known
  false-positive classes and carries a separate Boneyard-only sub-count (expected 1,020 -> 771,
  with 47 alongside), with the new rule documented in the script header and in
  `docs/development/MODULE_INVARIANTS.md`.
- Remove the 196 phantom declarations produced by the comment-blind declaration regex from the
  scanned-count denominator that C17, C19 and C23 share.
- Reconcile the import-orphan finding with C6's existing manifest and surface the
  unreachable-declaration count that nothing reports today.
- Record a disposition for every one of the 771 post-filter survivors, at cluster granularity.
- Execute the unambiguous deletions only: the `def` survivors, in three directory-scoped batches,
  each verified by `lake build`, `lake build BimodalTest` and the full invariant harness.
- Leave a written follow-up proposal for every contentious cluster.

**Non-Goals**:
- Gating C17 (D2 -- it stays reporting-only; a textual census with a 21% known-false-positive
  rate must never affect the exit code, and no `ENFORCE_C17` flag is introduced).
- Narrowing C17's occurrence corpus to code-only (D3/F7).
- Deleting the 12 flagged `formula_unfold`/`formula_fold` members, or any member of those
  31-declaration families (D1). The correct unit of any future retirement decision is the whole
  family plus both `register_simp_attr` declarations.
- Deleting or retiring the 683 `theorem` survivors, the 6 `structure` survivors, or the 47
  Boneyard-only-referenced declarations in this task -- these are dispositioned and handed off.
- Adding a new import-reachability check (superseded by the C6 reconciliation above).
- Introducing any `sorry` or axiom. Every change here is a deletion, a script filter, or a
  reporting change; a survivor that turns out to be load-bearing is kept with the reason
  recorded, never stubbed.
- Creating the follow-up tasks themselves. Phase 11 writes ready-to-run proposals; task creation
  is a user/orchestrator action.
- Writing the recommended `indirect-reachability.md` agent-context file. This repository has no
  `agent-system/extensions/` source store, so the correct target is ambiguous; it is recorded as
  a follow-up proposal instead.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Deleting a T4 row breaks the C2/C14 axiom baselines (7 names pinned inside the invariant script itself) | H | M | Phase 3 widens the corpus to `scripts/*.sh` and `typst/**/*.typ` *before* any deletion phase runs; every deletion batch additionally diffs its name list against `grep -F -f <names> scripts/check-module-invariants.sh typst/chapters/*.typ` and aborts on a hit |
| A C15 paper anchor cited only from the Typst manual is silently broken | H | M | Same corpus widening (Phase 3); Phase 3 is a hard prerequisite of Phases 8-10 through the dependency chain |
| Census line numbers go stale on the first edit, so a second batch deletes the wrong line | H | H | Never batch from a stored TSV. Every deletion phase regenerates the census first; `tools/c17_census.tsv` is a snapshot, never an input to a later batch |
| Deleting a `def` breaks a `lean_exe` root that `lake build` does not elaborate (C25's territory) | M | M | Per-batch verification runs the full harness, not just `lake build`; `Automation/ContrastiveGeneratorMain.lean` and `Automation/DatasetGenerator.lean` sit next to exe roots and are called out in Phase 10 |
| Changing the shared declaration regex flips C19's or C23's pass/fail state (C23 is gated by `ENFORCE_C23`) | M | M | Phase 5 records each check's status and count before and after, and treats any status change as a phase failure requiring investigation, not a new baseline |
| Excluding T1 `instance` rows hides a genuinely unused instance | L | M | Accepted, consistent with C17's existing same-base-name policy: for a never-gating census the safe direction of error is under-reporting. Recorded in the documentation change (Phase 6) |
| Excluding T2 `@[simp]` rows hides genuinely unused simp lemmas | M | M | Phase 6 records an explicit handoff note naming the 145-row population and assigning it to the unused-simp burn-down rather than absorbing it silently |
| The 771/47 predictions do not reproduce after the filters land | M | L | Every count in this plan is a Scope Hypothesis confirmed at implementation time; a divergence is investigated and the plan's number corrected, never papered over |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6, 7 | 4, 5 |
| 7 | 8 | 6, 7 |
| 8 | 9 | 8 |
| 9 | 10 | 9 |
| 10 | 11 | 10 |

Phases within the same wave can execute in parallel. Phases 6 and 7 are the only parallel pair:
Phase 6 edits `docs/development/MODULE_INVARIANTS.md` and the script's C17/C6 header comments,
Phase 7 writes only under `specs/588_triage_zero_occurrence_declarations/` -- disjoint file
territories. Every other phase is serialized because it either edits
`scripts/check-module-invariants.sh` (single-file contention) or consumes a census that the
previous phase invalidates.

---

### Phase 1: Baseline capture and census re-verification [COMPLETED]

**Goal**: Establish the measured before-state that every later phase's accounting is diffed
against, and confirm the research census still reproduces on the current tree.

**Tasks**:
- [x] Run `bash scripts/check-module-invariants.sh` and save the complete output to
      `specs/588_triage_zero_occurrence_declarations/tools/baseline-harness.txt`. *(completed -- exit 0, ALL CHECKS PASSED)*
- [x] Record, from that output: C17's headline count and its scanned-declaration denominator;
      C19's and C23's counts and pass/fail state; C2, C6, C14, C15, C21 and C28 states; the
      overall `FAILURES` total and exit code. *(completed -- C17 does not print a denominator, so it
      was measured directly with C17's own regex: 11,046 matched lines, 10,850 real, 196 phantom)*
- [x] Run `python3 specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py --summary`
      and confirm the tier table still matches the research report
      (T0 11, T1 48, T2 145, T3 12, T4 12, SURVIVOR 792 of 1,020). *(completed -- exact match)*
- [x] If the census has moved, regenerate `tools/c17_census.tsv` and record the delta and its
      cause in the baseline file before proceeding. Do not proceed on an unexplained delta.
      *(completed -- census has not moved; no regeneration needed)*
- [x] Confirm dependencies 591 and 594 have landed (both are under `specs/archive/`), since both
      change C17 occurrence counts. *(completed -- both present under specs/archive/)*

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: local

**Scope Hypothesis**: the census is 1,020 over 10,850 real declarations (11,046 as C17 currently
counts them), stratified T0 11 / T1 48 / T2 145 / T3 12 / T4 12 / SURVIVOR 792. Confirm by
running `c17_triage.py --summary` and cross-checking against
`bash scripts/check-module-invariants.sh --no-build | grep C17`; the two must agree exactly, as
they did at research time.

**Files to modify**:
- `specs/588_triage_zero_occurrence_declarations/tools/baseline-harness.txt` - new; full
  pre-change harness output plus the recorded per-check baseline.
- `specs/588_triage_zero_occurrence_declarations/tools/c17_census.tsv` - regenerated only if the
  census has moved.

**Verification**:
- `baseline-harness.txt` exists and contains a complete harness run with its exit code recorded.
- The stratifier's total equals C17's printed count exactly.

---

### Phase 2: Import-orphan reconciliation with C6 [COMPLETED]

**Goal**: Close research finding F5/R2 correctly -- confirm C6 already covers all ten orphan
modules, and add the one thing genuinely missing, the declaration count behind them.

**Tasks**:
- [x] Verify each of the ten modules named in F5 appears verbatim in
      `scripts/module-invariants-manifest.txt`, and that C6 passes with
      `all N unreachable live module(s) are manifested`. *(completed -- all ten match exactly;
      C6 prints `all 15 unreachable live module(s) are manifested`, the same pass branch as the
      baseline)*
- [x] Record in the phase notes that R2's "nothing currently reports it" is superseded: C6's
      reachability walk is the existing instrument, and a second check would trip C6's own
      stale-manifest branch. *(completed -- see Phase Notes below)*
- [x] Extend C6's reporting (not its gating) to print the aggregate declaration count and line
      count carried by the manifested unreachable modules, so the size of the out-of-graph
      population is visible at every gate. *(completed)*
- [x] Re-run the harness; confirm C6's pass/fail state is unchanged and only its INFO text moved.
      *(completed -- full harness exit 0; the ONLY line differing from `baseline-harness.txt` is
      the new INFO line)*

**Timing**: 1 hour

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: all 10 F5 modules are already manifested (verified at plan time by exact
match against all 15 manifest entries) and carry roughly 91 declarations across ~2,018 lines.
Confirm at implementation time by the new INFO line's own output; if the declaration count
differs materially from 91, record the measured number and the reason rather than the predicted
one.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C6 block (reachability/rot-guard section, near the
  `all N unreachable live module(s) are manifested` pass line): add the declaration/line count to
  the INFO output.

**Verification**:
- C6 still passes, with the same pass branch taken as in the baseline.
- The new INFO line prints a non-zero declaration count and a module count matching the manifest.
- No other check's output changed relative to `baseline-harness.txt`.

#### Phase Notes (measured at implementation time)

**R2 is superseded, and the record says so explicitly.** Research recommended adding a new
import-reachability check for the ten orphan modules because "nothing currently reports it".
C6 already performs exactly that walk: it seeds reachability from every `lean_lib` and
`lean_exe` root in `lakefile.toml`, fails on an unreachable live module missing from
`scripts/module-invariants-manifest.txt`, fails on a phantom entry, fails on an entry that has
become reachable, and compile-checks each manifested module in isolation. All ten F5 modules are
already manifested -- verified name by name against the manifest's fifteen entries. A second
check would duplicate that walk and trip C6's own stale-manifest branch. The one thing genuinely
unreported was the SIZE of the out-of-graph population, so the size is what was added, as an INFO
line, with no change to what C6 gates on.

**Measured, replacing the plan's estimate.** The Scope Hypothesis predicted "roughly 91
declarations across ~2,018 lines" for the ten FormalSystem modules. Line count matches exactly;
the measured declaration count is **89**, not 91. The difference is comment-awareness: the
research report's per-module table was produced with the comment-blind regex and double-counts
two declaration-shaped lines inside comments (one in `BiLasso/Orbit.lean`, one in
`BiLasso/Agreement.lean`) -- the same phantom class Phase 3 removes from C17. The new INFO line
uses the comment-aware count, so it agrees with C17's post-Phase-3 denominator rather than
contradicting it.

New output line, verbatim:

```
INFO  C6   15 manifested module(s) carry 128 declaration(s) across 3104 line(s) outside the build graph (10 FormalSystem module(s): 89 declaration(s), 2018 line(s))
```

---

### Phase 3: C17 filter set, part 1 -- comment-aware regex and widened corpus [COMPLETED]

**Goal**: Fix the two classes that are wrong rather than merely noisy: phantom declarations
parsed out of comments (T0), and the load-bearing references C17 cannot see because they live
outside its corpus (T4).

**Tasks**:
- [x] In C17's Python block, strip comments before matching the declaration regex and skip lines
      inside `/- ... -/` blocks (including docstring blocks), so a continuation line such as
      `lemma premises. -/` no longer parses as a declaration. *(completed -- new `strip_comments`
      helper; the declaration side is comment-aware, the occurrence side deliberately is not)*
- [x] Add `typst/**/*.typ` and `scripts/*.sh` to the occurrence corpus, alongside the existing
      `FormalSystem/` + `Tests/` `.lean` files and repo `.md` files. *(completed)*
- [x] Re-run and confirm the T0 rows (11) and T4 rows (12) have left the report, and that the
      scanned-declaration denominator has dropped by the phantom count. *(completed -- census
      1,020 -> 997, exactly the 23 rows predicted; denominator 11,046 -> 10,850)*
- [x] Spot-check that the seven C2/C14 baseline names (`soundness_setConsequence`,
      `setConsequence_iff_not_satisfiable`, `satisfiableSet_iff_finitelySatisfiable`,
      `modelExistence_iff_finitelySatisfiable`, `tmFrag_complete_dense`, `tmFrag_complete_ztime`,
      `tmFrag_complete_rtime`) and the five Typst-cited names (`getProof`,
      `int_nullity_example`, `generic_nullity_example`, `int_compositionality_example`,
      `generic_compositionality`) are no longer reported. *(completed -- all twelve absent, checked
      by name against the full 997-row list, not just the 20 the INFO line prints; all eleven T0
      phantoms absent too)*

**Timing**: 1.25 hours

**Depends on**: 2

**Verification Tier**: full

**Scope Hypothesis**: this step removes 11 T0 rows and 12 T4 rows from the census (1,020 ->
997) and 196 phantom declarations from the scanned denominator (11,046 -> 10,850). Confirm by
diffing the new C17 output against `baseline-harness.txt` and by grepping the new output for each
of the twelve named T4 declarations -- all twelve must be absent.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C17 Python block: `decl_re` matching site (comment
  awareness) and `occurrence_files` construction (corpus widening).

**Verification**:
- All twelve T4 names absent from C17's output.
- Scanned-declaration denominator dropped to the real declaration count.
- Harness exit code and every other check's state unchanged from the baseline.

#### Phase Notes (measured at implementation time)

Scope Hypothesis confirmed exactly: 1,020 -> 997 (11 T0 + 12 T4 rows leave), denominator
11,046 -> 10,850 (196 phantoms leave). Full harness exit 0; diffing every `PASS`/`FAIL`/`INFO`/
`TODO` line against the Phase 2 run shows **one** changed line, C17's own.

One addition beyond the stated tasks, made because the task "confirm the denominator has
dropped" was otherwise unobservable from the harness: **C17 never printed a denominator at all**.
Its INFO line now reads `N of M declaration(s) ...`, so the number the census is read against is
visible at the gate rather than having to be re-derived by hand. This is a reporting change
only; C17 remains reporting-only and still never touches `FAILURES`.

The two comment-aware counting variants were measured against each other before one was chosen:
requiring the stripped line to match (used) and additionally requiring the raw line to match the
same name (the stratifier's rule) give an identical 10,850, with zero rows differing. The simpler
rule was taken.

---

### Phase 4: C17 filter set, part 2 -- indirect-reachability exclusions and Boneyard sub-count [COMPLETED]

**Goal**: Exclude the four classes reachable by a mechanism other than a name, exclude the
directory whose contract is to be read rather than called, and split the "only consumer is
archived" population out of the headline.

**Tasks**:
- [x] Exclude `instance` declarations from C17's declaration scope (T1). *(completed -- 79 excluded
      tree-wide, of which 48 were flagged)*
- [x] Exclude declarations carrying `simp` or any attribute registered via `register_simp_attr`,
      discovering the attribute names by scanning the tree for `register_simp_attr` rather than
      hardcoding `formula_unfold` / `formula_fold` / `truth_norm` / `swap_norm`, so a future simp
      set is covered the day it is added (T2 + T3). *(completed -- attribute names are discovered,
      not hardcoded; 364 excluded tree-wide, of which 157 were flagged)*
- [x] Exclude `FormalSystem/Examples/**` from C17's declaration scope (D5/F4), on the same
      footing as smoke-test declarations: nothing calling them is the intended state.
      *(completed -- 36 excluded tree-wide, of which 21 were flagged)*
- [x] Report "flagged in live code but referenced only from `Boneyard/`" as a separate sub-count
      beneath the headline rather than folded into it. *(completed -- sub-count line reports 47;
      the Boneyard side is comment-stripped, so an archived prose mention is not a consumer)*
- [x] Re-run and confirm the headline count and the sub-count. *(completed -- 771 and 47, both
      exactly as hypothesised)*
- [x] Re-run `c17_triage.py` and confirm the tool and the script still agree; if they diverge,
      the script is authoritative and the tool is corrected. *(completed -- they diverged, because
      the tool had no tier for the new `Examples/` exclusion; the tool was corrected with a
      `T5_examples` tier and its SURVIVOR count now equals C17's headline exactly)*

**Timing**: 1.25 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: the completed six-filter set takes C17 from 1,020 to 771, with a 47-row
Boneyard-only sub-count reported alongside; the post-filter composition is 683 `theorem`, 81
`def`, 6 `structure`, 1 `abbrev`. Confirm by the script's own output and by
`c17_triage.py --summary`; a divergence between the two is a phase failure, not a rounding
difference.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C17 Python block: declaration-scope filters, the
  `register_simp_attr` discovery pass, and the sub-count reporting.
- `specs/588_triage_zero_occurrence_declarations/tools/c17_triage.py` - corrected only if it
  diverges from the script.

**Verification**:
- C17 prints 771 (or the measured equivalent, with the divergence explained) plus a separate
  Boneyard-only sub-count.
- C17 remains reporting-only: no `ENFORCE_C17` variable exists and `FAILURES` is untouched by it.
- Harness exit code unchanged from the baseline.

#### Phase Notes (measured at implementation time)

Scope Hypothesis confirmed exactly, with no divergence to explain: 997 -> **771**, composed of
683 `theorem` / 81 `def` / 6 `structure` / 1 `abbrev`, with a **47**-row Boneyard-only sub-count
reported beneath it. Full harness exit 0; the only line differing from the Phase 3 run is C17's
own.

C17's new output, verbatim:

```
INFO  C17  771 of 10371 in-scope declaration(s) have zero other occurrences (dead-declaration scan, approximate; never affects FAILURES)
            scope: 10850 real declaration(s) - 79 instance - 364 simp-set-attributed - 36 under FormalSystem/Examples/ = 10371
            of those 771, 47 ARE referenced from FormalSystem/Boneyard/ -- the only consumer is archived, which is a
            retirement decision about the archive, not a dead declaration
```

The exclusion counts on the `scope:` line are tree-wide, not flagged-only: 79 `instance`
declarations exist in the live tree of which 48 were flagged, 364 carry a simp-set attribute of
which 157 were flagged, and 36 sit under `FormalSystem/Examples/` of which 21 were flagged. Both
numbers matter -- the flagged figure explains the census drop, the tree-wide figure is what the
new denominator is built from.

**The Boneyard sub-count is a breakdown of the headline, not a subtraction from it.** All 47 are
inside the 771. Reporting them separately is what makes "the only consumer is archived" legible
as its own case; folding them in would have said nothing, and subtracting them would have hidden
a population that still needs a decision.

**The tool was corrected, as the task anticipated.** `c17_triage.py` had no tier corresponding to
the `Examples/` exclusion, so its SURVIVOR count stood at 792 against the script's 771. A
`T5_examples` tier was added between T4 and SURVIVOR; the tool now reports
T0 11 / T1 48 / T2 145 / T3 12 / T4 12 / T5 21 / SURVIVOR 771, and prints the survivor count a
second time labelled as C17's headline so the two can never silently drift. `tools/c17_census.tsv`
was regenerated against the corrected tiering.

---

### Phase 5: Propagate the comment-aware declaration regex to C19 and C23 [COMPLETED]

**Goal**: Remove the same phantom declarations from the other two checks that inherit the
comment-blind regex, without moving either check's verdict.

**Tasks**:
- [x] Record C19's and C23's exact counts and pass/fail state from `baseline-harness.txt`.
      *(completed -- C19 unrefined 9902/11043 = 89.67%, refined 10212/11043 = 92.47% PASS; all
      three C23 assertions PASS with zero findings each; C23 prints no denominator)*
- [x] Apply the same comment-stripping and block-comment skipping to C19's and C23's declaration
      regex sites. *(completed -- `strip_comments` is now shared by C17, C19 and the C16/C23
      block; C23's own ad-hoc tracker was replaced by it)*
- [x] Re-run the harness. Confirm each check's *verdict* is unchanged and only its denominator
      moved. *(completed -- C19 denominator 11,043 -> 10,850, verdict still PASS; C16 dupNamespace
      and all three C23 lines byte-identical)*
- [x] If either verdict changes, stop and investigate before proceeding -- C23 is gated by
      `ENFORCE_C23`, so a flip is a real regression, not a new baseline. *(completed -- no verdict
      changed, so this branch was not taken; the equivalence was additionally measured in
      isolation BEFORE the edit landed, see Phase Notes)*

**Timing**: 1 hour

**Depends on**: 4

**Verification Tier**: full

**Scope Hypothesis**: 196 phantom declarations leave C19's and C23's denominators, and neither
check's pass/fail verdict changes. Confirm by a before/after diff of both checks' lines against
`baseline-harness.txt`.

**Files to modify**:
- `scripts/check-module-invariants.sh` - C19 and C23 declaration-regex sites.

**Verification**:
- C19 and C23 verdicts identical to the baseline; denominators reduced.
- Harness exit code unchanged.

#### Phase Notes (measured at implementation time)

Scope Hypothesis confirmed: 193 phantom declarations leave C19's denominator (11,043 -> 10,850)
and no verdict moves. Full harness exit 0; the only two lines differing from the Phase 4 run are
C19's own pair. Coverage RISES rather than falls, as it must -- a declaration-shaped line inside a
comment is never credited as documented, so removing 193 of them from the denominator raises both
figures: unrefined 89.67% -> 91.25%, refined 92.47% -> **93.79%**, still clearing the 90% floor by
a wider margin than before.

Two findings that refine the plan's own description of this phase, both verified by direct read:

1. **C23's declaration scan already had a comment tracker**; it was not comment-blind. It counted
   `/-` and `-/` per line and skipped a `--` prefix. What it could not do was handle a trailing
   comment or a declaration sharing a line with a closed block comment, so it was strictly weaker
   than C17's pass rather than absent. It has been replaced by the shared `strip_comments` helper,
   so the three checks now agree by construction on what counts as code instead of carrying three
   definitions that can drift.
2. **C23 prints no denominator**, so "only its denominator moved" is vacuous for C23 -- the check
   reports finding counts (all zero) and nothing else. The observable claim for C23 is the
   stronger one actually verified: its output is byte-identical. The C16 `dupNamespace` scan in
   the same Python block shares that regex site and was comment-blind; it is fixed here too, and
   its output is likewise byte-identical.

The equivalence was measured BEFORE the edit landed, not only after: the block was extracted and
run standalone under both the old tracker and the new pass, and diffed. Both variants -- with the
`lemma` test reading the raw line and reading the stripped line -- produced identical output. That
is what made this safe to apply to an `ENFORCE_C23`-gated check.

---

### Phase 6: Document the new counting rules and record the simp-set handoff [COMPLETED]

**Goal**: Make the new counting rule readable where a future reader will look for it, and hand
the `@[simp]` population off explicitly instead of absorbing it silently.

**Tasks**:
- [x] Update C17's header comment block in `scripts/check-module-invariants.sh` to state the six
      filters, the widened corpus, the Boneyard-only sub-count, and the retained
      reporting-only-never-gating status. *(completed -- header rewritten with a
      `THE COUNTING RULE` section naming all six filters and a
      `WHAT THIS CHECK STILL CANNOT SEE` section; the top-of-file check summary was updated to
      match, for C17 and for C6's Phase 2 addition)*
- [x] Update the C17 row (and the C6 row, for Phase 2's added count) in
      `docs/development/MODULE_INVARIANTS.md`'s "What It Checks" table, in the style of the
      surrounding rows: what it checks and why it exists. *(completed -- C6's row extended;
      **C17 had no row at all**, so one was written and inserted, see Phase Notes)*
- [x] Record the two accepted blind spots explicitly: excluded `instance` rows may hide a
      genuinely unused instance, and excluded `@[simp]` rows (145 at measurement time) may hide
      genuinely unused simp lemmas. *(completed -- both recorded in the script header under
      `ACCEPTED BLIND SPOT` and in the docs row)*
- [x] Record the handoff: the 145-row `@[simp]` population belongs to the unused-simp burn-down
      effort, not to this census, so neither effort assumes the other covers it. *(completed --
      recorded in both places, with the reason the right instrument reads the simp set rather
      than counting tokens)*
- [x] Record why the corpus was widened but never narrowed (a code-only corpus reports 1,827
      against 1,009; 818 declarations are held alive by prose alone). *(completed -- the
      counterfactual was RE-MEASURED against the current filter set rather than quoting the
      pre-filter research figure, see Phase Notes)*

**Timing**: 0.75 hours

**Depends on**: 5

**Verification Tier**: prose

**Files to modify**:
- `scripts/check-module-invariants.sh` - C17 header comment block only (no executable change).
- `docs/development/MODULE_INVARIANTS.md` - C17 and C6 rows.

**Verification**:
- Every changed hunk lies inside a comment block or a markdown file; no executable line moved.
- The harness output is byte-identical to Phase 5's, apart from Phase 2's and Phase 4's already
  verified changes.
- C9/C9D (task-number citations) still pass -- no task numbers introduced in `docs/` or
  `FormalSystem/`.

#### Phase Notes (measured at implementation time)

All three verification criteria hold, and the first two were checked mechanically rather than by
eye:

- **No executable line moved.** `git diff` over `scripts/check-module-invariants.sh`, filtered to
  changed lines that are not comments, is empty.
- **Harness output identical.** Full harness exit 0, and a diff of every `PASS`/`FAIL`/`INFO`/
  `TODO` line against the Phase 5 run is empty. (The plan's caveat "apart from Phase 2's and
  Phase 4's changes" is not needed: those landed in earlier phases, so they are already in the
  Phase 5 baseline this is diffed against.)
- **C9 and C9D still pass**, along with C5, C12, C13, C14 and C15 -- all of which scan `docs/`
  and any of which a new table row could have broken.

Two things the plan did not anticipate, both resolved rather than deferred:

1. **C17 had no row in `MODULE_INVARIANTS.md` to update.** The "What It Checks" table documents
   the gating checks; the reporting-only ones (C17 through C23) were never added to it. The task
   said "update the C17 row", so a row was written and inserted, in the style of the surrounding
   ones. This is a small widening of the task, taken because leaving the new counting rule
   documented only inside the script would have missed the reader the phase exists to serve.
   The remaining reporting-only checks are still absent from the table; that is pre-existing and
   is left alone rather than expanded into here.
2. **The corpus-narrowing counterfactual was re-measured, not quoted.** The plan cites 1,827
   against 1,009, which was measured at research time BEFORE any filter landed. Re-measured
   against the current filter set: a code-only corpus (comments stripped from the occurrence
   side, markdown dropped) reports **1,525** against the current **771** -- 754 declarations are
   held alive by prose alone. The conclusion is unchanged and if anything sharper: narrowing the
   corpus would roughly double the census with rows that are documented rather than dead. The
   script header states the shape of this finding rather than a bare number, so it cannot go
   stale the way a pinned count would.

---

### Phase 7: Cluster disposition table for all post-filter survivors [COMPLETED]

**Goal**: Deliver the classification the task asks for -- a recorded disposition for every
post-filter survivor, at cluster granularity, before any deletion happens.

**Tasks**:
- [x] Regenerate the census from the post-filter script and group the survivors by
      (kind, directory cluster). *(completed)*
- [x] Write `specs/588_triage_zero_occurrence_declarations/dispositions.md` with one row per
      cluster: cluster, member count, kind, evidence, disposition
      (`delete-in-this-task` / `retire-to-Boneyard` / `keep-with-reason` / `follow-up`),
      and rationale. *(completed -- six clusters, A through F)*
- [x] Assign `delete-in-this-task` to the `def` survivors only, split into the three batches
      Phases 8-10 execute. *(completed -- 80 of the 81 `def` survivors; the 81st, `freshBase`, is
      Boneyard-referenced and belongs to the retirement cluster, not this one)*
- [x] Assign `retire-to-Boneyard` + `follow-up` to the 47 Boneyard-only-referenced survivors
      (largest cluster: 10 in `Syntax/SubformulaClosure/TemporalFormulas.lean`, then 5 in
      `WeakCanonical/Separation/Defs.lean`, 4 in `Algebraic/LindenbaumQuotient.lean`) -- "the
      only consumer is archived" is a retirement decision with its own C11 waiver consequences,
      not a deletion. *(completed -- the three named clusters reproduce exactly: 10, 5, 4)*
- [x] Assign `follow-up` to the `theorem` survivors, grouped by file cluster largest-first
      (`Syntax/SubformulaClosure/TemporalFormulas.lean` 18, `BXCanonical/Chronicle/RRelation.lean`
      16, `BXCanonical/Chronicle/ChronicleConstruction.lean` 16, `Conservativity/Plus/Forward.lean`
      12, then the 11-row files). *(completed -- grouped largest-first; the plan's per-file numbers
      are pre-split totals, see Phase Notes)*
- [x] Assign `keep-with-reason` to the `structure` survivors (constructors and projections are
      reached by pattern matching, which no textual scan sees) and to the six orphan-module
      survivors already covered by Phase 2's C6 reconciliation. *(completed -- clusters C and E)*
- [x] Confirm every post-filter survivor is accounted for in exactly one cluster; the row counts
      must sum to the headline. *(completed -- 80 + 47 + 6 + 1 + 6 + 631 = 771, computed from the
      census rather than asserted)*

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: prose

**Scope Hypothesis**: 771 post-filter survivors compose as 683 `theorem` / 81 `def` / 6
`structure` / 1 `abbrev`, of which 47 are Boneyard-only-referenced and 6 sit in manifested
orphan modules. Confirm by regenerating the census and summing the disposition table's member
counts; the sum must equal C17's printed headline exactly.

**Files to modify**:
- `specs/588_triage_zero_occurrence_declarations/dispositions.md` - new; the cluster disposition
  table.

**Verification**:
- Disposition rows sum to the post-filter headline count.
- Every row carries a disposition and a rationale; no row is left blank or "TBD".

#### Phase Notes (measured at implementation time)

Scope Hypothesis confirmed: 771 survivors composing as 683 `theorem` / 81 `def` / 6 `structure` /
1 `abbrev`, of which 47 are Boneyard-only-referenced and 6 sit in manifested orphan modules.

The six clusters **partition** the 771 -- each survivor is in exactly one, and the sum is computed
from the census file rather than asserted:

| Cluster | Members | Disposition |
|---|---:|---|
| A. `def`, no live or archived consumer | 80 | `delete-in-this-task` |
| B. Referenced only from `Boneyard/` (46 `theorem` + 1 `def`) | 47 | `retire-to-Boneyard` + `follow-up` |
| C. `structure` | 6 | `keep-with-reason` |
| D. `abbrev` | 1 | `follow-up` |
| E. `theorem` in manifested import-orphan modules | 6 | `keep-with-reason` |
| F. Remaining `theorem` | 631 | `follow-up` |
| **Total** | **771** | |

Three points where the measured partition is finer than the plan's prose, each recorded so the
arithmetic is checkable rather than merely plausible:

1. **The `def` cluster is 80, not 81.** `freshBase` (`FormalSystem/Syntax/Atom.lean`) is the one
   `def` survivor with archived consumers -- 14 comment-stripped occurrences under `Boneyard/`.
   It belongs to cluster B on the same rule as every other row there, so the deletion batches
   sum to 80 and Phase 10 must exclude it, exactly as that phase's own task list already says.
2. **The plan's per-file `theorem` counts are pre-split totals.** `TemporalFormulas.lean` shows
   18 `theorem` survivors, but 10 of them are Boneyard-referenced and sit in cluster B, leaving 8
   in cluster F. Likewise `ChronicleConstruction.lean` is 16 total, 1 Boneyard-referenced, 15 in
   F. The plan's numbers are right about the census; the table splits them because the two
   halves have different dispositions.
3. **The `abbrev` needed a disposition the plan did not assign**, and it gets its own cluster
   rather than being quietly folded into another. `FiniteTaskModel` is a reducible alias sitting
   beside a sibling alias that IS used; whether the library wants to offer both spellings is an
   API question, not a dead-code question, and it is outside this task's `def`-only deletion
   scope.

Cluster F is 631 rows across 189 files: 275 rows concentrated in 31 files carrying six or more
each, and the remaining 356 scattered one to five at a time across 158 files. That shape is why
the follow-ups are proposed per file cluster rather than as one undifferentiated backlog.

---

### Phase 8: Deletion batch A -- `def` survivors under `Metalogic/Decidability/` [COMPLETED]

**Goal**: Execute the highest-confidence deletion cluster, the one research inspected directly
(`DecideCache.hitRate`, `ProofExtractionStats`, `TableauStats`,
`countPotentialContradictions`, `countNegatedAxioms`, `patternStats`,
`branchUnexpandedComplexity` and siblings).

**Tasks**:
- [x] Regenerate the census; take the current `def` survivor list under
      `FormalSystem/Metalogic/Decidability/**` from that fresh run, never from a stored TSV.
      *(completed -- and stronger than stated: the census is regenerated before EVERY file, not
      once per batch, so no file's line numbers are ever read from a run that a previous
      deletion invalidated)*
- [x] Diff the name list against `grep -F -f <names> scripts/check-module-invariants.sh
      typst/chapters/*.typ`; abort the batch on any hit and reclassify that name instead.
      *(completed -- zero hits, gate passed)*
- [x] Delete the declarations file by file, committing each file's green state as it lands.
      *(completed -- 10 commits, `task 588 phase 8.1` through `8.9` plus the repair commit `8.10`)*
- [x] After each file: `lake build`. *(completed -- 10 guarded, detached builds, every one green;
      a deletion that broke the build would have aborted the batch, and none did)*
- [x] After the batch: `lake build`, `lake build BimodalTest`, and the full invariant harness.
      *(completed -- all three green; the harness needed two repairs first, see Phase Notes)*
- [x] Record the per-line accounting: each deleted name, its file, and the resulting drop in
      C17's headline. *(completed -- see Phase Notes; the drop is 28, not 35, and the difference
      is fully accounted for)*

**Timing**: 1.5 hours

**Depends on**: 6, 7

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~35 `def` survivors under `Metalogic/Decidability/`, concentrated in
`SignedFormula.lean` (13), `CountermodelExtraction.lean` (5), and three-each in
`DecisionProcedure.lean`, `Closure.lean`, `Saturation.lean`, `ProofExtraction.lean`. Confirm
against the regenerated census before deleting anything; the plan's number is a hypothesis and
the fresh census is the fact.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/SignedFormula.lean` and the other
  `Metalogic/Decidability/**` files named by the regenerated census - delete the flagged `def`s.

**Verification**:
- `lake build` and `lake build BimodalTest` exit 0.
- Full harness: C2 and C14 baselines unmoved, C15 anchors unbroken, C21 intact, exit code
  unchanged from the baseline.
- C17's headline dropped by exactly the number of declarations deleted, accounted for line by
  line.

#### Phase Notes (measured at implementation time)

Scope Hypothesis confirmed: **35** `def` survivors under `Metalogic/Decidability/`, distributed
across 10 files exactly as predicted (`SignedFormula.lean` 13, `CountermodelExtraction.lean` 5,
and three each in `DecisionProcedure.lean`, `Closure.lean`, `Saturation.lean`,
`ProofExtraction.lean`). All 35 deleted; **274 lines** removed.

Final state: `lake build` green, `lake build BimodalTest` green, full harness **exit 0, ALL
CHECKS PASSED**. C2's four flagship axiom sets and C14's pinned set are byte-identical to the
Phase 6 baseline, C15's 58 anchors and 75 theorem-index rows still resolve, C21's 27 pinned
results intact, C25's 13 exe roots still compile, C3 sorry inventory still zero.

**The per-line accounting, and why the headline moved by 28 rather than 35.**

```
  771   headline before the batch
 - 35   deleted (every one of the 35 leaves the census)
 +  7   NEWLY flagged: their only remaining consumer was one of the 35 deleted bodies
 -----
  743   headline after the batch          (verified against C17's own printed number)
```

The seven are `BranchStatus` (`Closure.lean`), `SemanticCountermodelResult`
(`CountermodelExtraction.lean`), `BatchDecisionResult` (`DecisionProcedure.lean`),
`mcs_filtration_equiv_equivalence` (`FMP/Filtration.lean`), `findContradiction` and
`unexpandedComplexity` (`SignedFormula.lean`), and `toFiniteTaskFrame`
(`Semantics/TaskFrame.lean`). This was verified by set-differencing the survivor lists before and
after, not inferred from the totals: exactly 35 rows left and exactly 7 rows appeared.

This **cascade is expected behaviour, not a defect**, and the plan already prescribes the right
response: every batch takes its list from a freshly regenerated census, so a cascade row that is
itself an unreferenced `def` simply joins the next batch. One of the seven does --
`toFiniteTaskFrame` -- and it is in Phase 10's regenerated list. The other six are `structure`,
`theorem` or in already-processed files, so they carry into the final accounting as newly
surfaced rows rather than deletions. The census is monotone under this process (a deletion can
only ever surface strictly fewer new rows than it removes), so it converges; it is not chased to
a fixpoint here, and the residue is recorded in Phase 11 rather than absorbed.

**Two gate failures the plan did not anticipate, both repaired.** The batch's own per-file gate
(`lake build`) stayed green throughout, but the *harness* came back `2 CHECK GROUP(S) FAILED`:

1. **INV** -- deleting 274 lines changed the per-directory line counts that the GENERATED
   inventory blocks in `README.md` and `FormalSystem/Metalogic/README.md` publish. Repaired by
   `bash scripts/check-module-invariants.sh --emit-inventory`, which is the documented remedy and
   which the failure message itself prints.
2. **C20 tier 1** -- one `file.lean:NNN` citation, in
   `Metalogic/Decidability/Verified/Termination/MintBound/Measure.lean`, pointed at
   `SignedFormula.lean:741`, which is now blank because 87 lines were deleted above it. Repaired
   by taking C20's own advice ("replace each with the declaration name at the intended site"):
   the sentence already names `reachableForward`, `reachableBackward`, `futureOf` and `pastOf`, so
   the three brittle line numbers were simply dropped. That is strictly more durable than
   renumbering, which would break again on the next edit.

Both repairs are in commit `task 588 phase 8.10`. **The runner for batches B and C was then
extended** to regenerate the inventory blocks and run a structural pass at the end of each batch,
so this class of breakage is repaired inside the batch instead of being discovered at the gate.

One honest note on commit granularity: the nine per-file commits are `lake build`-green, which is
the per-file gate this phase declares, but they are transiently INV-red because the inventory
repair can only be done once, after the batch's last deletion. The batch as a whole is green, and
that is the unit the phase gates on.

---

### Phase 9: Deletion batch B -- `def` survivors under the remaining `Metalogic/` subtrees [NOT STARTED]

**Goal**: Same execution, for `WeakCanonical/`, `BXCanonical/`, `Independence/` and
`Algebraic/`.

**Tasks**:
- [ ] Regenerate the census and take the current `def` survivor list under
      `FormalSystem/Metalogic/{WeakCanonical,BXCanonical,Independence,Algebraic}/**`.
- [ ] Run the same `check-module-invariants.sh` / `typst/chapters/*.typ` name diff and abort on
      any hit.
- [ ] Exclude any name whose only references are in `Boneyard/` -- those belong to the
      retire-to-Boneyard disposition, not to this batch.
- [ ] Delete file by file, committing each file's green state.
- [ ] After each file: `lake build`. After the batch: `lake build`, `lake build BimodalTest`,
      full harness.
- [ ] Extend the per-line accounting record.

**Timing**: 1.5 hours

**Depends on**: 8

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~26 `def` survivors (WeakCanonical 14, BXCanonical 10, Independence 1,
Algebraic 1), the largest single files being
`BXCanonical/Chronicle/PointInsertion.lean` (5), `WeakCanonical/EFGames/StaviCompleteness.lean`
(4) and `WeakCanonical/ChronicleExtraction.lean` (3). Confirm against the regenerated census.

**Files to modify**:
- The `Metalogic/{WeakCanonical,BXCanonical,Independence,Algebraic}/**` files named by the
  regenerated census.

**Verification**:
- Same gate set as Phase 8, all green.
- C17's headline drop matches the deletion count line for line.

---

### Phase 10: Deletion batch C -- `def` survivors outside `Metalogic/` [NOT STARTED]

**Goal**: Finish the `def` cluster: `Automation/`, `Syntax/`, `Semantics/`, `ProofSystem/`,
`Theorems/`.

**Tasks**:
- [ ] Regenerate the census and take the current non-`Metalogic/` `def` survivor list.
- [ ] Run the same name diff against the script and the Typst chapters; abort on any hit.
- [ ] Treat `Automation/ContrastiveGeneratorMain.lean` and `Automation/DatasetGenerator.lean`
      with extra care: they sit next to `lean_exe` roots that `lake build` does not elaborate, so
      C25 (exe-root compilation) is the check that will catch a break there -- run the full
      harness, never `lake build` alone, before committing either file.
- [ ] Exclude Boneyard-only-referenced names, as in Phase 9.
- [ ] Delete file by file, committing each file's green state.
- [ ] After the batch: `lake build`, `lake build BimodalTest`, full harness.

**Timing**: 1.5 hours

**Depends on**: 9

**Verification Tier**: full

**Commit Mode**: per-substep

**Scope Hypothesis**: ~20 `def` survivors (Automation 13 including 3 in `FormulaEnumerator.lean`,
Syntax 4, and one each in `Semantics/TaskModel.lean`, `ProofSystem/LinearityDerivedFacts.lean`,
`Theorems/Propositional/Reasoning.lean`). Confirm against the regenerated census.

**Files to modify**:
- The `Automation/**`, `Syntax/**`, `Semantics/**`, `ProofSystem/**` and `Theorems/**` files
  named by the regenerated census.

**Verification**:
- Same gate set as Phase 8, all green, with C25 explicitly confirmed green for the
  exe-root-adjacent files.
- C17's headline drop matches the deletion count line for line.

---

### Phase 11: Final accounting, follow-up proposals, and summary [NOT STARTED]

**Goal**: Close the task with the accounting the description requires and a written handoff for
every cluster this task deliberately did not execute.

**Tasks**:
- [ ] Run the full invariant harness one final time and diff every check against
      `baseline-harness.txt`.
- [ ] Produce the line-by-line accounting of C17's total drop: baseline 1,020 -> filter effect
      (per filter class) -> deletion effect (per batch) -> final headline, with the sum reconciled
      exactly.
- [ ] Write `specs/588_triage_zero_occurrence_declarations/followups.md` with one ready-to-run
      `/task "..."` proposal per contentious cluster, each carrying its evidence: the
      Boneyard-only retirement cluster (47), the `theorem` survivor clusters grouped by file, the
      `@[simp]` unused-simp-lemma population (145), the disposition of the BiLasso orphan-module
      subtree (~77 declarations outside the build graph), and the
      `indirect-reachability.md` agent-context note.
- [ ] Confirm the disposition table (Phase 7) has no row left in an undecided state, and update
      any row whose disposition changed during execution.
- [ ] Write the execution summary under
      `specs/588_triage_zero_occurrence_declarations/summaries/02_*-summary.md`.

**Timing**: 1.25 hours

**Depends on**: 10

**Verification Tier**: full

**Files to modify**:
- `specs/588_triage_zero_occurrence_declarations/followups.md` - new.
- `specs/588_triage_zero_occurrence_declarations/dispositions.md` - updated with execution
  outcomes.
- `specs/588_triage_zero_occurrence_declarations/summaries/02_*-summary.md` - new.

**Verification**:
- Harness exit code and every check's verdict match or improve on the baseline.
- The accounting reconciles exactly: baseline count minus filter effect minus deletions equals
  the final headline, with no unexplained residue.
- Every cluster is either executed or carries a follow-up proposal.

---

## Lean Challenge Statements

This plan proves no new theorems: it consists of deletions, invariant-script filter changes, and
reporting/documentation changes. The `- **Goals**:` bullets above name no Lean identifiers to
prove, so the identifier set this section is required to match is empty, and no ```lean fenced
block is present. The section is stated explicitly rather than omitted so that its emptiness
reads as a decision rather than an oversight.

## Testing & Validation

- [ ] `lake build` exits 0 after every deletion file and at the end of every deletion batch.
- [ ] `lake build BimodalTest` exits 0 at the end of every deletion batch.
- [ ] `bash scripts/check-module-invariants.sh` exits with the same code as the Phase 1 baseline,
      with C2 and C14 axiom baselines unmoved, C15 paper anchors unbroken, and C21 intact.
- [ ] C6 still passes, with the manifest unchanged and its new declaration-count INFO line
      populated.
- [ ] C19 and C23 verdicts unchanged from the baseline; only their denominators moved.
- [ ] C17 remains reporting-only: no `ENFORCE_C17` variable exists, and C17 never contributes to
      `FAILURES`.
- [ ] `c17_triage.py` and the in-script C17 agree exactly after the filter changes.
- [ ] Zero `sorry` and zero new axioms introduced (C3 and C14 unchanged).
- [ ] Every one of the post-filter survivors appears in exactly one disposition row.

## Artifacts & Outputs

- `specs/588_triage_zero_occurrence_declarations/plans/02_c17-census-filter-and-triage.md` (this file)
- `specs/588_triage_zero_occurrence_declarations/tools/baseline-harness.txt` (Phase 1)
- `specs/588_triage_zero_occurrence_declarations/dispositions.md` (Phase 7, updated Phase 11)
- `specs/588_triage_zero_occurrence_declarations/followups.md` (Phase 11)
- `specs/588_triage_zero_occurrence_declarations/summaries/02_c17-census-filter-and-triage-summary.md` (Phase 11)
- `scripts/check-module-invariants.sh` (Phases 2-6)
- `docs/development/MODULE_INVARIANTS.md` (Phase 6)
- Deleted declarations across `FormalSystem/` (Phases 8-10)

## Rollback/Contingency

Every phase commits at green sub-step granularity, so the unit of rollback is a single commit,
not the task. Contingencies, in escalation order:

1. **A deletion breaks the build or a gate**: revert that one file's commit
   (`git revert <sha>`), reclassify the declaration as `keep-with-reason` in
   `dispositions.md` with the failure recorded as its evidence, and continue the batch. A
   declaration that turns out to be load-bearing is kept with the reason written down -- never
   stubbed with a `sorry`.
2. **A script filter change moves another check's verdict**: revert the filter commit and
   re-approach the filter narrowly. C19/C23 verdict changes (Phase 5) are treated as regressions
   requiring investigation, never as a new baseline.
3. **A whole-tree rollback is genuinely required** (uncommitted work must be discarded): take a
   snapshot first using the rollback-rung invocation in
   `.claude/context/contracts/recovery.md`, including its out-of-scope override flag for the
   deliberate whole-tree case, then perform the reset. Do not use a bare default-mode snapshot
   call as a routine pre-phase checkpoint; for a defensive checkpoint before risky work, the
   `--no-revert` form is the correct one.
4. **The census does not reconcile at Phase 11**: the residue is investigated and recorded, not
   absorbed. An unexplained residue blocks task completion, because line-by-line accounting of
   C17's drop is an explicit requirement of the task.
