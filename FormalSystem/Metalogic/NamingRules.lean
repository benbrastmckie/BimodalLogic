/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Semantics.Frames.TranslationProduct
import FormalSystem.PlusLanguage.PlusValidity

/-!
# Naming rules: soundness of the irreflexivity and clock rules over L⁺

A **naming rule** is a non-orthodox inference rule: it licenses inferring `φ` from
`A(q) → φ` for a sentence letter `q` that does not occur in `φ`, where `A(q)` says that `q`
behaves like a *name* for the time of evaluation. The letter is auxiliary — it is discharged by
the rule and never appears in the conclusion — which is what makes such a rule sound without
`A(q)` being valid.

## Why a time can be named inside a stability cluster but not globally

No L⁺ formula can be true at exactly one time of every history: truth at a time is evaluated
against a valuation on world states, and a world state may recur. What *can* be arranged is a
model in which `q` holds at exactly one time of each history and in which that time is the same
across the whole stability cluster of the present state — the set `⟨τ⟩_x` of histories agreeing
with `τ` at `x` (`def:BLstar-semantics`). The translation product
(`Semantics/Frames/TranslationProduct.lean`) supplies exactly such a model: its states carry a
clock reading, every task advances the clock by its own duration (`clock_eq`), and `q` is
interpreted as "the clock reads zero". The clock is rigid under `⊡` because two histories
through one product state read the same clock there.

So the device is: move to the translation product, name the time with the clock, run the premise
there, then forget `q` (`plusTruthAt_congr_of_fresh`) and project back along
`HistMorphism.plus_invariance` / `plus_invariance`. The letter is auxiliary and the product is a
proof device, never an intended model — the standing caveat of the translation-product module
applies here unchanged.

## Main Definitions

- `Fresh q φ` — the atom `q` does not occur in `φ`
- `clockModel` — the product valuation that reads `q` as "the clock is zero"
- `nm`, `once`, `rigid`, `clockAnte` — the clock rule's antecedent, as L⁺ formulas

## Main Results

- `plusTruthAt_congr_of_fresh` — L⁺ truth is unchanged by a valuation change at a fresh atom only
- `plusTruthAt_nm`, `plusTruthAt_once`, `plusTruthAt_rigid`, `plusTruthAt_clockAnte` — the clock
  valuation satisfies the antecedent on every history of the product
- `clock_irr_sound` — **soundness of the clock rule**: an atom may be assumed to hold at exactly
  one time of every history, with that time rigid under `⊡`
- `irr_sound` — **soundness of Gabbay's plain irreflexivity rule**, as a corollary

## Not formalized

No completeness, decidability or axiomatizability claim is made or implied. These are soundness
facts about two rules; what an axiomatization built on them would prove is not settled here.

### The Auxiliary-Atoms expansion, and where it stops

