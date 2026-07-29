# Implementation Plan: Task #418

- **Task**: 418 - fix_tableau_engine_crossworld_temporalcopy_unsoundness_in_boxnegdiamondpos
- **Status**: [IMPLEMENTING]
- **Effort**: 11.25 hours
- **Dependencies**: None (this task unblocks task 165 Phase 7.2)
- **Research Inputs**: specs/165_establish_semantic_finite_model_property/reports/08_spawn-analysis.md
- **Artifacts**: plans/01_remove-unsound-temporal-copy-blocks.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md, lean4.md, plan-compliance.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Six `let` blocks in each of the `.boxNeg` and `.diamondPos` cases of `applyRule`
(`FormalSystem/Metalogic/Decidability/Tableau.lean`) copy temporal-universal and
temporal-existential signed formulas verbatim from the current branch into the freshly minted
`□`/`◇`-witness world. This conflates "true along the history being built" with "true at this
instant along every admissible history", which is exactly the distinction `□`/`◇` quantify over.
The fix is a pure deletion: remove the twelve blocks (six per rule) and the two `temporalProps`
assembly lines, leaving each rule's result as `.linear (witness :: boxProps ++ diaProps)`.

The deletion itself is roughly fifteen minutes of editing. The task is sized at eleven hours because
the deletion is **risk-asymmetric**: removing emitted formulas can only shrink a branch's
contradiction surface, so branches can only get *harder* to close. The fix cannot manufacture a
new false-`invalid` verdict; it can only reveal previously-hidden false-`valid` verdicts (the
intended repair) or leave branches uncloseable that legitimately should close (the regression to
hunt). The only instrument that distinguishes those two outcomes is running the entire
conformance corpus before and after and recording every verdict that moves. Most of this plan
exists to make that measurement trustworthy under a shared, concurrently-built git clone — and to
characterise one specific, already-identified downstream consequence (`boxAnchoredCheck`, Phase 5)
precisely enough to hand it to task 165 rather than let it surface as an unexplained red row.

### Research Integration

The spawn analysis (`reports/08_spawn-analysis.md`) supplies the root cause, the isolation
argument (groups 1 and 2 are sound and untouched), and the measured evidence:
`buildTableau ((G p) → □(G p)) 1000 .Base` returns `.allClosed` on a formula that is invalid,
with `decide` returning `.extractionFailed` rather than `.invalid`-with-countermodel. It also
supplies the concurrency hazard that shapes Phases 1, 2, 6 and 8.

A dedicated blast-radius investigation during planning added five facts the research report did
not carry. Each changes the plan's shape, and the third is the single most important thing in
this document.

1. **`lake build` does not build the tests.** `lakefile.lean` marks only `lean_lib FormalSystem`
   as `@[default_target]`. The conformance corpus lives in `lean_lib BimodalTest`
   (`srcDir := "Tests"`) and is reached only by `lake build BimodalTest` (or `lake test`, since
   `package Logos` sets `testDriver := "BimodalTest"`). A plan that ran only `lake build` would
   report a green acceptance gate having never compiled a single `#guard_msgs` row.
2. **The corpus is 145 `#guard_msgs` rows across eight probe files**, not the two named in the
   task description: `TemporalWitnessProbe` (71), `TableauConformance` (29),
   `BoxNegReachabilityProbe` (12), `RegionGateProbe` (10), `RayRegionProbe` (8),
   `CrossWorldPropagationProbe` (5), `BoxSpreadProbe` (5), `BoxNegPreservationProbe` (5). All
   eight are imported by `Tests/BimodalTest.lean`. Six of the eight are expected to move.
3. **`boxAnchoredCheck` is the real cost of the fix, and it is a semantic break, not a compile
   break.** `Verified/Bridge/BoxSaturation.lean:415-419` explicitly credits
   `tempGProps`/`tempHProps` as the supplier of `T(Gφ)`/`T(Hφ)` at minted worlds, and no other
   rule can put `T(Gφ)` at a world that never received `T(□φ)`: `boxProps` supplies only
   `T(inner)`; `boxTemporal` fires only on `T(□·)`, which never reaches a fresh world;
   `allFuturePos`/`allPastPos` require `T(G·)`/`T(H·)` to already be present. The six blocks are
   therefore the *only* route. `boxAnchoredCheck` (`BoxSaturation.lean:470-480`) is expected to
   compute `false` on multi-world branches after the deletion. It is carried as a hypothesis
   `hBA : boxAnchoredCheck b = true` — never unfolded — by `sat_box_grid_of_anchored` /
   `sat_box_grid_of_check` (`BoxSaturation.lean:534-551`), by `Verified/Bridge/IntTruth.lean`
   (lines 351, 366, 853, 866, 886, 1030, 1059) and by `Verified/Bridge/DenseTruth.lean` (lines
   84, 582, 613, 654, 677). **Nothing breaks at typecheck.** What breaks is that the hypothesis
   stops being dischargeable by computation on real engine output, so the truth lemma's `box`
   case loses its side condition. Phase 5 exists solely to measure and document this.
4. **Compile-time breakage inside `FormalSystem/` is expected to be nil.** No Lean proof term
   depends on the emitted-list *shape* of the temporal blocks.
   `Verified/Termination/SubformulaProperty.lean:828/859` (`applyRule_boxNeg_closed`,
   `applyRule_diamondPos_closed`) is the only pair that unfolds these arms; its `simp only` lists
   name all six removed accessors but are `try`-wrapped, and the closing `first`-chain is
   block-count-agnostic, so fewer blocks means fewer goals.
   `CountermodelExtraction.lean:505-524` (`sat_box_neg`) unfolds `applyRule` but reasons only
   through `witnessPresent .boxNeg`. `Verified/Termination/Fuel.lean:1118-1140` tests only
   `witnessPresent`. `TemporalSaturation.lean` and `TraceCertificate.lean` are untouched.
