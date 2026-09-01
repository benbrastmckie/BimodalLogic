/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Transfer
import FormalSystem.Metalogic.WeakCanonical.Table
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import FormalSystem.Metalogic.Bundle.TemporalCoherence
import FormalSystem.Metalogic.WeakCanonical.PriorDefsDense
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful
import FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleToCountermodelBasic
import FormalSystem.Metalogic.Algebraic.FlowFrame

/-!
# The Dense Monadic Bridge: Chronicle to `OrderedMonadicStructure` over `ℚ`

This module turns the landed rational chronicle (`cantorBfmcsDense`) into a temporal
structure in a **finite monadic language** over a countable, dense, endpointless flow.

## Source grounding

The *statement* of what this delivers is Reynolds' completeness proof, §9. The relevant
passage is quoted here character-for-character from the local corpus
(`reynolds_1992/sec07_9-completeness.md`, "## 9 Completeness"; the plan records this as
printed p.189):

> First use Burgess--Xu Corollary 1 to furnish us with a structure `M₀` such that
>
> 1. the flow of time of `M₀` is the rationals,
> 2. `M₀ ⊨ A₀(0)` and
> 3. all substitution instances of the axioms Prior-U, Prior-S and Sep are valid in `M₀`.
>
> By ignoring all the atoms which don't appear in `A₀` we have a temporal structure `M`
> from a finite language. `M` is still a model of `A₀`.
>
> The flow of time of `M` is countable, dense and without end points and D1 and D2 follow
> from the theorems 4 and 5.

This module is Reynolds' **step 2** ("by ignoring all the atoms which don't appear in `A₀`
we have a temporal structure `M` from a finite language") applied to this repository's
realization of his step 1. `cantorBfmcsDense` is this repository's Burgess--Xu structure
`M₀`: a bundle of MCS families indexed by `ℚ`. The "finite language" is `mkSigFrom root`,
whose predicate symbols are exactly `Formula.bot` together with the atoms and
box-subformulas occurring in `root` — a `Finset`, hence finite, and the "ignoring" is
effected by *choosing that signature* rather than by deleting anything.

**Honesty charter Rule 4 — the construction below has NO source in the corpus.**
Reynolds states the shape of step 2 in one sentence and does not construct it. The
definitions `chronicleMonadicStructureOf`/`chronicleMonadicStructure`, the truth
correspondence `chronicleMonadic_truth_correspondence`, the `predFormulas` containment
lemmas, and the generic multi-family frame are all original work and are attributed to no
one. Only the sentence quoted above is Reynolds'.

**ADAPTED-FROM**: `FormalSystem/Metalogic/WeakCanonical/IntegerModel/ReynoldsBridge.lean`.
The bimodal dimension is encoded here exactly as `ReynoldsBridge.lean` already encodes it
at `.Discrete`: `Formula.box ψ` is a *predicate symbol* of the monadic signature (it is in
`predFormulas`), so `TemporalTruth` reads box as an opaque unary predicate lookup rather
than as a quantification. The modal content is carried by the chronicle's `BFMCS` modal
coherence, not by the monadic language.

## The R7 gate (recorded answer)

Phase 15's first task is a gate: are `mkSigFrom`, `Formula.predFormulas`,
`multiFamTaskFrame` and its total-history set independent of
`SuccOrder`/`PredOrder`/`IsSuccArchimedean`, or is discreteness baked into the encoding?

**Answer: they are independent. Discreteness is baked only into
`countermodel_discrete_reynolds_v2`'s statement, not into the encoding.** Evidence:

* `ParamTaskFrame` (`Semantics/TaskFrame.lean:99`) is parameterized by
  `(D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]` and by nothing
  else. `WorldHistory` and `WorldHistory.timeShift` carry the same three
  instances and no successor structure.
* `Formula.predFormulas` (`Syntax/Formula.lean`) is a purely syntactic recursion on
  `Formula` with no temporal parameter at all, and `mkSigFrom φ`
  (`WeakCanonical/Transfer.lean:134`) is `Finset.cons Formula.bot φ.predFormulas _`. No
  order structure occurs in either.
* `multiFamTaskFrame FamIdx : ParamTaskFrame ℤ` (`ReynoldsBridge.lean:671`) has
  `WorldState := FamIdx × ℤ` and `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, in which
  `ℤ` occurs only as the carrier and `+` only as its group operation; likewise
  `multiFamHistory` and the totality characterization `multiFam_total_eq_range`.

The generic re-statements (`multiFamTaskFrameGen` and siblings, hosted in
`Metalogic/Algebraic/FlowFrame.lean`) *discharge* the gate
rather than merely asserting it: they typecheck over an arbitrary
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D] [Nontrivial D]`, and the `ℤ` originals are
recovered as definitional specializations (`multiFamTaskFrameGen_int` and siblings). The
`ℤ` originals are left byte-identical; `countermodel_discrete_reynolds_v2` still consumes
them. Phase 30 consumes the generic versions at `D := ℝ`.

## Note for the record

`mkSigFrom` lives in `WeakCanonical/Transfer.lean`, which carries this repository's single
live `sorry` at `:1242` in an **unrelated** declaration. Importing it is normal and already
universal in this tree. `Transfer.lean:1242` is not attempted here.

## Main results

* `multiFamTaskFrameGen_int` / `multiFamHistoryGen_int` / `multiFamGen_total_int` — the `ℤ`
  originals certified as definitional specializations of the discreteness-free multi-family
  frame (now hosted in `Metalogic/Algebraic/FlowFrame.lean`).
* `chronicleMonadicStructureOf` — a chronicle family as an `OrderedMonadicStructure` over
  the finite signature `mkSigFrom root`, with carrier `ℚ`.
* `chronicleMonadic_truth_correspondence` — for every `φ ∈ subformulaClosure root`,
  `TemporalTruth` on the structure agrees with membership in the family's MCS. This is the
  bridge's whole content and the only thing later phases consume.
* `chronicleMonadic_carrier_countable` / `_denselyOrdered` / `_noMaxOrder` / `_noMinOrder`
  — Reynolds' "countable, dense and without end points", immediate at `ℚ`.
-/

namespace FormalSystem.Metalogic.BXCanonical.Chronicle

open FormalSystem.Syntax
open FormalSystem.ProofSystem
open FormalSystem.Metalogic.Core
open FormalSystem.Metalogic.Bundle
open FormalSystem.Metalogic.WeakCanonical
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## Part 1: The discreteness-free multi-family frame (R7 gate discharge)

The generic re-statements of `ReynoldsBridge.lean`'s `multiFamTaskFrame`/`multiFamHistory`
family over an arbitrary ordered abelian group `D` —
`multiFamTaskFrameGen`/`multiFamHistoryGen` — are now hosted in
`Metalogic/Algebraic/FlowFrame.lean` (imported above), together with their four-axiom
conformance layer and totality characterization. The `ℤ` originals are untouched:
`countermodel_discrete_reynolds_v2` continues to consume the originals, and the `_int` lemmas
below certify that the originals are the definitional `D := ℤ` specializations of the generic
ones.
-/

section MultiFamGen

/-! ### The `ℤ` originals are the definitional specializations

These three `rfl` proofs are the substance of the R7 gate answer: the landed `ℤ`
definitions consumed by `countermodel_discrete_reynolds_v2` are *definitionally* the
`D := ℤ` instances of the generic ones, so nothing discrete was ever baked into them. -/

