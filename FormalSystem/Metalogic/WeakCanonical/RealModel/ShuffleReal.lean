/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.Shuffle
import FormalSystem.Metalogic.WeakCanonical.MixedSum
import FormalSystem.Metalogic.WeakCanonical.RealModel.OrderIsoReal

/-!
# The `ℝ`-extension of the shuffle

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **p.188**.

`Shuffle.lean` landed the `ℚ`-shuffle `Σ_{q∈ℚ} σ(q)` and the identification
`M | (⋃ I) ≡ₖ Σ_{q∈ℚ} σ(q)`. This module takes the next step of the printed proof: replace the
`ℚ`-indexed shuffle by an `ℝ`-indexed one, and establish the four order-theoretic properties of
the resulting flow that Phase 28's characterization of `ℝ` consumes.

## The source, verbatim

Printed p.188:

> Now let `σ*` be the extension of `σ` to `ℝ` given by `σ*(i) = N_{γ₁}` for `i ∈ ℝ − ℚ`, where
> `γ₁` is a `γ` in `G` which is only satisfied by one point structures. By another simple game
> argument we have `Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`.
>
> Let `R` be the flow of time of `Σ_{r∈ℝ} σ*(r)`. Clearly `R` is dense and without end points.
> `R` is also Dedekind complete: any subset bounded above intersects a last summand. Because the
> `γᵢ`'s say so the summands themselves are closed intervals of the reals so the supremum of the
> set exists in this class. Also `R` has a countable dense subflow.
>
> But then `R` being Dedekind complete, dense, without end points and with a countable dense
> subset must be isomorphic to the reals.

## What is landed here, and what is not

`shuffleColourReal` is `σ*`; `shuffleReal` is `Σ_{r∈ℝ} σ*(r)`.

**`doets_lemma_1_5` is stated but not proved.** Reynolds' *"another simple game argument"* is one
clause long and is not a proof. The result it names is **Doets 1987, 3.1.8** — the *mixing*
lemma:

> if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
> `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`

which reduces the claim to a `≡ⁿ` fact about the `Z`-coloured index orders. That is the form
`doets_lemma_1_5` below carries, with `Z` taken to be `KType sig k` (finite, by
`normalFormFintype`) and the colouring of an index the `k`-type of its summand — literally
*"which sentences of `Z` the summand satisfies"*.

The proof is a genuine Ehrenfeucht-Fraïssé argument on the sums, generalizing
`doets_lemma_1_4`'s (`OrderedSum.lean:41`) normal-form induction from a *shared* index set to a
*coloured back-and-forth between two different* index sets. `NEquivalence.lean`'s
`sum_nf_agree` apparatus proves the shared-index case; the two-index case is not in the tree and
is not derived here. It is carried as a documented strategic `sorry` with the follow-up named in
the docstring, exactly as the honesty charter requires, rather than as a false or vacuous
statement. **Nothing else in this module depends on it**: the order-theoretic content of `R`
below is independent and sorry-free.

The `≡ₖ` fact about the coloured index orders themselves — that `(ℚ, σ)` and `(ℝ, σ*)`, both
densely coloured by the same finite palette, are `≡ₖ` — is likewise not proved here. It is
carried as an **explicit hypothesis** of `kEquiv_shuffle_shuffleReal` rather than as a second
`sorry`, so a reader of that theorem's statement can see precisely what remains open.

## References
- Reynolds 1992, §8, printed p.188:
  `literature/sources/reynolds_1992/sec04_7-separability.md`
- Doets 1987/1989, 3.1.8 (the mixing lemma): `literature/Doets_1989_Monadic_Pi11_Theories.md`
- Doets 1989, Lemma 1.4 (shared-index case): `doets_lemma_1_4` (`OrderedSum.lean:41`)
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature} [Fintype sig.preds] [DecidableEq sig.preds]

/-! ## `σ*`: the extension of a shuffle colouring to `ℝ`

Printed p.188: *"let `σ*` be the extension of `σ` to `ℝ` given by `σ*(i) = N_{γ₁}` for
`i ∈ ℝ − ℚ`"*. The colour `γ₁` is carried as an explicit argument; the module proves nothing
about it beyond membership in the palette, and Reynolds' *"only satisfied by one point
structures"* enters only where it is actually used — in
`exists_countableDense_orderedSumReal`, as the hypothesis that the irrational summands are
subsingletons.
-/

open Classical in
/-- **`σ*`** (printed p.188): `σ` at the rationals, the distinguished colour `γ₁` elsewhere. -/
noncomputable def shuffleColourReal {ι : Type} (γ₁ : ι) (σ : ℚ → ι) (r : ℝ) : ι :=
  if h : ∃ q : ℚ, (q : ℝ) = r then σ h.choose else γ₁

/-- `σ*` agrees with `σ` at every rational. -/
@[simp] theorem shuffleColourReal_rat {ι : Type} (γ₁ : ι) (σ : ℚ → ι) (q : ℚ) :
    shuffleColourReal γ₁ σ (q : ℝ) = σ q := by
  have h : ∃ p : ℚ, (p : ℝ) = (q : ℝ) := ⟨q, rfl⟩
  rw [shuffleColourReal, dif_pos h]
  congr 1
  exact_mod_cast h.choose_spec

