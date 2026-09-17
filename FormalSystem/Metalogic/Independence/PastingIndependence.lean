/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.CoarsenedModels
import FormalSystem.Metalogic.Algebraic.FlowFrame

/-!
# The two pasting axioms are not derivable from the naive `⊡`-set

`pasteNotNaiveDerivable` and `untlPasteNotNaiveDerivable`: PS and US are **not** theorems of TM
together with the six S5/bridge schemata {SK, ST, S4, S5, MS, AS}. The axiom set of TM⁺
(`PlusLanguage/Axioms.lean`) is therefore non-redundant — its docstring's claim that the S5 set
"alone is provably incomplete" is now machine-checked.

## The refuting model

One coarsened-state model (`Metalogic/Independence/CoarsenedModels.lean`) refutes both:

* **Frame** — the deterministic clock over `ℤ` at a one-element family index,
  `multiFamTaskFrameGen (TemporalOrder.of ℤ) Unit`. Its world histories are exactly the flow
  lines `t ↦ ((), w₀ + t)`, one per offset `w₀ : ℤ` (`pTotal_toHist`).
* **Valuation** — every atom is true at the states whose clock reads `0`, so along the flow line
  of offset `w₀` the atom holds at exactly the time `-w₀`.
* **Coarsening** — `π ((), x) = |x|`, which identifies the offsets `w₀` and `-w₀` and is
  atom-invariant because `|x| = |y|` and `x = 0` force `y = 0`.

The point of evaluation is `(pHist (-1), 0)`. Its `π`-class contains exactly two flow lines,
those of offset `-1` and `+1`:

| line | `Fp` at time `0` | `Pp` at time `0` |
|---|---|---|
| `pHist (-1)` — atom at time `1` | **yes** | no |
| `pHist 1` — atom at time `-1` | no | **yes** |

So `⟐Fp` and `⟐Pp` both hold, while `⟐(Fp ∧ Pp)` fails — indeed `Fp ∧ Pp` is false at *every*
point of this model, since the atom holds at exactly one time on each line. That is PS refuted.
US is refuted at the same point with `α := ⊤` and `φ⁺ := Fp`: the antecedent `F⟐Fp` holds
(at time `2` the class of `pHist (-1)` contains the line of offset `-3`, whose atom is still
ahead), while the consequent `⟐FFp` fails, because neither line of the class at time `0` admits
a strictly intermediate time before its atom.

## Why the coarsening is what does the work

On a genuine task frame PS and US are **valid** (`Semantics/PlusLanguage/PlusPasting.lean`): the splice of
two world histories through a common state is again a world history. Coarsening breaks exactly
that, and nothing else — the two lines above pass through *different* states at time `0`, so
there is no state for a splice to run through. Everything else about the model is ordinary.

## Nothing here weakens TM⁺

The pasting axioms remain valid on every task frame; these theorems say only that the *naive*
system cannot prove them, which is why TM⁺ carries them as axioms. The live `PlusAxiom` is
unchanged, and `NaiveDerivable` is a predicate on the existing derivation trees
(`Metalogic/Independence/NaiveSystem.lean`), not a second proof system.

## Main Results

- `pasteNotNaiveDerivable` — PS is not naively derivable
- `untlPasteNotNaiveDerivable` — US is not naively derivable

## References

* `FormalSystem/PlusLanguage/Axioms.lean` — the docstring this result discharges
* `FormalSystem/Semantics/PlusLanguage/PlusPasting.lean` — the validity of PS and US on genuine frames

## Tags

independence · pasting · plus-language · stability-modal
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage
open FormalSystem.PlusLanguage.PlusFormula
open FormalSystem.Semantics
open FormalSystem.Metalogic.Algebraic

/-! ## The model -/

/-- The refuting frame: the deterministic clock over `ℤ` at a one-element family index. -/
@[reducible] noncomputable def PF : TaskFrame :=
  (multiFamTaskFrameGen (TemporalOrder.of ℤ) Unit).toTaskFrame

/-- The refuting coarsened model: every atom true where the clock reads `0`, and the coarsening
`|·|` on the clock, which identifies the offsets `w₀` and `-w₀`. -/
noncomputable def pModel : CoarseModel PF where
  toModel := { valuation := fun w _ => w.2 = 0 }
  Cls := ℕ
  π := fun w => w.2.natAbs
  atom_inv := by
    intro w u h p hv
    have h' : w.2.natAbs = u.2.natAbs := h
    have hv' : w.2.natAbs = 0 := Int.natAbs_eq_zero.mpr hv
    exact Int.natAbs_eq_zero.mp (h' ▸ hv')

/-- The flow line of offset `w₀`. -/
noncomputable def pHist (w₀ : ℤ) : WorldHistory PF := multiFamHistoryGen () w₀

theorem pHist_state (w₀ t : ℤ) : (pHist w₀).state t = ((), w₀ + t) := rfl

/-! ### Truth along a flow line -/

theorem pHist_atom (w₀ t : ℤ) (q : Atom) :
    CTruthAt pModel (pHist w₀) t (.atom q) ↔ w₀ + t = 0 :=
  Iff.rfl

