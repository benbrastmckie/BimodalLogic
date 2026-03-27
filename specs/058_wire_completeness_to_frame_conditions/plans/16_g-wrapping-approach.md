# Implementation Plan: Task #58 - G-Wrapping Approach (v16)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 6-8 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/63_team-research.md (G-wrapping approach recommended)
- **Previous Plan**: plans/15_bypass-false-theorem.md (Phase 1 complete, Phase 2 blocked)
- **Artifacts**: plans/16_g-wrapping-approach.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v15 completed Phase 1 (proving `neg_not_in_seed_when_in_brs`) but Phase 2 is blocked at line 1756 of SuccChainFMCS.lean. The "no contradictory pairs" approach fails because consistency in Hilbert systems requires more than absence of contradictory pairs - complex derivations can produce contradictions without explicit `{psi, psi.neg}` pairs.

Team research (report 63) identified **Path A: G-wrapping on restricted seed** as the most viable approach. This adapts the proven WitnessSeed.lean pattern (lines 79-177) to the multi-BRS case. The key insight: decompose consistency into stages, where Stage 1 handles `g_content(u) ∪ BRS` via G-wrapping, then Stage 2 shows adding remaining seed components preserves consistency.

### Research Integration (Report 63)

**Key Finding**: All 4 previously-attempted approaches definitively ruled out:
1. Direct substitution (psi -> psi v F(psi)) - invalid in Hilbert systems
2. Deduction theorem elimination alone - produces psi.neg, not bot
3. "No contradictory pairs" - insufficient (Hilbert systems can derive bot without explicit pairs)
4. Iterated deduction + MP chain - psi.neg cannot feed the implication chain

**Recommended Path**: G-wrapping on restricted seed (adapted from WitnessSeed pattern):
- Stage 1: Prove `g_content(u) ∪ BRS(phi, u)` consistent
- Stage 2: Show adding `deferralDisjunctions ∪ p_step_blocking_restricted` preserves consistency

## Goals & Non-Goals

**Goals**:
- Prove `constrained_successor_seed_restricted_consistent` (line 1481-1756) via G-wrapping approach
- Complete the dependency chain: seed consistent -> successor exists -> completeness
- Eliminate sorries: `dense_completeness_fc`, `completeness_over_Int` (both depend on seed consistency)

**Non-Goals**:
- `discrete_completeness_fc` (separate blocker: `discrete_Icc_finite_axiom`)
- Restructuring BRS definition (confirmed correct by team research)
- Proving false theorems (neg_not_in_boundary_resolution_set already deleted)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Multi-BRS induction complex | H | M | Start with k=1 case matching WitnessSeed exactly, then generalize |
| G-wrapping doesn't extend to multi-BRS | H | L | Research shows structure is preserved; single-BRS case directly follows WitnessSeed |
| Stage 2 consistency preservation nontrivial | M | M | All Stage 2 elements are subsets of u; use subset-of-consistent-is-consistent lemma |
| Existing proof structure incompatible | M | L | Proof is currently sorry; can restructure freely |
| Unknown proof-theoretic blockers | H | L | WitnessSeed provides working template; adapt rather than invent |

---

## Implementation Phases

### Phase 1: Prove Single-BRS Element Consistent with g_content(u) [NOT STARTED]

**Goal**: Establish the base case - `g_content(u) ∪ {psi}` is consistent when `psi ∈ BRS`

This mirrors WitnessSeed.lean lines 79-127 exactly. The key insight:
- If `L ⊆ g_content(u) ∪ {psi}` derives bot
- Case: psi in L -> deduction theorem gives `L_filt ⊢ psi.neg`, G-wrap to `G(psi.neg) ∈ u`
- But `F(psi) ∈ u` (BRS membership) and `F(psi) = neg(G(psi.neg))` -> contradiction
- Case: psi not in L -> `L ⊆ g_content(u)`, G-wrap entire derivation to contradiction

**Tasks**:
- [ ] Create helper lemma `single_brs_element_with_g_content_consistent`:
  ```lean
  lemma single_brs_element_with_g_content_consistent (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u) (psi : Formula)
      (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
      SetConsistent (g_content u ∪ {psi}) := by
    -- Follow WitnessSeed pattern exactly
  ```
- [ ] Verify proof structure matches WitnessSeed.lean lines 79-127
- [ ] Ensure all necessary lemmas exist (generalized_temporal_k, etc.)
- [ ] Run `lake build` to confirm no errors

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `single_brs_element_with_g_content_consistent` compiles without sorry
- `#print axioms single_brs_element_with_g_content_consistent` shows no sorryAx

