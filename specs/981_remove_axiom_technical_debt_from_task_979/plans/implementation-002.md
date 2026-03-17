# Implementation Plan: Task #981 (Revision 2)

- **Task**: 981 - remove_axiom_technical_debt_from_task_979
- **Status**: [PARTIAL]
- **Effort**: 5-7 hours
- **Dependencies**: None (builds on existing codebase)
- **Research Inputs**: research-002.md (blocking formula approach), research-003.md (G-inference consistency proof)
- **Artifacts**: plans/implementation-002.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean
- **Lean Intent**: true

## Revision Summary

**What changed from v1**:
- Phase 2 rewritten: "arbitrary forward witness containment" approach failed (mathematically impossible). New approach uses **direct finite derivation argument with G-inference lifting**.
- Phase 5 simplified: Use `SuccOrder.ofCore` from Mathlib instead of deriving from LocallyFiniteOrder.
- Phase 1 preserved: Blocking formula definitions are correct; no changes needed.
- Effort estimate reduced: G-inference approach is cleaner once understood.

**Key research insights (research-003)**:
1. `discreteImmediateSuccSeed(M) ⊆ W` for arbitrary W is impossible (blocking formulas are false in witnesses that go "too far ahead")
2. Each blocking formula is derivable from its trigger via `blocking_formula_from_negG` (already exists)
3. Use G-inference to lift `L_g ∪ triggers ⊢ ⊥` to `G(L_g) ∪ triggers ⊆ M ⊢ ⊥` contradiction

## Overview

This plan eliminates `discrete_Icc_finite_axiom` using the constructive method with blocking formulas. The key is proving consistency of `discreteImmediateSuccSeed(M)` via a **direct finite derivation argument**: any inconsistency would lift via G-inference to an inconsistency in M, contradicting M's MCS property.

## Goals & Non-Goals

**Goals**:
- Complete Phase 1 definitions (already done in v1)
- Prove consistency of blocking seed via direct G-inference argument
- Define `discreteImmediateSucc` as Lindenbaum extension
- Prove covering property using blocking formulas
- Instantiate `SuccOrder` via `SuccOrder.ofCore` (not LocallyFiniteOrder)
- Delete `discrete_Icc_finite_axiom`
- Build passes with zero sorries in affected files

**Non-Goals**:
- Using arbitrary forward witness containment (proven impossible)
- Deriving SuccOrder from LocallyFiniteOrder (reversed dependency)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| G-inference formalization fails | HIGH | LOW | Standard modal logic result; pattern exists in `g_content_consistent` |
| Cut admissibility proof difficult | MEDIUM | LOW | Lean derivation system should support this; check existing lemmas |
| Covering proof still challenging | MEDIUM | MEDIUM | Clearer now: blocking formulas force disjunction cases |
| SuccOrder.ofCore not available | LOW | LOW | Verify with `lean_local_search "SuccOrder.ofCore"` early |

## Sorry/Axiom Characterization

### Pre-existing
- 1 axiom: `discrete_Icc_finite_axiom` in DiscreteTimeline.lean
- 1 sorry: `DiscreteSuccSeed.lean:445` (to be replaced, not filled)

### Expected Resolution
- Phase 2 replaces lines 280-455 entirely (not filling sorry)
- Phase 5 eliminates axiom via SuccOrder.ofCore
- Phase 6 deletes axiom declaration

### New Sorries/Axioms
- None. NEVER introduce new sorries or axioms.

## Implementation Phases

### Phase 1: Define Discrete Immediate Successor Seed [COMPLETED]

**Status**: Already implemented in v1. No changes needed.

- Created `DiscreteSuccSeed.lean` with:
  - `blockingFormula`, `blockingFormulas`, `discreteImmediateSuccSeed`
  - `blocking_formula_from_negG`: `[¬G(ψ)] ⊢ ¬ψ ∨ ¬G(ψ)`
  - `g_content_consistent`: g_content(M) is consistent

**Files created**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

---

### Phase 2: Prove Blocking Seed Consistency (Direct G-Inference) [BLOCKED]

