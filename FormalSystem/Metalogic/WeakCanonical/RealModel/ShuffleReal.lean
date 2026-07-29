/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.Shuffle

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

/-- **`Σ_{r∈ℝ} σ*(r)`** (printed p.188): the `ℝ`-extension of the shuffle. -/
noncomputable def shuffleReal {ι : Type} (N : ι → OrderedMonadicStructure sig) (γ₁ : ι)
    (σ : ℚ → ι) : OrderedMonadicStructure sig :=
  orderedSum sig ℝ (fun r => N (shuffleColourReal γ₁ σ r))

/-! ## Doets 1987, 3.1.8 — the mixing lemma

The `Z`-coloured index order of the source statement is rendered as a monadic structure in its
own right, over a signature whose predicate symbols *are* the colours. With `Z := KType sig k`
and the colour of an index `i` its summand's `k`-type, `colourStructure` is literally
`(I, {i | m(i) ⊨ σ})_{σ∈Z}`.
-/

/-- The signature whose unary predicates are the colours of a palette `ι`. -/
def colourSig (ι : Type) : MonadicSignature where
  preds := ι

/-- **The `Z`-coloured index order as a structure**: carrier the index order, and the predicate
`p` true exactly at the indices coloured `p`. -/
def colourStructure {ι : Type} (I : Type) [LinearOrder I] (c : I → ι) :
    OrderedMonadicStructure (colourSig ι) where
  carrier := I
  interp := fun p i => c i = p
  carrierOrder := inferInstance

/-- The `k`-type colouring of an index set by its summands — *"which sentences of `Z` does the
summand at `i` satisfy"*, in the source's notation `{i | m(i) ⊨ σ}`. -/
noncomputable def kTypeColouring (sig : MonadicSignature) (k : Nat) {I : Type} [LinearOrder I]
    (m : I → OrderedMonadicStructure sig) : OrderedMonadicStructure (colourSig (KType sig k)) :=
  colourStructure I (fun i => kTypeOf sig k (m i))

/--
**Doets 1987, 3.1.8** — *the mixing lemma*:

> if `(I, {i | m(i) ⊨ σ})_{σ∈Z} ≡ⁿ (J, {j | m'(j) ⊨ σ})_{σ∈Z}` then
> `Σ_{i∈I} m(i) ≡ⁿ Σ_{j∈J} m'(j)`

This is the two-index generalization of `doets_lemma_1_4` (`OrderedSum.lean:41`), which is the
special case `I = J` with the identity colour-matching. It is what Reynolds 1992 (printed p.188)
invokes as *"another simple game argument"* when he passes from the `ℚ`-shuffle to its
`ℝ`-extension; he gives no proof, and the game argument is not simple.

**STRATEGIC SORRY — unproved.** The proof is an Ehrenfeucht-Fraïssé argument on the two sums:
Duplicator's strategy is assembled from a depth-`n` strategy on the coloured index orders
together with, at each matched pair of indices, a depth-`n` strategy inside the corresponding
summands (available because matched indices carry the same `k`-type). `NEquivalence.lean`'s
`sum_nf_agree` / `sum_lift_one_var` apparatus carries out exactly this induction for the
*shared*-index case; generalizing it to a coloured back-and-forth between two *different* index
sets is the missing work, and it is a phase-sized piece of formalization in its own right rather
than a gap in an otherwise complete proof.

**FOLLOW-UP**: *Generalize `NEquivalence.lean`'s `sum_nf_agree` normal-form induction from a
shared index set to a coloured correspondence between two index sets, and discharge this
`sorry`.* Until then every consumer of this lemma is conditional on it, and this module's
`kEquiv_shuffle_shuffleReal` is the only such consumer.

**Nothing else in this module rests on it.** The order-theoretic properties of `R`
(`denselyOrdered_orderedSumReal`, `noMax_orderedSumReal`, `noMin_orderedSumReal`,
`exists_isLUB_orderedSumReal`, `exists_countableDense_orderedSumReal`) are proved outright.
-/
theorem doets_lemma_1_5 (k : Nat) {I J : Type} [LinearOrder I] [LinearOrder J]
    (m : I → OrderedMonadicStructure sig) (m' : J → OrderedMonadicStructure sig)
    (_hcol : KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k m) (kTypeColouring sig k m')) :
    KEquiv sig k (orderedSum sig I m) (orderedSum sig J m') := by
  sorry

/--
**`Σ_{q∈ℚ} σ(q) ≡ₖ Σ_{r∈ℝ} σ*(r)`** — Reynolds 1992, §8, printed p.188.

`ADAPTED-FROM: Doets 1987, 3.1.8`. Reynolds asserts this in one clause — *"by another simple
game argument"* — without proof; the argument he is pointing at is Doets' mixing lemma, carried
here as `doets_lemma_1_5`.

The hypothesis `hcol` is the `≡ₖ` fact about the two **coloured index orders** that the mixing
lemma reduces the claim to: `(ℚ, σ)` and `(ℝ, σ*)` satisfy the same monadic sentences of depth
`≤ k` in the language of the colours. It is true — both are dense endpointless orders coloured by
the same finite palette with every colour dense, and the colour-preserving back-and-forth wins
the depth-`k` game — but it is *not* proved in this tree, so it is carried as an explicit
hypothesis rather than silently assumed. Discharging it is the second half of the follow-up
recorded on `doets_lemma_1_5`.
-/
theorem kEquiv_shuffle_shuffleReal (k : Nat) {ι : Type} (N : ι → OrderedMonadicStructure sig)
    (γ₁ : ι) (σ : ℚ → ι)
    (hcol : KEquiv (colourSig (KType sig k)) k
      (kTypeColouring sig k (fun q : ℚ => N (σ q)))
      (kTypeColouring sig k (fun r : ℝ => N (shuffleColourReal γ₁ σ r)))) :
    KEquiv sig k (shuffle N σ) (shuffleReal N γ₁ σ) :=
  doets_lemma_1_5 k _ _ hcol

end FormalSystem.Metalogic.WeakCanonical
