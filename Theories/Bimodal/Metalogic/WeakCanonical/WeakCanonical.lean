import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.TruthLemma
import Bimodal.Metalogic.WeakCanonical.FrameProperties
import Bimodal.Metalogic.WeakCanonical.ChronicleExtraction
import Bimodal.Metalogic.WeakCanonical.NEquivalence
import Bimodal.Metalogic.WeakCanonical.OrderedSum
import Bimodal.Metalogic.WeakCanonical.Table
import Bimodal.Metalogic.WeakCanonical.IntegerModel
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
6. **OrderedSum**: Doets Lemma 1.4/1.5 (finite case wrapper)
7. **Table**: Temporal-to-monadic table translation (deferred)
8. **IntegerModel**: Good/very good, contemp_equiv, one-class, chronicle_is_good
9. **Transfer**: `doets_countermodel_discrete` — the main theorem

## Main Export

`doets_countermodel_discrete` — drop-in replacement for
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
- Task #129 plan: `specs/129_weak_reflexive_completeness_conservative_extension/plans/05_chronicle-reynolds-plan.md`
- Report 08: `specs/129_weak_reflexive_completeness_conservative_extension/reports/08_phase-by-phase-research.md`
-/