/-- `σ*` takes the value `γ₁` at every irrational. -/
theorem shuffleColourReal_irrational {ι : Type} (γ₁ : ι) (σ : ℚ → ι) {r : ℝ}
    (hr : ¬ ∃ q : ℚ, (q : ℝ) = r) : shuffleColourReal γ₁ σ r = γ₁ := by
  rw [shuffleColourReal, dif_neg hr]

/-- **Reynolds' density condition, read at `ℝ`.** The `ℚ`-form is `IsShuffleMap`
(`Shuffle.lean:320`); this is the same condition with the index order `ℝ`, and is what the
`ℝ`-shuffle's order-theoretic facts consume. -/
def IsShuffleMapReal {ι : Type} (S : Finset ι) (π : ℝ → ι) : Prop :=
  (∀ r : ℝ, π r ∈ S) ∧
    ∀ i ∈ S, ∀ r s : ℝ, r < s → ∃ t : ℝ, r < t ∧ t < s ∧ π t = i

/-- **`σ*` is again a shuffle colouring** — every colour of the palette is taken somewhere
strictly inside every *real* interval.

This is the one place the density of `ℚ` in `ℝ` enters: a real interval contains a rational
interval, and `σ` already takes every colour strictly inside that. -/
theorem isShuffleMapReal_shuffleColourReal {ι : Type} {S : Finset ι} {γ₁ : ι} {σ : ℚ → ι}
    (hγ : γ₁ ∈ S) (hσ : IsShuffleMap S σ) :
    IsShuffleMapReal S (shuffleColourReal γ₁ σ) := by
  refine ⟨fun r => ?_, ?_⟩
  · rw [shuffleColourReal]
    split
    · exact hσ.1 _
    · exact hγ
  · intro i hi r s hrs
    obtain ⟨q₁, hrq₁, hq₁s⟩ := exists_rat_btwn hrs
    obtain ⟨q₂, hq₁q₂, hq₂s⟩ := exists_rat_btwn hq₁s
    have hq₁q₂' : q₁ < q₂ := by exact_mod_cast hq₁q₂
    obtain ⟨t, ht₁, ht₂, hteq⟩ := hσ.2 i hi q₁ q₂ hq₁q₂'
    refine ⟨(t : ℝ), lt_trans hrq₁ (by exact_mod_cast ht₁),
      lt_trans (by exact_mod_cast ht₂) hq₂s, ?_⟩
    rw [shuffleColourReal_rat, hteq]

/-! ### The two shuffle colourings, in the form the coloured-order game consumes

`IsShuffleMap` / `IsShuffleMapReal` state Reynolds' density condition for the concrete index
orders `ℚ` and `ℝ`. `IsShuffleColouring` (`ColourOrders.lean`) states it for an arbitrary index
order, adding the endpoint and nonemptiness clauses that `ℚ` and `ℝ` satisfy outright. These two
lemmas are the bridge, and they are what lets `kEquiv_colourStructure` be applied to the pair
`(ℚ, σ)`, `(ℝ, σ*)`.
-/

/-- `σ` is a shuffle colouring of `ℚ` over the palette `S`. -/
theorem isShuffleColouring_of_isShuffleMap {ι : Type} {S : Finset ι} {σ : ℚ → ι}
    (hσ : IsShuffleMap S σ) : IsShuffleColouring (↑S : Set ι) σ where
  mem_palette i := Finset.mem_coe.mpr (hσ.1 i)
  colour_dense z hz x y hxy := hσ.2 z (Finset.mem_coe.mp hz) x y hxy
  exists_lt x := ⟨x - 1, by linarith⟩
  exists_gt x := ⟨x + 1, by linarith⟩
  nonempty := ⟨0⟩

/-- `σ*` is a shuffle colouring of `ℝ` over the same palette `S`. -/
theorem isShuffleColouring_of_isShuffleMapReal {ι : Type} {S : Finset ι} {π : ℝ → ι}
    (hπ : IsShuffleMapReal S π) : IsShuffleColouring (↑S : Set ι) π where
  mem_palette r := Finset.mem_coe.mpr (hπ.1 r)
  colour_dense z hz x y hxy := hπ.2 z (Finset.mem_coe.mp hz) x y hxy
  exists_lt x := ⟨x - 1, by linarith⟩
  exists_gt x := ⟨x + 1, by linarith⟩
  nonempty := ⟨0⟩

/-- **`Σ_{r∈ℝ} σ*(r)`** (printed p.188): the `ℝ`-extension of the shuffle. -/
noncomputable def shuffleReal {ι : Type} (N : ι → OrderedMonadicStructure sig) (γ₁ : ι)
    (σ : ℚ → ι) : OrderedMonadicStructure sig :=
  orderedSum sig ℝ (fun r => N (shuffleColourReal γ₁ σ r))

/-! ## Doets 1987, 3.1.8 — the mixing lemma

The `Z`-coloured index order of the source statement is rendered as a monadic structure in its
own right, over a signature whose predicate symbols *are* the colours. With `Z := KType sig k`
and the colour of an index `i` its summand's `k`-type, `colourStructure` is literally
`(I, {i | m(i) ⊨ σ})_{σ∈Z}`.

