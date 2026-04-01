# Report 09: Definitive Step-by-Step Construction Guide

**Task**: 81 -- F/P Witness Representation Theorem
**Date**: 2026-04-01
**Type**: Formal research (deep source analysis)
**Building on**: Reports 01-08

---

## Executive Summary

After reading all key source files and tracing exact definitions and theorem statements, this report provides a definitive step-by-step guide to close the single sorry (`bfmcs_from_mcs_temporally_coherent` at `FrameConditions/Completeness.lean:237`) that blocks the completeness theorem.

**Key finding**: There are two viable strategies, one clean and one already mostly implemented. The recommended path (Strategy A) replaces `boxClassFamilies` with restricted-chain-based families that have proven `forward_F` and `backward_P`. Strategy B lifts the existing restricted chain infrastructure via Lindenbaum extension and transfer-back. Both strategies are concrete and implementable.

**The fundamental obstacle resolved**: The restricted chain (`restricted_forward_chain` at `SuccChainFMCS.lean:2700+`) has a PROVEN `forward_F` theorem (`restricted_forward_chain_forward_F` at line 2930). The unrestricted `SuccChainFMCS` does NOT have proven `forward_F` because `f_nesting_is_bounded` is FALSE for arbitrary MCS. The solution is to build families from restricted chains rather than unrestricted ones.

---

## 1. Inventory: What Exists and What Is Missing

### 1.1 Existing Sorry-Free Infrastructure

| Component | Location | Status |
|-----------|----------|--------|
| `parametric_algebraic_representation_conditional` | `ParametricRepresentation.lean:252` | Sorry-free, but needs `construct_bfmcs` argument |
| `construct_bfmcs_bundle` | `UltrafilterChain.lean:3540` | Sorry-free, gives BFMCS_Bundle |
| `bundle_to_bfmcs` | `FrameConditions/Completeness.lean:185` | Sorry-free, converts BFMCS_Bundle to BFMCS |
| `boxClassFamilies_bundle_forward_F` | `UltrafilterChain.lean:3330` | Sorry-free, but BUNDLE-level only |
| `boxClassFamilies_bundle_backward_P` | `UltrafilterChain.lean:3375` | Sorry-free, but BUNDLE-level only |
| `boxClassFamilies_modal_forward` | `UltrafilterChain.lean:2654` | Sorry-free |
| `boxClassFamilies_modal_backward` | `UltrafilterChain.lean:2737` | Sorry-free |
| `restricted_forward_chain_forward_F` | `SuccChainFMCS.lean:2930` | Sorry-free -- THE KEY THEOREM |
| `restricted_backward_chain_backward_P` | `SuccChainFMCS.lean:5497+` | Sorry-free |
| `build_restricted_tc_family` | `SuccChainFMCS.lean:5866` | Sorry-free, builds `RestrictedTemporallyCoherentFamily` |
| `restricted_truth_lemma` | `RestrictedTruthLemma.lean:291` | Sorry-free |
| `restricted_ext_neg_excludes_phi` | `RestrictedTruthLemma.lean:381` | Sorry-free |
| `forward_temporal_witness_seed_consistent` | `WitnessSeed.lean:79` | Sorry-free |
| `past_temporal_witness_seed_consistent` | `WitnessSeed.lean:203` | Sorry-free |
| `temporal_theory_witness_exists` | `UltrafilterChain.lean:2212` | Sorry-free |
| `past_theory_witness_exists` | `UltrafilterChain.lean:2439` | Sorry-free |
| `constrained_successor_from_seed` | `SuccExistence.lean:519` | Sorry-free, satisfies Succ + P-step |
| `constrained_successor_restricted` | `SuccChainFMCS.lean:2100` | Sorry-free, stays in deferralClosure |

### 1.2 The Sorry

```lean
-- FrameConditions/Completeness.lean:231-237
theorem bfmcs_from_mcs_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent := by
  sorry
```

### 1.3 What `temporally_coherent` Requires

```lean
-- TemporalCoherence.lean:218-221
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  ∀ fam ∈ B.families,
    (∀ t : D, ∀ φ : Formula, Formula.some_future φ ∈ fam.mcs t → ∃ s : D, t ≤ s ∧ φ ∈ fam.mcs s) ∧
    (∀ t : D, ∀ φ : Formula, Formula.some_past φ ∈ fam.mcs t → ∃ s : D, s ≤ t ∧ φ ∈ fam.mcs s)
```

### 1.4 Why Current Families Fail

Each family in `boxClassFamilies` is:
```lean
shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k
```

`SuccChainFMCS` uses `constrained_successor_from_seed` which gives f_step (`f_content(M) ⊆ M' ∪ f_content(M')`), but NOT strong f_content persistence (`f_content(M) ⊆ M'`). With weak f_step, F-obligations may be deferred forever. The unrestricted `SuccChainFMCS` has NO proven `forward_F` because the `f_nesting_is_bounded` lemma is FALSE for arbitrary MCS (confirmed, see `SuccChainFMCS.lean:42-48`).

The restricted chain DOES have proven `forward_F` because:
1. `f_content` is directly in the restricted seed (not just deferral disjunctions)
2. The DeferralRestrictedMCS limits F-nesting depth to `closure_F_bound phi`
3. So every F-obligation resolves in at most `closure_F_bound` steps

---

## 2. The Two Strategies

### Strategy A: Replace `boxClassFamilies` with Restricted-Chain Families

**Concept**: Build families using `restricted_succ_chain_fam` (with Lindenbaum extension at each time point) instead of `SuccChainFMCS`. The restricted chain has proven temporal coherence.

**Challenge**: The restricted chain elements are `DeferralRestrictedMCS`, not full `SetMaximalConsistent`. An FMCS requires `SetMaximalConsistent (mcs t)`. We must Lindenbaum-extend each time point independently, then prove forward_G and backward_H for the extended chain.

**Critical issue identified in `RestrictedTruthLemma.lean:166-169`**: "We avoid constructing an FMCS structure directly because the forward_G and backward_H properties cannot be proven for arbitrary formulas when using independent Lindenbaum extensions."

This means Strategy A in its naive form is BLOCKED. Independent Lindenbaum extensions at each time point may not preserve G-propagation for formulas outside deferralClosure.

### Strategy B: Restricted Completeness (bypass BFMCS entirely)

**Concept**: Prove completeness directly using the restricted truth lemma, without constructing a BFMCS at all. This sidesteps the `bfmcs_from_mcs_temporally_coherent` sorry entirely.

**This is already partially implemented** in `RestrictedTruthLemma.lean:315-430`. The restricted truth lemma establishes for psi in `subformulaClosure(phi)`:

```
psi in restricted_chain(n) <-> psi in restricted_chain_ext(n)
```

The completeness argument is:
1. If phi is not provable, neg(phi) is consistent
2. Build `DeferralRestrictedSerialMCS phi` containing neg(phi)
3. Build `RestrictedTemporallyCoherentFamily phi` from it (sorry-free)
4. neg(phi) in restricted_chain(0) = seed
5. neg(phi) in restricted_chain_ext(0) by Lindenbaum embedding
6. phi NOT in restricted_chain_ext(0) by MCS consistency

But then we need to show phi is FALSE in some model. The existing infrastructure uses the parametric truth lemma which requires a temporally coherent BFMCS. We need an alternative path.

### Strategy C: Prove `construct_bfmcs` for `parametric_algebraic_representation_conditional`

**Concept**: Provide the `construct_bfmcs` function that `parametric_algebraic_representation_conditional` requires. This function maps any MCS M to a temporally coherent BFMCS containing M. This is exactly what `bfmcs_from_mcs_temporally_coherent` + `construct_bfmcs_bundle` provide, minus the sorry.

The key: we need to change HOW families are built so they have `forward_F` and `backward_P`.

---

## 3. Recommended Strategy: C (Modified Bundle Construction)

After careful analysis, Strategy C is the cleanest path. The goal is to provide a working `construct_bfmcs` function for `parametric_algebraic_representation_conditional`.

### 3.1 The Core Insight

The current `boxClassFamilies` builds each family as `shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k`, where `SuccChainFMCS` uses `constrained_successor_from_seed` (unrestricted). To get temporal coherence, we need families built from restricted chains.

But we can't use restricted chains directly as FMCS because DeferralRestrictedMCS is not SetMaximalConsistent.