5. **The `Verified/` tree contains zero `sorry` terms** (the four `grep` hits are the string
   "sorry-free" and one docstring mention). The fix must not be the thing that introduces one.
   Relatedly, `Verified/Decidable.lean:1123` already *documents* that "the six group-3 blocks in
   `boxNeg` and `diamondPos` do not preserve satisfiability" — the file this task must not
   touch already knows about the defect this task removes.

### Prior Plan Reference

No prior plan. This is the task's first plan.

### Roadmap Alignment

No `roadmap_path` was supplied in the delegation context and no roadmap consultation was
performed. This task's alignment is to task 165: it clears the sole blocker on that task's
Phase 7.2 `RuleSound` assembly.

## Goals & Non-Goals

**Goals**:

- Delete the six group-3 temporal-copy blocks and the `temporalProps` assembly from `.boxNeg`
  (`Tableau.lean:555-575`) and from `.diamondPos` (`Tableau.lean:599-620`), leaving each rule
  emitting `.linear (witness :: boxProps ++ diaProps)`.
- Keep `lake build` (the `FormalSystem` library) green, repairing any downstream proof the
  changed `applyRule` term structure breaks — with the single named exception below.
- Keep `lake build BimodalTest` (the full corpus) green, with every `#guard_msgs` row either
  unchanged or updated to a new expected value that has been individually justified.
- Measure and fully document the `boxAnchoredCheck` consequence, with its downstream carrier
  list, as a handoff finding for task 165.
- Produce a complete before/after verdict-change table (formula, old verdict, new verdict) over
  the whole corpus, so the fix's blast radius is a recorded measurement rather than an assertion.
- Follow an explicit build-reliability protocol so no corpus run whose build step was interrupted
  is ever mistaken for a passing acceptance gate.

**Non-Goals**:

- **Do not edit `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`.** Not to repair
  it, not to weaken a statement in it, not to add a `sorry` to it. Investigation indicates it
  will not break at typecheck; if it does, the phase stops and reports `[BLOCKED]`.
- **Do not attempt task 165 Phase 7.2's `RuleSound` proof**, or any part of the
  `∀ r ∈ allRulesForFC fc, RuleSound _ r` assembly. This task makes that statement *true*; it
  does not prove it.
- **Do not repair `boxAnchoredCheck` by adding a replacement propagation block.** The obvious
  candidates — copying `T(□φ)` itself to the fresh world, or copying `T(Gφ)`/`T(Hφ)` only when
  box-derived — are *design changes to the engine's saturation strategy* with their own soundness
  obligations. Phase 5 measures and documents the gap; choosing the repair belongs to task 165,
  which owns the truth lemma the gap affects. Implementing one here would re-open the very
  question this task exists to close.
- Do not delete the six `Branch.*AtTime` accessor definitions in `SignedFormula.lean:473-537`.
  Only their call sites inside `applyRule` are removed; `SubformulaProperty.lean` still names them.
- Do not touch groups 1 (the existential witness) or 2 (`T(□B)`/`F(◇B)` propagation) in either
  rule. These are sound.
- Do not "fix" a corpus row by weakening or deleting the assertion. A row whose new value cannot
  be justified as correct is a regression to record and triage, not a test to soften.
- Do not run `lake clean`, at any point, for any reason. See the Build-Reliability Protocol.
- No `git push`, no PR, no branch creation.

## Build-Reliability Protocol (binding constraint on every phase)

Three concurrent sessions (tasks 408, 414, 415) share this git clone and have previously
destroyed full-build attempts by deleting `.olean` files mid-build. At planning time the clone
showed 405 `.olean` files present (a warm build) and multiple live `lake serve` / `lean --worker`
processes, including one holding
`FormalSystem/Metalogic/Decidability/Verified/Decidable.lean` — task 165's file — open. There is
no existing build-lock or build-coordination convention anywhere in the repository; a search of
`.claude/`, the repo root, and `.gitignore` found none. This plan therefore **establishes** one
in Phase 1 rather than honoring one.

The following rules bind every phase, not just the phases that mention them:

1. **Never run `lake clean`.** Not to force a rebuild, not to resolve a confusing error, not as
   a last resort. A concurrent session mid-build loses its work and the resulting failure is
   attributed to this task's edit. If a stale-artifact problem is genuinely suspected, delete the
   single specific `.olean`/`.trace` pair under `.lake/build/lib/lean/` and rebuild that module.
2. **Take the advisory lock before any build, release it after.** Phase 1 defines it. Honor it
   even though concurrent sessions predating this task will not.
3. **A build that failed or was interrupted makes the corpus run INCONCLUSIVE, not failing.**
   Distinguish two error classes before drawing any conclusion:
   - *Verdict errors* — `#guard_msgs` mismatch, `unsolved goals`, `type mismatch`, `unknown
     identifier`. These are real and attributable to this task's edit.
   - *Infrastructure errors* — `could not resolve import`, missing/corrupt `.olean`, `error:
     no such file or directory` under `.lake/`, an abrupt non-zero exit with no Lean diagnostic,
     or an olean count that dropped mid-run. These are the concurrent-session hazard.
   An infrastructure error means: re-check the olean count, wait, and **retry the whole build**.
   It never means the gate passed, and it never means the gate failed.
4. **Never record an oleans-were-deleted failure as corpus validation.** A baseline or acceptance
   result may only be written to an artifact if its build step exited zero *and* the pre-build and
   post-build olean counts are consistent with a build that ran to completion.
