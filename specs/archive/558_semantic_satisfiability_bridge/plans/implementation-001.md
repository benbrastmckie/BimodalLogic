# Implementation Plan: Task #558

- **Task**: 558 - Semantic Satisfiability Bridge
- **Status**: [NOT STARTED]
- **Effort**: 2 hours
- **Priority**: High
- **Dependencies**: Task 557 (completed)
- **Research Inputs**: specs/558_semantic_satisfiability_bridge/reports/research-003.md
- **Artifacts**: plans/implementation-001.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Overview

This task implements two critical theorems in `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` that bridge the canonical world representation to semantic satisfiability. The implementation proves `subformulaList_finite` using structural induction with arithmetic bounds, and `consistent_implies_satisfiable` via contrapositive proof leveraging the recently proven lemmas from Task 557.

### Research Integration

Research-003.md (synthesis report) confirms the proof strategies and identifies all required infrastructure. Key findings:
- `subformulaList_finite`: Structural induction with omega tactic for arithmetic (30-45 min)
- `consistent_implies_satisfiable`: Contrapositive proof via `valid_implies_derivable` (30-60 min)
- Helper lemma `complexity_pos` needed for arithmetic bounds
- All dependencies from Task 557 now proven (mcs_contains_or_neg, mcs_modus_ponens, extract_neg_derivation)

## Goals & Non-Goals

**Goals**:
- Prove `complexity_pos` helper lemma establishing all formulas have complexity >= 1
- Prove `subformulaList_finite` showing subformula lists have bounded length
- Prove `consistent_implies_satisfiable` bridging consistency to semantic satisfiability
- Maintain compatibility with existing canonical model infrastructure

**Non-Goals**:
- Constructing explicit TaskModel from CanonicalWorldState (alternative approach)
- Proving the axiom `representation_theorem_backward_empty` (accepted dependency)
- Modifying formula complexity definitions or subformula functions

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Arithmetic bound complexity in imp case requires additional lemmas | Medium | Medium | Pre-prove intermediate arithmetic lemma if omega struggles with compound bound |
| DerivationTree.weakening signature mismatch | Low | Low | Verify exact signature in ContextProvability.lean before use |
| Axiom dependency on representation_theorem_backward_empty | Low | Low | Acceptable for now; represents valid theorem to be proven later |

## Implementation Phases

### Phase 1: Prove complexity_pos helper lemma [NOT STARTED]

**Goal**: Establish that all formulas have complexity >= 1 to support arithmetic bounds in subformulaList_finite.

**Tasks**:
- [ ] Add `complexity_pos` lemma after the `complexity` definition
- [ ] Structure proof: `cases phi <;> simp [Formula.complexity] <;> omega`
- [ ] Verify lemma compiles with no errors

**Timing**: 5 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Add lemma around line 70-80

**Verification**:
- Lean compiles without errors
- `complexity_pos` accessible to subsequent proofs

---

### Phase 2: Prove subformulaList_finite [NOT STARTED]

**Goal**: Prove that subformula lists have length bounded by `2^(complexity phi) + 1` using structural induction.

**Tasks**:
- [ ] Replace sorry at line 81 with induction structure: `induction phi with`
- [ ] Handle base cases (atom, bot): use `simp [subformulaList, complexity] <;> omega`
- [ ] Handle imp case: apply IH to psi and chi, setup arithmetic with `complexity_pos`, use omega for bound
- [ ] Handle modal/temporal cases (box, all_past, all_future): apply IH and omega
- [ ] If omega struggles with imp case, add intermediate arithmetic lemma

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Replace sorry at line 81

**Verification**:
- Lean compiles without errors
- All cases covered (atom, bot, imp, box, all_past, all_future)
- Arithmetic bounds proven via omega

---

### Phase 3: Prove consistent_implies_satisfiable [NOT STARTED]

**Goal**: Bridge consistency to semantic satisfiability using contrapositive proof via valid_implies_derivable.

**Tasks**:
- [ ] Replace sorry at line 162 with `by_contra h_not_sat`
- [ ] Show `neg phi` is valid from unsatisfiability (universal quantification over models)
- [ ] Apply `valid_implies_derivable` from ContextProvability.lean to get derivation of `neg phi`
- [ ] Use `DerivationTree.weakening` to get `[phi] |- neg phi`
- [ ] Build `[phi] |- phi` using `DerivationTree.assumption`
- [ ] Apply `derives_bot_from_phi_neg_phi` to derive bot
- [ ] Contradiction with `Consistent [phi]` hypothesis

**Timing**: 30-60 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` - Replace sorry at line 162

**Verification**:
- Lean compiles without errors
- Proof uses contrapositive structure (by_contra)
- Dependencies on valid_implies_derivable, DerivationTree lemmas, derives_bot_from_phi_neg_phi all resolve
- No additional axioms introduced beyond accepted representation_theorem_backward_empty

---

## Testing & Validation

- [ ] Run `lake build Theories.Bimodal.Metalogic_v2.Representation.FiniteModelProperty` to verify compilation
- [ ] Verify no new sorries introduced
- [ ] Check that downstream files (RepresentationTheorem.lean, StrongCompleteness.lean) still compile
- [ ] Confirm `complexity_pos`, `subformulaList_finite`, and `consistent_implies_satisfiable` are now proven (no sorries)

## Artifacts & Outputs

- Modified: `Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean` (3 theorem proofs)
- Implementation summary: `specs/558_semantic_satisfiability_bridge/summaries/implementation-summary-{DATE}.md`

## Rollback/Contingency

If implementation fails:
1. Revert changes to FiniteModelProperty.lean using git
2. Restore sorries at lines 81 and 162
3. Document specific blocker (e.g., arithmetic lemma needed, signature mismatch)
4. Update task status to [BLOCKED] with reason
5. Create follow-up task for blocker resolution if needed
