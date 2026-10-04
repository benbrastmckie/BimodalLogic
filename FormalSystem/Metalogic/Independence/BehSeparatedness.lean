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
`driftLinear` and the drift frame's own construction, not through any step taken here. See the
provenance paragraph in this module's docstring.
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
