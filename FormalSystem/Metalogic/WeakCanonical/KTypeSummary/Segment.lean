/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Basic
import FormalSystem.Metalogic.WeakCanonical.GroupModel.BlockDecomposition
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures

/-!
# Step 3′ — the segment carrier, and a block as the sum of its segments

The carrier of Büchi's chain in this tree's idiom (see `KTypeSummary/Basic.lean` for the chain):
`segZ sig c a b` is the half-open coloured segment `[a, b)` of a coloured `ℤ`-block, the
time-axis analogue of the finite word between two positions of an ω-word, and
`kTypeOf sig k (segZ sig c a b)` is the finite summary alphabet that step 2 (`kType_finite`)
bounds. `kEquiv_zFiber_segSum` is the chain's step 3′, *a word is the concatenation of its
factors*: cut `ℤ` by any monotone covering sequence `W` and the block `zFiber sig c` is `≡ₖ` the
ordered sum of its segments `segZ sig c (W z) (W (z + 1))` indexed by `ℤ`. It is the hinge the
mixing lemma `kEquiv_orderedSum_of_kEquiv_colour` (`MixedSum.lean`) is applied through: every
comparison of two blocks is first rewritten, on each side, as a comparison of segment sums.

Both declarations were first proved inside `GroupModel/RamseyFactorization.lean` as ingredients
of the per-block inflation (`inflate_right`/`inflate_left`), where the segment-sum lemma was
private. They live here, under the **same namespace**, so that every fully-qualified name is
unchanged and the summary cluster can import the carrier without reaching the group-model front
(`GroupModel/MonoDiscrete.lean`, `GroupModel/GoodGroupable.lean`). `qzFiber`, the `ℚ ×ₗ ℤ`
tail shape, stays in `RamseyFactorization.lean`: it is group-model-specific and has no role in
the chain.

## Main definitions and results

* `segZ` — the half-open coloured segment `[a, b)` of `ℤ`, as an ordered monadic structure.
* `kEquiv_zFiber_segSum` — a coloured `ℤ`-block is `≡ₖ` the `ℤ`-indexed ordered sum of its
  segments under any monotone covering cutting sequence.

## References

* [K. Doets, *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order
  and Intensional Logic*][doets1987], ch. 7 (pp. 89–93), the Ramseyan factorization this carrier
  serves.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order FormalSystem.Metalogic.Expressiveness

/-! ## The segment carrier -/

/-- A half-open coloured segment `[a, b)` of `ℤ`. In the chain this is the time-axis analogue of
a finite word between two positions, and `kTypeOf sig k (segZ sig c a b)` is the finite summary
alphabet that `kType_finite` bounds: Büchi colours a pair of positions by the congruence class
of the word between them, and this tree colours the pair of times `a < b` by the depth-`k` type
of this segment. -/
def segZ (sig : MonadicSignature) (c : sig.preds → ℤ → Prop) (a b : ℤ) :
    OrderedMonadicStructure sig where
  carrier := {t : ℤ // a ≤ t ∧ t < b}
  interp := fun p t => c p t.1
  carrierOrder := inferInstance

/-! ## The block as a `ζ`-indexed sum of its segments -/

/-- **Step 3′ of the chain: a block *is* its factorization.** Under any monotone cutting sequence
`W : ℤ → ℤ` covering `ℤ`, the coloured block `zFiber sig c` is `≡ₖ` the `ℤ`-indexed ordered sum
of its segments `segZ sig c (W z) (W (z + 1))`, at every depth `k`. The two structures are in
fact isomorphic as coloured orders (`k_equiv_of_iso`): the map sending a point of the `z`-th
segment to itself in `ℤ` is strictly monotone — segments are ordered by their index and are
pairwise disjoint intervals — and surjective by coverage.

This is the hinge the mixing lemma `kEquiv_orderedSum_of_kEquiv_colour` is applied through: a
comparison of two blocks becomes a comparison of their segment sums, and the mixing lemma reduces
that to a comparison of the `k`-type-coloured index orders. -/
theorem kEquiv_zFiber_segSum (sig : MonadicSignature) [Finite sig.preds]
    (k : ℕ) (c : sig.preds → ℤ → Prop)
    (W : ℤ → ℤ) (hmono : Monotone W) (hcover : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1)) :
    KEquiv sig k (zFiber sig c)
      (orderedSum sig ℤ (fun z => segZ sig c (W z) (W (z + 1)))) := by
  haveI := Classical.decEq sig.preds
  haveI := Fintype.ofFinite sig.preds
  set m : ℤ → OrderedMonadicStructure sig := fun z => segZ sig c (W z) (W (z + 1)) with hm
  set g : (orderedSum sig ℤ m).carrier → (zFiber sig c).carrier := fun s => s.2.1 with hg
  have hgmono : StrictMono g := by
    intro s t hst
    have h : Sigma.Lex (· < ·) (fun _ => (· < ·)) s t := hst
    cases h with
    | left a b hij =>
      rename_i i j
      change a.1 < b.1
      calc a.1 < W (i + 1) := a.2.2
        _ ≤ W j := hmono (by omega)
        _ ≤ b.1 := b.2.1
    | right a b hab =>
      exact hab
  have hgsurj : Function.Surjective g := by
    intro t
    obtain ⟨z, h1, h2⟩ := hcover t
    exact ⟨⟨z, ⟨t, h1, h2⟩⟩, rfl⟩
  refine k_equiv_of_iso sig k _ _
    (StrictMono.orderIsoOfSurjective g hgmono hgsurj).symm ?_
  intro p x
  set s := (StrictMono.orderIsoOfSurjective g hgmono hgsurj).symm x with hs
  have hx : g s = x :=
    StrictMono.orderIsoOfSurjective_self_symm_apply g hgmono hgsurj x
  change c p x ↔ c p s.2.1
  rw [show s.2.1 = x from hx]

end FormalSystem.Metalogic.WeakCanonical
