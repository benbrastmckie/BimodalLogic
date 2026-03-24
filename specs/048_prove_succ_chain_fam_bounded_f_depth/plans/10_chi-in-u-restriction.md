# Implementation Plan: Task #48 (v10)

- **Task**: 48 - prove_succ_chain_fam_bounded_f_depth
- **Status**: [PARTIAL]
- **Effort**: 2-3 hours
- **Dependencies**: Research report 16 (derivability blocker analysis)
- **Research Inputs**:
  - specs/048_prove_succ_chain_fam_bounded_f_depth/reports/16_derivability-blocker.md
- **Previous Plans**:
  - plans/09_boundary-resolution-seed.md (Phase 2 blocked on derivability)
- **Artifacts**: plans/10_chi-in-u-restriction.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Plan v9 was blocked because proving `augmented_seed_consistent` required showing chi.neg is not derivable from old_seed, not just not IN old_seed. Research report 16 found that **chi.neg CAN be in u** while satisfying boundary_resolution_set conditions, making the augmented seed potentially inconsistent.

### The Solution: Option A (Require chi ∈ u)

Restrict `boundary_resolution_set` to only include chi when chi is already in u. This makes consistency trivial: `augmented_seed ⊆ u`, and u is consistent.

**Key question**: Does `chi ∈ u` always hold when we need boundary resolution?

**Answer from research**: When chi.neg ∈ u (so chi ∉ u), the F-obligation F(chi) will be satisfied by the successor through the deferral disjunction mechanism. The critical insight: when FF(chi) ∉ dc, we still need boundary resolution because F(chi) CAN be in dc (counterexample: phi = F(p)).

**How bounded_witness works with chi ∈ u restriction**:
- If F(chi) ∈ u and chi ∈ u: chi goes into boundary_resolution_set, chi ∈ successor ✓
- If F(chi) ∈ u and chi.neg ∈ u: chi NOT in boundary_resolution_set, but deferral disjunction chi ∨ F(chi) ∈ seed. Since FF(chi) ∉ dc, F(chi) ∉ dc (when F(chi) ∉ dc), forcing resolution to chi. But F(chi) CAN be in dc! So Lindenbaum might choose F(chi), and we need to track this case.

**Handling chi.neg ∈ u case**: This case is actually handled by the existing deferral disjunction! When chi.neg ∈ u:
1. chi ∨ F(chi) is in the seed
2. The successor MCS must choose one disjunct
3. If it chooses F(chi): that's fine, the F-obligation propagates to the next successor
4. If it chooses chi: contradiction with chi.neg propagating via g_content? NO — chi.neg is NOT in g_content(u) because that would require G(chi.neg) = neg(F(chi)) ∈ u, contradicting F(chi) ∈ u

So **chi.neg cannot propagate via g_content** when F(chi) ∈ u. The successor CAN have chi ∈ successor even when chi.neg ∈ u.

## Goals & Non-Goals

**Goals**:
- Modify `boundary_resolution_set` to require `chi ∈ u`
- Complete `augmented_seed_consistent` proof (trivial: subset of consistent u)
- Complete remaining phases from v9
- Remove boundary case sorries
- Net sorry reduction: from 8 to 2 (deprecated only)

**Non-Goals**:
- Handling chi.neg ∈ u case specially (handled by existing deferral disjunction)
- Major restructuring of bounded_witness

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| chi ∉ u case needed in bounded_witness | High | Low | Research shows deferral disjunction handles it |
| Breaks existing v9 lemmas | Low | Low | Minor modification |
| Build fails | Medium | Low | Incremental testing |

## Implementation Phases

### Phase 1: Modify boundary_resolution_set definition [COMPLETED]

**Goal**: Add `chi ∈ u` requirement to boundary_resolution_set.

**Current definition** (SuccExistence.lean ~320):
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

**New definition**:
```lean
def boundary_resolution_set (phi : Formula) (u : Set Formula) : Set Formula :=
  {chi | chi ∈ u ∧  -- NEW: chi must be in u
         Formula.some_future chi ∈ u ∧
         Formula.some_future (Formula.some_future chi) ∉ (deferralClosure phi : Set Formula) ∧
         Formula.all_future (Formula.some_future chi) ∉ u}
```

