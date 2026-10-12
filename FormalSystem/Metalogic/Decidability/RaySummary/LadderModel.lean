/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary.RunLayer
import FormalSystem.Semantics.TaskModel

/-!
# The admissible ladder carrier, and the frame and model over it

Requirement (W)'s run layer (`RaySummary/README.md`, "(W): what landed and what did not") has
its frame scheme in `RunLayer.lean`: the deadline ladder `Rlad` over `Q × ℕ × ℕ` and the frame
`ladderFrame` it yields through `ofSlicedStepFinBranch`, which takes seriality (`fwd`/`bwd`) as
explicit hypotheses exactly as `ofSlicedStep` does. This module lands the **admissibility set
`Adm`** the README names beside that frame, the carrier it cuts out, and the frame and model on
that carrier — beside `ladderFrame`, which stays instance-free and is not edited.

## Why `Adm` restricts the carrier

`ladderFrame`'s own seriality hypotheses are unsatisfiable: `Rlad` carries the source clause
`pend x.1 = false → x.2.1 = 0`, so the idle state `(q, 1, 0)` has no `Rlad`-successor (it is
not an admissible source) and no `Rlad`-predecessor (`Count _ false c n c'` forces `c' = 0`),
and when every state is pending `(q, 0, 0)` has no successor (`Count true true` demands
`c' + 1 = 0`). Hence `¬ ∀ t x, ∃ y, Rlad step pend t x y` for EVERY object (`no_fwd`,
`[Nonempty Q]` only) and `¬ ∀ t x, ∃ y, Rlad step pend (t - 1) y x` for every object with an
idle state (`no_bwd_of_idle`). `ladderFrame`, `ladderFrame_isRegular` and `ladderFrame_step`
are therefore theorems about a frame with no instances — the unsatisfiable-hypothesis form, not
a vacuity: every definition is meaningful, and nothing can be applied to it. The README's own
phrase is the fix — `c ∈ Adm q` is a restriction of the CARRIER, not an object condition.

## What this module holds

* `no_fwd`, `no_bwd_of_idle` — the two unsatisfiability theorems above.
* `Adm pend q := {c | pend q = false → c = 0}` — every current deadline while pending, only `0`
  while idle: exactly the clause `Rlad` imposes on its source.
* `LadderState Q pend := {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}` — the admissible carrier,
  inhabited (`ladderState_nonempty`) and still infinite (it contains `(q, 0, n)` for every `n`;
  `Rlad_slice_infinite` is the same width one level down).
* `RladAdm` — `Rlad` on the underlying triples, with two-sided finite branching for EVERY finite
  object by pulling `Rlad_fwd`/`Rlad_bwd` back along `Subtype.val` (`RladAdm_fwd`,
  `RladAdm_bwd`; `Set.Finite.preimage` with `Subtype.val_injective.injOn`, one line each).
* `ladderFrameAdm` through `ofSlicedStepFinBranch`, regular by
  `ofSlicedStepFinBranch_isRegular` unchanged (`ladderFrameAdm_isRegular`), and `ladderModel`,
  whose valuation reads the object component `q` of a state `(t, ⟨(q, c, n), h⟩)` and nothing
  else. On this carrier `fwd`/`bwd` are genuine object conditions, taken as hypotheses.

The carrier restriction exhibited here is one of several equally valid shapes: repairing
`ladderFrame` in place, or a sigma over `Adm`, are alternatives not taken. `[Finite Q]` is on
the OBJECT only.

## What this module does not hold