5. **Prefer scoped builds during iteration** (`lake build FormalSystem.Metalogic.Decidability.Tableau`)
   and reserve `lake build` + `lake build BimodalTest` for phase-end and acceptance gates. This
   shrinks the window in which a concurrent deletion can land.

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| `boxAnchoredCheck` stops computing `true` on multi-world branches, silently removing a side condition seven downstream lemma families carry | H | H | Phase 5 is dedicated to measuring it, enumerating carriers, and handing it to task 165 as a documented finding; explicitly out of scope to repair here |
| Concurrent session deletes `.olean` files mid-build, corrupting the acceptance gate | H | H | Build-Reliability Protocol; olean-count bracketing around every gate build; infra-vs-verdict triage; retry rather than record |
| Pressure to re-add a "narrower" temporal-copy block to make `boxAnchoredCheck` or a probe row pass | H | M | Named Non-Goal; Phase 5 and Phase 7 both forbid it explicitly; the engine diff is re-verified against Phase 3 at every later gate |
| A conformance row flips from a correct verdict to an uncloseable branch (genuine under-closing regression) | H | M | Phases 6-7: every moved row is individually adjudicated against the semantics, not auto-accepted; unjustifiable moves are recorded and triaged |
| `SubformulaProperty.lean`'s two `applyRule`-unfolding proofs break | M | L | Investigation found `try`-wrapped `simp only` and a block-count-agnostic `first` chain; Phase 4 handles it, expected repair is pruning six dead names from two simp lists |
| Fuel exhaustion appears where branches previously closed (fewer emitted formulas can mean longer searches) | M | M | Phase 6 classifies `.hasOpen` vs fuel-exhausted vs `extractionFailed` separately rather than collapsing them into pass/fail |
| `#guard_msgs` mismatches block the AFTER build, hiding later rows behind earlier failures | M | H | Phase 6 measures per-module (`lake build BimodalTest.X`) so every mismatch is surfaced, not just the first |
| Prose in probe and bridge docstrings still asserts the buggy behavior after the values are corrected | M | H | Phases 4 and 7 treat explanatory prose as part of the deliverable; specific known sites are enumerated per phase |
| The corpus was already red before the edit, making the baseline meaningless | M | L | Phase 2 records pre-existing failures explicitly and excludes them from attribution |
| `Verified/Decidable.lean` breaks despite the prediction that it will not | H | L | Phase 4 stops and reports `[BLOCKED]` rather than editing it |

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
| 7 | 7 | 6 |
| 8 | 8 | 7 |

Phases within the same wave can execute in parallel. This plan's waves are singletons: the chain
is strictly sequential by construction, because the whole point of the measurement is that the
BEFORE baseline must be captured on unmodified source and the AFTER run on modified source, with
nothing overlapping. Do not parallelize it.

---

### Phase 1: Build-Reliability Protocol and Concurrency Guard [COMPLETED]

**Goal**: Establish the advisory build lock and the infra-vs-verdict triage procedure that every
later phase depends on, and record the clone's starting build state so mid-task olean loss is
detectable rather than merely suspected.

**Tasks**:
- [x] Record the starting state: `find .lake/build -name "*.olean" | wc -l`, `git status --short`,
      `git rev-parse HEAD`, and `pgrep -af "lake|lean --"`. Write all four into
      `specs/418_.../artifacts/build-environment.md`.
- [x] Create the advisory lock convention at `.lake/.task-418-build.lock` — a plain file whose
      contents are the task number, PID, and ISO8601 acquisition time. Document the acquire /
      release / stale-detection procedure (a lock older than 60 minutes whose PID is dead is
      stale and may be broken) in the same artifact.
- [x] Write the infra-vs-verdict error triage table (from the Build-Reliability Protocol above)
      into the artifact as an operational checklist the later phases follow verbatim.
- [x] Confirm the six accessor definitions exist and are untouched at
      `FormalSystem/Metalogic/Decidability/SignedFormula.lean:473-537`, so the Phase 3 edit is
      unambiguously a call-site deletion.
- [x] Confirm `lake build` alone does NOT build the corpus, by reading `lakefile.lean`'s
      `@[default_target]` placement, and record `lake build BimodalTest` as the corpus command.

**Timing**: 0.75 hours

**Depends on**: none

**Verification Tier**: prose

**Files to modify**:
- `specs/418_.../artifacts/build-environment.md` - new; environment snapshot, lock convention,
  triage checklist
- `.lake/.task-418-build.lock` - runtime lock file (under gitignored `.lake/`; not a deliverable)

**Verification**:
- The artifact exists and states an olean baseline count, the HEAD commit, the lock protocol, and
  the infra-vs-verdict triage table.
- No Lean source file was modified (`git status --short` shows no `.lean` changes).

---

### Phase 2: BEFORE Baseline — Full Corpus Capture on Unmodified Source [COMPLETED]

**Goal**: Capture the complete pre-fix verdict state of the library and the conformance corpus,
so every post-fix change is attributable and nothing pre-existing is misread as a regression.

**Tasks**:
- [x] Acquire the build lock. Record the olean count immediately before building.
- [x] Run `lake build` (the `FormalSystem` library). Capture full stdout+stderr to
      `specs/418_.../artifacts/baseline-build.log`.
- [x] Run `lake build BimodalTest` (the corpus). Capture full output to
      `specs/418_.../artifacts/baseline-corpus.log`.
- [x] Record the olean count immediately after. If it dropped, or if either build produced an
      infrastructure-class error, discard both logs and retry from the top of this phase. Do not
      proceed on an inconclusive baseline.
- [x] Write `specs/418_.../artifacts/baseline-verdicts.md`: a table keyed by file and row
      recording each `#guard_msgs` row's expected value as written in the source, for all eight
      probe files — `TableauConformance` (29), `TemporalWitnessProbe` (71),
      `BoxNegReachabilityProbe` (12), `RegionGateProbe` (10), `RayRegionProbe` (8),
      `CrossWorldPropagationProbe` (5), `BoxSpreadProbe` (5), `BoxNegPreservationProbe` (5).
- [x] Capture the **pre-fix `boxAnchoredCheck` datum** explicitly, since Phase 5 needs a
      before-value to compare against: record `BoxSpreadProbe.lean` rows A/B/C (`:71-86`) —
      currently pinning `anchor = true` and `|T| = 7` / `|T| = 10` — verbatim, and note them as
      the anchor baseline.
