/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.PostBlocking
import FormalSystem.Metalogic.Decidability.Verified.Termination.Fuel

/-!
# Termination Probes

Executable rows for the verified termination development under
`FormalSystem/Metalogic/Decidability/Verified/Termination/`. Each is a `#guard_msgs` row pinning a
measured value, so a change in the engine's behaviour on these shapes fails the test-suite build.
They are measurements, not proofs: the theorems they accompany live beside their definitions.

- `TimeTypeBound.lean` — `closureStep` stabilisation, including delayed-trigger cascade seeds.
- `Fuel.lean` — the world-discipline guard, `OrderDual` on engine-shaped orderings, and the
  proportional arm-fuel split.
- `MintBound/PostBlocking.lean` — the post-blocking pass run in sequence after a seed run.
- `MintBound/Measure.lean` — the branching witness's expansion terminates.
-/

namespace BimodalTest.Metalogic.Decidability.Verified.TerminationProbes

open FormalSystem.Syntax
open FormalSystem.Metalogic.Decidability

/-! ### Stabilisation probes

A closure operator nobody has watched halt is not evidence of anything, so the reduction above is
committed together with executable rows that run it. Each row reports the round at which
`closureStep` stops adding formulas, starting from the subformula closure of `φ`, together with the
resulting `|C|` — which is the exponent in the `2 ^ (2 * |C|)` bound.

These are probes, not proofs: they witness that the operator halts on concrete inputs and that
`tableauClosed_of_closureStep_subset` is therefore not vacuously stated. The general
termination theorem is the remaining T2 obligation, tracked in the plan.
-/

section TimeTypeBoundProbes

private def probeAtom (s : String) : Formula := Formula.atom (Atom.mkBase s)

/-- First round at which `closureStep` adds nothing, searching up to `fuel` rounds. -/
private def stabilisesAt (φ : Formula) (fuel : Nat) : Option (Nat × Nat) :=
  let rec go : Nat → Nat → Finset Formula → Option (Nat × Nat)
    | 0, _, _ => none
    | k + 1, n, C => if closureStep C ⊆ C then some (n, C.card) else go k (n + 1) (closureStep C)
  go fuel 0 (subformulasFinset φ)

-- `p`
/-- info: some (3, 8) -/
#guard_msgs in
#eval stabilisesAt (probeAtom "p") 8

-- `□p` — exercises `boxTemp`.
/-- info: some (4, 17) -/
#guard_msgs in
#eval stabilisesAt (Formula.box (probeAtom "p")) 8

-- `F p` — exercises `priorU`.
/-- info: some (3, 11) -/
#guard_msgs in
#eval stabilisesAt (Formula.someFuture (probeAtom "p")) 8

-- `G p` — `G` carries `F(¬p)` as a subformula, so this exercises `priorU` one level down.
/-- info: some (3, 13) -/
#guard_msgs in
#eval stabilisesAt (Formula.allFuture (probeAtom "p")) 8

-- `U(⊤, p) ∧ F(¬p)` — the real `priorUGap` trigger.
/-- info: some (3, 20) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.untl (probeAtom "p") Formula.top)
    (Formula.someFuture (probeAtom "p").neg)) 8

-- `K⁺p ∧ ¬K⁺(p ∧ U(p, ¬p))` — the real `sepRule` trigger.
/-- info: some (3, 30) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.kPlus (probeAtom "p"))
    (Formula.neg (Formula.kPlus
      (Formula.and (probeAtom "p") (Formula.untl (probeAtom "p").neg (probeAtom "p")))))) 8

/-! #### Cascade rows

The rows above start from formulas whose emission triggers are all visible in the seed. The rows
below are the adversarial ones: they are *built* so that a trigger only appears **after** a round
of closure, which is the shape that could in principle make the operator run away.

`probeGapBody g` is the raw implication whose negation is exactly the `priorUGap` trigger
`U(⊤, g) ∧ F(¬g)`. So `F (probeGapBody g)` carries no trigger at all in its subformulas, but
`priorUZ` emits `U(probeGapBody g, ¬probeGapBody g)`, and that emission's second component *is*
the trigger — one round late. Nesting `probeGapBody` inside itself stacks the construction, and
putting a `□` on top routes it through `allFuture` (whose `U(_, ⊤)` subformula is itself a
`priorUZ` trigger) as well.

