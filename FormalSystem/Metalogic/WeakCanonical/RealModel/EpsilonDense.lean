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
open FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery

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

/-! ## `γ(z,t)`: relativization to the **open** interval

*"Let `γ(z,t)` be the result of relativising the quantifiers of `⋁_{i ≤ s} γ_i` to `(z,t)`, where
`z` and `t` are new variables"* (printed p.187).

The variable layout copies `relativize` (`MonadicFO.lean:551`) exactly, so that the two operators
are drop-in siblings: in `relativizeOpen φ` for `φ : MonadicFormula sig n`, variables `0 … n-1`
are `φ`'s own, variable `n` is the lower bound `z` and variable `n+1` is the upper bound `t`.
The only change is `<` in place of `≤` in the two quantifier guards, matching
`OrderedMonadicStructure.openSubinterval` in place of `OrderedMonadicStructure.subinterval`.
-/

/--
Relativize a monadic formula to the **open** subinterval `(var n, var (n+1))`.

The open sibling of `relativize` (`MonadicFO.lean:551`); see this section's header for why the
closed operator cannot be reused here.
-/
def relativizeOpen {sig : MonadicSignature} :
    {n : Nat} → MonadicFormula sig n → MonadicFormula sig (n + 2)
  | _, .atom p i => .atom p (i.castSucc.castSucc)
  | _, .lt i j => .lt (i.castSucc.castSucc) (j.castSucc.castSucc)
  | _, .not α => .not (relativizeOpen α)
  | _, .and α β => .and (relativizeOpen α) (relativizeOpen β)
  | n, .all α =>
    -- ∀ x, (z < x ∧ x < t) → relativizeOpen α
    .all (MonadicFormula.imp
      (.and (.lt ⟨n + 1, by omega⟩ ⟨0, by omega⟩) (.lt ⟨0, by omega⟩ ⟨n + 2, by omega⟩))
      (relativizeOpen α))
  | n, .ex α =>
    -- ∃ x, (z < x ∧ x < t) ∧ relativizeOpen α
    .ex (.and
      (.and (.lt ⟨n + 1, by omega⟩ ⟨0, by omega⟩) (.lt ⟨0, by omega⟩ ⟨n + 2, by omega⟩))
      (relativizeOpen α))

/-- Relativize a sentence to the open interval `(var 0, var 1)`. -/
def relativizeOpenSentence {sig : MonadicSignature} (φ : MonadicSentence sig) :
    MonadicFormula sig 2 :=
  relativizeOpen φ

/-- The environment for `relativizeOpen`: an environment over the open subinterval, projected
    into `M` and extended with the two bounds in the fresh slots `n` and `n+1`. -/
def relativizeOpenEnv {sig : MonadicSignature} {n : Nat} (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) :
    Fin (n + 2) → M.carrier :=
  fun i =>
    if h : i.val < n then (env_sub ⟨i.val, h⟩).val
    else if i.val = n then lo else hi

