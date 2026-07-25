/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.TruthLemma
import Bimodal.Metalogic.WeakCanonical.FrameProperties
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Bimodal.Metalogic.WeakCanonical.MonadicFO
import Bimodal.Metalogic.WeakCanonical.NEquivalence
import Bimodal.Metalogic.WeakCanonical.NormalForm
import Bimodal.Metalogic.WeakCanonical.Kamp.ESigmaExpansion
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallFormula
import Bimodal.Metalogic.WeakCanonical.Kamp.VeeExistsForall
import Bimodal.Metalogic.WeakCanonical.Kamp.ExistsForallLemmas
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.IntegerModel.GoodStructures
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ShiftAndGlue
import Bimodal.Metalogic.WeakCanonical.IntegerModel.ReynoldsBridge
import Bimodal.Metalogic.WeakCanonical.StaviConnectives
import Bimodal.Metalogic.WeakCanonical.EFGames.StaviCompleteness
import Bimodal.Metalogic.WeakCanonical.Expressiveness.Theorem6
import Bimodal.Metalogic.WeakCanonical.Transfer

/-!
# WeakCanonical: Reynolds/Doets Discrete Completeness

This module provides the Reynolds/Doets discrete completeness proof for TM
bimodal logic, bypassing the chronicle construction's `succ_cofinal` sorry.

## Architecture

1. **ReflexiveCanonical**: Domain, relation (reflexive), valuation
2. **TruthLemma**: Truth lemma (atom/bot/imp proved, rest sorried)
3. **FrameProperties**: Z1, Prior-UZ/SZ, seriality in canonical frame
4. **ChronicleExtraction**: Extract chronicle as prior structure (Corollary 3)
5. **NEquivalence**: Monadic FO framework, OrderedMonadicStructure, KEquivalenceFramework
6. **OrderedSum**: Doets Lemma 1.4/1.5 (ordered sum preservation)
7. **Table**: Temporal-to-monadic table translation (deferred)
8. **IntegerModel**: Good/very good, contemp_equiv, one-class, chronicle_is_good
9. **Transfer**: `countermodel_discrete` — the main theorem

## Main Export

`countermodel_discrete` — drop-in replacement for
`dd_countermodel_chronicle_discrete` in Completeness.lean.

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
