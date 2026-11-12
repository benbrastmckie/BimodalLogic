/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete

/-!
# Full Labels Collapse the `stab` Comparison Class

This file records, machine-checked, why the sliced certificate's position space `posAt` filters
labels by `AgreesOnState` -- agreement on the state shapes only -- rather than by equality with
the slice labelling. It contains **no `sorry`** and asserts nothing it does not prove.

## The decision this holds in place

The `TailStable` junk-position obstruction has a tempting root-level repair: carry FULL labels in
the certificate, so that the position space at a slice is a singleton and no junk position can
exist for either obligation direction, making both liveness filters deletable. That repair is
**refuted**, and the landed two-filter design (`TailStable`/`TailStableMirror`, `fwdLiveAt`/
`bwdLiveAt`) stands.

The argument is that label multiplicity over one state at one time is not slack in the
certificate -- it **is** the comparison class of `PlusTruthAt`'s `stab` clause. `⊡` quantifies
over the histories sharing the present world state, and the frame a certificate presents has
carrier `ℤ × Fin G.n`, so that class is exactly the labels of the live positions over one state
at one time, which is what `StabFaithful` reads. Collapsing it to one label per state would
restrict the comparison class to models in which `⊡φ ↔ φ` -- the deterministic collapse named by
`FormalSystem.PlusLanguage.stab_iff_of_deterministic`.

Part A measures the consequence at the two landed `⊡`-carrying non-vacuity witnesses
(`TotalEdge.certA` at target `Pp → ⊡Pp`, and `TotalEdge.certB`): under full labels both have an
**empty** position space, so full labels do not merely shrink the search -- they kill the landed
certificates outright. The slab is a state description, not a type. Part B measures the
multiplicity itself: strictly more live positions than live states at each of them.

Part E is the second half of the refutation: full labels do not make junk positions impossible
either. At `PlusSlicedCertificate.Fixture.cert` the full-label position space is still not the
live set, so the `⊇` superset failure -- repaired by absorption, not by any filter -- survives
the refinement independently.

## What it does NOT establish

Decidability is not the obstruction. The full-label position space is a `Finset.univ.filter` by a
decidable predicate exactly as `posAt` is, and every measurement below closes `by decide`; the
original deferral note's stated reason was a rework cost, not a decidability loss. Nor is the
refutation a claim that the embedding produces junk positions: it does not. That positive half
has a stable statement and now lives in the library, as
`FormalSystem.Metalogic.Decidability.WitnessFamily.FullLabelRegression.posAtFull` together with
`botSnce_posAtFull_eq_liveAt`, `botUntl_posAtFull_eq_liveAt` and
`liveFamily_posAtFull_eq_liveAt`; see Part C/D below.

Axioms: `[propext, Classical.choice, Quot.sound]` on every headline. No `sorryAx`, no custom
axiom, no `native_decide`.
-/

namespace Probe714

open FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.TotalEdge
open FormalSystem.Metalogic.Decidability.PlusSharingWitnessFamily
open FormalSystem.Metalogic.Decidability.WitnessFamily.Embedded

variable {Γ Del : PlusContext}