`colourSig`, `colourStructure` and `kTypeColouring` live in `ColourOrders.lean`, together with
the proof that any two shuffle colourings over a common palette give `≡ₖ` coloured orders. The
*mixing* half is `MixedSum.lean`'s `kEquiv_orderedSum_of_kEquiv_colour`; the statement is
restated here under Doets' numbering, which is how the rest of this file refers to it.
-/

/--
**Doets 1987, 3.1.8** — *the mixing lemma*:

> if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
> `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`

This is the two-index generalization of `doets_lemma_1_4` (`OrderedSum.lean:41`), which is the
special case `I = J` with the identity colour-matching. It is what Reynolds 1992 (printed p.188)
invokes as *"another simple game argument"* when he passes from the `ℚ`-shuffle to its
`ℝ`-extension; he gives no proof, and the game argument is not simple.

**Proved** in `MixedSum.lean`, by the Ehrenfeucht-Fraïssé argument on the two sums: Duplicator's
strategy is assembled from a depth-`k` strategy on the coloured index orders together with, at
each matched pair of indices, a depth-`k` strategy inside the corresponding summands — available
because matched indices carry the same `k`-type, which is exactly what the hypothesis says.

`BackAndForth.lean` supplies the engine (`BackForth` for an arbitrary **pair** of structures, and
`kEquiv_iff_backForth` converting it to and from `≡ₖ`); `MixedSum.lean`'s `Mixed` is the invariant
that assembles the two families of strategies, and `backForth_of_mixed` runs the induction.