- [x] Record explicitly whether the baseline is fully green. Name any already-failing row as a
      pre-existing failure excluded from before/after attribution.
- [x] Release the lock.

**Timing**: 1.5 hours

**Depends on**: 1

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts the corpus is exactly 145 `#guard_msgs` rows across
exactly eight probe files, and that both builds are green on unmodified source. The row counts
come from a `grep -c '#guard_msgs'` sweep at planning time and the file list from
`Tests/BimodalTest.lean`'s import block; neither the greenness nor the counts were confirmed by
an actual build. The implementer must confirm both by running the builds and re-counting, and
must correct `baseline-verdicts.md` to whatever is actually observed rather than reproducing
these numbers. A discrepancy here is information, not an error to suppress.

**Files to modify**:
- `specs/418_.../artifacts/baseline-build.log` - new; raw `lake build` output
- `specs/418_.../artifacts/baseline-corpus.log` - new; raw `lake build BimodalTest` output
- `specs/418_.../artifacts/baseline-verdicts.md` - new; per-file per-row expected-value table

No `.lean` file is modified in this phase.

**Verification**:
- Both logs exist; both builds exited zero, or every non-zero exit is recorded as a pre-existing
  named failure.
- Pre-build and post-build olean counts are consistent with a completed build.
- `baseline-verdicts.md` enumerates every probe file with its row count and greenness, and
  carries the `BoxSpreadProbe` anchor baseline.
- `git diff --stat` shows zero changes under `FormalSystem/` and `Tests/`.

---

### Phase 3: Remove the Six Group-3 Blocks from boxNeg and diamondPos [COMPLETED]

**Goal**: Perform the actual soundness fix — a pure deletion of twelve `let` blocks and two
assembly lines — and confirm the single edited module compiles.

**Tasks**:
- [x] In `Tableau.lean`'s `.boxNeg` case: delete the `-- Cross-modal-temporal: ...` comment and
      the six `let` bindings `tempGProps`, `tempHProps`, `tempFNegProps`, `tempPNegProps`,
      `tempUNegProps`, `tempSNegProps` (currently lines 554-572), and the `temporalProps` binding
      (currently 573-574).
- [x] Change the `.boxNeg` result line (currently 575) from
      `(.linear (witness :: boxProps ++ diaProps ++ temporalProps), timeOrd)` to
      `(.linear (witness :: boxProps ++ diaProps), timeOrd)`.
- [x] In `Tableau.lean`'s `.diamondPos` case: delete the corresponding comment, the same six
      `let` bindings (currently 598-616), and the `temporalProps` binding (617-619).
- [x] Change the `.diamondPos` result line (currently 620) identically.
- [x] Confirm by reading the surrounding code that group 1 (`freshWorld` / `freshLabel` /
      `witness`) and group 2 (`boxProps` / `diaProps`) in BOTH rules are byte-identical to their
      pre-edit form. This is the isolation guarantee; verify it, do not assume it.
- [x] Update the `applyRule` doc comment and any comment in the file describing cross-modal
      temporal propagation, so no surviving comment claims the removed behavior still happens.
- [x] Acquire the lock and run the scoped build
      `lake build FormalSystem.Metalogic.Decidability.Tableau`. Release the lock.

**Timing**: 1.0 hours

**Depends on**: 2

**Verification Tier**: local

**Commit Mode**: atomic-batch

**Scope Hypothesis**: This phase asserts the edit touches exactly one file at exactly two sites,
with line ranges `.boxNeg` 554-575 and `.diamondPos` 598-620. Those ranges were read at planning
time and will drift if a concurrent session edits this file first. The implementer must re-locate
both blocks by their `let tempGProps :=` anchors rather than trusting line numbers, and must
count occurrences of each `temp*Props` identifier before and after (expected: non-zero before, 0
after) rather than reproducing this estimate.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Tableau.lean` - delete twelve `let` blocks (six per rule),
  two `temporalProps` assemblies, and two `++ temporalProps` result-list suffixes; refresh the
  comments that described the removed behavior

**Verification**:
- `grep -c 'temporalProps\|tempGProps\|tempHProps\|tempFNegProps\|tempPNegProps\|tempUNegProps\|tempSNegProps' FormalSystem/Metalogic/Decidability/Tableau.lean`
  returns 0.
- `grep -n 'witness :: boxProps ++ diaProps' FormalSystem/Metalogic/Decidability/Tableau.lean`
  returns exactly two lines.
- `git diff FormalSystem/Metalogic/Decidability/Tableau.lean` shows deletions and comment edits
  only — no added logic, and no change to the `witness`/`boxProps`/`diaProps` bindings.
- `lake build FormalSystem.Metalogic.Decidability.Tableau` exits zero.

---

### Phase 4: Restore the Library Build and Refresh Stale Bridge Prose [COMPLETED]

**Goal**: Get `lake build` (the whole `FormalSystem` library) green, repairing any proof whose
tactic script was written against the old `applyRule` term structure, and correcting the bridge
docstrings that assert the removed behavior as live — without touching `Verified/Decidable.lean`.

**Tasks**:
- [x] Acquire the lock, bracket with olean counts, run `lake build`. Triage every error as
      infrastructure-class or verdict-class per the Phase 1 checklist. Retry on infrastructure
      errors; do not proceed on an inconclusive build.
- [x] Repair each verdict-class error. Investigation predicts **none**, with the only plausible
      site being `Verified/Termination/SubformulaProperty.lean` — `applyRule_boxNeg_closed`
      (~828) and `applyRule_diamondPos_closed` (~859). Each `unfold applyRule at hg`, then
      `simp only [...]` a list naming all six removed accessors, then peels membership with
      `repeat' rcases` and closes with a three-alternative `first` chain. Both `simp only` calls
      are `try`-wrapped and the chain is block-count-agnostic, so the expected outcome is that
      they still compile. Prune the six now-dead accessor names
      (`Branch.allFuturePosAtTime`, `Branch.allPastPosAtTime`, `Branch.someFutureNegAtTime`,
      `Branch.somePastNegAtTime`, `Branch.untlNegAtTime`, `Branch.snceNegAtTime`) from those two
      lists regardless, since they are now inert.
