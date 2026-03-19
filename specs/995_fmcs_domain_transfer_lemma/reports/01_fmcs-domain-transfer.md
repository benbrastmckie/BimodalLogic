# FMCS Domain Transfer Lemma Research Report

**Task**: 995 - fmcs_domain_transfer_lemma
**Date**: 2026-03-19
**Session**: sess_1773939954_e417d4

## Executive Summary

This research investigates how to construct a general FMCS domain transfer lemma that
transfers temporal coherence properties (forward_F, backward_P) from the sorry-free
`CanonicalMCS`-based construction to any domain `D` with `AddCommGroup + LinearOrder + IsOrderedAddMonoid`.

**Key Finding**: The transfer requires an **order embedding** (not full isomorphism) from
`CanonicalMCS` to `D`, combined with a structural compatibility constraint. The approach
is feasible but requires careful handling of the Preorder-vs-LinearOrder mismatch.

## Background: Current Architecture

### CanonicalMCS Construction (Sorry-Free)

Located in `Theories/Bimodal/Metalogic/Bundle/CanonicalFMCS.lean`:

```lean
structure CanonicalMCS where
  world : Set Formula
  is_mcs : SetMaximalConsistent world

noncomputable instance : Preorder CanonicalMCS where
  le a b := a = b ∨ CanonicalR a.world b.world
  -- reflexive closure of CanonicalR

noncomputable def canonicalMCSBFMCS : FMCS CanonicalMCS where
  mcs := canonicalMCS_mcs          -- identity: each element IS its MCS
  is_mcs := canonicalMCS_is_mcs
  forward_G := ...                  -- PROVEN (no sorry)
  backward_H := ...                 -- PROVEN (no sorry)
```

**Critical Properties (all proven)**:
- `canonicalMCS_forward_F`: F(phi) at w implies witness s >= w with phi at s
- `canonicalMCS_backward_P`: P(phi) at w implies witness s <= w with phi at s
- `temporal_coherent_family_exists_CanonicalMCS`: Complete existence theorem

### TaskFrame Requirements

Located in `Theories/Bimodal/Semantics/TaskFrame.lean`:

```lean
structure TaskFrame (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] where
  WorldState : Type
  task_rel : WorldState -> D -> WorldState -> Prop
  nullity_identity : ...
  forward_comp : ...
  converse : ...
```

**The Gap**: `CanonicalMCS` has `Preorder` but lacks:
- `AddCommGroup` (no group structure)
- `LinearOrder` (Preorder is NOT total)
- `IsOrderedAddMonoid` (no monoid structure)

### Existing Transfer Infrastructure

Located in `Theories/Bimodal/Metalogic/Domain/DurationTransfer.lean`:

```lean
-- Transfer algebraic structure via OrderIso
noncomputable def transferAddCommGroup
    {T : Type*} {G : Type*} [LinearOrder T] [AddCommGroup G] [LinearOrder G]
    (e : T ≃o G) : AddCommGroup T := Equiv.addCommGroup e.toEquiv

theorem transferIsOrderedAddMonoid
    {T : Type*} {G : Type*} ...
    (e : T ≃o G) :
    @IsOrderedAddMonoid T (transferAddCommGroup e).toAddCommMonoid ... := ...
```

This transfers algebraic structure from codomain to domain via **full OrderIso**.
For FMCS transfer, we need the reverse: transfer temporal coherence along an embedding.

## Analysis: Transfer Approaches

### Approach 1: Pull-Back via Order Embedding (Recommended)

**Core Idea**: Given `e : CanonicalMCS ↪o D` (order embedding), define:

```lean
def transferFMCS (fam : FMCS CanonicalMCS) (e : CanonicalMCS ↪o D) : FMCS D where
  mcs d := fam.mcs (??? : CanonicalMCS)  -- Problem: e is not surjective
```

**Problem**: Order embedding is NOT surjective. For `d : D`, there may be no
`w : CanonicalMCS` with `e w = d`.

