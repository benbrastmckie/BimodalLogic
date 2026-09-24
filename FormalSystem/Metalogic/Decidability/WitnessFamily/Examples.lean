/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.WitnessFamily.Agreement
import FormalSystem.Metalogic.Decidability.WitnessFamily.Decide
import FormalSystem.Metalogic.Soundness

/-!
# Non-Vacuity and Impossibility for Witness Families

`LocalCoherentLab`, `FulfillingLab` and `BoxFaithful` are `Prop`-valued conjunctions of
conditional clauses, so they can be accidentally vacuous in two opposite ways, both as fatal as a
`sorry`:

1. **Nothing satisfies them**, so every theorem taking them as hypotheses is empty.
2. **Everything satisfies them** — in particular `LocalCoherentLab` might silently imply
   `FulfillingLab`, collapsing the greatest-fixpoint / least-fixpoint distinction the whole
   design exists to make.

This module rules out both, and then proves the matching impossibility result.

- `posFamily` satisfies all three predicates and has a `Target`, so none of them is empty.
- `sepFamily` satisfies `LocalCoherentLab` but **not** `FulfillingLab`, so fulfilment carries
  real content.
- `no_witnessFamily_of_validZTime` and its instance `no_witnessFamily_of_MF` say no certificate
  can target a ℤ-time validity — the soundness of the certificate format, read contrapositively.

## The positive witness presents a model no finite presentation has

`posFamily` certifies the satisfiability of `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`, with `p` labelled at
the origin and nowhere else. That is the point of the example rather than an arbitrary choice:
`□(p → ¬Pp)` forces `p` to occur at most once along each history, while `□(p ∨ Fp ∨ Pp)` forces
it to occur at least once — and the resulting three-region label pattern (`Fp` to the left of the
origin, `p` at it, `Pp` to its right) is exactly what a bare periodic window cannot express and a
three-segment labelled lasso can.

The three labels are forced, clause by clause, by `LocalCoherentLab` together with the intended
reading; the `#guard`s below check that reading mechanically rather than trusting the derivation.
`Formula.top` appears in every label because the `imp` clause forces `⊥ → ⊥` in wherever `⊥` is
out, and `⊥` is out everywhere.

## The separation witness

`sepFamily` carries `p U q` at every position of a family in which `q` is labelled nowhere. Every
local clause is satisfied by passing the obligation forward one more step; the obligation is
never discharged. A checker that tested only local coherence would accept it and be wrong.

## What replaces the dispatched exhaustive `#guard`

The original brief asked for a `#guard` that no witness family with all segment lengths `≤ 2`
exists for the negation of MF. That enumeration is infeasible by about twelve orders of
magnitude: the closure has 10 members, so a single lasso admits up to `1024⁶ ≈ 1.2 · 10¹⁸` label
assignments. `no_witnessFamily_of_MF` proves the stronger statement — **no** witness family at
**any** segment lengths targets MF — at no enumeration cost, and `sepFamily` supplies the genuine
predicate separation the exhaustive guard was also reaching for.

## Main Results

- `posFamily_localCoherent`, `posFamily_fulfilling`, `posFamily_boxFaithful`, `posFamily_target`
- `sepFamily_localCoherent`, `sepFamily_not_fulfilling`
- `no_witnessFamily_of_validZTime` — **T3**, the impossibility theorem
- `no_witnessFamily_of_MF` — **T3** at the bimodal axiom MF
-/

namespace FormalSystem.Metalogic.Decidability

open FormalSystem.Syntax FormalSystem.Semantics

namespace WitnessFamilyExamples

/-! ## The alphabet -/

/-- The atom that holds exactly at the origin. -/
def pA : Atom := Atom.mkBase "p"

/-- The atom that holds nowhere — the event the separation witness never delivers. -/
def qA : Atom := Atom.mkBase "q"

/-- `p`, as a formula. -/
def pF : Formula := Formula.atom pA

/-- `q`, as a formula. -/
def qF : Formula := Formula.atom qA

/-! ## The positive witness