- [x] Rewrite the stale prose that describes the removed copying as live behavior. Three sites
      were identified: `Verified/Bridge/BoxSaturation.lean:266-283` (the `BoxTemporalSpread`
      docstring, which cites `Tableau.lean:553-559` as the supplier),
      `Verified/Bridge/BoxSaturation.lean:415-419` (the `BoxAnchored` rationale, which credits
      `tempGProps`/`tempHProps` for supplying `G` and `H` at the minting time), and
      `Verified/Bridge/TruthLemma.lean:379-390` (the O3 status block). Each must state that the
      copies were removed as unsound and, for the `BoxAnchored` site, forward-reference the
      Phase 5 finding rather than silently deleting the sentence.
- [x] Confirm the modules investigation predicts SAFE actually are:
      `Verified/Bridge/TemporalSaturation.lean`, `Verified/Bridge/PropSaturation.lean`,
      `Verified/Termination/Fuel.lean` (`:1118-1140`, `witnessPresent` only),
      `Verified/Termination/TimeTypeBound.lean`,
      `CountermodelExtraction.lean` (`:505-524`, `sat_box_neg`, reasons via `witnessPresent`),
      `TraceCertificate.lean` (`:212-213`, a rule-name table), `TraceExport.lean`,
      `Decidability.lean`.
- [x] Re-eyeball `Saturation.lean`'s Modal-Temporal Interaction block (`:1176-1256`, MT1-MT6).
      It uses `#eval` with no `#guard_msgs`, so it cannot fail the build, but MT4 and MT6
      (`□p → □(Gp)`) may now print different verdicts. Record any change; do not treat a printed
      FAIL as a build failure, and do not "fix" it by editing the engine.
- [x] **STOP if `Verified/Decidable.lean` fails.** Do not edit it. Mark the phase `[BLOCKED]`,
      record the exact error and goal state, and report.
- [x] Introduce no `sorry` and no vacuous definition (`:= True`, `:= trivial`, `:= Unit`). The
      `Verified/` tree currently has zero `sorry` terms; it must still have zero afterwards. If a
      proof cannot be repaired, the phase is `[BLOCKED]`.
- [x] Re-run `lake build` to green. Release the lock.

**Timing**: 1.75 hours

**Depends on**: 3

**Verification Tier**: full

**Scope Hypothesis**: This phase asserts that zero compile-time repairs are needed and that the
work is confined to pruning two inert simp lists and rewriting three prose sites. That prediction
comes from a static read of the tactic scripts, not from a build. Lean's actual elaboration is
the only authority: the implementer lets the error list define the real scope, and records any
expansion beyond `SubformulaProperty.lean` in the phase notes rather than silently absorbing it.

**Files to modify**:
- `FormalSystem/Metalogic/Decidability/Verified/Termination/SubformulaProperty.lean` - prune the
  six dead accessor names from the two `simp only` lists; repair only if the build requires it
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/BoxSaturation.lean` - rewrite the
  `BoxTemporalSpread` (`:266-283`) and `BoxAnchored` (`:415-419`) rationale prose
- `FormalSystem/Metalogic/Decidability/Verified/Bridge/TruthLemma.lean` - rewrite the O3 status
  block (`:379-390`)
- Other `applyRule`-dependent modules - only as the build requires
- **NOT** `FormalSystem/Metalogic/Decidability/Verified/Decidable.lean`

**Verification**:
- `lake build` exits zero with pre/post olean counts consistent with a completed build.
- `git diff --name-only` does NOT list `Verified/Decidable.lean`.
- `grep -rn 'sorry' FormalSystem/Metalogic/Decidability/Verified/` still yields only the
  prose/"sorry-free" hits, with no new term-level `sorry`.
- No `:= True` / `:= trivial` / `:= Unit` definition was introduced.
- No surviving docstring in `BoxSaturation.lean` or `TruthLemma.lean` describes the temporal
  copies as behavior the engine currently performs.

---

### Phase 5: Measure and Document the boxAnchoredCheck Consequence [COMPLETED]

**Goal**: Determine empirically whether `boxAnchoredCheck` still computes `true` on multi-world
branches after the deletion, enumerate every downstream lemma that carries it as a hypothesis, and
write the result up as a self-contained handoff finding for task 165 — without repairing it.

**Tasks**:
- [x] Construct a minimal multi-world probe (a scratch `#eval`, not a committed test) that builds
      a branch exercising `boxNeg`/`diamondPos` world-minting and evaluates `boxAnchoredCheck` on
      the result. Record the measured value. Compare against the Phase 2 `BoxSpreadProbe`
      anchor baseline (rows A/B/C, previously `anchor = true`, `|T| = 7` / `|T| = 10`).
- [x] Confirm or refute the mechanism claim: that no rule other than the deleted blocks can place
      `T(Gφ)` or `T(Hφ)` at a freshly minted world. Check each candidate route explicitly —
      `boxProps` supplies only `T(inner)`; `boxTemporal` fires only on `T(□·)`;
      `allFuturePos`/`allPastPos` require `T(G·)`/`T(H·)` already present;
      `boxDiamondPersistence` relabels within a world across times, not across worlds.
- [x] Enumerate and verify the carrier list — the lemmas taking `hBA : boxAnchoredCheck b = true`
      as a hypothesis: `sat_box_grid_of_anchored` and `sat_box_grid_of_check`
      (`Verified/Bridge/BoxSaturation.lean:534-551`); `Verified/Bridge/IntTruth.lean` lines 351,
      366, 853, 866, 886, 1030, 1059; `Verified/Bridge/DenseTruth.lean` lines 84, 582, 613, 654,
      677. Confirm each still typechecks (it should — the hypothesis is carried, never unfolded)
      and record which now have a hypothesis that is no longer dischargeable by computation.
