# Implementation Plan: Task #265

- **Task**: 265 - Simplify to single-tier fuel strategy with structural timeout pre-filter
- **Status**: [NOT STARTED]
- **Effort**: 3 hours
- **Dependencies**: Task 264 (completed), Task 263 (completed), Task 261 (completed)
- **Research Inputs**: specs/265_single_tier_fuel_and_timeout_prefilter/reports/01_fuel-strategy-prefilter.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Simplify the adaptive fuel strategy in `decideAutoAdaptive` from three tiers [500, 2000, 10000] to a single tier (fuel=500), eliminating dead code paths that task 264 proved are never reached. Add a structural pre-filter in `labelFormula` that detects known-valid timeout patterns (bot-temporal, double-box, box-prop) before invoking the decision procedure, labeling them as valid with zero fuel cost and the `structural_prefilter` decision method tag. After implementation, regenerate the c6 dataset to validate the speedup from ~18 hours to under 1 minute.

### Research Integration

Key findings from the research report (01_fuel-strategy-prefilter.md):

1. **Bimodal distribution confirmed**: Zero formulas across c3-c8 resolve at tier 2 or tier 3. The decision landscape is strictly bimodal -- formulas either resolve at fuel=500 or not at all.
2. **Soundness-critical pre-filter design**: A naive recursive `containsBotTemporal` is UNSOUND because bot-temporal subformulas in implication antecedents can make the antecedent always TRUE (not false). The correct approach uses `isUnsatBotTemporal` which only returns true when the sub-formula itself evaluates to false.
3. **Two-phase approach**: Call the pre-filter in `labelFormula` before `decideAutoAdaptive`, avoiding any modification to the `DecisionResult` type. Pre-filtered formulas are constructed as `LabeledFormula` directly with `label := .valid`, `proofTrace := none`, and `decisionMethod := "structural_prefilter"`.
4. **Coverage**: Pre-filter catches 151/247 c6 timeouts (61.1%), including ALL slow timeouts (405+ seconds). The remaining 96 are box-general-temporal patterns that include invalid formulas and must not be pre-filtered.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

This task does not directly advance any roadmap item. It is an infrastructure optimization for dataset generation throughput, reducing c6 generation time from ~18 hours to under 1 minute.

## Goals & Non-Goals

**Goals**:
- Simplify `decideAutoAdaptive` to single-tier fuel=500 with no functional regression
- Implement a sound structural pre-filter that catches bot-temporal, double-box, and box-prop validity patterns
- Integrate the pre-filter into `labelFormula` with the `structural_prefilter` decision method tag
- Regenerate the c6 dataset and verify speedup and label accuracy

**Non-Goals**:
- Modifying the `DecisionResult` type (use two-phase approach in `labelFormula` instead)
- Pre-filtering box-general-temporal patterns (`box(U(X,Y))` where X is not bot) -- these include invalid formulas
- Constructing formal `DerivationTree` proof terms for pre-filtered formulas
- Modifying `decideAuto` (uses `soundFuel`, not called by dataset pipeline)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Pre-filter labels an invalid formula as valid (soundness bug) | H | L | Conservative `isUnsatBotTemporal` only returns true for provably-false sub-formulas; double-box matches exact sub-patterns only; negative test cases in verification |
| `LabeledFormula` construction in pre-filter path missing required fields | M | M | Mirror exact field set from existing `.valid` and `.timeout` paths in `labelFormula` |
| Formula `BEq` instance behaves unexpectedly for double-box-identity pattern | M | L | `DecidableEq Formula` is derived; test `box(box(p)) -> p` equality check explicitly |
| C6 regeneration reveals new timeout patterns not in research data | L | L | Compare old vs new datasets record-by-record; investigate any discrepancies |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 1, 2 |
| 3 | 4 | 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Simplify `decideAutoAdaptive` to Single Tier [NOT STARTED]

**Goal**: Replace the three-tier adaptive fuel strategy with a single fuel=500 call, removing the `go` helper and tier list.

**Tasks**:
- [ ] Modify `decideAutoAdaptive` in `DecisionProcedure.lean` (lines 187-202):
  - Remove the `where go` helper function and the `tiers` list
  - Replace with direct `decide phi depth 500 fc` call
  - Return `("adaptive_500", result)` on success, `("adaptive_timeout", .timeout)` on timeout
- [ ] Update the doc comment (lines 174-186) to reflect single-tier strategy and reference task 264 findings
- [ ] Run `lake build Bimodal.Metalogic.Decidability.DecisionProcedure` to verify compilation