**Solution**: Use a **section/retraction pair**:

```lean
-- e : CanonicalMCS ↪o D (embedding)
-- r : D → CanonicalMCS (retraction, left inverse: r ∘ e = id)

def transferFMCS (fam : FMCS CanonicalMCS) (e : CanonicalMCS ↪o D)
    (r : D → CanonicalMCS) (h_retract : ∀ w, r (e w) = w)
    (h_monotone : ∀ d₁ d₂, d₁ < d₂ → r d₁ < r d₂) : FMCS D where
  mcs d := fam.mcs (r d)
  is_mcs d := fam.is_mcs (r d)
  forward_G d₁ d₂ phi h_lt h_G := fam.forward_G (r d₁) (r d₂) phi (h_monotone d₁ d₂ h_lt) h_G
  backward_H d₁ d₂ phi h_lt h_H := fam.backward_H (r d₁) (r d₂) phi (h_monotone d₂ d₁ h_lt) h_H
```

**Forward F Transfer**:
```lean
theorem transfer_forward_F (d : D) (phi : Formula)
    (h_F : Formula.some_future phi ∈ (transferFMCS fam e r ...).mcs d) :
    ∃ s : D, d < s ∧ phi ∈ (transferFMCS fam e r ...).mcs s := by
  -- h_F says F(phi) ∈ fam.mcs (r d)
  -- By canonicalMCS_forward_F: ∃ w : CanonicalMCS, r d ≤ w ∧ phi ∈ fam.mcs w
  -- Take s := e w, then d < e w (need: e reflects strict order from range)
  -- phi ∈ fam.mcs w = fam.mcs (r (e w)) = transferFMCS.mcs (e w)
  sorry
```

**Critical Requirements**:
1. `r : D → CanonicalMCS` must be **monotone** (reflect order)
2. `e : CanonicalMCS ↪o D` must be **strictly monotone** (OrderEmbedding ensures this)
3. Compatibility: `r (e w) = w` (retraction property)
4. **Density matching**: For discrete D (like Z), we need discrete CanonicalMCS

### Approach 2: Timeline Quotient with Cantor Isomorphism

**Existing Infrastructure** in `CanonicalEmbedding.lean`:

```lean
-- For dense D = Q
noncomputable def canonicalIso : TimelineQuot root_mcs root_mcs_proof ≃o Q :=
  Classical.choice (cantor_iso root_mcs root_mcs_proof)

noncomputable def ratFMCS : FMCS Q where
  mcs q := timelineQuotMCS root_mcs root_mcs_proof ((canonicalIso ...).symm q)
  ...
```

**Status**: Has sorries in `ratFMCS_forward_F` and `ratFMCS_backward_P`.

**Key Insight**: The `TimelineQuot` construction already has all MCS witnesses in
the timeline by construction (via staged saturation). The sorries exist because
we need to prove the staged construction includes F/P witnesses.

### Approach 3: Single Witness Chain (IntBFMCS Pattern)

**Existing Infrastructure** in `IntBFMCS.lean`:

```lean
-- Chain construction for D = Int
noncomputable def intChainMCS (M0 : Set Formula) (h_mcs0 : SetMaximalConsistent M0) :
    Int → Set Formula := ...

theorem intChain_forward_G : ... -- PROVEN
theorem intChain_backward_H : ... -- PROVEN
theorem intFMCS_forward_F : ... -- SORRY
theorem intFMCS_backward_P : ... -- SORRY
```

**Status**: The basic FMCS structure works, but forward_F/backward_P require
a **dovetailing construction** to ensure all F/P witnesses are in the chain.

## Mathlib Support for Order Embeddings

Key lemmas available:

