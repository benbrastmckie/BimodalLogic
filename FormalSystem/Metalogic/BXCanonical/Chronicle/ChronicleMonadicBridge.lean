/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.Transfer
import FormalSystem.Metalogic.WeakCanonical.Table
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import FormalSystem.Metalogic.Bundle.TemporalCoherence

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
`multiFamTaskFrame`, `multiFamOmega` and `multiFamOmega_shiftClosed` independent of
`SuccOrder`/`PredOrder`/`IsSuccArchimedean`, or is discreteness baked into the encoding?

**Answer: they are independent. Discreteness is baked only into
`countermodel_discrete_reynolds_v2`'s statement, not into the encoding.** Evidence:

* `TaskFrame` (`Semantics/TaskFrame.lean:99`) is parameterized by
  `(D : Type*) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]` and by nothing
  else. `WorldHistory`, `WorldHistory.timeShift` and `ShiftClosed` carry the same three
  instances and no successor structure.
* `Formula.predFormulas` (`Syntax/Formula.lean`) is a purely syntactic recursion on
  `Formula` with no temporal parameter at all, and `mkSigFrom φ`
  (`WeakCanonical/Transfer.lean:134`) is `Finset.cons Formula.bot φ.predFormulas _`. No
  order structure occurs in either.
* `multiFamTaskFrame FamIdx : TaskFrame ℤ` (`ReynoldsBridge.lean:671`) has
  `WorldState := FamIdx × ℤ` and `TaskRel p d q := p.1 = q.1 ∧ q.2 = p.2 + d`, in which
  `ℤ` occurs only as the carrier and `+` only as its group operation; likewise
  `multiFamOmega` (`:694`) and `multiFamOmega_shiftClosed` (`:708`).

The generic re-statements below (`multiFamTaskFrameGen` and siblings) *discharge* the gate
rather than merely asserting it: they typecheck over an arbitrary
`[AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]`, and the `ℤ` originals are
recovered as definitional specializations (`multiFamTaskFrameGen_int` and siblings). The
`ℤ` originals are left byte-identical; `countermodel_discrete_reynolds_v2` still consumes
them. Phase 30 consumes the generic versions at `D := ℝ`.

## Note for the record

`mkSigFrom` lives in `WeakCanonical/Transfer.lean`, which carries this repository's single
live `sorry` at `:1242` in an **unrelated** declaration. Importing it is normal and already
universal in this tree. `Transfer.lean:1242` is not attempted here.

## Main results

* `multiFamTaskFrameGen` / `multiFamOmegaGen` / `multiFamOmegaGen_shiftClosed` — the
  discreteness-free multi-family frame, over an arbitrary ordered abelian group.
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

/-! ## Part 1: The discreteness-free multi-family frame (R7 gate discharge)

Generic re-statements of `ReynoldsBridge.lean`'s `multiFamTaskFrame`/`multiFamHistory`/
`multiFamOmega` family over an arbitrary ordered abelian group `D`. These are landed
**beside** the `ℤ` originals, which are untouched: `countermodel_discrete_reynolds_v2`
continues to consume the originals, and the `_int` lemmas below certify that the originals
are the definitional `D := ℤ` specializations of these.

No source: this generalization is original work, adapted from the `ℤ` definitions named
above.
-/

section MultiFamGen

variable {D : Type} [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]

