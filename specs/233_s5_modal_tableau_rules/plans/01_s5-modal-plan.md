# Implementation Plan: S5 Modal Tableau Rules (Multi-World Bookkeeping)

- **Task**: 233 - S5 modal tableau rules (multi-world bookkeeping)
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: Task 232 (labeled branch infrastructure -- completed)
- **Research Inputs**: specs/233_s5_modal_tableau_rules/reports/01_s5-modal-research.md
- **Artifacts**: plans/01_s5-modal-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Replace the four unsound identity-collapse modal rules in `Tableau.lean` (lines 256-271) with correct S5 tableau rules that use multi-world bookkeeping from task 232. The correct rules split into existential (F(box A), T(diamond A)) which introduce fresh witness worlds, and universal (T(box A), F(diamond A)) which propagate to all known worlds. This requires extending `applyRule` to accept branch context, adding a `RuleResult.persistent` constructor for universal formulas that must not be removed after expansion, implementing auto-propagation of universal formulas when new worlds are created, and updating `expandOnce` in Saturation.lean to handle the persistent result type.

### Research Integration

The research report (01_s5-modal-research.md) provides the complete design:
- Section 3: Rule classification (existential vs universal) and specifications
- Section 5.2: Option A (extend `applyRule` to take branch) recommended over Option B (separate modal function)
- Section 5.3: Helper function signatures for `Branch.knownWorlds`, `Branch.nextWorld`, `Branch.boxPosFormulas`, `Branch.diamondNegFormulas`
- Section 5.4: Revised `applyRule` pseudocode for all four modal cases
- Section 5.5: Saturation check -- `applyRule` returns `notApplicable` when all propagations are already present
- Section 6: `expandOnce` modifications for `persistent` result type
- Section 7.2: Change surface estimate (~130 lines across 3 files)
- Closure.lean confirmed as requiring NO changes

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

No ROADMAP.md consultation needed for this task.

## Goals & Non-Goals

**Goals**:
- Replace all four identity-collapse modal rules with correct S5 rules
- Implement existential rules (F(box), T(diamond)) with fresh witness world introduction
- Implement universal rules (T(box), F(diamond)) with propagation to all known worlds
- Add auto-propagation of universal formulas when existential rules create new worlds
- Maintain `lake build` passing after all changes
- Preserve sorry-free compilation status

**Non-Goals**:
- Temporal rule corrections (task 234)
- Until/Since rules (task 235)
- Termination proofs (task 237, deferred -- fuel suffices)
- Frame-class-specific rules (task 238)
- Countermodel extraction updates for multi-world (future work)
- Proof extraction updates (task 239)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Infinite loop from persistent universal formulas | H | M | `applyRule` returns `notApplicable` when all propagations present; fuel provides hard safety net |
| `isExpanded`/`findUnexpanded` signature change cascade | M | H | These are all internal to Decidability module; pass branch through all callers systematically |
| Downstream pattern match failures on new `RuleResult.persistent` | M | L | Only ProofExtraction.lean/CountermodelExtraction.lean reference expansion; grep shows no direct `RuleResult` pattern matches in downstream files |
| Build time increase from branch scanning in `knownWorlds` | L | L | Branches are small in practice; O(n) scan is acceptable |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Branch Helper Functions [COMPLETED]

**Goal**: Add world-tracking and universal-formula-collection helpers to `SignedFormula.lean`

**Tasks**:
- [x] Add `Branch.knownWorlds` function that collects all distinct `WorldIndex` values from branch formulas (after line 294 in `SignedFormula.lean`, in the `Branch` namespace)
- [x] Add `Branch.maxWorld` function that returns the maximum world index in the branch (or 0 if empty)
- [x] Add `Branch.nextWorld` function that returns `maxWorld + 1` as the fresh world index
- [x] Add `Branch.boxPosFormulas` function that filters branch for all `T(box A)` formulas (sign = .pos, formula matches `.box _`)
- [x] Add `Branch.diamondNegFormulas` function that filters branch for all `F(diamond A)` formulas (sign = .neg, formula matches `asDiamond?` pattern) *(deviation: altered -- inlined diamond pattern match `.imp (.box (.imp _ .bot)) .bot` instead of using `asDiamond?` which is defined in Tableau.lean, not available in SignedFormula.lean)*
- [x] Verify `lake build Bimodal.Metalogic.Decidability.SignedFormula` compiles

