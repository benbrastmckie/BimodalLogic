/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment
import FormalSystem.ForMathlib.Combinatorics.InfiniteRamseyPairs

/-!
# Steps 3 and 4 — the bi-infinite family and its Ramsey cover

Büchi's step 3 is the family `[u]·[v]^ω` of ω-words: a prefix in one congruence class followed by
ω-many factors in another (Thomas 1997, *Languages, Automata, and Logic*, §5.1, p. 30; the shape
cslib names `Cslib.Automata.NA.Buchi.buchiFamily`, cited as a structural reference only). Here
the time axis is `ℤ`, not `ℕ`, because the seam-gluing presentation of a possible world glues a
**backward** ray to a **forward** ray at a seam, so the family is **bi-infinite**:

`(τneg)^(ω*) · τzero · (τpos)^ω`

— a monotone cutting sequence `W : ℤ → ℤ` covering `ℤ`, every segment `[W z, W (z+1))` below the
middle one of `k`-type `τneg`, the middle segment `[W 0, W 1)` of type `τzero`, and every segment
above it of type `τpos`. `SegmentFactorization` is that datum and `InFamily τneg τzero τpos c`
says the coloured block `c` admits one with the given triple.

Büchi's step 4 is the Ramsey cover: colour a pair of positions by the summary of the segment
between them, apply infinite Ramsey for pairs, and read off a monochromatic monotone subsequence.
`exists_zFactorization` does exactly that, **twice** — once upward on
`(a, b) ↦ kTypeOf (segZ c a b)` and once downward on the reflected colouring — and glues the two
subsequences at `0`; the Ramsey
ingredient is `Nat.exists_strictMono_const_pair_colour`
(`ForMathlib/Combinatorics/InfiniteRamseyPairs.lean`, the theorem `infinite_ramsey_pairs` in
`GroupModel/RamseyFactorization.lean` aliases), and the finite colour type is step 2's
`kType_finite`. `family_cover` restates the cover as "every block is in some family", and
`exists_matching_factorization` is its unbundled form, so a consumer can use the cover without
importing the structure.

Both the structure and its existence theorem were first proved in
`GroupModel/RamseyFactorization.lean` as private ingredients of the per-block inflation; they
live here under the **same namespace**, with one field added (`τzero`/`zero_type`, the middle
segment's type, which was implicit) and the existence proof otherwise unchanged. Nothing here
claims a complexity bound, and nothing reduces a `⊡` condition to a family: see
`KTypeSummary/Basic.lean` for the scope disclaimer.

## Main definitions and results

* `SegmentFactorization` — the datum of a bi-infinite Ramsey factorization of a coloured block.
* `exists_zFactorization` — every coloured block has one (the Ramsey cover, proved twice over).
* `InFamily`, `family_cover` — the family predicate and the cover in family form.
* `exists_matching_factorization` — the unbundled cover.

## References

* [K. Doets, *Completeness and Definability: Applications of the Ehrenfeucht Game in Second-Order
  and Intensional Logic*][doets1987], ch. 7 (pp. 89–93).
-/

namespace FormalSystem.Metalogic.WeakCanonical

open Order FormalSystem.Metalogic.Expressiveness

/-! ## Step 3: the bi-infinite family -/

/-- **The data of a bi-infinite Ramsey factorization** of the coloured block `c` at depth `k`:
a monotone cutting sequence `W` covering `ℤ`, whose segments `[W z, W (z+1))` have one `k`-type
`τneg` below the middle segment `[W 0, W 1)`, the type `τzero` at it, and one `k`-type `τpos`
above it, with the extremal segments nonempty. This is Büchi's `[u]·[v]^ω` with the time axis `ℤ`
in place of `ℕ`: `(τneg)^(ω*) · τzero · (τpos)^ω`. The triple `(τneg, τzero, τpos)` is the
block's **family**. -/
structure SegmentFactorization (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop) where
  /-- The cutting sequence. -/
  W : ℤ → ℤ
  /-- Cuts are monotone. -/
  mono : Monotone W
  /-- Every time lies in some segment `[W z, W (z + 1))`. -/
  cover : ∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1)
  /-- The common `k`-type of the segments above the middle one. -/
  τpos : KType sig k
  /-- The common `k`-type of the segments below the middle one. -/
  τneg : KType sig k
  /-- Segments above the middle one all have type `τpos`. -/
  pos_type : ∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos
  /-- Segments below the middle one all have type `τneg`. -/
  neg_type : ∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg
  /-- The first segment above the middle one is nonempty. -/
  strict_pos : W 1 < W 2
  /-- The first segment below the middle one is nonempty. -/
  strict_neg : W (-2) < W (-1)
  /-- The `k`-type of the middle segment `[W 0, W 1)`. -/
  τzero : KType sig k
  /-- The middle segment has type `τzero`. -/
  zero_type : kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero

/-! ## Step 4: the Ramsey cover -/

/-- **Step 4 of the chain: every coloured block has a bi-infinite Ramsey factorization.** Infinite
Ramsey for pairs (`Nat.exists_strictMono_const_pair_colour`) is applied twice: upward, to the
colouring `(a, b) ↦ kTypeOf sig k (segZ sig c a b)` of increasing pairs of naturals, and
downward, to its reflection `(a, b) ↦ kTypeOf sig k (segZ sig c (-b) (-a))`; the two
monochromatic strictly monotone subsequences are glued at `0` into the cutting sequence `W`. The
finite colour type is step 2, `kType_finite`. The middle segment's type is read off as
`kTypeOf sig k (segZ sig c (W 0) (W 1))` itself. -/
theorem exists_zFactorization (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop) :
    Nonempty (SegmentFactorization sig k c) := by
  haveI : Finite (KType sig k) := by
    unfold KType
    infer_instance
  obtain ⟨gU, hgU, τpos, hτU⟩ :=
    Nat.exists_strictMono_const_pair_colour
      (fun a b => kTypeOf sig k (segZ sig c (a : ℤ) (b : ℤ)))
  obtain ⟨gD, hgD, τneg, hτD⟩ :=
    Nat.exists_strictMono_const_pair_colour
      (fun a b => kTypeOf sig k (segZ sig c (-(b : ℤ)) (-(a : ℤ))))
  have hgU_ge : ∀ n : ℕ, n ≤ gU n := fun n => hgU.le_apply
  have hgD_ge : ∀ n : ℕ, n ≤ gD n := fun n => hgD.le_apply
  set W : ℤ → ℤ := fun z => if 0 < z then ((gU (z - 1).toNat : ℕ) : ℤ)
    else -((gD (-z).toNat : ℕ) : ℤ) with hW
  have hWpos : ∀ z : ℤ, 0 < z → W z = ((gU (z - 1).toNat : ℕ) : ℤ) := by
    intro z hz; simp only [hW, if_pos hz]
  have hWnonpos : ∀ z : ℤ, ¬ 0 < z → W z = -((gD (-z).toNat : ℕ) : ℤ) := by
    intro z hz; simp only [hW, if_neg hz]
  have hmono : Monotone W := by
    intro z z' hzz'
    by_cases hz : 0 < z
    · have hz' : 0 < z' := lt_of_lt_of_le hz hzz'
      rw [hWpos z hz, hWpos z' hz']
      exact_mod_cast (hgU.monotone (by omega))
    · by_cases hz' : 0 < z'
      · rw [hWnonpos z hz, hWpos z' hz']
        have h1 : (0 : ℤ) ≤ ((gD (-z).toNat : ℕ) : ℤ) := Int.natCast_nonneg _
        have h2 : (0 : ℤ) ≤ ((gU (z' - 1).toNat : ℕ) : ℤ) := Int.natCast_nonneg _
        omega
      · rw [hWnonpos z hz, hWnonpos z' hz']
        have := hgD.monotone (show (-z').toNat ≤ (-z).toNat by omega)
        omega
  refine ⟨⟨W, hmono, ?_, τpos, τneg, ?_, ?_, ?_, ?_,
    kTypeOf sig k (segZ sig c (W 0) (W 1)), rfl⟩⟩
  · -- coverage
    intro t
    have hlow : W (-(((t.natAbs + 1 : ℕ) : ℤ))) ≤ t := by
      rw [hWnonpos _ (by omega),
        show (-(-(((t.natAbs + 1 : ℕ) : ℤ)))).toNat = t.natAbs + 1 by omega]
      have h1 := hgD_ge (t.natAbs + 1)
      omega
    have hhigh : t < W (((t.natAbs + 2 : ℕ) : ℤ)) := by
      rw [hWpos _ (by omega),
        show ((((t.natAbs + 2 : ℕ) : ℤ)) - 1).toNat = t.natAbs + 1 by omega]
      have h1 := hgU_ge (t.natAbs + 1)
      omega
    set zL : ℤ := -(((t.natAbs + 1 : ℕ) : ℤ)) with hzL
    set zH : ℤ := ((t.natAbs + 2 : ℕ) : ℤ) with hzH
    have hLH : zL ≤ zH := by omega
    classical
    set P : ℕ → Prop := fun n => W (zL + n) ≤ t with hP
    have hP0 : P 0 := by simpa [hP] using hlow
    set Nn : ℕ := (zH - zL).toNat with hNn
    set j : ℕ := Nat.findGreatest P Nn with hj
    have hPj : P j := Nat.findGreatest_spec (Nat.zero_le Nn) hP0
    have hjN : j ≠ Nn := by
      intro hje
      have : W (zL + Nn) ≤ t := hje ▸ hPj
      have hzHN : zL + (Nn : ℤ) = zH := by omega
      rw [hzHN] at this
      omega
    have hjle : j ≤ Nn := Nat.findGreatest_le Nn
    have hjlt : j < Nn := lt_of_le_of_ne hjle hjN
    have hnot : ¬ P (j + 1) :=
      Nat.findGreatest_is_greatest (n := Nn) (by omega) (by omega)
    refine ⟨zL + j, hPj, ?_⟩
    have : ¬ W (zL + j + 1) ≤ t := by
      have harith : zL + (j : ℤ) + 1 = zL + ((j + 1 : ℕ) : ℤ) := by push_cast; ring
      rw [harith]
      exact hnot
    omega
  · -- positive segment types
    intro z hz
    rw [hWpos z hz, hWpos (z + 1) (by omega)]
    have h1 : (z - 1).toNat < (z + 1 - 1).toNat := by omega
    exact hτU _ _ h1
  · -- negative segment types
    intro z hz
    rw [hWnonpos z (by omega), hWnonpos (z + 1) (by omega)]
    have h1 : (-(z + 1)).toNat < (-z).toNat := by omega
    have h2 := hτD _ _ h1
    exact h2
  · -- W 1 < W 2
    rw [hWpos 1 (by omega), hWpos 2 (by omega)]
    exact_mod_cast hgU (show ((1 : ℤ) - 1).toNat < ((2 : ℤ) - 1).toNat by omega)
  · -- W (-2) < W (-1)
    rw [hWnonpos (-2) (by omega), hWnonpos (-1) (by omega)]
    have := hgD (show ((-(-1 : ℤ)).toNat) < ((-(-2 : ℤ)).toNat) by omega)
    omega

/-! ## The family predicate and the cover in family form -/

/-- **The family `(τneg)^(ω*) · τzero · (τpos)^ω`**, as a predicate on coloured blocks: `c` is in
the family with triple `(τneg, τzero, τpos)` when it admits a `SegmentFactorization` carrying
exactly those three types. Stated as a plain predicate over the data — no quotient, no `Set`. -/
def InFamily (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : ℕ)
    (τneg τzero τpos : KType sig k) (c : sig.preds → ℤ → Prop) : Prop :=
  ∃ F : SegmentFactorization sig k c, F.τneg = τneg ∧ F.τzero = τzero ∧ F.τpos = τpos

/-- **The Ramsey cover in family form: every coloured block lies in some family.** A one-line
corollary of `exists_zFactorization`; the triple is read off the factorization. -/
theorem family_cover (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : ℕ) (c : sig.preds → ℤ → Prop) :
    ∃ τneg τzero τpos : KType sig k, InFamily sig k τneg τzero τpos c := by
  obtain ⟨F⟩ := exists_zFactorization sig k c
  exact ⟨F.τneg, F.τzero, F.τpos, F, rfl, rfl, rfl⟩

-- linter.unusedFintypeInType, linter.unusedDecidableInType: the `[Fintype sig.preds]` and
-- `[DecidableEq sig.preds]` binders are this theorem's recorded interface — the unbundled form
-- of `family_cover`, whose `SegmentFactorization` carries them — and they are consumed by the
-- proof (through `exists_zFactorization` and `kType_finite`) rather than by the conclusion,
-- which mentions only `KType`, `kTypeOf` and `segZ`. Declaration-scoped, as for `kType_finite`.
set_option linter.unusedFintypeInType false in
set_option linter.unusedDecidableInType false in
/-- **The unbundled Ramsey cover.** The content of `family_cover` with the structure unpacked:
a monotone covering cutting sequence with nonempty extremal segments, one `k`-type on every
segment above the middle, one on every segment below, and the middle segment's own type. Exists
so a consumer can use the cover without importing `SegmentFactorization`. -/
theorem exists_matching_factorization (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : ℕ) (c : sig.preds → ℤ → Prop) :
    ∃ (W : ℤ → ℤ) (τneg τzero τpos : KType sig k),
      Monotone W ∧
      (∀ t : ℤ, ∃ z, W z ≤ t ∧ t < W (z + 1)) ∧
      W 1 < W 2 ∧ W (-2) < W (-1) ∧
      (∀ z : ℤ, 0 < z → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τpos) ∧
      (∀ z : ℤ, z < 0 → kTypeOf sig k (segZ sig c (W z) (W (z + 1))) = τneg) ∧
      kTypeOf sig k (segZ sig c (W 0) (W 1)) = τzero := by
  obtain ⟨τneg, τzero, τpos, F, hneg, hzero, hpos⟩ := family_cover sig k c
  exact ⟨F.W, τneg, τzero, τpos, F.mono, F.cover, F.strict_pos, F.strict_neg,
    fun z hz => (F.pos_type z hz).trans hpos, fun z hz => (F.neg_type z hz).trans hneg,
    F.zero_type.trans hzero⟩

end FormalSystem.Metalogic.WeakCanonical
