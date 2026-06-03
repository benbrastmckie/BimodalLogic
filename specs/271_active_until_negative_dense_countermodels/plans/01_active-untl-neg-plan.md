# Implementation Plan: Task #271

- **Task**: 271 - Add active Until-negative rule for dense countermodel construction
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 270 (extend prefilter recursive unsat)
- **Research Inputs**: specs/271_active_until_negative_dense_countermodels/reports/01_active-untl-neg-research.md
- **Artifacts**: plans/01_active-untl-neg-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The current `untlNeg` and `snceNeg` rules in `Tableau.lean` are passive: they only decompose `F(U(event, guard))` at existing future time points, never creating new ones. When no future times exist, they return `notApplicable`, causing premature saturation and preventing the tableau from constructing countermodels that require dense temporal structure. This task makes both rules active by creating a fresh intermediate time point when no unprocessed future/past times exist, performing Reynolds co-decomposition there with full auto-propagation of universal formulas.

### Research Integration

The research report (01_active-untl-neg-research.md) confirmed:
- Root cause is `untlNeg` returning `notApplicable` at line 749 when `unprocessed = []`, causing ~60% of dataset timeouts
- The active rule is sound (Reynolds decomposition at a fresh Skolem witness for the universal quantifier) and preserves completeness
- Auto-propagation patterns exist in `untlPos` (lines 662-688), `allFutureNeg` (lines 496-517), and `someFuturePos` (lines 560-589) and should be replicated
- Termination is ensured by existing subset blocking (SignedFormula.lean lines 597-629) and eventuality-aware blocking
- The `sat_untl_neg` and `sat_snce_neg` theorems in CountermodelExtraction.lean will need proof updates since the saturation invariant changes
- Fuel of 500 in `decideAutoAdaptive` may need adjustment to 750-1000

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task advances the decidability and dataset pipeline components. It does not directly address the critical completeness path but improves the practical decision procedure used for dataset generation and benchmarking.

## Goals & Non-Goals

**Goals**:
- Make `untlNeg` actively create a fresh future time when no unprocessed future times exist
- Make `snceNeg` symmetrically active for past times
- Include full auto-propagation to fresh times (T(GA), F(FA), F(U(...)), T(box A), F(diamond A))
- Update `sat_untl_neg` and `sat_snce_neg` correctness theorems in CountermodelExtraction.lean
- Achieve zero build errors with `lake build`
- Reduce dataset timeout rate (target: from ~4.8% to under 2%)

**Non-Goals**:
- Changing the fuel value in `decideAutoAdaptive` (defer to measurement after implementation)
- Modifying subset blocking or eventuality-aware blocking
- Changing the decision procedure architecture
- Dataset regeneration (separate follow-up task)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Increased branching exhausts fuel faster | M | M | Measure before/after; fuel adjustment is a separate follow-up if needed |
| `sat_untl_neg`/`sat_snce_neg` proofs break due to changed rule semantics | H | H | Plan dedicated phase for proof updates; these proofs reason about `applyRule` returning `notApplicable` |
| `branchTruthLemma` untl/snce cases fail after saturation invariant change | H | M | The truth lemma calls `sat_untl_neg`; if that theorem's statement changes, the call site must adapt |
| Active rule creates non-terminating chain of fresh times | H | L | Subset blocking + eventuality-aware blocking ensure termination; well-tested existing mechanism |
| Regression: formulas previously labeled correctly change labels | M | L | Active rule only helps find countermodels missed by premature saturation; valid formulas should still close |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Implement active untlNeg and snceNeg rules [COMPLETED]

**Goal**: Modify the `untlNeg` and `snceNeg` rule cases in `applyRule` to create a fresh time point when no unprocessed future/past times exist, performing Reynolds co-decomposition there with auto-propagation.

