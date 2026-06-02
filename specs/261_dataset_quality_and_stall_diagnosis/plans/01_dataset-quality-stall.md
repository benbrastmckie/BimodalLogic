# Implementation Plan: Task #261

- **Task**: 261 - Dataset Quality and Stall Diagnosis
- **Status**: [NOT STARTED]
- **Effort**: 10 hours
- **Dependencies**: Task 253 (enriched countermodel + decision method tracking)
- **Research Inputs**: specs/261_dataset_quality_and_stall_diagnosis/reports/01_dataset-quality-stall.md
- **Artifacts**: plans/01_dataset-quality-stall.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The c9 dataset generation stalled after 5,671 of ~1.6M formulas due to three independent root causes: (1) a persistent rule loop in `boxPos` that causes infinite cycling between persistent and consumable tableau rules, (2) no per-formula wall-clock timeout allowing a single formula to hang the entire pipeline, and (3) missing JSONL fields from an outdated binary. This plan addresses all three causes through four sequential phases: fixing the persistent rule loop in the tableau, adding adaptive fuel caps, extending the proof fast path for box-valid formulas, and rebuilding the pipeline to re-run c9 with all fixes active.

### Research Integration

The research report (01_dataset-quality-stall.md) identified:
- The persistent rule loop in `Saturation.lean` (lines 741-766) as the primary stall cause, with `boxPos` and `negPos` cycling infinitely
- 649 of 5,671 formulas (11.4%) labeled as timeout, with ~150-200 being provably valid (patterns like `[](bot -> X)`, `([]bot -> X)`, `[](X -> X)`)
- `soundFuel` up to 100,000 steps with O(branch_size) work per step on looping formulas
- Missing JSONL fields resolved by rebuilding with current code (no code fix needed)
- The stall formula was #5672: `(box(bot -> bot) -> r)`, complexity 6

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md items directly referenced. This task falls under the "dataset-enhancement" topic, improving the data generation pipeline for neural network training data quality.

## Goals & Non-Goals

**Goals**:
- Eliminate the persistent rule loop that causes infinite tableau expansion on box-containing formulas
- Ensure no single formula can hang the pipeline for more than a few seconds
- Correctly label box-valid formulas (currently mislabeled as timeout) as valid with proof traces
- Rebuild the dataset generator binary with all current code (resolving missing JSONL fields)
- Enable complete c9 generation (all ~1.6M formulas) to finish in reasonable time (< 6 hours)

**Non-Goals**:
- Multi-frame-class CLI support (Dense/Discrete) -- separate task scope
- Proving the tableau termination theorem (`blocking_terminates`) -- requires the loop fix but is a separate formal verification effort
- Changing the formula enumeration strategy
- Modifying the proof extraction pipeline (task 239 already addressed this)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Applied-set tracking changes tableau semantics, breaking soundness | H | L | The tracking only prevents re-application of identical (rule, formula) pairs; soundness proofs do not depend on re-application. Verify `expandBranchWithFuel_sound` still type-checks. |
| Adaptive fuel caps mask genuine bugs by labeling hard formulas as timeout | M | M | Use three escalating fuel levels (500, 2000, 10000) so most formulas get adequate fuel. Log fuel level used in decision_method field for analysis. |
| Necessitation fast path produces incorrect proofs for non-theorems | H | L | The fast path only fires when `buildCompositionalProof inner` succeeds, which already verifies the inner formula is provable. Type system enforces proof correctness. |
| Re-run discovers new stalling patterns not covered by the loop fix | M | M | Adaptive fuel caps (Phase 2) serve as a safety net even if new loop patterns emerge. Log slow formulas for post-run analysis. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Fix Persistent Rule Loop [COMPLETED]

**Goal**: Eliminate the infinite cycle between `boxPos` (persistent) and `negPos` (consumable) in tableau expansion by tracking already-applied persistent rule instances.

**Tasks**:
- [ ] Add an `appliedPersistent : Std.HashSet (String × SignedFormula)` field to be threaded through `expandBranchWithFuel`, tracking `(ruleName, targetFormula)` pairs that have already been applied
- [ ] Modify `expandOnce` (or the rule-application dispatch within it) to check the applied set before applying any persistent rule (`boxPos`, `boxNeg`, `untilPos`, `sincePos`, and their temporal variants)
- [ ] When a persistent rule would be re-applied to the same formula, skip it (treat as not applicable) instead of re-adding the result
- [ ] Add the `(ruleName, targetFormula)` pair to the tracking set after each successful persistent rule application
- [ ] Thread the `appliedPersistent` set through all recursive calls in `expandBranchWithFuel` (the `fuel + 1` branch and the `split branches` fold)
- [ ] Verify that `expandBranchWithFuel_sound` still type-checks (the soundness theorem should be unaffected since it only depends on `findClosure` results, not on which rules were applied)
- [ ] Test with the known counterexample: `◇p = (□(p → ⊥)) → ⊥` should now terminate without exhausting fuel
- [ ] Test with the stall formula: `(box(bot -> bot) -> r)` should decide quickly

