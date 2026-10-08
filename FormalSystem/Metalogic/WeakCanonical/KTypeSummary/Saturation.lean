/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Family

/-!
# Step 5a — the saturation core: a block's `k`-type is a function of its family

Büchi's step 5 is **saturation**: every member of a family `[u]·[v]^ω` is inside or disjoint from
the target language (Thomas 1997, *Languages, Automata, and Logic*, §5.1, p. 30; cslib's
`Cslib.Automata.NA.Buchi.buchiFamily_saturation` is the structural reference, cited and not
depended on). In the `k`-type idiom the hinge on which saturation turns is this module's
headline: **two coloured `ℤ`-blocks whose factorizations carry matching segment types are
`≡ₖ`**, so the `k`-type of a block is a function of its family triple `(τneg, τzero, τpos)`.
Saturation proper, for targets determined by the block's `k`-type, is `Universal.lean`.

The proof is **assembly of three proved parts, not a new induction**:

1. `kEquiv_zFiber_segSum` (`Segment.lean`) rewrites each block as the `ℤ`-indexed ordered sum of
   its segments.
2. Under the matching hypothesis the two `k`-type-coloured index orders
   `kTypeColouring sig k (fun z => segZ sig c (W z) (W (z+1)))` and its primed twin are
   **pointwise equal functions on `ℤ`**, so they are equal structures (`funext` + `congrArg`) —
   `kTypeColouring_eq_of_matching_segments`. No back-and-forth argument is needed, and in
   particular the anchored coloured-order lemma of `GroupModel/RamseyFactorization.lean` is not.
3. The mixing lemma `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean`, Doets 1987, 3.1.8)
   turns the coloured-order `≡ₖ` into a `≡ₖ` between the ordered sums.

`KEquiv` is, by definition, equality of `kTypeOf` values, so the composition is `Eq.trans` /
`Eq.symm`.

## What this does **not** give

Nothing here says that a `⊡` fibre condition is a `k`-type-determined target. That reduction is
the MSO-to-ω-regular correspondence, which has no formalization in any proof assistant, and it is
never used in this cluster; see `KTypeSummary/Basic.lean` for the scope disclaimer. No complexity
bound is claimed.

## Main results

* `kTypeColouring_eq_of_matching_segments` — matched segment types give equal coloured index
  orders.
* `kEquiv_zFiber_of_matching_segments` — the headline: matched segment types give `≡ₖ` blocks.
* `kTypeOf_zFiber_eq_of_sameTriple`, `kTypeOf_zFiber_eq_of_inFamily` — the block `k`-type is a
  function of the family triple, unbundled and over `InFamily`.

## References

* [K. Doets, *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order
  and Intensional Logic*][doets1987], 3.1.8 (the mixing lemma) and ch. 7 (pp. 89–93).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.Expressiveness

/-! ## The pointwise-colouring step -/

