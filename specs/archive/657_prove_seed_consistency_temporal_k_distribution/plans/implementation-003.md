# Implementation Plan: Task #657 (Revised v003)

- **Task**: 657 - Prove seed consistency (temporal K distribution)
- **Version**: 003
- **Status**: [COMPLETED]
- **Effort**: 2-3 hours
- **Priority**: Medium
- **Dependencies**: Task 654 (completed), Task 693 (completed - generalized_past_k now available)
- **Research Inputs**:
  - research-006.md (Approach A deep dive)
  - research-007.md (G' definition analysis - rules out alternatives)
  - research-008.md (syntactic vs semantic proof analysis)
- **Previous Plans**:
  - implementation-001.md (blocked at Phase 2 - no temporal T axiom)
  - implementation-002.md (blocked at Phase 4 - needed generalized_past_k)
- **Artifacts**: plans/implementation-003.md (this file)
- **Type**: lean
- **Lean Intent**: true

## Overview

This v003 revision updates the plan now that **Task 693 is completed**, which implemented `generalized_past_k` in GeneralizedNecessitation.lean. Phase 4 (`past_seed_consistent`) is now unblocked and can proceed using the same pattern as `future_seed_consistent`.

### What Changed from v002

| Phase | v002 Status | v003 Change |
|-------|-------------|-------------|
| Phase 1: Verify Infrastructure | COMPLETED | Preserve |
| Phase 2: Semantic Bridge Lemma | COMPLETED | Preserve |
| Phase 3: future_seed_consistent | COMPLETED | Preserve |
| Phase 4: past_seed_consistent | BLOCKED (needed generalized_past_k) | **UNBLOCKED** - Task 693 completed |
| Phase 5: Verification | COMPLETED | Preserve, re-verify after Phase 4 |

### New Infrastructure Available (from Task 693)

Located in `Theories/Bimodal/Theorems/GeneralizedNecessitation.lean`:
- `past_necessitation` - If `[] ⊢ φ` then `[] ⊢ H φ`
- `past_k_dist` - H distributes over implication: `⊢ H(φ → ψ) → (H φ → H ψ)`
- `generalized_past_k` - If `Gamma ⊢ φ` then `(H Gamma) ⊢ H φ`

## Goals & Non-Goals

**Goals**:
- Complete `past_seed_consistent` proof using `generalized_past_k` (now available)
- Remove remaining sorry from IndexedMCSFamily.lean
- Verify full compilation

**Non-Goals**:
- Modifying the approach (hypothesis-based method already works for future case)
- Re-implementing any completed phases

## Implementation Phases

### Phase 1: Verify Infrastructure [COMPLETED - Preserved]

Already done in v001/v002 - imports in place.

---

### Phase 2: Semantic Bridge Lemma [COMPLETED - Preserved]

`G_bot_forbids_future` lemma implemented inline.

---

### Phase 3: future_seed_consistent [COMPLETED - Preserved]

Completed using hypothesis `h_no_G_bot : Formula.all_future Formula.bot ∉ Gamma`.

---

### Phase 4: Complete past_seed_consistent Proof [COMPLETED]

**Goal**: Complete the `past_seed_consistent` proof using `generalized_past_k`

**Blocker Resolved**: Task 693 implemented `generalized_past_k` with signature:
```lean
noncomputable def generalized_past_k : (Γ : Context) → (φ : Formula) →
    (h : Γ ⊢ φ) → ((Context.map Formula.all_past Γ) ⊢ Formula.all_past φ)
```

**Tasks**:
- [ ] Replace sorry in `past_seed_consistent` with actual `generalized_past_k` call
- [ ] Follow same pattern as `future_seed_consistent`:
  1. Apply `generalized_past_k` to get `H L ⊢ H ⊥`
  2. Show all elements of `H L` are in Gamma (using membership check)
  3. By MCS deductive closure, `H ⊥ ∈ Gamma`
  4. Contradiction with hypothesis `h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma`
- [ ] Verify no remaining sorries in the lemma

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Replace sorry at `past_seed_consistent` (around line 420-450)

**Proof Structure**:
```lean
lemma past_seed_consistent (Gamma : Set Formula) (h_mcs : SetMaximalConsistent Gamma)
    (h_no_H_bot : Formula.all_past Formula.bot ∉ Gamma)
    (t : D) (ht : t < (0 : D)) : SetConsistent (past_seed D Gamma t) := by
  simp only [past_seed, ht, ↓reduceIte]
  intro L hL
  by_contra h_incons
  unfold Consistent at h_incons
  push_neg at h_incons
  obtain ⟨d_bot⟩ := h_incons

  -- Step 1: Apply generalized_past_k (NOW AVAILABLE from Task 693)
  let L_H := L.map Formula.all_past
  have d_H_bot : L_H ⊢ Formula.all_past Formula.bot :=
    Bimodal.Theorems.generalized_past_k L Formula.bot d_bot

  -- Step 2: Show all elements of L_H are in Gamma
  have h_L_H_sub : ∀ ψ ∈ L_H, ψ ∈ Gamma := by
    intro ψ h_mem
    simp only [L_H, List.mem_map] at h_mem
    obtain ⟨φ, h_φ_in_L, rfl⟩ := h_mem
    exact hL φ h_φ_in_L

  -- Step 3: By MCS deductive closure, H ⊥ ∈ Gamma
  have h_H_bot_in : Formula.all_past Formula.bot ∈ Gamma :=
    Bimodal.Boneyard.Metalogic.set_mcs_closed_under_derivation h_mcs L_H h_L_H_sub d_H_bot

  -- Step 4: Contradiction with hypothesis
  exact h_no_H_bot h_H_bot_in
```

**Verification**:
- `lean_diagnostic_messages` shows no errors at `past_seed_consistent`
- No sorry remains in the lemma

---

### Phase 5: Final Verification [COMPLETED]

**Goal**: Verify full compilation and check all downstream functions

**Tasks**:
- [ ] Run `lake build` for full project verification
- [ ] Verify `time_seed_consistent` compiles (depends on both future and past lemmas)
- [ ] Verify `mcs_at_time` compiles
- [ ] Verify `construct_indexed_family` compiles
- [ ] Check remaining sorries in file (coherence proofs are separate tasks)

**Timing**: 30 minutes

**Verification**:
- `lake build` succeeds
- `grep -n "sorry" IndexedMCSFamily.lean` shows only coherence-related sorries (not seed consistency)

---

## Testing & Validation

- [ ] `lake build Bimodal.Metalogic.Representation.IndexedMCSFamily` succeeds
- [ ] `lean_diagnostic_messages` shows no errors at `past_seed_consistent`
- [ ] Full project `lake build` completes without errors
- [ ] `#check past_seed_consistent` works with correct type signature
- [ ] `time_seed_consistent` compiles without sorry

## Artifacts & Outputs

- `specs/657_prove_seed_consistency_temporal_k_distribution/plans/implementation-003.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean`
- `specs/657_prove_seed_consistency_temporal_k_distribution/summaries/implementation-summary-YYYYMMDD.md`

## Remaining Sorries After This Plan

After completing Phase 4-5, the remaining sorries in IndexedMCSFamily.lean will be:
1. `construct_indexed_family.forward_G`: Coherence proof (separate task)
2. `construct_indexed_family.backward_H`: Coherence proof (separate task)
3. `construct_indexed_family.forward_H`: Coherence proof (separate task)
4. `construct_indexed_family.backward_G`: Coherence proof (separate task)

These are out of scope for Task 657 (seed consistency focus).

## Summary

With Task 693 completed, the `generalized_past_k` theorem is now available. The implementation follows the exact same pattern as `future_seed_consistent` (already completed in v002), making this a straightforward completion.

```
v002 status:
  Phase 4 (past_seed_consistent): BLOCKED - needed generalized_past_k

v003 status:
  Phase 4 (past_seed_consistent): UNBLOCKED - Task 693 provides generalized_past_k

Implementation: Mirror future_seed_consistent structure with H instead of G
```
