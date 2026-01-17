# Research Report: Task #558 (Synthesis)

**Task**: 558 - Semantic Satisfiability Bridge
**Date**: 2026-01-17
**Focus**: Synthesize research findings and confirm proof strategies
**Session**: sess_1768688539_8e1c7c
**Effort**: 2-3 hours
**Priority**: High
**Dependencies**: Task 557 (completed)
**Sources/Inputs**:
- Previous research: research-001.md, research-002.md
- Theories/Bimodal/Metalogic_v2/Representation/FiniteModelProperty.lean
- Theories/Bimodal/Metalogic_v2/Representation/CanonicalModel.lean (now complete)
- Theories/Bimodal/Metalogic_v2/Representation/ContextProvability.lean
- Mathlib model theory patterns
**Artifacts**: specs/558_semantic_satisfiability_bridge/reports/research-003.md
**Standards**: report-format.md, subagent-return.md

## Executive Summary

- Previous research (001, 002) provides thorough analysis of both target theorems
- Task 557 completion removes key blockers - `mcs_contains_or_neg` and `mcs_modus_ponens` now proven
- **Recommended strategy for `subformulaList_finite`**: Structural induction with omega tactic (30-45 min)
- **Recommended strategy for `consistent_implies_satisfiable`**: Contrapositive proof via `valid_implies_derivable` (30-60 min)
- The contrapositive approach is cleaner than explicit model construction and leverages existing infrastructure

## Context & Scope

### Synthesis of Prior Research

Research-001 identified:
- Type mismatch between `CanonicalWorldState` (set membership) and `formula_satisfiable` (semantic truth_at)
- Three approaches: (A) construct concrete model, (B) axiom bridge, (C) simplified Unit-based model

Research-002 identified:
- The contrapositive proof strategy for `consistent_implies_satisfiable`
- Specific arithmetic lemmas needed for `subformulaList_finite`
- Key helper lemma `complexity_pos`

### Post-Task-557 State

With Task 557 complete, the following are now proven:
1. `mcs_contains_or_neg` - MCS contains phi or neg phi
2. `mcs_modus_ponens` - MCS closed under modus ponens
3. `extract_neg_derivation` - Bridge from set inconsistency to derivation

These enable the contrapositive proof strategy.

## Findings

### Confirmed Strategy: subformulaList_finite

**Proof approach**: Structural induction with arithmetic bounds

**Key insight from Formula.complexity**:
```lean
def complexity : Formula -> Nat
  | atom _ => 1
  | bot => 1
  | imp phi psi => 1 + phi.complexity + psi.complexity
  | box phi => 1 + phi.complexity
  | all_past phi => 1 + phi.complexity
  | all_future phi => 1 + phi.complexity
```

Since `complexity >= 1` for all formulas, the bound `2^complexity + 1 >= 3` always holds.

**Helper lemma needed**:
```lean
lemma complexity_pos (phi : Formula) : 1 <= phi.complexity := by
  cases phi <;> simp [Formula.complexity] <;> omega
```

**Critical arithmetic**: For the `imp` case where we need:
```
1 + len(psi) + len(chi) < 2^(1 + c_psi + c_chi) + 1
```

Given IH bounds:
- `len(psi) < 2^c_psi + 1`
- `len(chi) < 2^c_chi + 1`

We have `1 + len(psi) + len(chi) < 3 + 2^c_psi + 2^c_chi`.

For `c_psi, c_chi >= 1`:
- `2^c_psi + 2^c_chi <= 2 * 2^max(c_psi, c_chi) <= 2^(1 + c_psi + c_chi)`
- So `3 + 2^c_psi + 2^c_chi < 2^(1 + c_psi + c_chi) + 1` when the exponent is large enough

The `omega` tactic should handle most of this with appropriate setup.

### Confirmed Strategy: consistent_implies_satisfiable

**Best approach**: Contrapositive proof (from research-002)

**Core argument**:
1. Assume `Consistent [phi]`
2. Assume `not formula_satisfiable phi`
3. Then `neg phi` is valid (true everywhere, since phi is nowhere true)
4. By `valid_implies_derivable`, we have `ContextDerivable [] (neg phi)`
5. By weakening, `[phi] |- neg phi`
6. Since `[phi] |- phi` (assumption), and `[phi] |- neg phi`
7. We get `[phi] |- bot` via `derives_bot_from_phi_neg_phi`
8. This contradicts `Consistent [phi]`

**Available infrastructure**:

| Lemma | Location | Status |
|-------|----------|--------|
| `valid_implies_derivable` | ContextProvability.lean | Uses axiom |
| `derives_bot_from_phi_neg_phi` | MaximalConsistent.lean | Complete |
| `DerivationTree.weakening` | ProofSystem | Complete |
| `DerivationTree.assumption` | ProofSystem | Complete |

