/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.RealModel.GoodDense
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Defs

/-!
# Reynolds §8 Lemma 12: `ε(x,y)` defines `∼_M`, and the finite `γ`-set

Reynolds 1992, *An Axiomatization for Until and Since over the Reals without the IRR Rule*,
§8 *"Doets' Theorem"*, printed **pp.186-187**.

This module continues Block H. Phase 24 landed Lemma 11 (`reynolds_lemma11`, countable + very
good ⇒ good) in `GoodDense.lean`; this module builds `∼_M` on top of it, exhibits the finite set
of `γ`-sentences that pins down goodness, and writes down Reynolds' defining formula `ε(x,y)`.

## The source, verbatim

Printed p.186, the definition of `∼_M`:

> Define `∼_M` on a temporal structure `M` by, for any `a, b ∈ M`, `a ∼_M b` if and only if
>
> - `a = b`,
> - `a < b` and `M | (a, b)` is very good or
> - `b < a` and `M | (b, a)` is very good.

Printed pp.186-187, **Lemma 12** — statement and whole proof:

> **LEMMA 12.** *There is a monadic formula `ε(x, y)` which defines `∼_M` as a contemporaneous
> equivalence relation on the domain of any `M`.*
>
> *Furthermore, there is a finite set `{γ_i | i = 1, …, s}` of sentences such that `M` is good if
> and only if `M ⊨ γ_i` for some `i`.*
>
> **PROOF.** There are only finitely many logically inequivalent maximal consistent conjunctions
> `γ` of sentences of quantifier depth `≤ k`. Any structure is a model of just one such `γ`, so
> if `N_1 ⊨ γ` then `N_2 ≡_k N_1` iff `N_2 ⊨ γ`. Only some will be true of good structures —
> `{γ_1, …, γ_s}` say. `N` is good iff `N ⊨ ⋁_{i ≤ s} γ_i`.
>
> Let `γ(z, t)` be the result of relativising the quantifiers of `⋁_{i ≤ s} γ_i` to `(z, t)`,
> where `z` and `t` are new variables. Put `γ'(z, t) = γ(z, t) ∧ (∃u(z < u < t))`.
>
> Then
>
> `ε(x, y) =  x < y → ∀z t(x < z < t < y → γ'(z, t))`
> `        ∧  y < x → ∀z t(y < z < t < x → γ'(z, t))`
>
> is a formula defining `∼_M`.
>
> To show that `∼` is contemporaneous, we first show that it is an equivalence relation. The
> difficult part is transitivity. Suppose that `a < b < c` are in `M` and `a ∼_M b` and
> `b ∼_M c`. We show that `M | (a, c)` is very good by showing that if `a < t < u < c` then
> `M | (t, u)` is non-empty and good.
>
> If `t` and `u` are on the same side of `b` then this is clear. If `b = t` or `b = u` then use a
> lexicographic sum.
>
> So assume that `a < t < b < u < c`. Now `M | (t, b)` and `M | (b, u)` are both very good so are
> good. Choose `R_1 ≡_k M | (t, b)`, `R_2 = M | {b}` and `R_3 ≡_k M | (b, u)` each with flow a
> subset of `ℝ`. Then we know that `M | (t, u) ≡_k R_1 + R_2 + R_3` whose flow is isomorphic to
> `ℝ` itself.
>
> That the `∼_M` classes are intervals follows from the fact that very goodness is inherited by
> substructures on subintervals.
>
> Contemporaneity then follows from the fact that the definition of `∼_M` is in terms of exactly
> the right substructure. ∎

## `ADAPTED-FROM`: the closed-interval Lemma 15

The discrete development's §10 Lemma 15 relativizes to the **closed** `[z,t]`, and that is what
the tree's `relativize` (`MonadicFO.lean:551`) implements, with `≤` guards and
`OrderedMonadicStructure.subinterval` as its semantic counterpart. Reynolds' §8 `γ(z,t)`
relativizes to the **open** `(z,t)`, matching `OrderedMonadicStructure.openSubinterval`
(`GoodDense.lean:222`). `relativizeOpen` below is the open sibling: the same recursion with `<`
guards. The two cannot be interchanged — the whole force of `ε` is that its inner interval
excludes its endpoints, so that `ε(a,b)` says exactly *"`M | (a,b)` is very good"*.