- **Dependencies:** Phase 1
- **Goal:** Prove `discreteImmediateSuccSeed M` is consistent using direct finite derivation argument

**Key insight**: The arbitrary forward witness approach at lines 280-455 fails because blocking formulas are designed to be false in witnesses that go "too far ahead". Replace with direct consistency proof.

**Tasks:**
- [ ] Delete lines 280-455 (failed containment proof with sorry at line 445)
- [ ] Implement new proof structure:

```lean
theorem discreteImmediateSuccSeed_consistent
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    SetConsistent (discreteImmediateSuccSeed M) := by
  -- Proof by contradiction
  intro L hL_sub ⟨d⟩
  -- Decompose L = L_g ∪ L_b where L_g ⊆ g_content(M), L_b ⊆ blockingFormulas(M)

  -- Case 1: L_b = ∅
  -- L ⊆ g_content(M), contradicts g_content_consistent

  -- Case 2: L_b ≠ ∅
  -- Each bf ∈ L_b has trigger ¬G(ψ) ∈ M with [¬G(ψ)] ⊢ bf
  -- Use blocking_formula_from_negG to replace bf → ¬G(ψ) in derivation
  -- Get: L_g ∪ {triggers} ⊢ ⊥ where triggers ⊆ M

  -- Apply G-inference: if φ_1,...,φ_m ⊢ ⊥ then G(φ_1),...,G(φ_m) ⊢ ⊥ (via K + G4)
  -- For φ_i ∈ L_g: G(φ_i) ∈ M by definition of g_content
  -- For ¬G(ψ) ∈ triggers: already in M
  -- So G(L_g) ∪ triggers ⊆ M with G(L_g) ∪ triggers ⊢ ⊥
  -- Contradicts h_mcs.consistent
  sorry
```

- [ ] Find or prove G-inference lemma: `L ⊢ ⊥ → G(L) ⊢ ⊥` (via K-axiom + G4)
  - Search: `lean_local_search "g_inference"` or similar
  - Check `forward_temporal_witness_seed_consistent` proof pattern
- [ ] Prove cut/substitution lemma for replacing `bf` with trigger
- [ ] Verify with `lake build`

**Timing**: 2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty
- `lean_goal` shows "no goals" at theorem QED

---

### Phase 3: Define Discrete Immediate Successor [NOT STARTED]

- **Dependencies:** Phase 2
- **Goal:** Define `discreteImmediateSucc M` as Lindenbaum extension

**Tasks:**
- [ ] Define `discreteImmediateSucc M := lindenbaumMCS_set (discreteImmediateSuccSeed M) h_consistent`
- [ ] Prove `discreteImmediateSucc_mcs`: result is MCS
- [ ] Prove `discreteImmediateSucc_extends_seed`: seed formulas are in result
- [ ] Prove `discreteImmediateSucc_canonicalR`: `CanonicalR M (discreteImmediateSucc M)`
  - Follows from `g_content M ⊆ seed ⊆ discreteImmediateSucc M`
- [ ] Prove `discreteImmediateSucc_blocking`: blocking formulas are in result
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- All proofs complete (no sorries)

---

### Phase 4: Prove Covering Property [NOT STARTED]

- **Dependencies:** Phase 3
- **Goal:** Prove no MCS exists strictly between M and `discreteImmediateSucc M`

**Tasks:**
- [ ] State covering theorem:
```lean
theorem discreteImmediateSucc_covers
    (M K : Set Formula)
    (h_M : SetMaximalConsistent M)
    (h_K : SetMaximalConsistent K)
    (h_MK : CanonicalR M K)
    (h_KW : CanonicalR K (discreteImmediateSucc M h_M)) :
    K = M ∨ K = discreteImmediateSucc M h_M
```

- [ ] Prove using blocking formula argument:
  - Let W = discreteImmediateSucc M
  - Suppose K ≠ M and K ≠ W (want contradiction)
  - Since K ≠ M: ∃ψ with (ψ ∈ K ∧ ψ ∉ M) ∨ (ψ ∉ K ∧ ψ ∈ M)
  - Focus on formulas of form ¬G(φ) ∈ M (these trigger blocking formulas)
  - Blocking formula `¬φ ∨ ¬G(φ) ∈ W`
  - Since CanonicalR K W: `g_content(K) ⊆ W`
  - Case analysis on the disjunction in W leads to constraints on K
  - Use MCS properties to derive K = W or K = M