theorem pHist_someFuture_atom (w₀ t : ℤ) (q : Atom) :
    CTruthAt pModel (pHist w₀) t (someFuture (.atom q)) ↔ t < -w₀ := by
  rw [CTruth.someFuture_iff]
  constructor
  · rintro ⟨s, hts, hs⟩
    have hts' : t < s := hts
    have hs' : w₀ + s = 0 := (pHist_atom w₀ s q).mp hs
    omega
  · intro h
    have hlt : t < -w₀ := h
    exact ⟨-w₀, hlt, (pHist_atom w₀ (-w₀) q).mpr (by omega)⟩

theorem pHist_somePast_atom (w₀ t : ℤ) (q : Atom) :
    CTruthAt pModel (pHist w₀) t (somePast (.atom q)) ↔ -w₀ < t := by
  rw [CTruth.somePast_iff]
  constructor
  · rintro ⟨s, hst, hs⟩
    have hst' : t > s := hst
    have hs' : w₀ + s = 0 := (pHist_atom w₀ s q).mp hs
    omega
  · intro h
    have hlt : -w₀ < t := h
    exact ⟨-w₀, hlt, (pHist_atom w₀ (-w₀) q).mpr (by omega)⟩

/-- `FFp` along a flow line: a strictly intermediate time before the atom is needed. -/
theorem pHist_someFuture_someFuture_atom (w₀ t : ℤ) (q : Atom) :
    CTruthAt pModel (pHist w₀) t (someFuture (someFuture (.atom q))) ↔ t + 1 < -w₀ := by
  rw [CTruth.someFuture_iff]
  constructor
  · rintro ⟨s, hts, hs⟩
    have hts' : t < s := hts
    have hs' : -w₀ > s := (pHist_someFuture_atom w₀ s q).mp hs
    omega
  · intro h
    have hlt : t < t + 1 := by omega
    exact ⟨t + 1, hlt, (pHist_someFuture_atom w₀ (t + 1) q).mpr (by omega)⟩

/-! ### Every world history is a flow line -/

/-- A world history of `PF` agrees pointwise with the flow line of its own offset at time `0`,
by `respects_task` at `(0, t)`. -/
theorem pTotal_states (σ : WorldHistory PF) (t : ℤ) :
    σ.state t = ((), (σ.state 0).2 + t) := by
  obtain ⟨_, h2⟩ := (FormalSystem.Metalogic.Algebraic.multiFamGen_taskRel (D := TemporalOrder.of ℤ) _ _ _).mp
    (σ.val.respects_task 0 t (σ.property 0) (σ.property t))
  refine Prod.ext rfl ?_
  show (σ.state t).2 = (σ.state 0).2 + t
  have h2' : (σ.state t).2 = (σ.state 0).2 + (t - 0) := h2
  rw [h2', sub_zero]

/-- Hence a world history satisfies exactly what its flow line satisfies. -/
theorem pTotal_toHist (σ : WorldHistory PF) (t : ℤ) (φ : PlusFormula) :
    CTruthAt pModel σ t φ ↔ CTruthAt pModel (pHist (σ.state 0).2) t φ :=
  c_truth_congr_ext pModel φ σ _ t fun s => (pTotal_states σ s).trans rfl

/-! ## PS is refuted -/

/-- The pure-future conjunct. -/
private def phiPlus (p : Atom) : PlusFormula := someFuture (.atom p)

/-- The pure-past conjunct. -/
private def psiMinus (p : Atom) : PlusFormula := somePast (.atom p)

theorem phiPlus_pureFuture (p : Atom) : IsPureFuture (phiPlus p) :=
  IsPureFuture.someFuture (IsPureFuture.atom p)

theorem psiMinus_purePast (p : Atom) : IsPurePast (psiMinus p) :=
  IsPurePast.somePast (IsPurePast.atom p)

/-- `Fp` holds along the line of offset `-1` at time `0`. -/
theorem dstab_phiPlus (p : Atom) :
    CTruthAt pModel (pHist (-1)) 0 (dstab (phiPlus p)) := by
  rw [CTruth.dstab_iff]
  have hahead : (0 : ℤ) < -(-1 : ℤ) := by decide
  exact ⟨pHist (-1), SameUnder.refl _ _ _,
    (pHist_someFuture_atom (-1) 0 p).mpr hahead⟩

/-- `Pp` holds along the line of offset `1`, which is in the same `π`-class at time `0`. -/
theorem dstab_psiMinus (p : Atom) :
    CTruthAt pModel (pHist (-1)) 0 (dstab (psiMinus p)) := by
  rw [CTruth.dstab_iff]
  have hback : -(1 : ℤ) < (0 : ℤ) := by decide
  refine ⟨pHist 1, ?_, (pHist_somePast_atom 1 0 p).mpr hback⟩
  show ((-1 : ℤ) + 0).natAbs = ((1 : ℤ) + 0).natAbs
  decide

/-- No world history of the model satisfies `Fp ∧ Pp`: on each flow line the atom holds at
exactly one time, which cannot be both strictly future and strictly past. -/
theorem not_and_phiPlus_psiMinus (p : Atom) (σ : WorldHistory PF) (t : ℤ) :
    ¬ CTruthAt pModel σ t ((phiPlus p).and (psiMinus p)) := by
  rw [pTotal_toHist σ t, CTruth.and_iff, phiPlus, psiMinus,
    pHist_someFuture_atom, pHist_somePast_atom]
  omega

/--
**PS is not derivable from the naive `⊡`-set.** The instance at `φ⁺ := Fp`, `ψ⁻ := Pp` fails at
`(pHist (-1), 0)` in a coarsened model, and every naive theorem is coarsely valid
(`naive_cValid`).

Paper: — (formalization-native; the naive `⊡`-set is this tree's own, with no paper counterpart)
-/
theorem pasteNotNaiveDerivable (p : Atom) :
    ∃ φ ψ : PlusFormula, IsPureFuture φ ∧ IsPurePast ψ ∧
      ¬ NaiveDerivable FrameClass.Base []
        ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ)))) := by
  refine ⟨phiPlus p, psiMinus p, phiPlus_pureFuture p, psiMinus_purePast p, ?_⟩
  refine not_naiveDerivable_of_cRefuted PF pModel (pHist (-1)) 0 ?_
  intro h
  have hcon := h (dstab_phiPlus p) (dstab_psiMinus p)
  rw [CTruth.dstab_iff] at hcon
  obtain ⟨σ, _, hand⟩ := hcon
  exact not_and_phiPlus_psiMinus p σ 0 hand