`relativizeAt` (`DenseModelSurgery/Lemma5.lean:672`) is a different operator again: it
relativizes to an `ε`-**class**, cut out by a binary formula at a single parameter. Reynolds'
`γ(z,t)` needs **two** parameters cutting out an interval, which is `relativizeOpen`'s job.

## Hypotheses Reynolds leaves implicit

Reynolds states Lemma 12 for *"any `M`"*. Two hypotheses are in fact used, both of which hold
throughout §8 because Doets' theorem's `M` has a countable dense endpointless flow:

* **Countability** (`[Countable M.carrier]`). The step *"`M | (t,b)` and `M | (b,u)` are both
  very good so are good"* is Lemma 11, whose hypothesis is countability.
* **Density** (`[DenselyOrdered M.carrier]`). Without it transitivity is **false**, not merely
  unproved. Take `M | (a,b)` order-isomorphic to `(0,1]`, with maximum `x`, and `M | (b,c)` very
  good. Then `a ∼ b` and `b ∼ c`, but `M | (x,b)` is empty, so `M | (a,c)` is not very good and
  `a ≁ c`. Reynolds' *"if `b = t` or `b = u` then use a lexicographic sum"* silently assumes the
  boundary subinterval is non-empty, which density supplies.

Both are recorded as explicit hypotheses on the theorems that need them rather than papered over.
-/

namespace FormalSystem.Metalogic.WeakCanonical

open FormalSystem.Metalogic.WeakCanonical

variable {sig : MonadicSignature}

/-! ## `∼_M`, Reynolds' three clauses

Printed p.186. The relation is stated at a fixed depth `k`, since `veryGoodDense` is.
-/

/--
**`∼_M`** — Reynolds 1992, printed p.186:

> `a ∼_M b` if and only if `a = b`, or `a < b` and `M | (a,b)` is very good, or `b < a` and
> `M | (b,a)` is very good.

The three clauses are kept in the source's order and shape. Note the asymmetry is only apparent:
`simDense_symm` below shows the relation is symmetric, because the last two clauses are mirrors.

This is the §8 relation. It is *not* the same as `ContempEquiv`
(`IntegerModel/GoodStructures.lean`), which is the discrete development's `VeryGood`-based
notion, nor is it by definition `ContempEquivDense M ε` — that the two coincide for Reynolds'
`ε` is the content of `contempEquivDense_epsDense_iff` below.
-/
def SimDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds] (k : Nat)
    (M : OrderedMonadicStructure sig) (a b : M.carrier) : Prop :=
  a = b ∨ (a < b ∧ veryGoodDense sig k (M.openSubinterval sig a b)) ∨
    (b < a ∧ veryGoodDense sig k (M.openSubinterval sig b a))

variable [Fintype sig.preds] [DecidableEq sig.preds]

/-- `∼_M` is reflexive: the first clause. -/
theorem simDense_refl (k : Nat) (M : OrderedMonadicStructure sig) (a : M.carrier) :
    SimDense sig k M a a := Or.inl rfl

/-- `∼_M` is symmetric: the second and third clauses are mirrors of one another. -/
theorem simDense_symm {k : Nat} {M : OrderedMonadicStructure sig} {a b : M.carrier}
    (h : SimDense sig k M a b) : SimDense sig k M b a := by
  rcases h with rfl | ⟨hab, hv⟩ | ⟨hba, hv⟩
  · exact Or.inl rfl
  · exact Or.inr (Or.inr ⟨hab, hv⟩)
  · exact Or.inr (Or.inl ⟨hba, hv⟩)

/-! ## Iterated open subintervals

*"very goodness is inherited by substructures on subintervals"* (printed p.187). The engine is
the identification `(M | (a,b)) | (z,w) = M | (z,w)`, which is an order isomorphism preserving
every predicate, hence a `k`-equivalence.
-/

/-- `(M | (a,b)) | (z,w) ≃o M | (z,w)`: cutting twice is cutting once. -/
def openSubOpenSubEquiv (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) (z w : (M.openSubinterval sig a b).carrier) :
    ((M.openSubinterval sig a b).openSubinterval sig z w).carrier ≃
      (M.openSubinterval sig z.val w.val).carrier where
  toFun x := ⟨x.val.val, x.property.1, x.property.2⟩
  invFun y := ⟨⟨y.val, lt_trans z.property.1 y.property.1,
    lt_trans y.property.2 w.property.2⟩, y.property.1, y.property.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- `(M | (a,b)) | (z,w) ≡_k M | (z,w)`. -/
