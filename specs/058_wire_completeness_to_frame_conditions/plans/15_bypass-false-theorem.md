# Implementation Plan: Task #58 - Bypass False Theorem (v15)

- **Task**: 58 - wire_completeness_to_frame_conditions
- **Status**: [NOT STARTED]
- **Effort**: 4-6 hours
- **Dependencies**: None (using existing infrastructure)
- **Research Inputs**: reports/65_team-research.md (critical finding: theorem is FALSE)
- **Previous Plan**: plans/14_fix-a1-brs-mutual-exclusion.md (Phase 2 blocked - theorem unprovable)
- **Artifacts**: plans/15_bypass-false-theorem.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v14 implemented Fix A1 (BRS mutual exclusion condition) successfully in Phase 1, and proved `brs_mutual_exclusion`. However, Phase 2 was blocked on `neg_not_in_boundary_resolution_set`. Team research (report 65, 3 teammates) discovered this theorem is **mathematically FALSE** - `F(chi) ∈ u` does NOT imply `chi.neg ∉ BRS` because `chi ≠ chi.neg.neg` syntactically in Lean.

This plan bypasses the false theorem entirely by using a reformulated lemma `neg_not_in_seed_when_in_brs` that takes `psi ∈ BRS` as hypothesis instead of `F(psi) ∈ u`.

### Research Integration (Report 65)

**Critical Finding**: `neg_not_in_boundary_resolution_set` is mathematically false:
- `F(chi)` and `F(chi.neg.neg)` are syntactically different formulas in Lean
- `deferralClosure` is NOT closed under double negation
- The conditions `F(chi) ∈ u` and `chi.neg ∈ BRS` can coexist without contradiction

**Solution**: Four existing proven lemmas suffice for seed consistency:
1. `neg_not_in_g_content_when_F_in` (proven)
2. `neg_not_in_deferralDisjunctions` (proven)
3. `neg_not_in_p_step_blocking_restricted` (proven)
4. `brs_mutual_exclusion` (proven in Phase 1)

**New Lemma**: `neg_not_in_seed_when_in_brs` (provable from the four above)

## Goals & Non-Goals

**Goals**:
- Delete the false theorem `neg_not_in_boundary_resolution_set`
- Delete dependent theorem `neg_not_in_constrained_successor_seed_restricted`
- Create and prove `neg_not_in_seed_when_in_brs` using four existing lemmas
- Prove `constrained_successor_seed_restricted_consistent` via "no contradictory pairs" argument
- Wire through to `dense_completeness_fc` and `bundle_validity_implies_provability`

**Non-Goals**:
- Fixing `discrete_completeness_fc` (separate blocker: `discrete_Icc_finite_axiom`)
- Attempting to prove the false theorem

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Four lemmas insufficient for full consistency | M | L | Research confirms sufficiency; partition argument handles all cases |
| "No contradictory pairs → consistent" step complex | M | M | Use deduction theorem iteration on BRS elements |
| Call sites of deleted theorems break | L | L | Only one call site exists; restructure proof directly |

---

## Implementation Phases

### Phase 1: Delete False Theorems and Create Replacement [NOT STARTED]

**Goal**: Remove the false `neg_not_in_boundary_resolution_set` and create the correct `neg_not_in_seed_when_in_brs`

**Tasks**:
- [ ] Delete `neg_not_in_boundary_resolution_set` (SuccChainFMCS.lean:1411-1440)
- [ ] Delete `neg_not_in_constrained_successor_seed_restricted` (SuccChainFMCS.lean:1445-1456)
- [ ] Create new theorem `neg_not_in_seed_when_in_brs`:

```lean
/--
For any psi in BRS, psi.neg is NOT in the constrained successor seed.

This is the correct formulation: the hypothesis is `psi ∈ BRS` (not `F(psi) ∈ u`).
Provable using the four proven lemmas:
1. neg_not_in_g_content_when_F_in (F(psi) ∈ u from BRS membership)
2. neg_not_in_deferralDisjunctions (structural)
3. neg_not_in_p_step_blocking_restricted (structural)
4. brs_mutual_exclusion (Fix A1)
-/
theorem neg_not_in_seed_when_in_brs (phi : Formula) (u : Set Formula) (psi : Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_psi_brs : psi ∈ boundary_resolution_set phi u) :
    psi.neg ∉ constrained_successor_seed_restricted phi u := by
  intro h_in
  rw [mem_constrained_successor_seed_restricted_iff] at h_in
  rcases h_in with h_g | h_dd | h_ps | h_brs
  · -- Case: psi.neg ∈ g_content(u)
    -- From h_psi_brs, we have F(psi) ∈ u (first BRS condition)
    have h_F_psi : Formula.some_future psi ∈ u :=
      (mem_boundary_resolution_set_iff phi u psi).mp h_psi_brs |>.1
    exact neg_not_in_g_content_when_F_in phi u psi h_mcs h_F_psi h_g
  · -- Case: psi.neg ∈ deferralDisjunctions
    exact neg_not_in_deferralDisjunctions phi u psi h_dd
  · -- Case: psi.neg ∈ p_step_blocking_restricted
    exact neg_not_in_p_step_blocking_restricted phi u psi h_ps
  · -- Case: psi.neg ∈ BRS
    exact brs_mutual_exclusion phi u psi h_psi_brs h_brs
```

- [ ] Run `lake build` to verify compilation

**Timing**: 30-45 minutes

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `neg_not_in_seed_when_in_brs` compiles and has no sorry
- `#print axioms neg_not_in_seed_when_in_brs` shows no sorryAx
- `lake build` succeeds

