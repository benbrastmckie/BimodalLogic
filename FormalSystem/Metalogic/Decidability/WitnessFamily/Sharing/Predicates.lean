/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Predicates
import FormalSystem.Metalogic.Decidability.WitnessFamily.Sharing.Thread

/-!
# The Certificate Predicates for a State-Sharing Family

Which of the deterministic device's four conditions survive recombination, and which do not, is
where the received account of this design is wrong in both directions. This module states the
ones that change and records, by name, the ones that do not.

## (C3) `BoxFaithful` is reused **verbatim**, and that is a correction

`WitnessFamily.BoxFaithful` reads

```
bx χ = true ↔ ∀ i t, χ ∈ W.L i t
```

Its right-hand side quantifies over the **label pool** — every position of every lasso — and
mentions no history, no orbit and no task relation. A recombined history visits a sequence of
positions `(θ.idx t, t)`, each of which is one of those same positions, so recombination adds
**no new label** for `□` to range over and the condition's content is unchanged.

The claim that (C3) is the load-bearing obstruction, and needs redesigning, is therefore refuted
by the Lean reading. `Sharing/Agreement.lean` applies `BoxFaithful` unchanged. What *does* break
is (C1) `LocalCoherentLab` and (C2) `FulfillingLab`, both of which are stated **per lasso** and
so silently assume a history never leaves the lasso it started on. Those are the two conditions
this module and `Sharing/Fulfil.lean` replace.

## (C4) `Target` is reused verbatim

`WitnessFamily.Target` names a time on the main lasso; it mentions neither the frame nor its
histories, so it is inherited with no change.

## (C0) `AtomCoherent` is new, and mandatory

`WitnessFamily/Predicates.lean`'s header records that atoms are "deliberately unconstrained",
and explains that this is what makes the agreement theorem's `atom` case `Iff.rfl`. That
explanation is exactly why the condition has to be added here: the branching model's carrier is
a quotient, so its valuation reads a `share`-**class** rather than an index/time pair, and a
`Quotient.lift` needs the labels of any two shared indices to agree on atoms. Without (C0) the
valuation is not even well defined, let alone sound.

Nothing else about the labels needs to agree across a shared state. Two lassos may carry
different `untl` labels at a shared position and the certificate is still sound — that is the
branching, and it is what makes the device see more than the deterministic one.

## (C1') `LocalCoherentShare`

The `bot`, `imp` and `box` clauses are one-position conditions and are carried over unchanged.
The two temporal clauses are not: the one-step unfolding of `untl g e` at `(i, t)` must hold
against **every** state the history can move to, which is every `j` with `share (t+1) i j`;
dually, the unfolding of `snce g e` must hold against every predecessor, which is every `k` with
`share t k i`. Taking `j := i` (resp. `k := i`) recovers the deterministic clause, which is why
`localCoherentLab_of_share` below is unconditional.

## (C2') `ThreadFulfilling`

`WitnessFamily.FulfillingLab` reads an eventuality's discharge off the *one lasso* the label
sits on: `untl g e ∈ L i t` obliges lasso `i` itself to deliver `e` later. That is sound only
because the deterministic device's histories are the lasso orbits. Once a history may cross to
another lasso at a shared state, the obligation is a **universal path quantifier** — `A[g U e]`
in branching-time notation — over every thread through the position, and a family can satisfy
the per-lasso condition while some recombined thread never delivers.

`ThreadFulfilling` below is that universal form. Taking the constant thread recovers the
deterministic condition, which is why `fulfillingLab_of_thread` is unconditional; the converse
fails, and that failure is the whole content of the branching device's fulfilment check.

Its decision procedure is not here: it is `Sharing/Fulfil.lean`'s finite position graph and
`A[g U e]` least fixpoint, together with the window reduction that connects the two.

## Recorded gap, now closed elsewhere: (C5), the stability clause, is not stateable here

A fifth condition `StabFaithful`, quantifying `⊡φ` over the shared states at one time, is **not
stated in this module** and cannot be. It is now stated, decided and consumed at
`Metalogic/Decidability/PlusWitnessFamily/`: the condition itself in `Predicates.lean`, its
decision procedure in `Decide.lean`, and the agreement case that makes it load-bearing in
`Agreement.lean`'s `plusTruth_iff_mem`.

The explanation of why it is not stateable *here* is retained below, unchanged, because it is
the reason that subtree exists at all — and because the reason is type-level, so it does not
stop being true once the condition has a home:

`WitnessFamily` is indexed by `FormalSystem.Syntax.Context = List Formula`, and
`FormalSystem.Syntax.Formula` has exactly six constructors — `atom`, `bot`, `imp`, `box`,
`untl`, `snce`. The stability modal `⊡` is `PlusFormula.stab`, a constructor of the **separate
inductive** `FormalSystem.PlusLanguage.PlusFormula` (`PlusLanguage/Formula.lean` records the
separate-inductive decision and the constructor-to-constructor embedding). There is therefore no
`⊡φ` to write on the left of (C5) at this datatype, and stating the condition would require
re-indexing the whole certificate — `LabelledLasso`, `closureOf`, `WitnessFamily`, its four
conditions and its agreement theorem — over `PlusFormula`.

That re-indexing is a separate, substantial addition, not a clause, and it has since been made
under `PlusWitnessFamily/`. What this directory *does* deliver for the stability modal is the
thing (C5) was wanted for, and it is what the L⁺ subtree is built on: a frame whose task relation
branches, on which `⊡` is not collapsed to the identity by
`PlusLanguage/PlusDeterminism.lean`'s `states_eq_of_deterministic`. The label-free part of that
substrate — `Sharing/Skeleton.lean` and `Sharing/Window.lean` — is shared between the two
certificates verbatim rather than duplicated; nothing in this directory was edited to accommodate
the L⁺ one, and the deterministic device's export contract is untouched.

## Main Definitions