The measured answer is the reason the confinement route below is worth pursuing: **the round count
stays at 4 no matter how deep the nesting goes**, while only `|C|` grows. Delaying a trigger does
not compound, because the delayed trigger's own emission introduces no further trigger.
-/

/-- The raw implication whose negation is the `priorUGap` trigger `U(⊤, g) ∧ F(¬g)`. -/
private def probeGapBody (g : Formula) : Formula :=
  Formula.imp (Formula.untl g Formula.top) (Formula.neg (Formula.someFuture g.neg))

-- `F(U(⊤,p) → ¬F(¬p))` — the trigger appears only after `priorUZ` fires.
/-- info: some (4, 22) -/
#guard_msgs in
#eval stabilisesAt (Formula.untl Formula.top (probeGapBody (probeAtom "p"))) 8

-- The same construction nested twice: still round 4.
/-- info: some (4, 33) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.untl Formula.top (probeGapBody (probeGapBody (probeAtom "p")))) 8

-- Nested three deep: still round 4. Depth of delay does not compound.
/-- info: some (4, 44) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.untl Formula.top (probeGapBody (probeGapBody (probeGapBody (probeAtom "p"))))) 8

-- `□` routes the same delayed trigger through `allFuture`.
/-- info: some (4, 28) -/
#guard_msgs in
#eval stabilisesAt (Formula.box (probeGapBody (probeAtom "p"))) 8

-- `□` on top of the doubly-nested delay.
/-- info: some (4, 42) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.box (Formula.untl Formula.top (probeGapBody (probeGapBody (probeAtom "p"))))) 8

-- The degenerate `g = ⊤` gap, where the emission `U(X, ⊤)` is itself a `priorUZ` trigger.
/-- info: some (3, 19) -/
#guard_msgs in
#eval stabilisesAt
  (Formula.and (Formula.untl Formula.top Formula.top)
    (Formula.someFuture Formula.top.neg)) 8

end TimeTypeBoundProbes

/-! ### World-discipline probes (`Fuel.lean`)

The engine's actual guard, `witnessPresent`, ignores the world it is asked about in its modal arms,
which is the S5 fact the world bound rests on.
-/

section WorldProbes

-- A witness at world `7` suppresses `boxNeg` asked at world `3`: the guard is
-- world-indifferent, which is the S5 fact the world bound is built on.
/-- info: true -/
#guard_msgs in
#eval witnessPresent .boxNeg
  (SignedFormula.neg (.box .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 0 }]
  TimeOrdering.empty

-- Same shape, witness at a different *time*: not suppressed. Time is the dimension the modal
-- guard does read, which is why the world bound is proportional to the time count.
/-- info: false -/
#guard_msgs in
#eval witnessPresent .boxNeg
  (SignedFormula.neg (.box .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 1 }]
  TimeOrdering.empty

-- The temporal mirror, for contrast: `allFutureNeg`'s guard holds the world fixed, so a witness
-- at another world does *not* suppress it. This is exactly why times need
-- `blocking_fires_of_card_lt` and worlds do not.
/-- info: false -/
#guard_msgs in
#eval witnessPresent .allFutureNeg
  (SignedFormula.neg (.allFuture .bot) { world := 3, time := 0 })
  [SignedFormula.neg .bot { world := 7, time := 1 }]
  ⟨[(0, 1)]⟩

end WorldProbes

/-! ### Duality probes

`OrderDual` is now discharged by `orderDual_holds`, but the rows are kept: they are what caught
the condition being true before the proof existed, and they remain the cheapest check that the
*statement* still says what it should on the shapes the engine actually builds: a chain
(`addFuture` repeated), a fork, a diamond, and a chain put through `identifyTime` — the one
operation that rewrites constraints rather than adding them, and hence the one most likely to
break a duality.
-/

section DualityProbes

/-- The `OrderDual` condition, as a decidable check over a finite set of times. -/
private def dualCheck (ord : TimeOrdering) (ts : List TimeIndex) : Bool :=
  ts.all fun t₁ => (ord.futureOf t₁).all fun t₂ => (ord.pastOf t₂).contains t₁

-- A chain `0 < 1 < 2 < 3`.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (1, 2), (2, 3)]⟩ [0, 1, 2, 3]

-- A fork: `0 < 1`, `0 < 2`, `2 < 3`.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (0, 2), (2, 3)]⟩ [0, 1, 2, 3]

-- A diamond: two incomparable middles rejoining.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨[(0, 1), (0, 2), (1, 3), (2, 3)]⟩ [0, 1, 2, 3]