**Nothing in this module is conditional any longer.** The order-theoretic properties of `R`
(`denselyOrdered_orderedSumReal`, `noMax_orderedSumReal`, `noMin_orderedSumReal`,
`exists_isLUB_orderedSumReal`, `exists_countableDense_orderedSumReal`) were already proved
outright, and `kEquiv_shuffle_shuffleReal` — this lemma's only consumer — now is too.
-/
theorem doets_lemma_1_5 (k : Nat) {I J : Type} [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (hcol : KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k m) (kTypeColouring sig k m')) :
    KEquiv sig k (orderedSum sig I m) (orderedSum sig J m') :=
  kEquiv_orderedSum_of_kEquiv_colour k m m' hcol

/--
**`Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`** — Reynolds 1992, §8, printed p.188.

`ADAPTED-FROM: Doets 1987, 3.1.8`. Reynolds asserts this in one clause — *"by another simple
game argument"* — without proof; the argument he is pointing at is Doets' mixing lemma, carried
here as `doets_lemma_1_5`.

The `≡ₖ` fact about the two **coloured index orders** that the mixing lemma reduces the claim to
— that `(ℚ, σ)` and `(ℝ, σ*)` satisfy the same monadic sentences of depth `≤ k` in the language
of the colours — is now **proved**, by `kEquiv_colourStructure` (`ColourOrders.lean`): both are
dense endpointless orders coloured by the same palette with every colour dense in every
interval, so the colour-preserving back-and-forth wins the depth-`k` game. It was carried as an
explicit hypothesis `hcol` while it was open; that hypothesis is gone, replaced by the shuffle
data `hγ` and `hσ` it was always a consequence of.

The only thing this theorem is still conditional on is `doets_lemma_1_5` itself.
-/
theorem kEquiv_shuffle_shuffleReal (k : Nat) {ι : Type} {S : Finset ι}
    (N : ι → OrderedMonadicStructure sig) {γ₁ : ι} {σ : ℚ → ι}
    (hγ : γ₁ ∈ S) (hσ : IsShuffleMap S σ) :
    KEquiv sig k (shuffle N σ) (shuffleReal N γ₁ σ) :=
  doets_lemma_1_5 k _ _
    (kEquiv_colourStructure
      ((isShuffleColouring_of_isShuffleMap hσ).map (fun i => kTypeOf sig k (N i)))
      ((isShuffleColouring_of_isShuffleMapReal
        (isShuffleMapReal_shuffleColourReal hγ hσ)).map (fun i => kTypeOf sig k (N i))) k)

/-! ## The flow `R` of `Σ_{r∈ℝ} σ*(r)`

Printed p.188: *"Let `R` be the flow of time of `Σ_{r∈ℝ} σ*(r)`. Clearly `R` is dense and without
end points. `R` is also Dedekind complete: any subset bounded above intersects a last summand.
Because the `γᵢ`'s say so the summands themselves are closed intervals of the reals so the
supremum of the set exists in this class. Also `R` has a countable dense subflow."*

The four facts are proved for an arbitrary `ℝ`-indexed family and then specialized to the
shuffle, because none of them uses anything about the summands beyond the order-theoretic
hypotheses stated: nonemptiness, internal density, internal completeness with a least element,
internal separability, and — for the countable dense subflow only — that the summands at the
*irrationals* are subsingletons. That last hypothesis is where Reynolds' choice of `γ₁` as
*"a `γ` in `G` which is only satisfied by one point structures"* does its work: without it, `R`
would have `ℝ`-many pairwise-separated pairs of points and no countable dense subset.

`orderedSum` is deliberately not reducible (see its docstring), so the four small transfer lemmas
between the lexicographic order and its components are stated once here rather than unfolded at
each use.
-/

section OrderFacts

/-! The four transfer lemmas are stated through `orderedSumPt` (`NEquivalence.lean:155`) rather
than through an anonymous `⟨r, a⟩`. An anonymous sigma literal forces its expected type to weak
head normal form, which unfolds `.carrier` to the raw `Sigma` type; typeclass search then finds
Mathlib's *non-lexicographic* `Sigma.instLE` in preference to the structure's `carrierOrder`, and
the statement silently becomes one about the wrong order. This is exactly the hazard
`orderedSum`'s docstring warns about, met here for `LE` rather than for `LinearOrder`. -/

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- A strictly smaller index gives a strictly smaller point of the sum. -/
private theorem osLt_of_fst_lt {fam : ℝ → OrderedMonadicStructure sig}
    {x y : (orderedSum sig ℝ fam).carrier} (h : x.1 < y.1) : x < y :=
  Sigma.Lex.lt_def.mpr (Or.inl h)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Within one summand, the component order is the induced order. -/
private theorem osLe_of_snd_le {fam : ℝ → OrderedMonadicStructure sig} {r : ℝ}
    {a b : (fam r).carrier} (h : a ≤ b) :
    orderedSumPt (ms := fam) r a ≤ orderedSumPt (ms := fam) r b := by
  rcases eq_or_lt_of_le h with rfl | hlt
  · exact le_refl _
  · exact le_of_lt (Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, hlt⟩))

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The index is monotone in the sum order. -/
private theorem osFst_le_of_le {fam : ℝ → OrderedMonadicStructure sig}
    {x y : (orderedSum sig ℝ fam).carrier} (h : x ≤ y) : x.1 ≤ y.1 := by
  by_contra hc
  exact absurd h (not_le.mpr (osLt_of_fst_lt (not_le.mp hc)))

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Within one summand, the sum order reflects to the component order. -/
private theorem osSnd_le_of_le {fam : ℝ → OrderedMonadicStructure sig} {r : ℝ}
    {a b : (fam r).carrier}
    (h : orderedSumPt (ms := fam) r a ≤ orderedSumPt (ms := fam) r b) : a ≤ b := by
  by_contra hc
  exact absurd h (not_le.mpr (Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, not_le.mp hc⟩)))

variable (fam : ℝ → OrderedMonadicStructure sig)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **`R` is dense** (printed p.188).

Two points in different summands are separated by a whole summand, because `ℝ` is densely
ordered and every summand is inhabited; two points in the same summand are separated inside it.
The second clause is why the singleton summands at the irrationals cost nothing: a subsingleton
summand has no pair to separate. -/
theorem denselyOrdered_orderedSumReal
    (hne : ∀ r : ℝ, Nonempty (fam r).carrier)
    (hdense : ∀ r : ℝ, ∀ x y : (fam r).carrier, x < y → ∃ z : (fam r).carrier, x < z ∧ z < y) :
    ∀ x y : (orderedSum sig ℝ fam).carrier, x < y →
      ∃ z : (orderedSum sig ℝ fam).carrier, x < z ∧ z < y := by
  rintro ⟨r, a⟩ ⟨s, b⟩ hlt
  rcases Sigma.Lex.lt_def.mp hlt with hrs | ⟨hrs, hab⟩
  · obtain ⟨t, hrt, hts⟩ := exists_between hrs
    exact ⟨⟨t, (hne t).some⟩, osLt_of_fst_lt hrt, osLt_of_fst_lt hts⟩
  · have heq : r = s := hrs
    subst heq
    obtain ⟨z, hz₁, hz₂⟩ := hdense r a b hab
    exact ⟨⟨r, z⟩, Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, hz₁⟩),
      Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, hz₂⟩)⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **`R` has no last point** (printed p.188): `ℝ` has none, and the later summands are
inhabited. -/
theorem noMax_orderedSumReal (hne : ∀ r : ℝ, Nonempty (fam r).carrier) :
    ∀ x : (orderedSum sig ℝ fam).carrier, ∃ y : (orderedSum sig ℝ fam).carrier, x < y := by
  rintro ⟨r, a⟩
  exact ⟨⟨r + 1, (hne (r + 1)).some⟩, osLt_of_fst_lt (by simp)⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **`R` has no first point** (printed p.188). -/
theorem noMin_orderedSumReal (hne : ∀ r : ℝ, Nonempty (fam r).carrier) :
    ∀ x : (orderedSum sig ℝ fam).carrier, ∃ y : (orderedSum sig ℝ fam).carrier, y < x := by
  rintro ⟨r, a⟩
  exact ⟨⟨r - 1, (hne (r - 1)).some⟩, osLt_of_fst_lt (by simp)⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/--
**`R` is Dedekind complete** — Reynolds 1992, §8, printed p.188:

> *`R` is also Dedekind complete: any subset bounded above intersects a last summand. Because
> the `γᵢ`'s say so the summands themselves are closed intervals of the reals so the supremum of
> the set exists in this class.*

The transcription makes the printed sentence's two moves explicit and adds the case Reynolds'
*"intersects a last summand"* passes over. Let `ρ` be the supremum in `ℝ` of the indices met by
`T`, which exists because `ℝ` is complete.