`Fp` and `Pp` abbreviate `someFuture p` and `somePast p`, both of which unfold to a temporal
operator with guard `⊤` — which is why `Formula.top` is in every label below.
-/

/-- `Fp`, the future occurrence of `p`. -/
def fP : Formula := pF.someFuture

/-- `Pp`, the past occurrence of `p`. -/
def pP : Formula := pF.somePast

/-- `p ∨ Fp ∨ Pp`: `p` occurs somewhere on the history. -/
def occurs : Formula := Formula.or pF (Formula.or fP pP)

/-- `p → ¬Pp`: `p` does not recur. -/
def once : Formula := pF.imp pP.neg

/-- `□(p ∨ Fp ∨ Pp) ∧ □(p → ¬Pp)`: `p` occurs exactly once along every history. -/
def phiPos : Formula := Formula.and occurs.box once.box

/-- The premise context of the positive certificate: the formula whose satisfiability it
witnesses. -/
def gammaPos : Context := [phiPos]

/-- The conclusion context of the positive certificate is empty: it refutes `Γ ⊨ σ` for no `σ`,
and instead exhibits a model of `Γ`. -/
def delPos : Context := []

/-- The label strictly left of the origin: `p` is still to come. -/
def labBack : Finset Formula :=
  {Formula.top, pF.neg, fP, Formula.or fP pP, pP.neg, occurs, occurs.box, once, once.box, phiPos}

/-- The label at the origin: `p` holds, and has neither happened before nor will again. -/
def labMid : Finset Formula :=
  {pF, Formula.top, fP.neg, pP.neg, occurs, occurs.box, once, once.box, phiPos}

/-- The label strictly right of the origin: `p` has happened. -/
def labFwd : Finset Formula :=
  {Formula.top, pF.neg, pP, fP.neg, Formula.or fP pP, occurs, occurs.box, once, once.box, phiPos}

/-- The positive witness's single lasso: one label leftward, one at the origin, one rightward. -/
def posLasso : LabelledLasso (closureOf (gammaPos ++ delPos)) where
  back := [labBack]
  mid := [labMid]
  fwd := [labFwd]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by decide

/-- **The positive witness.** The box guess reports `true` exactly at the two boxed formulas of
the closure, which are labelled at every position. -/
def posFamily : WitnessFamily gammaPos delPos where
  bx := fun ψ => (ψ == occurs) || (ψ == once)
  lassos := [posLasso]
  lassos_ne := by simp

/-! ## The separation witness

`p U q` — guard `p`, event `q` — carried at every position of a family on which `q` is labelled
nowhere. Both cycles carry the same label and the window is empty, so the decoded label is
constant in time and the argument is checkable by inspection.
-/

/-- `p U q`: guard `p`, event `q`. -/
def phiSep : Formula := Formula.untl pF qF

/-- The premise context of the separation witness. -/
def gammaSep : Context := [phiSep]

/-- The conclusion context of the separation witness. -/
def delSep : Context := []

/-- The constant label of the separation witness. Note it does **not** contain `q`. -/
def labSep : Finset Formula := {pF, phiSep}

/-- The separation witness's single lasso, constant in time. -/
def sepLasso : LabelledLasso (closureOf (gammaSep ++ delSep)) where
  back := [labSep]
  mid := []
  fwd := [labSep]
  back_ne := by simp
  fwd_ne := by simp
  label_sub := by decide

/-- **The separation witness**: locally coherent, not fulfilling. -/
def sepFamily : WitnessFamily gammaSep delSep where
  bx := fun _ => false
  lassos := [sepLasso]
  lassos_ne := by simp

/-! ## The instances compute, and they discriminate

Each `#guard` below names its `Decidable` instance explicitly rather than letting synthesis pick
one, so these lines are evidence about **those** instances: that they run, and that they return
different answers on the two witnesses.
-/

section SmokeTests

-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard @Decidable.decide _ (WitnessFamily.decidableLocalCoherentLab posFamily)
-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard @Decidable.decide _ (WitnessFamily.decidableFulfillingLab posFamily)
-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard @Decidable.decide _ (WitnessFamily.decidableBoxFaithful posFamily)
-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard @Decidable.decide _ (WitnessFamily.decidableTarget posFamily 0)