- [ ] If stuck, document the precise case analysis needed
- [ ] Verify with `lake build`

**Timing**: 1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean`

**Verification**:
- `lake build` passes
- `lean_goal` shows "no goals" at theorem QED
- `grep -n "\bsorry\b" DiscreteSuccSeed.lean` returns empty

---

### Phase 5: Derive SuccOrder via ofCore [NOT STARTED]

- **Dependencies:** Phase 4
- **Goal:** Instantiate `SuccOrder` using `SuccOrder.ofCore` and covering property

**Key change from v1**: Use `SuccOrder.ofCore` directly instead of deriving from LocallyFiniteOrder.

**Mathlib API**:
```lean
SuccOrder.ofCore :
  (succ : α → α) →
  (∀ {a}, ¬IsMax a → ∀ b, a < b ↔ succ a ≤ b) →
  (∀ a, IsMax a → succ a = a) →
  SuccOrder α
```

**Tasks:**
- [ ] Verify `SuccOrder.ofCore` is available: `lean_local_search "SuccOrder.ofCore"`
- [ ] Define `discreteSuccFn : DiscreteTimelineQuot → DiscreteTimelineQuot`
  - Lift `discreteImmediateSucc` to quotient
- [ ] Prove the covering condition for ofCore:
```lean
∀ {a}, ¬IsMax a → ∀ b, a < b ↔ discreteSuccFn a ≤ b
```
  - This follows from Phase 4's covering property
- [ ] Prove max handling (NoMaxOrder makes this vacuous):
```lean
∀ a, IsMax a → discreteSuccFn a = a
```
- [ ] Instantiate `SuccOrder` via `SuccOrder.ofCore`
- [ ] Derive `LocallyFiniteOrder` as consequence (from SuccOrder + PredOrder + linear)
- [ ] Verify with `lake build`

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes
- SuccOrder instance compiles WITHOUT `discrete_Icc_finite_axiom`

---

### Phase 6: Remove Axiom and Final Verification [NOT STARTED]

- **Dependencies:** Phase 5
- **Goal:** Delete `discrete_Icc_finite_axiom` and verify clean build

**Tasks:**
- [ ] Delete `discrete_Icc_finite_axiom` declaration from `DiscreteTimeline.lean`
- [ ] Delete `discrete_Icc_finite` theorem that wraps the axiom
- [ ] Update `LocallyFiniteOrder` instance to derive from SuccOrder
- [ ] Run full `lake build` to verify no regressions
- [ ] Run `grep -rn "\baxiom\b" Theories/Bimodal/` to verify no new axioms
- [ ] Run `grep -rn "\bsorry\b" Theories/Bimodal/` to verify zero sorries
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean`

**Verification**:
- `lake build` passes with no errors
- `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` returns empty

---

## Testing & Validation

### For Lean Tasks (Required)
- [ ] `lake build` passes with no errors
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` returns empty
- [ ] `grep -rn "\bsorry\b" Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] `grep -n "^axiom " Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` returns empty
- [ ] All proofs verified with `lean_goal` showing "no goals"

### General
- [ ] `discreteCanonicalTaskFrame` still compiles and works
- [ ] Downstream completeness proofs still work
- [ ] No regressions in existing functionality

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/StagedConstruction/DiscreteSuccSeed.lean` (modified)
- `Theories/Bimodal/Metalogic/Domain/DiscreteTimeline.lean` (modified)
- `specs/981_remove_axiom_technical_debt_from_task_979/summaries/implementation-summary-YYYYMMDD.md`

## Rollback/Contingency

If implementation fails:
1. Phase 2 (G-inference) is now the risk point - if formalization fails, mark [BLOCKED]
2. Phase 4 (covering) remains challenging but clearer with G-inference done
3. Original `DiscreteTimeline.lean` preserved in git history
4. Fallback: accept axiom with typeclass constraint (research-003 Approach D)