/-- `TaskFrame` with `WorldState = FamIdx × D` over an arbitrary ordered abelian group `D`.
The generic form of `multiFamTaskFrame` (`ReynoldsBridge.lean:671`); the task relation is
deterministic, stepping by `d` from `(f, x)` to `(f, x + d)`. -/
noncomputable def multiFamTaskFrameGen (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (FamIdx : Type) : TaskFrame D where
  WorldState := FamIdx × D
  TaskRel := fun p d q => p.1 = q.1 ∧ q.2 = p.2 + d
  nullity_identity := fun p q => by
    constructor
    · rintro ⟨h1, h2⟩
      refine Prod.ext h1 ?_
      rw [h2, add_zero]
    · rintro rfl; exact ⟨rfl, (add_zero _).symm⟩
  forward_comp := fun _ _ _ _ _ _ _ ⟨h1, h2⟩ ⟨h3, h4⟩ =>
    ⟨h1.trans h3, by rw [h4, h2, add_assoc]⟩
  converse := fun _ _ _ => by
    constructor
    · rintro ⟨h1, h2⟩; exact ⟨h1.symm, by rw [h2]; abel⟩
    · rintro ⟨h1, h2⟩; exact ⟨h1.symm, by rw [h2]; abel⟩

/-- World history for `multiFamTaskFrameGen`, visiting `(f, w₀ + t)` at each time `t`.
Generic form of `multiFamHistory` (`ReynoldsBridge.lean:684`). -/
noncomputable def multiFamHistoryGen {FamIdx : Type} (f : FamIdx) (w₀ : D) :
    WorldHistory (multiFamTaskFrameGen D FamIdx) where
  domain := fun _ => True
  convex := fun _ _ _ _ _ _ _ => trivial
  states := fun t _ => (f, w₀ + t)
  respects_task := fun s t _ _ _ => by
    refine ⟨rfl, ?_⟩
    show w₀ + t = w₀ + s + (t - s)
    abel

/-- Omega for `multiFamTaskFrameGen`: all histories `multiFamHistoryGen f w₀`.
Generic form of `multiFamOmega` (`ReynoldsBridge.lean:694`). -/
def multiFamOmegaGen (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (FamIdx : Type) : Set (WorldHistory (multiFamTaskFrameGen D FamIdx)) :=
  Set.range (fun (p : FamIdx × D) => multiFamHistoryGen p.1 p.2)

/-- Time-shifting `multiFamHistoryGen f w₀` by `Δ` gives `multiFamHistoryGen f (w₀ + Δ)`.
Generic form of `multiFamHistory_shift_eq` (`ReynoldsBridge.lean:698`). -/
theorem multiFamHistoryGen_shift_eq {FamIdx : Type} (f : FamIdx) (w₀ Δ : D) :
    WorldHistory.timeShift
        (multiFamHistoryGen f w₀ : WorldHistory (multiFamTaskFrameGen D FamIdx)) Δ =
      multiFamHistoryGen f (w₀ + Δ) := by
  have h_states : (fun (t : D) (_ : True) => ((f, w₀ + (t + Δ)) : FamIdx × D)) =
      (fun (t : D) (_ : True) => ((f, w₀ + Δ + t) : FamIdx × D)) := by
    funext t _; congr 1; abel
  change WorldHistory.mk _ _ _ _ = WorldHistory.mk _ _ _ _
  congr 1

/-- The generic multi-family Omega is shift-closed. Generic form of
`multiFamOmega_shiftClosed` (`ReynoldsBridge.lean:708`). -/
theorem multiFamOmegaGen_shiftClosed (D : Type) [AddCommGroup D] [LinearOrder D]
    [IsOrderedAddMonoid D] (FamIdx : Type) :
    ShiftClosed (multiFamOmegaGen D FamIdx) := by
  intro σ hσ Δ
  obtain ⟨⟨f, w₀⟩, hw₀⟩ := hσ
  rw [← hw₀, multiFamHistoryGen_shift_eq]
  exact ⟨⟨f, w₀ + Δ⟩, rfl⟩

/-- Every generic multi-family history is in the generic Omega. Generic form of
`multiFamHistory_mem_omega` (`ReynoldsBridge.lean:717`). -/
theorem multiFamHistoryGen_mem_omega {FamIdx : Type} (f : FamIdx) (w₀ : D) :
    multiFamHistoryGen f w₀ ∈ multiFamOmegaGen D FamIdx :=
  ⟨⟨f, w₀⟩, rfl⟩

/-! ### The `ℤ` originals are the definitional specializations

These three `rfl` proofs are the substance of the R7 gate answer: the landed `ℤ`
definitions consumed by `countermodel_discrete_reynolds_v2` are *definitionally* the
`D := ℤ` instances of the generic ones, so nothing discrete was ever baked into them. -/

/-- `multiFamTaskFrame` is definitionally `multiFamTaskFrameGen ℤ`. -/
theorem multiFamTaskFrameGen_int (FamIdx : Type) :
    multiFamTaskFrameGen ℤ FamIdx = multiFamTaskFrame FamIdx := rfl

/-- `multiFamHistory` is definitionally `multiFamHistoryGen` at `D := ℤ`. -/
theorem multiFamHistoryGen_int {FamIdx : Type} (f : FamIdx) (w₀ : ℤ) :
    multiFamHistoryGen f w₀ = multiFamHistory f w₀ := rfl

/-- `multiFamOmega` is definitionally `multiFamOmegaGen ℤ`. -/
theorem multiFamOmegaGen_int (FamIdx : Type) :
    multiFamOmegaGen ℤ FamIdx = multiFamOmega FamIdx := rfl

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
  | untl ψ χ ihψ ihχ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihψ h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihχ h)
  | snce ψ χ ihψ ihχ =>
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
  | untl α β ihα ihβ =>
    simp only [Formula.subformulas, List.mem_cons, List.mem_append] at h
    rcases h with h | h | h
    · exact absurd h (by simp)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inl (ihα h)
    · simp only [Formula.predFormulas, Finset.mem_union]; exact Or.inr (ihβ h)
  | snce α β ihα ihβ =>
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
`neg_imp_implies_antecedent` / `neg_imp_implies_neg_consequent` of
`Algebraic/RestrictedParametricTruthLemma.lean`, which are not exported. The proofs are
transcribed from there unchanged; nothing in the original file is edited or weakened. -/

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
  | untl α β ihα ihβ =>
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
  | snce α β ihα ihβ =>
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

end FormalSystem.Metalogic.BXCanonical.Chronicle