```lean
-- From Mathlib.Order.Hom.Basic
theorem OrderEmbedding.lt_iff_lt (f : α ↪o β) {a b : α} : f a < f b ↔ a < b
theorem OrderEmbedding.strictMono (f : α ↪o β) : StrictMono f
theorem OrderEmbedding.monotone (f : α ↪o β) : Monotone f

-- From OrderIso
theorem OrderIso.lt_iff_lt (e : α ≃o β) {a b : α} : e a < e b ↔ a < b
def OrderIso.symm (e : α ≃o β) : β ≃o α
```

## Proposed Transfer Lemma Structure

### Primary Theorem

```lean
/--
FMCS domain transfer lemma: given an order embedding from CanonicalMCS to D
with a compatible retraction, transfer temporal coherence.

**Type Parameters**:
- D : Type with AddCommGroup + LinearOrder + IsOrderedAddMonoid

**Parameters**:
- e : CanonicalMCS ↪o D (order embedding)
- r : D → CanonicalMCS (retraction)
- h_retract : ∀ w, r (e w) = w (left inverse property)
- h_r_mono : ∀ d₁ d₂, d₁ < d₂ → r d₁ < r d₂ (retraction preserves order)

**Result**:
- FMCS D with forward_F and backward_P
- Root preservation: ∃ d₀, mcs(d₀) = root.world
-/
theorem fmcs_domain_transfer
    (D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (e : CanonicalMCS ↪o D) (r : D → CanonicalMCS)
    (h_retract : ∀ w, r (e w) = w)
    (h_r_mono : ∀ d₁ d₂ : D, d₁ < d₂ → r d₁ < r d₂) :
    ∃ (fam : FMCS D),
      (∀ d φ, Formula.some_future φ ∈ fam.mcs d → ∃ s, d < s ∧ φ ∈ fam.mcs s) ∧
      (∀ d φ, Formula.some_past φ ∈ fam.mcs d → ∃ s, s < d ∧ φ ∈ fam.mcs s) := ...
```

### Instantiation Path for Z (Base Completeness)

1. **Build `e : CanonicalMCS ↪o Z`**:
   - Use intChainMCS construction
   - Define e(M) := minimal t with intChainMCS t = M.world
   - Problem: Not all MCS are in the chain

2. **Alternative**: Enrich the chain via dovetailing
   - At each step, include witnesses for pending F/P obligations
   - This ensures surjectivity onto the CanonicalMCS elements we need

### Instantiation Path for Q (Dense Completeness)

1. **Build `e : TimelineQuot ↪o Q`**:
   - Use `cantor_iso` (already exists as OrderIso)
   - OrderIso gives both directions automatically

2. **Transfer forward_F/backward_P**:
   - TimelineQuot is built with saturation; witnesses are included by construction
   - Need to prove `timelineQuotMCS` respects the F/P witness requirements

## Key Technical Challenges

### Challenge 1: CanonicalMCS is Not Linear

`CanonicalMCS` has Preorder, not LinearOrder. The reflexive closure of `CanonicalR`
is transitive and reflexive, but NOT total: there exist incomparable MCSes.

**Impact**: Cannot directly use OrderIso to Z or Q (requires LinearOrder).

**Solution**: Use a **linear quotient** or **chain extraction**:
- `TimelineQuot` already quotients by antisymmetric closure
- For Z, use the chain construction which is inherently linear

### Challenge 2: Surjectivity of Retraction

For `r : D → CanonicalMCS` to be a valid retraction, we need:
- `r (e w) = w` for all `w` in the image of `e`
- `r` monotone outside the image

**Solution**: Define `r d` as:
- If `d = e w` for some `w`, return `w`
- Otherwise, return nearest neighbor in the image (requires density analysis)

### Challenge 3: Witness Inclusion

The key insight for forward_F transfer:
1. `F(phi) ∈ fam.mcs d` means `F(phi) ∈ canonicalMCSBFMCS.mcs (r d)`
2. By `canonicalMCS_forward_F`: exists `w : CanonicalMCS` with `r d ≤ w` and `phi ∈ mcs w`
3. Need `e w` to satisfy `d < e w`

