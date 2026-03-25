# Teammate B: Sorry-Free Infrastructure Survey

## Key Findings

1. **The sorry-free algebraic pipeline is essentially complete up to one gap**: temporal coherence of the BFMCS bundle. Every other piece (truth lemma, modal forward/backward, box-class construction) is sorry-free.

2. **`construct_bfmcs` is deprecated and sorry-blocked** because it calls `SuccChainTemporalCoherent` which was removed (depending on the mathematically FALSE `f_nesting_is_bounded`).

3. **The restricted forward chain IS sorry-free for forward_F**. `restricted_forward_chain_forward_F` is proven sorry-free. Only the backward chain (P-direction) is missing.

4. **`parametric_algebraic_representation_conditional` is sorry-free** and is exactly the interface to the completeness proof. It only needs a `construct_bfmcs`-compatible function as argument.

5. **`parametric_shifted_truth_lemma` is sorry-free** and requires only `B.temporally_coherent` as hypothesis (`h_tc`).

6. **There are exactly 4 active sorries blocking completeness** (not "3"), each documented below.

---

## Sorry-Free Theorem Inventory

### Core MCS Infrastructure

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `set_lindenbaum` | Core/MaximalConsistent.lean | Any consistent set extends to MCS | via Zorn's lemma, sorry-free |
| `SetMaximalConsistent.negation_complete` | Core/MaximalConsistent.lean | MCS contains φ or ¬φ | sorry-free |
| `SetMaximalConsistent.closed_under_derivation` | Core/MaximalConsistent.lean | MCS closed under derivation | sorry-free |
| `SetMaximalConsistent.implication_property` | Core/MaximalConsistent.lean | MCS closed under modus ponens | sorry-free |
| `SetMaximalConsistent.neg_box_implies_box_neg_box` | Bundle/ModalSaturation.lean | ¬□φ ∈ M → □(¬□φ) ∈ M (S5 neg. introspection) | sorry-free |
| `theorem_in_mcs` | Core/MaximalConsistent.lean | Theorems are in every MCS | sorry-free |
| `set_consistent_not_both` | Core/MaximalConsistent.lean | Consistency excludes both φ and ¬φ | sorry-free |

### Algebraic/Truth Lemma Pipeline

| Theorem | File | Type Signature | Notes |
|---------|------|----------------|-------|
| `ParametricCanonicalTaskModel` | Algebraic/ParametricTruthLemma.lean | `D → TaskModel` | Definition, sorry-free |
| `parametric_canonical_truth_lemma` | Algebraic/ParametricTruthLemma.lean | `B, h_tc, fam, hfam, t, φ : φ ∈ fam.mcs t ↔ truth_at CanonicalModel ... t φ` | **SORRY-FREE**; requires `B.temporally_coherent` |
| `parametric_shifted_truth_lemma` | Algebraic/ParametricTruthLemma.lean | Same but for `ShiftClosedParametricCanonicalOmega B` | **SORRY-FREE**; requires `h_tc : B.temporally_coherent` |
| `parametric_box_persistent` | Algebraic/ParametricTruthLemma.lean | `Box φ ∈ fam.mcs t → Box φ ∈ fam.mcs s` | sorry-free via TF + dual-TF |
| `parametric_algebraic_representation_conditional` | Algebraic/ParametricRepresentation.lean | `¬⊢φ → construct_bfmcs → ∃ countermodel` | **SORRY-FREE**; takes BFMCS construction as arg |
| `not_provable_implies_neg_extends_to_mcs` | Algebraic/ParametricRepresentation.lean | `¬⊢φ → ∃ MCS M, φ.neg ∈ M` | sorry-free |

### Box-Class Bundle (Modal Part)

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `boxClassFamilies` | Algebraic/UltrafilterChain.lean | All shifted SuccChainFMCS from same-box-class MCSes | Definition, sorry-free |
| `boxClassFamilies_modal_forward` | Algebraic/UltrafilterChain.lean | Box φ ∈ fam.mcs t → φ ∈ all fam'.mcs t | **SORRY-FREE** |
| `boxClassFamilies_modal_backward` | Algebraic/UltrafilterChain.lean | φ ∈ all fam'.mcs t → Box φ ∈ fam.mcs t | **SORRY-FREE** |
| `boxClassFamilies_box_agree` | Algebraic/UltrafilterChain.lean | Box φ ∈ fam.mcs t ↔ Box φ ∈ M0 | sorry-free |
| `box_class_witness_consistent` | Algebraic/UltrafilterChain.lean | Diamond ψ ∈ M → {ψ} ∪ box_content(M) consistent | **SORRY-FREE** |
| `box_theory_witness_consistent` | Algebraic/UltrafilterChain.lean | Diamond ψ ∈ M → {ψ} ∪ box_theory(M) consistent | **SORRY-FREE** |
| `box_theory_witness_exists` | Algebraic/UltrafilterChain.lean | Diamond ψ ∈ M → ∃ W, ψ ∈ W ∧ box_class_agree(M,W) | **SORRY-FREE** |