---

### Phase 2: Extend to Multiple BRS Elements via Induction [NOT STARTED]

**Goal**: Prove `g_content(u) ∪ BRS(phi, u)` is consistent via induction on BRS elements

The multi-BRS case requires induction because we're adding multiple elements outside u. Key insight:
- BRS is finite (subset of subformulaClosure)
- Each BRS element psi has F(psi) in u, enabling the G-wrapping argument
- Add BRS elements one at a time, preserving consistency at each step

**Tasks**:
- [ ] Create lemma for adding one BRS element to existing consistent set:
  ```lean
  lemma add_brs_element_preserves_consistency (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u) (S : Set Formula)
      (h_S_sub : S ⊆ g_content u ∪ boundary_resolution_set phi u)
      (h_S_cons : SetConsistent S) (psi : Formula)
      (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
      SetConsistent (S ∪ {psi}) := by
    -- Adapt single-BRS argument: derive G(psi.neg) via G-wrapping
    -- Contradiction with F(psi) ∈ u
  ```
- [ ] Use Finset induction on boundary_resolution_set (convert via toFinset)
- [ ] Prove main lemma `g_content_union_brs_consistent`:
  ```lean
  lemma g_content_union_brs_consistent (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u) :
      SetConsistent (g_content u ∪ boundary_resolution_set phi u)
  ```
- [ ] Run `lake build` to verify

**Timing**: 2-2.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `g_content_union_brs_consistent` compiles without sorry
- Induction structure is clean and follows standard Lean patterns

---

### Phase 3: Show Adding Seed Components Preserves Consistency [NOT STARTED]

**Goal**: Prove that adding `deferralDisjunctions ∪ p_step_blocking_restricted` to a consistent subset of u preserves consistency

Key insight from research: deferralDisjunctions and p_step_blocking_restricted are subsets of u. Adding formulas from a consistent set to a subset of that set preserves consistency.

**Tasks**:
- [ ] Prove helper lemma `adding_u_subset_preserves_consistency`:
  ```lean
  lemma adding_u_subset_preserves_consistency (u : Set Formula)
      (h_u_cons : SetConsistent u) (S : Set Formula) (T : Set Formula)
      (h_S_cons : SetConsistent S) (h_T_sub : T ⊆ u)
      (h_S_sub_u : S ⊆ u) :  -- or weaker: S ∪ T ⊆ closure where u is MCS
      SetConsistent (S ∪ T) := by
    -- If (S ∪ T) ⊢ bot, then since S ∪ T ⊆ u, u ⊢ bot, contradicting u's consistency
  ```
- [ ] Apply to show `g_content(u) ∪ BRS ∪ deferralDisjunctions` consistent
- [ ] Apply again to show full seed consistent
- [ ] Handle the subtle case: BRS elements are NOT in u, so we need the Stage 1+2 combination

**Alternative approach** (if above is blocked):
- [ ] Direct proof: any L ⊆ full_seed with L ⊢ bot must have elements from BRS
- [ ] Those BRS elements can be "replaced" via disjunctive reasoning with their deferralDisjunction counterparts
- [ ] The deferralDisjunctions are in u, so the derivation transfers to u

**Timing**: 1.5-2 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- All helper lemmas compile without sorry
- The proof structure is mathematically sound

---

### Phase 4: Complete the Main Consistency Theorem [NOT STARTED]

**Goal**: Assemble Phase 1-3 results to complete `constrained_successor_seed_restricted_consistent`

**Tasks**:
- [ ] Restructure the existing proof at lines 1481-1756
- [ ] Remove the current sorry-filled approach
- [ ] Insert the new G-wrapping proof structure:
  ```lean
  theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
      (h_mcs : DeferralRestrictedMCS phi u)
      (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
      SetConsistent (constrained_successor_seed_restricted phi u) := by
    -- Use g_content_union_brs_consistent for core
    -- Then extend with deferralDisjunctions and p_step_blocking_restricted
    -- via adding_u_subset_preserves_consistency
  ```
- [ ] Verify `augmented_seed_consistent` also becomes sorry-free (depends on main theorem)
- [ ] Run `lake build` to confirm compilation

**Timing**: 1 hour

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `constrained_successor_seed_restricted_consistent` is sorry-free
- `augmented_seed_consistent` is sorry-free
- `#print axioms` shows no sorryAx for both

---

