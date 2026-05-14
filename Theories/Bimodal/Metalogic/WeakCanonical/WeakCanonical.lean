import Bimodal.Metalogic.WeakCanonical.ReflexiveCanonical
import Bimodal.Metalogic.WeakCanonical.TruthLemma
import Bimodal.Metalogic.WeakCanonical.FrameProperties
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
4. **NEquivalence**: Monadic FO framework (k-types, k-equivalence)
5. **OrderedSum**: Ordered sum with Doets Lemma 1.4/1.5
6. **Table**: Temporal-to-monadic table translation
7. **IntegerModel**: Good/very good, one-class, Z-model extraction
8. **Transfer**: `doets_countermodel_discrete` — the main theorem

## Main Export

`doets_countermodel_discrete` — drop-in replacement for
`dd_countermodel_chronicle_discrete` in Completeness.lean.

## Status

The full Reynolds construction has documented sorries at:
- Truth lemma: G/H backward, Until/Since
- Table correctness
- One-class theorem
- Monadic satisfaction formalization

Currently delegates to the chronicle construction as interim fallback.
-/