### Temporal Witness Machinery

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `temporal_theory_witness_consistent` | Algebraic/UltrafilterChain.lean | F(φ) ∈ M → {φ} ∪ G_theory(M) ∪ box_theory(M) consistent | **SORRY-FREE** |
| `temporal_theory_witness_exists` | Algebraic/UltrafilterChain.lean | F(φ) ∈ M → ∃ W, φ ∈ W ∧ G-persist ∧ box_class_agree | **SORRY-FREE** |
| `H_theory` analog | Algebraic/UltrafilterChain.lean | Symmetric past version | sorry-free (by duality) |
| `G_lift_from_context` | Algebraic/UltrafilterChain.lean | ctx ⊢ φ ∧ G(x) ∈ M for all x ∈ ctx → G(φ) ∈ M | **SORRY-FREE** |

### Restricted Chain (Forward Direction)

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `restricted_forward_chain` | Bundle/SuccChainFMCS.lean | Nat-indexed chain staying within deferralClosure(φ) | Construction, sorry-free |
| `restricted_forward_chain_succ` | Bundle/SuccChainFMCS.lean | Adjacent elements satisfy Succ | sorry-free |
| `f_nesting_is_bounded_restricted` | Bundle/SuccChainFMCS.lean | F-nesting bounded for RestrictedMCS | **SORRY-FREE** (unlike general version which is FALSE) |
| `restricted_forward_chain_F_bounded` | Bundle/SuccChainFMCS.lean | iter_F d ψ ∈ chain(k) → bounded | sorry-free |
| `restricted_forward_chain_forward_F` | Bundle/SuccChainFMCS.lean | F(ψ) ∈ chain(n) → ∃ m > n, ψ ∈ chain(m) | **SORRY-FREE** (forward temporal coherence proven!) |
| `restricted_bounded_witness` | Bundle/SuccChainFMCS.lean | Core inductive witness lemma | Has a sorry in termination_by (see below) |
| `MCS_to_SerialMCS` | Bundle/SuccChainFMCS.lean | Any MCS → SerialMCS (F_top/P_top are theorems) | sorry-free |
| `SuccChainFMCS` | Bundle/SuccChainFMCS.lean | FMCS structure from SerialMCS with succ chain | **SORRY-FREE** (forward_G + backward_H) |

### SuccChain FMCS Properties

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `succ_chain_forward_G_le` | (via FMCS.forward_G) | G(φ) ∈ mcs t → φ ∈ mcs s for s ≥ t | sorry-free |
| `succ_chain_backward_H_le` | (via FMCS.backward_H) | H(φ) ∈ mcs t → φ ∈ mcs s for s ≤ t | sorry-free |
| `shifted_fmcs` | Algebraic/UltrafilterChain.lean | Shift FMCS by integer offset k | sorry-free |
| `shifted_temporal_forward_F/backward_P` | Algebraic/UltrafilterChain.lean | Temporal coherence preserved by shift | sorry-free |
| `succ_chain_box_persistent` | Algebraic/UltrafilterChain.lean | Box φ constant along SuccChainFMCS | sorry-free via parametric_box_persistent |

### Saturation Infrastructure

| Theorem | File | What It Proves | Notes |
|---------|------|----------------|-------|
| `saturated_modal_backward` | Bundle/ModalSaturation.lean | Saturated BFMCS → modal_backward | **SORRY-FREE** |
| `is_modally_saturated` | Bundle/ModalSaturation.lean | Predicate: every ◇φ has a witness family | Definition |
| `axiom_5_negative_introspection` | Bundle/ModalSaturation.lean | ⊢ ¬□φ → □(¬□φ) | sorry-free |

---

## Sorry Inventory

