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

- `hnOpen`, `hnOpenMixed`, `hnStab` — the three formulas; `hnOpenMirror`, `hnStabMirror` — their
  time reflections
- `SinkState`, `sinkFrame`, `sinkHistA`, `sinkHistB`, `sinkModel` — the countermodel

## Main Results

- `hnOpen_openValid`, `hnOpenMixed_openValid`
- `hnStab_refuted_sinkFrame`, `not_openValid_hnStab`, and the L⁺-level `not_plusValid_hnStab`
  (`hnStab p` is an L⁺ formula: `hnStab_eq_ofPlus`)
- **The open-past mirror**, by time reflection: `hnOpenMirror_openValid`, `openValid_hnOpenPast`
  (`Fα → ◁F◁̂α` at every `α`), and `not_openValid_hnStabMirror` (`Fp → ⊡F⟐p` is not valid)
- **The strength ordering is strict**: `not_openValid_box_of_stab`, `not_openValid_stab_of_ofut`,
  `not_openValid_stab_of_opast`; and `▷`, `◁` are **incomparable**: `not_openValid_opast_of_ofut`,
  `not_openValid_ofut_of_opast`
- The five L⁺ refutations transferred to L^▷: `not_openValid_stab_box`,
  `not_openValid_allFuture_stab`, `not_openValid_stab_allFuture_past`, `not_openValid_determined`,
  `not_openValid_somePast_stab`

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
`s ≤ t`.

Paper: — (formalization-native; the manuscript gives `▷` a truth clause and supplies no logic
for the restricted modals) -/
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
world `sinkHistB` is at `b`, and no world through `b` is at `a`.

Paper: — (formalization-native; it is what separates the stability modal from Ockhamist
historical necessity) -/
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
  fun h => hnStab_refuted_sinkFrame p (h sinkFrame.toTaskFrame inferInstance)

/-- HN transposed to `⊡` is not L⁺-valid: the refutation is a fact about the stability language,
transferred along `openValid_ofPlus_iff`. -/
theorem not_plusValid_hnStab (p : Atom) :
    ¬ PlusValid (PlusFormula.imp (PlusFormula.somePast (PlusFormula.atom p))
      (PlusFormula.stab (PlusFormula.somePast (PlusFormula.dstab (PlusFormula.atom p))))) :=
  fun h => not_openValid_hnStab p ((openValid_ofPlus_iff _).mpr h)

/-! ## The open-past mirror

Time reflection exchanges `▷` with `◁` and `P` with `F`, and fixes `⊡`. Since validity is closed
under it (`openValid_reflectTime`), the separating pair has a mirror image: the principle
`Fα → ◁F◁̂α` is valid, and its stability transposition `Fp → ⊡F⟐p` is not. -/

/-- The time reflection of `hnOpen`. -/
def hnOpenMirror (α : OpenFormula) : OpenFormula := (hnOpen α).reflectTime

/-- The time reflection of `hnStab`. -/
def hnStabMirror (p : Atom) : OpenFormula := (hnStab p).reflectTime

/-- `hnOpenMirror α` is `Fα' → ◁F◁̂α'` at `α' := α.reflectTime`. -/
theorem hnOpenMirror_eq (α : OpenFormula) :
    hnOpenMirror α =
      imp (someFuture α.reflectTime) (opast (someFuture (dopast α.reflectTime))) := rfl

/-- `hnStabMirror p` is `Fp → ⊡F⟐p`. -/
theorem hnStabMirror_eq (p : Atom) :
    hnStabMirror p = imp (someFuture (atom p)) (stab (someFuture (dstab (atom p)))) := rfl

/-- **The mirrored principle is valid**, by time reflection of `hnOpen_openValid`.

Paper: — (formalization-native; the open-past mirror of `hnOpen_openValid`) -/
theorem hnOpenMirror_openValid (α : OpenFormula) : OpenValid (hnOpenMirror α) :=
  openValid_reflectTime _ (hnOpen_openValid α)

/-- **`Fα → ◁F◁̂α` is valid at every `α`**: `hnOpenMirror_openValid` at `α.reflectTime`, since
`reflectTime` is an involution. -/
theorem openValid_hnOpenPast (α : OpenFormula) :
    OpenValid (imp (someFuture α) (opast (someFuture (dopast α)))) := by
  have h := hnOpenMirror_openValid α.reflectTime
  rwa [hnOpenMirror_eq, reflect_time_involution] at h

