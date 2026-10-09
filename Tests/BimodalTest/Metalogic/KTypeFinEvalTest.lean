/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary
import FormalSystem.Metalogic.Decidability.RaySummary.Realize
import FormalSystem.Metalogic.Decidability.RaySummary.AnchorLayer

/-!
# Computability witnesses for the `k`-type device

This module is **permanent evidence**, on the pattern of `KTypeSummaryAxiomTest.lean`, that the
effective half of the realizability device actually runs: the computable `k`-type `kTypeOfFin`
on finite segments (`segZ` of a decidable colouring, `listSeg` of a list of letters) and the
computable realized-triple set `hitOf` of a finite labelled presentation. Each `#guard` is
evaluated by the compiler, so a red build is the signal that one of these definitions has become
noncomputable — the exact regression the device exists to rule out (`kTypeOf` itself is
`Classical.dec` by design, and `presentsMulti_seamTrace`'s `Bool` is classical).

## What the numbers are, and are not

Every value below is a **witness of computability and nothing else**. The cardinalities are not
a claim about any model: `hitOf` is the realized set of a *presentation*, and the bridge from a
presentation to a model's own `HitCl` holds only under the realization hypothesis `Presented`
(`hit_eq_hitOf_of_presented`, `RaySummary/Trace.lean`), which this tree discharges for no
non-trivial model. Nothing here decides anything, quantifies over models, or bounds anything.

## Alphabet and depth

All checks are on the two-letter alphabet `twoLetter` (`now := true`, `φ := false`) at depth
`1`, where a `k`-type is the set of letters a segment realizes (there is no order atom between a
point and itself), so the expected values can be read off by hand.
-/

namespace BimodalTest.KTypeFinEval

open FormalSystem.Metalogic.WeakCanonical FormalSystem.Metalogic.Decidability.RaySummary

/-! ## `kTypeOfFin` on segments of a decidable colouring -/

/-- `now` exactly at `0`; the letter `φ` at the even times. -/
def cBool : Bool → ℤ → Bool := fun p z => bif p then decide (z = 0) else decide (z % 2 = 0)

def c2 : twoLetter.preds → ℤ → Prop := fun p z => cBool p z = true

instance : ∀ p, DecidablePred (c2 p) := fun _ _ => inferInstanceAs (Decidable (_ = true))

-- Exactly one depth-1 normal form holds on `[0, 3)` (`nf_exists_unique`).
#guard (Finset.univ.filter (fun nf => kTypeOfFin (segZ twoLetter c2 0 3) 1 nf = true)).card = 1

-- `[0, 3)` and `[0, 5)` have the same depth-1 type (both realise `now ∧ φ`, `¬now ∧ φ`,
-- `¬now ∧ ¬φ`); `[0, 1)` realises only `now ∧ φ`, so it does not.
#guard kTypeOfFin (segZ twoLetter c2 0 3) 1 = kTypeOfFin (segZ twoLetter c2 0 5) 1
#guard kTypeOfFin (segZ twoLetter c2 0 3) 1 ≠ kTypeOfFin (segZ twoLetter c2 0 1) 1

/-! ## `kTypeOfFin` on list segments -/

/-- The letter reading `φ` only. -/
def f : twoLetter.preds → Bool := fun p => !p

/-- The letter reading nothing. -/
def g : twoLetter.preds → Bool := fun _ => false

-- `[f, g, f]` and `[f, g, f, g, f]` have the same depth-1 type; `[f]` does not (no `g`).
#guard kTypeOfFin (listSeg (sig := twoLetter) [f, g, f]) 1 =
  kTypeOfFin (listSeg (sig := twoLetter) [f, g, f, g, f]) 1
#guard kTypeOfFin (listSeg (sig := twoLetter) [f, g, f]) 1 ≠
  kTypeOfFin (listSeg (sig := twoLetter) [f]) 1

/-! ## `hitOf` on finite labelled presentations -/

/-- The two-state presentation with the complete step graph: state `true` reads both letters
(so it reads `now`), state `false` reads neither. Its anchored runs are exactly
`… false [true] false …`, so its realized set has the two middle-segment types `[true]` and
`[false …, true, false …]`, each with the letterless type on both sides. The smallest
presentation whose `hitOf` is nonempty. -/
def labW : Bool → twoLetter.preds → Bool := fun q _ => q

def stepW : Bool → Bool → Bool := fun _ _ => true

#guard (allPathTypes labW stepW true 1).card = 1
#guard (hitOf labW stepW true 1).card = 2

/-- The alternating presentation `step x y := (x ≠ y)`, state `false` reading `φ` only and
state `true` reading nothing: no state reads `now`, so it has no anchored run and its realized
set is empty. At the depth-1 type of `[labAlt false]`, the shared-endpoint liveness `fwdLive`
(`Present.lean`) holds at `false` through the one-state self-loop while the disjoint-segment
liveness `fwdLiveSep` (`HitOf.lean`, the one `hitOf` consumes) does not — the discriminator
recorded when `hitOf`'s consumption site moved to the separated graph. -/
def labAlt : Bool → twoLetter.preds → Bool := fun q p => !q && !p

def stepAlt : Bool → Bool → Bool := fun x y => x != y

/-- The depth-1 type of the one-letter path `[labAlt false]`. -/
def τAlt : KType twoLetter 1 := kTypeOfFin (listSeg (sig := twoLetter) [labAlt false]) 1

#guard fwdLive labAlt stepAlt true 1 τAlt false
#guard !fwdLiveSep labAlt stepAlt true 1 τAlt false
#guard bwdLive labAlt stepAlt true 1 τAlt false
#guard !bwdLiveSep labAlt stepAlt true 1 τAlt false
#guard (hitOf labAlt stepAlt true 1).card = 0

/-! ## `stabCheckSig` on finite labelled presentations

`stabCheckSig lab step now phi` (`RaySummary/StabCheck.lean`) is the liveness decider for the
run-level `⊡` condition: `true` iff every `now` state that is live in both `now`-free step graphs
reads `phi`. The four values below are evaluated by the compiler and are **witnesses of
computability and nothing else**: they are statements about four presentations, not about any
model, and the bridge from a presentation's runs to a model's `⊡` holds only under the
realization hypothesis `Presented` (`stabCheck_iff_of_presented`), which the wired probe
`specs/evidence/seam-gluing-ray-product/presented-not-complete.lean` refutes as a completeness
carrier on fixture model A for every finite presentation. Nothing here decides anything about a
model, and nothing here mentions validity.

The pair `labW`/`labX` on the complete graph is the discriminator: both presentations have the
one live `now` state `true`, which reads `phi` under `labW` and not under `labX`. The two
`stepAlt` values show the liveness guard is load-bearing: under `labX`/`stepAlt` the `now` state
`true` steps only to `false`, which is `now`-free but steps only back to `true`, which reads
`now`, so no infinite `now`-free path leaves `true`, no `now` state is live in both `now`-free
graphs, and the check is vacuously `true`; under `labAlt`/`stepAlt` no state reads `now` at
all. -/

/-- The complete-graph presentation with state `true` reading `now` only: the one live `now`
state lacks `phi`. -/
def labX : Bool → twoLetter.preds → Bool := fun q p => q && p

#guard stabCheckSig labW stepW true false
#guard !stabCheckSig labX stepW true false
#guard stabCheckSig labX stepAlt true false
#guard stabCheckSig labAlt stepAlt true false

/-! ## Non-vacuity of the `Cons` consistency conditions

`Cons` (`RaySummary/Realize.lean`) is the consistency bundle on a finite labelled presentation
that `cons_localRun` turns into `LocalRun`. A bundle of conditions is worthless if nothing
satisfies it, and worthless in the opposite way if everything does. The block below settles both
on ONE three-state presentation, with every value evaluated by the compiler against the landed
definitions themselves — `UCoh`, `ULive`, `deferGraph`, `SCoh`, `SLive` and `bwdDeferGraph` are
the real declarations here, not re-spelled copies.

The alphabet is `sigCons := ⟨Fin 4⟩` with `u = 0` (the eventuality claim), `g = 1` (the guard),
`e = 2` (the event) and `now = 3`. The presentation is `0 → 0`, `0 → 1`, `1 → 2`, `2 → 2`, with
the event at states `0` and `2` and the `now` marker at state `1` alone, which lies on no cycle.

What the checks establish, clause group by clause group of `Cons`:

* `serialFwd` / `serialBwd` — both bi-serialities hold, so a bi-infinite run exists.
* `ucoh` / `ulive` and `scoh` / `slive` — all four hold at the letter triple `(u, g, e)`, in both
  time directions. Both liveness conditions are non-vacuous constraints *that are satisfied*:
  the forward deferral graph has the edge `1 → 2` and the backward one the edge `1 → 0`, so
  neither `ULive` nor `SLive` holds merely because its graph is empty.
* `nowOnce` — checked by enumeration to depth 3. That is the carrier's full depth and so a
  complete check for this fixture: a `step3`-path of more than three states repeats a state and
  therefore adds no endpoint the depth-3 enumeration missed. The enumeration is a computed
  check on the fixture, not a proof of the `StepPath`-quantified `Cons.nowOnce` field.
* The marker is read at state `1` and nowhere else, which is what a run's `now` condition needs.

`boxStabFree` and the propositional clauses (`botFalse`, `impEq`) are not exercised here: they
are conditions on a labelling over `clSig φ` for a concrete `φ`, whereas everything above is at
a bare `sigCons` and so is shared by every `φ` whose closure supplies the three letters. This is
a non-vacuity witness for the bundle's *clauses*, not an inhabitant of `Cons` at a concrete `φ`.

The negative control is the point of the whole block. `labConsBad` differs from `labCons` in
exactly one letter — state `0` loses the event — and that single change makes the `0 → 0`
self-loop an event-free cycle every state of which claims the eventuality: precisely the object
`Probe735.pump_isRun` manufactures. Both liveness conditions go false on it while both
coherence conditions stay true, so the liveness half of `Cons` is shown to exclude something,
and to exclude exactly the shape it was read off. -/

/-- The four-letter alphabet of the `Cons` fixtures: `u = 0`, `g = 1`, `e = 2`, `now = 3`. -/
abbrev sigCons : FormalSystem.Metalogic.Expressiveness.MonadicSignature := ⟨Fin 4⟩

/-- The three states of the `Cons` fixtures. -/
abbrev QCons := Fin 3

/-- States `0` and `2` carry the event; `1` is the `now` state and lacks it. Every state claims
the eventuality `u` and carries the guard `g`. -/
def labCons : QCons → sigCons.preds → Bool
  | 0 => fun p => p != 3
  | 1 => fun p => p == 0 || p == 1 || p == 3
  | 2 => fun p => p != 3

/-- `0 → 0`, `0 → 1`, `1 → 2`, `2 → 2`: the `now` state `1` lies on no cycle. -/
def stepCons : QCons → QCons → Bool
  | 0, 0 => true
  | 0, 1 => true
  | 1, 2 => true
  | 2, 2 => true
  | _, _ => false

/-- The negative control: `labCons` with state `0`'s event removed, and nothing else changed.
The `0 → 0` self-loop becomes an event-free cycle claiming the eventuality. -/
def labConsBad : QCons → sigCons.preds → Bool
  | 0 => fun p => p == 0 || p == 1
  | 1 => fun p => p == 0 || p == 1 || p == 3
  | 2 => fun p => p != 3

/-! Bi-seriality in both senses (`Cons.serialFwd`, `Cons.serialBwd`). -/
#guard decide (∀ q : QCons, ∃ q' : QCons, stepCons q q' = true)
#guard decide (∀ q : QCons, ∃ q' : QCons, stepCons q' q = true)

/-! The forward conditions (`Cons.ucoh`, `Cons.ulive`) hold, and the deferral graph has a real
edge, so `ULive` is a satisfied constraint rather than an empty one. -/
#guard decide (UCoh labCons stepCons 0 1 2)
#guard decide (ULive labCons stepCons 0 2)
#guard deferGraph labCons stepCons 0 2 1 2

/-! The backward conditions (`Cons.scoh`, `Cons.slive`) hold, with a real backward deferral
edge. Checked on the landed `SCoh`/`SLive`/`bwdDeferGraph`, which were proved outright rather
than transported from the forward half — so these are four independent values, not two. -/
#guard decide (SCoh labCons stepCons 0 1 2)
#guard decide (SLive labCons stepCons 0 2)
#guard bwdDeferGraph labCons stepCons 0 2 1 0

/-! The once-only `now` condition (`Cons.nowOnce`), by enumeration to the carrier's full depth:
no `stepCons`-path of one, two, or three steps out of the `now` state `1` returns to it. -/
#guard decide (∀ a b c : QCons,
  ¬ (stepCons 1 a = true ∧ a = 1) ∧
  ¬ (stepCons 1 a = true ∧ stepCons a b = true ∧ b = 1) ∧
  ¬ (stepCons 1 a = true ∧ stepCons a b = true ∧ stepCons b c = true ∧ c = 1))