/-- `multiFamTaskFrame` is definitionally `multiFamTaskFrameGen ℤ`. -/
theorem multiFamTaskFrameGen_int (FamIdx : Type) [Nonempty FamIdx] :
    multiFamTaskFrameGen intOrder FamIdx = multiFamTaskFrame FamIdx := rfl

/-- `multiFamHistory` is definitionally `multiFamHistoryGen` at `D := ℤ`. -/
theorem multiFamHistoryGen_int {FamIdx : Type} [Nonempty FamIdx] (f : FamIdx) (w₀ : ℤ) :
    multiFamHistoryGen f w₀ = multiFamHistory f w₀ := rfl

/-- The `ℤ` frame's total-history set `H_F` (`def:world-history`) is definitionally the
generic frame's at `D := ℤ`. -/
theorem multiFamGen_total_int (FamIdx : Type) [Nonempty FamIdx] :
    {σ : WorldHistory (multiFamTaskFrameGen intOrder FamIdx) | ∀ t, σ.domain t} =
      {σ : WorldHistory (multiFamTaskFrame FamIdx) | ∀ t, σ.domain t} := rfl

end MultiFamGen

/-! ## Part 2: Syntactic containment — closure subformulas that are predicate symbols

`TemporalTruth` reads atoms and box-formulas through `atomMap`. For the truth
correspondence to hold at those leaves, the atom map must be the *identity* there, which
`mkAtomMapFwd_on_predFormulas` supplies exactly on `root.predFormulas`. These two lemmas
are the missing link: every atom and every box-formula occurring in `subformulaClosure
root` is in `root.predFormulas`.

No source: routine syntax, original work. -/

/-- Every atom occurring among the subformulas of `root` is a predicate symbol of
`mkSigFrom root`. -/
theorem atom_mem_predFormulas_of_mem_subformulas (a : Atom) (root : Formula)
    (h : Formula.atom a ∈ root.subformulas) : Formula.atom a ∈ root.predFormulas := by
  induction root with
  | atom b =>
    simp only [Formula.subformulas, List.mem_cons, List.not_mem_nil, or_false,
      Formula.atom.injEq] at h
    subst h
    simp [Formula.predFormulas]
  | bot => simp [Formula.subformulas] at h
  | imp ψ χ ihψ ihχ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihψ h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)
  | box χ ihχ =>
    simp only [Formula.subformulas, List.mem_cons] at h
    rcases h with h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)
  | untl χ ψ ihχ ihψ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihψ h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)
  | snce χ ψ ihχ ihψ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihψ h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)

/-- Every box-formula occurring among the subformulas of `root` is a predicate symbol of
`mkSigFrom root`. This is what makes the bimodal dimension an opaque predicate lookup, as
`ReynoldsBridge.lean` already has it at `.Discrete`. -/
theorem box_mem_predFormulas_of_mem_subformulas (ψ root : Formula)
    (h : Formula.box ψ ∈ root.subformulas) : Formula.box ψ ∈ root.predFormulas := by
  induction root with
  | atom b => simp [Formula.subformulas] at h
  | bot => simp [Formula.subformulas] at h
  | imp α β ihα ihβ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihα h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihβ h)
  | box χ ihχ =>
    simp only [Formula.subformulas, List.mem_cons, Formula.box.injEq] at h
    rcases h with h | h
    · subst h; simp [Formula.predFormulas]
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)
  | untl β α ihβ ihα =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihα h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihβ h)
  | snce β α ihβ ihα =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihα h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihβ h)

/-- Closure form of `atom_mem_predFormulas_of_mem_subformulas`. -/
theorem atom_mem_predFormulas_of_mem_closure (a : Atom) (root : Formula)
    (h : Formula.atom a ∈ subformulaClosure root) : Formula.atom a ∈ root.predFormulas :=
  atom_mem_predFormulas_of_mem_subformulas a root (List.mem_toFinset.mp h)

/-- Closure form of `box_mem_predFormulas_of_mem_subformulas`. -/
theorem box_mem_predFormulas_of_mem_closure (ψ root : Formula)
    (h : Formula.box ψ ∈ subformulaClosure root) : Formula.box ψ ∈ root.predFormulas :=
  box_mem_predFormulas_of_mem_subformulas ψ root (List.mem_toFinset.mp h)

/-! ## Part 3: The chronicle as an ordered monadic structure over `ℚ`

Reynolds' step 2. The carrier is `ℚ` — the flow of time of the Burgess--Xu structure — and
each predicate symbol `p` of the finite signature `mkSigFrom root` is interpreted at a
rational `q` as membership of the underlying formula `p.val` in the family's MCS at `q`.

No source: original work (see the module docstring). -/

/--
A chronicle family, read as an `OrderedMonadicStructure` over the finite signature
`mkSigFrom root`.

The carrier is `ℚ` and `interp p q` is `p.val ∈ fam.mcs q`. Every predicate symbol of
`mkSigFrom root` is either `Formula.bot` or an atom or a box-subformula of `root`
(`Formula.predFormulas`), so this interpretation says: *the predicate holds at `q` exactly
when the formula naming it is in the chronicle's MCS at `q`*.

This realizes Reynolds' "by ignoring all the atoms which don't appear in `A₀` we have a
temporal structure `M` from a finite language" (§9): the ignoring is effected by the choice
of signature, and `M`'s carrier is `M₀`'s.
-/
noncomputable def chronicleMonadicStructureOf {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) : OrderedMonadicStructure (mkSigFrom root) where
  carrier := Rat
  interp := fun p q => p.val ∈ fam.mcs q
  carrierOrder := inferInstance

@[simp] theorem chronicleMonadicStructureOf_carrier {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) :
    (chronicleMonadicStructureOf root fam).carrier = Rat := rfl

@[simp] theorem chronicleMonadicStructureOf_interp {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) (p : (mkSigFrom root).preds) (q : Rat) :
    (chronicleMonadicStructureOf root fam).interp p q ↔ p.val ∈ fam.mcs q := Iff.rfl

/--
The dense monadic bridge at the chronicle's distinguished evaluation family.

