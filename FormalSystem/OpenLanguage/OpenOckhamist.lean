/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.OpenLanguage.OpenReversal
import FormalSystem.Semantics.IntNormalForm
import FormalSystem.PlusLanguage.PlusNonValidities

/-!
# The Ockhamist separating pair: `▷` is historical necessity, `⊡` is not

Branching-time (Ockhamist) historical necessity quantifies over the histories through the moment
of evaluation, and on a tree a moment determines its past: "same moment" and "same past"
coincide. Its characteristic interaction with tense is the principle **HN**,

```
Pα → □P◇α        what was the case is now necessarily such that it was possibly the case.
```

On a task frame the two notions come apart. The present world **state** fixes the alternatives of
the stability modal `⊡`, and two possible worlds through one state need share neither past nor
future; the alternatives that share the *past* are those of the open-future modal `▷`. This module
machine-checks the separation:

* `hnOpen α := Pα → ▷P▷̂α` is **valid over every task frame** (`hnOpen_openValid`), and so is the
  mixed form `Pα → ▷P⟐α` (`hnOpenMixed_openValid`);
* the stability transposition `hnStab p := Pp → ⊡P⟐p` is **refuted** on `sinkFrame`
  (`hnStab_refuted_sinkFrame`), a three-state integer-time frame that satisfies *every* field of
  `FrameOver` — *Compositionality*, *Seriality*, *Limit* and *Saturation*.

So an argument that relies on shared pasts transfers to `▷` and does not transfer to `⊡`.

**The countermodel.** `sinkFrame` has states `a`, `b`, `c` and the one-step relation "stay, or
fall into the sink `c`". The worlds `sinkHistA` and `sinkHistB` sit at `a`, resp. `b`, before time
`0` and at `c` from `0` on: they meet at the present state and share no past. With `p` true at `a`
only, `Pp` holds at `(sinkHistA, 0)`, yet from `sinkHistB` no earlier state is `a`-compatible: a
world through `b` is never at `a`.

**HN and AK12.** Given S5 for the necessity, HN is interderivable with the form `P□α → □Pα`
(from `α → □◇α` in one direction, from `◇□α → α` in the other). The stability analogue of that
second form is refuted in `PlusLanguage/PlusNonValidities.lean` (`refute_somePast_stab`).

## Main Definitions

- `hnOpen`, `hnOpenMixed`, `hnStab` — the three formulas
- `SinkState`, `sinkFrame`, `sinkHistA`, `sinkHistB`, `sinkModel` — the countermodel

## Main Results

- `hnOpen_openValid`, `hnOpenMixed_openValid`
- `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`, and the L⁺-level `not_plusValid_hnStab`
  (`hnStab p` is an L⁺ formula: `hnStab_eq_ofPlus`)

## References

* JPL paper `sub:RestrictedModalities` — the stability and open-future operators
* JPL paper `def:frame` — the four frame axioms `sinkFrame` satisfies
* [M. Reynolds, *An Axiomatization of Prior's Ockhamist Logic of Historical
  Necessity*][reynolds2003], the HN axiom
* [R. H. Thomason, *Combinations of Tense and Modality*][thomason1984], §4, Kamp's AK12
* `FormalSystem/Semantics/IntNormalForm.lean` — `FrameOver.ofStep`, `worldHistoryOfStepPath`
* `FormalSystem/PlusLanguage/PlusNonValidities.lean` — `refute_somePast_stab`, the sibling
  refutation

## Tags

open-language · historical-necessity · ockhamist · countermodel
-/

namespace FormalSystem.OpenLanguage

open FormalSystem.Syntax
open FormalSystem.PlusLanguage
open FormalSystem.OpenLanguage.OpenFormula
open FormalSystem.Semantics
open OpenTruth

/-! ## The three formulas -/

/-- **HN for the open-future modal**: `Pα → ▷P▷̂α`. -/
def hnOpen (α : OpenFormula) : OpenFormula := imp (somePast α) (ofut (somePast (dofut α)))

/-- The mixed form `Pα → ▷P⟐α`, with the stability dual in the consequent. Weaker than `hnOpen`,
because `|τ⟩_x ⊆ ⟨τ⟩_x`. -/
def hnOpenMixed (α : OpenFormula) : OpenFormula := imp (somePast α) (ofut (somePast (dstab α)))

/-- **HN transposed to the stability modal**: `Pp → ⊡P⟐p`. -/
def hnStab (p : Atom) : OpenFormula :=
  imp (somePast (atom p)) (stab (somePast (dstab (atom p))))

/-- `hnStab p` is an L⁺ formula: the refutation below is a fact about L⁺. -/
theorem hnStab_eq_ofPlus (p : Atom) :
    hnStab p = ofPlus (PlusFormula.imp (PlusFormula.somePast (PlusFormula.atom p))
      (PlusFormula.stab (PlusFormula.somePast (PlusFormula.dstab (PlusFormula.atom p))))) := rfl

/-! ## HN is valid for `▷` over every task frame -/

/-- **`Pα → ▷P▷̂α` is valid.** If `α` held at `s < t` in `σ`, and `ρ` agrees with `σ` up to `t`,
then at `s` the original `σ` is itself an open-future alternative of `ρ`: the two agree up to
`s ≤ t`. -/
theorem hnOpen_openValid (α : OpenFormula) : OpenValid (hnOpen α) := by
  refine OpenValid.of_forall fun F M σ t h ρ hag => ?_
  obtain ⟨s, hs, hα⟩ := (somePast_iff M σ t α).mp h
  exact (somePast_iff M ρ t _).mpr
    ⟨s, hs, (dofut_iff M ρ s α).mpr ⟨σ, fun r hr => (hag r (le_trans hr hs.le)).symm, hα⟩⟩