/-! The marker is read at state `1` and nowhere else. -/
#guard decide (∀ q : QCons, labCons q 3 = true ↔ q = 1)

/-! **`Cons.nowUnique`**, the eleventh field, in its own vocabulary: the `clNow` marker pins a
UNIQUE state of the presentation. It follows from the marker guard immediately above, and is
guarded separately because `nowOnce` does not imply it and neither subsumes the other —
`nowOnce` is once-only ALONG a path, `nowUnique` once-only ACROSS the presentation. `nowOnce`
alone permits two mutually unreachable marked components, whose splices through one seam cannot
cover the whole run set, which is exactly the obligation `presented_modelOf`'s (⇐) direction
raised and the reason this field exists. -/
#guard decide (∀ q q' : QCons, labCons q 3 = true → labCons q' 3 = true → q = q')

/-! **The negative control.** One label changed: both coherence conditions survive, and both
liveness conditions fail — the `Probe735.pump_isRun` shape, in both time directions. If either
`!decide` below ever goes false, the liveness half of `Cons` has stopped excluding anything. -/
#guard decide (UCoh labConsBad stepCons 0 1 2)
#guard !decide (ULive labConsBad stepCons 0 2)
#guard live (deferGraph labConsBad stepCons 0 2) 0
#guard decide (SCoh labConsBad stepCons 0 1 2)
#guard !decide (SLive labConsBad stepCons 0 2)
#guard live (bwdDeferGraph labConsBad stepCons 0 2) 0