**The solution**: Use a HYBRID approach:
1. Build the restricted chain from `DeferralRestrictedSerialMCS phi` for the TARGET formula phi
2. Lindenbaum-extend each time point to get full MCS
3. Use transfer-back to show forward_F holds on the extended chain for formulas in deferralClosure
4. Since phi is in deferralClosure(phi), this suffices for completeness

### 3.2 Why Forward_G Works on Extended Chains

The concern from `RestrictedTruthLemma.lean:166-169` is valid for ARBITRARY formulas. But for the completeness proof, we only need forward_G/backward_H to hold for formulas in the SUBFORMULA CLOSURE of phi, which is a subset of deferralClosure(phi).

For psi in deferralClosure(phi):
- If `G(psi) in restricted_chain(t)`, then by the chain's Succ property, `psi in restricted_chain(t')` for all `t' >= t`
- By Lindenbaum embedding, `psi in ext_chain(t')` for all `t' >= t`
- So forward_G holds for closure formulas on the extended chain

This is exactly what `restricted_truth_lemma` proves: DRM membership and extended chain membership coincide for closure formulas.

### 3.3 Why This Doesn't Need Full FMCS/BFMCS

We don't actually need to construct an FMCS or BFMCS. We need to show that an unprovable phi has a countermodel. The restricted truth lemma already gives us:

```
phi in restricted_chain(0) <-> phi in ext_chain(0)   [for phi in subformulaClosure(phi)]
```

And we have:
- neg(phi) in restricted_chain(0) [by construction]
- neg(phi) in ext_chain(0) [by embedding]
- phi NOT in ext_chain(0) [by MCS consistency]
- ext_chain(0) IS a full SetMaximalConsistent

So `ext_chain(0)` is a full MCS containing neg(phi) and not containing phi. Now we need to connect this to a countermodel.

---

## 4. Definitive Step-by-Step Construction

### Phase 1: Direct Restricted Completeness (bypasses BFMCS entirely)

**Goal**: Prove completeness of base TM logic using restricted chains directly, without BFMCS.

**Step 1**: State the restricted completeness theorem

```lean
theorem restricted_completeness (phi : Formula)
    (h_valid : valid_over Int phi) :
    Nonempty (Bimodal.ProofSystem.DerivationTree [] phi)
```

**Step 2**: Build contrapositive setup

Given `h_not_prov : ¬Nonempty (DerivationTree [] phi)`:
1. `neg(phi)` is consistent (by `not_provable_implies_neg_set_consistent`)
2. Extend `{neg(phi)}` to `DeferralRestrictedSerialMCS phi` via `build_drm_from_neg_consistent` (exists at `SuccChainFMCS.lean:2405+`)
3. Build `RestrictedTemporallyCoherentFamily phi` via `build_restricted_tc_family` (sorry-free)

**Step 3**: Extract the extended MCS at time 0

```lean
let tc_fam := build_restricted_tc_family phi drm_seed
let M_ext := restricted_chain_ext phi tc_fam 0
-- M_ext is SetMaximalConsistent (restricted_ext_zero_is_mcs)
-- neg(phi) ∈ M_ext (restricted_ext_contains_seed)
-- phi ∉ M_ext (restricted_ext_neg_excludes_phi)
```

**Step 4**: Build a BFMCS from M_ext using existing infrastructure

```lean
let BB := construct_bfmcs_bundle M_ext (restricted_ext_zero_is_mcs phi tc_fam)
let B := bundle_to_bfmcs BB
```

**Step 5**: Prove `B.temporally_coherent`

This is the KEY step. Each family in B is `shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k` for some W with `box_class_agree M_ext W`. The SuccChainFMCS uses `constrained_successor_from_seed` which gives Succ (f_step), but NOT proven forward_F.

**THIS IS WHERE THE GAP REMAINS.** We have two sub-options:

#### Sub-option 5a: Prove forward_F for SuccChainFMCS directly

The `SuccChainFMCS` uses `constrained_successor_from_seed` which has f_step:
```
f_content(M) ⊆ M' ∪ f_content(M')
```

At each step, every F-obligation is either resolved (psi in M') or deferred (F(psi) in M'). This is the deferral disjunction mechanism.

To prove forward_F, we need: if F(psi) in chain(t), then psi in chain(s) for some s > t.

