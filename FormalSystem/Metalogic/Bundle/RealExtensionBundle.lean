/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Bundle.RealExtension
import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Theorems.Combinators
import FormalSystem.Theorems.Propositional.Core
import FormalSystem.Theorems.Propositional.Connectives

/-!
# RealExtensionBundle: the real bundle over a rational bundle

`Bundle/RealExtension.lean` extends a single rational `FMCS` to an `ℝ`-indexed one by rational
selection. This module assembles those extensions into a `BFMCS (fc := fc) ℝ` over a
`BFMCS (fc := fc) Rat`, and proves the two modal coherence fields.

## Box time-stability

Both modal fields rest on one syntactic fact: within a single `FMCS`, membership of a boxed
formula does not depend on the time index (`box_stable_in_fmcs`). The forward-in-time direction
is `temporalFutureDerived` (`Theorems/Combinators.lean`, `□φ → G(□φ)`) fed to `forward_G`.

The backward-in-time direction does **not** use a `□φ → H(□φ)` principle. No such axiom exists
in this system — `ProofSystem/Axioms.lean`'s Layer 4 has exactly one modal-temporal axiom,
`modal_future` — and none is added here. Instead the *negation* is pushed forward: from
`¬□φ` at the earlier point, S5 negative introspection (`negBoxIntrospection` below, from
`Axiom.modal_5_collapse`) gives `□¬□φ`, `temporalFutureDerived` propagates it forward with
`forward_G`, and `Axiom.modal_t` recovers `¬□φ` at the later point, contradicting `□φ` there.
Only `forward_G` is ever used, in both directions.

S5 negative introspection is already proved at `FrameClass.Base` as `negBoxToBoxNegBox` in
`BXCanonical/Frame.lean`, but that module sits *above* `Bundle/` in the import graph, so the
`fc`-generic form is re-derived here rather than imported.

## The family set is closed under real shifts

`BFMCS.toRealBundle` takes as its family set the **real-shift closure**
`{fam.toRealShift δ | fam ∈ B.families, δ : ℝ}`, not the image of `B.families` under a single
extension. This is forced by `modal_backward`, and the reason is worth recording.

`modal_backward` at a real time `t` must, from `φ` holding in *every* real family at `t`,
recover `□φ`. Through `box_mem_realLimitMCS_iff` that reduces to `□φ ∈ fam.mcs q` for every
rational `q`, and the rational bundle's own `modal_backward` at `q` then demands a witness
family carrying `φ` **at the rational `q`**. Under the image family set the only available
real families are the unshifted extensions, whose value at `t` is a left limit whose "eventually"
threshold is a real number below `t`; distinct families supply distinct thresholds and, at an
unselected `t`, no single rational lies below all of them. The rational-side field is then
inapplicable. Under the real-shift closure the witness family is instead *positioned*: the
member `fam'.toRealShift ((q : ℝ) - t)` has value exactly `fam'.mcs q` at `t`, by
`realLimitMCS_of_rat`. This mirrors the rational construction in
`BXCanonical/Chronicle/ChronicleToCountermodelBasic.lean`, whose `modal_backward` likewise
positions its witness family by choosing the chronicle's rational shift.

## Main definitions and results

- `negBoxIntrospection`, `box_stable_in_fmcs`.
- `mem_realLimitMCS_of_forall`, `box_mem_realLimitMCS_iff`.
- `BFMCS.toRealBundle`.
-/

namespace FormalSystem.Metalogic.Bundle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Theorems

/-! ## S5 negative introspection, `fc`-generically -/

/--
**S5 negative introspection**: `¬□φ → □(¬□φ)`, at an arbitrary frame class.

`Axiom.modal_5_collapse` is `◇□φ → □φ`, i.e. `¬□(¬□φ) → □φ`. Contraposing gives
`¬□φ → ¬¬□(¬□φ)`, and double negation elimination discharges the outer pair. The derivation is
built at `FrameClass.Base` and lifted, since `FrameClass.base_le` makes every frame class admit
it.
-/
noncomputable def negBoxIntrospection {fc : FrameClass} (φ : Formula) :
    DerivationTree fc [] ((Formula.box φ).neg.imp (Formula.box (Formula.box φ).neg)) := by
  have h_m5 : DerivationTree FrameClass.Base []
      ((Formula.box φ).neg.box.neg.imp (Formula.box φ)) :=
    DerivationTree.axiom [] _ (Axiom.modal_5_collapse φ) trivial
  have h_contra : DerivationTree FrameClass.Base []
      ((Formula.box φ).neg.imp (Formula.box φ).neg.box.neg.neg) :=
    Propositional.contraposition h_m5
  have h_dne : DerivationTree FrameClass.Base []
      ((Formula.box φ).neg.box.neg.neg.imp (Formula.box φ).neg.box) :=
    Propositional.doubleNegation ((Formula.box φ).neg.box)
  exact (Combinators.impTrans h_contra h_dne).lift (FrameClass.base_le fc)