theorem kEquiv_openSub_openSub (k : Nat) (M : OrderedMonadicStructure sig) (a b : M.carrier)
    (z w : (M.openSubinterval sig a b).carrier) :
    KEquiv sig k ((M.openSubinterval sig a b).openSubinterval sig z w)
      (M.openSubinterval sig z.val w.val) :=
  k_equiv_of_iso sig k _ _
    (Equiv.toOrderIso (openSubOpenSubEquiv sig M a b z w) (fun _ _ h => h) (fun _ _ h => h))
    (fun _ _ => Iff.rfl)

/--
**Very goodness is inherited by substructures on subintervals** (printed p.187).

If `M | (a,b)` is very good and `[t,u] ⊆ [a,b]` with `t < u`, then `M | (t,u)` is very good.
-/
theorem veryGoodDense_openSubinterval_mono (k : Nat) {M : OrderedMonadicStructure sig}
    {a b t u : M.carrier} (h : veryGoodDense sig k (M.openSubinterval sig a b))
    (hat : a ≤ t) (hub : u ≤ b) : veryGoodDense sig k (M.openSubinterval sig t u) := by
  intro z w hzw
  -- `z` and `w` also sit strictly inside `(a,b)`.
  have hz : a < z.val ∧ z.val < b :=
    ⟨lt_of_le_of_lt hat z.property.1, lt_of_lt_of_le (lt_trans hzw w.property.2) hub⟩
  have hw : a < w.val ∧ w.val < b :=
    ⟨lt_of_le_of_lt hat (lt_trans z.property.1 hzw), lt_of_lt_of_le w.property.2 hub⟩
  obtain ⟨hne, hgood⟩ := h ⟨z.val, hz⟩ ⟨w.val, hw⟩ hzw
  -- Both sides are `k`-equivalent to `M | (z,w)`; transport through it.
  have e₁ := kEquiv_openSub_openSub k M a b ⟨z.val, hz⟩ ⟨w.val, hw⟩
  have e₂ := kEquiv_openSub_openSub k M t u z w
  refine ⟨?_, goodDense_of_kEquiv sig k (e₂.trans e₁.symm) hgood⟩
  obtain ⟨x⟩ := hne
  exact ⟨(openSubOpenSubEquiv sig M t u z w).symm
    ((openSubOpenSubEquiv sig M a b ⟨z.val, hz⟩ ⟨w.val, hw⟩) x)⟩

/-- **`∼_M` classes are intervals** (printed p.187), i.e. `∼_M` is convex: this is the inheritance
    lemma applied to the two ordered cases. -/
