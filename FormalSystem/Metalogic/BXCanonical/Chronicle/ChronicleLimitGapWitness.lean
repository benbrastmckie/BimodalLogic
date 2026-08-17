/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.BXCanonical.Chronicle.PointInsertion
import FormalSystem.Metalogic.Bundle.RealExtensionBundle

/-!
# The definable-gap discharge of `BFMCS.LimitFutureWitness`

`Bundle/RealExtensionBundle.lean` isolates one residual obligation in the transport of restricted
temporal coherence to the real bundle: at an **unselected** real `r`, if `F φ` lies in the
ultrafilter limit `limitMCSBelow m r`, some rational strictly above `r` must already carry `φ`.
That is `BFMCS.LimitFutureWitness`. This module discharges it.

## Why the obligation is real

The obligation is literally Burgess' prophecy-at-a-gap claim (Burgess 1984, printed pp.109-110):
"Now if `Fa ∈ T*(w(Y,Z))`, we claim that `Fa ∈ T(z)` for some `z ∈ Z`. For if not, then
`G¬a ∈ T(z)` for all `z ∈ Z`, and by the previous Lemma, `G¬a ∈ T(y)` for some `y ∈ Y`."
Burgess' own proof routes through his continuity axiom, so the obligation cannot be dissolved by
changing the limit construction: adopting his two-sided seed at the gap leaves the very same step
to be paid for. It is paid for here by an axiom, and the price is that the discharge is
**`fc`-conditional** rather than `fc`-generic.

## The argument

Everything below is Reynolds 1992, the proof of Theorem 3, **printed p.176**:

> "Suppose for contradiction that `M ⊨ U'(A,B)(t)` in some Prior structure `M`. Thus `B` holds
> for a while up until a gap after which `¬B` is true arbitrarily soon. By Prior-U applied to `B`
> we have `M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction."

The decisive choice is **which formula plays the role of `B`**. Applying Prior-U to `φ` itself
does not work: below the gap the `φ`-points merely accumulate at `r`, so the antecedent `U(⊤, φ)`
of `Axiom.prior_U_gap` is not available. Applying it instead to `χ := F φ` does work, because
`χ`'s truth region below the gap is the whole interval `(-∞, r)` — an interval, not an
accumulating set — so `U(⊤, χ)` is free. Steps A and B below establish exactly that dichotomy
(`χ` everywhere below `r`, `¬χ` everywhere above), Step C assembles the Prior-U antecedent, and
Step D derives the contradiction. The shape of Steps C-D follows Reynolds' Lemma 3, **printed
p.178**: "Prior-U applied to `R` implies that `M` contains a last point of this stretch of `R` …
or a first point of `¬R`" — here neither exists, since the endpoint is the unselected real `r`.

Irrationality of `r` (i.e. its unselectedness) is used exactly twice: in Step A, to upgrade
`(s : ℝ) ≤ r` to `(s : ℝ) < r`, and in Step D, to exclude `(u : ℝ) = r`.

`Axiom.prior_U_gap` has `minFrameClass = .Dedekind` (`ProofSystem/Axioms.lean`), so both theorems
below carry `(hfc : FrameClass.Dedekind ≤ fc)`. This is the first point in the real-extension
route at which the Dedekind axiom layer is consumed; everything upstream is `fc`-generic.

## The self-root instantiation

`cantor_bfmcs_dense_restricted_fuc` and `_buc` are stated for a restricted (closure-bounded)
predicate, but they are polymorphic in `root` and their proofs **discard** the
closure-membership argument outright — the underlying resolution lemmas
(`limit_F_resolution`, `limit_satisfies_c4`, `limit_satisfies_c5_strong`) take their formula
arguments unconstrained. Instantiating at `root := Formula.untl α β` and discharging the side
condition with `self_mem_subformulaClosure` therefore recovers **unrestricted** Until coherence
for the Cantor dense chronicle, for every formula, without touching a single chronicle
declaration. That is what `cantor_bfmcs_dense_limit_future_witness` does below; a future reader
need not re-derive it.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Theorems.Combinators

/--
**The general definable-gap lemma.**

If a rational family `m` satisfies Until coherence in both directions (unrestricted), then at
any **unselected** real `r`, a membership `F φ ∈ limitMCSBelow m r` is realised by a rational
strictly above `r`.

The proof is Reynolds 1992's Theorem 3 argument (printed p.176) applied at `χ := F φ` rather
than at `φ`, which is what makes the Prior-U antecedent `U(⊤, χ)` available. See the module
docstring. `Axiom.prior_U_gap` is consumed at `χ`, whence the hypothesis `hfc`.
-/
theorem limitFutureWitness_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hUf : ∀ (t : Rat) (α β : Formula), Formula.untl β α ∈ m t →
      ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
    (hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
      Formula.untl β α ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (φ : Formula)
    (hF : Formula.someFuture φ ∈ limitMCSBelow m r) :
    ∃ s : Rat, r < (s : ℝ) ∧ φ ∈ m s := by
  by_contra hcon
  -- `(†) : ∀ s : Rat, r < (s : ℝ) → φ ∉ m s`
  push Not at hcon
  -- Unselectedness of `r`, in the form actually used.
  have hne : ∀ s : Rat, (s : ℝ) ≠ r := fun s h => hr ⟨s, h⟩
  -- `⊤` sits in every member of the family, so `⊤`-guards are free.
  have htop : ∀ q : Rat, Formula.top ∈ m q := by
    intro q
    exact theorem_in_mcs (hm q) (identity (fc := fc) Formula.bot)
  -- `F ψ = U(ψ, ⊤)`, so the two Until directions specialise to `someFuture`.
  have hSFf : ∀ (q : Rat) (ψ : Formula), Formula.someFuture ψ ∈ m q →
      ∃ s : Rat, q < s ∧ ψ ∈ m s := by
    intro q ψ h
    obtain ⟨s, hs, hψ, _⟩ := hUf q ψ Formula.top h
    exact ⟨s, hs, hψ⟩
  have hSFb : ∀ (q s : Rat) (ψ : Formula), q < s → ψ ∈ m s → Formula.someFuture ψ ∈ m q :=
    fun q s ψ hqs hψ => hUb q ψ Formula.top ⟨s, hqs, hψ, fun p _ _ => htop p⟩
  -- **Step A.** `χ = F φ` holds at every rational strictly below `r`.
  have stepA : ∀ q : Rat, (q : ℝ) < r → Formula.someFuture φ ∈ m q := by
    intro q hq
    obtain ⟨q', hq1, hq2, hχq'⟩ := limitMCSBelow_cofinal_below m r hF (q : ℝ) hq
    obtain ⟨s, hq's, hφs⟩ := hSFf q' φ hχq'
    have hq's' : (q' : ℝ) < (s : ℝ) := by exact_mod_cast hq's
    have hsr : (s : ℝ) < r := by
      rcases lt_trichotomy ((s : ℝ)) r with h | h | h
      · exact h
      · exact absurd h (hne s)
      · exact absurd hφs (hcon s h)
    exact hSFb q s φ (by exact_mod_cast lt_trans hq1 hq's') hφs
  -- **Step B.** `¬χ` holds at every rational strictly above `r`.
  have stepB : ∀ u : Rat, r < (u : ℝ) → (Formula.someFuture φ).neg ∈ m u := by
    intro u hu
    rcases SetMaximalConsistent.negation_complete (hm u) (Formula.someFuture φ) with h | h
    · exfalso
      obtain ⟨s, hus, hφs⟩ := hSFf u φ h
      exact hcon s (lt_trans hu (by exact_mod_cast hus)) hφs
    · exact h
  -- **Step C.** The Prior-U consequent at every rational strictly below `r`.
  have stepC : ∀ t : Rat, (t : ℝ) < r →
      Formula.untl (Formula.someFuture φ) (Formula.or (Formula.someFuture φ).neg
        (Formula.kPlus (Formula.someFuture φ).neg)) ∈ m t := by
    intro t ht
    -- `U(⊤, χ) ∈ m t`: witness any rational in `(t, r)`, guard true by Step A.
    obtain ⟨s0, hts0, hs0r⟩ := exists_rat_btwn ht
    have hA1 : Formula.untl (Formula.someFuture φ) Formula.top ∈ m t := by
      refine hUb t Formula.top (Formula.someFuture φ) ⟨s0, by exact_mod_cast hts0, htop s0, ?_⟩
      intro p _ hps0
      exact stepA p (lt_trans (by exact_mod_cast hps0) hs0r)
    -- `F(¬χ) ∈ m t`: witness any rational above `r`, guard trivial.
    obtain ⟨u0, hu0⟩ := exists_rat_gt r
    have hA2 : Formula.someFuture (Formula.someFuture φ).neg ∈ m t :=
      hSFb t u0 (Formula.someFuture φ).neg (by exact_mod_cast lt_trans ht hu0) (stepB u0 hu0)
    have hand : Formula.and (Formula.untl (Formula.someFuture φ) Formula.top)
        (Formula.someFuture φ).neg.someFuture ∈ m t := conj_mcs fc (hm t) _ _ hA1 hA2
    have himp := theorem_in_mcs (hm t)
      (DerivationTree.axiom [] _ (Axiom.prior_U_gap (Formula.someFuture φ)) hfc)
    exact SetMaximalConsistent.implication_property (hm t) himp hand
  -- **Step D.** The contradiction: the Until witness `u` must sit below `r`, where `χ` holds,
  -- so `K⁺(¬χ)` is forced at `u` — yet `¬χ` fails on all of `(u, r)`.
  obtain ⟨t, ht⟩ := exists_rat_lt r
  obtain ⟨u, htu, hor, hguard⟩ :=
    hUf t (Formula.or (Formula.someFuture φ).neg (Formula.kPlus (Formula.someFuture φ).neg))
      (Formula.someFuture φ) (stepC t ht)
  have hur : (u : ℝ) < r := by
    rcases lt_trichotomy ((u : ℝ)) r with h | h | h
    · exact h
    · exact absurd h (hne u)
    · exfalso
      obtain ⟨p, hrp, hpu⟩ := exists_rat_btwn h
      have hχp : Formula.someFuture φ ∈ m p :=
        hguard p (by exact_mod_cast lt_trans ht hrp) (by exact_mod_cast hpu)
      exact (SetMaximalConsistent.neg_excludes (hm p) _ (stepB p hrp)) hχp
  have hχu : Formula.someFuture φ ∈ m u := stepA u hur
  have hnn : (Formula.someFuture φ).neg.neg ∈ m u := by
    rcases SetMaximalConsistent.negation_complete (hm u) (Formula.someFuture φ).neg with h | h
    · exact absurd hχu (SetMaximalConsistent.neg_excludes (hm u) _ h)
    · exact h
  -- `Formula.or a b = a.neg.imp b`, so the disjunction at `u` is an implication.
  have hor' : ((Formula.someFuture φ).neg.neg).imp
      (Formula.kPlus (Formula.someFuture φ).neg) ∈ m u := hor
  -- `Formula.kPlus a = (U(⊤, ¬a)).neg`, so `K⁺(¬χ)` at `u` excludes `U(⊤, ¬¬χ)` at `u`.
  have hkplus : (Formula.untl (Formula.someFuture φ).neg.neg Formula.top).neg ∈ m u :=
    SetMaximalConsistent.implication_property (hm u) hor' hnn
  refine SetMaximalConsistent.neg_excludes (hm u) _ hkplus ?_
  -- But `¬¬χ` does hold throughout `(u, r)`, by Step A plus negation completeness.
  obtain ⟨s1, hus1, hs1r⟩ := exists_rat_btwn hur
  refine hUb u Formula.top (Formula.someFuture φ).neg.neg
    ⟨s1, by exact_mod_cast hus1, htop s1, ?_⟩
  intro p _ hps1
  have hχp : Formula.someFuture φ ∈ m p := stepA p (lt_trans (by exact_mod_cast hps1) hs1r)
  rcases SetMaximalConsistent.negation_complete (hm p) (Formula.someFuture φ).neg with h | h
  · exact absurd hχp (SetMaximalConsistent.neg_excludes (hm p) _ h)
  · exact h

/--
**The chronicle instantiation.**

`cantorBfmcsDense` satisfies `BFMCS.LimitFutureWitness` for every root, at any frame class
above `FrameClass.Dedekind`.

The unrestricted Until coherence hypotheses of `limitFutureWitness_of_priorU` are obtained by
**self-root instantiation** of `cantor_bfmcs_dense_restricted_fuc` / `_buc`: those theorems are
polymorphic in `root` and discard their closure-membership argument, so instantiating at
`root := Formula.untl α β` and discharging with `self_mem_subformulaClosure` recovers the
unrestricted statement. No chronicle declaration is modified.
-/
theorem cantor_bfmcs_dense_limit_future_witness (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    (cantorBfmcsDense fc A h_mcs h_box_dense).LimitFutureWitness root := by
  intro fam hfam r hr φ _ hF
  have hUf : ∀ (t : Rat) (α β : Formula), Formula.untl β α ∈ fam.mcs t →
      ∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
        (Formula.untl β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  have hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p) →
      Formula.untl β α ∈ fam.mcs t :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
        (Formula.untl β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  exact limitFutureWitness_of_priorU hfc fam.mcs fam.is_mcs hUf hUb r hr φ hF

end FormalSystem.Metalogic.BXCanonical.Chronicle