/-! ## US is refuted -/

/-- The antecedent of the US instance holds: at time `2` the `π`-class of `pHist (-1)` contains
the line of offset `-3`, whose atom is still ahead. -/
theorem someFuture_dstab_phiPlus (p : Atom) :
    CTruthAt pModel (pHist (-1)) 0 (someFuture (dstab (phiPlus p))) := by
  rw [CTruth.someFuture_iff]
  have h2 : (0 : ℤ) < 2 := by decide
  refine ⟨2, h2, ?_⟩
  rw [CTruth.dstab_iff]
  have hahead : (2 : ℤ) < -(-3 : ℤ) := by decide
  refine ⟨pHist (-3), ?_, (pHist_someFuture_atom (-3) 2 p).mpr hahead⟩
  show ((-1 : ℤ) + 2).natAbs = ((-3 : ℤ) + 2).natAbs
  decide

/-- The consequent fails: neither line of the class at time `0` admits a strictly intermediate
time before its atom. -/
theorem not_dstab_someFuture_phiPlus (p : Atom) :
    ¬ CTruthAt pModel (pHist (-1)) 0 (dstab (someFuture (phiPlus p))) := by
  rw [CTruth.dstab_iff]
  rintro ⟨σ, hsame, hff⟩
  have hcls : ((-1 : ℤ) + 0).natAbs = (σ.state 0).2.natAbs := hsame
  rw [pTotal_toHist σ 0, phiPlus, pHist_someFuture_someFuture_atom] at hff
  omega

/--
**US is not derivable from the naive `⊡`-set.** The instance at `α⁻ := ⊤`, `φ⁺ := Fp` fails at
`(pHist (-1), 0)` in the same coarsened model.

Paper: — (formalization-native; the naive `⊡`-set is this tree's own, with no paper counterpart)
-/
theorem untlPasteNotNaiveDerivable (p : Atom) :
    ∃ α φ : PlusFormula, IsPurePast α ∧ IsPureFuture φ ∧
      ¬ NaiveDerivable FrameClass.Base []
        ((PlusFormula.untl α (dstab φ)).imp (dstab (PlusFormula.untl α φ))) := by
  refine ⟨PlusFormula.top, phiPlus p, IsPurePast.top, phiPlus_pureFuture p, ?_⟩
  refine not_naiveDerivable_of_cRefuted PF pModel (pHist (-1)) 0 ?_
  intro h
  exact not_dstab_someFuture_phiPlus p (h (someFuture_dstab_phiPlus p))

/-! ## The axiom set of TM⁺ is non-redundant

Both pasting schemata are needed: neither follows from TM plus the S5/bridge set. -/

theorem plusAxiomSetNonRedundant (p : Atom) :
    (∃ φ ψ : PlusFormula, IsPureFuture φ ∧ IsPurePast ψ ∧
        ¬ NaiveDerivable FrameClass.Base []
          ((dstab φ).imp ((dstab ψ).imp (dstab (φ.and ψ))))) ∧
    (∃ α φ : PlusFormula, IsPurePast α ∧ IsPureFuture φ ∧
        ¬ NaiveDerivable FrameClass.Base []
          ((PlusFormula.untl α (dstab φ)).imp (dstab (PlusFormula.untl α φ)))) :=
  ⟨pasteNotNaiveDerivable p, untlPasteNotNaiveDerivable p⟩

end FormalSystem.Metalogic.Independence