/-! ## Box time-stability inside a single family -/

/--
**Forward propagation of a boxed formula inside one family.** `□ψ` at an index carries to every
strictly later index, by `temporalFutureDerived` (`□ψ → G(□ψ)`) and `forward_G`.
-/
theorem box_forward_in_fmcs {fc : FrameClass} {D : Type*} [Preorder D]
    (f : FMCS (fc := fc) D) {a b : D} (hab : a < b) (ψ : Formula)
    (hbox : Formula.box ψ ∈ f.mcs a) : Formula.box ψ ∈ f.mcs b := by
  have hG : Formula.allFuture (Formula.box ψ) ∈ f.mcs a :=
    SetMaximalConsistent.implication_property (f.is_mcs a)
      (theorem_in_mcs (f.is_mcs a) (Combinators.temporalFutureDerived ψ)) hbox
  exact f.forward_G a b (Formula.box ψ) hab hG

/--
**Box formulas are time-stable within an `FMCS`.** Membership of `□φ` is the same at every
index.

Both directions run forward along `forward_G`; see this module's docstring for why the
backward-in-time direction does not need — and this system does not have — a `□φ → H(□φ)`
principle. `LinearOrder` is used only for the trichotomy on the two indices, and both `Rat` and
`ℝ` supply it.
-/
theorem box_stable_in_fmcs {fc : FrameClass} {D : Type*} [LinearOrder D]
    (f : FMCS (fc := fc) D) (s t : D) (φ : Formula) :
    Formula.box φ ∈ f.mcs s ↔ Formula.box φ ∈ f.mcs t := by
  have up : ∀ a b : D, a < b → Formula.box φ ∈ f.mcs a → Formula.box φ ∈ f.mcs b :=
    fun a b hab hbox => box_forward_in_fmcs f hab φ hbox
  have down : ∀ a b : D, a < b → Formula.box φ ∈ f.mcs b → Formula.box φ ∈ f.mcs a := by
    intro a b hab hbox_b
    by_contra hnot
    -- `¬□φ` at the earlier index `a`.
    have hneg : (Formula.box φ).neg ∈ f.mcs a := by
      rcases SetMaximalConsistent.negation_complete (f.is_mcs a) (Formula.box φ) with h | h
      · exact absurd h hnot
      · exact h
    -- `□¬□φ` at `a`, by S5 negative introspection.
    have hboxneg : Formula.box (Formula.box φ).neg ∈ f.mcs a :=
      SetMaximalConsistent.implication_property (f.is_mcs a)
        (theorem_in_mcs (f.is_mcs a) (negBoxIntrospection φ)) hneg
    -- Push it forward to `b` and strip the box with `modal_t`.
    have hboxneg_b : Formula.box (Formula.box φ).neg ∈ f.mcs b :=
      box_forward_in_fmcs f hab (Formula.box φ).neg hboxneg
    have hneg_b : (Formula.box φ).neg ∈ f.mcs b :=
      SetMaximalConsistent.implication_property (f.is_mcs b)
        (theorem_in_mcs (f.is_mcs b)
          (DerivationTree.axiom [] _ (Axiom.modal_t (Formula.box φ).neg) (FrameClass.base_le fc)))
        hboxneg_b
    exact set_consistent_not_both (f.is_mcs b).1 (Formula.box φ) hbox_b hneg_b
  rcases lt_trichotomy s t with h | h | h
  · exact ⟨fun hs => up s t h hs, fun ht => down s t h ht⟩
  · rw [h]
  · exact ⟨fun hs => down t s h hs, fun ht => up t s h ht⟩

/-! ## Boxed membership in the real extension -/

/--
A formula lying in **every** rational set lies in the real extension at every point. Immediate
at selected points; at unselected points the membership set is all of `Rat`, hence large for
any filter.
-/
theorem mem_realLimitMCS_of_forall (m : Rat → Set Formula) (δ x : ℝ) (ψ : Formula)
    (h : ∀ q : Rat, ψ ∈ m q) : ψ ∈ realLimitMCS m δ x := by
  by_cases hx : ∃ q : Rat, (q : ℝ) = x + δ
  · obtain ⟨q, hq⟩ := hx
    rw [realLimitMCS_of_rat m δ x q hq]
    exact h q
  · rw [realLimitMCS_of_not_rat m δ x hx, mem_limitMCSBelow]
    have huniv : {q : Rat | ψ ∈ m q} = Set.univ := by
      ext q; simp [h q]
    rw [huniv]
    exact Filter.univ_mem

