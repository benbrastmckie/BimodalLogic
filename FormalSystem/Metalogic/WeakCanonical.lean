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
-- CI edge only: `GroupModel/GroupableCompanion.lean` (`companionGeneral`/`companionChronicle`,
-- the Base analogue of `limitdom_is_good`) is a leaf until the discrete-branch replacement of
-- `countermodel_discrete` consumes it. Same precedent.
import FormalSystem.Metalogic.WeakCanonical.GroupModel.GroupableCompanion
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
9. **Transfer**: `countermodel_discrete` — the main theorem

## Main Export

`countermodel_discrete` — the Base-MCS discrete branch of `completeness`. It was introduced as a
drop-in replacement for `dd_countermodel_chronicle_discrete`
(Chronicle/ChronicleToCountermodel.lean),
which has since been
archived to `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`.
`countermodel_discrete` carries the repository's sole live `sorry`; the sorry-free discrete result
is `completeness_discrete`, via `countermodel_discrete_reynolds_v2`
(IntegerModel/ReynoldsBridge.lean).

## Status

**This subtree carries exactly one structural `sorry`**: `countermodel_discrete`, in
`WeakCanonical/Transfer.lean`. It is also the repository's only one. Check C3 of
`scripts/check-module-invariants.sh` asserts this by content — it locates the enclosing
declaration by scanning backwards from the `sorry`, never by line number — so the claim is
re-derivable rather than maintained by hand, and no line number for it is recorded here.

Every other declaration in this subtree is sorry-free, which for a live declaration follows from
its existence given C3. In particular `G_backward_mcs` and `H_backward_mcs` (`TruthLemma.lean`),
`class KEquivalenceFramework` (`NEquivalence.lean`), and `table_correctness` (`Table.lean`) are
all proved.

**The consumer-facing discrete result routes around the one `sorry`.**
`BXCanonical.completeness_discrete` reaches its countermodel via
`countermodel_discrete_reynolds_v2` (`IntegerModel/ReynoldsBridge.lean`) rather than through
`countermodel_discrete`, and is therefore proved *and* sorry-free — check C2 records it as
depending on `[propext, Classical.choice, Quot.sound]`, with no `sorryAx`. This is a different
property from `BXCanonical.completeness` at `.Base`, which is proved but does depend on
`sorryAx`; C2 pins both, and the distinction is deliberate.

All definitions are NON-VACUOUS (no `True`, `trivial`, or `Unit` bodies).

## References
- Reynolds 1994, Theorems 14-18
- Doets 1989, Section 1 (k-types, Lemmas 1.4, 1.5)
- Design provenance: the chronicle → Reynolds completeness route for weak reflexive
  completeness as a conservative extension (status and gating summarized above)
-/
