/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.ReflexiveCanonical
import FormalSystem.Metalogic.WeakCanonical.TruthLemma
import FormalSystem.Metalogic.WeakCanonical.FrameProperties
import FormalSystem.Metalogic.WeakCanonical.ChronicleExtraction
import FormalSystem.Metalogic.WeakCanonical.MonadicFO
import FormalSystem.Metalogic.WeakCanonical.NEquivalence
import FormalSystem.Metalogic.WeakCanonical.NormalForm
import FormalSystem.Metalogic.WeakCanonical.Kamp.ESigmaExpansion
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import FormalSystem.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import FormalSystem.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas
import FormalSystem.Metalogic.WeakCanonical.OrderedSum
import FormalSystem.Metalogic.WeakCanonical.Table
import FormalSystem.Metalogic.WeakCanonical.PriorDefsDense
import FormalSystem.Metalogic.WeakCanonical.Kamp.DedekindINFDense
import FormalSystem.Metalogic.WeakCanonical.Kamp.KPlusFaithful
import FormalSystem.Metalogic.WeakCanonical.PriorExpressivenessDense
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue
import FormalSystem.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import FormalSystem.Metalogic.WeakCanonical.StaviConnectives
import FormalSystem.Metalogic.WeakCanonical.EFGames.StaviCompleteness
import FormalSystem.Metalogic.WeakCanonical.Expressiveness.Theorem6
import FormalSystem.Metalogic.WeakCanonical.Transfer
-- CI edge only: `Chronicle/ChronicleMonadicBridge.lean` sits ABOVE `Transfer.lean` in the import
-- graph despite living in the `BXCanonical/Chronicle/` directory, so no Chronicle aggregator can
-- reach it. Listed here, next to its lowest dependency, so it cannot rot out of the build closure.
import FormalSystem.Metalogic.BXCanonical.Chronicle.ChronicleMonadicBridge
-- CI edge only: the `DenseModelSurgery/` chain (Reynolds §6) is a leaf with no consumer yet —
-- Lemmas 5 onwards are still to be built on top of it. Listed here so it stays inside the
-- `lake build` closure rather than compiling only when named explicitly. `Defs.lean` is kept
-- listed alongside its consumer rather than dropped, so that removing `Lemma34.lean` from this
-- list could never silently drop the §6 vocabulary out of the closure too.
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Defs
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma34
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Dual
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma5
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.BadIntervals
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.TruthTransfer
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.NoGaps
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Singletons
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.ChronicleInstance
-- CI edge only: `GroupModel/GoodGroupable.lean` (Reynolds §8 p.185, transposed to the
-- non-Archimedean discrete carrier `ℚ ×ₗ ℤ`) is a leaf with no consumer yet — the companion
-- lemma that consumes `goodGroupable` is still to be built on top of it. Listed here on the
-- `DenseModelSurgery/` precedent above, so it stays inside the `lake build` closure rather than
-- compiling only when named explicitly.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.GoodGroupable
-- CI edge only: `GroupModel/BlockDecomposition.lean` (Doets 1987 ch. 7 step 9 at a discrete
-- unbounded flow: `M ≃o Σ_{i∈I} (ℤ, cᵢ)`) is a leaf until the companion lemma
-- (`GroupModel/GroupableCompanion.lean`) consumes it. Listed here on the same precedent.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.BlockDecomposition
-- CI edge only: `GroupModel/MonoDiscrete.lean` (Doets 1.0.2/1.0.3: monochromatic discrete
-- completeness at depth k, all three endpoint profiles) is a leaf until the Ramsey
-- factorization (`GroupModel/RamseyFactorization.lean`) consumes it. Same precedent.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.MonoDiscrete
-- CI edge only: `GroupModel/RamseyFactorization.lean` (infinite Ramsey for pairs + per-block
-- inflation `inflate_right`/`inflate_left`) is a leaf until the companion assembly
-- (`GroupModel/GroupableCompanion.lean`) consumes it. Same precedent.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.RamseyFactorization
-- `GroupModel/GroupableCompanion.lean` (`companionGeneral`/`companionChronicle`, the Base
-- analogue of `limitdom_is_good`) is no longer a leaf: `GroupModel/CountermodelBase.lean`
-- consumes `companionChronicle` to prove `countermodel_discrete`. Both are ordinary imports.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion
-- `GroupModel/CountermodelBase.lean` hosts `countermodel_discrete`, the Base-MCS discrete
-- branch of `BXCanonical.completeness`. It lives beside the companion lemma rather than in
-- `Transfer.lean` because `Transfer ← ReynoldsBridge ← GroupableCompanion` makes in-place
-- closure an import cycle; the fully-qualified name is preserved, so no call site moved.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.CountermodelBase