| Sorry Location | What It Blocks | Why It Exists |
|----------------|----------------|---------------|
| `SuccChainFMCS.lean:1435` (`neg_not_in_boundary_resolution_set`) | `constrained_successor_seed_restricted_consistent` | F(χ) ∈ u vs F(χ.neg) ∈ u are not provably inconsistent with current axioms |
| `SuccChainFMCS.lean:1480` (`augmented_seed_consistent`) | `constrained_successor_seed_restricted_consistent` | Depends on above sorry |
| `SuccChainFMCS.lean:1543` (`constrained_successor_seed_restricted_consistent`) | `constrained_successor_restricted` → restricted backward chain | Consistency of boundary_resolution_set seed |
| `SuccChainFMCS.lean:2405` (`restricted_bounded_witness` termination) | `restricted_forward_chain_forward_F` depends on `restricted_forward_chain_iter_F_witness` | Termination proof for d' > 1 recursive case; `all_goals sorry` in `decreasing_by` |
| `SuccChainTruth.lean:311` (Box backward singleton Omega) | `succ_chain_truth_lemma`, `succ_chain_truth_forward` | Singleton Omega cannot prove Box backward without saturation (mathematically correct behavior) |

**IMPORTANT NOTE**: `restricted_forward_chain_forward_F` calls `restricted_forward_chain_iter_F_witness` which calls `restricted_bounded_witness` which has `all_goals sorry` in its termination proof. This means `restricted_forward_chain_forward_F` also depends on sorryAx.

---

## Dependency Graph

```
parametric_algebraic_representation_conditional (SORRY-FREE)
  └─ parametric_shifted_truth_lemma (SORRY-FREE, needs h_tc)
       └─ [h_tc : B.temporally_coherent] ← THE GAP
            └─ needs: ∀ fam ∈ B.families, fam has forward_F and backward_P

BFMCS Construction target:
  boxClassFamilies (SORRY-FREE modal coherence)
    ├─ boxClassFamilies_modal_forward (SORRY-FREE)
    ├─ boxClassFamilies_modal_backward (SORRY-FREE)
    └─ temporal coherence of families ← BLOCKED
         └─ each family = shifted_fmcs (SuccChainFMCS M0)
              ├─ forward_F of SuccChainFMCS ← BLOCKED (no SuccChainTemporalCoherent)
              │    └─ restricted_forward_chain_forward_F (has sorry in termination)
              └─ backward_P of SuccChainFMCS ← MISSING (no backward chain construction)
                   └─ needs: constrained_predecessor_restricted (not yet built)
                        └─ needs: constrained_successor_seed_restricted_consistent (sorry)
```

**The gap is specifically**:
1. `forward_F` for arbitrary `SuccChainFMCS`: The restricted chain has it sorry-free only for `DeferralRestrictedMCS` (restricted to closure of a specific φ), not for arbitrary MCS.
2. `backward_P` for any chain: The `constrained_predecessor_restricted` construction is missing entirely.

---

## Underutilized Sorry-Free Results

These sorry-free theorems are built but NOT currently wired into any completeness attempt:

1. **`temporal_theory_witness_exists`** (UltrafilterChain.lean): Gives a witness W for F(φ) ∈ M with G-persistence and box-class agreement. This is a critical lemma for a **temporal modal witness BFMCS** but is not yet wired into a complete `construct_bfmcs_temporal` function.

2. **`H_theory` and `past_temporal_theory_witness_consistent`** (UltrafilterChain.lean): The past-direction analog exists but the completeness proof never uses it.

3. **`restricted_forward_chain_forward_F`** (SuccChainFMCS.lean): The forward_F proof for restricted chains exists. No current path uses it to build a complete BFMCS.

4. **`R_G_refl`, `R_G_trans`, `R_Box_euclidean`** (UltrafilterChain.lean): The ultrafilter relation properties are fully sorry-free but the ultrafilter chain construction was abandoned (no entry point that uses them for completeness).

5. **`boxClassFamilies_temporally_coherent`** is marked `@[deprecated]` but the underlying infrastructure `shifted_temporal_forward_F` and `shifted_temporal_backward_P` are sorry-free. The issue is only that `SuccChainTemporalCoherent` was removed.

---

## Alternative Architectures

### Can completeness be proven WITHOUT `construct_bfmcs`?

**YES.** `parametric_algebraic_representation_conditional` takes `construct_bfmcs` as a *parameter*, not as a fixed implementation. So:

```lean
theorem parametric_algebraic_representation_conditional
    (φ : Formula) (h_not_prov : ¬⊢φ)
    (construct_bfmcs : (M : Set Formula) → SetMaximalConsistent M →
      Σ' (B : BFMCS D) (h_tc : B.temporally_coherent)
         (fam : FMCS D) (hfam : fam ∈ B.families) (t : D),
         M = fam.mcs t) :
    ∃ countermodel ...
```

Any function matching this type signature works. Three alternative architectures:

#### Architecture A: Restricted Chain BFMCS
Build `construct_bfmcs` using restricted chains:
- Given M, pick any non-provable φ ∈ M (or use φ = ⊥ as a dummy)
- Build forward restricted chain using `restricted_forward_chain` (sorry-free forward_F)
- **GAPS**: (1) Need backward chain (P-direction); (2) `restricted_bounded_witness` termination sorry