- [x] Write `specs/418_.../artifacts/boxanchored-finding.md`: the measured before/after
      `boxAnchoredCheck` values, the mechanism argument, the full carrier list with file:line
      references, the precise statement of what is lost (the truth lemma's `box` case side
      condition stops being computable-true on real engine output), and an explicit note that
      nothing breaks at typecheck.
- [x] Sketch — as *options for task 165*, not as work performed — the candidate repairs and their
      soundness obligations: (a) propagate `T(□φ)` itself to the fresh world; (b) copy
      `T(Gφ)`/`T(Hφ)` only when box-derived; (c) weaken `BoxAnchored` / restructure the truth
      lemma's `box` case to not need the anchor. State for each what would have to be proved.
- [x] **Do not implement any of them.** Do not add any propagation block to `applyRule`. Do not
      edit `Verified/Decidable.lean`. Re-verify at phase end that
      `git diff FormalSystem/Metalogic/Decidability/Tableau.lean` is byte-identical to its
      Phase 3 state.

**Timing**: 1.5 hours

**Depends on**: 4

**Verification Tier**: interface

**Scope Hypothesis**: This phase asserts that `boxAnchoredCheck` will measure `false` on
multi-world branches post-fix, and asserts a specific carrier list of fourteen file:line sites
across three files. Both come from a static read during planning. The implementer must measure
the check rather than assume the predicted `false`, and must re-derive the carrier list by
searching for `boxAnchoredCheck` occurrences rather than trusting the enumerated line numbers —
recording any carrier this plan missed, and any listed line that does not in fact carry it.

**Files to modify**:
- `specs/418_.../artifacts/boxanchored-finding.md` - new; the measurement, mechanism, carrier
  list, loss statement, and repair options for task 165

No `.lean` file is modified in this phase. The measurement is done with scratch `#eval`s that are
not committed.

**Verification**:
- `boxanchored-finding.md` records a measured before-value and a measured after-value for
  `boxAnchoredCheck`, not a predicted one.
- The carrier list is derived from a fresh search and every entry carries a file:line reference.
- `git diff --name-only -- FormalSystem/ Tests/` shows no change beyond Phases 3 and 4.
- `Tableau.lean`'s diff is unchanged from Phase 3 — no propagation block was added.

---

### Phase 6: AFTER Corpus Measurement — Surface Every Moved Row [PARTIAL]

**Goal**: Run the full corpus against the fixed engine and produce a complete per-row record of
what moved — measuring first and adjudicating later, so the measurement is not contaminated by
edits made while taking it.

**Tasks**:
- [ ] Acquire the lock, bracket with olean counts, run `lake build BimodalTest`. Capture full
      output to `specs/418_.../artifacts/after-corpus-raw.log`.
- [x] Because a `#guard_msgs` mismatch is a hard error that can mask later rows in the same file,
      build each of the eight probe modules individually *(deviation: skipped — `lake build BimodalTest` surfaced every failing module independently and every mismatching row within each module; the raw log shows no masking, so the insurance was unnecessary)*
      (`lake build BimodalTest.TableauConformance`, `lake build BimodalTest.BoxNegReachabilityProbe`,
      and so on) so every file's mismatch set is surfaced independently.
- [ ] For each mismatch, record the row, its old expected value, and the actual value Lean
      reports, into `specs/418_.../artifacts/after-verdicts.md`. **Do not edit any test file in
      this phase.** This phase measures; Phase 7 adjudicates.
- [ ] Classify each moved row into a bucket and record it: (a) **intended repair** — a
      previously-`allClosed`/`extractionFailed` verdict on an invalid formula now
      `hasOpen`/`invalid`; (b) **probe-pins-the-bug** — the row asserted the buggy behavior
      directly and its new value is the correct one; (c) **suspected under-closing regression** —
      a valid formula that no longer closes; (d) **saturation-metric change** — `|T|`, `anchor`,
      candidate-count vectors and similar structural measurements that moved because the fresh
      world now carries fewer formulas; (e) **fuel/resource change**.
- [ ] *(deviation: deferred — measured STALLED at fuel 30/60; the fuel-1000 run did not terminate in over an hour and was stopped. See after-verdicts.md.)* Check the anchor row explicitly: `buildTableau ((G p) → □(G p)) 1000 .Base` must now return
      `.hasOpen`, and `decide` on it must return `.invalid` with `getCountermodel?.isSome = true`.
      This is the headline acceptance criterion; record its measured value verbatim.
- [ ] Confirm or refute each row predicted at planning time to move, recording what Lean actually
      reports rather than the prediction:
      - `BoxNegPreservationProbe` rows 1 (`emitted.length`, 2 → predicted 1), 3 (opposite-sign
        clash, true → predicted false), 4 (copied `T(G p)` present, true → predicted false);
        row 5 (`isValid = false`) predicted unchanged.
      - `BoxNegReachabilityProbe` rows 6-12; rows 1-4 (schedule and additivity) predicted safe.
      - `BoxSpreadProbe` rows A/B/C (`anchor`, `|T| = 7` / `|T| = 10`); rows D/E (`gapProbe`,
        single-world) predicted safe.
      - `RegionGateProbe` rows A, B, C, H (multi-world, `|T|` and `cands` vectors); rows D-G, I
        predicted safe.
      - `RayRegionProbe` row D (`"OPEN |W|=2 |T|=7 … rays=[(2, 2), (5, 5)]"`); rows A-C, E-G
        predicted safe.
      - `TemporalWitnessProbe` row D (`(□p ∧ ◇q) → r`) recurring at `:407`, `:520-522`,
        `:628-630`, `:774-776` and near `:914`; all other rows predicted safe.
      - `CrossWorldPropagationProbe` all five rows predicted safe in value (they pin `isValid`
        only) but superseded in narrative.
