# Implementation Plan: Task #238

- **Task**: 238 - Frame-class-aware tableau expansion
- **Status**: [NOT STARTED]
- **Effort**: 8 hours
- **Dependencies**: None (tasks 233-235 completed and archived)
- **Research Inputs**: specs/238_frame_class_tableau_gating/reports/01_frame-class-gating.md
- **Artifacts**: plans/01_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Thread a `FrameClass` parameter through the tableau decision pipeline (`checkAxiomNeg`, `findClosure`, `expandBranchWithFuel`, `buildTableau`, `decide`) and gate axiom-based closure by `ax.minFrameClass <= fc`. This fixes a critical correctness bug where `checkAxiomNeg` accepts ALL axiom witnesses -- including Dense-only and Discrete-only axioms -- regardless of the target frame class. After the parameter threading fix (Phase 1), add frame-class-specific tableau rules for Dense and Discrete logics (Phases 2-3), then update correctness infrastructure and downstream consumers (Phase 4). All parameters default to `.Base` for backward compatibility.

### Research Integration

Key findings from the research report:
- `checkAxiomNeg` (Closure.lean:96) calls `matchAxiom` without filtering by frame class -- this is a correctness bug for frame-class-specific decision
- `FrameClass` partial order, `minFrameClass`, and `Axiom` infrastructure are well-established (Axioms.lean, Derivation.lean)
- 6 primary files need modification: Closure.lean (395 lines), Saturation.lean (320 lines), DecisionProcedure.lean (268 lines), Tableau.lean (793 lines), ProofExtraction.lean (221 lines), CountermodelExtraction.lean (181 lines)
- 4 downstream consumers in Automation/: DatasetGenerator.lean, EnrichedCountermodel.lean, FormulaMutator.lean, BenchmarkAnchors.lean
- Recommended approach: parameter threading first (correctness fix), then frame-class-specific rules

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix the correctness bug in `checkAxiomNeg` by gating axiom closure with `ax.minFrameClass <= fc`
- Thread `fc : FrameClass` parameter through the entire tableau pipeline with `fc := .Base` defaults
- Add Dense-specific tableau rules (density rule, dense indicator closure)
- Add Discrete-specific tableau rules (Prior-UZ/SZ, Z1)
- Gate new rule applicability by `fc` in `findApplicableRule` and `allRules`
- Update all downstream consumers (ProofExtraction, CountermodelExtraction, DatasetGenerator, etc.)
- Maintain backward compatibility: all existing call sites compile unchanged

**Non-Goals**:
- Full completeness proofs for frame-class-specific tableaux (deferred to task 164)
- Semantic FMP for Dense/Discrete (task 165)
- Comprehensive termination analysis for new rules (task 237 scope)
- Adding the Complete frame class (task 169 scope)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Default parameter changes break existing call sites | H | L | All new params default to `.Base`, preserving existing behavior |
| Density rule creates non-terminating expansion (intermediate points) | M | M | Limit density rule to one application per G-formula per branch; rely on fuel for termination |
| Z1 rule is structurally complex (backward induction) | M | M | Implement as a conditional closure rule rather than full decomposition |
| `OpenBranch` proof term `notClosed : findClosure branch = none` breaks with new signature | H | H | Thread `fc` through `OpenBranch` and `ClosedBranch` types; update `Saturation.lean` accordingly |
| Downstream consumers (DatasetGenerator, EnrichedCountermodel) need coordinated updates | M | L | Update in Phase 4 as a sweep; all have simple call sites |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 1, 2, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Thread FrameClass parameter and gate checkAxiomNeg [COMPLETED]

**Goal**: Fix the critical correctness bug by adding `fc : FrameClass` parameter throughout the tableau pipeline, gating axiom closure by `ax.minFrameClass <= fc`, and preserving backward compatibility via default parameters.

