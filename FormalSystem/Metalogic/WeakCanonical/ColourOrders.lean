/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.BackAndForth

/-!
# Coloured index orders

Doets 1987, 3.1.8 states its hypothesis as a `≡ⁿ` fact about *coloured index orders*: the index
set `I` regarded as a structure `(I, {i | m(i) ⊨ σ})_{σ∈Z}` in the language whose unary
predicates are the colours `Z`. This module defines that structure and proves the `≡ₖ` fact the
Reynolds pipeline needs about it.

## Main definitions

* `colourSig ι` — the signature whose unary predicates *are* the colours `ι`.
* `colourStructure I c` — the index order `I` with predicate `z` true exactly at indices
  coloured `z`; literally `(I, {i | c i = z})_{z∈ι}`.
* `kTypeColouring sig k m` — the case `Z := KType sig k`, colouring an index by the `k`-type of
  its summand: *"which sentences of `Z` does the summand at `i` satisfy"*.
* `IsShuffleColouring S c` — `c` is a *shuffle colouring over the palette `S`*: it uses only
  colours of `S`, every colour of `S` occurs strictly inside every nonempty open interval, and
  the order is nonempty without endpoints. This is Reynolds' density condition (`IsShuffleMap`,
  `RealModel/Shuffle.lean:320`) stated for an arbitrary index order.

## Main result

`kEquiv_colourStructure`: **any two shuffle colourings over the same palette give `≡ₖ` coloured
orders, at every depth `k`.** Colours are matched by a colour-preserving back-and-forth: a new
point on one side falls into a gap of the finite matched configuration, and the density of its
colour supplies an answering point in the corresponding gap on the other side. There is no
cardinality obstruction, which is why this applies verbatim to `(ℚ, σ)` versus `(ℝ, σ*)` —
Reynolds' *"another simple game argument"*, printed p.188.

`RealModel/ShuffleReal.lean` instantiates it to discharge `kEquiv_shuffle_shuffleReal`'s
coloured-order hypothesis.

## References
- Reynolds 1992, §8, printed p.188: `literature/sources/reynolds_1992/sec04_7-separability.md`
- Doets 1987/1989, 3.1.8: `literature/Doets_1989_Monadic_Pi11_Theories.md`
-/

namespace FormalSystem.Metalogic.WeakCanonical

/-! ## The coloured index order as a structure -/

/-- The signature whose unary predicates are the colours of a palette `ι`. -/
def colourSig (ι : Type) : MonadicSignature where
  preds := ι

/-- **The `Z`-coloured index order as a structure**: carrier the index order, and the predicate
`z` true exactly at the indices coloured `z`. -/
def colourStructure {ι : Type} (I : Type) [LinearOrder I] (c : I → ι) :
    OrderedMonadicStructure (colourSig ι) where
  carrier := I
  interp := fun p i => c i = p
  carrierOrder := inferInstance

@[simp] theorem colourStructure_interp {ι I : Type} [LinearOrder I] (c : I → ι)
    (z : ι) (i : I) : (colourStructure I c).interp z i ↔ c i = z := Iff.rfl

/-- The `k`-type colouring of an index set by its summands — *"which sentences of `Z` does the
summand at `i` satisfy"*, in the source's notation `{i | m(i) ⊨ σ}`. -/
noncomputable def kTypeColouring (sig : MonadicSignature) (k : Nat) {I : Type} [LinearOrder I]
    (m : I → OrderedMonadicStructure sig) : OrderedMonadicStructure (colourSig (KType sig k)) :=
  colourStructure I (fun i => kTypeOf sig k (m i))

/-! ## Shuffle colourings -/

/--
**`c` is a shuffle colouring over the palette `S`.**