**Timing**: 1 hour

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` -- add ~30 lines of helper definitions in the `Branch` namespace (after line 294, before `Subformula Closure` section)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.SignedFormula` passes
- Each helper function has correct type signature and compiles without errors
- `Branch.nextWorld` returns 1 for a branch with only world 0 formulas

---

### Phase 2: Tableau.lean Rule Infrastructure [COMPLETED]

**Goal**: Add `RuleResult.persistent` constructor, change `applyRule` signature to accept branch, implement correct S5 modal rules, and update all callers

**Tasks**:
- [x] Add `RuleResult.persistent` constructor: `| persistent (formulas : List SignedFormula)` at line 118, after the `branching` constructor
- [x] Change `applyRule` signature (line 217) from `def applyRule (rule : TableauRule) (sf : SignedFormula) : RuleResult` to `def applyRule (rule : TableauRule) (sf : SignedFormula) (branch : Branch := []) : RuleResult`
- [x] Replace `boxPos` rule (lines 256-258): T(box A) @ w propagates T(A) @ w' for all w' in `branch.knownWorlds`; return `.persistent` if new formulas exist, `.notApplicable` if all already present; filter out formulas already in branch to avoid loops
- [x] Replace `boxNeg` rule (lines 259-261): F(box A) @ w introduces F(A) @ `branch.nextWorld` (fresh world); auto-propagate all `branch.boxPosFormulas` and `branch.diamondNegFormulas` to the fresh world; return `.linear` (consumable)
- [x] Replace `diamondPos` rule (lines 262-266): T(diamond A) @ w introduces T(A) @ `branch.nextWorld` (fresh world); auto-propagate all universal formulas to fresh world; return `.linear` (consumable)
- [x] Replace `diamondNeg` rule (lines 267-271): F(diamond A) @ w propagates F(A) @ w' for all w' in `branch.knownWorlds`; return `.persistent` if new formulas exist, `.notApplicable` if all already present
- [x] Update `findApplicableRule` (line 310) to pass branch: `def findApplicableRule (sf : SignedFormula) (branch : Branch := []) : Option (TableauRule × RuleResult)` -- pass `branch` to `applyRule`
- [x] Update `isExpanded` (line 321) to accept branch: `def isExpanded (sf : SignedFormula) (branch : Branch := []) : Bool` -- uses `findApplicableRule sf branch`
- [x] Update `findUnexpanded` (line 328) to pass branch to `isExpanded`: `def findUnexpanded (b : Branch) : Option SignedFormula` -- calls `isExpanded sf b` for each formula
- [x] Update `expandOnce` (line 349) to pass branch to `findApplicableRule` and handle `.persistent`: for `persistent`, add new formulas WITHOUT removing the source formula from branch
- [x] Update `countUnexpanded` (line 370) to pass branch: calls `isExpanded sf b`
- [x] Update `totalUnexpandedComplexity` (line 376) to pass branch: calls `isExpanded sf b`
- [x] Update docstrings on `TableauRule` modal constructors (lines 84-91) to reflect correct S5 semantics
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Tableau` compiles

**Timing**: 2.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` -- ~80 lines changed: `RuleResult` type, `applyRule` signature + 4 modal cases, `findApplicableRule`, `isExpanded`, `findUnexpanded`, `expandOnce`, `countUnexpanded`, `totalUnexpandedComplexity`

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Tableau` passes
- No `sorry` introduced
- `applyRule .boxPos (SignedFormula.pos (.box (.atom 0)) Label.initial) [SignedFormula.pos (.box (.atom 0)) Label.initial]` returns `.persistent [...]` with T(atom 0) at world 0
- `applyRule .boxNeg (SignedFormula.neg (.box (.atom 0)) Label.initial) [SignedFormula.neg (.box (.atom 0)) Label.initial]` returns `.linear [...]` with F(atom 0) at world 1

---

### Phase 3: Saturation.lean Expansion Update [COMPLETED]

**Goal**: Update `expandBranchWithFuel` and related functions to handle `RuleResult.persistent` and pass branch context

**Tasks**:
- [x] Update `expandBranchWithFuel` (line 92) to handle `persistent` result from `expandOnce`: when `expandOnce` returns `.extended` with a branch that came from a persistent expansion, the source formula is NOT removed (this is already handled by `expandOnce` in Tableau.lean, so Saturation.lean receives the correct branch) *(deviation: altered -- no changes needed to expandBranchWithFuel itself since expandOnce returns .extended for persistent results and the branch is already correct)*
- [x] Verify that fuel still decrements on persistent expansions (persistent expansions consume fuel even though the source formula is retained, preventing infinite loops)
- [x] Verify `isSaturated` (line 186) works correctly: a branch is saturated when `findUnexpanded` returns `none`, which happens when all universal formulas have been fully propagated (i.e., `applyRule` returns `notApplicable` for them)
- [x] Verify `expansionMeasure` (line 208) accounts for persistent formulas: since `isExpanded` now checks branch context, a fully-propagated T(box A) will be marked expanded
- [x] Verify `lake build Bimodal.Metalogic.Decidability.Saturation` compiles

**Timing**: 1 hour

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` -- ~10-15 lines: minor adjustments to ensure `expandBranchWithFuel` handles the persistent case correctly (most work is already done by `expandOnce` in Tableau.lean)