This is the structure Reynolds' step 2 hands to Doets' theorem: `cantorBfmcsDense`'s
`evalFamily` — the family rooted at `A` — read over the finite language `mkSigFrom root`.
The bundle's `families` set carries the modal dimension (via `BFMCS.modal_forward` /
`modal_backward`); the monadic language sees box only as an opaque predicate, exactly as
`ReynoldsBridge.lean` has it at `.Discrete`.
-/
noncomputable def chronicleMonadicStructure (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    OrderedMonadicStructure (mkSigFrom root) :=
  chronicleMonadicStructureOf root (cantorBfmcsDense fc A h_mcs h_box_dense).evalFamily

/-! ### Reynolds' "countable, dense and without end points"

*"The flow of time of `M` is countable, dense and without end points"* (§9, quoted in the
module docstring). Immediate at `ℚ`; recorded as named lemmas because Blocks F--H consume
them as hypotheses rather than re-deriving them. -/

/-- The bridge's carrier is countable. -/
theorem chronicleMonadic_carrier_countable {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) :
    Countable (chronicleMonadicStructureOf root fam).carrier :=
  inferInstanceAs (Countable Rat)

/-- The bridge's carrier is densely ordered. -/
theorem chronicleMonadic_carrier_denselyOrdered {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) :
    DenselyOrdered (chronicleMonadicStructureOf root fam).carrier :=
  inferInstanceAs (DenselyOrdered Rat)

/-- The bridge's carrier has no last point. -/
theorem chronicleMonadic_carrier_noMaxOrder {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) :
    NoMaxOrder (chronicleMonadicStructureOf root fam).carrier :=
  inferInstanceAs (NoMaxOrder Rat)

/-- The bridge's carrier has no first point. -/
theorem chronicleMonadic_carrier_noMinOrder {fc : FrameClass} (root : Formula)
    (fam : FMCS (fc := fc) Rat) :
    NoMinOrder (chronicleMonadicStructureOf root fam).carrier :=
  inferInstanceAs (NoMinOrder Rat)

/-! ## Part 4: The truth correspondence

The bridge's whole content: on `subformulaClosure root`, `TemporalTruth` over the monadic
structure agrees with membership in the chronicle's MCS.

The five cases divide as follows.

* **Atom** and **box**: `TemporalTruth` reads them through `atomMap`, and
  `mkAtomMapFwd_on_predFormulas` makes the atom map the identity on `root.predFormulas`.
  Part 2 puts every closure atom and closure box-formula there. The box case needs **no**
  inductive hypothesis — that is precisely the `.Discrete` encoding being reused: the modal
  dimension is not unfolded by the monadic language.
* **Bot**: MCS consistency.
* **Imp**: MCS implication-closure and negation-completeness, as in
  `restricted_parametric_shifted_truth_lemma`.
* **Untl**/**Snce**: the chronicle's restricted forward and backward Until/Since coherence,
  whose statements match the `TemporalTruth` clauses clause-for-clause.

No source: original work. -/

/-! ### Helper tautologies for the implication case

Classical propositional facts about `neg (ψ → χ)`. These duplicate the *private* helpers
`neg_imp_antecedent` / `neg_imp_neg_consequent` of `Algebraic/FlowFrame.lean` (originally of
the retired restricted parametric truth-lemma module), which are not exported. The proofs are
transcribed unchanged; nothing in the source file is edited or weakened. -/

/-- Classical tautology: `neg (ψ → χ) → ψ`. -/
private noncomputable def neg_imp_antecedent {fc : FrameClass} (ψ χ : Formula) :
    DerivationTree fc [] ((ψ.imp χ).neg.imp ψ) := by
  have h_efq : DerivationTree FrameClass.Base [] (ψ.neg.imp (ψ.imp χ)) :=
    FormalSystem.Theorems.Propositional.impOfNeg ψ χ
  have h_efq_ctx : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg.imp (ψ.imp χ) :=
    DerivationTree.weakening [] [ψ.neg, (ψ.imp χ).neg] _ h_efq (by intro; simp)
  have h_neg_psi : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    DerivationTree.modus_ponens _ _ _ h_efq_ctx h_neg_psi
  have h_neg_imp : [ψ.neg, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_bot : [ψ.neg, (ψ.imp χ).neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_neg_psi : [(ψ.imp χ).neg] ⊢ ψ.neg.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [(ψ.imp χ).neg] ψ.neg Formula.bot h_bot
  have h_deduct : [] ⊢ (ψ.imp χ).neg.imp ψ.neg.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [] (ψ.imp χ).neg ψ.neg.neg h_neg_neg_psi
  have h_dne : [] ⊢ ψ.neg.neg.imp ψ :=
    FormalSystem.Theorems.Propositional.doubleNegation ψ
  have h_b : [] ⊢ (ψ.neg.neg.imp ψ).imp
      (((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ)) :=
    FormalSystem.Theorems.Combinators.bCombinator
  have h_step1 : [] ⊢ ((ψ.imp χ).neg.imp ψ.neg.neg).imp ((ψ.imp χ).neg.imp ψ) :=
    DerivationTree.modus_ponens _ _ _ h_b h_dne
  have h_base : [] ⊢ (ψ.imp χ).neg.imp ψ :=
    DerivationTree.modus_ponens _ _ _ h_step1 h_deduct
  exact h_base.lift (by cases fc <;> trivial)

/-- Classical tautology: `neg (ψ → χ) → neg χ`. -/
private noncomputable def neg_imp_neg_consequent {fc : FrameClass} (ψ χ : Formula) :
    DerivationTree fc [] ((ψ.imp χ).neg.imp χ.neg) := by
  have h_prop_s : [] ⊢ χ.imp (ψ.imp χ) :=
    DerivationTree.axiom [] _ (Axiom.prop_s χ ψ) trivial
  have h_prop_s_ctx : [χ, (ψ.imp χ).neg] ⊢ χ.imp (ψ.imp χ) :=
    DerivationTree.weakening [] [χ, (ψ.imp χ).neg] _ h_prop_s (by intro; simp)
  have h_chi : [χ, (ψ.imp χ).neg] ⊢ χ := DerivationTree.assumption _ _ (by simp)
  have h_imp : [χ, (ψ.imp χ).neg] ⊢ ψ.imp χ :=
    DerivationTree.modus_ponens _ _ _ h_prop_s_ctx h_chi
  have h_neg_imp : [χ, (ψ.imp χ).neg] ⊢ (ψ.imp χ).neg :=
    DerivationTree.assumption _ _ (by simp)
  have h_bot : [χ, (ψ.imp χ).neg] ⊢ Formula.bot :=
    DerivationTree.modus_ponens _ _ _ h_neg_imp h_imp
  have h_neg_chi : [(ψ.imp χ).neg] ⊢ χ.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [(ψ.imp χ).neg] χ Formula.bot h_bot
  have h_base : [] ⊢ (ψ.imp χ).neg.imp χ.neg :=
    FormalSystem.Metalogic.Core.deductionTheorem [] (ψ.imp χ).neg χ.neg h_neg_chi
  exact h_base.lift (by cases fc <;> trivial)

/--
**Truth correspondence for the dense monadic bridge.**

For every `φ ∈ subformulaClosure root`, every family `fam` of the bundle and every rational
`q`, temporal truth of `φ` at `q` in `chronicleMonadicStructureOf root fam` holds exactly
when `φ ∈ fam.mcs q`.

This is the only thing later phases consume from Phase 15.
-/
theorem chronicleMonadic_truth_correspondence {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_fuc : B.RestrictedForwardUntilSinceCoherent root)
    (h_buc : B.RestrictedBackwardUntilSinceCoherent root)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root) (q : Rat) :
    TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) q φ ↔
      φ ∈ fam.mcs q := by
  induction φ generalizing q with
  | atom a =>
    have h_pred : Formula.atom a ∈ root.predFormulas :=
      atom_mem_predFormulas_of_mem_closure a root h_sub
    simp only [TemporalTruth, mkAtomMapFwd_on_predFormulas root (Formula.atom a) h_pred]
    exact Iff.rfl
  | bot =>
    simp only [TemporalTruth]
    constructor
    · intro h; exact h.elim
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs q).1
      have h_deriv : DerivationTree fc [Formula.bot] Formula.bot :=
        DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hpsi
        rw [hpsi]; exact h_mem) ⟨h_deriv⟩
  | imp ψ χ ihψ ihχ =>
    have h_ψ_sub : ψ ∈ subformulaClosure root := closure_imp_left root ψ χ h_sub
    have h_χ_sub : χ ∈ subformulaClosure root := closure_imp_right root ψ χ h_sub
    simp only [TemporalTruth]
    have h_mcs := fam.is_mcs q
    constructor
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs (ψ.imp χ) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : ψ ∈ fam.mcs q :=
          SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (neg_imp_antecedent ψ χ) (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : χ.neg ∈ fam.mcs q :=
          SetMaximalConsistent.closed_under_derivation h_mcs [(ψ.imp χ).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _ (neg_imp_neg_consequent ψ χ) (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_χ_mcs : χ ∈ fam.mcs q :=
          (ihχ h_χ_sub q).mp (h_truth_imp ((ihψ h_ψ_sub q).mpr h_ψ_mcs))
        exact set_consistent_not_both (fam.is_mcs q).1 χ h_χ_mcs h_neg_χ_mcs
    · intro h_imp h_ψ_true
      exact (ihχ h_χ_sub q).mpr
        (SetMaximalConsistent.implication_property h_mcs h_imp ((ihψ h_ψ_sub q).mp h_ψ_true))
  | box ψ _ih =>
    have h_pred : Formula.box ψ ∈ root.predFormulas :=
      box_mem_predFormulas_of_mem_closure ψ root h_sub
    simp only [TemporalTruth, mkAtomMapFwd_on_predFormulas root (Formula.box ψ) h_pred]
    exact Iff.rfl
  | untl β α ihβ ihα =>
    have h_α_sub : α ∈ subformulaClosure root := closure_untl_left root α β h_sub
    have h_β_sub : β ∈ subformulaClosure root := closure_untl_right root α β h_sub
    simp only [TemporalTruth]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · rintro ⟨s, h_qs, h_α_s, h_β_guard⟩
      exact h_bwd_U q α β h_sub ⟨s, h_qs, (ihα h_α_sub s).mp h_α_s,
        fun r h_qr h_rs => (ihβ h_β_sub r).mp (h_β_guard r h_qr h_rs)⟩
    · intro h_U
      obtain ⟨s, h_qs, h_α_s, h_β_guard⟩ := h_fwd_U q α β h_sub h_U
      exact ⟨s, h_qs, (ihα h_α_sub s).mpr h_α_s,
        fun r h_qr h_rs => (ihβ h_β_sub r).mpr (h_β_guard r h_qr h_rs)⟩
  | snce β α ihβ ihα =>
    have h_α_sub : α ∈ subformulaClosure root := closure_snce_left root α β h_sub
    have h_β_sub : β ∈ subformulaClosure root := closure_snce_right root α β h_sub
    simp only [TemporalTruth]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · rintro ⟨s, h_sq, h_α_s, h_β_guard⟩
      exact h_bwd_S q α β h_sub ⟨s, h_sq, (ihα h_α_sub s).mp h_α_s,
        fun r h_sr h_rq => (ihβ h_β_sub r).mp (h_β_guard r h_sr h_rq)⟩
    · intro h_S
      obtain ⟨s, h_sq, h_α_s, h_β_guard⟩ := h_fwd_S q α β h_sub h_S
      exact ⟨s, h_sq, (ihα h_α_sub s).mpr h_α_s,
        fun r h_sr h_rq => (ihβ h_β_sub r).mpr (h_β_guard r h_sr h_rq)⟩

/--
The truth correspondence at the chronicle bundle itself, with the restricted Until/Since
coherence hypotheses discharged by `cantor_bfmcs_dense_restricted_fuc` and
`cantor_bfmcs_dense_restricted_buc`.

This is the packaged form Reynolds' step 2 delivers: the finite-language structure over the
rationals, together with the guarantee that it models exactly the formulas of
`subformulaClosure root` that the chronicle's MCS at `q` contains.
-/
theorem chronicleMonadic_truth_correspondence_eval (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    (φ : Formula) (h_sub : φ ∈ subformulaClosure root) (q : Rat) :
    TemporalTruth (chronicleMonadicStructure fc A h_mcs h_box_dense root)
        (mkAtomMapFwd root) q φ ↔
      φ ∈ (cantorBfmcsDense fc A h_mcs h_box_dense).evalFamily.mcs q :=
  chronicleMonadic_truth_correspondence (cantorBfmcsDense fc A h_mcs h_box_dense) root
    (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense root)
    (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense root)
    (cantorBfmcsDense fc A h_mcs h_box_dense).evalFamily
    (cantorBfmcsDense fc A h_mcs h_box_dense).eval_family_mem φ h_sub q

/-! ## Part 5: Unrestricted Until/Since coherence for the dense chronicle

Reynolds §4 Corollary 1 clause 3 — *"all substitution instances of the axioms Prior-U, Prior-S
and Sep are valid in `M`"* — quantifies over **all** substitution instances, not only over the
subformulas of the root. Part 4's truth correspondence is closure-bounded, so Part 6 below
re-runs it unrestricted; that needs unrestricted Until/Since coherence.

It is available for free. `cantor_bfmcs_dense_restricted_fuc` / `_buc`
(`ChronicleToCountermodelBasic.lean:755` / `:680`) are polymorphic in `root` and **discard**
their closure-membership argument (their proofs open with `intro t φ ψ _`), so instantiating at
`root := Formula.untl α β` — respectively `Formula.snce α β` — and discharging with
`self_mem_subformulaClosure` recovers the unrestricted statement. This is the same **self-root
instantiation** already used by `cantor_bfmcs_dense_limit_guard_above`
(`ChronicleLimitGuardAbove.lean:203`) and `_below` (`ChronicleLimitGuardWitness.lean:198`); no
chronicle declaration is modified, and the restricted originals are retained unweakened.

No source: this is a Lean-level packaging step. -/

/-- Unrestricted forward Until/Since coherence for `cantorBfmcsDense`, by self-root
instantiation of `cantor_bfmcs_dense_restricted_fuc`. -/
theorem cantor_bfmcs_dense_fuc (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) :
    (cantorBfmcsDense fc A h_mcs h_box_dense).ForwardUntilSinceCoherent := by
  intro fam hfam
  refine ⟨fun t α β h => ?_, fun t α β h => ?_⟩
  · exact (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
      (Formula.untl β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  · exact (cantor_bfmcs_dense_restricted_fuc fc A h_mcs h_box_dense
      (Formula.snce β α) fam hfam).2 t α β (self_mem_subformulaClosure _) h

/-- Unrestricted backward Until/Since coherence for `cantorBfmcsDense`, by self-root
instantiation of `cantor_bfmcs_dense_restricted_buc`. -/
theorem cantor_bfmcs_dense_buc (fc : FrameClass) (A : Set Formula)
    (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) :
    (cantorBfmcsDense fc A h_mcs h_box_dense).BackwardUntilSinceCoherent := by
  intro fam hfam
  refine ⟨fun t α β h => ?_, fun t α β h => ?_⟩
  · exact (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
      (Formula.untl β α) fam hfam).1 t α β (self_mem_subformulaClosure _) h
  · exact (cantor_bfmcs_dense_restricted_buc fc A h_mcs h_box_dense
      (Formula.snce β α) fam hfam).2 t α β (self_mem_subformulaClosure _) h

/-! ## Part 6: The unrestricted (effective) truth correspondence

Part 4's `chronicleMonadic_truth_correspondence` is bounded by `subformulaClosure root`: outside
the closure an atom of `φ` need not be a predicate symbol of `mkSigFrom root`, so `TemporalTruth`
cannot read it back as membership of `φ` itself. Reynolds' clause 3 needs *all* substitution
instances, so this part removes the bound the only way it can be removed — by replacing `φ` on
the MCS side with its **effective formula** `effectiveFormula` (`Transfer.lean:1004`), which
rewrites each atom and each box-subformula through the signature round trip and leaves the
temporal skeleton alone.

This is `chronicle_temporal_truth_effective` (`Transfer.lean:1024`) transposed from
`ChronicleAsPriorModel` over an arbitrary domain to a `BFMCS` family over `ℚ`. The five cases are
the ones Part 4 already discharges; only the atom and box cases change (they become `Iff.rfl`,
since the effective formula is *defined* to be the round trip), and the Until/Since cases now
draw on Part 5 rather than on the restricted hypotheses.

**ADAPTED-FROM**: `FormalSystem/Metalogic/WeakCanonical/Transfer.lean:1024`
(`chronicle_temporal_truth_effective`). No source: original work, like the rest of the bridge. -/

/-- The chronicle bridge's effective-formula operator: `effectiveFormula` at this structure's own
atom maps, `mkAtomMap root` (`Transfer.lean:161`, which is `Subtype.val`) and `mkAtomMapFwd root`
(`:300`).

On `subformulaClosure root` it is the identity in the sense that matters — `mkAtomMapFwd_section`
makes the round trip identity on `root.predFormulas`, and Part 2 puts every closure atom and
closure box-formula there — so Part 4 is the special case of Part 6 where the rewriting does
nothing. Off the closure it renames the atoms `mkSigFrom root` cannot see, which is exactly
Reynolds' "ignoring all the atoms which don't appear in `A₀`" (§9) applied to a substitution
instance rather than to `A₀`. -/
noncomputable abbrev chronicleEff (root : Formula) : Formula → Formula :=
  effectiveFormula (mkAtomMap root) (mkAtomMapFwd root)

section ChronicleEffEqs

variable (root a b : Formula)

@[simp] theorem chronicleEff_bot : chronicleEff root Formula.bot = Formula.bot := rfl

@[simp] theorem chronicleEff_imp :
    chronicleEff root (a.imp b) = (chronicleEff root a).imp (chronicleEff root b) := rfl

@[simp] theorem chronicleEff_untl :
    chronicleEff root (Formula.untl b a)
      = Formula.untl (chronicleEff root b) (chronicleEff root a) := rfl

@[simp] theorem chronicleEff_snce :
    chronicleEff root (Formula.snce b a)
      = Formula.snce (chronicleEff root b) (chronicleEff root a) := rfl

/-- `chronicleEff` fixes `⊤`, since `Formula.top` is `⊥ → ⊥`. -/
@[simp] theorem chronicleEff_top : chronicleEff root Formula.top = Formula.top := rfl

/-- `chronicleEff` commutes with negation, since `Formula.neg` is `· → ⊥`. -/
@[simp] theorem chronicleEff_neg : chronicleEff root a.neg = (chronicleEff root a).neg := rfl

/-- `chronicleEff` commutes with conjunction. -/
@[simp] theorem chronicleEff_and :
    chronicleEff root (Formula.and a b)
      = Formula.and (chronicleEff root a) (chronicleEff root b) := rfl

/-- `chronicleEff` commutes with disjunction. -/
@[simp] theorem chronicleEff_or :
    chronicleEff root (Formula.or a b)
      = Formula.or (chronicleEff root a) (chronicleEff root b) := rfl

/-- `chronicleEff` commutes with `F`, since `Formula.someFuture` is `U(·,⊤)`. -/
@[simp] theorem chronicleEff_someFuture :
    chronicleEff root a.someFuture = (chronicleEff root a).someFuture := rfl

/-- `chronicleEff` commutes with `P`, since `Formula.somePast` is `S(·,⊤)`. -/
@[simp] theorem chronicleEff_somePast :
    chronicleEff root a.somePast = (chronicleEff root a).somePast := rfl

/-- `chronicleEff` commutes with `K⁺`, since `Formula.kPlus` is `¬U(⊤,¬·)`
(`Syntax/Formula.lean:180`). This is what lets the `Axiom.prior_U_gap` and `Axiom.sep` instances
be taken at the effective formula rather than at the original. -/
@[simp] theorem chronicleEff_kPlus :
    chronicleEff root (Formula.kPlus a) = Formula.kPlus (chronicleEff root a) := rfl

/-- `chronicleEff` commutes with `K⁻`, since `Formula.kMinus` is `¬S(⊤,¬·)`
(`Syntax/Formula.lean:193`). -/
@[simp] theorem chronicleEff_kMinus :
    chronicleEff root (Formula.kMinus a) = Formula.kMinus (chronicleEff root a) := rfl

end ChronicleEffEqs

/--
**Unrestricted truth correspondence for the dense monadic bridge.**

For **every** formula `φ` — no closure hypothesis — temporal truth of `φ` at `q` in
`chronicleMonadicStructureOf root fam` holds exactly when the *effective* formula
`chronicleEff root φ` is in `fam.mcs q`.

This is what Part 4 cannot give and what Reynolds' clause 3 requires. Part 4 remains the
statement later phases use when they are inside the closure, since there the effective rewriting
is invisible; this is the statement Parts 7 and 8 use.
-/
theorem chronicleMonadic_truth_effective {fc : FrameClass}
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_fuc : B.ForwardUntilSinceCoherent)
    (h_buc : B.BackwardUntilSinceCoherent)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families)
    (φ : Formula) (q : Rat) :
    TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) q φ ↔
      chronicleEff root φ ∈ fam.mcs q := by
  induction φ generalizing q with
  | atom a => exact Iff.rfl
  | bot =>
    simp only [TemporalTruth, chronicleEff_bot]
    constructor
    · intro h; exact h.elim
    · intro h_mem
      exfalso
      have h_cons := (fam.is_mcs q).1
      have h_deriv : DerivationTree fc [Formula.bot] Formula.bot :=
        DerivationTree.assumption [Formula.bot] Formula.bot (by simp)
      exact h_cons [Formula.bot] (fun psi hpsi => by
        simp only [List.mem_cons, List.not_mem_nil, or_false] at hpsi
        rw [hpsi]; exact h_mem) ⟨h_deriv⟩
  | imp ψ χ ihψ ihχ =>
    simp only [TemporalTruth, chronicleEff_imp]
    have h_mcs := fam.is_mcs q
    constructor
    · intro h_truth_imp
      rcases SetMaximalConsistent.negation_complete h_mcs
          ((chronicleEff root ψ).imp (chronicleEff root χ)) with h_imp | h_neg_imp
      · exact h_imp
      · exfalso
        have h_ψ_mcs : chronicleEff root ψ ∈ fam.mcs q :=
          SetMaximalConsistent.closed_under_derivation h_mcs
            [((chronicleEff root ψ).imp (chronicleEff root χ)).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _
                (neg_imp_antecedent (chronicleEff root ψ) (chronicleEff root χ))
                (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_neg_χ_mcs : (chronicleEff root χ).neg ∈ fam.mcs q :=
          SetMaximalConsistent.closed_under_derivation h_mcs
            [((chronicleEff root ψ).imp (chronicleEff root χ)).neg]
            (by simp [h_neg_imp])
            (DerivationTree.modus_ponens _ _ _
              (DerivationTree.weakening [] _ _
                (neg_imp_neg_consequent (chronicleEff root ψ) (chronicleEff root χ))
                (by intro; simp))
              (DerivationTree.assumption _ _ (by simp)))
        have h_χ_mcs : chronicleEff root χ ∈ fam.mcs q :=
          (ihχ q).mp (h_truth_imp ((ihψ q).mpr h_ψ_mcs))
        exact set_consistent_not_both (fam.is_mcs q).1 _ h_χ_mcs h_neg_χ_mcs
    · intro h_imp h_ψ_true
      exact (ihχ q).mpr
        (SetMaximalConsistent.implication_property h_mcs h_imp ((ihψ q).mp h_ψ_true))
  | box ψ _ih => exact Iff.rfl
  | untl β α ihβ ihα =>
    simp only [TemporalTruth, chronicleEff_untl]
    obtain ⟨h_fwd_U, _⟩ := h_fuc fam hfam
    obtain ⟨h_bwd_U, _⟩ := h_buc fam hfam
    constructor
    · rintro ⟨s, h_qs, h_α_s, h_β_guard⟩
      exact h_bwd_U q _ _ ⟨s, h_qs, (ihα s).mp h_α_s,
        fun r h_qr h_rs => (ihβ r).mp (h_β_guard r h_qr h_rs)⟩
    · intro h_U
      obtain ⟨s, h_qs, h_α_s, h_β_guard⟩ := h_fwd_U q _ _ h_U
      exact ⟨s, h_qs, (ihα s).mpr h_α_s,
        fun r h_qr h_rs => (ihβ r).mpr (h_β_guard r h_qr h_rs)⟩
  | snce β α ihβ ihα =>
    simp only [TemporalTruth, chronicleEff_snce]
    obtain ⟨_, h_fwd_S⟩ := h_fuc fam hfam
    obtain ⟨_, h_bwd_S⟩ := h_buc fam hfam
    constructor
    · rintro ⟨s, h_sq, h_α_s, h_β_guard⟩
      exact h_bwd_S q _ _ ⟨s, h_sq, (ihα s).mp h_α_s,
        fun r h_sr h_rq => (ihβ r).mp (h_β_guard r h_sr h_rq)⟩
    · intro h_S
      obtain ⟨s, h_sq, h_α_s, h_β_guard⟩ := h_fwd_S q _ _ h_S
      exact ⟨s, h_sq, (ihα s).mpr h_α_s,
        fun r h_sr h_rq => (ihβ r).mpr (h_β_guard r h_sr h_rq)⟩

/-! ## Part 7: Reynolds §4 Corollary 1 clause 3 — Prior-U, Prior-S and Sep

The corollary is quoted here character-for-character from the local corpus
(`reynolds_1992/sec02_3-irr.md`, "**Corollary 1.**"; the plan records this as printed p.174):

> Because it says so in $\Gamma$, all the substitution instances of the other axioms hold
> everywhere so we have...
>
> **Corollary 1.** *For every **US/R**-consistent set $\Gamma$ of formulas, there is a temporal
> structure $M$ such that*
>
> 1. *the flow of time of $M$ is the rationals,*
> 2. *for all $A \in \Gamma$, $M \models A(0)$ and*
> 3. *all substitution instances of the axioms Prior-U, Prior-S and Sep are valid in $M$.*

Clause 1 is `chronicleMonadicStructureOf`'s carrier. Clause 3 is this part. The route is
Reynolds' own one-sentence justification, *"Because it says so in `Γ`, all the substitution
instances of the other axioms hold everywhere"*, executed in Lean:

1. `Axiom.prior_U_gap`, `Axiom.prior_S_gap` and `Axiom.sep` each have
   `minFrameClass = FrameClass.Dedekind` (`Axioms.lean:524-526`), so under
   `hfc : FrameClass.Dedekind ≤ fc` every substitution instance is a `DerivationTree fc []`
   theorem;
2. `theorem_in_mcs` (`Core/MaximalConsistent.lean:491`) puts it in the family's MCS at *every*
   rational — Reynolds' "hold everywhere";
3. Part 6 reads it back semantically, and `kPlus_formula_correct` / `kMinus_formula_correct`
   (`Kamp/KPlusFaithful.lean:150` / `:170`) read the `K⁺` / `K⁻` the axioms are stated with.

Step 3's bridge lemma is the one the plan names: `Axiom.prior_U_gap` is stated with
`Formula.kPlus` (`Axioms.lean:377`; `Syntax/Formula.lean:180`), and `kPlus_formula_correct` is
what reads it semantically. `kplusFormula` (`Kamp/PriorINF.lean:~93`) is **not** substituted for
it — the two differ by a conjunct and the name-collision warning at `Formula.lean:163-179` says
so.

Reynolds gives no argument beyond the quoted sentence, so the Lean execution of steps 1-3 is
original glue on a sourced statement. -/

/-- **Semantic Sep** — Reynolds 1992, printed p.168:

```
Sep:   K⁺φ ∧ ¬K⁺(φ ∧ U(φ,¬φ)) → K⁺(K⁺φ ∧ K⁻φ)
```

the semantic reading of `Axiom.sep` (`ProofSystem/Axioms.lean:398`), in the idiom
`PriorDefsDense.lean` uses for `SemanticPriorU` / `SemanticPriorS`. Reynolds defers its validity
proof: *"we investigate this axiom in more detail in section 7 and defer proving its validity in
ℝ until lemma 10 there"* (printed p.168, quoted in the `Axiom.sep` docstring). **Lemma 10 is not
re-derived here** — this development obtains Sep the way Corollary 1 obtains it, from the axiom's
membership in the MCS, not from a validity argument over ℝ.

Each `K⁺` / `K⁻` is read at `kplusOpen` / `kminusOpen` (`Kamp/KPlusFaithful.lean`), the faithful
`Prop`-level reading of `Formula.kPlus` / `Formula.kMinus` that `kPlus_formula_correct` /
`kMinus_formula_correct` certify — **not** at this tree's stronger `kplus` / `kminus`, which
carry an extra conjunct that is in neither Reynolds nor Rabinovich.

**This is `Axiom.sep`'s first consumer on any completeness route in this repository.** -/
def SemanticSep {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig)
    (atomMap : Formula → sig.preds) : Prop :=
  ∀ (t : M.carrier) (p : Formula),
    Kamp.kplusOpen M atomMap p t →
    ¬ Kamp.kplusOpen M atomMap (Formula.and p (Formula.untl p.neg p)) t →
    Kamp.kplusOpen M atomMap (Formula.and (Formula.kPlus p) (Formula.kMinus p)) t

/-- **The bridge structure satisfies Prior-U** — Reynolds §4 Corollary 1 clause 3, first
conjunct: *"all substitution instances of the axioms Prior-U ... are valid in `M`"*.

Every substitution instance of `Axiom.prior_U_gap` is an `fc`-theorem for `fc ≥ Dedekind`, hence
in `fam.mcs t` for every rational `t`; Part 6 reads it back as `SemanticPriorU`. The instance is
taken at the **effective** formula `chronicleEff root p`, which is what makes the statement hold
for every `p` rather than only for `p ∈ subformulaClosure root`. -/
theorem chronicleMonadic_semanticPriorU {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_fuc : B.ForwardUntilSinceCoherent)
    (h_buc : B.BackwardUntilSinceCoherent)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) :
    SemanticPriorU (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) := by
  have corr := chronicleMonadic_truth_effective B root h_fuc h_buc fam hfam
  intro t p h_stretch h_future
  obtain ⟨s₀, hts₀, h_p_on⟩ := h_stretch
  obtain ⟨u₀, htu₀, h_np_u₀⟩ := h_future
  -- The antecedent `U(⊤,p) ∧ F¬p`, semantically.
  have h_ant : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.and (Formula.untl p Formula.top) p.neg.someFuture) := by
    rw [Kamp.temporal_truth_and]
    refine ⟨⟨s₀, hts₀, Kamp.temporal_truth_top _ _ _, h_p_on⟩,
      ⟨u₀, htu₀, (Kamp.temporal_truth_neg _ _ _ _).mpr h_np_u₀,
        fun r _ _ => Kamp.temporal_truth_top _ _ _⟩⟩
  -- ... transported to the MCS at `t`.
  have h_ant_mcs : Formula.and (Formula.untl (chronicleEff root p) Formula.top)
      (chronicleEff root p).neg.someFuture ∈ fam.mcs t := by
    have h := (corr _ t).mp h_ant
    simpa using h
  -- The axiom instance, at the effective formula.
  have h_thm : Formula.untl (chronicleEff root p) (Formula.or (chronicleEff root p).neg
      (Formula.kPlus (chronicleEff root p).neg)) ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t)
      (theorem_in_mcs (fam.is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.prior_U_gap (chronicleEff root p)) hfc))
      h_ant_mcs
  -- ... read back semantically.
  have h_truth : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.untl p (Formula.or p.neg (Formula.kPlus p.neg))) := by
    refine (corr _ t).mpr ?_
    simpa using h_thm
  obtain ⟨s, hts, h_disj, h_guard⟩ := h_truth
  refine ⟨s, hts, h_guard, ?_⟩
  rcases (Kamp.temporal_truth_or _ _ _ _ _).mp h_disj with h_neg | h_kp
  · exact Or.inl ((Kamp.temporal_truth_neg _ _ _ _).mp h_neg)
  · -- `K⁺(¬p)(s)`: `¬p` accumulates from above at `s`. Split on whether `p` holds at `s`.
    have h_open : Kamp.kplusOpen (chronicleMonadicStructureOf root fam)
        (mkAtomMapFwd root) p.neg s := (Kamp.kPlus_formula_correct _ _ _ _).mp h_kp
    by_cases h_ps : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) s p
    · refine Or.inr ⟨h_ps, fun u hsu => ?_⟩
      obtain ⟨r, hsr, hru, hr⟩ := h_open u hsu
      exact ⟨r, hsr, hru, (Kamp.temporal_truth_neg _ _ _ _).mp hr⟩
    · exact Or.inl h_ps

/-- **The bridge structure satisfies Prior-S** — Reynolds §4 Corollary 1 clause 3, second
conjunct. The past mirror of `chronicleMonadic_semanticPriorU`, at `Axiom.prior_S_gap` and
`kMinus_formula_correct`. -/
theorem chronicleMonadic_semanticPriorS {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_fuc : B.ForwardUntilSinceCoherent)
    (h_buc : B.BackwardUntilSinceCoherent)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) :
    SemanticPriorS (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) := by
  have corr := chronicleMonadic_truth_effective B root h_fuc h_buc fam hfam
  intro t p h_stretch h_past
  obtain ⟨s₀, hs₀t, h_p_on⟩ := h_stretch
  obtain ⟨u₀, hu₀t, h_np_u₀⟩ := h_past
  have h_ant : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.and (Formula.snce p Formula.top) p.neg.somePast) := by
    rw [Kamp.temporal_truth_and]
    refine ⟨⟨s₀, hs₀t, Kamp.temporal_truth_top _ _ _, h_p_on⟩,
      ⟨u₀, hu₀t, (Kamp.temporal_truth_neg _ _ _ _).mpr h_np_u₀,
        fun r _ _ => Kamp.temporal_truth_top _ _ _⟩⟩
  have h_ant_mcs : Formula.and (Formula.snce (chronicleEff root p) Formula.top)
      (chronicleEff root p).neg.somePast ∈ fam.mcs t := by
    have h := (corr _ t).mp h_ant
    simpa using h
  have h_thm : Formula.snce (chronicleEff root p) (Formula.or (chronicleEff root p).neg
      (Formula.kMinus (chronicleEff root p).neg)) ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t)
      (theorem_in_mcs (fam.is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.prior_S_gap (chronicleEff root p)) hfc))
      h_ant_mcs
  have h_truth : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.snce p (Formula.or p.neg (Formula.kMinus p.neg))) := by
    refine (corr _ t).mpr ?_
    simpa using h_thm
  obtain ⟨s, hst, h_disj, h_guard⟩ := h_truth
  refine ⟨s, hst, h_guard, ?_⟩
  rcases (Kamp.temporal_truth_or _ _ _ _ _).mp h_disj with h_neg | h_km
  · exact Or.inl ((Kamp.temporal_truth_neg _ _ _ _).mp h_neg)
  · have h_open : Kamp.kminusOpen (chronicleMonadicStructureOf root fam)
        (mkAtomMapFwd root) p.neg s := (Kamp.kMinus_formula_correct _ _ _ _).mp h_km
    by_cases h_ps : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) s p
    · refine Or.inr ⟨h_ps, fun u hus => ?_⟩
      obtain ⟨r, hur, hrs, hr⟩ := h_open u hus
      exact ⟨r, hur, hrs, (Kamp.temporal_truth_neg _ _ _ _).mp hr⟩
    · exact Or.inl h_ps

/-- **The bridge structure satisfies Sep** — Reynolds §4 Corollary 1 clause 3, third conjunct:
*"all substitution instances of the axioms ... and Sep are valid in `M`"*.

Same route as Prior-U and Prior-S. `Axiom.sep`'s soundness is already landed
(`Axioms.lean:398`, `minFrameClass = Dedekind`); Reynolds' Lemma 10 (printed p.184) is **not**
re-derived — this obtains Sep from the axiom's membership in the MCS, exactly as Corollary 1
does. -/
theorem chronicleMonadic_semanticSep {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (B : BFMCS (fc := fc) Rat) (root : Formula)
    (h_fuc : B.ForwardUntilSinceCoherent)
    (h_buc : B.BackwardUntilSinceCoherent)
    (fam : FMCS (fc := fc) Rat) (hfam : fam ∈ B.families) :
    SemanticSep (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) := by
  have corr := chronicleMonadic_truth_effective B root h_fuc h_buc fam hfam
  intro t p h_kp h_not_kp
  -- The antecedent `K⁺p ∧ ¬K⁺(p ∧ U(p,¬p))`, semantically.
  have h_ant : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.and (Formula.kPlus p)
        (Formula.kPlus (Formula.and p (Formula.untl p.neg p))).neg) := by
    rw [Kamp.temporal_truth_and]
    refine ⟨(Kamp.kPlus_formula_correct _ _ _ _).mpr h_kp, ?_⟩
    rw [Kamp.temporal_truth_neg]
    exact fun h => h_not_kp ((Kamp.kPlus_formula_correct _ _ _ _).mp h)
  have h_ant_mcs : Formula.and (Formula.kPlus (chronicleEff root p))
      (Formula.kPlus (Formula.and (chronicleEff root p)
        (Formula.untl (chronicleEff root p).neg (chronicleEff root p)))).neg ∈ fam.mcs t := by
    have h := (corr _ t).mp h_ant
    simpa using h
  have h_thm : Formula.kPlus (Formula.and (Formula.kPlus (chronicleEff root p))
      (Formula.kMinus (chronicleEff root p))) ∈ fam.mcs t :=
    SetMaximalConsistent.implication_property (fam.is_mcs t)
      (theorem_in_mcs (fam.is_mcs t)
        (DerivationTree.axiom [] _ (Axiom.sep (chronicleEff root p)) hfc))
      h_ant_mcs
  have h_truth : TemporalTruth (chronicleMonadicStructureOf root fam) (mkAtomMapFwd root) t
      (Formula.kPlus (Formula.and (Formula.kPlus p) (Formula.kMinus p))) := by
    refine (corr _ t).mpr ?_
    simpa using h_thm
  exact (Kamp.kPlus_formula_correct _ _ _ _).mp h_truth

/-! ## Part 8: The packaged dense Prior-Sep structure

Reynolds' §9 hands Doets' theorem one object: *"The flow of time of `M` is countable, dense and
without end points and D1 and D2 follow from the theorems 4 and 5"* (§9, quoted in the module
docstring), where `M` carries Corollary 1 clause 3. `IsDensePriorSepStructure` is that object,
and `chronicleIsDensePriorSepStructure` is the chronicle's instance of it — the exact input
Blocks F, G and H consume. -/

/-- **A countable, dense, endpointless Prior structure satisfying Sep** — the conjunction
Reynolds' §9 hands to Theorems 4 and 5 (D1 and D2): clause 1 of Corollary 1 (countable dense
endpointless flow, §9: *"The flow of time of `M` is countable, dense and without end points"*)
together with clause 3 (Prior-U, Prior-S, Sep).

`Countable` / `DenselyOrdered` / `NoMaxOrder` / `NoMinOrder` are carried as fields rather than as
instance hypotheses so that the whole package is one `Prop` that later phases can name, pass and
destructure without instance-resolution games on `OrderedMonadicStructure.carrierOrder`. -/
structure IsDensePriorSepStructure {sig : MonadicSignature}
    (M : OrderedMonadicStructure sig) (atomMap : Formula → sig.preds) : Prop where
  /-- Reynolds §9: the flow is countable. -/
  countable : Countable M.carrier
  /-- Reynolds §9: the flow is dense. -/
  denselyOrdered : DenselyOrdered M.carrier
  /-- Reynolds §9: the flow has no last point. -/
  noMax : NoMaxOrder M.carrier
  /-- Reynolds §9: the flow has no first point. -/
  noMin : NoMinOrder M.carrier
  /-- Reynolds §4 Corollary 1 clause 3: all substitution instances of Prior-U are valid. -/
  priorU : SemanticPriorU M atomMap
  /-- Reynolds §4 Corollary 1 clause 3: all substitution instances of Prior-S are valid. -/
  priorS : SemanticPriorS M atomMap
  /-- Reynolds §4 Corollary 1 clause 3: all substitution instances of Sep are valid. -/
  sep : SemanticSep M atomMap

/-- **The chronicle bridge is a countable dense endpointless Prior structure satisfying Sep.**

Reynolds §4 Corollary 1 in full, at this repository's realization of it: clause 1 from `ℚ`,
clause 3 from Part 7. Clause 2 (*"for all `A ∈ Γ`, `M ⊨ A(0)`"*) is Part 4's truth
correspondence at `q = 0` and is not repeated here.

The Until/Since coherence hypotheses are discharged at the chronicle by Part 5, so this
statement's only hypotheses are the ones `cantorBfmcsDense` itself needs plus
`hfc : FrameClass.Dedekind ≤ fc`, which is exactly the frame class at which the three axioms
become available. -/
theorem chronicleIsDensePriorSepStructure {fc : FrameClass} (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula) :
    IsDensePriorSepStructure
      (chronicleMonadicStructure fc A h_mcs h_box_dense root) (mkAtomMapFwd root) where
  countable := chronicleMonadic_carrier_countable root _
  denselyOrdered := chronicleMonadic_carrier_denselyOrdered root _
  noMax := chronicleMonadic_carrier_noMaxOrder root _
  noMin := chronicleMonadic_carrier_noMinOrder root _
  priorU := chronicleMonadic_semanticPriorU hfc _ root
    (cantor_bfmcs_dense_fuc fc A h_mcs h_box_dense)
    (cantor_bfmcs_dense_buc fc A h_mcs h_box_dense) _
    (cantorBfmcsDense fc A h_mcs h_box_dense).eval_family_mem
  priorS := chronicleMonadic_semanticPriorS hfc _ root
    (cantor_bfmcs_dense_fuc fc A h_mcs h_box_dense)
    (cantor_bfmcs_dense_buc fc A h_mcs h_box_dense) _
    (cantorBfmcsDense fc A h_mcs h_box_dense).eval_family_mem
  sep := chronicleMonadic_semanticSep hfc _ root
    (cantor_bfmcs_dense_fuc fc A h_mcs h_box_dense)
    (cantor_bfmcs_dense_buc fc A h_mcs h_box_dense) _
    (cantorBfmcsDense fc A h_mcs h_box_dense).eval_family_mem

/-! ### Anti-vacuity: the witness Phase 14's hypothesis wanted

`uSExpressivelyCompleteOverDensePrior` (`WeakCanonical/PriorExpressivenessDense.lean:302`) is
Reynolds §5 Theorem 3 relativized to the *dense* Prior hypotheses: its witness formula's
correctness clause binds `SemanticPriorU M atomMap` and `SemanticPriorS M atomMap`. Until this
part, the only structures known to satisfy that pair were Phase 9's `denseWindowFlow` and the
Dedekind-complete flows of `semanticPriorU_of_flowGLB` — none of them the countable dense
chronicle the completeness route actually runs on.

The application below closes that gap: the chronicle bridge satisfies the hypothesis pair, so
expressive completeness is available *at the structure Reynolds' §6 lemmas will be run on*.
Phases 17-22 consume it in exactly this form.

**Naming note.** The plan cites this development's expressive-completeness result as
`kampDedekindExpressiveCompleteness`. **No declaration of that name exists in the tree.** The
landed names are `KampFaithfulExpressiveCompleteness` (the obligation type,
`PriorExpressivenessDense.lean:170`) and `kampFaithfulExpressiveCompleteness_open` (its
inhabitant, `:277`), composed into `uSExpressivelyCompleteOverDensePrior` (`:302`), which is what
is used here. -/

/-- **Expressive completeness at the chronicle bridge** — `uSExpressivelyCompleteOverDensePrior`
with its two hypotheses discharged by Part 7.

For every monadic formula `psi` of one free variable over the finite signature `mkSigFrom root`
there is a temporal formula `A` true at exactly the points where `psi` is satisfied, *in the
chronicle structure itself*. This is the form Reynolds' §6 Lemma 2 applies to `rhoFormula ε`. -/
noncomputable def chronicleMonadic_expressiveCompleteness {fc : FrameClass}
    (hfc : FrameClass.Dedekind ≤ fc)
    (A : Set Formula) (h_mcs : SetMaximalConsistent (fc := fc) A)
    (h_box_dense : Formula.box nextTop.neg ∈ A) (root : Formula)
    (psi : MonadicFormula (mkSigFrom root) 1) :
    { F : Formula //
      ∀ t : (chronicleMonadicStructure fc A h_mcs h_box_dense root).carrier,
        eval (chronicleMonadicStructure fc A h_mcs h_box_dense root) (fun _ => t) psi ↔
        TemporalTruth (chronicleMonadicStructure fc A h_mcs h_box_dense root)
          (mkAtomMapFwd root) t F } :=
  let H := uSExpressivelyCompleteOverDensePrior (mkAtomMapFwd root)
    (mkAtomMapFwd_surj root) psi
  let hpack := chronicleIsDensePriorSepStructure hfc A h_mcs h_box_dense root
  ⟨H.val, fun t => H.property _ hpack.priorU hpack.priorS t⟩

end FormalSystem.Metalogic.BXCanonical.Chronicle