Reynolds' *Auxiliary Atoms* rule has a semantic core that the two rules above do not reach: above
any point of any model there should be a two-way-bounded-morphic preimage whose forward cone is a
**tree**, carrying a finite-state-machine labelling that each step advances. The preimage is the
forward-cone unravelling: one verbatim copy of the frame, plus one copy of each state *per path
by which it is reached*, so that every copy keeps all predecessors (whence the projection is a
two-way bounded morphism, `Semantics/HistoryMorphism.lean`'s `TwoWayBounded`) while inside the
unravelled part each state has exactly one predecessor (whence the tree).

That transfer is **not** formalized here, and the obstruction is specific — but it is narrower
than presenting the unravelled frame at all. Over a digraph the unravelling is immediate: the
path record is a finite list and one relational step extends it by one state. A task frame's
relation is not a digraph's — it is indexed by every duration. `FrameOver.ofReflective` presents
a frame from a reflective relation with **no** `def:frame` constraint, so the unravelled relation
can be wrapped as a `FrameOver` for free; it is `FrameOver.ofReflectiveRegular` that demands
*Compositionality*, *Seriality*, *Limit* and *Saturation*, and reasoning from that constructor is
what made all four look required. The first three are reachable over discrete time: the durations
are exactly the multiples of one step there, so "number of steps" is a function of the duration,
`k = k₁ + k₂` subdivides, and composing single steps into the task at an arbitrary pair of times
is what `TwoWayBounded.exists_histMorphism_of_isZTime_of_constraints` already does — over a base
frame carrying **no** constraint at all, and consuming *Compositionality*, *Seriality* and
*Limit* of the source and nothing more. So the lift itself does not need *Saturation* on either
side.

What *Saturation* is still needed for is **class membership**, not the lift.
`ProofSystem.FrameClass.Sat` demands `FrameOver.IsRegular` of a frame-class member, so the
unravelled frame has to be regular to count as a model of record — and that is where the
obligation below bites. The direction that does survive for free is the other one:
`Semantics.exists_orientedForest_cover_of_constraints` transfers L⁺ truth *off* a merely
compositional, serial, limit base onto a regular oriented-forest cover, with
`Semantics.StateTopology.SeparatingFrame.exists_nonSaturated_base_orientedForest_cover` as a
concrete non-saturated base it applies to. The *Saturation* obligation at the unravelled carrier
is

```
∀ S : Set (Set (W ⊕ (W × List W))), DirectedFamily S →
  (∀ s ∈ S, (IsFiber R s ∨ IsSegment R s) ∧ s.Nonempty) → (⋂₀ S).Nonempty
```

and, read as the class-membership obligation it is, none of the three routes this tree has to it
applies: `TaskFrame.saturation_of_finite` binds
`[Finite W]`, while the unravelled carrier is infinite whenever the base carrier is (and
`FrameOver.worldNonempty` makes the base carrier nonempty for every frame);
`TaskFrame.saturation_of_fib_finite` asks that every fibre be finite, which an arbitrary frame
does not give, and an unravelled fibre is in bijection with a fibre of the base;
`TaskFrame.saturation_of_deterministic` asks for a deterministic relation, which the unravelling
is not — branching is the whole point of it. Recording the path as a partial history over the
interval from the anchor, rather than as a finite list, changes nothing here: the machine run
stays definable by successor recursion, but the carrier only grows and the fibres are the same
sets, so the obligation is unchanged. Discharging *Saturation* for a path-recording relation
directly is left open.

## References

* `FormalSystem/Semantics/Frames/TranslationProduct.lean` — the clock product and its invariance
* `FormalSystem/Semantics/HistoryMorphism.lean` — `TwoWayBounded`, `HistMorphism.plus_invariance`
* Gabbay's irreflexivity rule and Reynolds' *Auxiliary Atoms* rule are the two sources; the clock
  rule below is the strengthening of the former that the latter's device suggests

## Tags

naming-rules · irreflexivity · clock-rule · soundness · plus-language
-/

namespace FormalSystem.Metalogic.NamingRules

open FormalSystem.Syntax FormalSystem.Semantics FormalSystem.PlusLanguage

/-! ## Freshness -/

/-- **The atom `q` does not occur in the formula.** A naming-rule-local predicate on the seven
L⁺ constructors: the syntax layer carries no `atoms` function, and adding one would rebuild every
dependent of `PlusLanguage/Formula.lean` for a notion only these two rules consume. -/
def Fresh (q : Atom) : PlusFormula → Prop
  | .atom p => p ≠ q
  | .bot => True
  | .imp a b => Fresh q a ∧ Fresh q b
  | .box a => Fresh q a
  | .untl a b => Fresh q a ∧ Fresh q b
  | .snce a b => Fresh q a ∧ Fresh q b
  | .stab a => Fresh q a

/-- `Fresh` rejects the atom it is about. -/
example (q : Atom) : ¬ Fresh q (PlusFormula.atom q) := fun h => h rfl

/-- `Fresh` accepts every other atom. -/
example (p q : Atom) (h : p ≠ q) : Fresh q (PlusFormula.atom p) := h

/-- `Fresh` is not everywhere true: it rejects a compound containing the atom. -/
example (q : Atom) : ¬ Fresh q (PlusFormula.stab (PlusFormula.atom q)) := fun h => h rfl

/--
**L⁺ truth is unchanged by a valuation change at a fresh atom only.**

Two models agreeing at every atom other than `q` give the same truth value to every `q`-fresh
formula, at every history and every time. This is what discharges the auxiliary letter: the
premise is instantiated at a model built to satisfy the antecedent, and the conclusion — being
`q`-free — holds at the model that forgets `q`.

By induction on `φ`. The `box` and `stab` cases are `forall_congr'` chains: both clauses
quantify over histories and neither consults the valuation except through the inductive
hypothesis.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem plusTruthAt_congr_of_fresh {F : TaskFrame} (M M' : TaskModel F) (q : Atom)
    (hV : ∀ (w : F.WorldState) (p : Atom), p ≠ q → (M.valuation w p ↔ M'.valuation w p)) :
    ∀ φ : PlusFormula, Fresh q φ → ∀ (τ : WorldHistory F) (t : F.Duration),
      PlusTruthAt M τ t φ ↔ PlusTruthAt M' τ t φ := by
  intro φ
  induction φ with
  | atom p => intro hq τ t; exact hV _ _ hq
  | bot => intro _ _ _; exact Iff.rfl
  | imp a b ih1 ih2 => intro hq τ t; exact imp_congr (ih1 hq.1 τ t) (ih2 hq.2 τ t)
  | box a ih => intro hq τ t; exact forall_congr' fun σ => ih hq σ t
  | untl a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 hq.2 τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 hq.1 τ r)
  | snce a b ih1 ih2 =>
    intro hq τ t
    exact exists_congr fun s => and_congr_right fun _ =>
      and_congr (ih2 hq.2 τ s) (forall_congr' fun r => imp_congr_right fun _ =>
        imp_congr_right fun _ => ih1 hq.1 τ r)
  | stab a ih =>
    intro hq τ t
    exact forall_congr' fun σ => imp_congr_right fun _ => ih hq σ t

/-! ## The clock rule's antecedent -/

/-- **`q` holds now and at no other time of this history** — `q` names the present time. -/
def nm (q : Atom) : PlusFormula :=
  (PlusFormula.atom q).and ((PlusFormula.atom q).neg.allPast.and
    (PlusFormula.atom q).neg.allFuture)

/-- **`q` holds at exactly one time of this history**: now, once in the past, or once in the
future. -/
def once (q : Atom) : PlusFormula := ((nm q).or (nm q).somePast).or (nm q).someFuture

/-- **The time at which `q` holds is the same on every history through the current state**: each
of "`q` sometime later" and "`q` sometime earlier" is `⊡`-stable. -/
def rigid (q : Atom) : PlusFormula :=
  ((PlusFormula.atom q).someFuture.imp (PlusFormula.stab (PlusFormula.atom q).someFuture)).and
    ((PlusFormula.atom q).somePast.imp (PlusFormula.stab (PlusFormula.atom q).somePast))

/-- **The clock rule's antecedent**: `q` now, and — on every history, at every time — `q` is a
`⊡`-rigid name of exactly one time. -/
def clockAnte (q : Atom) : PlusFormula :=
  (PlusFormula.atom q).and (PlusFormula.box ((once q).and (rigid q)).always)

/-! ## The clock valuation on the translation product -/

section Clock

variable {D : TemporalOrder} (F : FrameOver D) [F.IsRegular]

/-- **The clock valuation**: on the translation product, `q` is read as "the clock reads zero",
and every other atom keeps the base model's reading. The clock is a component of the product
state, so this is an ordinary valuation on world states — no two-dimensional semantics is
involved. -/
def clockModel (M : TaskModel F.toTaskFrame) (q : Atom) :
    TaskModel F.translationProduct.toTaskFrame :=
  ⟨fun a p => if p = q then a.2 = 0 else M.valuation a.1 p⟩

variable (M : TaskModel F.toTaskFrame) (q : Atom)

/-- Under the clock valuation, `q` holds exactly where the clock reads zero. -/
theorem plusTruthAt_atom_clock
    (σ : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D) :
    PlusTruthAt (clockModel F M q) σ s (PlusFormula.atom q) ↔ (σ.state s).2 = 0 := by
  simp [PlusTruth.atom_iff, clockModel]

/-- Under the clock valuation, every atom other than `q` reads as it does in the lifted base
model. -/
theorem clockModel_valuation_of_ne (a : F.WorldState × ↑D) {p : Atom} (hp : p ≠ q) :
    (clockModel F M q).valuation a p ↔ (liftModel F M).valuation a p := by
  simp [clockModel, liftModel, hp]

/-- **`nm q` holds wherever the clock reads zero**: the clock is time plus a constant along any
history of the product (`clock_eq`), so it reads zero at one time only. -/
theorem plusTruthAt_nm (σ : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D)
    (h0 : (σ.state s).2 = 0) :
    PlusTruthAt (clockModel F M q) σ s (nm q) := by
  have hs := h0
  rw [clock_eq F σ s] at hs
  rw [nm, PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.allPast_iff, PlusTruth.allFuture_iff]
  refine ⟨(plusTruthAt_atom_clock F M q σ s).2 h0, ?_, ?_⟩
  · intro r hr hc
    rw [plusTruthAt_atom_clock, clock_eq F σ r] at hc
    exact hr.ne (add_left_cancel (hc.trans hs.symm))
  · intro r hr hc
    rw [plusTruthAt_atom_clock, clock_eq F σ r] at hc
    exact hr.ne' (add_left_cancel (hc.trans hs.symm))

/-- **`once q` holds everywhere**: the clock reads zero at exactly one time of every history of
the product, namely `-(σ(0)).2`, which lies in the past of, at, or in the future of any given
time. -/
theorem plusTruthAt_once (σ : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D) :
    PlusTruthAt (clockModel F M q) σ s (once q) := by
  have hzero : (σ.state (-(σ.state 0).2)).2 = 0 := by
    rw [clock_eq F σ]; simp
  rw [once, PlusTruth.or_iff, PlusTruth.or_iff, PlusTruth.somePast_iff, PlusTruth.someFuture_iff]
  rcases lt_trichotomy (-(σ.state 0).2) s with hlt | heq | hgt
  · exact Or.inl (Or.inr ⟨_, hlt, plusTruthAt_nm F M q σ _ hzero⟩)
  · exact Or.inl (Or.inl (by rw [← heq]; exact plusTruthAt_nm F M q σ _ hzero))
  · exact Or.inr ⟨_, hgt, plusTruthAt_nm F M q σ _ hzero⟩

/-- **`rigid q` holds everywhere**: two histories of the product through one state at one time
read the same clock there, hence agree on which time the clock reads zero. That is why the name
is `⊡`-rigid even though no formula can name a time globally. -/
theorem plusTruthAt_rigid (σ : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D) :
    PlusTruthAt (clockModel F M q) σ s (rigid q) := by
  have hclock : ∀ (η : WorldHistory F.translationProduct.toTaskFrame),
      σ.state s = η.state s → ∀ r : ↑D, (σ.state r).2 = (η.state r).2 := by
    intro η he r
    have h1 : (σ.state s).2 = (η.state s).2 := by rw [he]
    rw [clock_eq F σ s, clock_eq F η s] at h1
    rw [clock_eq F σ r, clock_eq F η r, add_right_cancel h1]
  rw [rigid, PlusTruth.and_iff]
  constructor
  · intro hF η he
    rw [PlusTruth.someFuture_iff] at hF ⊢
    obtain ⟨r, hr, hq'⟩ := hF
    rw [plusTruthAt_atom_clock] at hq'
    exact ⟨r, hr, (plusTruthAt_atom_clock F M q η r).2 ((hclock η he r).symm.trans hq')⟩
  · intro hP η he
    rw [PlusTruth.somePast_iff] at hP ⊢
    obtain ⟨r, hr, hq'⟩ := hP
    rw [plusTruthAt_atom_clock] at hq'
    exact ⟨r, hr, (plusTruthAt_atom_clock F M q η r).2 ((hclock η he r).symm.trans hq')⟩

/-- **The clock valuation satisfies the whole antecedent** at any time where the clock reads
zero. The `□` of `clockAnte` ranges over every history of the product and the `△` over every
time, and `once`/`rigid` hold at all of them.

Paper: — (formalization-native; the manuscript states no naming rule) -/
theorem plusTruthAt_clockAnte (σ : WorldHistory F.translationProduct.toTaskFrame) (s : ↑D)
    (h0 : (σ.state s).2 = 0) :
    PlusTruthAt (clockModel F M q) σ s (clockAnte q) := by
  rw [clockAnte, PlusTruth.and_iff, PlusTruth.box_iff]
  refine ⟨(plusTruthAt_atom_clock F M q σ s).2 h0, ?_⟩
  intro ρ
  rw [PlusFormula.always, PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.allPast_iff,
    PlusTruth.allFuture_iff]
  have hmain : ∀ r : ↑D,
      PlusTruthAt (clockModel F M q) ρ r ((once q).and (rigid q)) := by
    intro r
    rw [PlusTruth.and_iff]
    exact ⟨plusTruthAt_once F M q ρ r, plusTruthAt_rigid F M q ρ r⟩
  exact ⟨fun r _ => hmain r, hmain s, fun r _ => hmain r⟩

end Clock

/-! ## The two rules -/

/--
**Soundness of the clock rule.** If `(q ∧ □△(once q ∧ rigid q)) → φ` is valid over a frame class
and `q` does not occur in `φ`, then `φ` is valid over that class.

So an atom may be assumed to hold at **exactly one time of every history**, with that time
**rigid under the stability modal** — provided it is discharged. A time cannot be named globally;
it can be named within every stability cluster.

The proof runs the premise on the translation product of the given frame, which lies in the same
class (`FrameOver.translationProduct_sat`) and is regular
(`FrameOver.translationProduct_isRegular`), under the clock valuation and the lift of the given
history placed so that the clock reads zero at the evaluation time (`liftH_through`'s offset
convention). `plusTruthAt_clockAnte` discharges the antecedent; `plusTruthAt_congr_of_fresh`
forgets `q`; and `plus_invariance` with `projH_liftH` projects the conclusion back to the base
frame. No frame construction is added: the clock product this rule needs is the library's
translation product.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem clock_irr_sound (fc : FormalSystem.ProofSystem.FrameClass) (q : Atom) (φ : PlusFormula)
    (hq : Fresh q φ) (hprem : PlusValidIn fc ((clockAnte q).imp φ)) :
    PlusValidIn fc φ := by
  intro G hG M τ x
  haveI := hG.isRegular
  have h0 : ((liftH G.toFibre τ (0 - x)).state x).2 = 0 := by simp
  have h1 : PlusTruthAt (clockModel G.toFibre M q) (liftH G.toFibre τ (0 - x)) x φ :=
    hprem G.toFibre.translationProduct.toTaskFrame
      ((FrameOver.translationProduct_sat G.toFibre fc).2 hG)
      (clockModel G.toFibre M q) (liftH G.toFibre τ (0 - x)) x
      (plusTruthAt_clockAnte G.toFibre M q (liftH G.toFibre τ (0 - x)) x h0)
  have h2 : PlusTruthAt (liftModel G.toFibre M) (liftH G.toFibre τ (0 - x)) x φ :=
    (plusTruthAt_congr_of_fresh (clockModel G.toFibre M q) (liftModel G.toFibre M) q
      (fun a p hp => clockModel_valuation_of_ne G.toFibre M q a hp) φ hq _ _).1 h1
  have h3 := (plus_invariance G.toFibre M φ (liftH G.toFibre τ (0 - x)) x).1 h2
  rwa [projH_liftH] at h3

/--
**Soundness of Gabbay's plain irreflexivity rule**, as a corollary. If `(q ∧ H¬q) → φ` is valid
over a frame class and `q` does not occur in `φ`, then `φ` is valid over that class.

The weaker antecedent follows from the clock antecedent: `once q` puts the unique time at which
`q` holds in the past of, at, or in the future of the evaluation time, and `q` holding *now*
rules out the two off-centre cases, leaving `nm q`, whose second conjunct is `H¬q`. `rigid q` is
not consumed — which is exactly the sense in which the clock rule is the stronger of the two.

Paper: — (formalization-native; the manuscript states no naming rule)
-/
theorem irr_sound (fc : FormalSystem.ProofSystem.FrameClass) (q : Atom) (φ : PlusFormula)
    (hq : Fresh q φ)
    (hprem : PlusValidIn fc
      (((PlusFormula.atom q).and (PlusFormula.atom q).neg.allPast).imp φ)) :
    PlusValidIn fc φ := by
  refine clock_irr_sound fc q φ hq ?_
  intro G hG M τ x hante
  refine hprem G hG M τ x ?_
  rw [clockAnte, PlusTruth.and_iff, PlusTruth.box_iff] at hante
  obtain ⟨hqt, hbox⟩ := hante
  have h1 := hbox τ
  rw [PlusFormula.always, PlusTruth.and_iff, PlusTruth.and_iff] at h1
  have h3 := h1.2.1
  rw [PlusTruth.and_iff, once, PlusTruth.or_iff, PlusTruth.or_iff, PlusTruth.somePast_iff,
    PlusTruth.someFuture_iff] at h3
  rw [PlusTruth.and_iff, PlusTruth.allPast_iff]
  refine ⟨hqt, ?_⟩
  intro r hr hqr
  rcases h3.1 with (h | ⟨s, hs, h⟩) | ⟨s, hs, h⟩
  · rw [nm, PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.allPast_iff,
      PlusTruth.allFuture_iff] at h
    exact h.2.1 r hr hqr
  · rw [nm, PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.allPast_iff,
      PlusTruth.allFuture_iff] at h
    exact h.2.2 x hs hqt
  · rw [nm, PlusTruth.and_iff, PlusTruth.and_iff, PlusTruth.allPast_iff,
      PlusTruth.allFuture_iff] at h
    exact h.2.1 x hs hqt

end FormalSystem.Metalogic.NamingRules