omit [Fintype sig.preds] [DecidableEq sig.preds] in
theorem relativizeOpenEnv_lt {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (i : Fin n) :
    relativizeOpenEnv M lo hi env_sub (i.castSucc.castSucc) = (env_sub i).val := by
  simp [relativizeOpenEnv, Fin.castSucc, i.isLt]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
theorem relativizeOpenEnv_lo {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (h : n < n + 2) :
    relativizeOpenEnv M lo hi env_sub ⟨n, h⟩ = lo := by
  simp [relativizeOpenEnv]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
theorem relativizeOpenEnv_hi {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (h : n + 1 < n + 2) :
    relativizeOpenEnv M lo hi env_sub ⟨n + 1, h⟩ = hi := by
  simp [relativizeOpenEnv]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- Pushing a fresh point through `relativizeOpenEnv`: extending the ambient environment by `x`
    is extending the subinterval environment by `x` viewed as a point of `(lo,hi)`. -/
theorem relativizeOpenEnv_cons {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier)
    (x : (M.openSubinterval sig lo hi).carrier) :
    Fin.cons x.val (relativizeOpenEnv M lo hi env_sub)
      = relativizeOpenEnv M lo hi (Fin.cons x env_sub) := by
  funext j
  rcases Fin.eq_zero_or_eq_succ j with rfl | ⟨i, rfl⟩
  · show x.val = _
    rw [show (0 : Fin (n + 1 + 2)) = (⟨0, by omega⟩ : Fin (n + 1 + 2)) from rfl]
    simp only [relativizeOpenEnv, dif_pos (by omega : (0 : Nat) < n + 1)]
    rfl
  · rw [Fin.cons_succ]
    simp only [relativizeOpenEnv, Fin.val_succ]
    by_cases hlt : i.val < n
    · rw [dif_pos hlt, dif_pos (by omega : i.val + 1 < n + 1)]
      congr 1
    · rw [dif_neg hlt, dif_neg (by omega : ¬ (i.val + 1 < n + 1))]
      by_cases heq : i.val = n
      · rw [if_pos heq, if_pos (by omega : i.val + 1 = n + 1)]
      · rw [if_neg heq, if_neg (by omega : ¬ (i.val + 1 = n + 1))]

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- `relativizeOpenEnv_cons` with the fresh point given as an ambient element together with its
    membership proofs; this is the form the quantifier cases actually rewrite with. -/
theorem relativizeOpenEnv_cons' {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (x : M.carrier)
    (h1 : lo < x) (h2 : x < hi) :
    Fin.cons x (relativizeOpenEnv M lo hi env_sub)
      = relativizeOpenEnv M lo hi (Fin.cons ⟨x, h1, h2⟩ env_sub) :=
  relativizeOpenEnv_cons M lo hi env_sub ⟨x, h1, h2⟩

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The lower-bound slot, seen from under one extra binder. -/
theorem cons_relativizeOpenEnv_lo {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (x : M.carrier)
    (h : n + 1 < n + 3) :
    (Fin.cons x (relativizeOpenEnv M lo hi env_sub) : Fin (n + 3) → M.carrier) ⟨n + 1, h⟩ = lo := by
  show (Fin.cons x (relativizeOpenEnv M lo hi env_sub) : Fin (n + 3) → M.carrier)
      (Fin.succ (⟨n, by omega⟩ : Fin (n + 2))) = lo
  rw [Fin.cons_succ]
  exact relativizeOpenEnv_lo M lo hi env_sub _

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The upper-bound slot, seen from under one extra binder. -/
theorem cons_relativizeOpenEnv_hi {n : Nat} (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (x : M.carrier)
    (h : n + 2 < n + 3) :
    (Fin.cons x (relativizeOpenEnv M lo hi env_sub) : Fin (n + 3) → M.carrier) ⟨n + 2, h⟩ = hi := by
  show (Fin.cons x (relativizeOpenEnv M lo hi env_sub) : Fin (n + 3) → M.carrier)
      (Fin.succ (⟨n + 1, by omega⟩ : Fin (n + 2))) = hi
  rw [Fin.cons_succ]
  exact relativizeOpenEnv_hi M lo hi env_sub _

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The freshly bound variable slot. -/
theorem cons_relativizeOpenEnv_zero {n : Nat} (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier) (x : M.carrier)
    (h : 0 < n + 3) :
    (Fin.cons x (relativizeOpenEnv M lo hi env_sub) : Fin (n + 3) → M.carrier) ⟨0, h⟩ = x := rfl

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/--
**The open relativization is correct**: evaluating `relativizeOpen φ` in `M` with the two bounds
in the fresh slots is evaluating `φ` in `M | (lo, hi)`.

The open counterpart of `relativize_correct` (`MonadicFO.lean:648`).
-/
theorem relativizeOpen_correct {n : Nat} (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (env_sub : Fin n → (M.openSubinterval sig lo hi).carrier)
    (φ : MonadicFormula sig n) :
    eval M (relativizeOpenEnv M lo hi env_sub) (relativizeOpen φ) ↔
      eval (M.openSubinterval sig lo hi) env_sub φ := by
  induction φ with
  | atom p i =>
    simp only [relativizeOpen, eval, OrderedMonadicStructure.openSubinterval]
    rw [relativizeOpenEnv_lt]
  | lt i j =>
    simp only [relativizeOpen, eval]
    rw [relativizeOpenEnv_lt, relativizeOpenEnv_lt]
    exact Iff.rfl
  | not α ih => simp only [relativizeOpen, eval]; exact (ih env_sub).not
  | and α β ihα ihβ => simp only [relativizeOpen, eval]; exact (ihα env_sub).and (ihβ env_sub)
  | @all n α ih =>
    simp only [relativizeOpen, eval, eval_imp, cons_relativizeOpenEnv_lo,
      cons_relativizeOpenEnv_hi, cons_relativizeOpenEnv_zero]
    constructor
    · intro h_all x
      refine (ih (Fin.cons x env_sub)).mp ?_
      rw [← relativizeOpenEnv_cons]
      exact h_all x.val ⟨x.property.1, x.property.2⟩
    · intro h_all x hguard
      rw [relativizeOpenEnv_cons' M lo hi env_sub x hguard.1 hguard.2]
      exact (ih (Fin.cons ⟨x, hguard.1, hguard.2⟩ env_sub)).mpr (h_all ⟨x, hguard.1, hguard.2⟩)
  | @ex n α ih =>
    simp only [relativizeOpen, eval, cons_relativizeOpenEnv_lo,
      cons_relativizeOpenEnv_hi, cons_relativizeOpenEnv_zero]
    constructor
    · rintro ⟨x, ⟨hlo, hhi⟩, hbody⟩
      rw [relativizeOpenEnv_cons' M lo hi env_sub x hlo hhi] at hbody
      exact ⟨⟨x, hlo, hhi⟩, (ih (Fin.cons ⟨x, hlo, hhi⟩ env_sub)).mp hbody⟩
    · rintro ⟨x, hbody⟩
      refine ⟨x.val, ⟨x.property.1, x.property.2⟩, ?_⟩
      rw [relativizeOpenEnv_cons]
      exact (ih (Fin.cons x env_sub)).mpr hbody

omit [Fintype sig.preds] [DecidableEq sig.preds] in
/-- The sentence case: `γ(z,t)` holds at `(lo,hi)` exactly when `M | (lo,hi) ⊨ γ`. -/
theorem relativizeOpenSentence_correct (M : OrderedMonadicStructure sig) (lo hi : M.carrier)
    (φ : MonadicSentence sig) :
    eval M ![lo, hi] (relativizeOpenSentence φ) ↔ eval (M.openSubinterval sig lo hi) Fin.elim0 φ := by
  have h := relativizeOpen_correct M lo hi (Fin.elim0 : Fin 0 → _) φ
  have henv : relativizeOpenEnv M lo hi (Fin.elim0 : Fin 0 → (M.openSubinterval sig lo hi).carrier)
      = ![lo, hi] := by
    funext i
    fin_cases i <;> simp [relativizeOpenEnv]
  rw [henv] at h
  exact h

/-! ## `γ'(z,t)` and `ε(x,y)`

*"Put `γ'(z,t) = γ(z,t) ∧ (∃u(z < u < t))`"*, and then

```
ε(x, y) =  x < y → ∀z t(x < z < t < y → γ'(z, t))
        ∧  y < x → ∀z t(y < z < t < x → γ'(z, t))
```

(printed p.187), transcribed with the source's variable order preserved.
-/

/--
**`γ'(z,t)`** (printed p.187): the free variable `0` is `z`, the free variable `1` is `t`.

The second conjunct `∃u(z < u < t)` is the non-emptiness clause; under the binder `u` is `0`,
`z` is `1` and `t` is `2`.
-/
noncomputable def gammaPrime (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) : MonadicFormula sig 2 :=
  .and (relativizeOpenSentence (gammaDisj sig k)) (.ex (.and (.lt 1 0) (.lt 0 2)))

/-- `γ'(z,t)` says exactly that `M | (z,t)` is non-empty and good — the body of the
    `veryGoodDense` clause. -/
theorem eval_gammaPrime (k : Nat) (M : OrderedMonadicStructure sig) (z t : M.carrier) :
    eval M ![z, t] (gammaPrime sig k) ↔
      Nonempty (M.openSubinterval sig z t).carrier ∧
        goodDense sig k (M.openSubinterval sig z t) := by
  have hgood : eval M ![z, t] (relativizeOpenSentence (gammaDisj sig k)) ↔
      goodDense sig k (M.openSubinterval sig z t) :=
    (relativizeOpenSentence_correct M z t (gammaDisj sig k)).trans
      (goodDense_iff_eval_gammaDisj k (M.openSubinterval sig z t)).symm
  have hne : eval M ![z, t] (MonadicFormula.ex (.and (.lt 1 0) (.lt 0 2)) : MonadicFormula sig 2) ↔
      Nonempty (M.openSubinterval sig z t).carrier := by
    simp only [eval]
    constructor
    · rintro ⟨u, h1, h2⟩; exact ⟨⟨u, h1, h2⟩⟩
    · rintro ⟨⟨u, h1, h2⟩⟩; exact ⟨u, h1, h2⟩
  simp only [gammaPrime, eval]
  rw [and_comm]
  exact and_congr hne hgood

/--
**`ε(x,y)`** — Reynolds 1992, printed p.187, transcribed verbatim.

De Bruijn layout: the free variable `0` is `x` and `1` is `y`. Under the two quantifiers of each
conjunct the layout is `t = 0`, `z = 1`, `x = 2`, `y = 3` — the inner binder is `t`, so `z` is the
outer one, matching the source's `∀z t`.
-/
noncomputable def epsDense (sig : MonadicSignature) [Fintype sig.preds] [DecidableEq sig.preds]
    (k : Nat) : MonadicFormula sig 2 :=
  .and
    -- x < y → ∀z t (x < z < t < y → γ'(z,t))
    (.imp (.lt 0 1)
      (.all (.all (.imp (.and (.lt 2 1) (.and (.lt 1 0) (.lt 0 3)))
        (epsAt (gammaPrime sig k) 1 0)))))
    -- y < x → ∀z t (y < z < t < x → γ'(z,t))
    (.imp (.lt 1 0)
      (.all (.all (.imp (.and (.lt 3 1) (.and (.lt 1 0) (.lt 0 2)))
        (epsAt (gammaPrime sig k) 1 0)))))

/-- Unfolding `ε(a,b)`: the two guarded universal clauses, with `γ'` already read semantically. -/
theorem eval_epsDense (k : Nat) (M : OrderedMonadicStructure sig) (a b : M.carrier) :
    eval M ![a, b] (epsDense sig k) ↔
      ((a < b → ∀ z t : M.carrier, a < z → z < t → t < b →
          Nonempty (M.openSubinterval sig z t).carrier ∧
            goodDense sig k (M.openSubinterval sig z t)) ∧
       (b < a → ∀ z t : M.carrier, b < z → z < t → t < a →
          Nonempty (M.openSubinterval sig z t).carrier ∧
            goodDense sig k (M.openSubinterval sig z t))) := by
  simp only [epsDense, eval, eval_imp, eval_epsAt, ContempEquivDense, eval_gammaPrime,
    Matrix.cons_val_zero, Matrix.cons_val_one, Fin.cons_zero]
  constructor
  · rintro ⟨h1, h2⟩
    refine ⟨fun hab z t hz hzt htb => h1 hab z t ⟨hz, hzt, htb⟩,
      fun hba z t hz hzt hta => h2 hba z t ⟨hz, hzt, hta⟩⟩
  · rintro ⟨h1, h2⟩
    exact ⟨fun hab z t hg => h1 hab z t hg.1 hg.2.1 hg.2.2,
      fun hba z t hg => h2 hba z t hg.1 hg.2.1 hg.2.2⟩

/-- `veryGoodDense` at an open subinterval, re-expressed with ambient points. This is the form
    `ε` matches: *"for all `t < u` in `M | (a,b)`, `M | (t,u)` is non-empty and good"*. -/
theorem veryGoodDense_openSubinterval_iff (k : Nat) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) :
    veryGoodDense sig k (M.openSubinterval sig a b) ↔
      ∀ z t : M.carrier, a < z → z < t → t < b →
        Nonempty (M.openSubinterval sig z t).carrier ∧
          goodDense sig k (M.openSubinterval sig z t) := by
  constructor
  · intro h z t haz hzt htb
    have hz : a < z ∧ z < b := ⟨haz, lt_trans hzt htb⟩
    have ht : a < t ∧ t < b := ⟨lt_trans haz hzt, htb⟩
    obtain ⟨hne, hgood⟩ := h ⟨z, hz⟩ ⟨t, ht⟩ hzt
    refine ⟨?_, goodDense_of_kEquiv sig k (kEquiv_openSub_openSub k M a b ⟨z, hz⟩ ⟨t, ht⟩).symm
      hgood⟩
    obtain ⟨x⟩ := hne
    exact ⟨openSubOpenSubEquiv sig M a b ⟨z, hz⟩ ⟨t, ht⟩ x⟩
  · intro h z t hzt
    obtain ⟨hne, hgood⟩ := h z.val t.val z.property.1 hzt t.property.2
    refine ⟨?_, goodDense_of_kEquiv sig k (kEquiv_openSub_openSub k M a b z t) hgood⟩
    obtain ⟨x⟩ := hne
    exact ⟨(openSubOpenSubEquiv sig M a b z t).symm x⟩

/--
**`ε` defines `∼_M`** — Reynolds 1992, printed p.187: *"`ε(x,y)` … is a formula defining
`∼_M`."*

The three clauses of `SimDense` fall out of trichotomy: at `a = b` both antecedents of `ε` are
false, and at `a < b` (resp. `b < a`) the surviving conjunct is literally the `veryGoodDense`
condition on `M | (a,b)` (resp. `M | (b,a)`).
-/
theorem contempEquivDense_epsDense_iff (k : Nat) (M : OrderedMonadicStructure sig)
    (a b : M.carrier) :
    ContempEquivDense M (epsDense sig k) a b ↔ SimDense sig k M a b := by
  rw [ContempEquivDense, eval_epsDense, SimDense]
  rcases lt_trichotomy a b with hab | rfl | hba
  · constructor
    · intro h
      exact Or.inr (Or.inl ⟨hab, (veryGoodDense_openSubinterval_iff k M a b).mpr (h.1 hab)⟩)
    · rintro (rfl | ⟨_, hv⟩ | ⟨hba, _⟩)
      · exact absurd hab (lt_irrefl a)
      · exact ⟨fun _ => (veryGoodDense_openSubinterval_iff k M a b).mp hv,
          fun hba => absurd hab (asymm hba)⟩
      · exact absurd hab (asymm hba)
  · exact ⟨fun _ => Or.inl rfl,
      fun _ => ⟨fun h => absurd h (lt_irrefl a), fun h => absurd h (lt_irrefl a)⟩⟩
  · constructor
    · intro h
      exact Or.inr (Or.inr ⟨hba, (veryGoodDense_openSubinterval_iff k M b a).mpr (h.2 hba)⟩)
    · rintro (rfl | ⟨hab, _⟩ | ⟨_, hv⟩)
      · exact absurd hba (lt_irrefl a)
      · exact absurd hba (asymm hab)
      · exact ⟨fun hab => absurd hba (asymm hab),
          fun _ => (veryGoodDense_openSubinterval_iff k M b a).mp hv⟩

/-! ## Contemporaneity

*"Contemporaneity then follows from the fact that the definition of `∼_M` is in terms of exactly
the right substructure"* (printed p.187): `ε(a,b)` only ever mentions points strictly between `a`
and `b`, so passing to `M | [a,b]` changes nothing.
-/

/-- An order isomorphism of ambient structures restricts to the open subintervals. -/
def openSubOrderEquiv (sig : MonadicSignature) {M N : OrderedMonadicStructure sig}
    (f : M.carrier ≃o N.carrier) (t u : M.carrier) :
    (M.openSubinterval sig t u).carrier ≃ (N.openSubinterval sig (f t) (f u)).carrier where
  toFun x := ⟨f x.val, f.lt_iff_lt.mpr x.property.1, f.lt_iff_lt.mpr x.property.2⟩
  invFun y := ⟨f.symm y.val,
    by simpa using f.symm.lt_iff_lt.mpr y.property.1,
    by simpa using f.symm.lt_iff_lt.mpr y.property.2⟩
  left_inv x := Subtype.ext (by simp)
  right_inv y := Subtype.ext (by simp)

/-- **Very goodness transfers along a predicate-preserving order isomorphism.** -/
theorem veryGoodDense_of_orderIso (k : Nat) {M N : OrderedMonadicStructure sig}
    (f : M.carrier ≃o N.carrier) (h_pred : ∀ (p : sig.preds) (x : M.carrier),
      M.interp p x ↔ N.interp p (f x)) (hN : veryGoodDense sig k N) :
    veryGoodDense sig k M := by
  intro t u htu
  obtain ⟨hne, hgood⟩ := hN (f t) (f u) (f.lt_iff_lt.mpr htu)
  refine ⟨?_, ?_⟩
  · obtain ⟨y⟩ := hne
    exact ⟨(openSubOrderEquiv sig f t u).symm y⟩
  · refine goodDense_of_orderIso sig k
      (Equiv.toOrderIso (openSubOrderEquiv sig f t u) ?_ ?_) (fun p x => h_pred p x.val) hgood
    · exact fun x y h => f.le_iff_le.mpr h
    · exact fun x y h => f.symm.le_iff_le.mpr h

/-- `(M | [lo,hi]) | (a,b) ≃ M | (a,b)`: cutting an open interval out of a closed one is cutting
    it out of `M` directly. -/
def subOpenSubEquiv (sig : MonadicSignature) (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (a b : (M.subinterval sig lo hi).carrier) :
    ((M.subinterval sig lo hi).openSubinterval sig a b).carrier ≃
      (M.openSubinterval sig a.val b.val).carrier where
  toFun x := ⟨x.val.val, x.property.1, x.property.2⟩
  invFun y := ⟨⟨y.val, le_trans a.property.1 (le_of_lt y.property.1),
    le_trans (le_of_lt y.property.2) b.property.2⟩, y.property.1, y.property.2⟩
  left_inv _ := rfl
  right_inv _ := rfl

/-- Very goodness of `(M | [lo,hi]) | (a,b)` is very goodness of `M | (a,b)`. -/
theorem veryGoodDense_subOpen_iff (k : Nat) (M : OrderedMonadicStructure sig)
    (lo hi : M.carrier) (a b : (M.subinterval sig lo hi).carrier) :
    veryGoodDense sig k ((M.subinterval sig lo hi).openSubinterval sig a b) ↔
      veryGoodDense sig k (M.openSubinterval sig a.val b.val) := by
  constructor
  · exact veryGoodDense_of_orderIso k
      (Equiv.toOrderIso (subOpenSubEquiv sig M lo hi a b).symm (fun _ _ h => h) (fun _ _ h => h))
      (fun _ _ => Iff.rfl)
  · exact veryGoodDense_of_orderIso k
      (Equiv.toOrderIso (subOpenSubEquiv sig M lo hi a b) (fun _ _ h => h) (fun _ _ h => h))
      (fun _ _ => Iff.rfl)

/--
**`∼_M` is contemporaneous** — Reynolds 1992, printed p.187, clause (iii) of the
`IsContempEquivDense` shape: `M ⊨ ε(a,b)` iff `M | [a,b] ⊨ ε(a,b)`.

Stated on `SimDense` rather than on `eval`; `contempEquivDense_epsDense_iff` converts.
-/
theorem simDense_contemporary (k : Nat) (M : OrderedMonadicStructure sig) (a b : M.carrier) :
    SimDense sig k M a b ↔
      SimDense sig k (M.subinterval sig (min a b) (max a b))
        ⟨a, min_le_left a b, le_max_left a b⟩ ⟨b, min_le_right a b, le_max_right a b⟩ := by
  constructor
  · rintro (rfl | ⟨h, hv⟩ | ⟨h, hv⟩)
    · exact Or.inl rfl
    · exact Or.inr (Or.inl ⟨h, (veryGoodDense_subOpen_iff k M (min a b) (max a b) _ _).mpr hv⟩)
    · exact Or.inr (Or.inr ⟨h, (veryGoodDense_subOpen_iff k M (min a b) (max a b) _ _).mpr hv⟩)
  · rintro (h | ⟨h, hv⟩ | ⟨h, hv⟩)
    · exact Or.inl (congrArg Subtype.val h)
    · exact Or.inr (Or.inl ⟨h, (veryGoodDense_subOpen_iff k M (min a b) (max a b) _ _).mp hv⟩)
    · exact Or.inr (Or.inr ⟨h, (veryGoodDense_subOpen_iff k M (min a b) (max a b) _ _).mp hv⟩)

end FormalSystem.Metalogic.WeakCanonical