**Tasks**:
- [ ] Update definition in SuccExistence.lean
- [ ] Verify boundary_resolution_set_subset_dc still holds
- [ ] Run `lake build` to check compilation

**Timing**: 0.25 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean`

---

### Phase 2: Complete augmented_seed_consistent [COMPLETED]

**Goal**: Remove the sorry in augmented_seed_consistent using trivial subset argument.

**Proof sketch**:
```lean
theorem augmented_seed_consistent (phi : Formula) (u : DeferralRestrictedSerialMCS phi) :
    SetConsistent (constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u) := by
  -- augmented_seed ⊆ u
  have h_subset : constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u ⊆ u := by
    intro x hx
    cases hx with
    | inl h => exact constrained_successor_seed_subset_u phi u h
    | inr h =>
      -- x ∈ boundary_resolution_set means x ∈ u (by new definition)
      exact h.1  -- chi ∈ u is first condition now
  -- u is consistent, subset is consistent
  exact SetConsistent.subset h_subset u.2.1.2
```

**Tasks**:
- [ ] Prove `boundary_resolution_set phi u ⊆ u` (follows from new definition)
- [ ] Complete augmented_seed_consistent
- [ ] Verify no additional sorries created

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 3: Update v2 construction and Succ proof [PARTIAL]

**NOTE**: The v2 construction approach was abandoned. Investigation revealed the existing construction is sufficient, but the boundary case proofs (FF(psi) ∉ dc) require a different strategy than originally planned.
- `Bimodal.Theorems.future_necessitation`
- `Bimodal.Theorems.future_k_dist`
- `Bimodal.ProofSystem.DerivationTree.neg_elim`
- `Bimodal.Syntax.closureWithNeg_subset_deferralClosure_inv`

These errors are unrelated to the boundary_resolution_set changes and predate this task.

---

### Phase 3 (Original): Update v2 construction and Succ proof [BLOCKED]

**Goal**: Complete the v2 chain construction from Phase 3 of v9.

**Tasks**:
- [ ] Verify constrained_successor_seed_restricted_v2 compiles with new boundary_resolution_set
- [ ] Prove Succ relation holds (g_persistence unchanged, f_step via deferral disjunction)
- [ ] Prove seriality preserved

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 4: Simplify restricted_single_step_forcing [PARTIAL]

**Goal**: Complete Phase 4 from v9 — use boundary_resolution_set to remove sorry.

**Actual outcome**: The boundary_resolution_set approach only helps when `psi ∈ chain(k)`, but `restricted_single_step_forcing` does not have this as a hypothesis. The sorry remains for the `FF(psi) ∉ dc` case.

**Proof for boundary case**:
```lean
-- Case: FF(psi) ∉ dc, GF(psi) ∉ chain(k)
-- If psi ∈ chain(k): psi ∈ boundary_resolution_set ⊆ seed ⊆ chain(k+1) ✓
-- If psi ∉ chain(k): psi.neg ∈ chain(k) by negation completeness
--   Then psi.neg NOT in g_content(chain(k)) (would require G(psi.neg) = neg(F(psi)) ∈ chain(k), contradicting F(psi) ∈ chain(k))
--   So psi.neg does NOT propagate to chain(k+1)
--   deferral disjunction psi ∨ F(psi) in seed
--   Lindenbaum must choose; can choose psi since psi.neg not forced
```

Wait, this shows that even when psi ∉ chain(k), the deferral disjunction handles it. So **do we even need boundary_resolution_set**?

Let me reconsider. The issue was that Lindenbaum MIGHT choose F(psi) instead of psi. With boundary_resolution_set (when psi ∈ u), we force psi directly. Without it (when psi.neg ∈ u), Lindenbaum could choose either, but F(psi) is problematic if FF(psi) ∉ dc.

**Key realization**: If F(psi) ∈ dc but FF(psi) ∉ dc, and Lindenbaum chooses F(psi), then F(psi) is in the successor. But F(psi) at the successor means we need to resolve it at the NEXT step. Since FF(psi) ∉ dc, the next step faces the same boundary issue. Eventually, by finiteness of dc, F(psi) must resolve to psi.

Actually, the bounded_witness already handles this via strong induction on d. The boundary_resolution_set optimization just forces resolution one step earlier.

**Simplified approach**: Maybe we don't need boundary_resolution_set at all! The existing deferral mechanism + bounded induction might suffice.

But wait, the original problem was that bounded_witness had sorries when FF(psi) ∉ dc. Let me check what those sorries actually need...

**The original sorry** (line 3077): `restricted_single_step_forcing` needs to prove `psi ∈ chain(k+1)` given F(psi) ∈ chain(k) and FF(psi) ∉ chain(k). The argument breaks down when FF(psi) ∉ dc because negation completeness doesn't apply.

With boundary_resolution_set (restricted to psi ∈ u): when psi ∈ u, psi is in the seed. When psi ∉ u, the deferral disjunction is in seed, and the proof needs to show Lindenbaum chooses psi over F(psi).

**Actually, the key lemma we need**: When FF(psi) ∉ dc and GF(psi) ∉ u and psi.neg ∈ u, the deferral disjunction psi ∨ F(psi) resolves to... either! And both are potentially consistent with the seed.

If it resolves to F(psi): F(psi) ∈ chain(k+1). Then at step k+1, F(psi) needs resolution. FF(psi) ∉ dc, so... same situation. If F(psi) ∈ dc, it can persist. But this is finite — eventually we run out of closure depth.

**Conclusion**: The bounded_witness induction handles the chi.neg ∈ u case via the d parameter decrease. boundary_resolution_set with chi ∈ u restriction accelerates resolution but isn't strictly necessary.

**For this plan**: Keep boundary_resolution_set with chi ∈ u restriction. It simplifies the proof for the chi ∈ u case.

**Tasks**:
- [ ] Complete restricted_single_step_forcing using boundary_resolution_set for chi ∈ u case
- [ ] For chi.neg ∈ u case: relies on bounded_witness induction (d decreases)
- [ ] Verify no new sorries

**Timing**: 0.75 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

### Phase 5: Update downstream and verify [PARTIAL]

**Goal**: Complete all remaining work and verify.

**Actual outcome**: Build passes. 7 sorries remain (5 boundary cases + 2 deprecated).

**Tasks**:
- [ ] Update bounded_witness to use v2 theorems
- [ ] Update restricted_forward_chain_iter_F_witness
- [ ] Run `lake build`
- [ ] Count sorries: should be 2 (deprecated at 736, 971)
- [ ] Remove obsolete v8 primed theorems if any
- [ ] Clean up debug comments

**Timing**: 0.5 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean`