* If `T` does meet the summand at `ρ` — Reynolds' *"intersects a last summand"* — the supremum is
  taken inside that summand, which is where *"the summands themselves are closed intervals of the
  reals"* is used: `hsum` says every inhabited subset of a summand has a least upper bound
  **in that summand**, which is exactly closedness on the right.
* If it does not, `ρ` is approached from below by indices met by `T` and the least point of the
  summand at `ρ` is the supremum; `hbot` — *"closed intervals"* again, now on the left — supplies
  it.

Stated as `∃ u, IsLUB T u` rather than through a `ConditionallyCompleteLinearOrder` instance:
the carrier is a `Sigma` type whose order comes from `orderedSum`'s `carrierOrder` field, and
registering a second order-theoretic instance on it is precisely the hazard `orderedSum`'s
docstring warns about.
-/
theorem exists_isLUB_orderedSumReal
    (hsum : ∀ r : ℝ, ∀ s : Set (fam r).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ r : ℝ, ∃ b : (fam r).carrier, ∀ x : (fam r).carrier, b ≤ x)
    (T : Set (orderedSum sig ℝ fam).carrier) (hT : T.Nonempty) (hbdd : BddAbove T) :
    ∃ u, IsLUB T u := by
  classical
  -- `P` is the set of indices met by `T`.
  set P : Set ℝ := Sigma.fst '' T with hP
  obtain ⟨z₀, hz₀⟩ := hT
  have hPne : P.Nonempty := ⟨z₀.1, ⟨z₀, hz₀, rfl⟩⟩
  obtain ⟨w, hw⟩ := hbdd
  have hPbdd : BddAbove P := by
    refine ⟨w.1, ?_⟩
    rintro _ ⟨z, hzT, rfl⟩
    exact osFst_le_of_le (hw hzT)
  obtain ⟨ρ, hρ⟩ : ∃ ρ : ℝ, IsLUB P ρ := ⟨sSup P, isLUB_csSup hPne hPbdd⟩
  -- Any upper bound of `T` has index at least every index met by `T`.
  have hub_fst : ∀ y : (orderedSum sig ℝ fam).carrier, y ∈ upperBounds T →
      ∀ r ∈ P, r ≤ y.1 := by
    rintro y hy _ ⟨z, hzT, rfl⟩
    exact osFst_le_of_le (hy hzT)
  by_cases hmem : ρ ∈ P
  · -- Reynolds' case: `T` meets the last summand.
    obtain ⟨z, hzT, hzfst⟩ := hmem
    obtain ⟨rz, xz⟩ := z
    simp only at hzfst
    subst hzfst
    set Tρ : Set (fam rz).carrier :=
      {u | (⟨rz, u⟩ : (orderedSum sig ℝ fam).carrier) ∈ T} with hTρ
    obtain ⟨u, hu⟩ := hsum rz Tρ ⟨xz, hzT⟩
    refine ⟨⟨rz, u⟩, ?_, ?_⟩
    · rintro ⟨s, y⟩ hyT
      have hs : s ≤ rz := hρ.1 ⟨⟨s, y⟩, hyT, rfl⟩
      rcases eq_or_lt_of_le hs with rfl | hlt
      · exact osLe_of_snd_le (hu.1 hyT)
      · exact le_of_lt (osLt_of_fst_lt hlt)
    · rintro ⟨s, y⟩ hy
      have hs : rz ≤ s := osFst_le_of_le (hy hzT)
      rcases eq_or_lt_of_le hs with rfl | hlt
      · refine osLe_of_snd_le (hu.2 ?_)
        intro v hv
        exact osSnd_le_of_le (hy hv)
      · exact le_of_lt (osLt_of_fst_lt hlt)
  · -- The case Reynolds' sentence passes over: no last summand is met.
    obtain ⟨b, hb⟩ := hbot ρ
    refine ⟨⟨ρ, b⟩, ?_, ?_⟩
    · rintro ⟨s, y⟩ hyT
      have hsP : s ∈ P := ⟨⟨s, y⟩, hyT, rfl⟩
      have hs : s ≤ ρ := hρ.1 hsP
      rcases eq_or_lt_of_le hs with rfl | hlt
      · exact absurd hsP hmem
      · exact le_of_lt (osLt_of_fst_lt hlt)
    · rintro ⟨s, y⟩ hy
      have hs : ρ ≤ s := hρ.2 (hub_fst ⟨s, y⟩ hy)
      rcases eq_or_lt_of_le hs with rfl | hlt
      · exact osLe_of_snd_le (hb y)
      · exact le_of_lt (osLt_of_fst_lt hlt)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/--