**Timing**: 3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add applied-set tracking to `expandBranchWithFuel`, modify persistent rule dispatch in `expandOnce` or `applyRule`
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - If `applyRule` is where persistent rules are dispatched, add the applicability check there

**Verification**:
- `lake build` passes with no new errors
- The comment block at Saturation.lean lines 741-766 can be updated to note the fix
- Manual test: `#eval decide (Formula.imp (Formula.box (Formula.imp (Formula.atom 0 |>.imp .bot) .bot)) .bot) 10 200 .Base` terminates with a result (not `.timeout`)

---

### Phase 2: Add Adaptive Fuel Caps [COMPLETED]

**Goal**: Replace the single large `soundFuel` call with an escalating adaptive fuel strategy so no individual formula consumes more than a few seconds of wall-clock time, while still giving most formulas enough fuel to decide.

**Tasks**:
- [ ] Create `decideAutoAdaptive` function in `DecisionProcedure.lean` that tries escalating fuel levels: `[500, 2000, 10000]`
- [ ] For each fuel level, call `decide φ depth fuel fc` -- if the result is `.timeout`, try the next level; if valid or invalid, return immediately
- [ ] If all fuel levels exhaust, return `.timeout` with the total fuel attempted recorded
- [ ] Add a `fuel_used` or `fuel_level` field to the result metadata so `labelFormula` can record which fuel tier was needed (logged in `decision_method` as e.g. `"adaptive_fuel_500"`, `"adaptive_fuel_2000"`, `"adaptive_fuel_10000"`, `"adaptive_timeout"`)
- [ ] Update `decideAuto` to call `decideAutoAdaptive` instead of `decide` with `soundFuel`
- [ ] Preserve the `soundFuel` function unchanged (still useful as a reference bound)
- [ ] Update `labelFormula` in `DatasetGenerator.lean` to propagate the fuel-level metadata into the `decision_method` field

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Add `decideAutoAdaptive`, update `decideAuto`
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Update `labelFormula` to record fuel tier in decision_method

**Verification**:
- `lake build` passes
- All existing `decideAuto` callers still compile (API change is internal)
- A formula that previously hit 100,000-step fuel now terminates after at most 10,000 steps

---

### Phase 3: Fast Path for Box-Valid Formulas [COMPLETED]

**Goal**: Extend the proof fast path in `buildCompositionalProof` to handle common box-valid patterns that currently fall through to the tableau and timeout, including necessitation of provable inner formulas and vacuous box implications.

**Tasks**:
- [ ] Add a `box` case to `buildCompositionalProof` that handles `Formula.box inner`: if `buildCompositionalProof inner (fuel-1)` succeeds with proof `p`, construct `DerivationTree.necessitation [] inner p` and return it
- [ ] Add handling for `Formula.imp (Formula.box .bot) rhs`: this is `([]bot -> X)` which is valid because `[]bot` is unsatisfiable. Construct the proof via: `modal_t : []bot -> bot` (axiom), then `ex_falso : bot -> X` (axiom), then chain with `imp_trans`
- [ ] Verify the proof constructions type-check by testing with specific formulas:
  - `[](bot -> p)` should return `.valid` with a proof via necessitation of `ex_falso`
  - `([]bot -> r)` should return `.valid` via the modal_t + ex_falso chain
  - `[](p -> p)` should return `.valid` via necessitation of identity
- [ ] Ensure the fast path fires before `bounded_search_with_proof` and `buildTableau` in the `decide` function (it already does via `buildCompositionalProof` called from `tryAxiomProof` path, but verify the compositional proof is actually called -- currently `decide` only calls `tryAxiomProof`, not `buildCompositionalProof`)
- [ ] If `decide` does not call `buildCompositionalProof`, add it as a second fast-path attempt between `tryAxiomProof` and `bounded_search_with_proof`

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` - Extend `buildCompositionalProof` with `box` case and `imp (box bot) _` case
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Add `buildCompositionalProof` call to `decide` if not already invoked in the fast-path chain

**Verification**:
- `lake build` passes
- `#eval decide (Formula.box (Formula.imp .bot (Formula.atom 0))) 10 200 .Base` returns `.valid` (not `.timeout`)
- `#eval decide (Formula.imp (Formula.box .bot) (Formula.atom 0)) 10 200 .Base` returns `.valid`
- `#eval decide (Formula.box (Formula.imp (Formula.atom 0) (Formula.atom 0))) 10 200 .Base` returns `.valid`

