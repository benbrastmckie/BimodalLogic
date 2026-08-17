/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.BXCanonical.Chronicle.PointInsertion
import FormalSystem.Metalogic.Bundle.RealExtensionBundle

/-!
# The definable-left-gap discharge of the Until/Since guard, above

This module is the **Prior-U mirror** of `ChronicleLimitGuardWitness.lean`. Where that module
moves a guard from **above** a gap to **below** it — answering *"how far down does the guard
reach?"* — this one moves a guard from **below** a gap to **above** it: at an **unselected** real
`r`, if a formula `ψ` is eventually true below `r` (`ψ ∈ limitSetBelow m r`), then `ψ` already
holds at every rational of some interval `(r, c)` abutting `r` **from above**.

Read contrapositively, that is the statement that the `ψ`-region has no definable **left** gap at
`r`. Its consumer is the forward `untl` case of the real extension, which is handed a guard
running up to an unselected real and must continue it past the gap.

## The argument

The excluded configuration is Reynolds' **left gap**, Reynolds 1992 **printed p.175**:

> "Given a temporal formula `A`, we can define a connective `γ⁺` by saying that `γ⁺(A)` holds
> exactly when `A` remains true for a while after now but only up until a gap after which `A` is
> arbitrarily soon false. If `γ⁺(A)` is true anywhere we call the indicated gap an `A` *left gap*
> and more generally a *definable gap*. Dually there is `γ⁻` and *right gaps*."

The proof move is the one Reynolds uses in the proof of Theorem 3, **printed p.176**: "Suppose for
contradiction that `M ⊨ U'(A, B)(t)` in some Prior structure `M`. Thus `B` holds for a while up
until a gap after which `¬B` is true arbitrarily soon. By Prior-U applied to `B` we have
`M ⊨ U(¬B ∨ K⁺(¬B), B)(t)` which is the contradiction." That is taken here directly, in the
future direction, rather than through its past mirror as `limitGuardBelow_of_priorS` does. The
same discipline — **apply the gap axiom to the formula uninterruptedly true on an interval
abutting the gap, never to a witness** — governs all of Reynolds' §6 appeals, including Lemma 3
(**printed pp.176, 178**).

The decisive choice is again **which formula plays the role of `B`** — and here, as in the past
mirror, it is not a witness but the **guard** `ψ` itself. The hypothesis `hev` literally hands us
a real threshold `z < r` with `ψ` true at every rational of `(z, r)`, so at any rational
`x ∈ (z, r)` the Prior-U antecedent `U(⊤, ψ)` is free. Prior-U then supplies a rational `e > x` at
which `¬ψ ∨ K⁺(¬ψ)` holds while `ψ` holds throughout `(x, e)`; unselectedness of `r` rules out
`e = r`, and the eventual guard itself rules out `e < r`, so `r < e` and the interval `(r, e)` is
the required one.

Unselectedness of `r` is used exactly **once**, to exclude `(e : ℝ) = r`. There is no outer
`by_contra`: the argument is a direct two-case split on whether `F(¬ψ)` holds at `x`, and the
first case needs no axiom at all.

`Axiom.prior_U_gap` (`ProofSystem/Axioms.lean`) has `minFrameClass = .Dedekind`, so both theorems
below carry `(hfc : FrameClass.Dedekind ≤ fc)`. This is the third place on the route where the
Dedekind axiom layer is consumed, after `ChronicleLimitGapWitness.lean` (`prior_U_gap`, at a
witness) and `ChronicleLimitGuardWitness.lean` (`prior_S_gap`, at a guard).

## Why the obligation is real

It has no counterpart in Burgess 1982 I, whose `U`/`S` chronicle this tree's chronicle layer
transcribes: Burgess' variants table (**printed p.369**) lists only Density, Discreteness,
First/Last Element and No First/No Last Element — there is **no Dedekind or continuity variant at
all** — and every witness his construction places sits strictly between two points already
present. No point is ever placed at a gap, so the interval datum his chronicle carries never has
to survive one. Passing to the reals is exactly where that datum is lost.

## Scoping caveat: no inheritance of expressive completeness

Reynolds obtains *his* gap-facing formulas "by expressive completeness" (**printed pp.176-178**);
his Theorem 3 argument is embedded in an expressive-completeness induction, and his §6 lemmas
construct their `B` and `C` the same way. **Nothing of the kind is inherited here.** In this
module `ψ` is a **hypothesis binder**, never a constructed formula: only the Prior-U appeal is
copied, never the machinery around it. No expressive-completeness apparatus is built, assumed, or
needed, and this module introduces no new connective.