-- The separation witness: locally coherent, **not** fulfilling. The second line is the one that
-- would fail if the fulfilment window were ever weakened into a purely local check.
-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard @Decidable.decide _ (WitnessFamily.decidableLocalCoherentLab sepFamily)
-- linter.hashCommand: this `#guard` runs the compiled `Decidable` instance, which is the point
-- (a kernel proof would not show the instance computes); it emits nothing when it passes.
set_option linter.hashCommand false in
#guard !(@Decidable.decide _ (WitnessFamily.decidableFulfillingLab sepFamily))

end SmokeTests

/-! ## The witnesses, as theorems -/

/-- The positive witness is locally coherent. -/
theorem posFamily_localCoherent : posFamily.LocalCoherentLab := by decide

/-- The positive witness is fulfilling: the eventuality `Fp` is discharged at the origin from the
left, and `Pp` from the right. -/
theorem posFamily_fulfilling : posFamily.FulfillingLab := by decide

/-- The positive witness's box guess is faithful. -/
theorem posFamily_boxFaithful : posFamily.BoxFaithful := by decide

/-- The positive witness targets the origin, so `phiPos` is true there in the presented model. -/
theorem posFamily_target : posFamily.Target 0 := by decide

/-- The separation witness is locally coherent. -/
theorem sepFamily_localCoherent : sepFamily.LocalCoherentLab := by decide

/-- **The separation witness is not fulfilling** — so `FulfillingLab` is not implied by
`LocalCoherentLab`, and the distinction between the greatest and the least fixpoint is real. -/
theorem sepFamily_not_fulfilling : ¬ sepFamily.FulfillingLab := by decide

/-- **Non-vacuity, assembled**: the positive witness presents a ℤ-time model of `phiPos`. -/
theorem phiPos_satisfiable :
    ∃ (F : TaskFrame) (_ : FormalSystem.ProofSystem.FrameClass.ZTime.Sat F) (M : TaskModel F)
      (τ : WorldHistory F) (u : F.Duration),
      (∀ γ ∈ gammaPos, TruthAt M τ u γ) ∧ (∀ σ ∈ delPos, ¬ TruthAt M τ u σ) :=
  posFamily.joint_countermodel posFamily_localCoherent posFamily_fulfilling
    posFamily_boxFaithful posFamily_target

end WitnessFamilyExamples

namespace WitnessFamily

variable {Γ Del : Context}

/--
**T3, impossibility**: no witness family can target a ℤ-time validity.

A corollary of T1', with no new mathematics: the certificate hands over an explicit ℤ-time model
at which the conclusion is false, and a validity is true in every such model.
-/
theorem no_witnessFamily_of_validZTime {σ : Formula} (hσ : σ ∈ Del) (hvalid : ValidZTime σ)
    (W : WitnessFamily Γ Del) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) : False := by
  obtain ⟨F, hF, M, τ, u, _, hcon⟩ := W.joint_countermodel hloc hful hbox htgt
  exact hcon σ hσ (hvalid F hF M τ u)

/--
**T3 at the bimodal axiom MF**: no witness family refutes `□φ → □Gφ`.

This is what the dispatched exhaustive `#guard` was reaching for, proved rather than enumerated,
and at every segment length rather than at lengths `≤ 2`. See this module's header for the
feasibility arithmetic that ruled the enumeration out.
-/
theorem no_witnessFamily_of_MF (φ : Formula)
    (W : WitnessFamily [] [(φ.box).imp ((φ.allFuture).box)]) {t : ℤ}
    (hloc : W.LocalCoherentLab) (hful : W.FulfillingLab) (hbox : W.BoxFaithful)
    (htgt : W.Target t) : False :=
  no_witnessFamily_of_validZTime (by simp)
    (Validity.valid_implies_valid_ztime (modal_future_valid φ)) W hloc hful hbox htgt

end WitnessFamily

end FormalSystem.Metalogic.Decidability
