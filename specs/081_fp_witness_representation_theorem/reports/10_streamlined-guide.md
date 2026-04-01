# Report 10: Streamlined Implementation Guide

**Task**: 81 -- F/P Witness Representation Theorem
**Date**: 2026-04-01
**Type**: Verified implementation roadmap (source-verified 2026-04-01)

---

## Goal

Close the sorry in `Theories/Bimodal/FrameConditions/Completeness.lean:237`:

```lean
theorem bfmcs_from_mcs_temporally_coherent (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    (bundle_to_bfmcs (construct_bfmcs_bundle M h_mcs)).temporally_coherent := by
  sorry
```

This blocks `completeness_over_Int` (line 305) and `discrete_completeness_fc` (line 324).

---

## Verified Dependency Map

Verified by reading source files 2026-04-01. All line numbers are current.

### The Completeness Chain

```
completeness_over_Int (FrameConditions/Completeness.lean:305)
  -> bundle_validity_implies_provability (line 261)
    -> bfmcs_from_mcs_temporally_coherent (line 231, SORRY)
    -> shifted_truth_lemma (sorry-free, requires B.temporally_coherent)
    -> construct_bfmcs_bundle (UltrafilterChain.lean:3540, sorry-free)
    -> not_provable_implies_neg_consistent (sorry-free)
```

### What `temporally_coherent` Requires (TemporalCoherence.lean:218)

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s >= t, phi in fam.mcs s) /\
    (forall t phi, P(phi) in fam.mcs t -> exists s <= t, phi in fam.mcs s)
```

This is SAME-FAMILY coherence. The existing `BundleTemporallyCoherent` (UltrafilterChain.lean:3241) provides CROSS-FAMILY coherence (witness in any family), which is sorry-free.

### The Gap

Each family in `boxClassFamilies` is `shifted_fmcs (SuccChainFMCS S) k`. The `SuccChainFMCS` uses `constrained_successor_from_seed` (SuccExistence.lean, sorry-free) which provides f_step (resolve-or-defer). But perpetual deferral is not ruled out for the unrestricted chain, so forward_F is unproven.

---

## Sorry Inventory (Verified)

### Blocking Sorry

| File | Line | Theorem |
|------|------|---------|
| `FrameConditions/Completeness.lean` | 237 | `bfmcs_from_mcs_temporally_coherent` |

### Restricted Chain Sorries

| File | Line | Theorem | Impact |
|------|------|---------|--------|
| `Bundle/SuccChainFMCS.lean` | 1734 | `g_content_union_brs_consistent` | Restricted seed consistency |
| `Bundle/SuccChainFMCS.lean` | 1763 | `augmented_seed_consistent` | Restricted seed consistency |
| `Bundle/SuccChainFMCS.lean` | 2082 | `constrained_successor_seed_restricted_consistent` | **Key gap**: restricted seed consistency |
| `Bundle/SuccChainFMCS.lean` | 5386 | `restricted_forward_bounded_witness_fueled` fuel=0 | Semantically unreachable |
| `Bundle/SuccChainFMCS.lean` | 5544 | `restricted_backward_bounded_witness_fueled` fuel=0 | Semantically unreachable |
| `Bundle/SuccChainFMCS.lean` | 5740 | cross-chain P witness fuel=0 | Semantically unreachable |

### CRITICAL CORRECTION: The restricted chain is NOT sorry-free.

Report 09 claims `restricted_forward_chain_forward_F` (line 2930) is sorry-free. **This is wrong.** The chain:

```
restricted_forward_chain_forward_F (2930)
  -> restricted_forward_chain_F_resolves (2783)
    -> constrained_successor_restricted_f_content_persistence (2153)
      -> constrained_successor_restricted_extends (2110)
        -> constrained_successor_restricted (2100)
          -> constrained_successor_seed_restricted_consistent (2082, SORRY)