**Tasks**:
- [x] Add `fc : FrameClass := .Base` parameter to `checkAxiomNeg` in Closure.lean; add guard `witness.minFrameClass <= fc` before returning `some (.axiomNeg ...)` (line 96-107)
- [x] Add `fc : FrameClass := .Base` parameter to `findClosure`, `isClosed`, `isOpen`, `classifyBranch` in Closure.lean; forward `fc` to `checkAxiomNeg`
- [x] Update `OpenBranch` structure: change `notClosed : findClosure branch = none` to `notClosed : findClosure branch fc = none` (may need to make `fc` a field or parameter of the structure)
- [ ] Add `fc : FrameClass := .Base` parameter to `expandOnce`, `findApplicableRule`, `findUnexpanded`, `isExpanded` in Tableau.lean; forward through call chain *(deviation: deferred to Phase 2/3 -- these functions do not need fc for gating axiomNeg; fc will be added when frame-class-specific rules are introduced)*
- [x] Add `fc : FrameClass := .Base` parameter to `expandBranchWithFuel`, `expandBranchesWithFuel`, `buildTableau`, `buildTableauAuto`, `recommendedFuel` in Saturation.lean; forward `fc` to `findClosure` and `expandOnce` *(deviation: altered -- recommendedFuel not parameterized since it only depends on formula complexity, not frame class)*
- [x] Add `fc : FrameClass := .Base` parameter to `decide`, `decideAuto`, `decideOptimized`, `decideBatch`, `isValid`, `isSatisfiable` in DecisionProcedure.lean; forward to `buildTableau` and `tryAxiomProof`
- [x] Add `fc : FrameClass := .Base` parameter to `tryAxiomProof`, `proofFromAxiom`, `extractFromClosureReason`, `extractProof`, `findProofCombined` in ProofExtraction.lean; gate axiom proofs by `ax.minFrameClass <= fc` *(deviation: altered -- ProofExtraction functions kept at Base level since DecisionResult returns Base proofs; fc parameter added to extractProof and findProofCombined for forward-compatibility but proof extraction stays at FrameClass.Base)*
- [x] Add `fc : FrameClass := .Base` to `extractCountermodelSimple`, `extractCountermodelFromTableau` in CountermodelExtraction.lean *(deviation: altered -- extractCountermodelSimple not parameterized since it only extracts atoms from branch, independent of fc; fc added to extractCountermodelFromTableau, findCountermodel, branchTruthLemma)*
- [x] Update `decide` function (DecisionProcedure.lean:120-157): change the hardcoded `ax.minFrameClass <= FrameClass.Base` check at line 140 to `ax.minFrameClass <= fc` *(deviation: altered -- kept at FrameClass.Base since DecisionResult type returns Base proofs; the correctness fix is in checkAxiomNeg gating which uses fc)*
- [x] Update Correctness.lean: thread `fc` through `decision_trichotomy` and any other theorems that reference `decide`
- [x] Update test section at bottom of Saturation.lean (lines 255-312): all `buildTableauAuto` calls compile unchanged due to default parameter
- [x] Run `lake build` to verify zero errors

**Timing**: 2.5 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Closure.lean` - Add `fc` to `checkAxiomNeg`, `findClosure`, `isClosed`, `isOpen`, `classifyBranch`, `OpenBranch`
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Add `fc` to `expandOnce`, `findApplicableRule`, `findUnexpanded`, `isExpanded`
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add `fc` to `expandBranchWithFuel`, `expandBranchesWithFuel`, `buildTableau`, `buildTableauAuto`
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` - Add `fc` to `decide`, `decideAuto`, `decideOptimized`, `decideBatch`, `isValid`, `isSatisfiable`
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` - Add `fc` to `tryAxiomProof`, `proofFromAxiom`, `extractFromClosureReason`, `extractProof`, `findProofCombined`
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` - Add `fc` to extraction functions
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Thread `fc` through theorems

**Verification**:
- `lake build` passes with zero errors
- All existing test formulas in Saturation.lean still produce same results (default `.Base`)
- `checkAxiomNeg` with `fc := .Base` rejects Dense/Discrete-only axioms (add `#eval` test)

---

### Phase 2: Dense-specific tableau rules [COMPLETED]

**Goal**: Add tableau rules that exploit the Dense frame class axioms: a density rule for intermediate-point insertion and closure via the dense indicator axiom `neg U(top, bot)`.

**Tasks**:
- [x] Add `TableauRule` constructors to the `inductive TableauRule` enum (Tableau.lean:67-116):
  - `denseIndicatorClosure` -- close branch when `T(U(top, bot))` appears with `fc >= .Dense` (since `neg U(top, bot)` is a Dense axiom)
  - `densityRule` -- when `T(G(phi))` and a future witness time exists on the branch, introduce intermediate time with `T(phi)` (captures density: between any two points there is another)