---

### Phase 4: Rebuild and Validate [NOT STARTED]

**Goal**: Rebuild the dataset generator binary with all fixes applied, run a validation pass on a subset of formulas to confirm correctness improvements, and prepare for full c9 re-run.

**Tasks**:
- [ ] Run `lake build` to compile the full project with all changes from Phases 1-3
- [ ] Run `lake build dataset_generator` (or equivalent target name for the CLI executable) to rebuild the dataset generation binary
- [ ] Create a small validation script that tests the known problematic formulas:
  - The 649 timeout formulas from the c9 run (if available in existing data)
  - The stall formula `(box(bot -> bot) -> r)`
  - A sample of box-valid patterns: `[](bot -> p)`, `([]bot -> r)`, `[](p -> p)`, `[](bot -> bot)`
- [ ] Verify the rebuilt binary includes all 6 previously-missing JSONL fields (`decision_method`, `proof_reconstruction_method`, `rule_profile`, `countermodel_consistent`, `enriched_countermodel`, `semantic_countermodel`) by examining the first few output records
- [ ] Run a short generation test: generate and label the first 100 formulas at complexity 3-5 to confirm:
  - No stalling
  - Timeout rate drops significantly (from 11.4% to < 3%)
  - All JSONL fields present
  - Box-valid formulas correctly labeled as valid with proof traces
- [ ] Update the Saturation.lean comment block (lines 741-766) to document the resolution of the persistent rule loop
- [ ] Add progress logging enhancement: log a warning when a formula exceeds 1 second of decision time (for post-run analysis of remaining slow formulas)

**Timing**: 3 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Update documentation comments at lines 741-766
- `Theories/Bimodal/Automation/DatasetExport.lean` - Add per-formula timing warning log (optional, low-risk enhancement)
- `scripts/run_dataset_generation.sh` - Verify script still works with rebuilt binary

**Verification**:
- `lake build` passes with zero errors
- Short generation test (100 formulas) completes in < 30 seconds with correct output
- All JSONL fields present in output records
- No formula takes > 10 seconds to decide
- Timeout rate on test subset is < 5%

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] The known counterexample `◇p = (□(p → ⊥)) → ⊥` terminates quickly (< 1 second)
- [ ] The stall formula `(box(bot -> bot) -> r)` decides in < 1 second
- [ ] Box-valid formulas `[](bot -> p)`, `([]bot -> r)`, `[](p -> p)` all labeled as `.valid` with proof traces
- [ ] Short dataset generation run (100-1000 formulas) completes without stalling
- [ ] Timeout rate drops from 11.4% to < 3% on equivalent formula set
- [ ] All 22 JSONL fields present in output records (including the 6 previously missing)
- [ ] `expandBranchWithFuel_sound` theorem still type-checks (soundness preserved)

## Artifacts & Outputs

- `specs/261_dataset_quality_and_stall_diagnosis/plans/01_dataset-quality-stall.md` (this plan)
- Modified `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (persistent rule loop fix)
- Modified `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` (adaptive fuel)
- Modified `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` (box fast path)
- Modified `Theories/Bimodal/Automation/DatasetGenerator.lean` (fuel-level metadata)
- Modified `Theories/Bimodal/Automation/DatasetExport.lean` (timing warnings)
- Rebuilt `dataset_generator` binary
- `specs/261_dataset_quality_and_stall_diagnosis/summaries/01_dataset-quality-stall-summary.md` (post-implementation)

## Rollback/Contingency

All changes are in Lean source files tracked by git. If any phase introduces build errors or incorrect behavior:
1. `git stash` or `git checkout -- Theories/Bimodal/` to revert
2. Each phase's changes are isolated to specific files, enabling selective rollback
3. The `soundFuel` function is preserved unchanged, so the original behavior can be restored by reverting `decideAuto` to call `decide` with `soundFuel` directly
4. The persistent rule loop fix is additive (tracking set), so removing it restores original behavior without affecting other code