**Verification**:
- `lake build Bimodal.Metalogic.Decidability.Saturation` passes
- `expandBranchWithFuel` terminates on branches with universal modal formulas (fuel consumed per step)
- No infinite loops -- verify by running `buildTableauAuto` on `Formula.box (.atom 0)` and `.imp (.box (.atom 0)) (.atom 0)` (should close via reflexivity propagation)

---

### Phase 4: Full Build and Integration Verification [NOT STARTED]

**Goal**: Verify full project builds and modal tableau behavior is correct

**Tasks**:
- [ ] Run `lake build` to verify full project compilation (all downstream files: ProofExtraction.lean, CountermodelExtraction.lean, DecisionProcedure.lean, Correctness.lean)
- [ ] Fix any downstream compilation errors from signature changes (primarily `findUnexpanded` type changes if used in other files -- grep shows `CountermodelExtraction.lean:121` uses `findUnexpanded`)
- [ ] Verify `#check @findUnexpanded` and `#check @isExpanded` have correct types
- [ ] Verify no `sorry` introduced anywhere in the Decidability module
- [ ] Test basic S5 validity: `buildTableauAuto (.imp (.box (.atom 0)) (.atom 0))` should return `allClosed` (T-axiom, follows from reflexivity propagation)
- [ ] Test basic S5 invalidity: `buildTableauAuto (.imp (.atom 0) (.box (.atom 0)))` should return `hasOpen` (p does not imply box p)
- [ ] Test K axiom: `buildTableauAuto (.imp (.box (.imp (.atom 0) (.atom 1))) (.imp (.box (.atom 0)) (.box (.atom 1))))` should return `allClosed`

**Timing**: 1.5 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` -- may need minor update if `findUnexpanded` signature changed (line 121 uses it as a proof parameter)
- `Theories/Bimodal/Metalogic/Decidability/ProofExtraction.lean` -- unlikely changes needed, but verify compilation
- `Theories/Bimodal/Metalogic/Decidability/DecisionProcedure.lean` -- verify compilation
- `Theories/Bimodal/Metalogic/Decidability/Correctness.lean` -- verify compilation

**Verification**:
- `lake build` passes with zero errors
- `#print axioms buildTableauAuto` shows no `sorryAx`
- Modal validity tests pass (T-axiom, K-axiom valid; non-theorems invalid)
- No regressions in propositional or temporal rule behavior

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] No `sorry` in any Decidability module file
- [ ] T-axiom `box p -> p` recognized as valid (closed tableau)
- [ ] K-axiom `box (p -> q) -> (box p -> box q)` recognized as valid
- [ ] 5-axiom `diamond p -> box (diamond p)` recognized as valid (S5-specific)
- [ ] `p -> box p` correctly recognized as invalid (open branch)
- [ ] Propositional formulas still work correctly (no regression)

## Artifacts & Outputs

- `specs/233_s5_modal_tableau_rules/plans/01_s5-modal-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Decidability/SignedFormula.lean` (~30 new lines)
- Modified: `Theories/Bimodal/Metalogic/Decidability/Tableau.lean` (~80 lines changed)
- Modified: `Theories/Bimodal/Metalogic/Decidability/Saturation.lean` (~10-15 lines)
- Potentially modified: `Theories/Bimodal/Metalogic/Decidability/CountermodelExtraction.lean` (minor)

## Rollback/Contingency

All changes are within the `Theories/Bimodal/Metalogic/Decidability/` module. If implementation fails:
1. Revert `SignedFormula.lean`, `Tableau.lean`, `Saturation.lean` to their pre-task-233 state via `git checkout`
2. The identity-collapse placeholders are functional (unsound but compilable) as a fallback
3. No changes to Closure.lean, so closure detection remains correct regardless