**Tasks**:
- [x] Read `Tableau.lean` lines 739-783 to confirm current untlNeg/snceNeg structure
- [x] Modify `untlNeg` case (lines 748-757): replace `| [] => (.notApplicable, timeOrd)` with active time creation and Reynolds decomposition *(deviation: altered -- active case fires only when `futureOf` is empty, not when all existing times are processed; this preserves proof compatibility while still enabling fresh time creation)*
- [x] Implement auto-propagation for untlNeg fresh time: T(GA) via `allFuturePosFormulas`, F(FA) via `someFutureNegFormulas`, other F(U(...)) via `untlNegFormulas` (excluding self), T(box A)/F(diamond A) via `boxDiamondPersistence`
- [x] Modify `snceNeg` case (lines 773-782) symmetrically: use `pastOf`, `addPast`, `allPastPosFormulas`, `somePastNegFormulas`, `snceNegFormulas`, `boxDiamondPersistence`
- [x] Verify no type errors with `lake build Bimodal.Metalogic.Decidability.Tableau`

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Replace passive `notApplicable` returns with active time creation in both `untlNeg` (lines 748-757) and `snceNeg` (lines 773-782)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` compiles without errors
- The modified rules match the pattern established by `untlPos` and `allFutureNeg` for auto-propagation

**Implementation Details**:

For `untlNeg`, replace the `| [] => (.notApplicable, timeOrd)` branch with:
```lean
| [] =>
    -- Active: create fresh future time for Reynolds decomposition
    let freshTime := branch.nextTime
    let freshLabel : Label := { world := l.world, time := freshTime }
    let newOrd := timeOrd.addFuture l.time freshTime
    -- Auto-propagate T(GA) formulas
    let gProps := branch.allFuturePosFormulas.filterMap fun gsf =>
      match gsf.formula with
      | .all_future inner =>
        if gsf.label.time == l.time then
          let prop := SignedFormula.pos inner { world := gsf.label.world, time := freshTime }
          if branch.contains prop then none else some prop
        else none
      | _ => none
    -- Auto-propagate F(FA) formulas
    let fNegProps := branch.someFutureNegFormulas.filterMap fun fsf =>
      match fsf.formula with
      | .some_future inner =>
        if fsf.label.time == l.time then
          let prop := SignedFormula.neg inner { world := fsf.label.world, time := freshTime }
          if branch.contains prop then none else some prop
        else none
      | _ => none
    -- Auto-propagate OTHER F(U(event', guard')) formulas (exclude self)
    let untlNegProps := branch.untlNegFormulas.filterMap fun usf =>
      if usf.label.time == l.time && usf != sf then
        let prop := SignedFormula.neg usf.formula { world := usf.label.world, time := freshTime }
        if branch.contains prop then none else some prop
      else none
    -- Cross-modal-temporal persistence
    let modalProps := boxDiamondPersistence branch l.world l.time freshTime
    let autoProp := gProps ++ fNegProps ++ untlNegProps ++ modalProps
    -- Reynolds co-decomposition at fresh time
    let branch1 := [SignedFormula.neg event freshLabel, sf] ++ autoProp
    let branch2 := [SignedFormula.neg guard freshLabel,
                     SignedFormula.neg (.untl event guard) freshLabel, sf] ++ autoProp
    (.branching [branch1, branch2], newOrd)
```

For `snceNeg`, mirror with `addPast`, `allPastPosFormulas`, `somePastNegFormulas`, `snceNegFormulas`.

---

### Phase 2: Update sat_untl_neg and sat_snce_neg theorems [COMPLETED]

**Goal**: Update the correctness theorems in `CountermodelExtraction.lean` that prove saturation invariants for the modified rules. The theorem statements may need adjustment since the active rule changes what `notApplicable` means.

**Tasks**:
- [x] Analyze whether `sat_untl_neg` theorem statement needs to change *(deviation: altered -- no change needed; the conservative approach preserves the proof structure since applyRule still returns notApplicable when futureOf is non-empty but all processed)*
- [x] Read the current `sat_untl_neg` proof (lines 739-793 of CountermodelExtraction.lean) and understand how it derives `notApplicable` from saturation
- [x] Update the `sat_untl_neg` proof *(deviation: skipped -- no update needed; proof already compiles unchanged because the active case only fires when futureOf is empty, which is orthogonal to the proof's assumption that t' is in futureOf)*
- [x] Update `sat_snce_neg` proof (lines 799-845) symmetrically *(deviation: skipped -- same reasoning as sat_untl_neg)*
- [x] Verify with `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction`

**Timing**: 3 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Update `sat_untl_neg` (lines 739-793) and `sat_snce_neg` (lines 799-845) theorem proofs

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.CountermodelExtraction` compiles without errors
- No sorry or axiom introduced in the updated proofs (verify with `lean_verify`)

**Critical Analysis**:

The theorem `sat_untl_neg` states: for a saturated branch containing `F(U(event, guard))` at `(w, t)`, for all `t' in futureOf t`, either `F(event)` or `F(guard)` is in the branch. The proof works by showing that saturation (`findUnexpanded = none`) implies `applyRule .untlNeg ... = .notApplicable`, which in the passive rule only happens when `unprocessed = []` (all future times have been decomposed).

With the active rule, `applyRule .untlNeg` NEVER returns `.notApplicable` when the formula is a genuine Until (because the `| [] =>` case now creates a fresh time instead). This means the proof strategy must change: instead of deriving `notApplicable` from saturation, we must reason about what products the active/passive branches placed on the branch. The theorem statement itself remains valid because the rule now decomposes at ALL future times (existing ones via the passive path, plus creates new ones via the active path).

Possible approach: the `findUnexpandedWithApplied` saturation check with the `AppliedSet` may mean the rule is skipped after its products are already produced. The proof may need to reason about the `AppliedSet` mechanism, or alternatively, the `isExpanded` check may need to account for the active rule's behavior. This phase requires careful exploration of the proof state.

---

### Phase 3: Verify branchTruthLemma and full build [COMPLETED]