- [x] Add `isApplicable` cases for both new rules in Tableau.lean:247+ gated by `fc : FrameClass` parameter (only applicable when `.Dense <= fc`)
- [x] Add `applyRule` cases in Tableau.lean:288+ for both new rules:
  - `denseIndicatorClosure`: return `.linear []` (closure, branch will be caught by `checkAxiomNeg` after gating, or directly close here)
  - `densityRule`: return `.persistent [witness :: gProps]` adding intermediate time point with the appropriate signed formulas *(deviation: altered -- used persistent instead of extended to keep T(G(phi)) on branch for re-propagation)*
- [x] Create `allRulesForFC (fc : FrameClass) : List TableauRule` that includes Dense rules only when `.Dense <= fc`; update `findApplicableRule` to use this instead of the fixed `allRules` list
- [ ] Add Dense-specific `#eval` tests to Saturation.lean verifying: *(deviation: deferred to Phase 4 -- integration tests consolidated)*
  - `buildTableau (density_axiom p) (fc := .Dense)` closes (valid on Dense)
  - `buildTableau (dense_indicator) (fc := .Dense)` closes (valid on Dense)
  - `buildTableau (dense_indicator) (fc := .Base)` does NOT close (not valid on Base)
- [x] Run `lake build` to verify zero errors

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Add `denseIndicatorClosure`, `densityRule` constructors; `isApplicable` and `applyRule` cases; refactor `allRules` to `allRulesForFC`
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add Dense test formulas in test section

**Verification**:
- `lake build` passes with zero errors
- Dense axiom instances close under `fc := .Dense` but not under `fc := .Base`
- The `allRulesForFC .Base` returns the same rules as the original `allRules`

---

### Phase 3: Discrete-specific tableau rules [COMPLETED]

**Goal**: Add tableau rules that exploit the Discrete frame class axioms: Prior-UZ/SZ decomposition rules and the Z1 backward induction rule.

**Tasks**:
- [x] Add `TableauRule` constructors to the `inductive TableauRule` enum (Tableau.lean):
  - `priorUZ` -- when `T(F(phi))` is on the branch with `.Discrete <= fc`, add `T(U(phi, neg phi))` (nearest future phi-point reachable by Until)
  - `priorSZ` -- when `T(P(phi))` is on the branch with `.Discrete <= fc`, add `T(S(phi, neg phi))` (nearest past phi-point reachable by Since)
  - `z1Rule` -- when `T(G(G(phi) -> phi))` and `T(F(G(phi)))` are both on the branch with `.Discrete <= fc`, add `T(G(phi))` (IsSuccArchimedean backward induction)
- [x] Add `isApplicable` cases for all three rules, gated by `.Discrete <= fc`
- [x] Add `applyRule` cases:
  - `priorUZ`: match `T(F(phi))`, produce `.persistent [T(U(phi, neg phi))]` at same label *(deviation: altered -- used persistent to keep source formula)*
  - `priorSZ`: match `T(P(phi))`, produce `.persistent [T(S(phi, neg phi))]` at same label *(deviation: altered -- used persistent to keep source formula)*
  - `z1Rule`: search branch for matching pair `T(G(G(phi) -> phi))` and `T(F(G(phi)))`, produce `.persistent [T(G(phi))]` at same label *(deviation: altered -- used persistent to keep source formula)*
- [x] Update `allRulesForFC` to include Discrete rules when `.Discrete <= fc`
- [ ] Add Discrete-specific `#eval` tests to Saturation.lean verifying: *(deviation: deferred to Phase 4 -- integration tests consolidated)*
  - `buildTableau (prior_UZ_axiom p) (fc := .Discrete)` closes (valid on Discrete)
  - `buildTableau (z1_axiom p) (fc := .Discrete)` closes (valid on Discrete)
  - `buildTableau (prior_UZ_axiom p) (fc := .Base)` does NOT close (not valid on Base)
  - `buildTableau (prior_UZ_axiom p) (fc := .Dense)` does NOT close (Dense and Discrete are incomparable)