/-- **The mirrored stability transposition `Fp → ⊡F⟐p` is not valid**: were it valid, its time
reflection `hnStab p` would be. -/
theorem not_openValid_hnStabMirror (p : Atom) : ¬ OpenValid (hnStabMirror p) := by
  intro h
  have h' := openValid_reflectTime _ h
  rw [hnStabMirror, reflect_time_involution] at h'
  exact not_openValid_hnStab p h'

/-! ## The strength ordering is strict, and `▷` and `◁` are incomparable

`□ ⟹ ⊡ ⟹ ▷` and `⊡ ⟹ ◁` are validities (`OpenLanguage/OpenValidity.lean`). Each converse
fails, and neither of `▷`, `◁` implies the other. Every countermodel is on the permissive frame
`NF` over `ℤ` with the valuation "true at state `0` only", evaluated at the constantly-`0` world
at time `0`, in the house style of `PlusLanguage/PlusNonValidities.lean`. -/

/-- **`⊡p → □p` fails**: the constantly-`1` world is not through the present state. -/
theorem not_openValid_box_of_stab (p : Atom) :
    ¬ OpenValid (imp (stab (atom p)) (box (atom p))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : OpenTruthAt natModel (natHist fun _ => 0) 0 (stab (atom p)) := by
    intro ρ hs
    exact hs.symm
  have hB := hv hA (natHist fun _ => 1)
  have v' : (1 : ℕ) = 0 := hB
  exact one_ne_zero v'

/-- **`▷Pp → ⊡Pp` fails**: a world through the present state may have a different past. -/
theorem not_openValid_stab_of_ofut (p : Atom) :
    ¬ OpenValid (imp (ofut (somePast (atom p))) (stab (somePast (atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : OpenTruthAt natModel (natHist fun _ => 0) 0 (ofut (somePast (atom p))) := by
    intro ρ hag
    refine (somePast_iff _ _ _ _).mpr ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), ?_⟩
    have h1 := hag (-1 : ℤ) (by decide : (-1 : ℤ) ≤ 0)
    change (0 : ℕ) = ρ.state (-1 : ℤ) at h1
    change ρ.state (-1 : ℤ) = (0 : ℕ)
    exact h1.symm
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  obtain ⟨s, hs, hat⟩ := (somePast_iff _ _ _ _).mp hB
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/-- **`◁Fp → ⊡Fp` fails**: a world through the present state may have a different future. -/
theorem not_openValid_stab_of_opast (p : Atom) :
    ¬ OpenValid (imp (opast (someFuture (atom p))) (stab (someFuture (atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : OpenTruthAt natModel (natHist fun _ => 0) 0 (opast (someFuture (atom p))) := by
    intro ρ hag
    refine (someFuture_iff _ _ _ _).mpr ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_⟩
    have h1 := hag (1 : ℤ) (by decide : (0 : ℤ) ≤ 1)
    change (0 : ℕ) = ρ.state (1 : ℤ) at h1
    change ρ.state (1 : ℤ) = (0 : ℕ)
    exact h1.symm
  have hB := hv hA (natHist fun s => if 0 < s then 1 else 0)
    (by change (0 : ℕ) = (if (0 : ℤ) < 0 then 1 else 0); simp)
  obtain ⟨s, hs, hat⟩ := (someFuture_iff _ _ _ _).mp hB
  have hs' : (0 : ℤ) < s := hs
  have v' : (if (0 : ℤ) < s then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/-- **`▷Pp → ◁Pp` fails**: a world that shares the future need not share the past. -/
theorem not_openValid_opast_of_ofut (p : Atom) :
    ¬ OpenValid (imp (ofut (somePast (atom p))) (opast (somePast (atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : OpenTruthAt natModel (natHist fun _ => 0) 0 (ofut (somePast (atom p))) := by
    intro ρ hag
    refine (somePast_iff _ _ _ _).mpr ⟨(-1 : ℤ), (by decide : (-1 : ℤ) < 0), ?_⟩
    have h1 := hag (-1 : ℤ) (by decide : (-1 : ℤ) ≤ 0)
    change (0 : ℕ) = ρ.state (-1 : ℤ) at h1
    change ρ.state (-1 : ℤ) = (0 : ℕ)
    exact h1.symm
  have hB := hv hA (natHist fun s => if s < 0 then 1 else 0) (by
    intro s hs
    have hs' : ¬ (s : ℤ) < 0 := not_lt.mpr hs
    change (0 : ℕ) = (if (s : ℤ) < 0 then 1 else 0)
    rw [if_neg hs'])
  obtain ⟨s, hs, hat⟩ := (somePast_iff _ _ _ _).mp hB
  have hs' : (s : ℤ) < 0 := hs
  have v' : (if (s : ℤ) < 0 then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/-- **`◁Fp → ▷Fp` fails**: a world that shares the past need not share the future. -/
theorem not_openValid_ofut_of_opast (p : Atom) :
    ¬ OpenValid (imp (opast (someFuture (atom p))) (ofut (someFuture (atom p)))) := by
  intro h
  have hv := h.apply NF natModel (natHist fun _ => 0) 0
  have hA : OpenTruthAt natModel (natHist fun _ => 0) 0 (opast (someFuture (atom p))) := by
    intro ρ hag
    refine (someFuture_iff _ _ _ _).mpr ⟨(1 : ℤ), (by decide : (0 : ℤ) < 1), ?_⟩
    have h1 := hag (1 : ℤ) (by decide : (0 : ℤ) ≤ 1)
    change (0 : ℕ) = ρ.state (1 : ℤ) at h1
    change ρ.state (1 : ℤ) = (0 : ℕ)
    exact h1.symm
  have hB := hv hA (natHist fun s => if 0 < s then 1 else 0) (by
    intro s hs
    have hs' : ¬ (0 : ℤ) < s := not_lt.mpr hs
    change (0 : ℕ) = (if (0 : ℤ) < s then 1 else 0)
    rw [if_neg hs'])
  obtain ⟨s, hs, hat⟩ := (someFuture_iff _ _ _ _).mp hB
  have hs' : (0 : ℤ) < s := hs
  have v' : (if (0 : ℤ) < s then (1 : ℕ) else 0) = 0 := hat
  rw [if_pos hs'] at v'
  exact one_ne_zero v'

/-! ## The L⁺ refutations, transferred

The five refutations of `PlusLanguage/PlusNonValidities.lean` bound the `⊡` axiom set from above.
Each transfers to L^▷ in one line through `openValid_ofPlus_iff`: extending the language by `▷`
and `◁` validates none of them. -/

/-- `⊡p → □⊡p` is not L^▷-valid. -/
theorem not_openValid_stab_box (p : Atom) :
    ¬ OpenValid (ofPlus (.imp (.stab (.atom p)) (.box (.stab (.atom p))))) :=
  fun h => refute_stab_box p ((openValid_ofPlus_iff _).mp h)

/-- `G⊡p → ⊡Gp` is not L^▷-valid. -/
theorem not_openValid_allFuture_stab (p : Atom) :
    ¬ OpenValid (ofPlus (.imp (PlusFormula.allFuture (.stab (.atom p)))
      (.stab (PlusFormula.allFuture (.atom p))))) :=
  fun h => refute_allFuture_stab p ((openValid_ofPlus_iff _).mp h)

/-- `⊡GPp → G⊡Pp` is not L^▷-valid. -/
theorem not_openValid_stab_allFuture_past (p : Atom) :
    ¬ OpenValid (ofPlus (.imp (.stab (PlusFormula.allFuture (PlusFormula.somePast (.atom p))))
      (PlusFormula.allFuture (.stab (PlusFormula.somePast (.atom p)))))) :=
  fun h => refute_stab_allFuture_past p ((openValid_ofPlus_iff _).mp h)

/-- `Fp → ⊡Fp` is not L^▷-valid. -/
theorem not_openValid_determined (p : Atom) :
    ¬ OpenValid (ofPlus (.imp (PlusFormula.someFuture (.atom p))
      (.stab (PlusFormula.someFuture (.atom p))))) :=
  fun h => refute_determined p ((openValid_ofPlus_iff _).mp h)

/-- `P⊡p → ⊡Pp` is not L^▷-valid. -/
theorem not_openValid_somePast_stab (p : Atom) :
    ¬ OpenValid (ofPlus (.imp (PlusFormula.somePast (.stab (.atom p)))
      (.stab (PlusFormula.somePast (.atom p))))) :=
  fun h => refute_somePast_stab p ((openValid_ofPlus_iff _).mp h)

end FormalSystem.OpenLanguage