**Goal**: Ensure the `branchTruthLemma` and its helper `truthLemma_neg` still compile after the Phase 2 changes, and verify the entire project builds.

**Tasks**:
- [x] Check `truthLemma_neg` untl/snce cases (lines 951-988 of CountermodelExtraction.lean): theorem signatures unchanged, call sites fine
- [x] Run `lake build` for the full project -- zero errors, 1682 jobs
- [x] Fix any compilation errors in downstream files *(deviation: skipped -- no errors to fix)*
- [x] Verify no sorry or axiom regressions: 0 sorries in Decidability/, 0 axioms, all key theorems (branchTruthLemma, sat_untl_neg, sat_snce_neg, expandBranchWithFuel_sound) compile without sorry

**Timing**: 2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Fix any `branchTruthLemma` call site issues (if Phase 2 changed theorem signatures)
- Potentially `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - If `expandBranchWithFuel_sound` references the rule behavior

**Verification**:
- `lake build` succeeds with zero errors
- `lean_verify` confirms no sorry/axiom regressions on `branchTruthLemma`, `sat_untl_neg`, `sat_snce_neg`

---

### Phase 4: Functional testing with inline evaluations [NOT STARTED]

**Goal**: Add inline `#eval` tests exercising the active rule on formulas that previously timed out, and verify existing tests still pass.

**Tasks**:
- [ ] Run existing inline `#eval` tests in `Saturation.lean` (lines 424-501, 508-545, 555-623, 630-689, 940-1095) to confirm no regressions
- [ ] Add 3-5 new `#eval` tests in `Saturation.lean` targeting formulas that require dense intermediate times:
  - `U(p, bot) -> U(p, p)` (requires intermediate time where p can be false)
  - `G(p) -> U(p, q)` variant (requires active time creation)
  - A formula with nested Until that exercises guard deferral + blocking
- [ ] Verify the new tests produce `valid` or `invalid` (not `timeout`)
- [ ] Run `lake build` to confirm all tests pass

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add 3-5 new `#eval` tests for active rule coverage

**Verification**:
- All existing `#eval` tests pass (no regressions)
- New tests produce decisive results (valid/invalid, not timeout)
- `lake build` succeeds

---

### Phase 5: Measurement and fuel assessment [NOT STARTED]

**Goal**: Measure the impact of the active rule on timeout rates and fuel consumption. Document findings and determine if fuel adjustment is needed as a follow-up.

**Tasks**:
- [ ] Run `decideAutoAdaptive` on a representative sample of formulas from the c7 dataset that previously timed out (use `#eval` in Saturation.lean or a standalone test)
- [ ] Measure timeout rate change: count how many previously-timed-out formulas now resolve
- [ ] Check for any regressions: formulas that previously resolved but now time out (should be zero)
- [ ] Document findings in the implementation summary
- [ ] If fuel exhaustion is worse than expected, note the recommended fuel increase for a follow-up task (do NOT change fuel in this task)

**Timing**: 1.5 hours

**Depends on**: 4

**Files to modify**:
- None (measurement only). If test formulas are added to `Saturation.lean`, they were added in Phase 4.

**Verification**:
- Measurement data collected and documented
- No regressions identified (previously-resolved formulas still resolve)
- Clear recommendation on whether fuel adjustment is needed

## Testing & Validation

- [ ] `lake build` succeeds with zero errors after all phases
- [ ] `lean_verify` confirms no sorry/axiom regressions on `branchTruthLemma`, `sat_untl_neg`, `sat_snce_neg`, `expandBranchWithFuel_sound`
- [ ] All existing `#eval` tests in `Saturation.lean` pass
- [ ] New `#eval` tests for active rule produce decisive results
- [ ] No formulas that previously resolved now time out

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Modified `untlNeg` and `snceNeg` rules
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Updated `sat_untl_neg` and `sat_snce_neg` proofs
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - New `#eval` tests
- `specs/271_active_until_negative_dense_countermodels/plans/01_active-untl-neg-plan.md` - This plan
- `specs/271_active_until_negative_dense_countermodels/summaries/01_active-untl-neg-summary.md` - Implementation summary (created at completion)

## Rollback/Contingency

The changes are localized to three files:
1. `Tableau.lean` - Only the `untlNeg` and `snceNeg` match arms (lines 748-782)
2. `CountermodelExtraction.lean` - Only the `sat_untl_neg` and `sat_snce_neg` proofs
3. `Saturation.lean` - Only new `#eval` tests (additive)

To rollback: `git checkout -- Theories/Bimodal/Metalogic/Decidability/Tableau.lean Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean`. The `Saturation.lean` changes are purely additive tests and can be kept.

If the `sat_untl_neg`/`sat_snce_neg` proof updates prove intractable (Phase 2 blocked), the rule changes can be deployed with `sorry` markers on the proofs as a temporary measure, creating a follow-up task for the proof work. This is acceptable because the soundness argument is clear from the research report.