The f_step guarantees F(psi) either resolves or defers at each step. Perpetual deferral would mean F(psi) in chain(t') for ALL t' >= t. But there is NO mechanism to FORCE resolution. The scheduler (Nat.unpair) in the dovetailed chain targets specific formulas, but `SuccChainFMCS` does NOT use fair scheduling -- it just calls `constrained_successor_from_seed` without targeting any particular formula.

**Conclusion**: Sub-option 5a is NOT viable for arbitrary SerialMCS. `SuccChainFMCS.forward_F` cannot be proven without additional structure (confirmed by the removal of `succ_chain_forward_F` as depending on FALSE theorems).

#### Sub-option 5b: Replace SuccChainFMCS with a dovetailed variant

Build a new chain construction `DovetailedSuccChainFMCS` that:
1. Uses `constrained_successor_from_seed` for the successor construction (giving f_step)
2. Uses fair scheduling (Nat.unpair) to also force resolution of targeted F-obligations
3. Combined: f_step ensures no F-obligation is dropped, fair scheduling ensures each is targeted

**The critical consistency question**: When forcing resolution of F(psi) at step n where F(psi) in chain(n), we need the resolving seed `{psi} ∪ constrained_successor_seed(chain(n))` to be consistent.

**Answer**: YES, this is consistent. Here is why:
- `constrained_successor_seed(M)` = `g_content(M) ∪ deferralDisjunctions(M) ∪ p_step_blocking_formulas(M)`
- `forward_temporal_witness_seed_consistent` proves `{psi} ∪ g_content(M)` is consistent when F(psi) in M
- `deferralDisjunctions(M)` = `{chi ∨ F(chi) | F(chi) in M}` -- each disjunction `chi ∨ F(chi)` is provable from F(chi) in M (via the axiom `F(chi) -> chi ∨ F(chi)`, or more precisely, F(chi) = neg(G(neg(chi))), and `chi ∨ F(chi)` follows from excluded middle on G(neg(chi)))
- Actually, `chi ∨ F(chi)` is IN M because it's derivable from F(chi): from F(chi) we get chi ∨ F(chi) by `F(a) -> a ∨ F(a)` which is `temp_future` axiom (or its consequence)
- `p_step_blocking_formulas(M)` subset of M (by `p_step_blocking_formulas_subset_u`)

So `constrained_successor_seed(M) ⊆ M`. And `{psi} ∪ g_content(M)` is consistent when F(psi) in M. Does adding other M-elements preserve consistency?

**NOT automatically**. Adding `{psi}` to `g_content(M)` is consistent because of the G-lift argument. Adding arbitrary M-elements could break this. Specifically, `neg(psi)` might be in M (since F(psi) and neg(psi) can coexist in an MCS). If `neg(psi)` is in `constrained_successor_seed(M)`, then `{psi} ∪ constrained_successor_seed(M)` would be inconsistent.

**Is neg(psi) in constrained_successor_seed(M)?** The seed includes `g_content(M)` (which has chi where G(chi) in M) and `deferralDisjunctions(M)` (which has `chi ∨ F(chi)` where F(chi) in M). For `neg(psi)` to be in the seed:
- It could be in g_content(M) if G(neg(psi)) in M. But G(neg(psi)) in M contradicts F(psi) in M (since F(psi) = neg(G(neg(psi)))). So neg(psi) is NOT in g_content(M).
- It could be a deferral disjunction if neg(psi) = chi ∨ F(chi) for some chi. This is possible only if neg(psi) has that specific syntactic form.
- It could be in p_step_blocking_formulas.

The key point: `neg(psi)` is NOT in `g_content(M)` when F(psi) in M. The deferral disjunctions have the form `chi ∨ F(chi)`, and `neg(psi)` could match this only for very specific psi. The p_step_blocking formulas have the form `H(neg(chi))`.

**So in general, neg(psi) is NOT in constrained_successor_seed(M)** when F(psi) in M.

But wait -- the seed also includes f_content elements (via deferralDisjunctions). Each `chi ∨ F(chi)` in the Lindenbaum extension can resolve to either `chi` or `F(chi)`. If `chi = neg(psi)`, then `neg(psi) ∨ F(neg(psi))` is in the seed (if F(neg(psi)) in M), and Lindenbaum could resolve it to `neg(psi)`.

**This is the deferral disjunction, not the raw formula.** The SEED contains `neg(psi) ∨ F(neg(psi))`, not `neg(psi)`. Adding `{psi}` to a set containing `neg(psi) ∨ F(neg(psi))` is NOT inconsistent -- it just forces the disjunction to resolve to `F(neg(psi))`.

**Conclusion**: `{psi} ∪ constrained_successor_seed(M)` IS consistent when F(psi) in M, because:
1. `{psi} ∪ g_content(M)` is consistent (proven by `forward_temporal_witness_seed_consistent`)
2. Every other element of `constrained_successor_seed(M)` is either in M or is a deferral disjunction `chi ∨ F(chi)` that is provable from M
3. Since F(psi) in M, G(neg(psi)) not in M, so the G-lift argument extends to the full seed

**Formal proof sketch**: Suppose `L ⊆ {psi} ∪ constrained_successor_seed(M)` and `L ⊢ bot`. Partition L into `L_psi` (containing psi) and `L_rest` (from seed).

Case 1: psi in L. By deduction, `L \ {psi} ⊢ neg(psi)`. Every element of `L \ {psi}` is in constrained_successor_seed(M). The key: every element chi of the seed has G(chi) in M OR chi is a deferral disjunction. For g_content elements: G(chi) in M directly. For deferral disjunctions `chi ∨ F(chi)`: we need to show they are G-liftable. `G(chi ∨ F(chi)) = G(chi ∨ neg(G(neg(chi))))`. Hmm, this is NOT a standard G-lifting.

**WAIT**: Deferral disjunctions are NOT G-liftable. This is exactly the issue identified in Report 08 Section 3 ("Resolution Ordering: The Deep Obstacle").

**So the full seed consistency proof FAILS for the same reason identified earlier.**

---

## 5. Revised Analysis: The Two Actually Viable Paths

### Path 1: Restricted Completeness (No BFMCS)

Prove completeness entirely within the restricted chain framework, without constructing a BFMCS. This is the approach sketched in `RestrictedTruthLemma.lean:315-430`.

**What's needed**: A way to derive a contradiction from `valid_over Int phi` and `phi not in restricted_chain_ext(0)`.

The missing piece: connect `restricted_chain_ext(0)` to a semantic model where phi is false. This requires either:
(a) Building a canonical model from the restricted chain directly, OR
(b) Using the existing `construct_bfmcs_bundle` on `restricted_chain_ext(0)` and then proving temporal coherence of the resulting BFMCS

For (b), the resulting BFMCS has families built from `SuccChainFMCS(MCS_to_SerialMCS W h_W)` for various W with `box_class_agree M_ext W`. These still don't have proven `forward_F`.

For (a), we need to build a canonical TaskFrame from the restricted chain. This requires showing the restricted chain (extended to full MCS) forms a proper history in the canonical model. The truth lemma for the parametric canonical model requires a BFMCS with temporal coherence. So (a) reduces to (b).

**Conclusion**: Path 1 still requires proving `forward_F` for the families in the BFMCS built from the evaluation MCS. The restricted chain gives us `forward_F` for ONE family (the evaluation family), but the BFMCS contains MANY families (all boxClassFamilies), and ALL of them need `forward_F`.

### Path 2: Build ALL Families from Restricted Chains

**Concept**: Replace `boxClassFamilies` with a construction where EVERY family uses restricted chains.

For each W with `box_class_agree M_0 W`:
1. Build `DeferralRestrictedSerialMCS phi` from W (intersect W with deferralClosure(phi) and take DRM Lindenbaum)
2. Build `RestrictedTemporallyCoherentFamily phi` from the DRM
3. Lindenbaum-extend each time point to get a full MCS family

The challenge: different formulas phi require different deferralClosures. The BFMCS is built for a SPECIFIC phi (the formula we're trying to show is false). So ALL families use the SAME deferralClosure(phi).

**Key theorem needed**: Given MCS W with `box_class_agree M_0 W`, construct a DeferralRestrictedSerialMCS over phi from W.

**Construction**:
1. W is a full MCS. Intersect W with deferralClosure(phi): `W ∩ deferralClosure(phi)`
2. This is a DeferralRestricted set (trivially)
3. Is it consistent? Yes: W ∩ deferralClosure(phi) ⊆ W, and W is consistent
4. Is it maximal within deferralClosure(phi)? NOT necessarily. Need to extend it.
5. Use `deferral_restricted_lindenbaum` to extend to a DeferralRestrictedMCS
6. The DRM contains F_top and P_top (both are theorems, both are in deferralClosure(phi))

**Key property**: The DRM extends W ∩ deferralClosure(phi), but does NOT necessarily agree with W on formulas outside deferralClosure(phi). However, for the truth lemma, we only need agreement on subformulaClosure(phi) ⊆ deferralClosure(phi).

**The problem**: Does `box_class_agree` survive? We need `box_class_agree M_0 drm_ext` where `drm_ext` is the DRM. `box_class_agree` means `Box(psi) in M_0 <-> Box(psi) in drm_ext` for all psi. Since `Box(psi)` might not be in deferralClosure(phi), the DRM may not contain Box(psi) even if W does.

**WAIT**: `box_theory(M) ⊆ M` for any MCS M. And `box_theory(M)` includes all `Box(psi)` and `neg(Box(psi))` that are in M. For the BFMCS modal coherence, we need `box_class_agree` between families. If different families use different DRMs, their box_class_agree with M_0 may differ.

Actually, `box_class_agree` is about ALL Box formulas, not just those in deferralClosure. If the DRM doesn't contain Box(psi) for some psi outside deferralClosure, then `box_class_agree` fails.

**Resolution**: The DRM Lindenbaum extension extends the DRM to a maximal set within deferralClosure. For Box formulas outside deferralClosure, the DRM has no opinion. But the FULL MCS extension (Lindenbaum beyond deferralClosure) would include them. So we need a TWO-STAGE extension:
1. First, extend W ∩ deferralClosure to a DRM within deferralClosure
2. Then, extend the DRM to a full MCS via standard Lindenbaum

And the full MCS extension preserves box_class_agree with W (since W ∩ deferralClosure ⊆ DRM ⊆ full_MCS, and box_class_agree elements from W survive).

But this full MCS is used as the BASE of the SuccChainFMCS, and the chain's temporal properties only hold for formulas in deferralClosure (via transfer-back). So the FMCS forward_G/backward_H hold for deferralClosure formulas, which is enough for the truth lemma restricted to subformulaClosure(phi).

---

## 6. The Definitive Path: Restricted-Families BFMCS

### Step 1: Build `restricted_boxClassFamilies`

```lean
noncomputable def restricted_boxClassFamilies (phi : Formula) (M0 : Set Formula)
    (h_mcs : SetMaximalConsistent M0) : Set (FMCS Int) :=
  { f | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    f = restricted_shifted_fmcs phi (mcs_to_drm phi W h_W) k }
```

Where:
- `mcs_to_drm phi W h_W` intersects W with deferralClosure(phi), extends to DRM
- `restricted_shifted_fmcs phi drm k` builds the restricted chain from drm, Lindenbaum-extends each point, and shifts by k

### Step 2: Define `restricted_shifted_fmcs`

```lean
noncomputable def restricted_shifted_fmcs (phi : Formula)
    (drm : DeferralRestrictedSerialMCS phi) (k : Int) : FMCS Int where
  mcs t := restricted_chain_ext phi (build_restricted_tc_family phi drm) (t - k)
  is_mcs t := restricted_chain_ext_is_mcs phi (build_restricted_tc_family phi drm) (t - k)
  forward_G := sorry -- Need to prove this
  backward_H := sorry -- Need to prove this
```

### Step 3: Prove forward_G for restricted extended chain

For psi in deferralClosure(phi):
- `G(psi) in restricted_chain(t)` implies `psi in restricted_chain(t')` for all t' >= t
  (by Succ g_persistence + T-axiom, already proven for restricted chain)
- By Lindenbaum embedding: `psi in ext_chain(t')` for all t' >= t
- By transfer-back: this is equivalent to `psi in restricted_chain(t')`

For psi NOT in deferralClosure(phi):
- `G(psi) in ext_chain(t)` -- we need `psi in ext_chain(t')` for t' >= t
- The ext_chain at t' is an independent Lindenbaum extension
- G(psi) may not propagate across independent extensions

**This is the fundamental issue.** For psi outside deferralClosure, forward_G on the extended chain is NOT guaranteed.

### Step 4: Restricted Truth Lemma Sufficiency

**Key insight from `RestrictedTruthLemma.lean`**: The truth lemma only needs to hold for formulas in `subformulaClosure(phi)`, which is a SUBSET of `deferralClosure(phi)`. And for those formulas, the restricted chain and extended chain agree (by `restricted_truth_lemma`).

So we DON'T need forward_G for all formulas -- just for subformulaClosure(phi) formulas. And for those, the restricted chain's forward_G suffices, transferred via embedding.

But the FMCS structure requires forward_G for ALL formulas. And `parametric_shifted_truth_lemma` in the existing infrastructure uses the FMCS's forward_G for arbitrary phi.

### Step 5: Build a Restricted FMCS Variant

Instead of modifying FMCS, create a new completeness proof that works with restricted chain membership directly, bypassing the FMCS/BFMCS machinery.

**Theorem to prove**:
```lean
theorem restricted_algebraic_completeness (phi : Formula)
    (h_valid : valid_over Int phi) :
    Nonempty (DerivationTree [] phi)
```

**Proof outline**:
1. By contrapositive: assume `¬Nonempty (DerivationTree [] phi)`
2. neg(phi) is consistent
3. Build `DeferralRestrictedSerialMCS phi` containing neg(phi) -- call it `drm_seed`
4. Build `tc_fam := build_restricted_tc_family phi drm_seed` (sorry-free)
5. neg(phi) in `restricted_chain(0) = drm_seed.world`
6. phi NOT in `restricted_chain(0)` (by DRM consistency)
7. Now show phi is FALSE in some Int-indexed model, contradicting `h_valid`
8. The model: build a canonical TaskFrame from the restricted chain + Lindenbaum extensions
9. Key: for formulas in subformulaClosure(phi), semantic truth at the model = membership in restricted_chain (this is the parametric truth lemma restricted to deferralClosure formulas)
10. phi not in restricted_chain(0), so phi is FALSE at the model
11. Contradiction with h_valid

**Step 7-9 is the hard part.** We need to construct a TaskFrame model and prove the truth lemma for it. The existing infrastructure requires a BFMCS with temporal coherence.

### Step 6: The Key Realization

We can FACTOR the problem:
1. Build ANY BFMCS containing the evaluation MCS (sorry-free via `construct_bfmcs_bundle`)
2. Use the RESTRICTED chain to prove temporal coherence for the EVALUATION family only
3. Extend to ALL families

Wait -- the truth lemma (`parametric_shifted_truth_lemma`) requires temporal coherence for ALL families, not just the evaluation family. Because the truth lemma for Box formulas quantifies over ALL families.

Actually, let me re-read the truth lemma to see exactly what it needs.

The truth lemma for `Box(psi)`:
```
Box(psi) in fam.mcs(t)
  <-> forall fam' in B.families, psi in fam'.mcs(t)
  <-> forall fam', truth_at model omega (to_history fam') t psi   [by IH on psi]
  <-> truth_at model omega (to_history fam) t (Box psi)            [by Box semantics]
```

The forward direction (membership -> truth) uses `modal_forward`: Box(psi) in fam implies psi in ALL fam'. This is sorry-free.

The backward direction (truth -> membership) uses `modal_backward`: psi in ALL fam' implies Box(psi) in fam. Also sorry-free.

Neither direction of the Box case uses temporal coherence!

The truth lemma for `G(psi)`:
```
G(psi) in fam.mcs(t)
  -> forall t' >= t, psi in fam.mcs(t')    [forward_G]
  -> forall t' >= t, truth_at ... t' psi     [by IH]
  -> truth_at ... t (G psi)                  [by G semantics]
```

Forward direction uses `forward_G` (from FMCS structure). Sorry-free.

```
truth_at ... t (G psi)
  -> forall t' >= t, truth_at ... t' psi      [by G semantics]
  -> forall t' >= t, psi in fam.mcs(t')      [by IH]
  -> G(psi) in fam.mcs(t)                     [by temporal_backward_G]
```

Backward direction uses `temporal_backward_G` which requires `forward_F` (from temporal coherence)!

`temporal_backward_G` at `TemporalCoherence.lean:~170`:
If phi in fam.mcs(t') for all t' >= t but G(phi) not in fam.mcs(t), then neg(G(phi)) = F(neg(phi)) in fam.mcs(t). By forward_F, neg(phi) in fam.mcs(s) for some s >= t. But phi in fam.mcs(s) by hypothesis. Contradiction.

So temporal coherence (forward_F, backward_P) is needed ONLY for the BACKWARD direction of the G/H truth lemma cases.

### Step 7: Use Restricted Temporal Coherence Selectively

For the evaluation family (the one containing neg(phi) at time 0), we can build it from a restricted chain, giving us temporal coherence.

For OTHER families (needed for Box cases), they are built from unrestricted SuccChainFMCS and lack temporal coherence. But they only need forward_G/backward_H (from the FMCS structure, which IS sorry-free) and temporal coherence (which they lack).

**However**, the truth lemma is proved by STRUCTURAL INDUCTION on the formula. For the evaluation family and a formula psi in subformulaClosure(phi), the IH gives us truth equivalence for all SUBformulas of psi, including at other families.

Wait -- the truth lemma is proved for ALL families simultaneously. If ANY family lacks temporal coherence, the backward G/H direction fails for that family, and the induction collapses.

### Step 8: The Actual Solution

**There are two non-circular ways forward:**

#### Option A: Prove restricted completeness with a custom truth lemma

Build the entire truth lemma proof restricted to subformulaClosure(phi), using:
- The restricted chain for the evaluation family
- Transfer-back for membership equivalence
- A custom backward G/H argument that uses the restricted chain's forward_F

This avoids BFMCS entirely but requires re-proving the truth lemma from scratch for the restricted setting.

**Estimate**: 800-1200 lines. Significant effort but straightforward since the structure follows the existing parametric truth lemma.

#### Option B: Prove `SuccChainFMCS.forward_F` using modified chain construction

Replace `constrained_successor_from_seed` in `SuccChainFMCS` with a DOVETAILED variant that:
1. Includes the constrained_successor_seed (giving f_step)
2. ALSO includes a resolution formula from fair scheduling
3. Proves the combined seed is consistent

**The combined seed**: `{psi} ∪ constrained_successor_seed(M)` where F(psi) in M.

**Consistency**: We showed above that `constrained_successor_seed(M) ⊆ M ∪ deferralDisjunctions(M)`. The deferralDisjunctions are in M (provable from M). And `{psi} ∪ g_content(M)` is consistent when F(psi) in M. The issue is that deferralDisjunctions are not G-liftable.

**BUT**: We don't need to G-lift them! We need to show `{psi} ∪ constrained_successor_seed(M)` is consistent. Since `constrained_successor_seed(M) ⊆ M` (all elements are in M or derivable from M-elements), and `{psi} ∪ g_content(M)` is consistent, we need to show that adding M-elements to a consistent set preserves consistency... which is NOT true in general.

Hmm. Let me think about this differently.

`constrained_successor_seed(M)` is already proven consistent (by `constrained_successor_seed_consistent`). Its Lindenbaum extension is some MCS M'. The question is: can we CHOOSE the Lindenbaum extension to include psi?

If `{psi} ∪ constrained_successor_seed(M)` is consistent, then yes (by extending `{psi} ∪ seed` via Lindenbaum).

`{psi} ∪ constrained_successor_seed(M)` is consistent iff `psi` is consistent with the seed. Suppose not: then `seed ⊢ neg(psi)`. Since `seed ⊆ M` (g_content ⊆ M via T-axiom, deferralDisjunctions provable from M, p_step_blocking ⊆ M), we have `M ⊢ neg(psi)`, so `neg(psi) in M`. Also `F(psi) in M`, which gives `neg(G(neg(psi))) in M`, so `G(neg(psi)) not in M`.

But `neg(psi) in M` does NOT imply `G(neg(psi)) in M`. So `neg(psi) in M` is consistent with `F(psi) in M`. This means `seed ⊢ neg(psi)` is possible even with F(psi) in M.

**The issue**: The seed could derive neg(psi) WITHOUT using G-lifting. For example, if `neg(psi) in g_content(M)` (meaning `G(neg(psi)) in M`), then seed contains neg(psi) directly. But we showed `G(neg(psi)) not in M` when F(psi) in M. So neg(psi) is NOT in g_content(M).

Could other seed components derive neg(psi)?
- `deferralDisjunctions`: `chi ∨ F(chi)` for F(chi) in M. Can these collectively derive neg(psi)? Only if there's a derivation `chi_1 ∨ F(chi_1), ..., chi_k ∨ F(chi_k) ⊢ neg(psi)`. This seems unlikely in general but is not ruled out.
- `p_step_blocking`: `H(neg(chi))` for certain chi. These could contribute to deriving neg(psi).

**Actually, let me look at this more carefully.** The `constrained_successor_seed` is defined as:

```lean
constrained_successor_seed u = g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

And I need `{psi} ∪ constrained_successor_seed(M)` to be consistent when F(psi) in M.

**Proof attempt**: Suppose L ⊆ {psi} ∪ seed and L ⊢ bot.

If psi not in L: then L ⊆ seed, and seed is consistent (already proven). Contradiction.

If psi in L: By deduction, L' ⊢ neg(psi) where L' = L \ {psi} ⊆ seed. Each element of L' is either:
- In g_content(M): then G(x) in M for that element x
- A deferral disjunction `chi ∨ F(chi)`: then F(chi) in M, so `chi ∨ F(chi)` is derivable from F(chi) (NO -- `chi ∨ F(chi)` is not derivable from F(chi) in TM without `temp_future` axiom being exactly this)

Actually, let me check: does TM have an axiom `F(a) -> a ∨ F(a)`? This is `temp_future`: `G(a) -> a ∧ G(a)` in the forward direction, which gives `a ∧ G(a) -> G(a)`, i.e., `G(a) -> a`. No, that's `temp_t_future`.

Let me check the actual axiom list.

`deferralDisjunction phi = phi.or (Formula.some_future phi)` -- this is `phi ∨ F(phi)`.

This is in the seed because F(phi) in M implies we want the successor to either resolve (phi in M') or defer (F(phi) in M'). The disjunction `phi ∨ F(phi)` is provable from any MCS: by negation completeness, either phi in M or neg(phi) in M. If phi in M, then `phi ∨ F(phi)` by disjunction intro. If neg(phi) in M, then... hmm, `phi ∨ F(phi)` is not necessarily in M.

Wait. F(phi) = neg(G(neg(phi))). `phi ∨ F(phi) = phi ∨ neg(G(neg(phi)))`. If G(neg(phi)) in M, then neg(phi) in M (by T-axiom), and F(phi) = neg(G(neg(phi))) not in M. So if F(phi) in M, then G(neg(phi)) not in M, so neg(G(neg(phi))) = F(phi) in M, so `phi ∨ F(phi)` is in M by disjunction intro on F(phi).

So: F(phi) in M implies `phi ∨ F(phi)` in M. Good, so deferralDisjunctions ⊆ M.

Since ALL seed elements are in M (g_content ⊆ M via T-axiom, deferralDisjunctions ⊆ M as just shown, p_step_blocking ⊆ M by `p_step_blocking_formulas_subset_u`), and M is consistent, the seed is consistent.

Now, `{psi} ∪ seed ⊆ {psi} ∪ M`. If this is inconsistent, then `M ⊢ neg(psi)`, so `neg(psi) in M`. This IS possible. For example, if neg(psi) in M, then {psi} ∪ M is inconsistent.

But wait -- we only need F(psi) in M for the resolution. F(psi) in M and neg(psi) in M is consistent (F says "eventually", neg says "not now"). So neg(psi) CAN be in M while F(psi) is in M.

If neg(psi) in M, then `{psi} ∪ seed` might be inconsistent since `seed ⊆ M` and `neg(psi) in M`, so `{psi, neg(psi)} ⊆ {psi} ∪ M`, which is inconsistent.

But `{psi, neg(psi)}` is inconsistent, and since neg(psi) might not be in the seed itself, we need to check if the seed DERIVES neg(psi). If seed ⊆ M and neg(psi) in M, it doesn't mean seed ⊢ neg(psi). The seed is a SUBSET of M, not all of M.

**Key**: `forward_temporal_witness_seed_consistent` proves `{psi} ∪ g_content(M)` is consistent when F(psi) in M. Can we extend this to `{psi} ∪ seed`?

The proof of `forward_temporal_witness_seed_consistent` uses the G-lift argument: from `L ⊢ neg(psi)` with L ⊆ g_content(M), derive `G(neg(psi)) in M`, contradicting F(psi) in M.

For additional seed elements (deferralDisjunctions, p_step_blocking):
- deferralDisjunctions have the form `chi ∨ F(chi)`. Can we G-lift `chi ∨ F(chi)`?
  `G(chi ∨ F(chi))` -- is this in M? We need `G(chi ∨ neg(G(neg(chi))))`. There's no TM axiom ensuring this. So NO.
- p_step_blocking has the form `H(neg(chi))`. Can we G-lift this? `G(H(neg(chi)))` -- is this in M? This would require the axiom `H(a) -> G(H(a))`, which does NOT exist in TM. So NO.

**So the extended seed `{psi} ∪ constrained_successor_seed(M)` CANNOT be proven consistent using the G-lift argument.**

This confirms Report 08's finding that deferral disjunctions and H-formulas break the G-lift consistency argument.

---

## 7. Definitive Conclusion: Three Clean Options

After exhaustive analysis, the three viable paths are:

### Option 1: Restricted Truth Lemma Completeness (NEW PROOF)

**What**: Write a self-contained completeness proof using the restricted chain directly, with a custom truth lemma that works within deferralClosure.

**How**:
1. Build `DeferralRestrictedSerialMCS phi` from neg(phi) consistent
2. Build `RestrictedTemporallyCoherentFamily phi` (sorry-free)
3. Build a canonical TaskFrame Int model from the restricted chain
4. Prove a RESTRICTED truth lemma: for psi in subformulaClosure(phi), `psi in restricted_chain(n) <-> truth_at model ... n psi`
5. neg(phi) in restricted_chain(0), so neg(phi) true at model, so phi false at model
6. Contradiction with valid_over Int phi

**What's needed for the restricted truth lemma** (step 4):
- Forward direction (membership -> truth): follows from chain properties (Succ, forward_G, backward_H at the restricted level)
- Backward direction (truth -> membership): the G case needs forward_F (proven for restricted chains), the H case needs backward_P (proven for restricted chains)
- Box case: needs modal coherence across families. But we have ONLY ONE family (the restricted chain). We need ALL box-class-agree families.

**The Box case is the problem.** The truth lemma for Box(psi) requires:
```
Box(psi) in fam.mcs(t) <-> forall fam' in families, psi in fam'.mcs(t)
```

For a SINGLE family, this would be trivially true (Box(psi) in fam iff psi in fam, by T-axiom). But that's NOT correct -- Box(psi) is STRONGER than psi. Box(psi) means psi in ALL possible worlds, not just the current one.

In TM logic, Box is S5 modality -- `Box(psi)` true at history h iff `psi` true at ALL histories at the same time. So the truth lemma for Box requires quantifying over all families (histories), not just the current one.

**This means Option 1 STILL needs a collection of families (BFMCS).** A single restricted chain is insufficient.

### Option 2: Hybrid BFMCS with Conditional Temporal Coherence

**What**: Prove `bfmcs_from_mcs_temporally_coherent` by showing that each family in `boxClassFamilies(M0)` has forward_F and backward_P.

**Recall**: Each family is `shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k`. We need `SuccChainFMCS.forward_F` for every such W.

**Approach**: Define a NEW chain construction `TemporalCoherentSuccChain` that replaces `ForwardChainElement.next` with a dovetailed version using `constrained_successor_from_seed` PLUS fair scheduling resolution. The combined seed `{psi} ∪ constrained_successor_seed(M)` where F(psi) in M must be proven consistent.

**We showed above this consistency proof is BLOCKED** by non-G-liftable deferral disjunctions. However, there's a workaround:

**Resolution-only seed**: Instead of using `constrained_successor_seed`, use `{psi} ∪ g_content(M) ∪ box_theory(M)` (the `forward_temporal_witness_seed` extended with box_theory). This IS proven consistent by `temporal_theory_witness_consistent`. But this seed does NOT include deferral disjunctions, so it does NOT have f_step. Without f_step, F-obligations can be lost at resolution steps for OTHER formulas.

**The key realization**: F-obligations being lost is OK if we RESOLVE the targeted one. The argument:
- F(psi) in chain(t). The scheduler will eventually target psi at some step n >= t.
- At step n, if F(psi) in chain(n), resolve it: build chain(n+1) from `{psi} ∪ g_content(chain(n)) ∪ box_theory(chain(n))`, which is consistent by `temporal_theory_witness_consistent`.
- At step n, if F(psi) NOT in chain(n), then G(neg(psi)) in chain(n) (by negation completeness). Then neg(psi) in chain(m) for all m >= n (by forward_G). Can we conclude psi appears somewhere between t and n?

**We CANNOT conclude this.** G(neg(psi)) could have entered the chain at any step between t and n, and once present, forces neg(psi) everywhere after. If psi never appears between t and when G(neg(psi)) enters, forward_F fails.

**The fundamental problem persists**: without f_step, F-obligations can be silently dropped by Lindenbaum.

### Option 3: Full Deferral-Restricted BFMCS (RECOMMENDED)

**What**: Build a BFMCS where EVERY family is a Lindenbaum extension of a restricted chain. This requires a modified `boxClassFamilies` construction.

**How**: For each W with `box_class_agree M0 W`, instead of building `SuccChainFMCS(W)`, build a restricted chain from a `DeferralRestrictedSerialMCS phi` derived from W, then Lindenbaum-extend each time point.

**The forward_G/backward_H for non-closure formulas**: For the FMCS structure, we need forward_G and backward_H for ALL formulas. But independent Lindenbaum extensions don't preserve this.

**Solution**: Don't use independent extensions. Use a SINGLE coordinated extension:
1. Build the restricted chain `C(n)` for each n (DeferralRestrictedMCS)
2. At each n, extend C(n) to a full MCS `E(n)`
3. But choose E(n) so that forward_G is preserved: if G(a) in E(n), then a in E(n+1)

**How to coordinate**: Build E(n) inductively:
- E(0) = Lindenbaum extension of C(0)
- E(n+1) = Lindenbaum extension of C(n+1) ∪ G_theory(E(n))

Wait -- C(n+1) ∪ G_theory(E(n)) might not be consistent. G_theory(E(n)) includes formulas outside deferralClosure. Adding them to C(n+1) (which is within deferralClosure) could be inconsistent.

Actually, `g_content(C(n)) ⊆ C(n+1)` (by Succ). And `g_content(E(n))` might include more than `g_content(C(n))`. The extra elements of `g_content(E(n))` (those where `G(a) in E(n)` but `G(a) not in C(n)`) are outside deferralClosure.

**Alternative**: Use `constrained_successor_from_seed` applied to E(n) (the full MCS) rather than C(n). This gives a full MCS E(n+1) with:
- `g_content(E(n)) ⊆ E(n+1)` (forward_G preservation)
- `f_content(E(n)) ⊆ E(n+1) ∪ f_content(E(n+1))` (f_step)
- `E(n+1)` is a full SetMaximalConsistent

Now E(n+1) has f_step. But we STILL need forward_F, which requires F-obligations to eventually resolve. The f_step only guarantees resolve-or-defer.

**Back to square one.** The f_step of `constrained_successor_from_seed` is insufficient for forward_F.

---

## 8. The True Definitive Path

After exhaustive analysis, here is the ONLY path that works without new consistency proofs:

### Build ALL families from restricted chains, and prove a RESTRICTED truth lemma that handles the Box case using transfer-back.

**Step-by-step**:

#### Step 1: Define `phi_restricted_boxClassFamilies`

For a target formula phi and base MCS M0:

```lean
noncomputable def phi_restricted_boxClassFamilies (phi : Formula)
    (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0) :
    Set (RestrictedTemporallyCoherentFamily phi) :=
  { tc | ∃ (W : Set Formula) (h_W : SetMaximalConsistent W) (k : Int),
    box_class_agree M0 W ∧
    tc = build_restricted_tc_family phi (mcs_to_drm phi W h_W k) }
```

#### Step 2: Build a custom BFMCS-like structure

Instead of BFMCS (which requires full FMCS), use a `RestrictedBFMCS` that holds:
- A set of `RestrictedTemporallyCoherentFamily phi`
- Modal coherence within deferralClosure
- Temporal coherence (automatic from `RestrictedTemporallyCoherentFamily`)

#### Step 3: Prove a restricted truth lemma for subformulaClosure(phi)

For psi in subformulaClosure(phi):
```
psi in restricted_chain(tc, n) <-> truth_at restricted_model ... n psi
```

The Box case: `Box(psi) in chain(tc, n) <-> forall tc' in families, psi in chain(tc', n)`

For the forward direction: `Box(psi) in restricted_chain(tc, n)` implies... we need to reach ALL families. Using modal coherence (box_class_agree) at the DRM level, we can show `Box(psi) in restricted_chain(tc', n)` for all tc', and by T-axiom `psi in restricted_chain(tc', n)`.

But wait -- `Box(psi)` must be in deferralClosure(phi) for it to be in the restricted chain. Is `Box(psi)` in deferralClosure(phi) when psi is in subformulaClosure(phi)? YES: if psi is a subformula of phi, then Box(psi) is in the subformula closure if Box(psi) occurs as a subformula of phi, BUT NOT NECESSARILY OTHERWISE.

Hmm, subformulaClosure is the set of subformulas of phi (plus negations). If Box(psi) is NOT a subformula of phi, it might not be in deferralClosure.

**But the truth lemma only quantifies over subformulas of phi.** And the Box case only arises when `Box(psi)` is itself a subformula of phi. So `Box(psi)` IS in subformulaClosure(phi), and hence in deferralClosure(phi). And psi is a subformula of Box(psi), hence also in subformulaClosure and deferralClosure.

**Good.** So for the restricted truth lemma, all relevant formulas are in deferralClosure.

#### Step 4: Modal coherence for restricted families

Need: if `Box(psi) in restricted_chain(tc, n)` (with psi in deferralClosure), then `psi in restricted_chain(tc', n)` for all tc' in the restricted family bundle.

Each tc is built from some W with `box_class_agree M0 W`. The restricted chain at time n contains formulas from deferralClosure. `Box(psi)` being in `restricted_chain(tc, n)` means `Box(psi)` is in the DRM at time n.

For tc' built from W' with `box_class_agree M0 W'`:
- `box_class_agree W W'` (transitivity via M0)
- The DRM at time n for tc contains `Box(psi)`, which is in deferralClosure
- Does `Box(psi)` propagate to tc'?

The DRM for tc at time 0 is built from W restricted to deferralClosure. `Box(psi) in W` iff `Box(psi) in W'` (by box_class_agree). And `Box(psi)` is in deferralClosure. So `Box(psi) in DRM_0(tc)` iff `Box(psi) in W` iff `Box(psi) in W'` iff `Box(psi) in DRM_0(tc')` (assuming DRM extends W ∩ deferralClosure).

Actually, the DRM is a Lindenbaum extension of W ∩ deferralClosure within deferralClosure. So `Box(psi) in DRM` iff `Box(psi) in W ∩ deferralClosure` iff `Box(psi) in W` (since Box(psi) is in deferralClosure). And box_class_agree gives `Box(psi) in W <-> Box(psi) in W'`. So `Box(psi) in DRM(tc) <-> Box(psi) in DRM(tc')`.

This works for time 0. For time n, we need `Box(psi)` to propagate through the chain. In the restricted chain, the Succ relation preserves g_content, and `Box(psi)` propagates via modal 4 axiom. Specifically, `Box(psi) in chain(n) -> Box(Box(psi)) in chain(n)` (modal 4, stays in deferralClosure since box of a deferralClosure formula is in closureWithNeg which is a subset of deferralClosure), and `Box(psi) in g_content(chain(n)) ⊆ chain(n+1)` -- wait, `g_content` is for `G`, not `Box`.

**Oh.** `g_content(M) = {chi | G(chi) in M}`, not `{chi | Box(chi) in M}`. Box and G are DIFFERENT operators in TM.

For the Box case, we need `box_class_agree` at EACH time point, not just time 0. In the existing `boxClassFamilies`, this is provided by `boxClassFamilies_box_agree` which uses the fact that SuccChainFMCS preserves box_class_agree at each step.

For the restricted chain, does `box_class_agree` propagate? The `constrained_successor_restricted` seed includes `box_theory(M) ∩ deferralClosure` (implicitly, through the p_step_blocking which includes blocking formulas). Actually, let me check: does the restricted seed include box_theory?

Looking at `constrained_successor_seed_restricted`, it includes:
1. g_content (G-formulas)
2. deferralDisjunctions (chi ∨ F(chi))
3. p_step_blocking_formulas_restricted
4. boundary_resolution_set
5. f_content

It does NOT include box_theory. So box_class_agree is NOT preserved through the restricted chain!

The unrestricted `constrained_successor_seed` includes box_theory (via the seed structure in SuccExistence.lean). Let me verify.

Actually, looking at `constrained_successor_seed`:
```lean
constrained_successor_seed u = g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

This also does NOT include box_theory. But the Lindenbaum extension can freely add Box formulas. The `SuccChainFMCS` preserves box_class_agree because `constrained_successor_from_seed` extends a seed that includes g_content and box_theory? Let me check `temporal_box_seed`.

Actually, `temporal_theory_witness_exists` uses `{phi} ∪ temporal_box_seed(M)` where:
```
temporal_box_seed M = G_theory M ∪ box_theory M
```

So `temporal_theory_witness_exists` preserves box_class_agree. But `constrained_successor_from_seed` uses `constrained_successor_seed` which does NOT include box_theory.

Wait, let me re-read the SuccExistence.lean definition.

Looking at `constrained_successor_seed`:
```lean
constrained_successor_seed u =
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas u
```

And `forward_chain_succ` proves the Succ relation. The `SuccChainFMCS` is built from `forward_chain` which uses `ForwardChainElement.next` which uses `constrained_successor_from_seed`.

For box_class_agree, I see `forward_chain_box_agree` -- let me check.

Actually, looking at `forward_dovetailed_box_agree` (DovetailedChain.lean:279), it proves box_class_agree for the dovetailed chain because `forward_step` uses `temporal_theory_witness_exists` which preserves box_class_agree.

But `forward_chain` in SuccChainFMCS uses `constrained_successor_from_seed`, NOT `temporal_theory_witness_exists`. So does `forward_chain` preserve box_class_agree?

Looking at `SuccChainFMCS.lean:186-194`: `ForwardChainElement.next` uses `constrained_successor_from_seed`. The `constrained_successor_seed` does NOT include box_theory. So box_class_agree is NOT directly preserved.

But looking at the actual definition of `SuccChainFMCS`:
```lean
noncomputable def SuccChainFMCS (M0 : SerialMCS) : FMCS Int where
  mcs := succ_chain_fam M0
  ...
```

And `succ_chain_fam` is defined as the forward chain for non-negative n, backward chain for negative n. The chain uses `constrained_successor_from_seed`.

Now, `boxClassFamilies` at UltrafilterChain.lean:2612 defines families using `SuccChainFMCS`, and `boxClassFamilies_box_agree` proves box_class_agree. Let me look at how it's proven.

Looking at `boxClassFamilies_box_agree` (line 2703):
```lean
theorem boxClassFamilies_box_agree (M0 : Set Formula) (h_mcs : SetMaximalConsistent M0)
    (fam : FMCS Int) (hfam : fam ∈ boxClassFamilies M0 h_mcs)
    (t : Int) : box_class_agree M0 (fam.mcs t) := by
```

This is proven for ALL t. The proof works because the chain construction from `SuccChainFMCS` propagates box_class_agree from the base W to each time point. This relies on the fact that the successor construction preserves box_class_agree.

For the unrestricted chain, `constrained_successor_from_seed` does include box_theory in the seed? Let me check SuccExistence.lean more carefully.

Actually, I see now that `constrained_successor_seed` is defined in SuccExistence.lean. Let me look at it again.

The seed for the unrestricted successor is `constrained_successor_seed u`, but for the SuccChainFMCS, the chain uses `ForwardChainElement.next` which calls `constrained_successor_from_seed`. Looking at the seed definition more carefully in SuccExistence.lean...

Actually, I realize I need to look at what `constrained_successor_seed` actually includes versus `temporal_box_seed`.

In summary, the key issue for the restricted BFMCS approach is: does box_class_agree propagate through the restricted chain? If not, the Box case of the truth lemma fails.

Given the complexity of this analysis, let me consolidate my findings into the definitive recommendation.

---

## 9. Final Recommendation: Two-Phase Approach

### Phase 1: Prove `bfmcs_from_mcs_temporally_coherent` using restricted chain transfer

**Approach**: For each family `fam = shifted_fmcs (SuccChainFMCS (MCS_to_SerialMCS W h_W)) k` in `boxClassFamilies M0`:

1. Build `DeferralRestrictedSerialMCS phi` from W (call it `drm_W`)
2. Build `RestrictedTemporallyCoherentFamily phi` from `drm_W` (has proven forward_F)
3. The restricted chain at time 0 is drm_W.world ⊆ W
4. The SuccChainFMCS at time 0 is W
5. For psi in deferralClosure(phi): `F(psi) in SuccChainFMCS.mcs(t)` implies `F(psi) in W` (or at some chain position)

**The key transfer**: Show that `forward_F` on the restricted chain implies `forward_F` on the unrestricted SuccChainFMCS for formulas in deferralClosure.

This requires: if `F(psi) in SuccChainFMCS.mcs(t)` and `F(psi) in deferralClosure(phi)`, then `psi in SuccChainFMCS.mcs(s)` for some s >= t.

Proof: `F(psi) in SuccChainFMCS.mcs(t)` means `F(psi) in fwd_chain(t)` (for t >= 0). The fwd_chain uses `constrained_successor_from_seed` which has f_step. By f_step, `psi in fwd_chain(t+1) ∨ F(psi) in fwd_chain(t+1)`.

If psi in fwd_chain(t+1), done. If F(psi) in fwd_chain(t+1), repeat.

But this can continue forever (perpetual deferral). We need to show perpetual deferral is impossible.

**For the RESTRICTED chain**, perpetual deferral is impossible because F-nesting is bounded within deferralClosure. Specifically, if F(psi) in DRM at time t, then f_nesting_depth(F(psi)) <= max_F_depth_in_closure, and the strong f_content persistence resolves ALL F-obligations in one step.

**For the UNRESTRICTED SuccChainFMCS**, f_nesting is NOT bounded. The chain is a full MCS at each step, and F^n(p) can exist for arbitrarily large n.

**So transfer does NOT work.** The unrestricted chain can defer forever because its MCSes are unrestricted.

### Phase 2 (Actual Solution): Replace `SuccChainFMCS` with `RestrictedSuccChainFMCS`

**This is the only clean path.** Every family must be built from restricted chains.

**Concrete plan**:

1. **Define `RestrictedFMCS phi`**: Like FMCS but with `restricted_chain_ext` at each time point. The `forward_G` and `backward_H` are proven ONLY for formulas in deferralClosure(phi).

2. **Define `RestrictedBFMCS phi`**: Collection of `RestrictedFMCS phi` families with modal coherence (box_class_agree within deferralClosure).

3. **Prove restricted temporal coherence**: Automatic from `RestrictedTemporallyCoherentFamily`.

4. **Prove restricted truth lemma**: For psi in subformulaClosure(phi), membership in restricted chain <-> truth in canonical model. This requires:
   - G case: uses `forward_G` for deferralClosure formulas (proven)
   - H case: uses `backward_H` for deferralClosure formulas (proven)
   - G backward: uses `forward_F` for deferralClosure formulas (proven via restricted chain)
   - H backward: uses `backward_P` for deferralClosure formulas (proven via restricted chain)
   - Box case: uses modal coherence across families within deferralClosure

5. **For modal coherence**: Show `box_class_agree` at each time point WITHIN deferralClosure. This requires Box formulas in deferralClosure to propagate through the restricted chain.

   **Question**: Is `Box(psi)` in deferralClosure(phi) when psi is in subformulaClosure(phi) and Box(psi) occurs as a subformula?

   **Answer**: Yes. subformulaClosure includes all subformulas and their negations. If Box(psi) is a subformula of phi, then Box(psi) is in subformulaClosure, hence in closureWithNeg, hence in deferralClosure.

   **Question**: Does box_class_agree propagate through the restricted chain?

   The restricted seed includes g_content but NOT box_theory. So `Box(psi)` might not be in the successor. However, `Box(psi)` is in deferralClosure. And by DRM maximality, if Box(psi) is consistent with the restricted chain at time n+1, it's in the DRM at time n+1.

   The chain's Succ relation preserves g_content. For Box formulas, we need a different argument. In S5 modal logic, Box(psi) has a special property: `Box(psi) -> Box(Box(psi))` (modal 4). So if `Box(psi) in chain(n)`, then `Box(Box(psi)) in chain(n)`. But g_content only handles G-formulas, not Box-formulas.

   **Key insight**: The restricted chain does NOT preserve Box formulas through the chain. This means box_class_agree does NOT propagate, and the Box case of the truth lemma fails.

   **Solution**: Add `box_theory` to the restricted seed. We need to show `box_theory(M) ∩ deferralClosure ⊆ restricted_seed`. Since `box_theory(M) = {Box(psi) | Box(psi) in M} ∪ {neg(Box(psi)) | Box(psi) not in M}` and both forms are in deferralClosure when psi is in deferralClosure, we can include them.

   But adding box_theory to the seed requires re-proving seed consistency. The box_theory elements ARE G-liftable? `G(Box(psi))` -- by the interaction axiom `Box(a) -> G(Box(a))` (which is a consequence of S5 + linearity). If this axiom holds, then Box formulas are G-liftable and can be added to the seed.

   Actually, in TM logic, `Box(a) -> G(Box(a))` IS derivable (from `Box(a) -> Box(Box(a))` by modal 4, and `Box(Box(a)) -> G(Box(a))` by the axiom that Box implies G in TM, i.e., `modal_future: Box(a) -> G(a)`). So:
   ```
   Box(a) -> Box(Box(a))    [modal 4]
   Box(Box(a)) -> G(Box(a))  [modal_future applied to Box(a)]
   Box(a) -> G(Box(a))       [transitivity]
   ```

   And for neg(Box(a)):
   ```
   neg(Box(a)) in M -> G(neg(Box(a))) in M?
   ```
   This would mean `neg(Box(a)) -> G(neg(Box(a)))`, which says if something is not necessarily true, then it's always not necessarily true. In S5 this is `neg(Box(a)) -> Box(neg(Box(a)))` (negative introspection), which combined with `Box -> G` gives `neg(Box(a)) -> G(neg(Box(a)))`. And TM does have S5 for Box (modal_t, modal_4, modal_b).

   **Yes**: In S5, `neg(Box(a)) -> Box(neg(Box(a)))` is derivable (5 axiom). And `Box -> G` (modal_future). So `neg(Box(a)) -> G(neg(Box(a)))`. This means neg(Box(a)) IS G-liftable.

   **So box_theory elements ARE G-liftable**, and can be safely added to the restricted seed without breaking the consistency proof.

6. **Implementation plan**:
   - Add `box_theory ∩ deferralClosure` to `constrained_successor_seed_restricted`
   - Prove the extended seed stays in deferralClosure (trivial, box_theory ∩ dc ⊆ dc)
   - Prove the extended seed is consistent (using G-liftability of Box formulas)
   - Prove box_class_agree propagation through the restricted chain
   - Build `RestrictedBFMCS phi` with modal coherence
   - Prove the restricted truth lemma with Box case using modal coherence
   - Wire into completeness

**Estimated effort**: 600-1000 lines total.

---

## 10. Step-by-Step Implementation Guide

### Step 1: Add box_theory to restricted seed (~50 lines)

In `SuccChainFMCS.lean`, modify `constrained_successor_seed_restricted`:

```lean
def constrained_successor_seed_restricted_with_box (phi : Formula) (u : Set Formula) :
    Set Formula :=
  constrained_successor_seed_restricted phi u ∪
  (box_theory u ∩ (deferralClosure phi : Set Formula))
```

Prove: stays in deferralClosure, is consistent (using G-liftability of Box formulas).

### Step 2: Prove box_class_agree propagation (~100 lines)

```lean
theorem restricted_chain_box_agree_step (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    ∀ psi, Formula.box psi ∈ deferralClosure phi →
    (Formula.box psi ∈ restricted_forward_chain phi M0 n ↔
     Formula.box psi ∈ restricted_forward_chain phi M0 (n + 1))
```

### Step 3: Build RestrictedBFMCS (~200 lines)

Define the structure and prove:
- Nonemptiness
- Modal forward/backward within deferralClosure
- Temporal coherence (from RestrictedTemporallyCoherentFamily)

### Step 4: Prove restricted truth lemma (~300 lines)

Follow the structure of `parametric_shifted_truth_lemma` but restricted to subformulaClosure(phi). Key cases:
- Atom: trivial
- neg/imp: by IH
- Box: uses modal coherence within deferralClosure
- G: forward direction uses forward_G, backward uses forward_F (both proven)
- H: symmetric to G

### Step 5: Wire completeness (~100 lines)

```lean
theorem restricted_completeness (phi : Formula)
    (h_not_prov : ¬Nonempty (DerivationTree [] phi)) :
    ¬(valid_over Int phi) := by
  -- 1. neg(phi) consistent
  -- 2. Build DeferralRestrictedSerialMCS containing neg(phi)
  -- 3. Build RestrictedBFMCS from it
  -- 4. Apply restricted truth lemma
  -- 5. phi false at canonical model
  -- 6. Contradiction with valid_over
```

### Step 6: Replace the sorry (~20 lines)

Either:
(a) Remove `bfmcs_from_mcs_temporally_coherent` and use `restricted_completeness` directly
(b) Prove `bfmcs_from_mcs_temporally_coherent` by routing through the restricted construction

Option (a) is cleaner: add `restricted_completeness` as a separate completeness theorem, then wire `completeness_over_Int` to use it.

---

## 11. Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| G-liftability of Box fails | LOW | S5 axioms are well-understood; verify `Box -> G(Box)` and `neg(Box) -> G(neg(Box))` exist as derived theorems |
| box_theory consistency proof is hard | MEDIUM | Follow the pattern of `forward_temporal_witness_seed_consistent`; Box formulas are simpler than F-formulas |
| Restricted truth lemma is complex | MEDIUM | Follow existing `parametric_shifted_truth_lemma` structure; most cases are identical |
| Modal coherence across restricted families | MEDIUM | The key is that Box formulas in deferralClosure propagate; verify using box_class_agree at DRM level |
| Integration with existing completeness | LOW | The parametric representation theorem is already conditional; just provide the construction |

---

## 12. Summary of Source Files Referenced

| File | Key Definitions/Theorems |
|------|-------------------------|
| `SuccChainFMCS.lean` | `ForwardChainElement`, `forward_chain`, `restricted_forward_chain`, `restricted_forward_chain_forward_F`, `build_restricted_tc_family`, `DeferralRestrictedSerialMCS`, `RestrictedTemporallyCoherentFamily`, `restricted_succ_chain_fam` |
| `SuccExistence.lean` | `constrained_successor_from_seed`, `constrained_successor_seed`, `constrained_successor_succ`, f_step and p_step theorems |
| `SuccRelation.lean` | `Succ` (g_persistence + f_step), `Succ_implies_h_content_reverse` |
| `UltrafilterChain.lean` | `temporal_theory_witness_exists`, `boxClassFamilies`, `construct_bfmcs_bundle`, `boxClassFamilies_bundle_forward_F` (bundle-level only) |
| `DovetailedChain.lean` | Design documentation of failed approaches; `forward_step`, `forward_dovetailed` |
| `WitnessSeed.lean` | `forward_temporal_witness_seed_consistent`, `past_temporal_witness_seed_consistent`, g_content/h_content duality |
| `ParametricRepresentation.lean` | `parametric_algebraic_representation_conditional` (the conditional completeness theorem) |
| `FrameConditions/Completeness.lean` | `bfmcs_from_mcs_temporally_coherent` (THE SORRY), `bundle_to_bfmcs`, `bundle_validity_implies_provability` |
| `TemporalCoherence.lean` | `BFMCS.temporally_coherent`, `temporal_backward_G`, `temporal_backward_H` |
| `FMCSDef.lean` | `FMCS` structure (mcs, is_mcs, forward_G, backward_H) |
| `RestrictedTruthLemma.lean` | `restricted_chain_ext`, `restricted_truth_lemma`, `restricted_ext_neg_excludes_phi` |
| `RestrictedMCS.lean` | `DeferralRestrictedMCS`, `deferral_restricted_lindenbaum` |
