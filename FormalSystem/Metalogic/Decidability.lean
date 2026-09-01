/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.SignedFormula
import FormalSystem.Metalogic.Decidability.Tableau
import FormalSystem.Metalogic.Decidability.Closure
import FormalSystem.Metalogic.Decidability.Saturation
import FormalSystem.Metalogic.Decidability.ProofExtraction
import FormalSystem.Metalogic.Decidability.CountermodelExtraction
import FormalSystem.Metalogic.Decidability.DecisionProcedure
import FormalSystem.Metalogic.Decidability.Correctness
import FormalSystem.Metalogic.Decidability.IntPresentation
import FormalSystem.Metalogic.Decidability.Propositional.PropForm
import FormalSystem.Metalogic.Decidability.Propositional.Kalmar
import FormalSystem.Metalogic.Decidability.Propositional.Decidable
import FormalSystem.Metalogic.Decidability.Verified.RuleSpec
import FormalSystem.Metalogic.Decidability.Verified.Termination.SubformulaProperty
import FormalSystem.Metalogic.Decidability.Verified.Termination.TimeTypeBound
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BranchOrder
import FormalSystem.Metalogic.Decidability.Verified.Bridge.Embed
import FormalSystem.Metalogic.Decidability.Verified.Bridge.Carrier
import FormalSystem.Metalogic.Decidability.Verified.Bridge.Interpolate
import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionFrame
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TruthLemma
import FormalSystem.Metalogic.Decidability.Verified.Bridge.Valuation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.BoxSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.PropSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalSaturation
import FormalSystem.Metalogic.Decidability.Verified.Bridge.RegionLabel
import FormalSystem.Metalogic.Decidability.Verified.Bridge.TemporalGate
import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntGaps
import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntTruth
import FormalSystem.Metalogic.Decidability.Verified.Bridge.DenseTruth
import FormalSystem.Metalogic.Decidability.Verified.Decidable
import FormalSystem.Metalogic.Decidability.BiLasso

/-!
# FormalSystem.Metalogic.Decidability - Decision Procedure for TM Logic

Tableau-based decision procedure returning proof terms or countermodels.

## Submodules

- `SignedFormula`: Sign, SignedFormula, Branch types
- `Tableau`: Tableau expansion rules (propositional, modal, temporal)
- `Closure`: Branch closure detection
- `Saturation`: Saturation and fuel-based termination
- `ProofExtraction`: Extract DerivationTree from closed tableau
- `CountermodelExtraction`: Extract countermodel from open branch
- `DecisionProcedure`: Main decide function with proof search optimization
- `Correctness`: Soundness and completeness proofs
- `Verified.RuleSpec`: rule/axiom frame-class gate lemmas
- `Verified.Termination.SubformulaProperty`: T1, the signed subformula property (per rule)
- `Verified.Termination.TimeTypeBound`: T2, the `2 ^ (2 * |C|)` time-type bound and pigeonhole
- `Verified.Termination.Fuel`: T3, the set-growth progress measure and the uncapped fuel figure
- `Verified.Bridge.BranchOrder`: the finite linear order a gated saturated branch carries
- `Verified.Bridge.Embed`: monotone placement of a finite order in a dense carrier or in `ℤ`
- `Verified.Bridge.Carrier`: `TemporalCarrier fc D`, the per-frame-class carrier interface
- `Verified.Bridge.Interpolate`: the region structure a placement cuts in the carrier, the
  total-on-`D` extension operator, and the invariance induction's propositional and modal cases
- `Verified.Bridge.RegionFrame`: the countermodel's frame, its region histories, the fact
  that those are exactly the frame's total histories — which is what `valid` quantifies over —
  and `truthAt_box_iff`: `□` is the universal modality, with no closure hypothesis needed
- `Verified.Bridge.TruthLemma`: `InterpInvariantAt`, region invariance at a single history — the
  form this carrier admits — and its instantiation at the countermodel's base histories
- `Verified.Bridge.Valuation`: the countermodel's `TaskModel` — the branch's atoms at placed region
  codes, a parameter at gap codes — with the placed-point readback the truth lemma's atom case
  consumes, and the two theorems refuting the endpoint-copy gap policies
- `Verified.Bridge.BoxSaturation`: `sat_box_temporal`, `sat_all_future_pos`, `sat_all_past_pos`
  and their composition `sat_box_cross`, plus `BoxAnchored`/`boxAnchoredCheck` and
  `sat_box_grid_of_check` — the branch condition that turns the cross into the full grid of
  labels the `box` case needs
- `Verified.Bridge.PropSaturation`: `sat_imp_pos`, the one member of the `sat_*` family
  `CountermodelExtraction.lean` does not carry, because `impPos` is the only *branching*
  propositional rule and the guard it fails is the arm-already-present test
- `Verified.Bridge.TemporalSaturation`: `sat_untl_pos_future` and `sat_snce_pos_past` — the
  positive temporal witnesses with the one fact `sat_untl_pos`/`sat_snce_pos` discard, namely
  that the witness lies strictly after (resp. before) the formula's own time. Isolated here for
  the reason `PropSaturation` is: both unfold `applyRule`. Also `orderDual_converse`, the
  `pastOf → futureOf` direction of the closure duality
- `Verified.Bridge.RegionLabel`: the gap arm of the atom clause, after three refuted policies —
  a region takes the atoms of a *chosen known label*, certified by the decidable gate
  `regionLabelCheck` in the family `timeOrderTotal` and `boxAnchoredCheck` belong to