-- The chain after `identifyTime 2 1` — the arm of `timeLinearity` that rewrites constraints.
/-- info: true -/
#guard_msgs in
#eval dualCheck ((⟨[(0, 1), (1, 2), (2, 3)]⟩ : TimeOrdering).identifyTime 2 1) [0, 1, 3]

-- A long chain, well past the ordering depths the corpus produces.
/-- info: true -/
#guard_msgs in
#eval dualCheck ⟨(List.range 30).map fun i => (i, i + 1)⟩ (List.range 31)

end DualityProbes

/-! ### Arm-fuel probes

The shortfall above is a claim about a `#eval`-able function, so it is checked by running it
rather than by reading it — the same discipline as the duality and world-discipline rows.
-/

section SplitFuelProbes

-- Three arms, a thousand units at the parent: each arm receives a *third*, not the whole.
-- This is the shortfall, at the smallest branching factor the rule set produces.
/-- info: [333, 333, 333] -/
#guard_msgs in
#eval allocateFuelProportionally 1000 [([] : Branch), [], []]

-- The floor is real: two units at the parent leave one per arm, never zero.
/-- info: [1, 1] -/
#guard_msgs in
#eval allocateFuelProportionally 2 [([] : Branch), []]

-- And the shortfall compounds: a second split inside an arm leaves a ninth of the original.
/-- info: [111, 111, 111] -/
#guard_msgs in
#eval allocateFuelProportionally 333 [([] : Branch), [], []]

end SplitFuelProbes

/-! ### Post-blocking run probe (`MintBound/PostBlocking.lean`) -/

section PostBlockingRunProbe

/-- The terminus's own two calls, run in sequence and reported as three booleans: the seed run
reached an open exit; the post-blocking pass strictly extended that exit; the blocking-aware
saturation test closed on the pass's output. -/
private def postBlockingRunProbe (phi : Formula) (fuel : Nat)
    (fc : FormalSystem.ProofSystem.FrameClass) : Bool × Bool × Bool :=
  match expandBranchWithFuel (seedBranch phi) fuel TimeOrdering.empty fc
      (maxBranches := 50000) with
  | some (.inr (ob, oOrd, _)) =>
      match saturateBlocked ob fuel oOrd fc with
      | some (.inr (satBr, satOrd)) =>
          (true, ob.length < satBr.length,
            (findUnexpandedUnblockedWith satBr satOrd fc
              (blockedTimes satBr satOrd fc (armTracker satBr))).isNone)
      | _ => (true, false, false)
  | _ => (false, false, false)

-- The propositional seed `p → q`, at every frame class. Frame classes are written out rather
-- than abbreviated: inside this namespace the `.Dense` shorthand resolves elsewhere, and the
-- probe silently reported an unexpanded run until the names were qualified.
/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.imp mfp mfq) 40 FormalSystem.ProofSystem.FrameClass.Base

/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.imp mfp mfq) 40 FormalSystem.ProofSystem.FrameClass.Dense

/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.imp mfp mfq) 40 FormalSystem.ProofSystem.FrameClass.ZTime

/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.imp mfp mfq) 40 FormalSystem.ProofSystem.FrameClass.RTime

-- The temporal seed `F p = ⊤ U p`, so the witness set is not purely propositional.
/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.untl (Formula.imp .bot .bot) mfp) 40
  FormalSystem.ProofSystem.FrameClass.Base

/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.untl (Formula.imp .bot .bot) mfp) 40
  FormalSystem.ProofSystem.FrameClass.RTime

-- `□p`, whose expansion mints a fresh world — the shape whose *unrestricted* counterexample
-- `freshWorldBranch` is. The engine never hands that branch to the pass, and the run settles.
/-- info: (true, true, true) -/
#guard_msgs in
#eval postBlockingRunProbe (Formula.box mfp) 40 FormalSystem.ProofSystem.FrameClass.Base

end PostBlockingRunProbe

/-! ### Branching non-vacuity (`MintBound/Measure.lean`)

At `branchingWitness` the engine's step is a genuine two-arm split (`branchingWitness_splits`, by
`decide`), and the expansion at that branch still terminates.
-/

section BranchingNonVacuity

-- …and the expansion at that branch still terminates.
/-- info: true -/
#guard_msgs in
#eval (expandBranchWithFuel branchingWitness 500).isSome

end BranchingNonVacuity

end BimodalTest.Metalogic.Decidability.Verified.TerminationProbes
