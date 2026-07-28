/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.BXCanonical.Chronicle.PointInsertion
import FormalSystem.Metalogic.Bundle.RealExtensionBundle

/-!
# The definable-right-gap discharge of the Until/Since guard

`Bundle/RealExtensionBundle.lean` isolates a second residual obligation, dual to the one
`ChronicleLimitGapWitness.lean` discharges. Where that module answers *"where is the witness?"*,
this one answers *"how far down does the guard reach?"*: at an **unselected** real `r`, if a
formula `ψ` holds at every rational of some interval `(r, c)` abutting `r` **from above**, then
`ψ` already holds throughout an interval abutting `r` **from below**, i.e. `ψ ∈ limitSetBelow m r`.
That is `BFMCS.LimitGuardBelow`. This module discharges it.

## Why the obligation is real

The obligation has no counterpart in Burgess 1982 I, the paper whose `U`/`S` chronicle (conditions
C1/C3/C5a/C4a, **printed p.372**) this tree's chronicle layer transcribes. Burgess' variants table
(**printed p.369**) lists only Density, Discreteness, First/Last Element and No First/No Last
Element — there is **no Dedekind or continuity variant at all** — and every witness his
construction places sits strictly between two points already present (`z = x + y/2`, `y = x + 1`,
`z = x + x'/2`; **printed pp.372-373**). No point is ever placed at a gap, so the interval datum
`g(x,y)` that his chronicle carries never has to survive one. Passing to the reals is exactly
where that datum is lost, which is the structural root of this obligation. Burgess 1984 runs the
completion route only in the `F`/`G` fragment and reaches for his continuity axiom `A7a` at the
analogous step (**printed pp.109-110**).

## The argument

The excluded configuration is Reynolds' **right gap**, Reynolds 1992 **printed p.175**:

> "Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds
> exactly when `A` remains true for a while after now but only up until a gap after which `A` is
> arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` *left gap*
> and more generally a *definable gap*. Dually there is `γ⁻` and *right gaps*."

The proof move is the one Reynolds uses in the proof of Theorem 3, **printed p.176**: "Suppose for
contradiction that `M ⊨ U'(A, B)(t)` in some Prior structure `M`. Thus `B` holds for a while up
until a gap after which `¬B` is true arbitrarily soon. By Prior-U applied to `B` we have
`M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction." Its past mirror, and the one taken here,
applies **Prior-S** to the formula that is uninterruptedly true on an interval ending at the gap.
The same discipline governs Reynolds' Lemma 3, **printed p.178**.

The decisive choice is again **which formula plays the role of `B`** — and here it is not a
witness but the **guard** `ψ` itself. The hypothesis of the obligation literally hands us `ψ` true
at every rational of `(r, c)`, so the Prior-S antecedent `S(⊤, ψ)` is free at any rational
`t ∈ (r, c)`. Prior-S then supplies a rational `w` below `t` at which `¬ψ ∨ K⁻(¬ψ)` holds while
`ψ` holds throughout `(w, t)`; unselectedness of `r` rules out `w = r`, and the guard itself rules
out `w > r`, so `w < r` and the interval `(w, r)` witnesses `ψ ∈ limitSetBelow m r`.

Unselectedness of `r` is used exactly **once**, to exclude `(w : ℝ) = r`. There is no outer
`by_contra`: the argument is a direct two-case split on whether `P(¬ψ)` holds at `t`, and the
first case needs no axiom at all.

`Axiom.prior_S_gap` (`ProofSystem/Axioms.lean`) has `minFrameClass = .Dedekind`, so both theorems
below carry `(hfc : FrameClass.Dedekind ≤ fc)`. The axiom was present in the tree and proved sound
(`Metalogic/Soundness.lean`) but was **consumed nowhere on the completeness route** before this
module; `Axiom.prior_U_gap` alone was in use, by `ChronicleLimitGapWitness.lean`.

## Scoping caveat: no inheritance of expressive completeness

Reynolds' §6 Lemma 2 obtains *its* formula "by the expressive completeness of `U` and `S`"
(**printed p.177**). Nothing of the kind is inherited here. In this module `ψ` is a **hypothesis
binder**, never a constructed formula: only the Prior-S appeal is copied, never the machinery
around it. No expressive-completeness apparatus is built, assumed, or needed.

## The self-root instantiation

`cantor_bfmcs_dense_restricted_fuc` and `_buc` are stated for a restricted (closure-bounded)
predicate, but they are polymorphic in `root` and their proofs **discard** the closure-membership
argument outright. Instantiating at `root := Formula.snce α β` and discharging the side condition
with `self_mem_subformulaClosure` therefore recovers **unrestricted** Since coherence for the
Cantor dense chronicle, for every formula, without touching a single chronicle declaration. Note
the projection: this module uses the `.2` (`snce`) halves where `ChronicleLimitGapWitness.lean`
uses the `.1` (`untl`) halves.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Theorems.Combinators

/--
**The general guard gap lemma.**

If a rational family `m` satisfies Since coherence in both directions (unrestricted), then at any
**unselected** real `r`, a formula `ψ` holding at every rational of an interval `(r, c)` abutting
`r` from above also holds throughout an interval abutting `r` from below — that is,
`ψ ∈ limitSetBelow m r`. Equivalently: the `ψ`-region has no definable **right** gap at `r`.

The proof is the past mirror of Reynolds 1992's Theorem 3 argument (printed p.176), applied to the
**guard** `ψ` rather than to a witness, which is what makes the Prior-S antecedent `S(⊤, ψ)`
available. See the module docstring. `Axiom.prior_S_gap` is consumed at `ψ`, whence the hypothesis
`hfc`.
-/
theorem limitGuardBelow_of_priorS {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hSf : ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ m t →
      ∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p)
    (hSb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ m s ∧ ∀ p : Rat, s < p → p < t → β ∈ m p) →
      Formula.snce α β ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
    (c : Rat) (hc : r < (c : ℝ))
    (hguard : ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q) :
    ψ ∈ limitSetBelow m r := by
  -- A rational `t` strictly inside the guarded interval `(r, c)`.
  obtain ⟨t, hrt, htc⟩ := exists_rat_btwn hc
  -- `⊤` sits in every member of the family, so `⊤`-guards are free.
  have htop : ∀ q : Rat, Formula.top ∈ m q := by
    intro q
    exact theorem_in_mcs (hm q) (identity (fc := fc) Formula.bot)
  -- Double negation introduction inside a maximal consistent set.
  have hdn : ∀ q : Rat, ψ ∈ m q → ψ.neg.neg ∈ m q := by
    intro q hq
    rcases SetMaximalConsistent.negation_complete (hm q) ψ.neg with h | h
    · exact absurd hq (SetMaximalConsistent.neg_excludes (hm q) _ h)
    · exact h
  by_cases hcase : ψ.neg.somePast ∈ m t
  · -- **Case 2 — `P(¬ψ) ∈ m t`.** The Prior-S antecedent is available; the axiom applies.
    -- `S(⊤, ψ) ∈ m t`: witness any rational in `(r, t)`, guard supplied by `hguard`.
    obtain ⟨w₀, hrw₀, hw₀t⟩ := exists_rat_btwn hrt
    have hA1 : Formula.snce Formula.top ψ ∈ m t := by
      refine hSb t Formula.top ψ ⟨w₀, by exact_mod_cast hw₀t, htop w₀, ?_⟩
      intro p hw₀p hpt
      have hrp : r < (p : ℝ) := lt_trans hrw₀ (by exact_mod_cast hw₀p)
      have hpc : (p : ℝ) < (c : ℝ) := lt_trans (by exact_mod_cast hpt) htc
      exact hguard p hrp hpc
    have hand : Formula.and (Formula.snce Formula.top ψ) ψ.neg.somePast ∈ m t :=
      conj_mcs fc (hm t) _ _ hA1 hcase
    have himp := theorem_in_mcs (hm t)
      (DerivationTree.axiom [] _ (Axiom.prior_S_gap ψ) hfc)
    have hcons : Formula.snce (Formula.or ψ.neg (Formula.kMinus ψ.neg)) ψ ∈ m t :=
      SetMaximalConsistent.implication_property (hm t) himp hand
    -- Prior-S's consequent, read backwards: a rational `w < t` carrying `¬ψ ∨ K⁻(¬ψ)`, with
    -- `ψ` uninterrupted on `(w, t)`.
    obtain ⟨w, hwt, hor, hguard'⟩ :=
      hSf t (Formula.or ψ.neg (Formula.kMinus ψ.neg)) ψ hcons
    have hwc : (w : ℝ) < (c : ℝ) := lt_trans (by exact_mod_cast hwt) htc
    -- `w` sits strictly below `r`: it cannot equal `r` (unselectedness — the only use), and it
    -- cannot exceed `r`, since there `hguard` forces `ψ` and hence contradicts `K⁻(¬ψ)`.
    have hwr : (w : ℝ) < r := by
      rcases lt_trichotomy ((w : ℝ)) r with h | h | h
      · exact h
      · exact absurd ⟨w, h⟩ hr
      · exfalso
        have hψw : ψ ∈ m w := hguard w h hwc
        have hnn : ψ.neg.neg ∈ m w := hdn w hψw
        -- `Formula.or a b = a.neg.imp b`, so the disjunction at `w` is an implication.
        have hor' : (ψ.neg).neg.imp (Formula.kMinus ψ.neg) ∈ m w := hor
        -- `Formula.kMinus a = (S(⊤, ¬a)).neg`, so `K⁻(¬ψ)` at `w` excludes `S(⊤, ¬¬ψ)` at `w`.
        have hkminus : (Formula.snce Formula.top ψ.neg.neg).neg ∈ m w :=
          SetMaximalConsistent.implication_property (hm w) hor' hnn
        refine SetMaximalConsistent.neg_excludes (hm w) _ hkminus ?_
        -- But `¬¬ψ` does hold throughout `(r, w) ⊆ (r, c)`, by `hguard`.
        obtain ⟨w₁, hrw₁, hw₁w⟩ := exists_rat_btwn h
        refine hSb w Formula.top ψ.neg.neg ⟨w₁, by exact_mod_cast hw₁w, htop w₁, ?_⟩
        intro p hw₁p hpw
        have hrp : r < (p : ℝ) := lt_trans hrw₁ (by exact_mod_cast hw₁p)
        have hpc : (p : ℝ) < (c : ℝ) := lt_trans (by exact_mod_cast hpw) hwc
        exact hdn p (hguard p hrp hpc)
    -- The interval `(w, r)` is the required threshold interval.
    refine ⟨(w : ℝ), hwr, ?_⟩
    intro q h₁ h₂
    exact hguard' q (by exact_mod_cast h₁) (by exact_mod_cast lt_trans h₂ hrt)
  · -- **Case 1 — `P(¬ψ) ∉ m t`.** No axiom appeal: `ψ` already holds at *every* rational below
    -- `t`, so any threshold below `r` works.
    have hno : ∀ s : Rat, s < t → ψ ∈ m s := by
      intro s hst
      rcases SetMaximalConsistent.negation_complete (hm s) ψ with h | h
      · exact h
      · exact absurd (hSb t ψ.neg Formula.top ⟨s, hst, h, fun p _ _ => htop p⟩) hcase
    refine ⟨r - 1, by linarith, ?_⟩
    intro q _ h₂
    exact hno q (by exact_mod_cast lt_trans h₂ hrt)

/--
**The chronicle instantiation.**

`cantorBfmcsDense` satisfies `BFMCS.LimitGuardBelow`, at any frame class above
`FrameClass.Dedekind`.

The unrestricted Since coherence hypotheses of `limitGuardBelow_of_priorS` are obtained by
**self-root instantiation** of `cantor_bfmcs_dense_restricted_fuc` / `_buc`: those theorems are
polymorphic in `root` and discard their closure-membership argument, so instantiating at
`root := Formula.snce α β` and discharging with `self_mem_subformulaClosure` recovers the
unrestricted statement. No chronicle declaration is modified.
-/
theorem cantor_bfmcs_dense_limit_guard_below (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) :
    (cantorBfmcsDense fc A h_mcs h_box_dense).LimitGuardBelow := by
  intro fam hfam r hr ψ c hc hguard
  have hSf : ∀ (t : Rat) (α β : Formula), Formula.snce α β ∈ fam.mcs t →
      ∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
        (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
  have hSb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, s < t ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, s < p → p < t → β ∈ fam.mcs p) →
      Formula.snce α β ∈ fam.mcs t :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
        (Formula.snce α β) fam hfam).2 t α β (self_mem_subformulaClosure _) h
  exact limitGuardBelow_of_priorS hfc fam.mcs fam.is_mcs hSf hSb r hr ψ c hc hguard

end FormalSystem.Metalogic.BXCanonical.Chronicle
