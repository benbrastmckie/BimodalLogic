/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Independence.StarDiscrimination
import FormalSystem.Semantics.Presheaf.Determinism

/-!
# Separatedness of `Beh F` is strictly stronger than the validity of *Determined*

The countermodel half of the *Determinism* theorem pair. `Semantics/DeterministicBridge.lean`'s
`deterministic_iff_separated` settles the clause itself: at a regular frame, `F.Deterministic` and
`Presheaf.Separated F` are equivalent. This module settles what that equivalence does **not** say.
Over the drift frame `F°` of `app:drift` — this repository's own countermodel, not a new
construction — every instance of *Determined* is valid while `Beh F°` fails to be separated.

## Which converse fails, and which does not

Two converses are in play and a reader must not be allowed to conflate them. **The clause's own
converse is true**: `Semantics/DeterministicBridge.lean`'s `deterministic_iff_separated` is a
biconditional at `[F.IsRegular]`, so there is nothing there left to refute — `Presheaf.Separated F`
and `F.Deterministic` stand or fall together. What **fails** is the converse of the composite
"validity of *Determined* on `F` ⟹ `Beh F` separated", and `fzero_not_separated` is the witness for
that failure and for nothing else. Taken for a counterexample to the clause it would be a
contradiction; taken for what it is, it is the measure of the gap between a *validity* on the frame
and a *frame condition* on it — the same gap `Independence/DeterminismUndefinable.lean`'s
`determined_valid_on_non_deterministic` records at the frame level, read here on the presheaf side.

## Why `F°` validates the schema without being separated

Validity of *Determined* over `F°` is established through the state-set bridge: over a frame
satisfying (H1) `OrderFlow` and (H2) `StateOccurs`, L⁺ truth depends only on the **world state** at
the time of evaluation (`Independence/StateSetTruth.lean`), and `F°` discharges both
(`Independence/DriftHistories.lean`). A property of that shape is invariant under **re-timing** a
history — reparametrizing which time carries which state leaves the set of states swept, and hence
every L⁺ truth value, untouched. `F°`'s world histories are exactly the strictly increasing
bi-Lipschitz bijections of `ℝ`, so they are re-timings of one another, and `driftLinear 1` and
`driftLinear 2` are two such re-timings of the same sweep.

Separatedness is **not** invariant under re-timing, and that is the whole of the asymmetry: a
section of `Beh F` carries its parametrization, so the rate-1 and rate-2 sections over `[0, 1]` are
distinct sections agreeing at the germ at `0`. The frame validates the schema because the schema
cannot see the rate; the presheaf is unseparated because its restriction maps can.

## Choice, and what it is not

Nothing here appeals to `thm:extension` or to `cor:occurrence`, **hence no Zorn**, and the
provenance claim is prose-level, as `Independence/DriftHistories.lean` and
`StarLanguage/StarDeterminism.lean` both word theirs. All three declarations below measure
`[propext, Classical.choice, Quot.sound]`, and that `Classical.choice` is the ambient real-analytic
apparatus — `driftLinear`, `F°`'s own `fzero_not_deterministic` and `fzero_determined` each already
measure it independently of this module. The sections are explicit and the only step taken over
them is arithmetic on the band. The measurable fact is the axiom list; the attribution is the
sentence above, and neither should be read as the other.

## An open question, posed and not attacked

**Does any formula characterize separatedness of `Beh F` choice-freely?** The question as first
posed — whether any `BL⋆` formula characterizes it at all — has been overtaken by a theorem:
`StarLanguage/StarDeterminism.lean`'s `deterministic_starDefinable` gives
`F.Deterministic ↔ ∀ φ, F.StarValidOn (detPM φ)` at `[F.IsRegular]`, already at bare atoms, so
composing it with `deterministic_iff_separated` makes `detPM` a `BL⋆` characterization of
separatedness on regular frames. For `L⁺` the answer is flatly negative:
`deterministic_not_plusDefinable` (`Independence/DeterminismUndefinable.lean`) shows no set of
`PlusFormula`s defines the deterministic frames, hence none defines separatedness.

What survives is the choice-freeness. `deterministic_starDefinable`'s (⇒) direction routes through
`deterministic_of_singletonClasses` and hence `thm:extension` and Zorn's lemma, so it is a theorem
of **ZFC**, and `StarDeterminism.lean`'s own choice-dependence note — which records that the
asymmetry between the two directions is structural rather than visible in `#print axioms` — suggests
no choice-free characterization exists. This module poses that and does not attack it; nothing below
is an attempt on it.

## Main Definitions

- `driftSec` — the affine drift world of rate `a`, cut down to the section over `[0, 1]`

## Main Results

- `fzero_not_separated` — `Beh F°` is not separated
- `separated_strictly_stronger` — the theorem pair: `F°` validates every instance of *Determined*
  **and** `Beh F°` is not separated

## Implementation Notes