**Implementation sketch**:
```lean
theorem consistent_implies_satisfiable (phi : Formula) (h_cons : Consistent [phi]) :
    formula_satisfiable phi := by
  by_contra h_not_sat
  -- Show neg phi is valid
  have h_neg_valid : valid (Formula.neg phi) := by
    intro D _ _ _ F M tau t
    simp only [Formula.neg, truth_at]
    intro h_phi
    apply h_not_sat
    exact ⟨D, _, _, _, F, M, tau, t, h_phi⟩
  -- Get derivation of neg phi
  have h_neg_deriv := valid_implies_derivable h_neg_valid
  obtain ⟨d_neg⟩ := h_neg_deriv
  -- Build contradiction
  have d_neg' := DerivationTree.weakening [] [phi] (Formula.neg phi) d_neg (by simp)
  have d_phi := DerivationTree.assumption [phi] phi (List.mem_singleton.mpr rfl)
  apply h_cons
  exact ⟨derives_bot_from_phi_neg_phi d_phi d_neg'⟩
```

### Dependency Analysis

The proof relies on `valid_implies_derivable`, which uses the axiom `representation_theorem_backward_empty`. This creates a logical dependency:

```
consistent_implies_satisfiable
    uses valid_implies_derivable
        uses representation_theorem_backward_empty (AXIOM)
```

This is acceptable because:
1. The axiom represents the standard completeness direction
2. The axiom will eventually be proven when full completeness is established
3. This theorem provides the other direction (consistency -> satisfiability) which is also part of completeness

**Alternative**: If we wanted to avoid the axiom dependency, we would need to construct an explicit TaskModel from CanonicalWorldState (the approach from research-001 Option A/C). This is more complex but would prove the axiom itself.

### Checking Current Sorries in Related Files

| File | Line | Sorry | Impact |
|------|------|-------|--------|
| FiniteModelProperty.lean | 81 | `subformulaList_finite` | Target |
| FiniteModelProperty.lean | 162 | `consistent_implies_satisfiable` | Target |
| ContextProvability.lean | 83-84 | `representation_theorem_backward_empty` axiom | Used by target |
| TruthLemma.lean | 160 | `necessitation_lemma` | Task 561 |
| RepresentationTheorem.lean | 151, 159 | `completeness_corollary` | Depends on bridge |
| StrongCompleteness.lean | 82, 114 | `entails_imp_chain`, `imp_chain_to_context` | Task 559 |
| Core/Basic.lean | 56 | `consistent_iff_consistent` | Task 561 |

Completing task 558 will not directly reduce the sorry count but establishes critical completeness infrastructure.

## Decisions

1. **subformulaList_finite**: Use structural induction with omega/linarith for arithmetic
2. **consistent_implies_satisfiable**: Use contrapositive proof via valid_implies_derivable
3. **Axiom dependency**: Accept dependency on `representation_theorem_backward_empty` axiom for now

## Recommendations

### Implementation Plan

**Phase 1: Prove helper lemma** (5 min)
```lean
lemma complexity_pos (phi : Formula) : 1 <= phi.complexity
```

**Phase 2: Prove subformulaList_finite** (30-45 min)
1. Induction on formula structure
2. Base cases handled by simp + omega
3. Recursive cases use IH with arithmetic manipulation
4. For `imp` case, may need intermediate arithmetic lemma

**Phase 3: Prove consistent_implies_satisfiable** (30-60 min)
1. Contrapositive setup with `by_contra`
2. Show `neg phi` is valid from unsatisfiability
3. Apply `valid_implies_derivable`
4. Build contradiction using existing derivation lemmas

### Estimated Total Effort

- Phase 1: 5 minutes
- Phase 2: 30-45 minutes
- Phase 3: 30-60 minutes
- Buffer: 15 minutes

**Total: 1.5-2 hours**

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Arithmetic bound complexity in imp case | Medium | Pre-prove arithmetic helper lemma if omega struggles |
| Axiom dependency on backward_empty | Low | Acceptable for now; axiom represents valid theorem |
| DerivationTree.weakening signature | Low | Verify exact signature matches expected usage |

## Appendix

### Mathlib Lemmas to Import/Use

For `subformulaList_finite`:
- `List.length_append`
- `List.length_cons` (implicit in simp)
- Standard arithmetic (omega handles)

For `consistent_implies_satisfiable`:
- Already have all needed lemmas in project

### Search Queries Used (This Session)

1. `lean_local_search "formula_satisfiable"` - Confirmed definition
2. `lean_local_search "complexity"` - Found definitions
3. `lean_local_search "subformula"` - Found both versions
4. `lean_loogle "List.length (_ ++ _) = _"` - Found `List.length_append`
5. `lean_leansearch "canonical model finite model property satisfiable"` - Found Mathlib patterns
6. `lean_leanfinder "consistent theory has model satisfiable"` - Found model theory patterns

### Verification: Task 557 Completion

Confirmed these are now proven in CanonicalModel.lean:
- `extract_neg_derivation` (line 180-219)
- `mcs_contains_or_neg` (line 231-266)
- `mcs_modus_ponens` (line 274-308)

These were required dependencies for the contrapositive proof strategy.

## Next Steps

Run `/plan 558` to create detailed implementation plan with step-by-step proof construction.
