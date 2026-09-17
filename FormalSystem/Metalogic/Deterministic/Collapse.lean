/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Deterministic.System
import FormalSystem.Metalogic.Deterministic.Erasure
import FormalSystem.Theorems.Propositional.Reasoning

/-!
# The syntactic collapse in TM⁺ + *Determined*

`detDerivable_iff_erasePlus`: the extended system derives `φ ↔ erasePlus φ` for **every**
`PlusFormula φ`. Together with the semantic collapse (`Metalogic/Deterministic/Erasure.lean`) and
the narrowed engines (`Metalogic/Deterministic/Engines.lean`), this is the last step of the
deterministic completeness proof: a TM derivation of the erasure is converted into an extended
derivation of the original (`detDerivable_of_derivable_erasePlus`).

## The three layers

1. **Propositional glue, imported by substitution.** The tree has a full propositional theorem
   layer over `Formula` (`Theorems/Propositional/`) and none over `PlusFormula`. Rather than
   rebuild it, five of its theorems are instantiated at reserved atoms and pushed into L⁺ by
   `detDerivable_substPlus` (`PlusLanguage/Substitution.lean`): `identity`, `bCombinator`,
   `theoremFlip`, `biImp`, `lceImp`, `rceImp`. That is the whole use of the substitution transfer
   here.
2. **Modal and temporal congruence, needing no substitution.** `PlusAxiom.modal_k_dist`,
   `.left_mono_until_G`, `.right_mono_until`, `.left_mono_since_H` and `.right_mono_since` are
   *already* stated at arbitrary `PlusFormula` arguments — that is exactly why `PlusAxiom`
   re-declares the TM schemata rather than embedding them — so `□`, `U` and `S` congruence are
   direct.
3. **The `⊡` case**, the only place *Determined* is used: `stab_t` gives `⊡φ → φ` on every frame,
   *Determined* gives `φ → ⊡φ`, and the two make `⊡φ ↔ φ` an extended-system theorem
   (`detStabIff`). The induction then discards the `⊡` and appeals to the hypothesis.

## Main Results

- the derived rules `detIffRefl`, `detIffIntro`, `detIffMp`, `detIffMpr`, `detImpTrans`,
  `detIffTrans`, `detImpCongr`, `detBoxCongr`, `detUntlCongr`, `detSnceCongr`, `detStabIff`
- `detDerivable_iff_erasePlus` — the collapse
- `detDerivable_of_derivable_erasePlus` — the transport a completeness proof consumes

## Why the derived rules are stated at the `Prop` level

`DetDerivable` is `Nonempty`, so every rule below is a `theorem` combining `Nonempty`s rather
than a `def` building a tree. Nothing downstream inspects a derivation, and the `Prop` level
keeps the noncomputable `Theorems/` imports (`biImp` routes through `deductionTheorem`) from
leaking a computability obligation.

## References

* `FormalSystem/PlusLanguage/Substitution.lean` — the transfer that imports layer 1
* `FormalSystem/Theorems/Propositional/` — the source of the six imported theorems

## Tags

collapse · determinism · plus-language · substitution · app:deterministic
-/

namespace FormalSystem.Metalogic.Deterministic

open FormalSystem.Syntax
open FormalSystem.ProofSystem (FrameClass)
open FormalSystem.PlusLanguage

/-! ## Primitive Prop-level rules -/

variable {fc : FrameClass}

/-- Modus ponens at the `Prop` level. -/
theorem detMp {φ ψ : PlusFormula} (h1 : DetDerivable fc [] (φ.imp ψ))
    (h2 : DetDerivable fc [] φ) : DetDerivable fc [] ψ :=
  h1.elim fun d1 => h2.elim fun d2 => ⟨.modus_ponens [] φ ψ d1 d2⟩

/-- A TM⁺ axiom instance is an extended-system theorem, at any class above its minimum. -/
theorem detPlusAxiom {φ : PlusFormula} (h : PlusAxiom φ) (hb : h.minFrameClass ≤ fc) :
    DetDerivable fc [] φ :=
  ⟨.axiom [] φ (DetAxiom.ofPlus h) hb⟩