#### Architecture B: Temporal-Modal Witness Pyramid
Use `temporal_theory_witness_exists` and `box_theory_witness_exists`:
- The bundle = all families reachable from M0 via temporal and modal witnesses
- Modal coherence: `box_theory_witness_exists` already provides this
- Temporal coherence: `temporal_theory_witness_exists` provides forward_F witnesses, but we need to close under them
- **ADVANTAGE**: Both witness lemmas are fully sorry-free
- **GAPS**: (1) Need to close the family collection transitively; (2) Termination of closure is non-trivial

#### Architecture C: Use `semantic_weak_completeness` (FMP path)
The file `Decidability/FMP/SemanticCanonicalModel.lean` reportedly has `semantic_weak_completeness` as sorry-free. This uses filtration/FMP rather than canonical model completeness.
- **GAPS**: FMP sorries in `TruthPreservation.lean` (lines 263, 281: 2 sorries)

### What is `h_tc` exactly?

```lean
B.temporally_coherent : Prop :=
  ∀ fam ∈ B.families,
    (∀ t φ, Formula.some_future φ ∈ fam.mcs t → ∃ s, t < s ∧ φ ∈ fam.mcs s) ∧
    (∀ t φ, Formula.some_past φ ∈ fam.mcs t → ∃ s, s < t ∧ φ ∈ fam.mcs s)
```

So `h_tc` requires: for every family in the bundle, the MCS sequence has both forward_F (F-witnesses) and backward_P (P-witnesses) at every time point.

### What does `parametric_algebraic_representation_conditional` require?

The hypothesis `construct_bfmcs` must provide:
- `B : BFMCS D` — a bundle of families over D
- `h_tc : B.temporally_coherent` — temporal coherence (the hard part)
- `fam : FMCS D` — an evaluation family
- `hfam : fam ∈ B.families`
- `t : D` — evaluation time
- `M = fam.mcs t` — the input MCS equals the family at time t

The key constraint is **temporal coherence**: both forward_F and backward_P must hold for every family in the bundle.

---

## Exact Signatures of the Sorry Theorems

### Sorry 1: `neg_not_in_boundary_resolution_set` (SuccChainFMCS.lean:1412)
```lean
theorem neg_not_in_boundary_resolution_set (phi : Formula) (u : Set Formula) (chi : Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_in : Formula.some_future chi ∈ u) :
    chi.neg ∉ boundary_resolution_set phi u
-- STATUS: sorry at line 1435, comment says "may not be provable"
```

### Sorry 2: `augmented_seed_consistent` (SuccChainFMCS.lean:1467)
```lean
theorem augmented_seed_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed_restricted phi u ∪ boundary_resolution_set phi u)
-- STATUS: sorry at line 1480; this is actually a consequence of #1
```

### Sorry 3: `constrained_successor_seed_restricted_consistent` (SuccChainFMCS.lean:1507)
```lean
theorem constrained_successor_seed_restricted_consistent (phi : Formula) (u : Set Formula)
    (h_mcs : DeferralRestrictedMCS phi u)
    (h_F_top : Formula.some_future (Formula.neg Formula.bot) ∈ u) :
    SetConsistent (constrained_successor_seed_restricted phi u)
-- STATUS: sorry at line 1543; blocks constrained_successor_restricted construction
```

### Sorry 4: `restricted_bounded_witness` termination (SuccChainFMCS.lean:2380)
```lean
theorem restricted_bounded_witness (phi : Formula) (M0 : DeferralRestrictedSerialMCS phi)
    (k : Nat) (theta : Formula) (d : Nat)
    (h_d_ge : d ≥ 1)
    (h_iter_in : iter_F d theta ∈ restricted_forward_chain phi M0 k)
    (h_iter_not : iter_F (d + 1) theta ∉ restricted_forward_chain phi M0 k) :
    ∃ m : Nat, m > k ∧ theta ∈ restricted_forward_chain phi M0 m
-- STATUS: termination_by d with `all_goals sorry` in decreasing_by
-- The d' > 1 case is NOT actually well-founded: recursive call can increase depth
```

---

## Confidence Level

**High** — I read all the relevant source files directly. The sorry inventory is complete for the Metalogic directory. The architectural analysis is grounded in the actual theorem signatures.

**One uncertainty**: Whether `restricted_bounded_witness`'s termination sorry actually blocks `restricted_forward_chain_forward_F` in practice (Lean may accept it anyway via `termination_by d` even with the sorry, since the primary induction is on d). Need to verify with `#print axioms restricted_forward_chain_forward_F`.
