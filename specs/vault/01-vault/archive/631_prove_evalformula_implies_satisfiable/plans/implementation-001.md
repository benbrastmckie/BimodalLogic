# Implementation Plan: Task #631

- **Task**: 631 - Prove evalFormula_implies_satisfiable bridging lemma
- **Status**: [COMPLETED]
- **Effort**: 4 hours
- **Priority**: Medium
- **Dependencies**: Task 630 (BranchTaskModel extraction - completed)
- **Research Inputs**: specs/631_prove_evalformula_implies_satisfiable/reports/research-001.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

Prove the semantic bridge lemma `evalFormula_implies_sat` that connects tableau-based evaluation to full task frame semantics. The key insight from research is that this proof is MUCH SIMPLER than expected due to saturation: only F(atom p) and F(bot) can appear in saturated branches since complex formulas would have been expanded. The atom case uses existing `atom_false_if_neg_in_open_branch`, and all complex formula cases are vacuous via `saturation_contradiction`.

### Research Integration

Key findings integrated from research-001.md:
- Saturation simplifies everything: F(imp), F(box), F(all_future), F(all_past) cannot exist in saturated branches
- All required `isExpanded_neg_*_false` lemmas already proven in CountermodelExtraction.lean
- `saturation_contradiction` helper already available for vacuous cases
- `atom_false_if_neg_in_open_branch` from BranchTaskModel.lean provides atom case
- The constant history from `extractBranchWorldHistory` has `domain = True` everywhere

## Goals & Non-Goals

**Goals**:
- Prove `evalFormula_implies_sat` theorem connecting F(phi) in saturated branch to not-satisfiable
- Connect the proof to existing BranchTaskModel and CountermodelExtraction infrastructure
- Ensure the theorem integrates with the decidability procedure (Task 490)

**Non-Goals**:
- Proving the reverse direction (true implies satisfiable) - not needed for completeness
- Modifying existing infrastructure - all required lemmas exist
- Proving bidirectional correspondence for all formula cases

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Atom case type mismatch | Medium | Low | Use existing `atom_false_if_neg_in_open_branch` signature exactly |
| Universe level issues | Medium | Low | Already resolved in BranchTaskModel per research |
| Missing imports | Low | Low | Check imports match BranchTaskModel.lean pattern |
| truth_at unfolding issues | Low | Medium | Use `simp only [truth_at]` with explicit lemmas |

## Implementation Phases

### Phase 1: Setup and Imports [COMPLETED]

**Goal**: Create the theorem file structure with correct imports and verify existing infrastructure.

**Tasks**:
- [ ] Add theorem stub to CountermodelExtraction.lean (where branchTruthLemma lives)
- [ ] Verify `saturation_contradiction` is accessible (private - may need to make public or inline)
- [ ] Verify all `isExpanded_neg_*_false` lemmas are accessible
- [ ] Verify `atom_false_if_neg_in_open_branch` is imported from BranchTaskModel

**Timing**: 30 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean` - main changes

**Verification**:
- `lake build` succeeds with theorem stub containing `sorry`

---

### Phase 2: Atom Case [COMPLETED]

**Goal**: Prove the atom case using `atom_false_if_neg_in_open_branch`.

**Tasks**:
- [ ] Implement atom case: F(atom p) in b implies not truth_at M tau 0 (atom p)
- [ ] Handle domain membership: constant history has `domain = True` everywhere
- [ ] Connect valuation false to truth_at false using Exists elimination

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Verification**:
- Atom case compiles without `sorry`
- `lean_goal` shows no remaining goals for atom case

---

### Phase 3: Bot Case [COMPLETED]

**Goal**: Prove the trivial bot case.

**Tasks**:
- [ ] Implement bot case: truth_at bot = False, so not False is trivial
- [ ] Use `simp only [truth_at, not_false_eq_true]` or equivalent

**Timing**: 15 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Verification**:
- Bot case compiles without `sorry`

---

### Phase 4: Complex Formula Cases via Saturation [COMPLETED]

**Goal**: Prove all complex formula cases (imp, box, all_future, all_past) are vacuous.

**Tasks**:
- [ ] Implement imp case using `saturation_contradiction` + `isExpanded_neg_imp_false`
- [ ] Implement box case using `saturation_contradiction` + `isExpanded_neg_box_false`
- [ ] Implement all_future case using `saturation_contradiction` + `isExpanded_neg_all_future_false`
- [ ] Implement all_past case using `saturation_contradiction` + `isExpanded_neg_all_past_false`
- [ ] Address `saturation_contradiction` visibility (private -> public if needed)

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Verification**:
- All four complex cases compile without `sorry`
- Full theorem compiles with `lake build`

---

### Phase 5: Integration and Documentation [COMPLETED]

**Goal**: Finalize theorem, add documentation, verify integration with decidability.

**Tasks**:
- [ ] Add docstring explaining the semantic bridge role
- [ ] Verify theorem signature matches research recommendation
- [ ] Run `lake build` for full project verification
- [ ] Update any comments referencing this theorem

**Timing**: 45 minutes

**Files to modify**:
- `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`

**Verification**:
- `lake build` succeeds for entire project
- Theorem has proper documentation
- No remaining `sorry` statements in theorem

## Testing & Validation

- [ ] `lake build` succeeds with no errors
- [ ] Theorem `evalFormula_implies_sat` compiles without `sorry`
- [ ] All case branches of the proof are complete
- [ ] Theorem uses consistent naming with existing codebase conventions
- [ ] Documentation matches existing docstring style

## Artifacts & Outputs

- plans/implementation-001.md (this file)
- summaries/implementation-summary-YYYYMMDD.md (after completion)
- Modified: `Theories/Bimodal/Boneyard/Metalogic_v2/Decidability/CountermodelExtraction.lean`

## Rollback/Contingency

If implementation encounters unexpected issues:
1. Preserve original CountermodelExtraction.lean via git
2. If `saturation_contradiction` visibility is problematic, inline the proof locally
3. If type mismatches occur with BranchTaskModel, check universe levels match
4. If atom case fails, review `atom_false_if_neg_in_open_branch` signature carefully