## The self-root instantiation

`cantor_bfmcs_dense_restricted_fuc` and `_buc` are stated for a restricted (closure-bounded)
predicate, but they are polymorphic in `root` and their proofs **discard** the closure-membership
argument outright. Instantiating at `root := Formula.untl α β` and discharging the side condition
with `self_mem_subformulaClosure` therefore recovers **unrestricted** Until coherence for the
Cantor dense chronicle, for every formula, without touching a single chronicle declaration. Note
the projection: this module uses the `.1` (`untl`) halves where `ChronicleLimitGuardWitness.lean`
uses the `.2` (`snce`) halves.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Theorems.Combinators

/--
**The general guard gap lemma, above.**

If a rational family `m` satisfies Until coherence in both directions (unrestricted), then at any
**unselected** real `r`, a formula `ψ` that is eventually true below `r` — that is,
`ψ ∈ limitSetBelow m r` — also holds at every rational of some interval `(r, c)` abutting `r` from
above. Equivalently: the `ψ`-region has no definable **left** gap at `r`.

The proof is Reynolds 1992's Theorem 3 argument (printed p.176), applied to the **guard** `ψ`
rather than to a witness, which is what makes the Prior-U antecedent `U(⊤, ψ)` available. See the
module docstring. `Axiom.prior_U_gap` is consumed at `ψ`, whence the hypothesis `hfc`.
-/
theorem limitGuardAbove_of_priorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (m : Rat → Set Formula) (hm : ∀ q : Rat, SetMaximalConsistent (fc := fc) (m q))
    (hUf : ∀ (t : Rat) (α β : Formula), Formula.untlQ β α ∈ m t →
      ∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p)
    (hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ m s ∧ ∀ p : Rat, t < p → p < s → β ∈ m p) →
      Formula.untlQ β α ∈ m t)
    (r : ℝ) (hr : ¬ ∃ q : Rat, (q : ℝ) = r) (ψ : Formula)
    (hev : ψ ∈ limitSetBelow m r) :
    ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ m q := by
  -- The eventual-truth datum: a real threshold `z < r` below which `ψ` is uninterrupted.
  obtain ⟨z, hzr, hguard⟩ := hev
  -- A rational `x` strictly inside the guarded interval `(z, r)`.
  obtain ⟨x, hzx, hxr⟩ := exists_rat_btwn hzr
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
  by_cases hcase : ψ.neg.someFuture ∈ m x
  · -- **Case 2 — `F(¬ψ) ∈ m x`.** The Prior-U antecedent is available; the axiom applies.
    -- `U(⊤, ψ) ∈ m x`: witness any rational in `(x, r)`, guard supplied by `hguard`.
    obtain ⟨s₀, hxs₀, hs₀r⟩ := exists_rat_btwn hxr
    have hA1 : Formula.untlQ ψ Formula.top ∈ m x := by
      refine hUb x Formula.top ψ ⟨s₀, by exact_mod_cast hxs₀, htop s₀, ?_⟩
      intro p hxp hps₀
      have hzp : z < (p : ℝ) := lt_trans hzx (by exact_mod_cast hxp)
      have hpr : (p : ℝ) < r := lt_trans (by exact_mod_cast hps₀) hs₀r
      exact hguard p hzp hpr
    have hand : Formula.and (Formula.untlQ ψ Formula.top) ψ.neg.someFuture ∈ m x :=
      conj_mcs fc (hm x) _ _ hA1 hcase
    have himp := theorem_in_mcs (hm x)
      (DerivationTree.axiom [] _ (Axiom.prior_U_gap ψ) hfc)
    have hcons : Formula.untlQ ψ (Formula.or ψ.neg (Formula.kPlus ψ.neg)) ∈ m x :=
      SetMaximalConsistent.implication_property (hm x) himp hand
    -- Prior-U's consequent, read forwards: a rational `e > x` carrying `¬ψ ∨ K⁺(¬ψ)`, with `ψ`
    -- uninterrupted on `(x, e)`.
    obtain ⟨e, hxe, hor, hguard'⟩ :=
      hUf x (Formula.or ψ.neg (Formula.kPlus ψ.neg)) ψ hcons
    have hze : z < (e : ℝ) := lt_trans hzx (by exact_mod_cast hxe)
    -- `e` sits strictly above `r`: it cannot equal `r` (unselectedness — the only use), and it
    -- cannot fall below `r`, since there `hguard` forces `ψ` and hence contradicts `K⁺(¬ψ)`.
    have hre : r < (e : ℝ) := by
      rcases lt_trichotomy ((e : ℝ)) r with h | h | h
      · exfalso
        have hψe : ψ ∈ m e := hguard e hze h
        have hnn : ψ.neg.neg ∈ m e := hdn e hψe
        -- `Formula.or a b = a.neg.imp b`, so the disjunction at `e` is an implication.
        have hor' : (ψ.neg).neg.imp (Formula.kPlus ψ.neg) ∈ m e := hor
        -- `Formula.kPlus a = (U(⊤, ¬a)).neg`, so `K⁺(¬ψ)` at `e` excludes `U(⊤, ¬¬ψ)` at `e`.
        have hkplus : (Formula.untlQ ψ.neg.neg Formula.top).neg ∈ m e :=
          SetMaximalConsistent.implication_property (hm e) hor' hnn
        refine SetMaximalConsistent.neg_excludes (hm e) _ hkplus ?_
        -- But `¬¬ψ` does hold throughout `(e, r) ⊆ (z, r)`, by `hguard`.
        obtain ⟨e₁, hee₁, he₁r⟩ := exists_rat_btwn h
        refine hUb e Formula.top ψ.neg.neg ⟨e₁, by exact_mod_cast hee₁, htop e₁, ?_⟩
        intro p hep hpe₁
        have hzp : z < (p : ℝ) := lt_trans hze (by exact_mod_cast hep)
        have hpr : (p : ℝ) < r := lt_trans (by exact_mod_cast hpe₁) he₁r
        exact hdn p (hguard p hzp hpr)
      · exact absurd ⟨e, h⟩ hr
      · exact h
    -- The interval `(r, e)` is the required one.
    refine ⟨e, hre, ?_⟩
    intro q h₁ h₂
    exact hguard' q (by exact_mod_cast lt_trans hxr h₁) (by exact_mod_cast h₂)
  · -- **Case 1 — `F(¬ψ) ∉ m x`.** No axiom appeal: `ψ` already holds at *every* rational above
    -- `x`, so any rational above `r` works as the right endpoint.
    have hno : ∀ s : Rat, x < s → ψ ∈ m s := by
      intro s hxs
      rcases SetMaximalConsistent.negation_complete (hm s) ψ with h | h
      · exact h
      · exact absurd (hUb x ψ.neg Formula.top ⟨s, hxs, h, fun p _ _ => htop p⟩) hcase
    obtain ⟨c, hrc⟩ := exists_rat_gt r
    refine ⟨c, hrc, ?_⟩
    intro q h₁ _
    exact hno q (by exact_mod_cast lt_trans hxr h₁)