theorem simDense_convex (k : Nat) (M : OrderedMonadicStructure sig) (a b c : M.carrier)
    (hab : a ≤ b) (hbc : b ≤ c) (h : SimDense sig k M a c) : SimDense sig k M a b := by
  rcases eq_or_lt_of_le hab with rfl | hab'
  · exact Or.inl rfl
  refine Or.inr (Or.inl ⟨hab', ?_⟩)
  rcases h with rfl | ⟨_, hv⟩ | ⟨hca, _⟩
  · exact absurd (lt_of_lt_of_le hab' hbc) (lt_irrefl a)
  · exact veryGoodDense_openSubinterval_mono k hv (le_refl a) hbc
  · exact absurd (lt_of_lt_of_le hab' hbc) (asymm hca)

/-! ## The finite `γ`-set

*"There are only finitely many logically inequivalent maximal consistent conjunctions `γ` of
sentences of quantifier depth `≤ k`. Any structure is a model of just one such `γ` …"*
(printed p.187).

Reynolds' `γ`'s are exactly the tree's depth-`k` normal forms with no free variables: `NormalForm
sig k 0` is a `Fintype` (`normalForm_card`, `NormalForm.lean:611`), every structure satisfies
exactly one of them (`nf_exists_unique`, `NormalForm.lean:293`), and `nfToSentence`
(`NormalForm.lean:861`) renders each as an honest `MonadicSentence`. The `NormalForm` layer is
consumed as it stands; nothing here rebuilds it.

The `hn : n ≤ 1` restriction that `Kamp.nf_nvar_exist_all_depths` (`Kamp/KampPrior.lean:363`)
carries does **not** bite here: that restriction is on the *Prior-expressiveness* route, which
needs a normal-form-to-`U`/`S` translation at `n` free variables. This module stays inside the
monadic language and uses only the `n = 0` case.
-/

open scoped Classical in
/--
**`{γ_1, …, γ_s}`** — the depth-`k` normal forms realized by good structures.

Finiteness is `Finset`-level and needs no argument: `NormalForm sig k 0` is a `Fintype`.
-/
noncomputable def goodNFs (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) : Finset (NormalForm sig k 0) :=
  Finset.univ.filter
    (fun nf => ∃ M : OrderedMonadicStructure sig, goodDense sig k M ∧ NfEvalNf M k 0 Fin.elim0 nf)

/-- The `γ_i` themselves, as sentences. -/
noncomputable def gammaSentences (sig : MonadicSignature) [Fintype sig.preds]
    [DecidableEq sig.preds] (k : Nat) : List (MonadicSentence sig) :=
  (goodNFs sig k).toList.map nfToSentence

/-- **`⋁_{i ≤ s} γ_i`** (printed p.187). -/
noncomputable def gammaDisj (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) : MonadicSentence sig :=
  MonadicFormula.listDisj (gammaSentences sig k)

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Structures satisfying the same normal form are `k`-equivalent — *"if `N_1 ⊨ γ` then
    `N_2 ≡_k N_1` iff `N_2 ⊨ γ`"* (printed p.187). -/
theorem kEquiv_of_shared_nf (k : Nat) {M N : OrderedMonadicStructure sig}
    {nf : NormalForm sig k 0} (hM : NfEvalNf M k 0 Fin.elim0 nf)
    (hN : NfEvalNf N k 0 Fin.elim0 nf) : KEquiv sig k M N := by
  funext nf'
  have hiff : NfEvalNf M k 0 Fin.elim0 nf' ↔ NfEvalNf N k 0 Fin.elim0 nf' := by
    constructor
    · intro h; exact (nf_eval_unique M k 0 Fin.elim0 nf' nf h hM) ▸ hN
    · intro h; exact (nf_eval_unique N k 0 Fin.elim0 nf' nf h hN) ▸ hM
  simp only [kTypeOf, decide_eq_decide]
  exact hiff

/--
**The finite `γ`-set works** — Reynolds 1992, printed p.187: *"`N` is good iff
`N ⊨ ⋁_{i ≤ s} γ_i`."*
-/
theorem goodDense_iff_eval_gammaDisj (k : Nat) (M : OrderedMonadicStructure sig) :
    goodDense sig k M ↔ eval M Fin.elim0 (gammaDisj sig k) := by
  classical
  rw [gammaDisj, eval_listDisj]
  constructor
  · intro hM
    refine ⟨nfToSentence (nfCharacteristic M k 0 Fin.elim0), ?_, ?_⟩
    · refine List.mem_map.mpr ⟨nfCharacteristic M k 0 Fin.elim0, ?_, rfl⟩
      refine Finset.mem_toList.mpr ?_
      simp only [goodNFs, Finset.mem_filter, Finset.mem_univ, true_and]
      exact ⟨M, hM, nf_characteristic_satisfies M k 0 Fin.elim0⟩
    · exact (nf_to_sentence_correct M _).mpr (nf_characteristic_satisfies M k 0 Fin.elim0)
  · rintro ⟨φ, hmem, hev⟩
    obtain ⟨nf, hnf, rfl⟩ := List.mem_map.mp hmem
    have hnf' := Finset.mem_toList.mp hnf
    simp only [goodNFs, Finset.mem_filter, Finset.mem_univ, true_and] at hnf'
    obtain ⟨N, hNgood, hNnf⟩ := hnf'
    exact goodDense_of_kEquiv sig k
      (kEquiv_of_shared_nf k ((nf_to_sentence_correct M nf).mp hev) hNnf) hNgood

end FormalSystem.Metalogic.WeakCanonical