/-! ## `AnchorConsFin` on concrete cell sets

`AnchorConsFin φ 𝒞` (`RaySummary/AnchorLayer.lean`) is the `Finset` twin of the closure-wide
anchor object `AnchorCons`: five equations on a set of cells (sets of closure types), decided
field for field by `decidableAnchorConsFin`. The two values below are evaluated by the compiler
and are **witnesses of computability and non-vacuity, nothing else**: they are statements about
two concrete `Finset (Finset (Finset PlusFormula))` literals, not about any model. The bridge
from a model to its cells is `anchorCons_anchorCells` (for every model, no hypothesis), and the
bridge from the `Finset` object to the `Set` one is `anchorConsFin_iff`; neither is exercised
here, and nothing here mentions validity or decides anything about a model.

The formula is `⊡p`, whose closure is `{⊡p, p}`. The POSITIVE witness has three cells: `{{⊡p, p}}`
(a state at which `p` holds along every history, so `⊡p` holds), `{∅}` (a state at which `p`
fails along every history), and `{{p}, ∅}` — a state at which `p` holds along some histories and
fails along others, so `⊡p` is in NEITHER type. That third cell carries TWO types at one world
state, which is exactly the shape the trace-level realization hypothesis `Presented` with a
unique `now` state can never present (`Probe747.stab_iff_of_presented_nowUnique`, the wired
probe `w-soundness-shape-refuted.lean`: at such a seam `ψ ↔ ⊡ψ` for every closure `ψ`). So the
witness is non-vacuous in the sense requirement (W) asks for.

