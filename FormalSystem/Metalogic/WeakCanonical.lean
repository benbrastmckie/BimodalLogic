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
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.Lemma5
import FormalSystem.Metalogic.WeakCanonical.DenseModelSurgery.BadIntervals

/-!
# WeakCanonical: Reynolds/Doets Discrete Completeness

This module provides the Reynolds/Doets discrete completeness proof for TM
bimodal logic, bypassing the chronicle construction's `succ_cofinal` sorry (that whole chain
is archived — see `Boneyard/DeadChronicleGapElimination/ChronicleGapChainExcision.lean`).

## Architecture

1. **ReflexiveCanonical**: Domain, relation (reflexive), valuation
2. **TruthLemma**: Truth lemma (atom/bot/imp proved, rest sorried)
3. **FrameProperties**: Z1, Prior-UZ/SZ, seriality in canonical frame
4. **ChronicleExtraction**: Extract chronicle as prior structure (Corollary 3)
5. **NEquivalence**: Monadic FO framework, OrderedMonadicStructure, KEquivalenceFramework
6. **OrderedSum**: Doets Lemma 1.4/1.5 (ordered sum preservation)
7. **Table**: Temporal-to-monadic table translation (deferred)
8. **IntegerModel**: Good/very good, ContempEquiv, one-class, chronicle_is_good
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

The full Reynolds construction has documented sorries at:
- Truth lemma: G/H backward, Until/Since
- KEquivalenceFramework: awaiting Tarski semantics instance
- Table correctness: monadic FO satisfaction deferred
- One-class theorem: depends on gap-elimination lemmas
- chronicle_is_good: cofinal sequence construction

All definitions are NON-VACUOUS (no `True`, `trivial`, or `Unit` bodies).
Sorries are clean — they represent standard model-theoretic results
(Doets 1989) that follow once monadic FO Tarski semantics is formalized.

Currently delegates to the chronicle construction as interim fallback.
The structural Reynolds pipeline is fully wired for activation when
the Phase 3-5 sorries are resolved.

## References
- Reynolds 1994, Theorems 14-18
- Doets 1989, Section 1 (k-types, Lemmas 1.4, 1.5)
- Design provenance: the chronicle → Reynolds completeness route for weak reflexive
  completeness as a conservative extension (status and gating summarized above)
-/
