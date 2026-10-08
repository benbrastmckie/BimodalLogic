/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.RaySummary

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

end BimodalTest.KTypeFinEval