/-- Necessitation at the `Prop` level. -/
theorem detNec {φ : PlusFormula} (h : DetDerivable fc [] φ) :
    DetDerivable fc [] (PlusFormula.box φ) :=
  h.elim fun d => ⟨.necessitation φ d⟩

/-- Temporal necessitation at the `Prop` level. -/
theorem detTNec {φ : PlusFormula} (h : DetDerivable fc [] φ) :
    DetDerivable fc [] (PlusFormula.allFuture φ) :=
  h.elim fun d => ⟨.temporal_necessitation φ d⟩

/-- **Past temporal necessitation**, derived: from `⊢ φ` conclude `⊢ Hφ`. There is no `H`-rule in
the system — the past half of every temporal principle is obtained by temporal duality, exactly as
in TM. Three rule applications: dualize, `G`-necessitate, dualize back, the last step landing on
`Hφ` because `reflectTime` is an involution. -/
theorem detHNec {φ : PlusFormula} (h : DetDerivable fc [] φ) :
    DetDerivable fc [] (PlusFormula.allPast φ) := by
  have h1 : DetDerivable fc [] φ.reflectTime := h.elim fun d => ⟨.time_reflection φ d⟩
  have h3 : DetDerivable fc [] (PlusFormula.allFuture φ.reflectTime).reflectTime :=
    (detTNec h1).elim fun d => ⟨.time_reflection _ d⟩
  rwa [PlusFormula.reflect_time_all_future, PlusFormula.reflect_time_involution] at h3

/-! ## Layer 1: propositional glue, imported by substitution

The reserved atoms and the substitution that reads its values off their fresh indices. Nothing
outside this section mentions them: they exist only so that a TM theorem stated at *arbitrary*
`Formula` arguments can be instantiated once and then pushed into L⁺ at `PlusFormula` arguments.
-/

section Glue

/-- The reserved atoms of the substitution layer. -/
private def substAtom (n : Nat) : Atom := ⟨"tmDetCollapse", some n⟩

/-- The L formula consisting of the `n`-th reserved atom. -/
private def substVar (n : Nat) : Formula := Formula.atom (substAtom n)

/-- The substitution sending the `n`-th reserved atom to `f n`. -/
private def substOf (f : Nat → PlusFormula) : Atom → PlusFormula :=
  fun a => f (a.freshIndex.getD 0)

@[simp] private theorem substPlus_substVar (f : Nat → PlusFormula) (n : Nat) :
    substPlus (substOf f) (substVar n) = f n := rfl

/-- `⊢ φ → φ`, imported from `Theorems.Combinators.identity`. -/
theorem detIdentity (α : PlusFormula) : DetDerivable fc [] (α.imp α) :=
  detDerivable_substPlus (substOf fun _ => α)
    ⟨FormalSystem.Theorems.Combinators.identity (substVar 0)⟩

/-- `⊢ (ψ → χ) → ((φ → ψ) → (φ → χ))`, imported from `Theorems.Combinators.bCombinator`. -/
theorem detBComb (α β γ : PlusFormula) :
    DetDerivable fc [] ((β.imp γ).imp ((α.imp β).imp (α.imp γ))) :=
  detDerivable_substPlus (substOf fun n => match n with | 0 => α | 1 => β | _ => γ)
    ⟨FormalSystem.Theorems.Combinators.bCombinator
      (A := substVar 0) (B := substVar 1) (C := substVar 2)⟩

/-- `⊢ (φ → (ψ → χ)) → (ψ → (φ → χ))`, imported from `Theorems.Combinators.theoremFlip`. -/
theorem detFlip (α β γ : PlusFormula) :
    DetDerivable fc [] ((α.imp (β.imp γ)).imp (β.imp (α.imp γ))) :=
  detDerivable_substPlus (substOf fun n => match n with | 0 => α | 1 => β | _ => γ)
    ⟨FormalSystem.Theorems.Combinators.theoremFlip
      (A := substVar 0) (B := substVar 1) (C := substVar 2)⟩