**Critical Constraint**: The embedding must preserve strict order:
- `r d < w` in CanonicalMCS implies `d < e w` in D
- This requires `e` to be order-reflecting (which OrderEmbedding provides)

## Recommended Implementation Strategy

### Phase 1: Define Transfer Infrastructure

```lean
-- In a new file: Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean

structure FMCSTransfer (D : Type*) [Preorder D] [Preorder CanonicalMCS] where
  embed : CanonicalMCS ↪o D
  retract : D → CanonicalMCS
  retract_left_inverse : ∀ w, retract (embed w) = w
  retract_monotone : ∀ d₁ d₂, d₁ < d₂ → retract d₁ < retract d₂
  embed_retract_le : ∀ d, embed (retract d) ≤ d  -- embed is "below" d
  retract_embed_strict : ∀ w₁ w₂, w₁ < w₂ → embed w₁ < embed w₂ -- strict preservation
```

### Phase 2: Prove Transfer Theorems

```lean
theorem transfer_forward_G (T : FMCSTransfer D) (d₁ d₂ : D) (phi : Formula)
    (h_lt : d₁ < d₂) (h_G : Formula.all_future phi ∈ canonicalMCSBFMCS.mcs (T.retract d₁)) :
    phi ∈ canonicalMCSBFMCS.mcs (T.retract d₂) :=
  canonicalMCS_forward_G (T.retract d₁) (T.retract d₂) phi (T.retract_monotone d₁ d₂ h_lt) h_G

theorem transfer_forward_F (T : FMCSTransfer D) (d : D) (phi : Formula)
    (h_F : Formula.some_future phi ∈ canonicalMCSBFMCS.mcs (T.retract d)) :
    ∃ s : D, d < s ∧ phi ∈ canonicalMCSBFMCS.mcs (T.retract s) := by
  -- Use canonicalMCS_forward_F to get witness w
  -- Show T.embed w satisfies the requirements
  ...
```

### Phase 3: Instantiate for Z and Q

```lean
-- For Z: Build chain-based FMCSTransfer
noncomputable def intTransfer (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    FMCSTransfer Int := ...

-- For Q: Build Cantor-based FMCSTransfer
noncomputable def ratTransfer (M₀ : Set Formula) (h_mcs₀ : SetMaximalConsistent M₀) :
    FMCSTransfer Rat := ...
```

## Estimated Effort

| Component | Difficulty | Estimate |
|-----------|------------|----------|
| FMCSTransfer structure | Low | 1-2 hours |
| transfer_forward_G/backward_H | Low | 1 hour |
| transfer_forward_F/backward_P | Medium | 2-3 hours |
| intTransfer instantiation | High | 4-6 hours |
| ratTransfer instantiation | Medium | 2-3 hours |
| **Total** | | **10-15 hours** |

The main complexity is in the instantiation: proving that the chain/timeline
construction provides a valid FMCSTransfer with all required properties.

## Conclusion

The FMCS domain transfer lemma is **feasible** with the following approach:

1. **Define FMCSTransfer structure** encapsulating the embedding/retraction pair
2. **Prove generic transfer theorems** for forward_G, backward_H, forward_F, backward_P
3. **Instantiate for Z** using enriched dovetailing chain
4. **Instantiate for Q** using TimelineQuot + Cantor isomorphism

The key insight is that `CanonicalMCS` provides sorry-free temporal coherence,
and we transfer this along order embeddings rather than trying to prove these
properties directly on Z/Q-indexed chains.

## References

- `CanonicalFMCS.lean`: Sorry-free CanonicalMCS construction
- `IntBFMCS.lean`: Partial Int FMCS (sorries in F/P)
- `CanonicalEmbedding.lean`: Partial Q FMCS via Cantor (sorries in F/P)
- `DurationTransfer.lean`: Algebraic structure transfer via OrderIso
- `WitnessSeed.lean`: g_content/h_content duality theorems
- `CanonicalFrame.lean`: canonical_forward_F, canonical_backward_P lemmas
