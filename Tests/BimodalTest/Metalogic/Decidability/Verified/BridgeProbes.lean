/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Bridge.Embed
import FormalSystem.Metalogic.Decidability.Verified.Bridge.IntGaps

/-!
# Bridge Probes

Executable rows for `FormalSystem/Metalogic/Decidability/Verified/Bridge/`: the branch-order gate
of `BranchOrder.lean`, and the computed `ℤ` placement shared by `Embed.lean` and `IntGaps.lean`.
-/

namespace BimodalTest.Metalogic.Decidability.Verified.BridgeProbes

open FormalSystem.Metalogic.Decidability
open FormalSystem.Metalogic.Decidability.Verified.Bridge

/-! ## Regression probes

These pin the gate's behaviour on the shapes the repair has to move. They are `#guard_msgs` rows so
a silent change in `futureOf`, `knownTimes` or `identifyTime` fails the test-suite build rather than
being absorbed.
-/

section BranchOrderProbes

/-- A three-element chain `0 < 1 < 2`, all three times live on the branch. Total, acyclic,
transitive — the gate passes. -/
private def chainBranch : Branch :=
  [ { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 0 } },
    { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 1 } },
    { sign := .pos, formula := .atom (.mkBase "p"), label := { world := 0, time := 2 } } ]

private def chainOrd : TimeOrdering := ⟨[(0, 1), (1, 2), (0, 2)]⟩

/-- info: true -/
#guard_msgs in
#eval branchOrderValid chainBranch chainOrd

/-- The same chain *without* the transitive edge. `futureOf` is a transitive closure, so the
gate still passes — this is the probe that would catch a regression to a direct-edge reading
of `futureOf` (which would break `G p → G G p`; see `futureOf`'s docstring). -/
private def chainOrdNoShortcut : TimeOrdering := ⟨[(0, 1), (1, 2)]⟩

/-- info: true -/
#guard_msgs in
#eval branchOrderValid chainBranch chainOrdNoShortcut

/-- Two incomparable siblings under a common root — the measured `¬(F(G p) ∧ F(¬p))` shape.
Totality fails, so the gate fails. This is the row the order-level branching rule has to flip. -/
private def forkOrd : TimeOrdering := ⟨[(0, 1), (0, 2)]⟩

/-- info: false -/
#guard_msgs in
#eval branchOrderValid chainBranch forkOrd

/-- Totality alone is not the gate: a **cycle** makes every time reachable from every other, so
`timeOrderTotal` reports `true` while the order is inconsistent. `branchOrderValid` rejects it on
the irreflexivity conjunct. This row is the reason the gate is three conditions. -/
private def cycleOrd : TimeOrdering := ⟨[(0, 1), (1, 2), (2, 0)]⟩

/-- info: true -/
#guard_msgs in
#eval timeOrderTotal chainBranch cycleOrd

/-- info: false -/
#guard_msgs in
#eval branchOrderValid chainBranch cycleOrd

-- Identification is the sanctioned repair (never edge-addition): identifying `2` into `1`
-- collapses the fork to a two-element chain, and the gate passes on the identified branch.
--
-- These two rows call `Branch.identifyTime` / `TimeOrdering.identifyTime` **directly**, not through
-- `timeLinearity`'s arm 3, so they are unaffected by that arm's orientation (which retires
-- `min t₁ t₂` rather than `t₂`). They are about the loop-blocking repair, whose choice of which
-- numeral survives is its own; nothing here is a claim about the ordered split.
/-- info: true -/
#guard_msgs in
#eval branchOrderValid (chainBranch.identifyTime 2 1) (forkOrd.identifyTime 2 1)

-- The identified branch really did lose a time — `knownTimes` shrinks, which is the measure the
-- loop-unwinding argument inducts on.
/-- info: [0, 1] -/
#guard_msgs in
#eval (chainBranch.identifyTime 2 1).knownTimes

end BranchOrderProbes

/-! ## `ℤ` placement of a finite order

The `ℤ` embedding of `Fin 4` is the identity cast, in order: contiguous, hence no interior gaps.
Both `Embed.lean` (the embedding) and `IntGaps.lean` (the contiguity claim) rest on this value.
-/

section Placement

/-- info: [0, 1, 2, 3] -/
#guard_msgs in
#eval (List.finRange 4).map (finOrderEmbInt 4)

end Placement

end BimodalTest.Metalogic.Decidability.Verified.BridgeProbes