**`R` has a countable dense subflow** — Reynolds 1992, §8, printed p.188 (*"Also `R` has a
countable dense subflow."*).

The witness is the union over the **rationals** of a countable dense subset of each rational
summand, together with one chosen point of each rational summand. Countability is then a
countable union of countable sets.

Density needs both hypotheses and shows what each is for. Two points in different summands are
separated by any point sitting over a rational strictly between their indices — this is why the
chosen basepoints are thrown in, since a subsingleton summand's dense subset is empty. Two
points in the *same* summand are separated inside it when the index is rational; when the index
is irrational, `hirr` says the summand is a subsingleton, so there is no such pair. That is
precisely Reynolds' reason for putting the one-point structures at `ℝ − ℚ`: a family of
non-degenerate summands over all of `ℝ` has no countable dense subset at all.
-/
theorem exists_countableDense_orderedSumReal
    (hne : ∀ r : ℝ, Nonempty (fam r).carrier)
    (hirr : ∀ r : ℝ, ¬ (∃ q : ℚ, (q : ℝ) = r) → ∀ x y : (fam r).carrier, x = y)
    (hsep : ∀ q : ℚ, ∃ D : Set (fam (q : ℝ)).carrier, D.Countable ∧
      ∀ x y : (fam (q : ℝ)).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    ∃ D : Set (orderedSum sig ℝ fam).carrier, D.Countable ∧
      ∀ x y : (orderedSum sig ℝ fam).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y := by
  classical
  choose D hDc hDd using hsep
  refine ⟨⋃ q : ℚ, (fun u : (fam (q : ℝ)).carrier =>
      (⟨(q : ℝ), u⟩ : (orderedSum sig ℝ fam).carrier)) ''
      (insert (hne (q : ℝ)).some (D q)), ?_, ?_⟩
  · exact Set.countable_iUnion (fun q => (((hDc q).insert _)).image _)
  · rintro ⟨r, a⟩ ⟨s, b⟩ hlt
    rcases Sigma.Lex.lt_def.mp hlt with hrs | ⟨hrs, hab⟩
    · obtain ⟨q, hrq, hqs⟩ := exists_rat_btwn hrs
      refine ⟨⟨(q : ℝ), (hne (q : ℝ)).some⟩, ?_, osLt_of_fst_lt hrq, osLt_of_fst_lt hqs⟩
      exact Set.mem_iUnion.mpr ⟨q, ⟨_, Set.mem_insert _ _, rfl⟩⟩
    · have heq : r = s := hrs
      subst heq
      by_cases hq : ∃ q : ℚ, (q : ℝ) = r
      · obtain ⟨q, hqr⟩ := hq
        subst hqr
        obtain ⟨d, hdD, hd₁, hd₂⟩ := hDd q a b hab
        refine ⟨⟨(q : ℝ), d⟩, ?_, Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, hd₁⟩),
          Sigma.Lex.lt_def.mpr (Or.inr ⟨rfl, hd₂⟩)⟩
        exact Set.mem_iUnion.mpr ⟨q, ⟨d, Set.mem_insert_of_mem _ hdD, rfl⟩⟩
      · exact absurd (hirr r hq a b) (ne_of_lt hab)

end OrderFacts

/-! ## The four facts at the `ℝ`-shuffle itself

`shuffleReal N γ₁ σ` is `orderedSum sig ℝ (fun r => N (σ* r))`, so the four facts above apply
verbatim once the hypotheses are read off the palette. `hone` is Reynolds' *"`γ₁` is a `γ` in `G`
which is only satisfied by one point structures"* (printed p.188) — the only place that clause is
used.
-/

section ShuffleRealFacts

variable {ι : Type} (N : ι → OrderedMonadicStructure sig) (γ₁ : ι) (σ : ℚ → ι)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow is dense** (printed p.188). -/
theorem denselyOrdered_shuffleReal
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y) :
    ∀ x y : (shuffleReal N γ₁ σ).carrier, x < y →
      ∃ z : (shuffleReal N γ₁ σ).carrier, x < z ∧ z < y :=
  denselyOrdered_orderedSumReal _ (fun _ => hne _) (fun _ => hdense _)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow has no last point** (printed p.188). -/
theorem noMax_shuffleReal (hne : ∀ i : ι, Nonempty (N i).carrier) :
    ∀ x : (shuffleReal N γ₁ σ).carrier, ∃ y : (shuffleReal N γ₁ σ).carrier, x < y :=
  noMax_orderedSumReal _ (fun _ => hne _)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow has no first point** (printed p.188). -/
theorem noMin_shuffleReal (hne : ∀ i : ι, Nonempty (N i).carrier) :
    ∀ x : (shuffleReal N γ₁ σ).carrier, ∃ y : (shuffleReal N γ₁ σ).carrier, y < x :=
  noMin_orderedSumReal _ (fun _ => hne _)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow is Dedekind complete** (printed p.188).

`hsum` and `hbot` together are *"the summands themselves are closed intervals of the reals"*. -/
theorem exists_isLUB_shuffleReal
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (T : Set (shuffleReal N γ₁ σ).carrier) (hT : T.Nonempty) (hbdd : BddAbove T) :
    ∃ u, IsLUB T u :=
  exists_isLUB_orderedSumReal _ (fun _ => hsum _) (fun _ => hbot _) T hT hbdd

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow has a countable dense subflow** (printed p.188).