Reynolds' density condition (`IsShuffleMap`, `RealModel/Shuffle.lean:320`), stated for an
arbitrary index order rather than for `ℚ` or `ℝ` specifically. The endpoint and nonemptiness
clauses are what let a new point be answered when it falls below, above, or outside the whole of
a finite matched configuration.
-/
structure IsShuffleColouring {ι I : Type} [LinearOrder I] (S : Set ι) (c : I → ι) : Prop where
  /-- Every index carries a colour of the palette. -/
  mem_palette : ∀ i : I, c i ∈ S
  /-- Every colour of the palette occurs strictly inside every nonempty open interval. -/
  colour_dense : ∀ z ∈ S, ∀ x y : I, x < y → ∃ t : I, x < t ∧ t < y ∧ c t = z
  /-- No least element. -/
  exists_lt : ∀ x : I, ∃ y : I, y < x
  /-- No greatest element. -/
  exists_gt : ∀ x : I, ∃ y : I, x < y
  /-- The order is nonempty. -/
  nonempty : Nonempty I

namespace IsShuffleColouring

variable {ι I : Type} [LinearOrder I] {S : Set ι} {c : I → ι}

/-- Every colour of the palette occurs strictly below any given point. -/
theorem exists_colour_lt (h : IsShuffleColouring S c) {z : ι} (hz : z ∈ S) (x : I) :
    ∃ t : I, t < x ∧ c t = z := by
  obtain ⟨y, hy⟩ := h.exists_lt x
  obtain ⟨t, _, ht₂, ht₃⟩ := h.colour_dense z hz y x hy
  exact ⟨t, ht₂, ht₃⟩

/-- Every colour of the palette occurs strictly above any given point. -/
theorem exists_colour_gt (h : IsShuffleColouring S c) {z : ι} (hz : z ∈ S) (x : I) :
    ∃ t : I, x < t ∧ c t = z := by
  obtain ⟨y, hy⟩ := h.exists_gt x
  obtain ⟨t, ht₁, _, ht₃⟩ := h.colour_dense z hz x y hy
  exact ⟨t, ht₁, ht₃⟩

/-- Every colour of the palette occurs somewhere. -/
theorem exists_colour (h : IsShuffleColouring S c) {z : ι} (hz : z ∈ S) :
    ∃ t : I, c t = z := by
  obtain ⟨x⟩ := h.nonempty
  obtain ⟨t, _, ht⟩ := h.exists_colour_gt hz x
  exact ⟨t, ht⟩

/-- Recolouring along any map of palettes preserves the shuffle condition. Used to pass from a
colouring by the shuffle palette `ι` to the colouring by `k`-types that Doets 3.1.8 requires. -/
theorem map {ι' : Type} (h : IsShuffleColouring S c) (f : ι → ι') :
    IsShuffleColouring (f '' S) (fun i => f (c i)) where
  mem_palette i := ⟨c i, h.mem_palette i, rfl⟩
  colour_dense := by
    rintro _ ⟨w, hw, rfl⟩ x y hxy
    obtain ⟨t, ht₁, ht₂, ht₃⟩ := h.colour_dense w hw x y hxy
    exact ⟨t, ht₁, ht₂, by rw [ht₃]⟩
  exists_lt := h.exists_lt
  exists_gt := h.exists_gt
  nonempty := h.nonempty

end IsShuffleColouring

/-! ## Atom agreement for coloured orders

An atom of `colourSig ι` is either a colour predicate applied to a variable or an order
comparison of two variables. So two environments agree on all atoms exactly when they are
colour-preserving and order-preserving — the invariant the back-and-forth maintains.
-/