---

### Phase 2: Prove Seed Consistency [NOT STARTED]

**Goal**: Eliminate the root sorry `constrained_successor_seed_restricted_consistent` at line 1543

**Proof Strategy** (enabled by Phase 1):

The seed is: `g_content(u) ∪ deferralDisjunctions(u) ∪ p_step_blocking_restricted(phi, u) ∪ BRS(phi, u)`

**No contradictory pairs argument**:
1. Non-BRS elements are subsets of u, hence any pair from non-BRS is consistent (u is consistent)
2. For any BRS element psi, psi.neg ∉ seed (by `neg_not_in_seed_when_in_brs`)
3. For any two BRS elements psi and chi.neg, if chi ∈ BRS then chi.neg ∉ BRS (by `brs_mutual_exclusion`)
4. Therefore no `{psi, psi.neg}` pair exists in the seed
5. A finite set without contradictory pairs, where the non-BRS part is consistent, is itself consistent

**Tasks**:
- [ ] Examine goal state at SuccChainFMCS.lean:1543
- [ ] Implement the "no contradictory pairs" argument:
  - For any finite L ⊆ seed with L ⊢ ⊥, construct L' ⊆ u with L' ⊢ ⊥
  - Split L = L_nb ∪ L_brs where L_nb = L ∩ (g_content ∪ deferralDisjunctions ∪ p_step_blocking)
  - For each psi ∈ L_brs: use deferralDisjunction `psi ∨ F(psi)` (since F(psi) ∈ u)
  - Apply deduction theorem to eliminate BRS elements one at a time
- [ ] Run `lake build` and verify no sorry remains

**Expected proof structure**:
```lean
theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u) :
    SetConsistent (constrained_successor_seed_restricted phi u) := by
  -- Use: no {psi, psi.neg} pair exists in seed
  -- For BRS elements: neg_not_in_seed_when_in_brs
  -- For non-BRS: subset of u, which is consistent
  intro L hL_sub h_not_cons
  -- Construct derivation contradiction with u's consistency
  sorry -- Implementation details
```

**Timing**: 2-3 hours (this is the critical phase)

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

**Verification**:
- `constrained_successor_seed_restricted_consistent` is sorry-free
- `#print axioms constrained_successor_seed_restricted_consistent` shows no sorryAx

---

### Phase 3: Wire to Completeness.lean Sorries [NOT STARTED]

**Goal**: Eliminate `dense_completeness_fc` (line 120) and complete `bundle_validity_implies_provability` (line 214)

**Approach**: Same as v14 Phase 4 - build TaskModel directly from RestrictedTemporallyCoherentFamily

**Mathematical structure**:
1. Consistent neg(phi) extends to DeferralRestrictedMCS
2. Build RestrictedTemporallyCoherentFamily from that DRM
3. Build RestrictedCanonicalTaskModel from RTCF
4. Use restricted_truth_lemma: phi in chain iff truth_at in model
5. neg(phi) true at position 0 means phi false there
6. Contrapositive: valid_over Int phi implies provable phi

**Tasks**:
- [ ] Define `RestrictedCanonicalTaskModel` (if not already present)
- [ ] Define `RestrictedOmega` (single history + time shifts)
- [ ] Prove `restrictedOmega_shift_closed`
- [ ] Prove `restricted_completeness_truth` using `restricted_truth_lemma`
- [ ] Wire `bundle_validity_implies_provability` using restricted construction
- [ ] Wire `dense_completeness_fc` via the same path
- [ ] Final: `#print axioms` for all target theorems
- [ ] `lake build` succeeds clean

**Note**: `discrete_completeness_fc` remains sorry - separate blocker not addressed by this plan.

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/CanonicalConstruction.lean` (or new file `RestrictedCanonicalModel.lean`)
- `Theories/Bimodal/FrameConditions/Completeness.lean`

**Verification**:
- `bundle_validity_implies_provability` sorry-free
- `dense_completeness_fc` sorry-free
- `#print axioms` clean for both

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase
- [ ] Each modified/new theorem verified with `#print axioms` (no sorryAx)
- [ ] `neg_not_in_seed_when_in_brs` is sorry-free
- [ ] `constrained_successor_seed_restricted_consistent` is sorry-free
- [ ] `bundle_validity_implies_provability` is sorry-free
- [ ] `dense_completeness_fc` is sorry-free
- [ ] `discrete_completeness_fc` remains sorry (documented, separate blocker)

## Artifacts & Outputs

- plans/15_bypass-false-theorem.md (this file)
- Modified: SuccChainFMCS.lean (delete false theorems, add correct ones)
- Modified/New: CanonicalConstruction.lean or RestrictedCanonicalModel.lean
- Modified: Completeness.lean (target sorries eliminated)

## Rollback/Contingency

If the "no contradictory pairs → consistent" step proves difficult:
1. Try alternative proof via model-theoretic argument (every element compatible with u)
2. Use Lindenbaum extension argument directly on the seed
3. If blocked, document the specific gap and escalate

## Approaches Definitively Ruled Out

| Approach | Why Blocked | Reference |
|----------|-------------|-----------|
| `neg_not_in_boundary_resolution_set` with F(chi) hypothesis | THEOREM IS FALSE | Report 65 |
| Forward-only truth lemma (BFMCS_Bundle) | imp case backward IH needs G/H family-level coherence | Report 64 |
| Extending deferralClosure for double negation | High cost, changes DRM definition | Report 65, Teammate A |
| `chi = chi.neg.neg` syntactic identity | FALSE in Lean - these are structurally different | All teammates |