`hone` is where *"`γ₁` … is only satisfied by one point structures"* is consumed. -/
theorem exists_countableDense_shuffleReal
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    ∃ D : Set (shuffleReal N γ₁ σ).carrier, D.Countable ∧
      ∀ x y : (shuffleReal N γ₁ σ).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y := by
  refine exists_countableDense_orderedSumReal _ (fun _ => hne _) (fun r hr => ?_)
    (fun q => ?_)
  · rw [shuffleColourReal_irrational γ₁ σ hr]
    exact hone
  · obtain ⟨D, hDc, hDd⟩ := hsep (shuffleColourReal γ₁ σ (q : ℝ))
    exact ⟨D, hDc, hDd⟩

end ShuffleRealFacts

/-! ## Anti-vacuity: the hypothesis bundles are satisfiable

Every order fact above is stated under hypotheses on the summands, and would be worthless if no
family satisfied them. A witness is exhibited here: the constant `ℝ`-family of one-point
structures, which satisfies *all* of the hypotheses of *all five* lemmas simultaneously. This is
not an artificial witness — it is exactly what `σ*` produces at the irrationals (printed p.188,
`γ₁` *"only satisfied by one point structures"*), so the degenerate case is on the main path
rather than beside it.
-/

section AntiVacuity

/-- The one-point structure over any signature. -/
def pointStructure (sig : MonadicSignature) : OrderedMonadicStructure sig where
  carrier := PUnit
  interp := fun _ _ => False
  carrierOrder := inferInstance

/-- The constant `ℝ`-family of one-point structures. -/
def pointFam (sig : MonadicSignature) : ℝ → OrderedMonadicStructure sig :=
  fun _ => pointStructure sig

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Every summand of `pointFam` is a subsingleton. -/
theorem pointFam_subsingleton (r : ℝ) (x y : (pointFam sig r).carrier) : x = y := rfl

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The hypotheses of all five order facts hold together** at the one-point family, so none of
them is vacuously satisfiable only. The conclusions are then instantiated below. -/
theorem pointFam_hyps :
    (∀ r : ℝ, Nonempty (pointFam sig r).carrier) ∧
    (∀ r : ℝ, ∀ x y : (pointFam sig r).carrier, x < y →
      ∃ z : (pointFam sig r).carrier, x < z ∧ z < y) ∧
    (∀ r : ℝ, ∀ s : Set (pointFam sig r).carrier, s.Nonempty → ∃ u, IsLUB s u) ∧
    (∀ r : ℝ, ∃ b : (pointFam sig r).carrier, ∀ x : (pointFam sig r).carrier, b ≤ x) ∧
    (∀ q : ℚ, ∃ D : Set (pointFam sig (q : ℝ)).carrier, D.Countable ∧
      ∀ x y : (pointFam sig (q : ℝ)).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) := by
  refine ⟨fun _ => ⟨PUnit.unit⟩, ?_, ?_, ?_, ?_⟩
  · exact fun r x y h => absurd (pointFam_subsingleton (sig := sig) r x y) (ne_of_lt h)
  · exact fun r s _ => ⟨PUnit.unit, fun a _ => le_of_eq (pointFam_subsingleton (sig := sig) r a _),
      fun b _ => le_of_eq (pointFam_subsingleton (sig := sig) r _ b)⟩
  · exact fun r => ⟨PUnit.unit, fun x => le_of_eq (pointFam_subsingleton (sig := sig) r _ x)⟩
  · exact fun q => ⟨∅, Set.countable_empty,
      fun x y h => absurd (pointFam_subsingleton (sig := sig) (q : ℝ) x y) (ne_of_lt h)⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **Anti-vacuity witness**: the one-point family's sum is dense, endpointless, Dedekind
complete and separable — every conclusion of the section, at one concrete family. -/
theorem pointFam_orderedSum_facts :
    (∀ x y : (orderedSum sig ℝ (pointFam sig)).carrier, x < y →
      ∃ z : (orderedSum sig ℝ (pointFam sig)).carrier, x < z ∧ z < y) ∧
    (∀ x : (orderedSum sig ℝ (pointFam sig)).carrier,
      ∃ y : (orderedSum sig ℝ (pointFam sig)).carrier, x < y) ∧
    (∀ x : (orderedSum sig ℝ (pointFam sig)).carrier,
      ∃ y : (orderedSum sig ℝ (pointFam sig)).carrier, y < x) ∧
    (∀ T : Set (orderedSum sig ℝ (pointFam sig)).carrier, T.Nonempty → BddAbove T →
      ∃ u, IsLUB T u) ∧
    (∃ D : Set (orderedSum sig ℝ (pointFam sig)).carrier, D.Countable ∧
      ∀ x y : (orderedSum sig ℝ (pointFam sig)).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) := by
  obtain ⟨hne, hdense, hsum, hbot, hsep⟩ := pointFam_hyps (sig := sig)
  exact ⟨denselyOrdered_orderedSumReal _ hne hdense, noMax_orderedSumReal _ hne,
    noMin_orderedSumReal _ hne,
    fun T hT hbdd => exists_isLUB_orderedSumReal _ hsum hbot T hT hbdd,
    exists_countableDense_orderedSumReal _ hne
      (fun r _ => pointFam_subsingleton (sig := sig) r) hsep⟩

end AntiVacuity

/-! ## `R ≅o ℝ` — the last sentence of the printed paragraph