- `Verified.Bridge.TemporalGate`: `temporalWitnessCheck`, a fourth decidable branch gate in the
  family `timeOrderTotal`/`boxAnchoredCheck`/`regionLabelCheck` belongs to, carrying the four
  demands the `untl`/`snce` cases make and the region gate does not: the negative spread in each
  direction and the two ray self-witnesses. Every row measured on an extended engine corpus
  before being stated (`Tests/BimodalTest/TemporalWitnessProbe.lean`); two further candidates
  were refuted there and are deliberately absent
- `Verified.Bridge.IntGaps`: the `ℤ` placement is contiguous, so a non-placed integer lies on one
  of the two rays and there is no interior gap — the reason the `ℤ` milestone is strictly easier
  than the `ℚ`/`ℝ` one
- `Verified.Bridge.IntTruth`: the signed truth correspondence and its six-case induction, run at
  `ℤ`; the `atom`, `bot`, `imp` and `box` cases are proved there for an arbitrary carrier and an
  arbitrary injective placement, and so are not `ℤ`-specific despite the module's name
- `Verified.Bridge.DenseTruth`: the same correspondence at a dense carrier.
  `branchTruthAt_of_temporal` is the machine-checked statement of what the two milestones share —
  the whole induction with only the `untl`/`snce` cases abstracted, the four others discharged
  from `IntTruth` unchanged
- `Verified.Decidable`: the *other* direction — `allClosed → valid`. `SatState` is the
  satisfiability notion a branch supports (a model, an interpretation of the branch's world
  labels by **total** histories, and an interpretation of its time labels respecting the
  abstract `TimeOrdering`); `SatResult` is satisfiability preservation read off `applyRule`'s
  own `RuleResult × TimeOrdering`; `RuleSound` is the per-rule obligation, indexed by a carrier
  property so that a frame-class-gated rule can assume what its class supplies
- `BiLasso`: the bi-lasso decision layer — decides truth of a formula at a state of a *given*
  `IntPresentation` (a finite graph on `Fin card` with a `Bool` valuation), by bi-lasso unfolding
  and periodicity. Entry point `check` and its correctness theorem `check_correct`
  (`BiLasso/Check.lean`). It decides a *presentation*, not the logic: nothing in it quantifies
  over frames

## Status

Each claim below names its subject and the theorem that carries it. Proof-system results and this
directory's decision-procedure results are different claims, and they are kept apart deliberately:
the tableau contributes the derivation, not the soundness.

**Proof system** — proved elsewhere, consumed here:

- Soundness: `Metalogic.soundness` (`Soundness.lean`), `Γ ⊢[Base] φ → Γ ⊨ φ`, sorry-free, with
  `soundness_dense` and `soundness_discrete` the frame-class variants. Its corollary at the empty
  context is `decide_sound` (`Correctness.lean`), `⊢ φ → ⊨ φ`, which is what consumes the
  derivation `decide` returns in its `.valid` constructor.
- Completeness: `BXCanonical.completeness`, `BXCanonical.completeness_dense` and
  `BXCanonical.completeness_discrete` (`BXCanonical/Completeness.lean`) are all proved *and*
  sorry-free. The `.Base` one closed last, when its discrete branch
  `WeakCanonical.countermodel_discrete` was proved at the `ℚ ×ₗ ℤ` carrier
  (`WeakCanonical/GroupModel/CountermodelBase.lean`). Check C2 of
  `scripts/check-module-invariants.sh` pins all three axiom sets, which are now identical:
  `[propext, Classical.choice, Quot.sound]`.
  "BFMCS" names the canonical-frame construction under `Metalogic/Bundle/`, which is not part of
  `Decidability/`.

**This directory's decision procedure**:

- The rule half of `allClosed → valid` is proved: `ruleSound_of_mem_allRulesForFC`
  (`Verified/Decidable.lean`), sorry-free — every rule `allRulesForFC` can schedule at a frame
  class preserves satisfiability under that class's carrier property.
- The **sound direction** of the `isValid`-shaped statement, `isValid φ fc = true → ⊨ φ`, is
  proved and landed: `sound_of_isValid` and `isValid_sound` (`Correctness.lean`), sorry-free,
  along with the `isTautology` / `isContradiction` / `isSatisfiable` siblings and the
  frame-class-relativized forms.
- The **completeness direction**, `⊨ φ → isValid φ fc = true` — and therefore
  `valid_iff_allClosed`, the `isValid φ fc = true ↔ ⊨ φ` biconditional, and the `Decidable (⊨ φ)`
  instances for the four frame classes — is **open**. See `Correctness.lean`'s section
  "`validity_decidable` / `validity_has_decision_procedure` — Retired as vacuous" for what is
  still owed and why no `isValid`-shaped biconditional is written before it can be proved.
- Proof extraction: Partial. `extractProof` (`ProofExtraction.lean`) runs five strategies in order
  — `tryAxiomProof`, `matchDerived`, the closure-based `.axiomNeg` filter,
  `buildCompositionalProof`, `enhancedSearch` — and returns `.incomplete` once all are exhausted.

## Usage

```lean
import FormalSystem.Metalogic.Decidability

open FormalSystem.Metalogic.Decidability

#check decide        -- Main decision procedure
#check isValid       -- Boolean validity check
#check isSatisfiable -- Boolean satisfiability check
```
-/