/-- **Matched segment types give equal coloured index orders.** If the `z`-th segments of the two
cuttings have the same `k`-type for every `z`, the two `k`-type colourings of `ℤ` are the same
function, so the two coloured index orders are literally equal: `funext` on the colour function
and `congrArg` on `colourStructure`. Kept as its own step so that a failure would localize. -/
theorem kTypeColouring_eq_of_matching_segments (sig : MonadicSignature) (k : ℕ)
    (c c' : sig.preds → ℤ → Prop) (W W' : ℤ → ℤ)
    (hmatch : ∀ z : ℤ,
      kTypeOf sig k (segZ sig c (W z) (W (z + 1)))
        = kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1)))) :
    kTypeColouring sig k (fun z : ℤ => segZ sig c (W z) (W (z + 1)))
      = kTypeColouring sig k (fun z : ℤ => segZ sig c' (W' z) (W' (z + 1))) := by
  unfold kTypeColouring
  exact congrArg (colourStructure ℤ) (funext hmatch)

/-! ## The headline -/

/-- **Step 5a of the chain: matched segment types give `≡ₖ` blocks.** Two coloured `ℤ`-blocks,
each cut by a monotone covering sequence, whose `z`-th segments have the same `k`-type for every
`z`, are `≡ₖ`. Each block is its segment sum (`kEquiv_zFiber_segSum`); the two coloured index
orders are equal (`kTypeColouring_eq_of_matching_segments`), hence `≡ₖ`; and the mixing lemma
`kEquiv_orderedSum_of_kEquiv_colour` lifts that to the sums. -/
theorem kEquiv_zFiber_of_matching_segments (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c c' : sig.preds → ℤ → Prop) (W W' : ℤ → ℤ)
    (hW : Monotone W) (hW' : Monotone W')
    (hcov : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1))
    (hcov' : ∀ t : ℤ, ∃ z, W' z ≤ t ∧ t < W' (z + 1))
    (hmatch : ∀ z : ℤ,
      kTypeOf sig k (segZ sig c (W z) (W (z + 1)))
        = kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1)))) :
    KEquiv sig k (zFiber sig c) (zFiber sig c') := by
  have h1 := kEquiv_zFiber_segSum sig k c W hW hcov
  have h2 := kEquiv_zFiber_segSum sig k c' W' hW' hcov'
  have hcol : KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k (fun z : ℤ => segZ sig c (W z) (W (z + 1))))
      (kTypeColouring sig k (fun z : ℤ => segZ sig c' (W' z) (W' (z + 1)))) :=
    congrArg (kTypeOf (colourSig (KType sig k)) k)
      (kTypeColouring_eq_of_matching_segments sig k c c' W W' hmatch)
  have hmix := kEquiv_orderedSum_of_kEquiv_colour k _ _ hcol
  exact h1.trans (hmix.trans h2.symm)

/-! ## The block `k`-type is a function of the family -/

/-- **The block `k`-type is a function of the family triple** (unbundled form). Two coloured
blocks whose factorizations carry the same `(τneg, τzero, τpos)` have equal `k`-types: the six
type equations give the matching hypothesis of `kEquiv_zFiber_of_matching_segments` by a
three-way case split on the segment index (`z < 0`, `z = 0`, `0 < z`). -/
theorem kTypeOf_zFiber_eq_of_sameTriple (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c c' : sig.preds → ℤ → Prop) (W W' : ℤ → ℤ)
    (τneg τzero τpos : KType sig k)
    (hW : Monotone W) (hW' : Monotone W')
    (hcov : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1))
    (hcov' : ∀ t : ℤ, ∃ z, W' z ≤ t ∧ t < W' (z + 1))
    (hpos : ∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos)
    (hneg : ∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg)
    (hzero : kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero)
    (hpos' : ∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1))) = τpos)
    (hneg' : ∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c' (W' z) (W' (z + 1))) = τneg)
    (hzero' : kTypeOf sig k (segZ sig c' (W' 0) (W' 1)) = τzero) :
    kTypeOf sig k (zFiber sig c) = kTypeOf sig k (zFiber sig c') := by
  refine kEquiv_zFiber_of_matching_segments sig k c c' W W' hW hW' hcov hcov' ?_
  intro z
  rcases lt_trichotomy z 0 with hz | rfl | hz
  · exact (hneg z hz).trans (hneg' z hz).symm
  · rw [zero_add]
    exact hzero.trans hzero'.symm
  · exact (hpos z hz).trans (hpos' z hz).symm

/-- **The block `k`-type is a function of the family** (bundled form over `InFamily`). The
binders are `InFamily`'s own — `SegmentFactorization` is stated over `[Fintype sig.preds]
[DecidableEq sig.preds]` — and the `[Finite sig.preds]` the unbundled theorem needs is derived
from them. -/
theorem kTypeOf_zFiber_eq_of_inFamily (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (τneg τzero τpos : KType sig k)
    (c c' : sig.preds → ℤ → Prop)
    (h : InFamily sig k τneg τzero τpos c) (h' : InFamily sig k τneg τzero τpos c') :
    kTypeOf sig k (zFiber sig c) = kTypeOf sig k (zFiber sig c') := by
  haveI : Finite sig.preds := Finite.of_fintype _
  obtain ⟨F, hFneg, hFzero, hFpos⟩ := h
  obtain ⟨F', hF'neg, hF'zero, hF'pos⟩ := h'
  exact kTypeOf_zFiber_eq_of_sameTriple sig k c c' F.W F'.W τneg τzero τpos
    F.mono F'.mono F.cover F'.cover
    (fun z hz => (F.pos_type z hz).trans hFpos) (fun z hz => (F.neg_type z hz).trans hFneg)
    (F.zero_type.trans hFzero)
    (fun z hz => (F'.pos_type z hz).trans hF'pos) (fun z hz => (F'.neg_type z hz).trans hF'neg)
    (F'.zero_type.trans hF'zero)

end FormalSystem.Metalogic.WeakCanonical