- `SharingWitnessFamily.AtomCoherent` — (C0) atoms agree across a shared state
- `SharingWitnessFamily.LocalCoherentShare` — (C1') local coherence across the branching
- `SharingWitnessFamily.ThreadFulfilling` — (C2') every thread discharges its eventualities

## Main Results

- `SharingWitnessFamily.localCoherentLab_of_share` — (C1') implies the deterministic (C1)
- `SharingWitnessFamily.fulfillingLab_of_thread` — (C2') implies the deterministic (C2)
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

namespace SharingWitnessFamily

variable {Γ Del : Context}

/--
**(C0) Atom coherence.** Indices naming the same state at a time carry the same atoms.

Mandatory, and new: the branching model's valuation is a `Quotient.lift` over `share`-classes,
so without this it is not well defined. See this module's header for why the deterministic
device could leave atoms unconstrained.
-/
def AtomCoherent (S : SharingWitnessFamily Γ Del) : Prop :=
  ∀ (u : ℤ) (i j : Fin S.lassos.length), S.share u i j →
    ∀ p : Atom, (Formula.atom p ∈ S.L i u ↔ Formula.atom p ∈ S.L j u)

/--
**(C1') Local coherence across the branching.**

`WitnessFamily.LocalCoherentLab` with the two temporal clauses taken across the **succession**
relation: the `untl` unfolding against every index the position succeeds to, the `snce` unfolding
against every index the position is succeeded from. The `bot`, `imp` and `box` clauses are
one-position conditions and are unchanged.

Quantifying over `trans` rather than over `share` is the repair this module's redesign exists
for. Under the old reading the `snce` clause ranged over the share-class at the label's *own*
time `t`, which forced any two indices naming one world state to agree on every `snce` formula of
the closure — the congruence `snce_share_congr` recorded, and the reason no six-condition family
could certify an instance of `g S e → ⊡(g S e)`. Succession is a genuinely finer relation than
state-identity at a time, so the two clauses are now symmetric: `untl` reads succession *out of*
`t`, `snce` reads succession *into* `t`.
-/
def LocalCoherentShare (S : SharingWitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin S.lassos.length) (t : ℤ),
    (Formula.bot ∉ S.L i t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ closureOf (Γ ++ Del) →
        (Formula.imp a b ∈ S.L i t ↔ (a ∈ S.L i t → b ∈ S.L i t))) ∧
    (∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) →
        (Formula.box χ ∈ S.L i t ↔ S.bx χ = true)) ∧
    (∀ j : Fin S.lassos.length, S.trans t i j →
      ∀ g e : Formula, Formula.untl g e ∈ closureOf (Γ ++ Del) →
        (Formula.untl g e ∈ S.L i t ↔
          (e ∈ S.L j (t + 1) ∨ (g ∈ S.L j (t + 1) ∧ Formula.untl g e ∈ S.L j (t + 1))))) ∧
    (∀ k : Fin S.lassos.length, S.trans (t - 1) k i →
      ∀ g e : Formula, Formula.snce g e ∈ closureOf (Γ ++ Del) →
        (Formula.snce g e ∈ S.L i t ↔
          (e ∈ S.L k (t - 1) ∨ (g ∈ S.L k (t - 1) ∧ Formula.snce g e ∈ S.L k (t - 1)))))

/--
**(C1') implies (C1).** Instantiating the successor and predecessor quantifiers at the index
itself — legitimate because `trans` is reflexive, `trans_refl'` being the arrival-pruned
consequence of the skeleton's `trans_refl` field — recovers the deterministic condition on the
underlying family verbatim.

This is the sense in which the branching condition is a strengthening rather than a replacement,
and it is what lets the specialization in `Sharing/Specialize.lean` run in both directions.
-/
theorem localCoherentLab_of_share {S : SharingWitnessFamily Γ Del}
    (h : S.LocalCoherentShare) : S.toWitnessFamily.LocalCoherentLab := by
  intro i t
  obtain ⟨hbot, himp, hbox, huntl, hsnce⟩ := h i t
  exact ⟨hbot, himp, hbox, huntl i (S.trans_refl' t i), hsnce i (S.trans_refl' (t - 1) i)⟩

/-- The deterministic `untl` clause, as the reflexive instance of the branching one. -/
theorem untl_self_of_share {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (i : Fin S.lassos.length) (t : ℤ) (g e : Formula)
    (hc : Formula.untl g e ∈ closureOf (Γ ++ Del)) :
    Formula.untl g e ∈ S.L i t ↔
      (e ∈ S.L i (t + 1) ∨ (g ∈ S.L i (t + 1) ∧ Formula.untl g e ∈ S.L i (t + 1))) :=
  (h i t).2.2.2.1 i (S.trans_refl' t i) g e hc

/-- The deterministic `snce` clause, as the reflexive instance of the branching one. -/
theorem snce_self_of_share {S : SharingWitnessFamily Γ Del} (h : S.LocalCoherentShare)
    (i : Fin S.lassos.length) (t : ℤ) (g e : Formula)
    (hc : Formula.snce g e ∈ closureOf (Γ ++ Del)) :
    Formula.snce g e ∈ S.L i t ↔
      (e ∈ S.L i (t - 1) ∨ (g ∈ S.L i (t - 1) ∧ Formula.snce g e ∈ S.L i (t - 1))) :=
  (h i t).2.2.2.2 i (S.trans_refl' (t - 1) i) g e hc

/--
**(C2') Thread fulfilment.**

`WitnessFamily.FulfillingLab` with the per-lasso quantifier replaced by a quantifier over
**every thread** through the position: an eventuality labelled at `(i, u)` must be discharged
along every history that passes through that state, not merely along the lasso it is written
on. This is `A[g U e]` (resp. its past mirror) at the position, and it is one of the two
conditions that genuinely break under recombination.

Stated over all `g` and `e` rather than over closure members only, exactly as `FulfillingLab`
is: labels are subsets of the closure anyway (`WitnessFamily.subset_closureOf`), so the extra
generality costs nothing and saves a side condition at every use site.
-/
def ThreadFulfilling (S : SharingWitnessFamily Γ Del) : Prop :=
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : Formula), Formula.untl g e ∈ S.L i u →
      ∀ θ : S.Thread, θ.idx u = i →
        ∃ s : ℤ, u < s ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, u < r → r < s → g ∈ S.L (θ.idx r) r) ∧
  (∀ (i : Fin S.lassos.length) (u : ℤ) (g e : Formula), Formula.snce g e ∈ S.L i u →
      ∀ θ : S.Thread, θ.idx u = i →
        ∃ s : ℤ, s < u ∧ e ∈ S.L (θ.idx s) s ∧
          ∀ r : ℤ, s < r → r < u → g ∈ S.L (θ.idx r) r)

/--
**(C2') implies (C2).** Instantiating the thread quantifier at the constant thread — legitimate
because staying on one lasso is always a thread — recovers the deterministic condition on the
underlying family verbatim.

As with `localCoherentLab_of_share`, this is what makes the branching condition a strengthening
rather than a replacement, and it is the direction the specialization consumes. The converse is
false, and that is the point of the branching device.
-/
theorem fulfillingLab_of_thread {S : SharingWitnessFamily Γ Del}
    (h : S.ThreadFulfilling) : S.toWitnessFamily.FulfillingLab := by
  refine ⟨fun i t g e hmem => ?_, fun i t g e hmem => ?_⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.1 i t g e hmem (Thread.const S i) rfl
    exact ⟨s, hs, hes, hgs⟩
  · obtain ⟨s, hs, hes, hgs⟩ := h.2 i t g e hmem (Thread.const S i) rfl
    exact ⟨s, hs, hes, hgs⟩

end SharingWitnessFamily

end FormalSystem.Metalogic.Decidability