* **No realization theorem.** Nothing here says a ladder state realizes any closure type; the
  run layer's phase 2 remains open. Its first statement — that the realized cells `cellAt` of
  `ladderModel` stabilize in the pair of counters `(c, n)` past a bound syntactic in `φ`, in the
  exhibited-bound form or the `∃ B` form — is REFUTED by the wired probe
  `specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean`, which consumes the
  declarations of this module on the two-state object: the gap `n - c` between the counters is
  observable through `p U (r ∧ X(p ∧ X r))`, because `Count`'s idle clause reads `c' = n`.
* **No index of a ladder cell is claimed**, in any shape, and the clipped-coordinate index
  family is refuted at the countdown coordinate as well as bounded at the gap one, by the wired
  probe `specs/evidence/seam-gluing-ray-product/ladder-cell-index-obstructions.lean`: `Count true
  true` admits no early discharge, so a pending region's first idle state sits at distance exactly
  `c + 1`, and `step` is independent of the counters, so the countdown's PARITY is observable
  there (`cell_succ_ne` at every `c` with `n` held fixed, `ladderIndex_not_factoring` at every
  clip bound, in both the exhibited-bound and `∃ B` forms). A computable index of which cell a
  ladder state has is absent, and the positive factorization lemma — for a candidate of this
  family or any other — is open and asserted nowhere. The bounded-carrier alternative, replacing
  this carrier by its deadline-bounded sub-carrier, is closed as a GENERAL route by the same probe
  (`bounded_width_validates_Phi_neg` against `Phi_neg_not_valid`); the narrow carve-out is that a
  bounded carrier remains available for a target that does have a finite-width countermodel, per
  `not_finite_width_fmp`'s own disclaimer. The residue-carrying six-coordinate candidate that
  probe exhibits, at its object-exhibited threshold and period, is refuted at BOTH parameters by
  the wired probe `specs/evidence/seam-gluing-ray-product/ladder-residue-index-refutation.lean`,
  uniformly in the clip bound (`object_only_parameters_refuted`: the forced first idle state's
  exact distance is observable to the formula's `untl`-nesting depth, so no threshold fixed
  before the formula survives; `reach_period_refuted`: the reach-set period of the full step
  graph is not the period of the sub-object a formula that forbids a letter carves out). The
  threshold must therefore be formula-derived and the modulus must dominate every
  letter-definable sub-object period — a NECESSARY condition on any index's parameters — and the
  positive lemma for parameters depending on the object and the formula jointly is OPEN and
  asserted nowhere. What that probe proves positively is fixture-level only
  (`qp_cell_eq_of_depth_parity`): on the two-state object, where every history through a pending
  state shares one object path, the cell is determined by the object state, the countdown's
  parity and a formula-derived threshold; the general object has no such forced path.
* **`anchorCells_finite` and `anchorCells_ncard_le` are untouched**: the SET of cells of any
  model is still finite and bounded. What is absent is only the computable index of WHICH cell a
  ladder state has.
* **Every quantity named is a COUNT.** No upper bound and no complexity bound is claimed, for
  the construction or for anything it feeds.
* The refuted statement is direction-neutral and the witness refuting it is forward-only, as
  every probe in that collection is.
* Nothing about `HitPresented`; nothing mentions `PlusValidZTime`, and
  `Decidable (PlusValidZTime φ)` is not stated in any form. Depth `k = 1`, as in `RunLayer.lean`.
-/

namespace FormalSystem.Metalogic.Decidability.RaySummary

open FormalSystem.Syntax FormalSystem.Semantics

/-! ## The landed frame's seriality hypotheses are unsatisfiable -/

/-- **`ladderFrame`'s forward seriality hypothesis is unsatisfiable, for every object.** If some
state is idle, `(q, 1, 0)` is not an admissible `Rlad`-source; if every state is pending,
`(q, 0, 0)` has no successor since `Count true true` demands `c' + 1 = 0`. Only `[Nonempty Q]`
is used.

