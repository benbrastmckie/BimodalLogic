/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Basic

/-!
# The Certificate Predicates

Three conditions turn a `WitnessFamily` from an arbitrary pile of labels into a machine-checkable
refutation: local coherence, fulfilment and box faithfulness. A fourth, `Target`, says which
consequence is being refuted and at which time.

## The clause-by-clause correspondence with `BiLasso/Annotation.lean`

`LocalCoherentLab` is `BiLasso.LocalCoherent` with **exactly two clause families dropped**:

| `LocalCoherent` clause | here | why |
|---|---|---|
| the `atom` clause, against `P.val` | **dropped** | no presentation; see below |
| `bot ∉ label t` | kept, unconditional | `⊥` may never be labelled, in or out of the closure |
| `imp a b ∈ label t ↔ (a ∈ … → b ∈ …)` | kept verbatim | |
| `box χ ∈ label t ↔ bx χ` | kept verbatim | |
| `untl g e` one-step unfolding at `t + 1` | kept verbatim | |
| `snce g e` one-step unfolding at `t - 1` | kept verbatim | |

Nothing else changes: the closure guard becomes `closureOf (Γ ++ Del)` in place of
`subformulaClosure φ`, and the position index gains a lasso coordinate.

**Atoms are deliberately unconstrained.** That is not an omission — it is what makes the
agreement theorem's `atom` case `Iff.rfl` rather than an appeal to a valuation clause.

`FulfillingLab` is `BiLasso.Fulfilling` verbatim on the decoded label function, per lasso. As
there, it is stated over **all** `g` and `e` rather than over closure members only: labels are
subsets of the closure anyway (`WitnessFamily.L_subset`), so the extra generality costs nothing
and saves a closure side condition at every use site. It is also the clause that selects the
*least* fixpoint: `LocalCoherentLab`'s temporal clauses alone are satisfied by an eventuality
passed forward forever with the event never delivered.

`BoxFaithful` is the new one, and it is what replaces `BiLasso.BoxOracleSound`. There, soundness
of the oracle was a statement about *all* world histories of a presented frame and needed the
small-model theorem to discharge. Here the presented model's histories are exactly the family's
lassos and their shifts, so the same content is a statement about the family itself — which is
why the box case of agreement is three lines rather than a separate development.

## Main Definitions

- `WitnessFamily.LocalCoherentLab` — the Hintikka conditions on labels
- `WitnessFamily.FulfillingLab` — every eventuality is discharged
- `WitnessFamily.BoxFaithful` — the box guess is exactly global label membership
- `WitnessFamily.Target` — the time at which the consequence fails
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax

namespace WitnessFamily

variable {Γ Del : Context}

/--
**Local coherence on labels.**

The `BiLasso.LocalCoherent` clauses minus the atom and presentation clauses; see this module's
header for the clause-by-clause correspondence. Every clause is a biconditional, which is what
makes a label negation-complete over the closure with no maximal-consistent-set machinery.
-/
def LocalCoherentLab (W : WitnessFamily Γ Del) : Prop :=
  ∀ (i : Fin W.lassos.length) (t : ℤ),
    (Formula.bot ∉ W.L i t) ∧
    (∀ a b : Formula, Formula.imp a b ∈ closureOf (Γ ++ Del) →
        (Formula.imp a b ∈ W.L i t ↔ (a ∈ W.L i t → b ∈ W.L i t))) ∧
    (∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) →
        (Formula.box χ ∈ W.L i t ↔ W.bx χ = true)) ∧
    (∀ g e : Formula, Formula.untl g e ∈ closureOf (Γ ++ Del) →
        (Formula.untl g e ∈ W.L i t ↔
          (e ∈ W.L i (t + 1) ∨ (g ∈ W.L i (t + 1) ∧ Formula.untl g e ∈ W.L i (t + 1))))) ∧
    (∀ g e : Formula, Formula.snce g e ∈ closureOf (Γ ++ Del) →
        (Formula.snce g e ∈ W.L i t ↔
          (e ∈ W.L i (t - 1) ∨ (g ∈ W.L i (t - 1) ∧ Formula.snce g e ∈ W.L i (t - 1)))))

/--
**Fulfilment**: every eventuality carried by a label is actually discharged.

`BiLasso.Fulfilling` verbatim on the decoded label function, per lasso. The gap between this and
`LocalCoherentLab`'s temporal clauses is the gap between "locally consistent" and "describes a
genuine model"; `Examples.lean` exhibits a locally coherent family that fails it.
-/
def FulfillingLab (W : WitnessFamily Γ Del) : Prop :=
  (∀ (i : Fin W.lassos.length) (t : ℤ) (g e : Formula), Formula.untl g e ∈ W.L i t →
      ∃ s : ℤ, t < s ∧ e ∈ W.L i s ∧ ∀ r : ℤ, t < r → r < s → g ∈ W.L i r) ∧
  (∀ (i : Fin W.lassos.length) (t : ℤ) (g e : Formula), Formula.snce g e ∈ W.L i t →
      ∃ s : ℤ, s < t ∧ e ∈ W.L i s ∧ ∀ r : ℤ, s < r → r < t → g ∈ W.L i r)

/--
**Box faithfulness**: the box guess is exactly global label membership.

For every `□χ` in the target closure, `bx χ` is `true` precisely when `χ` is labelled at every
position of every lasso. This is what makes `bx` a sound oracle for the presented model, because
that model's world histories are exactly the family's lassos and their shifts.
-/
def BoxFaithful (W : WitnessFamily Γ Del) : Prop :=
  ∀ χ : Formula, Formula.box χ ∈ closureOf (Γ ++ Del) →
    (W.bx χ = true ↔ ∀ (i : Fin W.lassos.length) (t : ℤ), χ ∈ W.L i t)

/--
**The target**: a time on the main lasso at which every premise is labelled and no conclusion is.

Read on lasso `0` only. The other lassos exist to witness the box clause, not the consequence.
-/
def Target (W : WitnessFamily Γ Del) (t : ℤ) : Prop :=
  (∀ γ ∈ Γ, γ ∈ W.main t) ∧ (∀ σ ∈ Del, σ ∉ W.main t)

/-- Every premise lies in the target closure, so agreement applies to it. -/
theorem premise_mem_closure {γ : Formula} (hγ : γ ∈ Γ) : γ ∈ closureOf (Γ ++ Del) :=
  self_mem_closureOf (List.mem_append_left _ hγ)

/-- Every conclusion lies in the target closure, so agreement applies to it. -/
theorem conclusion_mem_closure {σ : Formula} (hσ : σ ∈ Del) : σ ∈ closureOf (Γ ++ Del) :=
  self_mem_closureOf (List.mem_append_right _ hσ)

end WitnessFamily

end FormalSystem.Metalogic.Decidability