The NEGATIVE control is the point of the block: `{{{p}}}` violates the `stab` equation — `⊡p` is
not in the one type `{p}` although `p` is in every type of the cell — so the checker returns
`false`. If `!decide` below ever goes false, the `stab` equation has stopped excluding anything. -/

/-- The atom `p`. -/
def pAtom : FormalSystem.Syntax.Atom := ⟨"p", none⟩

/-- `p` and `⊡p` as L⁺ formulas. -/
abbrev pF : FormalSystem.PlusLanguage.PlusFormula := .atom pAtom
abbrev stabP : FormalSystem.PlusLanguage.PlusFormula := .stab pF

/-! The closure of `⊡p` is `{⊡p, p}`. -/
#guard FormalSystem.PlusLanguage.plusSubformulaClosure stabP = {stabP, pF}

/-- POSITIVE: three cells, the third carrying two types at one state. -/
def cellsPos : Finset (Finset (Finset FormalSystem.PlusLanguage.PlusFormula)) :=
  {{{stabP, pF}}, {∅}, {{pF}, ∅}}

/-- NEGATIVE control: one cell, one type, the `stab` equation violated. -/
def cellsNeg : Finset (Finset (Finset FormalSystem.PlusLanguage.PlusFormula)) :=
  {{{pF}}}

#guard decide (AnchorConsFin stabP cellsPos)
#guard !decide (AnchorConsFin stabP cellsNeg)

end BimodalTest.KTypeFinEval
