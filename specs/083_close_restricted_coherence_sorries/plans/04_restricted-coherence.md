# Implementation Plan: Close Restricted Coherence Sorries (v4)

- **Task**: 83 - Close Restricted Coherence Sorries
- **Status**: [NOT STARTED]
- **Effort**: 10-14 hours
- **Dependencies**: None (ResolvingChain.lean foundation from v3 in place)
- **Research Inputs**: specs/083_close_restricted_coherence_sorries/reports/03_team-research.md, specs/083_close_restricted_coherence_sorries/handoffs/03_drm-chain-approach.md
- **Artifacts**: plans/04_restricted-coherence.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorries (`succ_chain_restricted_forward_F` and `succ_chain_restricted_backward_P`) blocking sorry-free `completeness_over_Int`. Previous plans failed on: (v1) multi-target F-persistence gap; (v2) enriched deferral seed inconsistency; (v3) joint filtered F-formula consistency proven unprovable (concrete counterexample). This v4 plan uses a **DRM (DeferralRestrictedMCS) chain** approach: build chains of DRMs using `simplified_restricted_successor` (already implemented sorry-free in ResolvingChain.lean), prove forward_F via the existing `bounded_witness` theorem leveraging bounded F-nesting in DRMs, extend DRM chains to full MCS chains via Lindenbaum, and rewire the completeness path through the new bundle.

### What Changed from v3

- **v3 Phase 2 is dead**: Joint consistency of filtered F-formulas has a concrete counterexample (`G(p -> G(neg A) v G(neg B))` with `F(p)`, `F(A)`, `F(B)`)
- **v3 Phase 1 (blocking relation) is abandoned**: Not needed — the DRM approach avoids topological ordering entirely
- **New approach**: DRM chains have bounded F-nesting (unlike full MCS chains where `F(A) -> F(F(A))` makes nesting unbounded), enabling `bounded_witness`
- **Foundation built**: `ResolvingChain.lean` provides sorry-free DRM successor with Succ relation

### Key Mathematical Insight

In a full MCS, `F(ψ) ∈ M ⟹ F(F(ψ)) ∈ M` (via T-axiom contrapositive), making F-nesting unbounded and `bounded_witness` inapplicable. In a DRM restricted to `deferralClosure(root)`, `F^B(ψ) ∉ deferralClosure` for large enough B, so there exists a maximum nesting depth. The `bounded_witness` theorem (CanonicalTaskRelation.lean:650, sorry-free) then gives: given an n-step Succ chain from u to v where `iter_F n ψ ∈ u` and `iter_F (n+1) ψ ∉ u`, we get `ψ ∈ v`.

### Critical Dependencies (all proven, sorry-free)

| Theorem | Location | What it provides |
|---------|----------|-----------------|
| `bounded_witness` | CanonicalTaskRelation.lean:650 | `iter_F n φ ∈ u`, `iter_F (n+1) φ ∉ u`, n-step MCS Succ chain → `φ ∈ v` |
| `deferral_restricted_mcs_F_bounded` | RestrictedMCS.lean:1126 | DRM has max F-nesting: `∃ d, iter_F d ψ ∈ M ∧ iter_F (d+1) ψ ∉ M` |
| `simplified_restricted_successor_succ` | ResolvingChain.lean:233 | DRM successor satisfies `Succ` |
| `simplified_restricted_successor_is_drm` | ResolvingChain.lean:73 | DRM successor is still a DRM |
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean | Seed `{ψ} ∪ g_content(M)` consistent when `F(ψ) ∈ M` |

### Key Challenge: bounded_witness requires full MCS chain

`bounded_witness` uses `CanonicalTask_forward_MCS` which requires `SetMaximalConsistent` and `Succ` at each step. Our DRM chain has `Succ` but DRM ≠ MCS. Two options:

**Option A (preferred)**: Prove a DRM-version of `bounded_witness`. The proof logic is identical — it only needs: (1) Succ at each step, (2) ability to derive `¬(iter_F (n+1) ψ)` from `iter_F (n+1) ψ ∉ chain(t)`. For DRM, (2) holds when `iter_F (n+1) ψ ∈ deferralClosure` (DRM maximality). Since we only apply this to `ψ ∈ deferralClosure`, all F-iterations up to the bound are in deferralClosure.