---

## Testing & Validation

- [ ] `lake build` succeeds
- [ ] `grep -c "sorry" SuccChainFMCS.lean` returns 2 (deprecated only)
- [ ] boundary_resolution_set has chi ∈ u condition
- [ ] augmented_seed_consistent has no sorry
- [ ] restricted_single_step_forcing has no sorry (boundary cases handled)
- [ ] restricted_bounded_witness compiles

## Artifacts & Outputs

- `Theories/Bimodal/Metalogic/Bundle/SuccExistence.lean` — Modified boundary_resolution_set
- `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` — Completed proofs
- `specs/048_prove_succ_chain_fam_bounded_f_depth/summaries/10_chi-in-u-restriction-summary.md` — Summary

## Rollback/Contingency

If chi ∈ u restriction is insufficient:

1. **Add semantic consistency argument**: Show augmented seed has a model
2. **Use induction on brs intersection**: Option C from research report
3. **Remove boundary_resolution_set entirely**: Rely solely on bounded_witness induction

## Key Insight

The chi ∈ u restriction makes consistency trivial (augmented_seed ⊆ u). For the chi.neg ∈ u case, the existing deferral disjunction mechanism handles it, with bounded_witness induction ensuring termination. This is the cleanest fix because it doesn't require new derivability arguments.