### Phase 5: Wire Through to Completeness Theorems [NOT STARTED]

**Goal**: Eliminate `dense_completeness_fc` and `completeness_over_Int` sorries

With seed consistency proven, the dependency chain is complete:
1. Seed consistent -> Lindenbaum extension succeeds
2. Successor construction works -> canonical model exists
3. Truth lemma applies -> completeness follows

**Tasks**:
- [ ] Trace dependency chain from `constrained_successor_seed_restricted_consistent` to `dense_completeness_fc`
- [ ] Verify `constrained_successor_restricted` can be constructed
- [ ] Check that the chain terminates at the completeness theorems
- [ ] Identify and fix any intermediate sorries in the chain
- [ ] Verify `dense_completeness_fc` (line 108 in Completeness.lean) is now sorry-free
- [ ] Verify `completeness_over_Int` (line 170) is now sorry-free
- [ ] Run full `lake build`

**Timing**: 1-1.5 hours

**Files to modify**:
- `Theories/Bimodal/FrameConditions/Completeness.lean`
- Potentially intermediate files in the chain

**Verification**:
- `dense_completeness_fc` is sorry-free
- `completeness_over_Int` is sorry-free
- `lake build` succeeds with no errors
- `#print axioms dense_completeness_fc` shows no sorryAx

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each modified/new theorem verified with `#print axioms` (no sorryAx)
- [ ] `single_brs_element_with_g_content_consistent` matches WitnessSeed structure
- [ ] `g_content_union_brs_consistent` uses sound induction
- [ ] `constrained_successor_seed_restricted_consistent` is sorry-free
- [ ] `dense_completeness_fc` is sorry-free
- [ ] `completeness_over_Int` is sorry-free
- [ ] `discrete_completeness_fc` remains sorry (documented, separate blocker)

## Artifacts & Outputs

- plans/16_g-wrapping-approach.md (this file)
- Modified: SuccChainFMCS.lean (new G-wrapping proofs, restructured main theorem)
- Modified: Completeness.lean (sorries eliminated via dependency chain)

## Rollback/Contingency

If the G-wrapping approach hits an unexpected blocker:

1. **Phase 1 blocked**: Re-examine WitnessSeed.lean more carefully; the pattern is proven to work
2. **Phase 2 blocked (multi-BRS)**: Try proving BRS is a singleton or small (may simplify induction)
3. **Phase 3 blocked (subset consistency)**: Fall back to Path C (reformulate construction to avoid seed consistency proof entirely - this is invasive but architecturally sound)
4. **Phase 4/5 blocked**: Likely intermediate sorries exist in dependency chain; trace and fix

If fundamentally blocked:
- Path C from research: Restructure Lindenbaum to start from u and greedily add seed elements while maintaining consistency. This avoids proving seed consistency a priori but requires significant refactoring.

## Key Lemmas from Existing Infrastructure

The following proven lemmas are available:
- `generalized_temporal_k` (Theorems/): `L ⊢ phi -> G(L) ⊢ G(phi)`
- `forward_temporal_witness_seed_consistent` (WitnessSeed.lean:79-177): Template for G-wrapping
- `neg_not_in_seed_when_in_brs` (SuccChainFMCS.lean:1408-1425): BRS elements don't have negations in seed
- `brs_mutual_exclusion` (SuccChainFMCS.lean): No chi, chi.neg both in BRS
- `g_content_subset_deferral_restricted_mcs`: g_content(u) ⊆ u
- `deferralDisjunctions_subset_deferral_restricted_mcs`: deferralDisjunctions(u) ⊆ u
- `p_step_blocking_restricted_subset`: p_step_blocking_restricted(phi, u) ⊆ u
- `set_consistent_not_both`: MCS can't contain phi and phi.neg

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| "No contradictory pairs" alone | Insufficient in Hilbert systems - complex derivations can produce bot | Report 63, All teammates |
| Deduction theorem elimination alone | Produces psi.neg, not bot | Report 63, All teammates |
| Direct substitution psi -> psi v F(psi) | Invalid in Hilbert calculus | Report 63, Teammates A, C |
| Iterated deduction + MP chain | psi.neg cannot feed the implication chain | Report 63, Teammate B |
| Semantic satisfiability + soundness | Circular - we need consistency TO BUILD the model | Report 63, Teammates A, B |
| proof_by_cases_bot | Requires both branches; second branch is FALSE | Report 63, Teammate A |
| neg_not_in_boundary_resolution_set | Theorem is mathematically FALSE (deleted) | Report 65 |
