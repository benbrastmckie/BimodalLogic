/-
Copyright (c) 2026 Benjamin Brast-McKie. All rights reserved.
Released under Apache 2.0 license as described in the file LICENSE.
Authors: Benjamin Brast-McKie
-/

import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Basic
import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Segment
import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Family
import FormalSystem.Metalogic.WeakCanonical.KTypeSummary.Saturation

/-!
# `KTypeSummary` — Büchi's complementation chain in the monadic `k`-type idiom

Aggregator for the `k`-type summary substrate: Büchi's complementation chain (Thomas 1997
§5.1) transposed to monadic `k`-types of coloured segments of the `ℤ` time axis. See
`KTypeSummary/Basic.lean` for the six-step table, the owning module of each step, and the scope
disclaimer — no complexity bound is claimed and no `⊡` condition is reduced to a `k`-type target.

## Modules

* `KTypeSummary.Basic` — the cluster root and step 2, `kType_finite`.
* `KTypeSummary.Segment` — step 3′: the segment carrier `segZ` and the block-as-segment-sum
  lemma `kEquiv_zFiber_segSum`.
* `KTypeSummary.Family` — steps 3 and 4: the bi-infinite family `SegmentFactorization`/`InFamily`
  and its Ramsey cover `exists_zFactorization`/`family_cover`/`exists_matching_factorization`.
* `KTypeSummary.Saturation` — step 5a: matched segment types give `≡ₖ` blocks
  (`kEquiv_zFiber_of_matching_segments`), so the block `k`-type is a function of the family
  (`kTypeOf_zFiber_eq_of_sameTriple`, `kTypeOf_zFiber_eq_of_inFamily`).

Later steps of the chain are appended here as their modules land.
-/
