# Implementation Plan: Task #681 (Revised v4)

- **Task**: 681 - Redesign construct_indexed_family with coherent approach
- **Version**: 004 (Complete remaining Phase 4 proofs)
- **Status**: [IMPLEMENTING]
- **Effort**: 4-6 hours
- **Priority**: Medium
- **Dependencies**: None (unblocks Task 658)
- **Previous Plan**: plans/implementation-003.md (Phases 1-3, 5-6 complete)
- **Previous Summary**: summaries/implementation-summary-20260128.md
- **Type**: lean
- **Lean Intent**: true

## Executive Summary

This plan completes the remaining work from implementation-003.md. Phases 1-3, 5-6 are complete. Phase 4 (coherence transitivity) is partial with 7 sorries remaining in `CoherentConstruction.lean`.

### Remaining Sorries (from lines 380-539)

| Location | Sorry | Description |
|----------|-------|-------------|
| Line 380 | `mcs_forward_chain` | Seed consistency induction (forward) |
| Line 393 | `mcs_backward_chain` | Seed consistency induction (backward) |
| Line 480 | `mcs_forward_chain_coherent` | G-persistence through chain |
| Line 520 | `mcs_unified_chain_pairwise_coherent` | Cross-origin case (t < 0 ≤ t') |
| Line 523 | `mcs_unified_chain_pairwise_coherent` | Backward chain forward_G case |
| Line 527 | `mcs_unified_chain_pairwise_coherent` | backward_H condition |
| Line 534 | `mcs_unified_chain_pairwise_coherent` | forward_H condition |
| Line 539 | `mcs_unified_chain_pairwise_coherent` | backward_G condition |

### Key Dependencies Identified

1. **Seed consistency proofs (lines 380, 393)** depend on:
   - Showing G⊥ ∉ mcs(n) implies G⊥ ∉ mcs(n+1) (forward)
   - Showing H⊥ ∉ mcs(n) implies H⊥ ∉ mcs(-n-1) (backward)
   - These use G-4/H-4 axioms: if G⊥ ∈ mcs(n+1), then GG⊥ would be in forward_seed, contradicting G⊥ ∉ mcs(n)

2. **G-persistence through chain (line 480)** depends on:
   - Showing Gφ ∈ mcs(n) → Gφ ∈ mcs(m) for n < m
   - Uses `forward_G_persistence` lemma already proven (lines 262-271)
   - Need inductive infrastructure showing forward_seed ⊆ mcs(n+1)

3. **Cross-origin case (line 520)** requires:
   - Combining backward chain at t < 0 with forward chain at t' ≥ 0
   - Both chains share origin at Gamma = mcs(0)
   - Proof: Gφ ∈ mcs(t) → Gφ ∈ Gamma (backward chain coherence) → φ ∈ mcs(t') (forward chain coherence)

4. **Remaining coherence conditions (lines 523-539)** require:
   - Backward chain symmetry to forward chain proofs
   - T-axiom reasoning: Hφ ∈ mcs(t') → φ ∈ mcs(t') (by reflexivity), then propagate

## Implementation Phases

### Phase 1: Complete Seed Consistency Proofs [NEW]

**Goal**: Prove seeds remain consistent through chain construction.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Strategy**: Replace the sorry at line 380 with a proper proof using inductive maintenance of G⊥-absence.

**Tasks**:
- [ ] Define helper lemma `forward_chain_no_G_bot`:
  ```lean
  /-- G⊥ absence is preserved through forward chain construction.

  Proof idea: Suppose G⊥ ∈ mcs(n+1). Since mcs(n+1) = extendToMCS(forward_seed(mcs(n))),
  and G⊥ ∈ extendToMCS means G⊥ is derivable from forward_seed or G⊥ ∈ forward_seed.
  - If G⊥ ∈ forward_seed(mcs(n)), then GG⊥ ∈ mcs(n), contradicting consistency.
  - If G⊥ derivable from forward_seed: The derivation would require premises Gψᵢ ∈ mcs(n).
    By necessitation of the derivation, GG⊥ would be derivable from GGψᵢ.
    But GGψᵢ ∈ forward_seed(mcs(n)) (by G-4), leading to G⊥ ∈ mcs(n) by closure.

  This is subtle - may need to accept sorry matching Boneyard line 2507.
  -/
  lemma forward_chain_no_G_bot (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) :
      Formula.all_future Formula.bot ∉ mcs_forward_chain Gamma h_mcs h_no_G_bot n := by
    induction n with
    | zero => exact h_no_G_bot
    | succ n ih =>
      -- Proof that G⊥ ∉ extendToMCS(forward_seed(mcs(n)))
      intro h_G_bot_in
      -- G⊥ ∈ extendToMCS(...) means G⊥ ∈ forward_seed(mcs(n)) or G⊥ derivable from it
      -- But G⊥ ∈ forward_seed means GG⊥ ∈ mcs(n)
      -- Need to show this contradicts ih
      sorry -- Accept matching Boneyard line 2507 if full proof too complex
  ```

- [ ] Similarly define `backward_chain_no_H_bot`

- [ ] Use these lemmas to complete the sorries at lines 380 and 393

**Note**: If full proof is too complex due to Lindenbaum extension internals, accept sorries matching Boneyard line 2507 (seed consistency gap).

**Timing**: 1.5 hours

**Verification**:
- Helper lemmas stated correctly
- Sorries reduced or documented as matching Boneyard gap

---

### Phase 2: Complete G-Persistence Through Chain [NEW]

**Goal**: Prove G-formulas persist through the forward chain.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Strategy**: The sorry at line 480 needs to show Gφ ∈ mcs(m') implies Gφ ∈ mcs(m'+1). This uses `forward_G_persistence` (already proven) combined with seed containment.

**Tasks**:
- [ ] Define lemma `forward_chain_G_persistence`:
  ```lean
  /-- G-formulas persist through forward chain.

  If Gφ ∈ mcs(n), then Gφ ∈ mcs(m) for all m ≥ n.
  Uses forward_G_persistence and seed containment.
  -/
  lemma forward_chain_G_persistence (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma)
      (n m : ℕ) (h_le : n ≤ m) (φ : Formula)
      (hG : Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot n) :
      Formula.all_future φ ∈ mcs_forward_chain Gamma h_mcs h_no_G_bot m := by
    induction m with
    | zero =>
      interval_cases n
      exact hG
    | succ m' ih =>
      by_cases h : n ≤ m'
      · -- n ≤ m': Use IH to get Gφ ∈ mcs(m'), then forward_G_persistence for mcs(m'+1)
        have hG_m' := ih h
        -- Need: mcs(m') is MCS and forward_seed(mcs(m')) ⊆ mcs(m'+1)
        have h_mcs_m' : SetMaximalConsistent (mcs_forward_chain Gamma h_mcs h_no_G_bot m') :=
          -- Use induction on mcs_unified_chain_is_mcs pattern
          sorry
        have h_seed_sub := mcs_forward_chain_seed_containment Gamma h_mcs h_no_G_bot m'
        exact forward_G_persistence h_mcs_m' h_seed_sub φ hG_m'
      · -- n = m' + 1 (since n ≤ m'+1 and ¬(n ≤ m'))
        push_neg at h
        have h_eq : n = m' + 1 := Nat.eq_of_lt_succ_of_not_lt (Nat.lt_add_one_of_le h_le) h
        subst h_eq
        exact hG
  ```

- [ ] Prove helper `mcs_forward_chain_is_mcs`:
  ```lean
  lemma mcs_forward_chain_is_mcs (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
      (h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma) (n : ℕ) :
      SetMaximalConsistent (mcs_forward_chain Gamma h_mcs h_no_G_bot n) := by
    induction n with
    | zero => exact h_mcs
    | succ n ih =>
      unfold mcs_forward_chain
      exact extendToMCS_is_mcs _ _
  ```

- [ ] Use `forward_chain_G_persistence` to complete the sorry at line 480

**Timing**: 1 hour

**Verification**:
- `mcs_forward_chain_coherent` compiles without sorry at line 480
- G-persistence proven for arbitrary gaps

---

### Phase 3: Complete Pairwise Coherence Cases [NEW]

**Goal**: Complete all remaining cases in `mcs_unified_chain_pairwise_coherent`.

**File**: `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean`

**Strategy**: Handle each case systematically by combining forward/backward chain coherence through the shared origin at 0.

#### Case 1: Cross-origin (line 520) - t < 0 ≤ t'

**Proof sketch**:
```
Given: Gφ ∈ mcs(t) where t < 0, need φ ∈ mcs(t') where t' ≥ 0
- mcs(t) = mcs_backward_chain(..., (-t).toNat)
- mcs(t') = mcs_forward_chain(..., t'.toNat)
- Key: Show Gφ propagates backward to Gamma (mcs(0))
  - If t = -1: Gφ ∈ mcs(-1) = extendToMCS(backward_seed(Gamma))
    Need to show Gφ ∈ Gamma or Gφ derivable from backward_seed
    This requires backward chain version of G-preservation
  - Actually, backward_G in coherent_at says: t' < t → Gφ ∈ mcs(t') → φ ∈ mcs(t)
    We need: Gφ ∈ mcs(t) where t < 0 < t'

Alternative approach: Use that both chains share Gamma at origin.
- From t to 0: backward_G gives Gφ ∈ mcs(0) (vacuously? No, t < 0 so we need forward direction)
- Actually this is the forward_G direction in reverse time...

Key insight: The backward chain builds from 0 going negative.
- mcs(-1) extends backward_seed(Gamma)
- mcs(-2) extends backward_seed(mcs(-1))
- etc.

For Gφ ∈ mcs(t) where t < 0:
- By construction, we need to trace Gφ back to Gamma
- The backward construction doesn't directly preserve G-formulas going toward origin
- Need: forward_H or backward_G in the chain

Actually: Since t < 0 < t', we can use:
1. backward_G: 0 < t → Gφ ∈ mcs(0) → φ ∈ mcs(t)
   But this goes wrong direction (0 to t, not t to 0)
2. Need "Gφ ∈ mcs(t) → ... → φ ∈ mcs(t')"
   This crosses the origin, which is non-trivial.

Simpler approach: Show Gφ ∈ mcs(t) for any t < 0 implies φ ∈ mcs(t') via:
- Use T-axiom: Gφ → φ (by reflexivity)
- So Gφ ∈ mcs(t) → φ ∈ mcs(t) (MCS closed under derivation)
- Then propagate φ from mcs(t) to mcs(t') via chain
- But this doesn't give forward_G directly...

Best approach: Accept that cross-origin case may need separate reasoning
about how G/H formulas relate between the two chain directions.
```

#### Case 2: Both backward (line 523) - t, t' < 0 with t < t'

**Proof sketch**:
```
Given: Gφ ∈ mcs(t) where t < t' < 0, need φ ∈ mcs(t')
- mcs(t) = mcs_backward_chain(..., (-t).toNat)
- mcs(t') = mcs_backward_chain(..., (-t').toNat)
- Since t < t' < 0, we have -t > -t' > 0, so (-t).toNat > (-t').toNat

Need backward_chain_G_coherent: opposite direction in ℕ
- Gφ ∈ mcs_backward_chain(n) → φ ∈ mcs_backward_chain(m) for m < n
- This is "going toward origin" which is where we started

Key: backward_seed = {φ | Hφ ∈ S}
- If Gφ ∈ mcs(-n), how does φ end up in mcs(-m) for m < n?
- This requires G-formulas to propagate "forward in time" even in backward chain
- The backward chain guarantees H-coherence, not G-coherence directly

Alternative: Use reflexive semantics
- Gφ ∈ mcs(t) → φ ∈ mcs(t) (by T-axiom, since we have reflexive temporal semantics)
- Then use backward chain coherence to get φ from mcs(t) to mcs(t')
- But H-coherence gives: Hφ ∈ mcs(t) → φ ∈ mcs(t') when t < t'
- We have Gφ not Hφ...

This case is genuinely difficult - may need architectural change or accept sorry.
```

#### Case 3-5: Remaining conditions (lines 527, 534, 539)

These cases follow similar patterns to cases 1-2 but for backward_H, forward_H, and backward_G.

**Tasks**:
- [ ] Complete cross-origin case (line 520) using chain composition through Gamma
- [ ] Complete backward chain forward_G case (line 523)
- [ ] Complete backward_H case (line 527) - symmetric to forward_G
- [ ] Complete forward_H case (line 534) - uses T-axiom: Hφ → φ
- [ ] Complete backward_G case (line 539) - symmetric to forward_H

**Key Lemmas Needed**:
```lean
/-- backward_chain preserves H-coherence. -/
lemma mcs_backward_chain_H_coherent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (n m : ℕ) (h_lt : m < n) (φ : Formula)
    (hH : Formula.all_past φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot n) :
    φ ∈ mcs_backward_chain Gamma h_mcs h_no_H_bot m := by
  -- Symmetric to mcs_forward_chain_coherent
  sorry

/-- T-axiom: Gφ → φ holds in MCS (by reflexive semantics). -/
lemma mcs_G_implies_self (S : Set Formula) (h_mcs : SetMaximalConsistent S) (φ : Formula)
    (hG : Formula.all_future φ ∈ S) : φ ∈ S := by
  -- Use T-axiom derivation: Gφ → φ
  have h_T : [] ⊢ (Formula.all_future φ).implies φ := T_axiom_G φ
  exact set_mcs_closed_under_mp h_mcs hG h_T

/-- T-axiom: Hφ → φ holds in MCS (by reflexive semantics). -/
lemma mcs_H_implies_self (S : Set Formula) (h_mcs : SetMaximalConsistent S) (φ : Formula)
    (hH : Formula.all_past φ ∈ S) : φ ∈ S := by
  have h_T : [] ⊢ (Formula.all_past φ).implies φ := T_axiom_H φ
  exact set_mcs_closed_under_mp h_mcs hH h_T
```

**Note**: The `T_axiom_G` and `T_axiom_H` lemmas should exist from the reflexive temporal semantics work in Task 658/716.

**Timing**: 2.5 hours

**Verification**:
- All 5 sorry cases in pairwise_coherent addressed
- Uses existing T-axiom infrastructure from Task 658/716

---

## Risk Analysis

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Cross-origin case too complex | High | Medium | Document as Boneyard-matching gap |
| T-axiom lemmas don't exist | Medium | Low | Create them using reflexive semantics |
| Backward chain G-coherence unprovable | High | Medium | This is genuinely hard - may need to accept sorry |

### Critical Insight: Forward vs Backward G/H Asymmetry

The forward chain naturally preserves G-coherence (Gφ ∈ S → φ ∈ T for t < t').
The backward chain naturally preserves H-coherence (Hφ ∈ S → φ ∈ T for t' < t).

**But** we also need:
- Forward chain: H-coherence (forward_H, backward_G)
- Backward chain: G-coherence (forward_G, backward_H)

These "cross-modal" conditions require the T-axiom (Gφ → φ, Hφ → φ) to mediate.

### Fallback Strategy

If full proofs are not achievable:
1. Document the architectural limitation clearly
2. Accept sorries matching Boneyard's gap at line 2507
3. The overall structure is sound; only seed consistency details remain
4. This still represents significant progress over the original Task 658 blockers

## Success Criteria

- [ ] All sorries either proven or documented as matching Boneyard gap
- [ ] `lake build Bimodal.Metalogic.Representation.CoherentConstruction` succeeds
- [ ] Clear documentation of any remaining gaps
- [ ] Task 658 coherence sorries replaced by CoherentConstruction bridge

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.CoherentConstruction` compiles
- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` compiles
- [ ] Sorries documented with mathematical justification

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Representation/CoherentConstruction.lean` (updated)
- `specs/681_redesign_construct_indexed_family_coherent_approach/summaries/implementation-summary-YYYYMMDD-v2.md`

## References

- Previous plan: specs/681_*/plans/implementation-003.md
- Previous summary: specs/681_*/summaries/implementation-summary-20260128.md
- CoherentConstruction.lean current state: 7 sorries at lines 380, 393, 480, 520, 523, 527, 534, 539
- Boneyard seed consistency gap: Completeness.lean:2507
- Reflexive temporal semantics: Task 658 implementation-summary-20260128.md