- [ ] Record any row that moved which this plan did not anticipate as a first-class finding.
- [ ] Release the lock.

**Timing**: 1.75 hours

**Depends on**: 5

**Verification Tier**: full

**Scope Hypothesis**: This phase predicts a specific moved set — roughly seventeen rows named
above across six of the eight probe files — and predicts specific new values for several. Every
one is a hypothesis derived from reading probe sources, not a measurement. The build output
defines the actual moved set; unanticipated movement is a finding to record, not noise to fold
into the predicted set.

**Files to modify**:
- `specs/418_.../artifacts/after-corpus-raw.log` - new; raw per-module build output
- `specs/418_.../artifacts/after-verdicts.md` - new; per-row moved/unmoved record with bucket
  classification

No `.lean` file is modified in this phase. That is the point of separating it from Phase 7.

**Verification**:
- `after-verdicts.md` accounts for every row in the Phase 2 baseline as moved or unmoved.
- Every moved row carries an actual value quoted from Lean's output and a bucket label.
- The anchor row's measured `buildTableau` / `decide` / `getCountermodel?` values are recorded.
- `git diff --name-only -- Tests/` is empty.

---

### Phase 7: Adjudicate and Realign the Corpus [IN PROGRESS]

**Goal**: Turn the Phase 6 measurement into a green corpus, updating each moved row's expected
value only where the new value is individually justified as correct — and escalating, rather than
softening, any row that cannot be justified.

**Tasks**:
- [ ] For each moved row in bucket (a), (b) or (d), write a one-to-two sentence justification of
      why the new value is the semantically correct one, then update the `/-- info: ... -/`
      expectation in the source to match. Bucket (d) rows additionally cross-reference
      `boxanchored-finding.md`, since a moved `anchor` or `|T|` value is that finding observed
      from the test side.
- [ ] Rewrite the prose. `BoxNegReachabilityProbe.lean` and `BoxNegPreservationProbe.lean` are
      extended arguments *about the defect*, written in the present tense — their module
      docstrings assert that the copy fires, that the branch closes, and that `decide` returns
      `extractionFailed`. After the fix those sentences are false. Each docstring must be
      rewritten to record the defect in the past tense and to state that the rows below now pin
      the *repaired* behavior. A corrected numeric expectation sitting under prose that
      contradicts it is not an acceptable end state.
- [ ] Do the same for the narratives in `BoxSpreadProbe.lean` (`:29`),
      `CrossWorldPropagationProbe.lean` (whose five values are predicted to survive but whose
      thesis — "the copy does not make the engine decide wrongly" — is superseded), and
      `TemporalWitnessProbe.lean`.
- [ ] For each moved row in bucket (c) or (e) — suspected under-closing or resource change —
      **do not edit the assertion to make it pass.** Adjudicate: determine from the semantics
      whether the formula is valid. If it is valid and no longer closes, that is a genuine
      regression. Record it in `after-verdicts.md` with a full description and mark this phase
      `[BLOCKED]` if it cannot be resolved without re-adding unsound behavior.
- [ ] Under no circumstances re-add any of the six deleted blocks, or a narrower variant, to make
      a row pass. If a row genuinely requires cross-world temporal propagation to close, that is
      a finding for task 165 — append it to `boxanchored-finding.md` — not a licence to
      reintroduce the unsoundness.
- [ ] Acquire the lock and re-run `lake build BimodalTest` to green, or to a state where every
      remaining failure is a recorded, triaged bucket-(c)/(e) regression. Release the lock.

**Timing**: 2.0 hours

**Depends on**: 6

**Verification Tier**: full

**Files to modify**:
- `Tests/BimodalTest/BoxNegReachabilityProbe.lean` - update moved expectations; rewrite the
  module docstring to past tense
- `Tests/BimodalTest/BoxNegPreservationProbe.lean` - same
- `Tests/BimodalTest/BoxSpreadProbe.lean` - rows A/B/C expectations and the `:29` narrative
- `Tests/BimodalTest/RegionGateProbe.lean` - rows A, B, C, H if moved
- `Tests/BimodalTest/RayRegionProbe.lean` - row D if moved
- `Tests/BimodalTest/TemporalWitnessProbe.lean` - row D occurrences if moved
- `Tests/BimodalTest/TableauConformance.lean` - any moved pinned-verdict rows
- `Tests/BimodalTest/CrossWorldPropagationProbe.lean` - narrative; values only if measured to move
- `specs/418_.../artifacts/after-verdicts.md` - per-row justifications and regression triage
- `specs/418_.../artifacts/boxanchored-finding.md` - append any corpus-side evidence

**Verification**:
- `lake build BimodalTest` exits zero, or every remaining failure is an explicitly recorded
  bucket-(c)/(e) regression with written triage.
- Every changed `/-- info: ... -/` line has a written justification in `after-verdicts.md`.
- No `#guard_msgs` block was deleted or commented out and no assertion was weakened to a
  tautology — per-file `grep -c '#guard_msgs'` matches the Phase 2 baseline counts exactly.
- `git diff FormalSystem/Metalogic/Decidability/Tableau.lean` is unchanged from Phase 3 — no
  deleted block was reintroduced in any form.
- Neither `BoxNeg*Probe` docstring still asserts in the present tense that the copy fires.

---

### Phase 8: Acceptance Gate and Before/After Verdict-Change Table [NOT STARTED]

**Goal**: Run the full acceptance gate under the build-reliability protocol and produce the
before/after verdict-change table the task requires as its summary deliverable.

**Tasks**:
- [ ] Acquire the lock. Record the olean count.
- [ ] Run the complete gate in order: `lake build` (library), then `lake build BimodalTest`
      (corpus). Capture both to `specs/418_.../artifacts/acceptance-build.log`.