/-- **`Pα → ▷P⟐α` is valid**: the same witness, read through `|τ⟩_s ⊆ ⟨τ⟩_s`. -/
theorem hnOpenMixed_openValid (α : OpenFormula) : OpenValid (hnOpenMixed α) := by
  refine OpenValid.of_forall fun F M σ t h ρ hag => ?_
  obtain ⟨s, hs, hα⟩ := (somePast_iff M σ t α).mp h
  exact (somePast_iff M ρ t _).mpr
    ⟨s, hs, (dstab_iff M ρ s α).mpr ⟨σ, (hag s hs.le).symm, hα⟩⟩

/-! ## The countermodel -/

/-- The three world states of `sinkFrame`. -/
inductive SinkState : Type where
  | a | b | c
  deriving DecidableEq

instance : Nonempty SinkState := ⟨SinkState.a⟩

instance : Fintype SinkState where
  elems := {SinkState.a, SinkState.b, SinkState.c}
  complete := by intro x; cases x <;> simp

/-- **The sink frame**: over `ℤ`, one step either stays put or falls into the sink `c`. Every
field of `FrameOver` is discharged by `FrameOver.ofStep` — *Saturation* through the finite
carrier. An `abbrev`, so that `sinkFrame.WorldState` reduces to `SinkState`. -/
abbrev sinkFrame : FrameOver intOrder :=
  FrameOver.ofStep (fun x y : SinkState => x = y ∨ y = SinkState.c)
    (fun w => ⟨w, Or.inl rfl⟩) (fun w => ⟨w, Or.inl rfl⟩)

/-- The state function of `sinkHistA`: at `a` before `0`, at `c` from `0` on. -/
def sinkFunA : ℤ → SinkState := fun n => if n < 0 then SinkState.a else SinkState.c

/-- The state function of `sinkHistB`: at `b` before `0`, at `c` from `0` on. -/
def sinkFunB : ℤ → SinkState := fun n => if n < 0 then SinkState.b else SinkState.c

theorem sinkFunA_isStepPath : IsStepPath sinkFrame sinkFunA := by
  intro n
  refine (FrameOver.ofStep_step _ _ _ _ _).mpr ?_
  unfold sinkFunA
  by_cases h : n + 1 < 0
  · rw [if_pos (by omega : n < 0), if_pos h]; exact Or.inl rfl
  · rw [if_neg h]; exact Or.inr rfl

theorem sinkFunB_isStepPath : IsStepPath sinkFrame sinkFunB := by
  intro n
  refine (FrameOver.ofStep_step _ _ _ _ _).mpr ?_
  unfold sinkFunB
  by_cases h : n + 1 < 0
  · rw [if_pos (by omega : n < 0), if_pos h]; exact Or.inl rfl
  · rw [if_neg h]; exact Or.inr rfl

/-- The world through `a` that falls into the sink at time `0`. -/
def sinkHistA : WorldHistory sinkFrame.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath sinkFrame sinkFunA sinkFunA_isStepPath

/-- The world through `b` that falls into the sink at time `0`. It meets `sinkHistA` at the
present state `c` and shares none of its past. -/
def sinkHistB : WorldHistory sinkFrame.toTaskFrame :=
  FrameOver.worldHistoryOfStepPath sinkFrame sinkFunB sinkFunB_isStepPath

/-- Every atom is true at `a` and nowhere else. -/
def sinkModel : TaskModel sinkFrame.toTaskFrame where
  valuation := fun (x : SinkState) _ => x = SinkState.a

/-! ## HN fails for `⊡` -/

/-- **`Pp → ⊡P⟐p` is refuted on `sinkFrame`.** At `(sinkHistA, 0)` the antecedent holds (`p` at
time `-1`); `sinkHistB` is a stability alternative (both are at `c`); but at every `s < 0` the
world `sinkHistB` is at `b`, and no world through `b` is at `a`. -/
theorem hnStab_refuted_sinkFrame (p : Atom) :
    ¬ sinkFrame.toTaskFrame.OpenValidOn (hnStab p) := by
  intro hvalid
  have h := hvalid sinkModel sinkHistA 0
  have h1 : OpenTruthAt sinkModel sinkHistA 0 (somePast (atom p)) :=
    (somePast_iff _ _ _ _).mpr ⟨-1, by norm_num, by
      rw [atom_iff]; change sinkFunA (-1) = SinkState.a; simp [sinkFunA]⟩
  have h2 := h h1 sinkHistB (by change sinkFunA 0 = sinkFunB 0; simp [sinkFunA, sinkFunB])
  obtain ⟨s, hs, hd⟩ := (somePast_iff _ _ _ _).mp h2
  obtain ⟨η, he, hp⟩ := (dstab_iff _ _ _ _).mp hd
  rw [atom_iff] at hp
  have hp' : η.state s = SinkState.a := hp
  have he' : sinkFunB s = η.state s := he
  rw [hp'] at he'
  simp [sinkFunB, hs] at he'

/-- HN transposed to `⊡` is not L^▷-valid. -/
theorem not_openValid_hnStab (p : Atom) : ¬ OpenValid (hnStab p) :=
  fun h => hnStab_refuted_sinkFrame p (h sinkFrame.toTaskFrame trivial)

/-- HN transposed to `⊡` is not L⁺-valid: the refutation is a fact about the stability language,
transferred along `openValid_ofPlus_iff`. -/
theorem not_plusValid_hnStab (p : Atom) :
    ¬ PlusValid (PlusFormula.imp (PlusFormula.somePast (PlusFormula.atom p))
      (PlusFormula.stab (PlusFormula.somePast (PlusFormula.dstab (PlusFormula.atom p))))) :=
  fun h => not_openValid_hnStab p ((openValid_ofPlus_iff _).mpr h)

end FormalSystem.OpenLanguage