**Option B (fallback)**: Extend each DRM to full MCS, prove Succ transfers. Risk: `g_content(MCS) ⊃ g_content(DRM)`, so Succ at MCS level needs separate argument.

## Goals & Non-Goals

**Goals**:
- Sorry-free `completeness_over_Int` and `discrete_completeness_fc`
- DRM-based resolving chain with forward_F/backward_P for deferralClosure formulas
- New bundle construction replacing `boxClassFamilies` in completeness path
- Clean `lake build`

**Non-Goals**:
- Proving original `succ_chain_restricted_forward_F` on `succ_chain_fam` (confirmed unprovable — perpetual deferral is consistent in full MCS chains)
- Closing `bfmcs_from_mcs_temporally_coherent` or `dense_completeness`
- Joint consistency of filtered F-formulas (proven unprovable)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| DRM bounded_witness adaptation harder than expected | M | L | The proof structure is identical to the MCS version. Only substitution: DRM maximality for MCS maximality on deferralClosure formulas. If needed, fall back to Option B (DRM→MCS extension). |
| `CanonicalTask_forward_MCS` reuse requires MCS, not DRM | H | M | Define `CanonicalTask_forward_DRM` analogously. Or extend DRM to MCS and use existing theorem. Either way, bounded_witness logic applies. |
| DRM-to-MCS extension loses Succ for non-DC formulas | M | H | Expected and acceptable. The restricted truth lemma only evaluates deferralClosure formulas. Modal properties (box_class_agree) are handled separately at the bundle level. |
| Modal properties need full MCS for box_class_agree | M | M | Box formulas for which we need box_class_agree are in deferralClosure (they're subformulas of root). DRM maximality suffices for these. |
| Bundle construction more complex than expected | M | L | Follow existing `boxClassFamilies` pattern exactly. Most properties delegate to MCS-level lemmas. |

## Implementation Phases

### Phase 1: DRM Forward/Backward Chains [BLOCKED]

**Goal**: Build Nat-indexed DRM chains using `simplified_restricted_successor`, prove they form Succ chains with all DRM properties propagated.

**Tasks**:
- [ ] Define `drm_forward_chain (phi : Formula) (u₀ : Set Formula) (h_drm₀ : DeferralRestrictedMCS phi u₀) (h_F_top₀ : F(¬⊥) ∈ u₀) : Nat → Set Formula` by recursion (each step applies `simplified_restricted_successor`)
- [ ] Prove `drm_forward_chain_is_drm : ∀ n, DeferralRestrictedMCS phi (drm_forward_chain n)` (by induction, using `simplified_restricted_successor_is_drm`)
- [ ] Prove `drm_forward_chain_succ : ∀ n, Succ (drm_forward_chain n) (drm_forward_chain (n+1))` (by `simplified_restricted_successor_succ`)
- [ ] Prove `drm_forward_chain_F_top : ∀ n, F(¬⊥) ∈ drm_forward_chain n` (propagated via g_content or f_step; `F(¬⊥) = F(¬⊥)` persists since `¬⊥` is always derivable, so deferred F(¬⊥) resolves to ¬⊥ which is in every MCS, hence F(¬⊥) ∈ g-content... need to verify exact propagation mechanism)
- [ ] Define symmetric `drm_backward_chain` using backward seed (p_step analogue)
- [ ] Prove symmetric properties for backward chain

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean`

**Verification**:
- `lake build` passes
- `lean_goal` shows no sorry in chain definitions/properties

---

### Phase 2: DRM Bounded Witness and Forward_F [NOT STARTED]

**Goal**: Prove that the DRM forward chain resolves all F-obligations for deferralClosure formulas (forward_F), using bounded F-nesting and the bounded_witness theorem (or its DRM adaptation).

**Strategy**: For `F(ψ) ∈ drm_forward_chain(t)` with `ψ ∈ deferralClosure`:
1. By `deferral_restricted_mcs_F_bounded`: `∃ d ≥ 1, iter_F d ψ ∈ chain(t) ∧ iter_F (d+1) ψ ∉ chain(t)`
2. Build a `CanonicalTask_forward_DRM` (or adapt to MCS) for the d-step sub-chain from `chain(t)` to `chain(t+d)`
3. Apply bounded_witness (or DRM variant): `ψ ∈ chain(t+d)`

**Tasks**:
- [ ] Define `CanonicalTask_forward_DRM` analogous to `CanonicalTask_forward_MCS` but using DRM instead of MCS (or prove DRM implies MCS for the purpose of using existing theorem — requires extending each DRM to MCS)
- [ ] Prove `drm_chain_canonical_task : CanonicalTask_forward_DRM (drm_forward_chain t) n (drm_forward_chain (t+n))` (by induction on n, using `drm_forward_chain_succ`)
- [ ] Prove (or adapt) `bounded_witness_drm` for DRM chains. Key: the proof of `single_step_forcing` needs `¬(iter_F (n+1) ψ) ∈ u` from `iter_F (n+1) ψ ∉ u`. In DRM: holds when `iter_F (n+1) ψ ∈ deferralClosure` (DRM maximality). Since `F(ψ) ∈ deferralClosure` and all sub-iterations are in deferralClosure up to the bound, this is fine.
- [ ] Prove `drm_forward_chain_forward_F`: `∀ t, ∀ ψ ∈ deferralClosure, F(ψ) ∈ drm_forward_chain(t) → ∃ s > t, ψ ∈ drm_forward_chain(s)`
  - Combine: `deferral_restricted_mcs_F_bounded` gives bound d, `drm_chain_canonical_task` gives d-step chain, `bounded_witness_drm` gives `ψ ∈ chain(t+d)`, set `s = t+d`.
- [ ] Prove symmetric `drm_backward_chain_backward_P`

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean`
- Possibly `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (if adapting bounded_witness for DRM)

**Verification**:
- `lake build` passes
- `lean_verify` on `drm_forward_chain_forward_F` shows no sorry

---

### Phase 3: Int-Indexed FMCS and DRM-to-MCS Bridge [NOT STARTED]

**Goal**: Combine forward/backward DRM chains into an Int-indexed family, extend each DRM to full MCS, and prove temporal properties transfer for deferralClosure formulas.

**Tasks**:
- [ ] Define `drm_fam (phi : Formula) (u₀ : Set Formula) : Int → Set Formula` combining forward (n ≥ 0) and backward (n < 0) DRM chains
- [ ] Prove `drm_fam_forward_G : ∀ t, G(ψ) ∈ drm_fam(t) → ψ ∈ drm_fam(t+1)` (from g_content propagation via Succ)
- [ ] Prove `drm_fam_backward_H : ∀ t, H(ψ) ∈ drm_fam(t) → ψ ∈ drm_fam(t-1)` (symmetric)
- [ ] Prove `drm_fam_forward_F` and `drm_fam_backward_P` (from Phase 2 results)
- [ ] Define `resolving_mcs_fam : Int → Set Formula` by extending each `drm_fam(t)` to full MCS via Lindenbaum
- [ ] Prove `resolving_mcs_fam_is_mcs : ∀ t, SetMaximalConsistent (resolving_mcs_fam(t))`
- [ ] Prove `resolving_mcs_dc_agree : ∀ t, ∀ ψ ∈ deferralClosure, ψ ∈ resolving_mcs_fam(t) ↔ ψ ∈ drm_fam(t)` (by DRM maximality: DRM ⊆ MCS, and if ψ ∈ MCS but ψ ∉ DRM, then ¬ψ ∈ DRM ⊆ MCS, contradiction)
- [ ] Prove `resolving_mcs_fam_forward_G` for deferralClosure formulas (via dc_agree + drm_fam_forward_G)
- [ ] Prove `resolving_mcs_fam_forward_F` for deferralClosure formulas (via dc_agree + drm_fam_forward_F)
- [ ] Construct `ResolvingFMCS` bundling the Int-indexed MCS family with all properties

**Timing**: 2-3 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean`

**Verification**:
- `lake build` passes
- `lean_verify` on `ResolvingFMCS` shows no sorry

---

### Phase 4: Bundle Construction and Completeness Rewiring [NOT STARTED]

**Goal**: Build `resolvingBoxClassFamilies` bundle, prove all BFMCS properties, and rewire `completeness_over_Int` to use the new sorry-free path.

**Tasks**:
- [ ] Define `resolvingBoxClassFamilies M₀ h_mcs root` (same structure as `boxClassFamilies` but starting from `ResolvingFMCS` instead of `SuccChainFMCS`)
- [ ] Prove `resolvingBoxClassFamilies_nonempty`
- [ ] Prove modal properties:
  - `resolvingBoxClassFamilies_modal_forward` (via `box_class_agree` — only needs MCS property, not temporal coherence)
  - `resolvingBoxClassFamilies_modal_backward`
- [ ] Prove bundle temporal properties:
  - `resolvingBoxClassFamilies_bundle_forward_F` (delegates to `ResolvingFMCS.forward_F` for DC formulas)
  - `resolvingBoxClassFamilies_bundle_backward_P` (symmetric)
- [ ] Define `construct_resolving_bfmcs_bundle` assembling all properties
- [ ] Prove `construct_resolving_bfmcs_bundle_eval_at_zero`
- [ ] Prove `resolving_bfmcs_restricted_temporally_coherent` (delegates to forward_F/backward_P)
- [ ] Update `completeness_over_Int` to use `construct_resolving_bfmcs_bundle` path
- [ ] Update `discrete_completeness_fc` to delegate through new `completeness_over_Int`
- [ ] Annotate original sorries (`succ_chain_restricted_forward_F`, `succ_chain_restricted_backward_P`) as BYPASSED
- [ ] Run `lake build` — zero errors
- [ ] Run `lean_verify` on `completeness_over_Int` — no sorry
- [ ] Run `lean_verify` on `discrete_completeness_fc` — no sorry
- [ ] Verify sorry count: only `bfmcs_from_mcs_temporally_coherent` and `dense_completeness` remain

**Timing**: 3-4 hours

**Files to modify**:
- `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean` — bundle construction
- `Theories/Bimodal/FrameConditions/Completeness.lean` — rewire completeness
- `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` — BYPASSED annotations

**Verification**:
- `lake build` passes with zero errors
- `lean_verify` on `completeness_over_Int` shows no sorry
- `lean_verify` on `discrete_completeness_fc` shows no sorry
- grep `sorry` in Completeness.lean returns only unrestricted and dense paths
- grep `sorry` in ResolvingChain.lean returns zero

## Testing & Validation

- [ ] `lake build` passes with zero errors
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.completeness_over_Int` shows no sorry
- [ ] `lean_verify` on `Bimodal.FrameConditions.Completeness.discrete_completeness_fc` shows no sorry
- [ ] grep `sorry` in Completeness.lean returns only `bfmcs_from_mcs_temporally_coherent` and `dense_completeness_fc` paths
- [ ] grep `sorry` in ResolvingChain.lean returns zero

## Artifacts & Outputs

- `specs/083_close_restricted_coherence_sorries/plans/04_restricted-coherence.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/Bundle/ResolvingChain.lean` (phases 1-4)
- Modified: `Theories/Bimodal/FrameConditions/Completeness.lean` (phase 4)
- Modified: `Theories/Bimodal/Metalogic/Algebraic/UltrafilterChain.lean` (phase 4 — BYPASSED)
- Possibly modified: `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` (phase 2 — DRM bounded_witness)
- `specs/083_close_restricted_coherence_sorries/summaries/04_restricted-coherence-summary.md` (after implementation)

## Rollback/Contingency

**If Phase 2 fails (DRM bounded_witness)**:
- Option B: Extend each DRM to full MCS first, use existing `bounded_witness` directly. Requires proving Succ transfers across DRM→MCS extension, which is non-trivial due to g_content expansion. +3-4 hours.

**If Phase 3 fails (DRM-to-MCS bridge)**:
- Bypass the bridge: prove a restricted truth lemma that operates directly on DRM chains without requiring full MCS. The DRM has enough structure (consistent, maximal within DC) for the truth lemma on DC formulas. +4-6 hours.

**If Phase 4 fails (bundle porting)**:
- Prove completeness directly from the resolving family without BFMCS bundle. Adapt restricted truth lemma to take a family instead of a bundle. +3-4 hours.

**Full rollback**: `git revert` all v4 commits. Original sorries remain. ResolvingChain.lean foundation preserved.
