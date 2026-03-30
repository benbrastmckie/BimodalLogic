# Implementation Plan: Close Remaining Sorries in F-Preserving Construction

- **Task**: 69 - close_z_chain_forward_f
- **Status**: [PARTIAL]
- **Effort**: 2-3 hours
- **Dependencies**: None (prior implementation complete)
- **Research Inputs**:
  - specs/069_close_z_chain_forward_f/reports/03_sorry-closure-research.md
- **Artifacts**: plans/05_sorry-closure-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md
- **Type**: lean4
- **Plan Version**: 3 (closes sorries from v2 implementation)

## Overview

Close the 2 remaining sorries from the F-preserving seeds implementation:

1. **`f_preserving_seed_consistent`** (line 1413): Iterated F-extraction with strong induction
2. **`omega_F_preserving_forward_F_resolution` edge case** (line 4338): Handle phi already in chain(t)

The strategies are fully worked out in the research report with concrete code snippets.

## Goals & Non-Goals

**Goals**:
- Close both sorries with verified proofs
- Zero sorries in F-preserving construction
- Unblock downstream theorems (Z_chain_forward_F, bfmcs_from_mcs_temporally_coherent)

**Non-Goals**:
- Restructuring existing proven code
- Modifying temporal coherence definition (use weaker theorem variant instead)

## Implementation Phases

### Phase 1: Close Sorry 2 (Edge Case) [PARTIAL]

**Goal**: Handle the case where `phi ∈ chain(t)` already when proving F-resolution

**Strategy**: Two-case split on `G(phi) ∈ chain(t)`

**Tasks**:
- [ ] Add case split in `omega_F_preserving_forward_F_resolution`:
  ```lean
  by_cases h_phi_t : phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 t
  · -- phi already in chain(t)
    by_cases h_G : Formula.all_future phi ∈ omega_chain_F_preserving_forward M0 h_mcs0 t
    · -- G(phi) ∈ chain(t): use G-theory preservation + T-axiom
      -- G(phi) propagates to chain(t+1), then phi ∈ chain(t+1) by T-axiom
    · -- G(phi) ∉ chain(t): semantic interpretation is F satisfied at t
      -- Weaken to s ≥ t, return s = t
  · -- phi ∉ chain(t): existing persistence argument works
  ```
- [ ] For the `G(phi) ∉ chain(t)` subcase, either:
  - Option A: Return s = t (requires weakening theorem statement)
  - Option B: Show phi must appear via dovetailed enumeration anyway
- [ ] Verify proof compiles without sorry

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line ~4338)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Sorry at line 4338 closed

### Phase 2: Helper Lemmas for Sorry 1 [COMPLETED]

**Goal**: Add infrastructure for iterated F-extraction proof

**Tasks**:
- [ ] Add `countFUnresolved` measure function:
  ```lean
  def countFUnresolved (M : Set Formula) (phi : Formula) (L : List Formula) : Nat :=
    L.countP (fun x => x ∈ F_unresolved_theory M ∧ x ∉ {phi} ∪ temporal_box_seed M)
  ```
- [ ] Add `derives_or_from_neg` lemma for disjunction introduction:
  ```lean
  lemma derives_or_from_neg (Γ : List Formula) (A B : Formula)
      (h : A :: Γ ⊢ B.neg) : Γ ⊢ A.or B
  ```
- [ ] Add `G_or_in_mcs_implies_some` for G distributing over disjunctions:
  ```lean
  lemma G_or_in_mcs_implies_some (M : Set Formula) (h_mcs : SetMaximalConsistent M)
      (As : List Formula) (h : (As.foldr Formula.or Formula.bot).all_future ∈ M) :
      ∃ a ∈ As, Formula.all_future a ∈ M
  ```

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (after F_unresolved_theory definition)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Helper lemmas prove without sorry

### Phase 3: Close Sorry 1 (F-Preserving Consistency) [BLOCKED]

**Goal**: Prove `f_preserving_seed_consistent` via iterated F-extraction

**Strategy**: Strong induction on `countFUnresolved`

**Tasks**:
- [ ] Restructure proof with strong induction:
  ```lean
  theorem f_preserving_seed_consistent ... := by
    have main : ∀ (n : Nat) (L : List Formula),
        (∀ x ∈ L, x ∈ f_preserving_seed M phi) →
        countFUnresolved M phi L = n →
        ¬(L ⊢ Formula.bot) := by
      intro n
      induction n using Nat.strong_induction_on with
      | ind n ih => ...
    intro L h_sub h_derives
    exact main (countFUnresolved M phi L) L h_sub rfl h_derives
  ```
- [ ] Implement base case (n = 0): All elements in standard seed, apply `temporal_theory_witness_consistent`
- [ ] Implement inductive case (n > 0):
  - Find F(psi) ∈ L from F_unresolved_theory
  - Apply deduction theorem: `L \ {F(psi)} ⊢ G(neg psi)`
  - Apply IH with decreased count
  - Collect all G(neg psi_i) into disjunction
  - Use G-lift to get `G(neg psi_i) ∈ M` for some i
  - Contradict with `F(psi_i) ∈ M` via `some_future_excludes_all_future_neg`

**Timing**: 1.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (line ~1413)

**Verification**:
- [ ] `lake build` succeeds
- [ ] Sorry at line 1413 closed

### Phase 4: Final Verification [PARTIAL]

**Goal**: Verify all sorries closed and downstream theorems unblocked

**Tasks**:
- [ ] Run `lake build` and verify no errors
- [ ] Check sorry count in UltrafilterChain.lean:
  ```bash
  grep -c "sorry" Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean
  ```
- [ ] Verify downstream theorems can close:
  - `Z_chain_forward_F` (line 2486)
  - `Z_chain_forward_F'` (line 3666)
  - `omega_forward_F_bounded_persistence` (line 3611)
- [ ] Create implementation summary

**Timing**: 0.5 hours

**Verification**:
- [ ] Zero new sorries in F-preserving construction
- [ ] Downstream theorems closable
- [ ] `lake build` succeeds

## Testing & Validation

- [ ] `lake build` succeeds after each phase
- [ ] Use `lean_goal` to inspect proof states at key lemmas
- [ ] Verify sorry count decreases monotonically

## Artifacts & Outputs

- plans/05_sorry-closure-plan.md (this file)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean`
- summaries/06_sorry-closure-summary.md (post-implementation)

## Key Code References

From research report (03_sorry-closure-research.md):

| Theorem | Line | Purpose |
|---------|------|---------|
| `temporal_theory_witness_consistent` | 1109 | Base case for F-extraction |
| `G_lift_from_context` | 1065 | Derive G(phi) ∈ M from context |
| `some_future_excludes_all_future_neg` | 1089 | Final contradiction |
| `disjunction_iff` | Completeness.lean:133 | MCS disjunction property |
| `deduction_theorem` | Core | Extract F-formulas |

## Rollback/Contingency

If proofs become too complex:
1. Leave detailed sorry with full proof strategy documented
2. Consider alternative approaches from research (e.g., modify temporal coherence definition)
3. Mark as [BLOCKED] with specific technical gap identified