> But then `R` being Dedekind complete, dense, without end points and with a countable dense
> subset must be isomorphic to the reals.

The characterization itself is `orderIsoRealOfDedekindDenseSeparable`
(`RealModel/OrderIsoReal.lean`); this section only feeds it the five facts established above.

This is also the **non-trivial anti-vacuity instantiation** that `OrderIsoReal.lean`'s docstring
points at. It is not `ℝ` in disguise: the carrier of `shuffleReal N γ₁ σ` is a lexicographically
ordered `Sigma` type over `ℝ` whose fibres are the carriers of arbitrary monadic structures, and
the isomorphism to `ℝ` is a theorem about that type, not a re-labelling of `ℝ`.
-/

section OrderIsoRealShuffle

variable {ι : Type} (N : ι → OrderedMonadicStructure sig) (γ₁ : ι) (σ : ℚ → ι)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The `ℝ`-shuffle's flow satisfies the whole hypothesis bundle of the `ℝ`-characterization**
(printed p.188). The six hypotheses are exactly the ones the five order facts above need, in the
same spelling; no clause is added here. -/
theorem isRealLike_shuffleReal
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    IsRealLike (shuffleReal N γ₁ σ).carrier where
  nonempty' := ⟨⟨(0 : ℝ), (hne (shuffleColourReal γ₁ σ (0 : ℝ))).some⟩⟩
  dense := denselyOrdered_shuffleReal N γ₁ σ hne hdense
  noMax := noMax_shuffleReal N γ₁ σ hne
  noMin := noMin_shuffleReal N γ₁ σ hne
  lub := fun S hS hbdd => exists_isLUB_shuffleReal N γ₁ σ hsum hbot S hS hbdd
  sep := exists_countableDense_shuffleReal N γ₁ σ hne hone hsep

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **The flow of `Σ_{r∈ℝ} σ*(r)` is order-isomorphic to `ℝ`** (Reynolds 1992, §8, printed p.188,
last sentence of the paragraph).

Statement source: Reynolds, as quoted. Proof: `orderIsoRealOfDedekindDenseSeparable`, which is
original to this development — Reynolds gives no proof of the characterization. -/
theorem nonempty_orderIso_real_shuffleReal
    (hne : ∀ i : ι, Nonempty (N i).carrier)
    (hdense : ∀ i : ι, ∀ x y : (N i).carrier, x < y → ∃ z : (N i).carrier, x < z ∧ z < y)
    (hsum : ∀ i : ι, ∀ s : Set (N i).carrier, s.Nonempty → ∃ u, IsLUB s u)
    (hbot : ∀ i : ι, ∃ b : (N i).carrier, ∀ x : (N i).carrier, b ≤ x)
    (hone : ∀ x y : (N γ₁).carrier, x = y)
    (hsep : ∀ i : ι, ∃ D : Set (N i).carrier, D.Countable ∧
      ∀ x y : (N i).carrier, x < y → ∃ d ∈ D, x < d ∧ d < y) :
    Nonempty ((shuffleReal N γ₁ σ).carrier ≃o ℝ) :=
  orderIsoRealOfDedekindDenseSeparable
    (isRealLike_shuffleReal N γ₁ σ hne hdense hsum hbot hone hsep)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Every point of the one-point structure equals every other. -/
theorem pointStructure_subsingleton (x y : (pointStructure sig).carrier) : x = y := rfl

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- **Anti-vacuity for the isomorphism itself**: the six hypotheses of
`nonempty_orderIso_real_shuffleReal` are jointly satisfiable, so the theorem is not vacuous. The
witness is the constant one-point palette — the degenerate case Reynolds' own `γ₁` clause puts on
the main path (printed p.188: `γ₁` is *"only satisfied by one point structures"*). Its shuffle is
`Σ_{r∈ℝ} 1`, whose flow really is a copy of `ℝ` obtained through the full construction: Cantor on
a countable dense subflow, then the cut map. -/
theorem nonempty_orderIso_real_shuffleReal_point :
    Nonempty ((shuffleReal (sig := sig) (fun _ : PUnit => pointStructure sig) PUnit.unit
      (fun _ => PUnit.unit)).carrier ≃o ℝ) := by
  refine nonempty_orderIso_real_shuffleReal _ _ _ (fun _ => ⟨PUnit.unit⟩) ?_ ?_ ?_ ?_ ?_
  · exact fun _ x y h => absurd (pointStructure_subsingleton (sig := sig) x y) (ne_of_lt h)
  · exact fun _ s _ => ⟨PUnit.unit,
      fun a _ => le_of_eq (pointStructure_subsingleton (sig := sig) a _),
      fun b _ => le_of_eq (pointStructure_subsingleton (sig := sig) _ b)⟩
  · exact fun _ => ⟨PUnit.unit, fun x => le_of_eq (pointStructure_subsingleton (sig := sig) _ x)⟩
  · exact fun x y => pointStructure_subsingleton (sig := sig) x y
  · exact fun _ => ⟨∅, Set.countable_empty, fun x y h =>
      absurd (pointStructure_subsingleton (sig := sig) x y) (ne_of_lt h)⟩

end OrderIsoRealShuffle

end FormalSystem.Metalogic.WeakCanonical