theorem colour_atom_agree {ι I J : Type} [LinearOrder I] [LinearOrder J]
    (c : I → ι) (c' : J → ι) {n : Nat} (eI : Fin n → I) (eJ : Fin n → J)
    (hord : ∀ p q : Fin n, eI p < eI q ↔ eJ p < eJ q)
    (hcol : ∀ p : Fin n, c (eI p) = c' (eJ p)) :
    ∀ ak : AtomKind (colourSig ι) n,
      AtomEval (colourStructure I c) eI ak ↔ AtomEval (colourStructure J c') eJ ak := by
  intro ak
  cases ak with
  | pred z i =>
    show c (eI i) = z ↔ c' (eJ i) = z
    rw [hcol i]
  | order i j _ => exact hord i j

/-! ## The matching step

The combinatorial heart: a new point `b` on the `J` side is answered by a point `a` on the `I`
side of the same colour, sitting in the corresponding gap of the finite matched configuration.
-/

open scoped Classical in
/--
**The answering point exists.** Given a finite order- and colour-preserving matching between
`eI` and `eJ`, and any `b : J`, there is `a : I` of the same colour standing in the same order
relation to every matched point.

The four cases are: `b` already matched (answer with its partner); `b` inside a gap of the
matched configuration (density of `c' b`'s colour in that gap); `b` above/below everything (no
endpoints, then density); and the configuration empty (the palette colour occurs somewhere).
-/
theorem exists_matching_point {ι I J : Type} [LinearOrder I] [LinearOrder J]
    {S : Set ι} {c : I → ι} {c' : J → ι}
    (h : IsShuffleColouring S c) (h' : IsShuffleColouring S c')
    {n : Nat} (eI : Fin n → I) (eJ : Fin n → J)
    (hord : ∀ p q : Fin n, eI p < eI q ↔ eJ p < eJ q)
    (hcol : ∀ p : Fin n, c (eI p) = c' (eJ p))
    (b : J) :
    ∃ a : I, c a = c' b ∧
      ∀ p : Fin n, (eI p < a ↔ eJ p < b) ∧ (a < eI p ↔ b < eJ p) := by
  classical
  have hzS : c' b ∈ S := h'.mem_palette b
  by_cases hEq : ∃ p : Fin n, eJ p = b
  · -- `b` is already matched: answer with its partner.
    obtain ⟨p, hp⟩ := hEq
    refine ⟨eI p, by rw [hcol p, hp], fun q => ⟨?_, ?_⟩⟩
    · rw [hord q p, hp]
    · rw [hord p q, hp]
  · -- `b` is distinct from every matched point, so every position is strictly below or above.
    have hsplit : ∀ p : Fin n, eJ p < b ∨ b < eJ p := by
      intro p
      rcases lt_trichotomy (eJ p) b with hlt | heq | hgt
      · exact Or.inl hlt
      · exact absurd ⟨p, heq⟩ hEq
      · exact Or.inr hgt
    -- The `I`-images of the positions below `b`, and of those above `b`.
    set Lo : Finset I := (Finset.univ.filter (fun p : Fin n => eJ p < b)).image eI with hLo
    set Hi : Finset I := (Finset.univ.filter (fun p : Fin n => b < eJ p)).image eI with hHi
    have hLo_mem : ∀ p : Fin n, eJ p < b → eI p ∈ Lo := fun p hp => by
      rw [hLo]
      exact Finset.mem_image_of_mem eI (Finset.mem_filter.mpr ⟨Finset.mem_univ p, hp⟩)
    have hHi_mem : ∀ p : Fin n, b < eJ p → eI p ∈ Hi := fun p hp => by
      rw [hHi]
      exact Finset.mem_image_of_mem eI (Finset.mem_filter.mpr ⟨Finset.mem_univ p, hp⟩)
    have hLo_spec : ∀ x ∈ Lo, ∃ p : Fin n, eJ p < b ∧ eI p = x := by
      intro x hx
      rw [hLo] at hx
      obtain ⟨p, hp, hpx⟩ := Finset.mem_image.mp hx
      exact ⟨p, (Finset.mem_filter.mp hp).2, hpx⟩
    have hHi_spec : ∀ x ∈ Hi, ∃ p : Fin n, b < eJ p ∧ eI p = x := by
      intro x hx
      rw [hHi] at hx
      obtain ⟨p, hp, hpx⟩ := Finset.mem_image.mp hx
      exact ⟨p, (Finset.mem_filter.mp hp).2, hpx⟩
    -- Find a point of the right colour strictly above every `Lo` value and below every `Hi` one.
    have key : ∃ a : I, c a = c' b ∧ (∀ x ∈ Lo, x < a) ∧ (∀ x ∈ Hi, a < x) := by
      by_cases hLne : Lo.Nonempty
      · by_cases hHne : Hi.Nonempty
        · have hmax : ∀ x ∈ Lo, x ≤ Lo.max' hLne := fun x hx => Finset.le_max' Lo x hx
          have hmin : ∀ x ∈ Hi, Hi.min' hHne ≤ x := fun x hx => Finset.min'_le Hi x hx
          have hgap : Lo.max' hLne < Hi.min' hHne := by
            obtain ⟨p, hpb, hpx⟩ := hLo_spec _ (Lo.max'_mem hLne)
            obtain ⟨q, hqb, hqx⟩ := hHi_spec _ (Hi.min'_mem hHne)
            have : eI p < eI q := (hord p q).mpr (hpb.trans hqb)
            rwa [hpx, hqx] at this
          obtain ⟨a, ha₁, ha₂, ha₃⟩ := h.colour_dense (c' b) hzS _ _ hgap
          exact ⟨a, ha₃, fun x hx => lt_of_le_of_lt (hmax x hx) ha₁,
            fun x hx => lt_of_lt_of_le ha₂ (hmin x hx)⟩
        · have hmax : ∀ x ∈ Lo, x ≤ Lo.max' hLne := fun x hx => Finset.le_max' Lo x hx
          obtain ⟨a, ha₁, ha₂⟩ := h.exists_colour_gt hzS (Lo.max' hLne)
          exact ⟨a, ha₂, fun x hx => lt_of_le_of_lt (hmax x hx) ha₁,
            fun x hx => absurd ⟨x, hx⟩ hHne⟩
      · by_cases hHne : Hi.Nonempty
        · have hmin : ∀ x ∈ Hi, Hi.min' hHne ≤ x := fun x hx => Finset.min'_le Hi x hx
          obtain ⟨a, ha₁, ha₂⟩ := h.exists_colour_lt hzS (Hi.min' hHne)
          exact ⟨a, ha₂, fun x hx => absurd ⟨x, hx⟩ hLne,
            fun x hx => lt_of_lt_of_le ha₁ (hmin x hx)⟩
        · obtain ⟨a, ha⟩ := h.exists_colour hzS
          exact ⟨a, ha, fun x hx => absurd ⟨x, hx⟩ hLne, fun x hx => absurd ⟨x, hx⟩ hHne⟩
    obtain ⟨a, hac, hLo_lt, hHi_gt⟩ := key
    refine ⟨a, hac, fun p => ?_⟩
    rcases hsplit p with hp | hp
    · have hlt : eI p < a := hLo_lt _ (hLo_mem p hp)
      exact ⟨⟨fun _ => hp, fun _ => hlt⟩,
        ⟨fun hc => absurd (hlt.trans hc) (lt_irrefl _),
         fun hc => absurd (hc.trans hp) (lt_irrefl _)⟩⟩
    · have hgt : a < eI p := hHi_gt _ (hHi_mem p hp)
      exact ⟨⟨fun hc => absurd (hc.trans hgt) (lt_irrefl _),
              fun hc => absurd (hp.trans hc) (lt_irrefl _)⟩,
        ⟨fun _ => hp, fun _ => hgt⟩⟩

/-! ## The back-and-forth and the `≡ₖ` conclusion -/

/-- **The colour-preserving back-and-forth.** Any order- and colour-preserving finite matching
between two shuffle colourings over a common palette extends to a strategy of any depth. -/
theorem backForth_colourStructure {ι I J : Type} [LinearOrder I] [LinearOrder J]
    {S : Set ι} {c : I → ι} {c' : J → ι}
    (h : IsShuffleColouring S c) (h' : IsShuffleColouring S c') :
    ∀ (d n : Nat) (eI : Fin n → I) (eJ : Fin n → J),
      (∀ p q : Fin n, eI p < eI q ↔ eJ p < eJ q) →
      (∀ p : Fin n, c (eI p) = c' (eJ p)) →
      BackForth (colourSig ι) d n (colourStructure I c) (colourStructure J c') eI eJ := by
  intro d
  induction d with
  | zero => intro _ _ _ _ _; trivial
  | succ d ih =>
    intro n eI eJ hord hcol
    refine ⟨fun b => ?_, fun a => ?_⟩
    · obtain ⟨a, hac, hab⟩ := exists_matching_point h h' eI eJ hord hcol b
      have hord' : ∀ p q : Fin (n + 1),
          (Fin.cons a eI : Fin (n + 1) → I) p < (Fin.cons a eI : Fin (n + 1) → I) q ↔
          (Fin.cons b eJ : Fin (n + 1) → J) p < (Fin.cons b eJ : Fin (n + 1) → J) q := by
        intro p q
        cases p using Fin.cases with
        | zero =>
          cases q using Fin.cases with
          | zero => exact iff_of_false (lt_irrefl _) (lt_irrefl _)
          | succ q => exact (hab q).2
        | succ p =>
          cases q using Fin.cases with
          | zero => exact (hab p).1
          | succ q => exact hord p q
      have hcol' : ∀ p : Fin (n + 1),
          c ((Fin.cons a eI : Fin (n + 1) → I) p) =
          c' ((Fin.cons b eJ : Fin (n + 1) → J) p) := by
        intro p
        cases p using Fin.cases with
        | zero => exact hac
        | succ p => exact hcol p
      exact ⟨a, colour_atom_agree c c' _ _ hord' hcol', ih (n + 1) _ _ hord' hcol'⟩
    · obtain ⟨b, hbc, hba⟩ := exists_matching_point h' h eJ eI
        (fun p q => (hord p q).symm) (fun p => (hcol p).symm) a
      have hord' : ∀ p q : Fin (n + 1),
          (Fin.cons a eI : Fin (n + 1) → I) p < (Fin.cons a eI : Fin (n + 1) → I) q ↔
          (Fin.cons b eJ : Fin (n + 1) → J) p < (Fin.cons b eJ : Fin (n + 1) → J) q := by
        intro p q
        cases p using Fin.cases with
        | zero =>
          cases q using Fin.cases with
          | zero => exact iff_of_false (lt_irrefl _) (lt_irrefl _)
          | succ q => exact ((hba q).2).symm
        | succ p =>
          cases q using Fin.cases with
          | zero => exact ((hba p).1).symm
          | succ q => exact hord p q
      have hcol' : ∀ p : Fin (n + 1),
          c ((Fin.cons a eI : Fin (n + 1) → I) p) =
          c' ((Fin.cons b eJ : Fin (n + 1) → J) p) := by
        intro p
        cases p using Fin.cases with
        | zero => exact hbc.symm
        | succ p => exact hcol p
      exact ⟨b, colour_atom_agree c c' _ _ hord' hcol', ih (n + 1) _ _ hord' hcol'⟩

/--
**Any two shuffle colourings over a common palette give `≡ₖ` coloured index orders.**

This is Reynolds 1992's *"another simple game argument"* (printed p.188) made precise and
proved: the coloured index orders `(ℚ, σ)` and `(ℝ, σ*)` satisfy the same monadic sentences of
depth `≤ k` in the language of the colours. Nothing here is specific to `ℚ` or `ℝ`; only the
density of each palette colour in every interval, and the absence of endpoints, are used.
-/
theorem kEquiv_colourStructure {ι I J : Type} [LinearOrder I] [LinearOrder J]
    {S : Set ι} {c : I → ι} {c' : J → ι}
    (h : IsShuffleColouring S c) (h' : IsShuffleColouring S c') (k : Nat) :
    KEquiv (colourSig ι) k (colourStructure I c) (colourStructure J c') :=
  kEquiv_of_backForth k _ _
    (backForth_colourStructure h h' k 0 Fin.elim0 Fin.elim0
      (fun p _ => Fin.elim0 p) (fun p => Fin.elim0 p))

end FormalSystem.Metalogic.WeakCanonical