/-- `⊢ (φ → ψ) → ((ψ → φ) → (φ ↔ ψ))`, imported from `Theorems.Propositional.biImp`. -/
theorem detBiImp (α β : PlusFormula) :
    DetDerivable fc [] ((α.imp β).imp ((β.imp α).imp (α.iff β))) :=
  detDerivable_substPlus (substOf fun n => match n with | 0 => α | _ => β)
    ⟨FormalSystem.Theorems.Propositional.biImp (substVar 0) (substVar 1)⟩

/-- `⊢ (φ ∧ ψ) → φ`, imported from `Theorems.Propositional.lceImp`. -/
theorem detAndLeft (α β : PlusFormula) : DetDerivable fc [] ((α.and β).imp α) :=
  detDerivable_substPlus (substOf fun n => match n with | 0 => α | _ => β)
    ⟨FormalSystem.Theorems.Propositional.lceImp (substVar 0) (substVar 1)⟩

/-- `⊢ (φ ∧ ψ) → ψ`, imported from `Theorems.Propositional.rceImp`. -/
theorem detAndRight (α β : PlusFormula) : DetDerivable fc [] ((α.and β).imp β) :=
  detDerivable_substPlus (substOf fun n => match n with | 0 => α | _ => β)
    ⟨FormalSystem.Theorems.Propositional.rceImp (substVar 0) (substVar 1)⟩

end Glue

/-! ## Derived implication and biconditional rules -/

/-- Transitivity of implication, as a rule. -/
theorem detImpTrans {α β γ : PlusFormula} (h1 : DetDerivable fc [] (α.imp β))
    (h2 : DetDerivable fc [] (β.imp γ)) : DetDerivable fc [] (α.imp γ) :=
  detMp (detMp (detBComb α β γ) h2) h1

/-- Introduction of `↔` from the two implications. -/
theorem detIffIntro {α β : PlusFormula} (h1 : DetDerivable fc [] (α.imp β))
    (h2 : DetDerivable fc [] (β.imp α)) : DetDerivable fc [] (α.iff β) :=
  detMp (detMp (detBiImp α β) h1) h2

/-- Left elimination of `↔`. -/
theorem detIffMp {α β : PlusFormula} (h : DetDerivable fc [] (α.iff β)) :
    DetDerivable fc [] (α.imp β) :=
  detMp (detAndLeft (α.imp β) (β.imp α)) h

/-- Right elimination of `↔`. -/
theorem detIffMpr {α β : PlusFormula} (h : DetDerivable fc [] (α.iff β)) :
    DetDerivable fc [] (β.imp α) :=
  detMp (detAndRight (α.imp β) (β.imp α)) h

/-- Reflexivity of `↔`. -/
theorem detIffRefl (α : PlusFormula) : DetDerivable fc [] (α.iff α) :=
  detIffIntro (detIdentity α) (detIdentity α)

/-- Symmetry of `↔`. -/
theorem detIffSymm {α β : PlusFormula} (h : DetDerivable fc [] (α.iff β)) :
    DetDerivable fc [] (β.iff α) :=
  detIffIntro (detIffMpr h) (detIffMp h)

/-- Transitivity of `↔`. -/
theorem detIffTrans {α β γ : PlusFormula} (h1 : DetDerivable fc [] (α.iff β))
    (h2 : DetDerivable fc [] (β.iff γ)) : DetDerivable fc [] (α.iff γ) :=
  detIffIntro (detImpTrans (detIffMp h1) (detIffMp h2))
    (detImpTrans (detIffMpr h2) (detIffMpr h1))

/-! ## Congruence -/