/-- The position space under full labels (option 3's `posAt`). -/
def posAtFull (G : PlusSlicedCertificate Γ Del) (t : ℤ) : Finset G.Pos :=
  Finset.univ.filter (fun p => LabCoherent Γ Del p.2.1 ∧ p.2.1 = G.slab t p.1)

/-! ## Part A — the two total-edge witnesses under full labels -/

set_option maxRecDepth 100000 in
/-- `certA`'s target path label differs from the slab at its own state and time, so option 3's
`TargetPathPos` fails at this landed certifying certificate. -/
theorem certA_target_not_full : certA.target.lab 0 ≠ certA.slab 0 (certA.target.st 0) := by
  decide

set_option maxRecDepth 100000 in
theorem certB_target_not_full : certB.target.lab 0 ≠ certB.slab 0 (certB.target.st 0) := by
  decide

set_option maxRecDepth 400000 in
/-- Stronger: `certA`'s slice labelling is not even an internally coherent label, so under full
labels the position space over it is EMPTY. -/
theorem certA_slab_not_labCoherent :
    ¬ LabCoherent ([] : PlusContext) [targetA atomP] (certA.slab 0 (0 : Fin certA.n)) := by
  decide

set_option maxRecDepth 400000 in
theorem certA_posAtFull_empty : posAtFull certA 0 = ∅ := by decide

set_option maxRecDepth 400000 in
theorem certB_posAtFull_empty : posAtFull certB 0 = ∅ := by decide

/-! ## Part B — label multiplicity over one state in the live set -/

#eval (certA.posAt 0).card
#eval (certA.liveAt 0).card
#eval ((certA.liveAt 0).image Prod.fst).card
#eval (certB.posAt 0).card
#eval (certB.liveAt 0).card
#eval ((certB.liveAt 0).image Prod.fst).card

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
/-- At `certA` strictly more live positions than live states: two distinct live labels sit over
one slice state at one time. -/
theorem certA_live_multiplicity :
    ((certA.liveAt 0).image Prod.fst).card < (certA.liveAt 0).card := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
theorem certB_live_multiplicity :
    ((certB.liveAt 0).image Prod.fst).card < (certB.liveAt 0).card := by decide

/-! ## Parts C and D -- the embedded route, now a library regression triple

The three equalities this probe once proved locally are now library declarations:
`FormalSystem.Metalogic.Decidability.WitnessFamily.FullLabelRegression.botSnce_posAtFull_eq_liveAt`
(at the `⊥ S ⊥` certificate that forced the backward filter),
`.botUntl_posAtFull_eq_liveAt` (at the `⊥ U ⊥` certificate that forced the forward filter) and
`.liveFamily_posAtFull_eq_liveAt` (at the embedded live-eventuality certificate), each stated
against that namespace's own `posAtFull`, which is this file's definition verbatim. They say that
along the embedding route the full-label position space is exactly the computed live set at every
window time -- so the `posAt` over-approximation costs that route nothing.

They are a fact about the **embedding**, not about full labels: Part E below is the same
measurement at `Fixture.cert`, where it fails. This probe therefore keeps only the readouts the
library theorems do not state -- the position-space cardinalities and the target-label comparisons
that show *how* the two spaces coincide, rather than *that* they do.
-/

#eval (liveFamily.sliced (-1)).n
#eval ((liveFamily.sliced (-1)).posAt (-1)).card
#eval (posAtFull (liveFamily.sliced (-1)) (-1)).card
#eval ((liveFamily.sliced (-1)).liveAt (-1)).card
#eval ((liveFamily.sliced (-1)).posAt 0).card
#eval (posAtFull (liveFamily.sliced (-1)) 0).card
#eval ((liveFamily.sliced (-1)).liveAt 0).card
#eval (((liveFamily.sliced (-1)).target.lab 0) =
  (liveFamily.sliced (-1)).slab 0 ((liveFamily.sliced (-1)).target.st 0))
#eval (((liveFamily.sliced (-1)).target.lab (-1)) =
  (liveFamily.sliced (-1)).slab (-1) ((liveFamily.sliced (-1)).target.st (-1)))

end Probe714

namespace Probe714

open FormalSystem.PlusLanguage
open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate
open FormalSystem.Metalogic.Decidability.WitnessFamily.Embedded
open FormalSystem.Metalogic.Decidability.WitnessFamily.BotTargets

#eval ((botSnceFamily.sliced 0).winTimes).card
#eval ((botSnceFamily.sliced 0).posAt 0).card
#eval (posAtFull (botSnceFamily.sliced 0) 0).card
#eval ((botSnceFamily.sliced 0).liveAt 0).card
#eval ((botUntlFamily.sliced 0).posAt 0).card
#eval (posAtFull (botUntlFamily.sliced 0) 0).card
#eval ((botUntlFamily.sliced 0).liveAt 0).card

end Probe714

namespace Probe714

open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate
open FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Fixture

/-! ## Part E -- the `⊇` (superset) failure under full labels -/

#eval (Fixture.cert.winTimes).card
#eval (Fixture.cert.posAt (-1)).card
#eval (posAtFull Fixture.cert (-1)).card
#eval (Fixture.cert.liveAt (-1)).card
#eval (Fixture.cert.L₀).card
#eval decide (Fixture.p₀ ∈ posAtFull Fixture.cert (-1))
#eval decide (posAtFull Fixture.cert (-1) = Fixture.cert.liveAt (-1))
#eval (Fixture.cert.posAt 0).card
#eval (posAtFull Fixture.cert 0).card
#eval (Fixture.cert.liveAt 0).card

end Probe714

#print axioms Probe714.certA_target_not_full
#print axioms Probe714.certB_target_not_full
#print axioms Probe714.certA_slab_not_labCoherent
#print axioms Probe714.certA_posAtFull_empty
#print axioms Probe714.certB_posAtFull_empty
#print axioms Probe714.certA_live_multiplicity
#print axioms Probe714.certB_live_multiplicity
