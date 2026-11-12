import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.Examples
import FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.EmbedComplete

/-!
# Probe: full labels in the sliced certificate

Measures what option 3 -- replacing `AgreesOnState` by full label/slab equality -- does to the
three landed certifying certificates of the sliced class.
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

/-! ## Part C — the embedded (⊡-free) route -/

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

/-! ## Part D -- full labels against the certificates that forced each filter -/

#eval ((botSnceFamily.sliced 0).winTimes).card
#eval ((botSnceFamily.sliced 0).posAt 0).card
#eval (posAtFull (botSnceFamily.sliced 0) 0).card
#eval ((botSnceFamily.sliced 0).liveAt 0).card
#eval ((botUntlFamily.sliced 0).posAt 0).card
#eval (posAtFull (botUntlFamily.sliced 0) 0).card
#eval ((botUntlFamily.sliced 0).liveAt 0).card

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
/-- At the `⊥ S ⊥` certificate that forced the backward filter, the full-label position space is
exactly the computed live set at every window time. -/
theorem botSnce_posAtFull_eq_liveAt :
    ∀ t ∈ (botSnceFamily.sliced 0).winTimes,
      posAtFull (botSnceFamily.sliced 0) t = (botSnceFamily.sliced 0).liveAt t := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
/-- The same at the `⊥ U ⊥` certificate that forced the forward filter. -/
theorem botUntl_posAtFull_eq_liveAt :
    ∀ t ∈ (botUntlFamily.sliced 0).winTimes,
      posAtFull (botUntlFamily.sliced 0) t = (botUntlFamily.sliced 0).liveAt t := by decide

set_option maxRecDepth 4000000 in
set_option maxHeartbeats 2000000 in
/-- And at the embedded live-eventuality certificate, whose raw demand also fails today. -/
theorem liveFamily_posAtFull_eq_liveAt :
    ∀ t ∈ (liveFamily.sliced (-1)).winTimes,
      posAtFull (liveFamily.sliced (-1)) t = (liveFamily.sliced (-1)).liveAt t := by decide

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
#print axioms Probe714.botSnce_posAtFull_eq_liveAt
#print axioms Probe714.botUntl_posAtFull_eq_liveAt
#print axioms Probe714.liveFamily_posAtFull_eq_liveAt