/-- **Congruence at `→`.** Built from `bCombinator` twice, with `theoremFlip` supplying the
argument order the first composition needs. -/
theorem detImpCongr {α α' β β' : PlusFormula} (h1 : DetDerivable fc [] (α.iff α'))
    (h2 : DetDerivable fc [] (β.iff β')) :
    DetDerivable fc [] ((α.imp β).iff (α'.imp β')) := by
  have fwd : DetDerivable fc [] ((α.imp β).imp (α'.imp β')) := by
    have step1 : DetDerivable fc [] ((α.imp β).imp (α'.imp β)) :=
      detMp (detMp (detFlip (α.imp β) (α'.imp α) (α'.imp β)) (detBComb α' α β))
        (detIffMpr h1)
    have step2 : DetDerivable fc [] ((α'.imp β).imp (α'.imp β')) :=
      detMp (detBComb α' β β') (detIffMp h2)
    exact detImpTrans step1 step2
  have bwd : DetDerivable fc [] ((α'.imp β').imp (α.imp β)) := by
    have step1 : DetDerivable fc [] ((α'.imp β').imp (α.imp β')) :=
      detMp (detMp (detFlip (α'.imp β') (α.imp α') (α.imp β')) (detBComb α α' β'))
        (detIffMp h1)
    have step2 : DetDerivable fc [] ((α.imp β').imp (α.imp β)) :=
      detMp (detBComb α β' β) (detIffMpr h2)
    exact detImpTrans step1 step2
  exact detIffIntro fwd bwd

/-- **Congruence at `□`**, by necessitation and `modal_k_dist` in each direction. -/
theorem detBoxCongr {α β : PlusFormula} (h : DetDerivable fc [] (α.iff β)) :
    DetDerivable fc [] ((PlusFormula.box α).iff (PlusFormula.box β)) := by
  have fwd : DetDerivable fc [] ((PlusFormula.box α).imp (PlusFormula.box β)) :=
    detMp (detPlusAxiom (PlusAxiom.modal_k_dist α β) (FrameClass.base_le fc))
      (detNec (detIffMp h))
  have bwd : DetDerivable fc [] ((PlusFormula.box β).imp (PlusFormula.box α)) :=
    detMp (detPlusAxiom (PlusAxiom.modal_k_dist β α) (FrameClass.base_le fc))
      (detNec (detIffMpr h))
  exact detIffIntro fwd bwd

/-- **Congruence at `U`**, by temporal necessitation with `left_mono_until_G` on the guard and
`right_mono_until` on the event, composed. -/
theorem detUntlCongr {ψ ψ' α α' : PlusFormula} (hg : DetDerivable fc [] (ψ.iff ψ'))
    (he : DetDerivable fc [] (α.iff α')) :
    DetDerivable fc [] ((PlusFormula.untl ψ α).iff (PlusFormula.untl ψ' α')) := by
  have fwd : DetDerivable fc [] ((PlusFormula.untl ψ α).imp (PlusFormula.untl ψ' α')) := by
    have hguard : DetDerivable fc [] ((PlusFormula.untl ψ α).imp (PlusFormula.untl ψ' α)) :=
      detMp (detPlusAxiom (PlusAxiom.left_mono_until_G ψ ψ' α) (FrameClass.base_le fc))
        (detTNec (detIffMp hg))
    have hevent : DetDerivable fc [] ((PlusFormula.untl ψ' α).imp (PlusFormula.untl ψ' α')) :=
      detMp (detPlusAxiom (PlusAxiom.right_mono_until α α' ψ') (FrameClass.base_le fc))
        (detTNec (detIffMp he))
    exact detImpTrans hguard hevent
  have bwd : DetDerivable fc [] ((PlusFormula.untl ψ' α').imp (PlusFormula.untl ψ α)) := by
    have hguard : DetDerivable fc [] ((PlusFormula.untl ψ' α').imp (PlusFormula.untl ψ α')) :=
      detMp (detPlusAxiom (PlusAxiom.left_mono_until_G ψ' ψ α') (FrameClass.base_le fc))
        (detTNec (detIffMpr hg))
    have hevent : DetDerivable fc [] ((PlusFormula.untl ψ α').imp (PlusFormula.untl ψ α)) :=
      detMp (detPlusAxiom (PlusAxiom.right_mono_until α' α ψ) (FrameClass.base_le fc))
        (detTNec (detIffMpr he))
    exact detImpTrans hguard hevent
  exact detIffIntro fwd bwd

/-- **Congruence at `S`**, the past mirror of `detUntlCongr`; the temporal-necessitation step is
the same rule, because `left_mono_since_H` and `right_mono_since` take `H`-guarded premises and
`Gφ`'s derivation gives `Hφ`'s by temporal duality — which is already inside the axioms here, so
the derivation reads exactly as the future one with `H` in place of `G`. -/
theorem detSnceCongr {ψ ψ' α α' : PlusFormula} (hg : DetDerivable fc [] (ψ.iff ψ'))
    (he : DetDerivable fc [] (α.iff α')) :
    DetDerivable fc [] ((PlusFormula.snce ψ α).iff (PlusFormula.snce ψ' α')) := by
  have fwd : DetDerivable fc [] ((PlusFormula.snce ψ α).imp (PlusFormula.snce ψ' α')) := by
    have hguard : DetDerivable fc [] ((PlusFormula.snce ψ α).imp (PlusFormula.snce ψ' α)) :=
      detMp (detPlusAxiom (PlusAxiom.left_mono_since_H ψ ψ' α) (FrameClass.base_le fc))
        (detHNec (detIffMp hg))
    have hevent : DetDerivable fc [] ((PlusFormula.snce ψ' α).imp (PlusFormula.snce ψ' α')) :=
      detMp (detPlusAxiom (PlusAxiom.right_mono_since α α' ψ') (FrameClass.base_le fc))
        (detHNec (detIffMp he))
    exact detImpTrans hguard hevent
  have bwd : DetDerivable fc [] ((PlusFormula.snce ψ' α').imp (PlusFormula.snce ψ α)) := by
    have hguard : DetDerivable fc [] ((PlusFormula.snce ψ' α').imp (PlusFormula.snce ψ α')) :=
      detMp (detPlusAxiom (PlusAxiom.left_mono_since_H ψ' ψ α') (FrameClass.base_le fc))
        (detHNec (detIffMpr hg))
    have hevent : DetDerivable fc [] ((PlusFormula.snce ψ α').imp (PlusFormula.snce ψ α)) :=
      detMp (detPlusAxiom (PlusAxiom.right_mono_since α' α ψ) (FrameClass.base_le fc))
        (detHNec (detIffMpr he))
    exact detImpTrans hguard hevent
  exact detIffIntro fwd bwd

/-! ## The `⊡` case -/

/-- **`⊡φ ↔ φ` is an extended-system theorem.** (⇒) is `stab_t`, valid on every frame; (⇐) is
*Determined*, the one axiom this system adds. This is the only place *Determined* is used in the
collapse. -/
theorem detStabIff (α : PlusFormula) :
    DetDerivable fc [] ((PlusFormula.stab α).iff α) :=
  detIffIntro (detPlusAxiom (PlusAxiom.stab_t α) (FrameClass.base_le fc))
    (detDerivable_determined α)

/-! ## The collapse -/

/--
**The syntactic collapse.** TM⁺ + *Determined* derives `φ ↔ erasePlus φ` for every `PlusFormula`,
at every frame class.

By induction on `φ`: `atom` and `bot` are reflexivity, `imp`/`box`/`untl`/`snce` are the four
congruence rules, and `stab` composes `detStabIff` with the induction hypothesis — which is where
the erasure's defining clause `erasePlus (⊡φ) = erasePlus φ` is discharged.
-/
theorem detDerivable_iff_erasePlus (φ : PlusFormula) :
    DetDerivable fc [] (φ.iff (ofFormula (erasePlus φ))) := by
  induction φ with
  | atom p => exact detIffRefl _
  | bot => exact detIffRefl _
  | imp φ ψ ihφ ihψ => exact detImpCongr ihφ ihψ
  | box φ ih => exact detBoxCongr ih
  | untl ψ φ ihψ ihφ => exact detUntlCongr ihψ ihφ
  | snce ψ φ ihψ ihφ => exact detSnceCongr ihψ ihφ
  | stab φ ih => exact detIffTrans (detStabIff φ) ih

/--
**The transport a completeness proof consumes.** A TM derivation of `erasePlus φ` yields an
extended-system derivation of `φ` itself: embed the TM derivation
(`detDerivable_of_derivable`), then cross the collapse right-to-left.
-/
theorem detDerivable_of_derivable_erasePlus {φ : PlusFormula}
    (h : ProofSystem.Derivable fc [] (erasePlus φ)) : DetDerivable fc [] φ :=
  detMp (detIffMpr (detDerivable_iff_erasePlus (fc := fc) φ)) (detDerivable_of_derivable h)

end FormalSystem.Metalogic.Deterministic
