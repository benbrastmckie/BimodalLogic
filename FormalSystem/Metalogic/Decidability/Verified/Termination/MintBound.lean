/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Invariants
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.OrderingTimes
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPotential
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Measure
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Terminus
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.ClosureResidual
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.TimeCensus
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.TimeReuse
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MonotoneIssuance
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.OrientedGate
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.FourComponent
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.SigmaFixed
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.LabelHeadroom
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.PostBlocking
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.UntlSnceFree
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.BoxFree
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.GapPotential
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.MintPaysAssembly
import FormalSystem.Metalogic.Decidability.Verified.Termination.MintBound.Register

/-!
# The mint bound — an independent ceiling on fresh-time minting

`Fuel.lean` (T3) turns the formula stock (T1) and the time-type bound (T2) into a fuel figure at
which `expandBranchWithFuel` cannot exhaust, but its totality theorem
`expandBranchWithFuel_isSome_of_noSplit` is scoped to runs that never branch. Lifting that scope
needs a bound on the number of **fresh-time mints** along a run that is independent of branch
growth, because at an ordered split's third arm (`Branch.identifyTime`) the branch shrinks as a
set and the branch-cardinality measure the extending case relies on is not available.

This file is an aggregator: it declares nothing and re-exports the submodules below, which supply
that bound in four blocks.

## A. The irreflexivity invariant (`IrreflOrd`)

Witness preservation across the identification arm is **conditional** on the ordering carrying no
self-loop. That is not a convenience hypothesis: `TimeOrdering.identifyTime` drops every
constraint whose two components rename to the same index, including a pre-existing `(a, a)`, and
a witness reachable only around such a self-loop is destroyed. The counterexample
`witnessPresent_identifyTime_unconditional_false` refutes the unconditional form outright.
`IrreflOrd` is therefore established as an engine-level run invariant before anything is built on
top of it.

## B. Reachability transport and witness preservation

`futureOf`/`pastOf` reachability transports along the identification renaming `rho`, length
preserving, so a witness found at one fuel figure is re-found at the same one. That lifts to
`witnessPresent` for all eight fresh-label rules, with every other rule covered by a *proved*
vacuity rather than an assumed one.

## C. The mint potential

The count of `(rule, signed formula)` pairs still eligible to mint. Witness preservation makes it
non-increasing along a run and a mint makes it strictly decrease, which is what converts "each
pair mints at most once" into a per-state measure an induction can carry.

## D. The amortized counting chain

`#mints`, `#identifications`, total shrinkage, and `#extensions`, each bounded absolutely, feeding
the branch-budget-carrying restatement of the totality theorem and its terminus at
`buildTableauAt`.

## Submodules

Listed in dependency order. Every module below `Invariants` imports only earlier ones, and the
graph is a DAG with two parallel branches rather than a chain: `TimeCensus` and `TimeReuse` both
hang off the `MintPotential`/`Measure` foundation rather than off the closure chain.

- `Invariants`: the renaming `rho`/`rhoSF`, `IrreflOrd` and its preservation at all four result
  shapes, the `OrdTimesLeMaxTime` ordering-times invariant, the reachability transport stack, and
  the pick bridges `pickOrd`/`pickBranches`
- `OrderingTimes`: `OrdTimesLeMaxTime` at the branching shapes together with the refutation at the
  ordered split's identification arm, the strengthened `OrdTimesKnown`, the engine-level run
  invariant, and `witnessPresent` monotonicity
- `MintPotential`: the world dimension and a time bound that does not go through the mint chain,
  the fresh-world discipline, `mintPotential` itself, the once-only bound, the counting chain, and
  the fuel induction over an abstract measure
- `Measure`: the concrete measure and the fuel figure it earns, the difficulty toolkit and the
  scope decision it settles, and the closure residual as literally stated — refuted at every `D`
- `Terminus`: the terminus at `buildTableauAt`, and its sibling terminus at the length budget
- `ClosureResidual`: the repaired closure residual, the four consuming theorems restated at it,
  and the refutations of clause 1's label and formula dimensions
- `TimeCensus`: the time coordinate — the minting census, `applyRule_emitted_time_mem` as the time
  analogue of the world sweep, and the time dichotomy lifted to the engine
- `TimeReuse`: the verdict on `MintPaysForTime` — the refuting configuration, the repair attempted
  and blocked, and the fourth measure component (the self-guard discharge potential)
- `MonotoneIssuance`: monotone time issuance at the identification-side gate, run-level
  monotonicity off the gate configuration, and invariant survival at the oriented arm
- `OrientedGate`: the self-guard component re-gated at the oriented arm, its structural facts, and
  the σ-hit obligation discharged rather than carried
- `FourComponent`: the four-component measure, its per-step bundle and fuel figure, and the
  terminus chain restated at the repaired predicate
- `SigmaFixed`: the formula-level σ obligation and the refutation it forces, then `SigmaFixed` —
  the formula-level repair the residual is restated at
- `LabelHeadroom`: clause 1's label dimension discharged from branch-side headroom, with the
  refutation that generalizes to every nonempty `L` rather than one witness
- `PostBlocking`: the post-blocking settlement residual, refuted and repaired; the narrowed repair
  at what the terminus instantiates it at, and the verdict on it
- `UntlSnceFree`: the residual discharged at a **nonempty** universe over the `untl`/`snce`-free
  fragment, with the time sweep traded for branch-level freeness
- `BoxFree`: the label residual **replaced** — the `boxFree` shape gate and the world coordinate,
  and the boundary at which the route stops
- `GapPotential`: the density coordinate — `gapPotential` over the fixed index set `U ×ˢ U`,
  its ceiling, growth and identification-arm transport, the strict drop at a `densityRule`
  step, the refutation of `MintPaysForTimeFixed` at `.Dense`/`.RTime`, and the repaired
  residual `MintPaysForTimeGap` the repair is stated at
- `MintPaysAssembly`: the engine-level assembly — `MintPaysForTimeFixed` off `.Dense`, at any
  universe, via the four-bucket case split at the `pickBranches` level
- `Register`: the do-not-re-attempt register — twenty-five statements that look like the natural
  next lemma and are **not** available, each cited by declaration name and, where one exists, by
  refuting witness. It is documentation of what did not work, carries no declaration, and is kept
  in its own module so that a reader can always tell locally whether they are reading a live
  result or a record of a refuted approach

## Placement

Everything here is downstream of `Fuel.lean` and purely additive: no declaration in
`Fuel.lean`, `Saturation.lean`, or `Tableau.lean` is edited, and in particular `buildTableau`,
its default fuel, and `expandBranchWithFuel`'s default branch cap are untouched.
-/