The witness is two lines of the band. `driftSec 1` and `driftSec 2` are the rate-1 and rate-2
affine drift worlds (`Independence/StarDiscrimination.lean`'s `driftLinear`) cut down to `[0, 1]`.
Both are `0` at time `0`, so they have the same germ there; at time `1` one reads `1` and the other
reads `2`. The germ restriction `Beh.restrict 0 0` is therefore not injective, which is exactly the
failure of `Presheaf.Separated`.

**Measured axiom profile** (`#print axioms`): all three declarations are
`[propext, Classical.choice, Quot.sound]`. The `Classical.choice` is ambient — it arrives through
`driftLinear` and the drift frame's own construction, not through any step taken here. See
"Choice, and what it is not" above.

## References

* JPL paper `app:presheaf-dictionary` — the dictionary theorem whose *Determinism* clause this
  module is the countermodel half of. **`DANGLING`**: cut from the paper with `app:Structure` and
  recorded in `docs/reference/paper-definitions-of-record.md`
* JPL paper `app:drift` — the drift frame `F°` supplying the witness. Cited as a **pointer only**:
  its record row is `LIVE-UNPINNED` because the text this tree engages with sits in the `proof`
  block outside the theorem environment, so a pin would hash text no docstring quotes
* JPL paper `cor:no-characterization`, `thm:extension`, `def:deterministic` — the L⁺
  non-definability result, the extension theorem the open question's ZFC dependence runs through,
  and the determinism predicate
* `FormalSystem/Semantics/Presheaf/Determinism.lean` — `Presheaf.Separated` and `Presheaf.secOf`,
  which `driftSec` instantiates
* `FormalSystem/Semantics/DeterministicBridge.lean` — `deterministic_iff_separated`, the clause
  itself, whose own converse does not fail
* `FormalSystem/Metalogic/Independence/StarDiscrimination.lean` — `driftLinear`, the affine drift
  worlds
* `FormalSystem/Metalogic/Independence/DeterminismUndefinable.lean` — `fzero_determined`, the left
  conjunct of the pair, and `determined_valid_on_non_deterministic`, the frame-level reading of the
  same gap
* `FormalSystem/Metalogic/Independence/DriftFrame.lean` — `F0` and `fzero_not_deterministic`
* `FormalSystem/Metalogic/Independence/DriftHistories.lean` — `F°`'s world histories as strictly
  increasing bi-Lipschitz bijections of `ℝ`, and (H1)/(H2) discharged
* `FormalSystem/Metalogic/Independence/StateSetTruth.lean` — the state-set bridge: L⁺ truth depends
  only on the world state of evaluation
* `FormalSystem/StarLanguage/StarDeterminism.lean` — `deterministic_starDefinable` and the
  choice-dependence note the open question rests on

## Tags

independence · drift-frame · separatedness · presheaf-dictionary · app:presheaf-dictionary
-/

namespace FormalSystem.Metalogic.Independence

open FormalSystem.Syntax
open FormalSystem.Semantics
open FormalSystem.Semantics.Presheaf
open FormalSystem.PlusLanguage

/-- The affine drift world of rate `a`, cut down to the section over `[0, 1]`. Its state at a time
`z` of that interval is `a * z`, through `Presheaf.secOf` at base time `0`. -/
noncomputable def driftSec (a : ℝ) (h1 : 1 ≤ a) (h2 : a ≤ 2) : Beh F0 1 :=
  secOf (driftLinear a h1 h2) 0 1 zero_le_one

/--
**`Beh F°` is not separated.**

The rate-1 and rate-2 drift sections over `[0, 1]` have the same germ at `0` — both read `0` there
— and different states at `1`, namely `1` and `2`. So the germ restriction `Beh.restrict 0 0` over
the duration `1` is not injective.

The two worlds are the repository's own (`Independence/StarDiscrimination.lean`'s `driftLinear`),
and nothing here appeals to `thm:extension` or `cor:occurrence`, hence to no Zorn argument: the
sections are explicit, and the only step is arithmetic on the band.
-/
theorem fzero_not_separated : ¬ Separated F0 := by
  intro hS
  have hple : (0 : F0.Duration) + 0 ≤ 1 := by rw [add_zero]; exact zero_le_one
  have hgerm : Beh.restrict 0 0 le_rfl le_rfl hple (driftSec 1 le_rfl one_le_two)
      = Beh.restrict 0 0 le_rfl le_rfl hple (driftSec 2 one_le_two le_rfl) := by
    refine Beh.ext (partialHistory_ext rfl ?_)
    intro r hr hr'
    obtain rfl : r = 0 := le_antisymm hr.2 hr.1
    change (1 : ℝ) * ((0 : ℝ) + 0 + 0) = (2 : ℝ) * ((0 : ℝ) + 0 + 0)
    ring
  have heq := hS 1 0 0 le_rfl le_rfl hple hgerm
  have hdom : (driftSec 1 le_rfl one_le_two).val.domain 1 := ⟨zero_le_one, le_rfl⟩
  have hdom' : (driftSec 2 one_le_two le_rfl).val.domain 1 := ⟨zero_le_one, le_rfl⟩
  have hst := states_eq_of_eq heq 1 hdom hdom'
  have hne : (1 : ℝ) * ((1 : ℝ) + 0) = (2 : ℝ) * ((1 : ℝ) + 0) := hst
  norm_num at hne

/--
**The theorem pair.** `F°` validates every instance of *Determined* and `Beh F°` is not separated:
separatedness of the behavior presheaf is **strictly stronger** than the validity of *Determined*
on the frame.

The left conjunct is `Independence/DeterminismUndefinable.lean`'s `fzero_determined`; the right is
`fzero_not_separated` above. See this module's docstring for why this is not a counterexample to
`Semantics.deterministic_iff_separated`.
-/
theorem separated_strictly_stronger :
    (∀ φ : PlusFormula, F0.PlusValidOn (.imp φ (.stab φ))) ∧ ¬ Separated F0 :=
  ⟨fzero_determined, fzero_not_separated⟩

end FormalSystem.Metalogic.Independence