- [ ] Record the olean count after. Apply the infra-vs-verdict triage one final time: if either
      build hit an infrastructure error the gate is **inconclusive** — retry the whole gate. Do
      not write the summary on an inconclusive gate, and never describe an interrupted build as
      a pass.
- [ ] Write `specs/418_.../summaries/01_remove-unsound-temporal-copy-blocks-summary.md`
      containing the **before/after verdict-change table**: one row per corpus row that changed,
      with columns *formula / probe row*, *old verdict*, *new verdict*, *bucket*,
      *justification*. Rows that did not change are summarized in aggregate with a count, not
      enumerated.
- [ ] Include in the summary: the anchor result (`(G p) → □(G p)` now `.hasOpen`, `decide` now
      `.invalid` with a countermodel), the total moved-row count, the `boxAnchoredCheck` finding
      in one paragraph with a pointer to `boxanchored-finding.md`, any bucket-(c)/(e) regression
      left open, and the final state of both builds.
- [ ] State explicitly that `Verified/Decidable.lean` was not modified, that the `RuleSound`
      proof was not attempted, that no replacement propagation block was added, and that task 165
      Phase 7.2 is now unblocked with the `boxAnchoredCheck` gap as its inherited open item.
- [ ] Release the lock and remove the lock file.
- [ ] Commit with `task 418: {action}` and the session ID in the body. Do not push, do not create
      a PR.

**Timing**: 1.0 hours

**Depends on**: 7

**Verification Tier**: full

**Files to modify**:
- `specs/418_.../artifacts/acceptance-build.log` - new; final gate output
- `specs/418_.../summaries/01_remove-unsound-temporal-copy-blocks-summary.md` - new; the
  before/after verdict-change table and final state

**Verification**:
- Both `lake build` and `lake build BimodalTest` exited zero within a single locked window, with
  consistent olean counts.
- The summary contains a before/after table with one row per changed verdict.
- The summary names every unresolved regression, or states that there are none, and carries the
  `boxAnchoredCheck` handoff paragraph.
- `git diff --name-only` against the task's starting HEAD lists no file outside the declared
  scope plus the Phase 4 repair set, and does not list `Verified/Decidable.lean`.

---

## Testing & Validation

- [ ] `lake build` (library) exits zero, bracketed by consistent olean counts.
- [ ] `lake build BimodalTest` (full corpus, 145 `#guard_msgs` rows across eight probe files)
      exits zero, or every remaining failure is a recorded and triaged regression.
- [ ] `buildTableau ((G p) → □(G p)) 1000 .Base` returns `.hasOpen`.
- [ ] `decide ((G p) → □(G p))` returns `.invalid` with `getCountermodel?.isSome = true`.
- [ ] `grep -c` for all six `temp*Props` identifiers in `Tableau.lean` returns 0; exactly two
      occurrences of `witness :: boxProps ++ diaProps`.
- [ ] `boxAnchoredCheck`'s post-fix value is measured and documented, with its carrier list.
- [ ] No `sorry`, no vacuous definition, no deleted or weakened `#guard_msgs` block in the diff;
      the `Verified/` tree still has zero term-level `sorry`.
- [ ] `Verified/Decidable.lean` is absent from `git diff --name-only`.
- [ ] No propagation block was added to `applyRule` to compensate for the deletion.
- [ ] Every changed expected value has a written justification in the verdict artifacts.

## Artifacts & Outputs

- `specs/418_.../artifacts/build-environment.md` - build lock protocol, environment snapshot,
  infra-vs-verdict triage checklist
- `specs/418_.../artifacts/baseline-build.log`, `baseline-corpus.log`, `baseline-verdicts.md` -
  the BEFORE measurement
- `specs/418_.../artifacts/boxanchored-finding.md` - the `boxAnchoredCheck` measurement,
  mechanism, carrier list, and repair options handed to task 165
- `specs/418_.../artifacts/after-corpus-raw.log`, `after-verdicts.md` - the AFTER measurement,
  per-row bucket classification, and regression triage
- `specs/418_.../artifacts/acceptance-build.log` - the final gate
- `specs/418_.../summaries/01_remove-unsound-temporal-copy-blocks-summary.md` - the before/after
  verdict-change table and final state
- Modified: `FormalSystem/Metalogic/Decidability/Tableau.lean` (the fix), the Phase 4 repair and
  prose set, and the Phase 7 corpus realignment set

## Rollback/Contingency

The fix is a single-file pure deletion, so rollback is cheap and precise:

- **Revert the engine edit only**: `git checkout HEAD -- FormalSystem/Metalogic/Decidability/Tableau.lean`,
  then `lake build`. The measurement artifacts under `specs/418_.../` retain their value even if
  the code change is reverted — the baseline, the moved-row table, and the `boxAnchoredCheck`
  finding are the task's durable output.
- **Full revert**: `git checkout HEAD -- FormalSystem/ Tests/` restores the pre-task state.
  Never use `lake clean` to recover from a bad build; a targeted revert plus rebuild is always
  sufficient and does not endanger concurrent sessions.
- **If Phase 4 blocks on `Verified/Decidable.lean`**: leave the `Tableau.lean` edit in place,
  mark the phase `[BLOCKED]`, and report. That file is task 165's; a blocked handoff there is the
  correct outcome, not a failure of this task.
- **If Phase 5 confirms `boxAnchoredCheck = false`**: this is an expected finding, not a rollback
  trigger. Document and continue. Reverting the fix to preserve a computable side condition would
  trade a real soundness defect for a proof convenience.
- **If Phase 7 finds a genuine under-closing regression**: leave the fix in place and record the
  regression. Reintroducing the unsound blocks to make a row pass would restore a measured
  soundness defect in exchange for a green test, which is strictly worse than a red test beside a
  sound engine. Escalate instead.
- **If a build is destroyed by a concurrent session**: this is never a rollback trigger. Retry
  the build under the lock. Only a verdict-class failure justifies reverting code.