```

The entire restricted chain construction depends on `constrained_successor_seed_restricted_consistent` (S2), whose proof is incomplete.

### Other Sorries (non-blocking for this task)

| File | Line | Theorem |
|------|------|---------|
| `Bundle/CanonicalConstruction.lean` | 889, 893 | `restricted_tc_family_to_fmcs` forward_G/backward_H |
| `Algebraic/RestrictedTruthLemma.lean` | 116, 158 | G/H propagation through DRM chain |
| `FrameConditions/Completeness.lean` | ~390 | `dense_completeness_fc` (separate issue) |

---

## What Exists (Sorry-Free, Verified)

| Component | File:Line | What it provides |
|-----------|-----------|-----------------|
| `forward_temporal_witness_seed_consistent` | WitnessSeed.lean:79 | `{psi} ∪ g_content(M)` consistent when `F(psi) in M` |
| `temporal_theory_witness_exists` | UltrafilterChain.lean:2212 | MCS W with `psi in W`, G-agree, box_class_agree |
| `past_theory_witness_exists` | UltrafilterChain.lean:2439 | Symmetric P-direction |
| `forward_step` | DovetailedChain.lean:66 | Single dovetailed step, resolves targeted F-obligation |
| `forward_dovetailed` | DovetailedChain.lean:146 | Full chain with `forward_G`, `backward_H`, `box_class_agree` |
| `construct_bfmcs_bundle` | UltrafilterChain.lean:3540 | BFMCS_Bundle with bundle-level temporal coherence |
| `constrained_successor_from_seed` | SuccExistence.lean:519 | Unrestricted successor with Succ relation |
| `parametric_algebraic_representation_conditional` | ParametricRepresentation.lean:252 | Completeness conditional on `construct_bfmcs` |
| `not_provable_implies_neg_set_consistent` | ParametricRepresentation.lean:113 | Non-provability gives consistency of neg |
| `deferral_restricted_lindenbaum` | RestrictedMCS.lean | Lindenbaum within deferralClosure |
| `restricted_truth_lemma` | RestrictedTruthLemma.lean:291 | DRM membership iff extended chain membership for subformulaClosure |
| `restricted_ext_neg_excludes_phi` | RestrictedTruthLemma.lean:381 | neg(phi) in seed implies phi not in ext(0) |

**Missing from DovetailedChain.lean**: `dovetailed_fmcs` and `construct_bfmcs_int` (declared in header, never implemented). The file is design analysis only beyond the `forward_dovetailed` chain and its properties.

---

## The Correct Path

### Architecture

Build a self-contained completeness proof that bypasses `bfmcs_from_mcs_temporally_coherent` entirely, using a simplified restricted chain with trivially consistent seed, multi-step forward_F via bounded F-nesting, and a restricted truth lemma for the target formula.

### Why This Path

1. The restricted seed consistency (S2) is the mathematical bottleneck -- the BRS and f_content elements break the G-lift argument.
2. A simplified seed without BRS/f_content is trivially consistent (all elements in u).
3. The weak f_step (resolve-or-defer from deferralDisjunctions alone) still holds.
4. Bounded F-nesting within deferralClosure guarantees resolution in finitely many steps.
5. The truth lemma only needs forward_G/backward_H for subformulaClosure formulas (within deferralClosure).

---

## Step-by-Step Implementation

### Step 1: Simplified Restricted Seed and Successor

**File**: `Theories/Bimodal/Metalogic/Bundle/SuccChainFMCS.lean` (new section) or new file

**Depends on**: `DeferralRestrictedMCS` (RestrictedMCS.lean), `g_content`/`deferralDisjunctions`/`p_step_blocking_formulas_restricted` (SuccExistence.lean)

**Define**:
```lean
def simplified_restricted_seed (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u
```

**Prove**:
```lean
-- Trivially consistent: all elements are in u
theorem simplified_restricted_seed_consistent (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    SetConsistent (simplified_restricted_seed phi u)

-- Stays within deferralClosure
theorem simplified_restricted_seed_subset_dc (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u) :
    simplified_restricted_seed phi u ⊆ deferralClosure phi
```

**Proof strategy for consistency**: Every element of the simplified seed is in u (by `g_content_subset_deferral_restricted_mcs`, `deferralDisjunctions_subset_deferral_restricted_mcs`, `p_step_blocking_restricted_subset`). Since the seed is a subset of u and u is consistent, the seed is consistent.

**Define the successor**:
```lean
noncomputable def simplified_successor_restricted (phi : Formula) (u : Set Formula)
    (h_drm : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) : Set Formula :=
  (deferral_restricted_lindenbaum phi
    (simplified_restricted_seed phi u)
    (simplified_restricted_seed_subset_dc phi u h_drm)
    (simplified_restricted_seed_consistent phi u h_drm)).choose
```

**Properties to prove**:
```lean
-- Successor is a DRM
theorem simplified_successor_is_drm ...

-- G-persistence: g_content(u) ⊆ successor
theorem simplified_successor_g_persistence ...

-- Weak f_step: f_content(u) ⊆ successor ∪ f_content(successor)
-- (from deferralDisjunctions in seed + DRM maximality)
theorem simplified_successor_f_step ...

-- P-step blocking
theorem simplified_successor_p_step ...

-- F_top preservation
theorem simplified_successor_has_F_top ...
```

**Estimated lines**: ~150

### Step 2: Build Simplified Restricted Chain

**File**: Same as Step 1

**Depends on**: Step 1

**Define**:
```lean
noncomputable def simplified_forward_chain (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) : Nat -> Set Formula
  | 0 => M0.world
  | n + 1 => simplified_successor_restricted phi
      (simplified_forward_chain phi M0 n)
      (simplified_forward_chain_is_drm phi M0 n)
      (simplified_forward_chain_has_F_top phi M0 n)
```

**Properties to prove**:
```lean
-- Each element is a DRM
theorem simplified_forward_chain_is_drm ...

-- Succ relation between adjacent elements
theorem simplified_forward_chain_succ ...

-- G-persistence through chain
theorem simplified_forward_chain_g_persistence ...

-- Weak f_step through chain
theorem simplified_forward_chain_f_step ...

-- F_top preservation
theorem simplified_forward_chain_has_F_top ...
```

**Estimated lines**: ~100

### Step 3: Prove forward_F via Bounded F-Nesting

**File**: Same as Step 1

**Depends on**: Step 2, `f_nesting_is_bounded_restricted` (SuccChainFMCS.lean, for DRMs)

**Key theorem**:
```lean
theorem simplified_forward_chain_forward_F (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) (psi : Formula)
    (h_F : Formula.some_future psi ∈ simplified_forward_chain phi M0 n) :
    ∃ m : Nat, n < m ∧ psi ∈ simplified_forward_chain phi M0 m
```

**Proof strategy**: By the weak f_step, `F(psi) in chain(n)` implies either `psi in chain(n+1)` (done) or `F(psi) in chain(n+1)`. By DRM properties, the F-nesting depth of `F(psi)` within deferralClosure is bounded by `closure_F_bound phi`. At each step where deferral occurs, the F-nesting decreases (or stays the same). Within at most `closure_F_bound phi` steps, the obligation must resolve because F^B(psi) cannot be in the DRM chain when B exceeds the bound.

Formally: by well-founded induction on F-nesting depth within deferralClosure. If `F(psi) in chain(n)`, find the boundary depth d such that `iter_F d psi in chain(n)` but `iter_F (d+1) psi not in chain(n)`. The deferral disjunction for the boundary formula resolves to the inner formula (since F of it is outside deferralClosure). This gives resolution at depth d-1, and by induction resolution at depth 0.

**Note**: This proof parallels the existing `restricted_forward_bounded_witness_fueled` (SuccChainFMCS.lean:5300+) but avoids the sorry-bearing seed.

**Estimated lines**: ~200

### Step 4: Symmetric backward_P

**File**: Same as Step 1

**Depends on**: Step 1 (symmetric construction for backward chain)

Build `simplified_backward_chain` and prove `simplified_backward_chain_backward_P`. The construction mirrors the forward chain using `h_content`/`deferralDisjunctions` for P-obligations.

**Estimated lines**: ~200

### Step 5: Combined Chain and Temporal Coherence

**File**: Same as Step 1

**Depends on**: Steps 2-4

**Define**:
```lean
-- Combined forward/backward chain indexed by Int
noncomputable def simplified_succ_chain_fam (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) : Int -> Set Formula
  | Int.ofNat n => simplified_forward_chain phi M0 n
  | Int.negSucc n => simplified_backward_chain phi M0 (n + 1)

-- Temporal coherence structure
structure SimplifiedTemporallyCoherentFamily (phi : Formula) where
  seed : DeferralRestrictedSerialMCS phi
  forward_F : forall n psi, F(psi) in chain(n) -> exists m > n, psi in chain(m)
  backward_P : forall n psi, P(psi) in chain(n) -> exists m < n, psi in chain(m)

noncomputable def build_simplified_tc_family (phi : Formula)
    (seed : DeferralRestrictedSerialMCS phi) : SimplifiedTemporallyCoherentFamily phi
```

**Estimated lines**: ~100

### Step 6: Add box_theory to Seed for Modal Coherence

**File**: Modify Step 1 definitions

**Depends on**: Steps 1-5, S5 axioms for Box

**Why needed**: The truth lemma's Box case requires box_class_agree at each time point. Box formulas must propagate through the chain. The current simplified seed does NOT include box_theory.

**Key insight**: Box formulas are G-liftable in TM:
- `Box(a) -> Box(Box(a))` (modal 4)
- `Box(Box(a)) -> G(Box(a))` (modal_future applied to Box(a))
- Therefore `Box(a) -> G(Box(a))`, so `G(Box(a)) in M` when `Box(a) in M`.
- `neg(Box(a)) -> Box(neg(Box(a)))` (S5 negative introspection)
- `Box(neg(Box(a))) -> G(neg(Box(a)))` (modal_future)
- Therefore `G(neg(Box(a))) in M` when `neg(Box(a)) in M`.

**Modify seed**:
```lean
def simplified_restricted_seed_with_box (phi : Formula) (u : Set Formula) : Set Formula :=
  g_content u ∪ deferralDisjunctions u ∪ p_step_blocking_formulas_restricted phi u ∪
  (box_theory u ∩ deferralClosure phi)
```

**Prove consistency**: All elements of `g_content ∪ deferralDisjunctions ∪ p_step_blocking` are in u (proven). For `box_theory ∩ deferralClosure`: `Box(a) in u` implies `Box(a)` is in box_theory and (if in deferralClosure) in the seed. `Box(a)` IS G-liftable (proven above), so the G-lift consistency argument extends to include these elements.

Formally: suppose `L ⊆ seed, L ⊢ bot`. Every element x of L has `G(x) in M` (for g_content: by definition; for deferralDisjunctions: by `G(chi ∨ F(chi))` derivable when `G(chi) in M`... wait, this is NOT automatic for deferralDisjunctions).

**Problem**: deferralDisjunctions `(chi ∨ F(chi))` are NOT G-liftable. But they ARE in u. So the consistency argument for the simplified seed is simply "seed ⊆ u and u is consistent", not the G-lift argument.

For box_theory elements in the seed that are NOT in u: this cannot happen because box_theory elements Box(a) satisfy either `Box(a) in u` or `neg(Box(a)) in u` (by MCS negation completeness of the DRM for formulas in deferralClosure). box_theory includes BOTH forms. Since the DRM already contains one of `Box(a)` or `neg(Box(a))`, the element from box_theory that is in the seed IS in u (because box_theory = {Box(a) | Box(a) in M} union {neg(Box(a)) | neg(Box(a)) in M}, so by definition every element of box_theory(u) is already in u).

Wait -- let me check the definition of box_theory:

```lean
def box_theory (M : Set Formula) : Set Formula :=
  {phi | ∃ a, phi = Formula.box a ∧ Formula.box a ∈ M}
```

So `box_theory(M) = {Box(a) | Box(a) in M}`, which is a SUBSET of M. So `box_theory(u) ⊆ u`. No new elements, trivially consistent.

**But for propagation**: we need `box_theory(u) ⊆ successor` so Box formulas persist. Since `Box(a) in u` implies `G(Box(a)) in u` (by the G-liftability proven above), and `G(Box(a)) in u` means `Box(a) in g_content(u) ⊆ successor`, we get `box_theory(u) ⊆ successor` automatically from g_content. No seed modification needed.

**Correction**: Box propagation follows from g_content propagation plus `Box(a) -> G(Box(a))`. No seed change required. Box_class_agree propagates through the simplified chain via g_content.

**Prove**:
```lean
theorem simplified_forward_chain_box_agree (phi : Formula)
    (M0 : DeferralRestrictedSerialMCS phi) (n : Nat) :
    forall a, Formula.box a ∈ simplified_forward_chain phi M0 0 ->
              Formula.box a ∈ simplified_forward_chain phi M0 n
```

**Proof**: `Box(a) in chain(0)` implies `G(Box(a)) in chain(0)` (by `Box -> G(Box)` derivable in TM, plus DRM closure). Then `Box(a) in g_content(chain(0)) ⊆ chain(1)`. Iterate.

For the FULL box_class_agree (involving neg(Box(a)) too): `neg(Box(a)) in chain(0)` implies `G(neg(Box(a))) in chain(0)` (by S5 negative introspection + modal_future). Then `neg(Box(a)) in g_content(chain(0)) ⊆ chain(1)`. Iterate.

**Key prerequisite**: Prove `Box(a) -> G(Box(a))` and `neg(Box(a)) -> G(neg(Box(a)))` as derived theorems. These follow from the existing axioms: modal_4, modal_b (or 5), modal_future.

**Estimated lines**: ~100

### Step 7: Build Restricted Family Bundle

**File**: New file `Theories/Bimodal/Metalogic/Algebraic/RestrictedCompleteness.lean`

**Depends on**: Steps 1-6

For a target formula phi and base MCS M0:

1. For each W with box_class_agree(M0, W), build DRM from W:
   - `W ∩ deferralClosure(phi)` is consistent (subset of consistent W)
   - Extend to DRM via `deferral_restricted_lindenbaum`
   - Prove DRM contains F_top and P_top (derivable theorems in deferralClosure)

2. Build `SimplifiedTemporallyCoherentFamily phi` from each DRM.

3. Lindenbaum-extend each chain element to a full MCS.

4. Define a restricted BFMCS-like structure:

```lean
structure RestrictedBFMCS (phi : Formula) where
  families : Set (SimplifiedTemporallyCoherentFamily phi)
  nonempty : families.Nonempty
  -- Modal coherence within deferralClosure at each time point
  modal_forward_dc : forall tc in families, forall tc' in families, forall t psi,
    psi ∈ deferralClosure phi ->
    Formula.box psi ∈ chain(tc, t) -> psi ∈ chain(tc', t)
  modal_backward_dc : forall tc in families, forall t psi,
    psi ∈ deferralClosure phi ->
    (forall tc' in families, psi ∈ chain(tc', t)) -> Formula.box psi ∈ chain(tc, t)
```

**Estimated lines**: ~200

### Step 8: Restricted Truth Lemma

**File**: Same as Step 7

**Depends on**: Steps 5-7

**The restricted truth lemma**: For psi in subformulaClosure(phi):

```lean
theorem restricted_truth_lemma_semantic (phi : Formula)
    (rbfmcs : RestrictedBFMCS phi)
    (tc : SimplifiedTemporallyCoherentFamily phi)
    (h_tc : tc ∈ rbfmcs.families)
    (t : Int) (psi : Formula)
    (h_sub : psi ∈ subformulaClosure phi) :
    psi ∈ simplified_succ_chain_fam phi tc.seed t ↔
    truth_at model Omega (to_restricted_history tc) t psi
```

**Cases**:
- **Atom**: by canonical valuation definition
- **neg/imp**: by IH (subformulas of phi are in subformulaClosure)
- **Box(psi)**: Box(psi) in subformulaClosure means Box(psi) is a subformula of phi, so both Box(psi) and psi are in deferralClosure. Forward: Box(psi) in chain(tc, t) implies psi in chain(tc', t) for all tc' (by modal_forward_dc). By IH: truth_at ... t psi at all histories. By Box semantics: truth_at ... t (Box psi). Backward: symmetric via modal_backward_dc.
- **G(psi)**: Forward: G(psi) in chain(tc, t) implies psi in chain(tc, t') for all t' >= t (by g_content propagation + T-axiom). By IH: truth at all t'. By G semantics: truth G(psi). Backward: If psi true at all t' >= t, then psi in chain at all t' >= t (by IH). If G(psi) not in chain(t), then F(neg psi) in chain(t) (by DRM negation completeness for deferralClosure formulas). By forward_F: neg(psi) in chain(s) for some s >= t. But psi in chain(s) (from hypothesis). Contradiction with DRM consistency.
- **H(psi)**: Symmetric to G using backward_P and backward_H from the chain.

**Estimated lines**: ~400

### Step 9: Completeness Theorem

**File**: Same as Step 7

**Depends on**: Steps 7-8

```lean
theorem restricted_completeness (phi : Formula)
    (h_valid : valid_over Int phi) :
    Nonempty (DerivationTree [] phi) := by
  by_contra h_not_prov
  -- 1. neg(phi) is consistent
  have h_neg_cons := not_provable_implies_neg_set_consistent phi h_not_prov
  -- 2. Extend to MCS M0 with neg(phi) in M0
  obtain ⟨M0, h_mcs, h_neg_in⟩ := not_provable_implies_neg_extends_to_mcs phi h_not_prov
  -- 3. Build DRM from M0
  -- 4. Build SimplifiedTemporallyCoherentFamily
  -- 5. Build RestrictedBFMCS
  -- 6. By restricted truth lemma: neg(phi) in chain(0) iff truth_at ... neg(phi)
  -- 7. neg(phi) in chain(0) (by construction)
  -- 8. So neg(phi) true at model, hence phi false at model
  -- 9. Contradiction with h_valid
  sorry -- filled in by implementation
```

**Estimated lines**: ~100

### Step 10: Wire to Existing Infrastructure

**File**: `Theories/Bimodal/FrameConditions/Completeness.lean`

**Depends on**: Step 9

Replace the sorry in `bfmcs_from_mcs_temporally_coherent` by routing through `restricted_completeness`, OR (cleaner) replace `completeness_over_Int` to call `restricted_completeness` directly.

```lean
theorem completeness_over_Int {phi : Formula} :
    CompletenessOverIntStatement phi := by
  intro h_valid
  exact restricted_completeness phi h_valid
```

**Estimated lines**: ~20

---

## Summary

| Step | Lines | Description |
|------|-------|-------------|
| 1 | ~150 | Simplified restricted seed (trivially consistent) and successor |
| 2 | ~100 | Forward chain construction |
| 3 | ~200 | Forward_F via bounded F-nesting induction |
| 4 | ~200 | Backward chain + backward_P |
| 5 | ~100 | Combined Int-indexed chain + temporal coherence structure |
| 6 | ~100 | Box_class_agree propagation (via `Box -> G(Box)` derived theorem) |
| 7 | ~200 | RestrictedBFMCS construction |
| 8 | ~400 | Restricted truth lemma |
| 9 | ~100 | Completeness theorem |
| 10 | ~20 | Wire to existing infrastructure |
| **Total** | **~1570** | |

---

## Prerequisites to Verify Before Starting

Before implementation, confirm these derived theorems exist or can be proven:

1. **`Box(a) -> G(Box(a))`**: From modal_4 (`Box(a) -> Box(Box(a))`) and modal_future (`Box(a) -> G(a)` applied to Box(a)).

2. **`neg(Box(a)) -> G(neg(Box(a)))`**: From S5 negative introspection (`neg(Box(a)) -> Box(neg(Box(a)))`) and modal_future.

3. **Weak f_step from deferralDisjunctions alone**: If chi or F(chi) is in the DRM successor (from deferralDisjunction in seed), and the successor is a DRM, then either chi is in successor (resolved) or F(chi) is in successor (deferred).

4. **F-nesting boundedness for DRMs**: `f_nesting_is_bounded_restricted` exists and is sorry-free.

5. **DRM closure under derivation within deferralClosure**: `theorem_in_drm` or similar exists.

---

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Weak f_step insufficient for bounded forward_F | LOW | The bounded F-nesting argument is the mathematical basis for the restricted chain; it works with resolve-or-defer |
| Box propagation needs axioms not yet formalized | MEDIUM | Check `Box -> G(Box)` derivability; may need new derived theorem (~20 lines) |
| Restricted truth lemma G-backward case fails | LOW | Only needs forward_F for deferralClosure formulas, which Phase 3 provides |
| Modal coherence across restricted families | MEDIUM | Needs box_class_agree at each time point within deferralClosure; relies on box propagation from Step 6 |
| Integration with canonical model infrastructure | MEDIUM | May need to define a restricted canonical TaskFrame/TaskModel; follow existing patterns in ParametricCanonical.lean |