Paper: — (a statement about the frame scheme's own seriality hypotheses, which have no
counterpart in HWZ 2000's quasimodels, where the run set is chosen freely) -/
theorem no_fwd {Q : Type} [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    ¬ ∀ t x, ∃ y, Rlad step pend t x y := by
  intro h
  by_cases hidle : ∃ q, pend q = false
  · obtain ⟨q, hq⟩ := hidle
    obtain ⟨y, hy⟩ := h 0 (q, 1, 0)
    have h1 : (1 : ℕ) = 0 := hy.2.1 hq
    exact absurd h1 one_ne_zero
  · have hall : ∀ q, pend q = true := fun q => by
      by_contra hq
      exact hidle ⟨q, by simpa using hq⟩
    obtain ⟨y, hy⟩ := h 0 (Classical.arbitrary Q, 0, 0)
    have hc := hy.2.2.2
    simp [Count, hall] at hc

/-- **`ladderFrame`'s backward seriality hypothesis is unsatisfiable, for every object with an
idle state.** The idle state `(q, 1, 0)` has no `Rlad`-predecessor: `Count _ false c n c'`
forces `c' = 0`.

Paper: — (the backward twin of `no_fwd`; the same remark applies) -/
theorem no_bwd_of_idle {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool)
    (q : Q) (hq : pend q = false) :
    ¬ ∀ t x, ∃ y, Rlad step pend (t - 1) y x := by
  intro h
  obtain ⟨y, hy⟩ := h 0 (q, 1, 0)
  have hc := hy.2.2.2
  simp [Count, hq] at hc

/-! ## The admissible carrier and the ladder frame on it (generic in the object) -/

/-- Admissible current-deadline values at an object state: every `c` while pending, only `0`
while idle — exactly the clause `Rlad` imposes on its source. This is the README's `c ∈ Adm q`,
a restriction of the CARRIER (`no_fwd`, `no_bwd_of_idle` say why no object condition would
do); it is unrelated to the family of admissible propositions also written `Adm` in
`FormalSystem/QuantLanguage/`, a parameter of another namespace. -/
def Adm {Q : Type} (pend : Q → Bool) (q : Q) : Set ℕ := {c | pend q = false → c = 0}

/-- The admissible ladder carrier: the triples `(q, c, n)` whose current deadline is admissible
at `q`. Still infinite — `(q, 0, n)` is admissible for every `n`. -/
abbrev LadderState (Q : Type) (pend : Q → Bool) : Type :=
  {x : Q × ℕ × ℕ // x.2.1 ∈ Adm pend x.1}

/-- The admissible carrier is inhabited whenever the object is: `(q, 0, 0)` is admissible at
every `q`. -/
instance ladderState_nonempty {Q : Type} [Nonempty Q] (pend : Q → Bool) :
    Nonempty (LadderState Q pend) :=
  ⟨⟨(Classical.arbitrary Q, 0, 0), fun _ => rfl⟩⟩

/-- The ladder relation restricted to the admissible carrier: `Rlad` on the underlying
triples. -/
def RladAdm {Q : Type} (step : Q → Q → Bool) (pend : Q → Bool) :
    ℤ → LadderState Q pend → LadderState Q pend → Prop :=
  fun t x y => Rlad step pend t x.1 y.1

/-- Forward finite branching of `RladAdm` for every finite object: `Rlad_fwd` pulled back along
`Subtype.val`. -/
theorem RladAdm_fwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    FwdFinBranch (RladAdm step pend) :=
  fun t x => (Rlad_fwd step pend t x.1).preimage Subtype.val_injective.injOn

/-- Backward finite branching of `RladAdm` for every finite object: `Rlad_bwd` pulled back along
`Subtype.val`. -/
theorem RladAdm_bwd {Q : Type} [Finite Q] (step : Q → Q → Bool) (pend : Q → Bool) :
    BwdFinBranch (RladAdm step pend) :=
  fun t y => (Rlad_bwd step pend t y.1).preimage Subtype.val_injective.injOn

/-- The ladder frame on the admissible carrier, through `ofSlicedStepFinBranch`. Seriality
(`fwd`/`bwd`) is a genuine object condition on this carrier and is taken as hypotheses, exactly
as `ladderFrame` and `ofSlicedStep` take theirs; `[Finite Q]` is on the OBJECT only, and the
slice `LadderState Q pend` is infinite. -/
def ladderFrameAdm {Q : Type} [Finite Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) : FrameOver intOrder :=
  ofSlicedStepFinBranch (RladAdm step pend) (RladAdm_fwd step pend) (RladAdm_bwd step pend) fwd bwd

/-- **`ladderFrameAdm` is regular.** `Saturation` comes from `saturation_of_finBranch` through
`RladAdm_fwd`/`RladAdm_bwd`, with no `[Finite W]` on the carrier, so `not_finite_width_fmp` is
not contradicted. This is the frame on the admissible carrier and nothing else: no realization
theorem (nothing says a ladder state realizes a closure type), no index of a ladder cell,
nothing about `HitPresented`, nothing about `PlusValidZTime` in any form, and no complexity
bound.

Paper: — (as for `ladderFrame_isRegular`: the nearest literature object is the quasimodel
`⟨f, R⟩` of HWZ 2000's Definition 12, whose run set `R` is chosen freely; no counterpart
constructor exists there, and the HWZ corpus entry is of UNVERIFIED-summary provenance, so it
orients the shape and sources no claim) -/
instance ladderFrameAdm_isRegular {Q : Type} [Finite Q] [Nonempty Q]
    (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) :
    (ladderFrameAdm step pend fwd bwd).IsRegular :=
  ofSlicedStepFinBranch_isRegular _ _ _ _ _

/-- **The ladder model**: the valuation reads the object component only — at a world state
`(t, ⟨(q, c, n), h⟩)` the letter `p` holds iff `lab q p = true`; the time `t` and the two
counters are invisible to it. No realization theorem is claimed for it, and the stabilization
of its cells in the counter pair `(c, n)` is refuted by the wired probe
`specs/evidence/seam-gluing-ray-product/ladder-cell-refutation.lean` (see the module docstring).

Paper: — (the model over the frame-scheme constructor; the frame it sits on has no literature
counterpart, see `ladderFrameAdm_isRegular`) -/
def ladderModel {Q : Type} [Finite Q] [Nonempty Q] (step : Q → Q → Bool) (pend : Q → Bool)
    (fwd : ∀ t x, ∃ y, RladAdm step pend t x y)
    (bwd : ∀ t x, ∃ y, RladAdm step pend (t - 1) y x) (lab : Q → Atom → Bool) :
    TaskModel (ladderFrameAdm step pend fwd bwd).toTaskFrame where
  valuation := fun (w : ℤ × LadderState Q pend) p => lab w.2.1.1 p = true

end FormalSystem.Metalogic.Decidability.RaySummary