/--
**The chronicle instantiation.**

The Cantor dense chronicle's families satisfy the guard-reach property above every unselected
real, at any frame class above `FrameClass.Dedekind`.

The unrestricted Until coherence hypotheses of `limitGuardAbove_of_priorU` are obtained by
**self-root instantiation** of `cantor_bfmcs_dense_restricted_fuc` / `_buc`: those theorems are
polymorphic in `root` and discard their closure-membership argument, so instantiating at
`root := Formula.untl α β` and discharging with `self_mem_subformulaClosure` recovers the
unrestricted statement. No chronicle declaration is modified.
-/
theorem cantor_bfmcs_dense_limit_guard_above (fc : FrameClass)
    (hfc : FrameClass.Dedekind ≤ fc) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) :
    ∀ fam ∈ (cantorBfmcsDense fc A h_mcs h_box_dense).families, ∀ r : ℝ,
      (¬ ∃ q : Rat, (q : ℝ) = r) → ∀ ψ : Formula, ψ ∈ limitSetBelow fam.mcs r →
      ∃ c : Rat, r < (c : ℝ) ∧ ∀ q : Rat, r < (q : ℝ) → (q : ℝ) < (c : ℝ) → ψ ∈ fam.mcs q := by
  intro fam hfam r hr ψ hev
  have hUf : ∀ (t : Rat) (α β : Formula), Formula.untlQ β α ∈ fam.mcs t →
      ∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
        (Formula.untlQ β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  have hUb : ∀ (t : Rat) (α β : Formula),
      (∃ s : Rat, t < s ∧ α ∈ fam.mcs s ∧ ∀ p : Rat, t < p → p < s → β ∈ fam.mcs p) →
      Formula.untlQ β α ∈ fam.mcs t :=
    fun t α β h =>
      (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
        (Formula.untlQ β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  exact limitGuardAbove_of_priorU hfc fam.mcs fam.is_mcs hUf hUb r hr ψ hev

end FormalSystem.Metalogic.BXCanonical.Chronicle