**Timing**: 30 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Simplify `decideAutoAdaptive` function

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.DecisionProcedure` succeeds
- No sorry introduced
- Function signature `DecisionResult phi x String` unchanged

---

### Phase 2: Add Structural Pre-Filter to DatasetGenerator.lean [NOT STARTED]

**Goal**: Implement `isUnsatBotTemporal` and `structuralPrefilter` functions, then integrate into `labelFormula` as a pre-filter check before `decideAutoAdaptive`.

**Tasks**:
- [ ] Add `isUnsatBotTemporal : Formula -> Bool` function before `labelFormula`:
  - `.untl .bot _` => true (U(bot,X) always false)
  - `.snce .bot _` => true (S(bot,X) always false)
  - `.box a` => recurse (box(false) = false)
  - All else => false
- [ ] Add `structuralPrefilter : Formula -> Option Bool` function:
  - `.imp antecedent _` => if `isUnsatBotTemporal antecedent` then `some true` (vacuous implication)
  - `.imp (.box (.box .bot)) _` => `some true` (unsatisfiable antecedent)
  - `.imp (.box (.box inner)) consequent` => if `inner == consequent` then `some true` (double-T)
  - `.imp (.box inner) (.imp _ rhs)` => if `inner == rhs` then `some true` (T + prop_s)
  - `.box inner` => recurse into `structuralPrefilter inner` (necessitation of valid = valid)
  - All else => `none`
- [ ] Modify `labelFormula` (line 399) to check `structuralPrefilter phi` before calling `decideAutoAdaptive`:
  - On `some true`: construct `LabeledFormula` with `label := .valid`, `proofTrace := none`, `countermodel := none`, `decisionMethod := "structural_prefilter"`, `proofReconstructionMethod := some "structural_prefilter"`, `ruleProfile := none`, and compute `metrics` with 0ms elapsed and `interestingness` with no proof data
  - On `none`: fall through to existing `decideAutoAdaptive` path (unchanged)
- [ ] Ensure the pre-filter LabeledFormula has all required fields matching the existing valid/invalid/timeout constructors
- [ ] Run `lake build Bimodal.Automation.DatasetGenerator` to verify compilation

**Timing**: 1.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Add pre-filter functions and integrate into `labelFormula`

**Verification**:
- `lake build Bimodal.Automation.DatasetGenerator` succeeds
- No sorry introduced
- `structuralPrefilter` returns `some true` for bot-temporal, double-box-bot, double-box-identity, and box-prop patterns
- `structuralPrefilter` returns `none` for box-general-temporal and consequent-side bot-temporal

---

### Phase 3: Full Build and Unit Verification [NOT STARTED]

**Goal**: Verify the full project builds and the pre-filter produces correct results for known test cases.

**Tasks**:
- [ ] Run `lake build` for full project build verification
- [ ] Add `#eval` tests in DatasetGenerator.lean (or a scratch file) to verify pre-filter on concrete formulas:
  - Positive: `U(bot,p) -> q`, `S(bot,r) -> bot`, `box(U(bot,p)) -> q`, `box(box(bot)) -> p`, `box(box(p)) -> p`, `box(p) -> (q -> p)`, `box(U(bot,p) -> q)` (box-descent)
  - Negative: `box(U(p,q)) -> bot` (non-bot event), `p -> U(bot,q)` (consequent-side bot-temporal), `box(box(p)) -> q` (p != q, not double-T)
- [ ] Remove `#eval` tests after verification (or gate behind `-- #eval` comments)
- [ ] Verify no regressions in existing functionality

**Timing**: 30 minutes

**Depends on**: 1, 2

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Temporary `#eval` tests (removed after verification)

**Verification**:
- `lake build` succeeds with zero errors
- All positive pre-filter tests return `some true`
- All negative pre-filter tests return `none`
- No sorry count increase

---

### Phase 4: Regenerate C6 Dataset and Validate [NOT STARTED]

**Goal**: Regenerate the c6 dataset with the new pipeline and verify the expected label distribution and speedup.

**Tasks**:
- [ ] Run c6 dataset generation:
  ```bash
  lake exe dataset_generator -- --max-complexity 6 --output data/bmlogic-c6.jsonl --mode exhaustive
  ```
- [ ] Verify expected results against research predictions:
  - Total records: 5,931 (unchanged)
  - Valid count: ~596 (445 original + 151 pre-filtered)
  - Invalid count: 5,239 (unchanged)
  - Timeout count: ~96 (down from 247)
  - New decision method `structural_prefilter` appears for ~151 formulas
  - Wall-clock time: under 5 minutes (down from ~18 hours)
- [ ] Spot-check a sample of pre-filtered formulas to confirm they are genuinely valid
- [ ] Verify no formula that was previously valid/invalid changed label (regression check)

**Timing**: 30 minutes

**Depends on**: 3

**Files to modify**:
- `data/bmlogic-c6.jsonl` - Regenerated dataset (output only)

**Verification**:
- Dataset generation completes in under 5 minutes
- Label distribution matches predictions within tolerance
- No previously-valid or previously-invalid formula changed label
- `structural_prefilter` decision method tag appears in output

## Testing & Validation

- [ ] `lake build` succeeds with zero errors and no new sorries
- [ ] `decideAutoAdaptive` signature unchanged (`DecisionResult phi x String`)
- [ ] Pre-filter positive cases: bot-temporal (top-level and box-wrapped), double-box-bot, double-box-identity, box-prop, box-descent
- [ ] Pre-filter negative cases: non-bot-event temporal, consequent-side bot-temporal, non-identity double-box
- [ ] C6 dataset: ~151 timeouts converted to `structural_prefilter` valid, ~96 remain as timeouts
- [ ] C6 generation runtime: under 5 minutes (down from ~18 hours)
- [ ] No regression in previously-valid or previously-invalid formula labels

## Artifacts & Outputs

- `specs/265_single_tier_fuel_and_timeout_prefilter/plans/01_implementation-plan.md` (this file)
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` (modified: single-tier)
- `Theories/Bimodal/Automation/DatasetGenerator.lean` (modified: pre-filter + labelFormula integration)
- `data/bmlogic-c6.jsonl` (regenerated dataset)

## Rollback/Contingency

If the pre-filter introduces soundness issues (labels invalid formulas as valid):
1. Revert `DatasetGenerator.lean` pre-filter changes, keeping the single-tier simplification (which is independently safe)
2. Investigate which pre-filter pattern matched incorrectly
3. Tighten the pattern matching to exclude the problematic case
4. Re-run c6 generation with the corrected pre-filter

If the single-tier simplification causes unexpected regressions:
1. Revert `decideAutoAdaptive` to the three-tier version
2. Re-examine the task 264 data for edge cases not covered in the analysis