/--
**Boxed membership in the real extension is case-free.** Given box time-stability of the
rational family, `□φ` lies in the extension at *some* real point exactly when it lies in *every*
rational set.

At a selected point this is stability alone. At an unselected point the forward direction is the
descent handle `limitMCSBelow_cofinal_below`: the ultrafilter limit realises `□φ` at some
rational below the point, and stability spreads it to all rationals. This is what makes both
modal fields of `BFMCS.toRealBundle` free of the selected/unselected case split.
-/
theorem box_mem_realLimitMCS_iff (m : Rat → Set Formula)
    (hstab : ∀ (s t : Rat) (ψ : Formula), Formula.box ψ ∈ m s ↔ Formula.box ψ ∈ m t)
    (δ x : ℝ) (φ : Formula) :
    Formula.box φ ∈ realLimitMCS m δ x ↔ ∀ q : Rat, Formula.box φ ∈ m q := by
  constructor
  · intro h q
    by_cases hx : ∃ p : Rat, (p : ℝ) = x + δ
    · obtain ⟨p, hp⟩ := hx
      rw [realLimitMCS_of_rat m δ x p hp] at h
      exact (hstab p q φ).mp h
    · rw [realLimitMCS_of_not_rat m δ x hx] at h
      obtain ⟨p, _, _, hp⟩ :=
        limitMCSBelow_cofinal_below m (x + δ) h (x + δ - 1) (by linarith)
      exact (hstab p q φ).mp hp
  · intro h
    exact mem_realLimitMCS_of_forall m δ x (Formula.box φ) h

/-! ## The real bundle -/

/--
The **real bundle** over a rational bundle: every real shift of every rational family, extended
to `ℝ` by rational selection.

The family set is the real-shift closure rather than an image; this module's docstring records
why `modal_backward` forces that choice. Both modal fields run through
`box_mem_realLimitMCS_iff`, so neither performs a selected/unselected case split.
-/
noncomputable def BFMCS.toRealBundle {fc : FrameClass} (B : BFMCS (fc := fc) Rat) :
    BFMCS (fc := fc) ℝ where
  families := {G | ∃ fam ∈ B.families, ∃ δ : ℝ, G = fam.toRealShift δ}
  nonempty := ⟨B.evalFamily.toRealShift 0, B.evalFamily, B.eval_family_mem, 0, rfl⟩
  modal_forward := by
    rintro G ⟨fam, hfam, δ, rfl⟩ φ t hbox G' ⟨fam', hfam', δ', rfl⟩
    have hbox' : Formula.box φ ∈ realLimitMCS fam.mcs δ t := hbox
    have hall : ∀ q : Rat, Formula.box φ ∈ fam.mcs q :=
      (box_mem_realLimitMCS_iff fam.mcs (fun s t ψ => box_stable_in_fmcs fam s t ψ) δ t φ).mp hbox'
    exact mem_realLimitMCS_of_forall fam'.mcs δ' t φ
      (fun q => B.modal_forward fam hfam φ q (hall q) fam' hfam')
  modal_backward := by
    rintro G ⟨fam, hfam, δ, rfl⟩ φ t hall
    show Formula.box φ ∈ realLimitMCS fam.mcs δ t
    refine (box_mem_realLimitMCS_iff fam.mcs
      (fun s t ψ => box_stable_in_fmcs fam s t ψ) δ t φ).mpr ?_
    intro q
    refine B.modal_backward fam hfam φ q ?_
    intro fam' hfam'
    -- The witness family is *positioned* at `t`: its shifted coordinate there is exactly `q`.
    have hmem : fam'.toRealShift ((q : ℝ) - t) ∈
        {G : FMCS (fc := fc) ℝ | ∃ f ∈ B.families, ∃ e : ℝ, G = f.toRealShift e} :=
      ⟨fam', hfam', (q : ℝ) - t, rfl⟩
    have hφ : φ ∈ realLimitMCS fam'.mcs ((q : ℝ) - t) t := hall _ hmem
    rwa [realLimitMCS_of_rat fam'.mcs ((q : ℝ) - t) t q (by ring)] at hφ
  evalFamily := B.evalFamily.toRealShift 0
  eval_family_mem := ⟨B.evalFamily, B.eval_family_mem, 0, rfl⟩

end FormalSystem.Metalogic.Bundle