/-!
# WeakCanonical: Reynolds/Doets Discrete Completeness

This module provides the Reynolds/Doets discrete completeness proof for TM
bimodal logic, bypassing the chronicle construction's `succ_cofinal` sorry (that whole chain
is archived — see `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`).

## Architecture

1. **ReflexiveCanonical**: Domain, relation (reflexive), valuation
2. **TruthLemma**: Truth lemma; sorry-free, including the backward directions
   `G_backward_mcs` and `H_backward_mcs`
3. **FrameProperties**: Z1, Prior-UZ/SZ, seriality in canonical frame
4. **ChronicleExtraction**: Extract chronicle as prior structure (Corollary 3)
5. **NEquivalence**: Monadic FO framework, OrderedMonadicStructure, KEquivalenceFramework
6. **OrderedSum**: Doets Lemma 1.4/1.5 (ordered sum preservation)
7. **Table**: Temporal-to-monadic table translation — `table`, `table_depth_bound`,
   `TemporalTruth` and `table_correctness` are all landed and sorry-free
8. **IntegerModel**: Good/very good, ContempEquiv, one-class, and the sorry-free bridge
   `countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean`)
9. **Transfer**: `truth_transfer` and the chronicle-side transfer lemmas
10. **GroupModel**: the `ℚ ×ₗ ℤ` companion chain — `goodGroupable`, block decomposition, Ramsey
   factorization, `companionGeneral`/`companionChronicle`, and `countermodel_discrete`
   (`GroupModel/CountermodelBase.lean`)

## Main Export

`countermodel_discrete` — the Base-MCS discrete branch of `completeness`, hosted in
`GroupModel/CountermodelBase.lean`. It was introduced as a drop-in replacement for
`dd_countermodel_chronicle_discrete` (Chronicle/ChronicleToCountermodel.lean), which has since
been archived to `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`. It is
proved at the non-Archimedean discrete carrier `ℚ ×ₗ ℤ` off `companionChronicle`
(`GroupModel/GroupableCompanion.lean`); the separate sorry-free discrete result is
`completeness_discrete`, via `countermodel_discrete_reynolds_v2`
(IntegerModel/ReynoldsBridge.lean) at `ℤ`.

It lives in `GroupModel/` rather than in `Transfer.lean` because
`Transfer ← IntegerModel/ReynoldsBridge ← GroupModel/GroupableCompanion` makes closing it in
place an import cycle. The fully-qualified name
`FormalSystem.Metalogic.WeakCanonical.countermodel_discrete` is unchanged by the move.

## Status

**This subtree is sorry-free**, as is all of `FormalSystem/` outside `Boneyard/`. Check C3 of
`scripts/check-module-invariants.sh` asserts the structural-`sorry` inventory is ZERO by
content, over the whole tree — so the claim is re-derivable rather than maintained by hand, and
no line numbers are recorded here. A new structural `sorry` anywhere is a C3 regression.

Every declaration in this subtree is sorry-free, which for a live declaration follows from its
existence given C3. In particular `G_backward_mcs` and `H_backward_mcs` (`TruthLemma.lean`),
`class KEquivalenceFramework` (`NEquivalence.lean`), and `table_correctness` (`Table.lean`) are
all proved.

**Both consumer-facing completeness results are sorry-free.**
`BXCanonical.completeness_discrete` reaches its countermodel via
`countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean`); `BXCanonical.completeness`
at `.Base` reaches its discrete branch via `countermodel_discrete`
(`GroupModel/CountermodelBase.lean`). Check C2 records both as depending on
`[propext, Classical.choice, Quot.sound]`, with no `sorryAx`.

All definitions are NON-VACUOUS (no `True`, `trivial`, or `Unit` bodies).

## References
- Reynolds 1994, Theorems 14-18
- Doets 1989, Section 1 (k-types, Lemmas 1.4, 1.5)
- Design provenance: the chronicle → Reynolds completeness route for weak reflexive
  completeness as a conservative extension (status and gating summarized above)
-/