- [x] Run `lake build` to verify zero errors

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` - Add `priorUZ`, `priorSZ`, `z1Rule` constructors; `isApplicable` and `applyRule` cases; update `allRulesForFC`
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Add Discrete test formulas in test section

**Verification**:
- `lake build` passes with zero errors
- Discrete axiom instances close under `fc := .Discrete` but not under `fc := .Base` or `fc := .Dense`
- The Z1 rule correctly identifies the two-formula trigger pattern on the branch

---

### Phase 4: Correctness theorems and integration testing [NOT STARTED]

**Goal**: Update downstream consumers (DatasetGenerator, EnrichedCountermodel, FormulaMutator), update Correctness.lean theorems for frame-class parameterization, and run comprehensive integration tests.

**Tasks**:
- [ ] Update `DatasetGenerator.lean`: add `fc : FrameClass := .Base` to `labelFormula` and related functions; update `decideAuto`/`decideOptimized` call sites to forward `fc`
- [ ] Update `EnrichedCountermodel.lean`: add `fc` parameter to `buildEnrichedCountermodel` and forward to `buildTableau`
- [ ] Update `FormulaMutator.lean`: add `fc` parameter to `classifyMutation` and forward to `decideAuto`/`decideOptimized`
- [ ] Update `Correctness.lean`: ensure `decision_trichotomy` and related theorems work with the parameterized `decide`
- [ ] Add comprehensive integration tests in Saturation.lean test section:
  - All 42 axiom constructors: each axiom instance should close under `fc >= ax.minFrameClass` and NOT close under incompatible frame classes
  - Cross-class validation: Dense axiom does not close under `.Discrete`; Discrete axiom does not close under `.Dense`
  - Base axioms close under all frame classes (monotonicity)
- [ ] Run full `lake build` to verify zero errors across entire project
- [ ] Verify `#print axioms` on key definitions shows no new axioms introduced

**Timing**: 1.5 hours

**Depends on**: 1, 2, 3

**Files to modify**:
- `Theories/Bimodal/Automation/DatasetGenerator.lean` - Thread `fc` through labeling functions
- `Theories/Bimodal/Automation/EnrichedCountermodel.lean` - Thread `fc` through countermodel building
- `Theories/Bimodal/Automation/FormulaMutator.lean` - Thread `fc` through mutation classification
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` - Update theorems for `fc` parameter
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` - Comprehensive integration tests

**Verification**:
- Full `lake build` passes with zero errors
- No new axioms (`#print axioms` clean on `decide`, `buildTableau`, `checkAxiomNeg`)
- Integration tests demonstrate correct frame-class gating across Base, Dense, and Discrete

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after each phase
- [ ] `checkAxiomNeg b .Base` rejects Dense-only and Discrete-only axioms
- [ ] `checkAxiomNeg b .Dense` accepts Dense axioms but rejects Discrete-only axioms
- [ ] `checkAxiomNeg b .Discrete` accepts Discrete axioms but rejects Dense-only axioms
- [ ] `buildTableau (density phi) (fc := .Dense)` closes; `buildTableau (density phi) (fc := .Base)` does not
- [ ] `buildTableau (prior_UZ phi) (fc := .Discrete)` closes; `buildTableau (prior_UZ phi) (fc := .Dense)` does not
- [ ] All existing tests pass unchanged (backward compatibility via `.Base` defaults)
- [ ] `#print axioms decide` shows no new axioms
- [ ] Downstream consumers (DatasetGenerator, FormulaMutator, EnrichedCountermodel) compile and function correctly

## Artifacts & Outputs

- `specs/238_frame_class_tableau_gating/plans/01_implementation-plan.md` (this file)
- `specs/238_frame_class_tableau_gating/summaries/01_implementation-summary.md` (after implementation)
- Modified files: Closure.lean, Tableau.lean, Saturation.lean, DecisionProcedure.lean, ProofExtraction.lean, CountermodelExtraction.lean, Correctness.lean, DatasetGenerator.lean, EnrichedCountermodel.lean, FormulaMutator.lean

## Rollback/Contingency

All changes use default parameters (`fc := .Base`), so existing call sites are unaffected. If the implementation fails:
1. Revert all changes to the 10 modified files via `git checkout -- Theories/Bimodal/Metalogic/Decidability/ Theories/Bimodal/Automation/`
2. The `FrameClass` type and `minFrameClass` infrastructure remain untouched (no rollback needed for those)
3. If specific rules (density, Z1) cause termination issues, they can be removed from `allRulesForFC` independently while keeping the parameter threading fix
