# Handoff: Phase 1 Complete — Enriched Seed + lemma_2_4_with_guard

## Session
- **Session ID**: sess_1778085791_d0f727
- **Plan**: plans/63_implementation-plan.md
- **Phase**: 1 (Enrich lemma_2_4 to Produce Guard in B)
- **Status**: COMPLETED

## What Was Done

### 1. Enriched seed consistency theorem (sorry-free)
- **Location**: `PointInsertion.lean:4832-4940` (end of file)
- **Name**: `until_witness_enriched_seed_consistent`
- **Statement**: `SetConsistent ({β} ∪ g_content A ∪ {φ | ∃ α ∈ A, φ = Formula.snce γ α})`
  given `untl(γ, β) ∈ A` where A is MCS.
- **Proof technique**: For any finite L ⊆ seed with L ⊢ ⊥:
  1. Classically extract α-witnesses from Since-obligations in L
  2. Form α* = list_conj(alpha_list) ∈ A (MCS closed under ∧)
  3. BX13 enrichment: untl(γ, β ∧ snce(γ, α*)) ∈ A
  4. BX10: F(β ∧ snce(γ, α*)) ∈ A
  5. forward_temporal_witness_seed_consistent gives {β ∧ snce(γ, α*)} ∪ g_content(A) consistent
  6. Map L to context Γ ⊆ {β ∧ snce(γ, α*)} ∪ g_content(A) via derivation_from_implied
  7. BX3' right-monotonicity: snce(γ, α*) → snce(γ, αᵢ) for each αᵢ

### 2. lemma_2_4_with_guard (sorry-free)
- **Location**: `PointInsertion.lean:4942-4973` (end of file)
- **Name**: `lemma_2_4_with_guard`
- **Statement**: Returns `∃ B C, ... ∧ γ ∈ B ∧ BurgessR3Maximal A B C`
- **Key difference from lemma_2_4**: Returns `γ ∈ B` (guard in interval DCS)
- **How**: Enriched seed gives C with burgessRSince(C, γ, A).
  burgessRSince_implies_burgessR gives burgessR(A, γ, C).
  burgessR3Maximal_with_guard gives B with γ ∈ B.

### 3. Original lemma_2_4 preserved
- The original `lemma_2_4` was NOT modified (to avoid touching callers unnecessarily)
- Callers that need the guard will switch to `lemma_2_4_with_guard` in Phase 2

## Design Decisions

- **Created lemma_2_4_with_guard as a separate function** instead of modifying lemma_2_4.
  Rationale: lemma_2_4 has 3 callers in CounterexampleElimination.lean. Most don't need
  the guard. Only the C5 elimination callers need it. Modifying lemma_2_4's return type
  would require updating all callers mechanically, while creating a separate function
  lets Phase 2 switch only the callers that need the guard.

- **Placed new theorems at end of PointInsertion.lean** because the proof depends on
  private helpers (list_conj, enrichment_until_mcs, derivation_from_implied, etc.)
  that are defined later in the file than the original lemma_2_4.

## Verification
- `lake build` succeeds (full project, 1097 jobs)
- No new sorry sites introduced
- Exactly 2 sorry sites remain in Chronicle: ChronicleToCountermodel.lean lines 634, 638
- All existing tests pass

## What Remains (Phases 2-5)

### Phase 2: Thread guard through C5 elimination
- Switch the C5 elimination callers in CounterexampleElimination.lean to use
  `lemma_2_4_with_guard` instead of `lemma_2_4`
- Capture the `γ ∈ B` field and propagate it through EliminationResult or
  prove guard propagation directly from c2' + absorption

### Phase 3: Guard propagation to limit
- Prove omega_chain_guard_stable or equivalent
- Show guard ∈ limit_g(x,y) from finite-stage membership

### Phase 4: limit_satisfies_c5_strong
- Combine limit_satisfies_c5_weak + guard propagation

### Phase 5: Close FUC/FSC
- Transfer through Cantor isomorphism
- Close the 2 remaining sorry sites

## Key File Paths
- Modified: `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean`
  - Lines 4832-4973: new theorems (enriched seed + lemma_2_4_with_guard)
- NOT modified: CounterexampleElimination.lean (Phase 2)
- NOT modified: ChronicleConstruction.lean (Phases 3-4)
- NOT modified: ChronicleToCountermodel.lean (Phase 5)
