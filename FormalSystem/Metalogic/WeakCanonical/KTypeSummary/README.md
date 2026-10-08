# KTypeSummary — Büchi's complementation chain in the monadic `k`-type idiom

This directory is the **universal-summary substrate** for the `⊡` fibre check on the seam-gluing
route: Büchi's complementation chain (Thomas 1997, *Languages, Automata, and Logic*, §5.1, p. 30)
transposed from finite words and congruence classes to **monadic `k`-types of coloured segments
of the `ℤ` time axis**. Where Büchi colours a pair of positions by the congruence class of the
word between them, this cluster colours a pair of times `a < b` by `kTypeOf sig k (segZ sig c a b)`
and applies infinite Ramsey for pairs (`infinite_ramsey_pairs`, proved in this tree because
Mathlib does not carry it at pin `v4.33.0-rc1`). The transposition is licensed by the
observation cslib's own `buchiFamily_cover` docstring makes about the argument: it *"does not
depend on any details of the congruence other than that it is of finite index"* — and the
finite-index fact for `k`-types is `kType_finite`.

The cluster sits beside its ingredients: `KType`/`kTypeOf`/`KEquiv` (`../NEquivalence.lean`),
`zFiber` (`../GroupModel/BlockDecomposition.lean`), and the mixing lemma
`kEquiv_orderedSum_of_kEquiv_colour` (`../MixedSum.lean`), which is the single piece that makes
saturation tractable. cslib is cited for shape only: nothing here imports, ports, or `require`s
it.

## Why this cluster exists

Checking `⊡φ` over the seam-gluing path space (`plusStab_iff_omega`,
`FormalSystem/PlusLanguage/PlusRayFibre.lean`) needs a summary device that quantifies over *all*
paths, hence is complementation-shaped, and that works over the **time axis** with a finite
alphabet of per-time summaries rather than over states — because finite width is refuted
(`FormalSystem.Metalogic.Decidability.PlusSlicedCertificate.NoFiniteWidth.not_finite_width_fmp`)
and pigeonhole-over-states lasso summaries are refuted on infinite acyclic fibres
(`not_lasso_sufficient_on_chain`, `specs/evidence/seam-gluing-ray-product/device-selection-probe.lean`).
Büchi's Ramsey-over-time chain is exactly such a device, and four of its six steps already
existed in this tree, proved and axiom-clean, as private ingredients of the per-block inflation
in `../GroupModel/RamseyFactorization.lean`. This cluster publishes them as a named chain and
closes the step they did not cover: saturation.

## The six-step chain

| Step | Büchi (Thomas 1997 §5.1) | This tree | Module | Status |
|---|---|---|---|---|
| 1 | finite-index right congruence on finite words | `KType`, `kTypeOf`, `KEquiv` | `../NEquivalence.lean` | landed (pre-existing) |
| 2 | the congruence has finite index | `kType_finite` | `Basic.lean` | **landed** |
| 3 | the family `[u]·[v]^ω`, here bi-infinite `(τneg)^(ω*) · τzero · (τpos)^ω` | `SegmentFactorization`, `InFamily` | `Family.lean` | **landed** (the private `ZFactorization` of `../GroupModel/RamseyFactorization.lean`, renamed, with the middle segment's type `τzero`/`zero_type` added) |
| 3′ | a word *is* the concatenation of its factors | `kEquiv_zFiber_segSum` | `Segment.lean` | **landed** (moved from `../GroupModel/RamseyFactorization.lean`, made public) |
| 4 | Ramsey: a monochromatic monotone cutting sequence | `exists_zFactorization`, `family_cover`, `exists_matching_factorization` | `Family.lean` | **landed** (moved, made public; Ramsey applied twice, once per orientation) |
| 5 | saturation: each family member is inside or disjoint from the target | `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple` (`Saturation.lean`, **landed**: the block `k`-type is a function of the family); `family_saturation` (`Universal.lean`, planned) | `Saturation.lean`, `Universal.lean` | 5a landed; 5b planned |
| 5′ | a finite saturating cover makes the target a finite union of families | `target_eq_union_of_families` | `Universal.lean` | planned |
| 6 | conclude decidability | — | — | **out of scope** — the consumer's work |

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Basic.lean` | 122 | Cluster root: the six-step table, the scope disclaimer, and step 2, `kType_finite` — the alphabet of depth-`k` segment summaries is finite. |
| `Family.lean` | 238 | Steps 3-4: `SegmentFactorization` (the bi-infinite family datum, with the middle segment's type), `exists_zFactorization` (the Ramsey cover, `Nat.exists_strictMono_const_pair_colour` applied once per orientation), `InFamily`, `family_cover` and the unbundled `exists_matching_factorization`. |
| `Saturation.lean` | 148 | Step 5a: `kTypeColouring_eq_of_matching_segments` (matched segment types give equal coloured index orders), the headline `kEquiv_zFiber_of_matching_segments` (matched segment types give `≡ₖ` blocks, by the segment-sum lemma on each side and the mixing lemma), and `kTypeOf_zFiber_eq_of_sameTriple`/`kTypeOf_zFiber_eq_of_inFamily` (the block `k`-type is a function of the family triple). |
| `Segment.lean` | 108 | Step 3′: the segment carrier `segZ` (the half-open coloured segment `[a, b)` of `ℤ`) and `kEquiv_zFiber_segSum` — a coloured `ℤ`-block is `≡ₖ` the `ℤ`-indexed sum of its segments under any monotone covering cutting sequence. |

## The consumer relation

The substrate is **built here and consumed downstream, never absorbed into the consuming
record**. Its consumer is the decidability side's seam interface, which connects
`plusStab_iff_omega` to the family triple of a coloured block against an abstract realization
hypothesis; assembling a decidable `⊡` check on the path-space presentation is that consumer's
work, not this cluster's. Headline axiom profiles are pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean`.

## What this cluster does not give you

- **No decidability result and no complexity bound.** Saturation is proved for targets
  determined by the block's `k`-type. Getting from a `⊡` fibre condition to such a target is the
  MSO-to-ω-regular correspondence, unformalized in every proof assistant (cslib has zero MSO);
  the seam interface carries it as a hypothesis field and discharges nothing. The CTL⋆ 2EXPTIME
  lower bound is a sanity ceiling only, never a source of an upper bound.
- **No device discrimination on the probed shapes.** `⊡(Fp)`/`⊡(Pp)` are device-inert on finite
  fixtures (machine-checked in the device-selection probe); nothing here claims otherwise.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of this chain with the Ramsey core of Büchi complementation was raised
   from a framing to a proof-level reading of cslib's `IsRegular.compl` proof body; the further
   claim that MSO-over-`⟨ℤ,<⟩` *reduces* to it remains Medium-confidence and is not used by any
   theorem here.

## Recorded follow-up

A task-type-neutral home for the `k`-type kernel (`KType`, `kTypeOf`, `KEquiv`, the mixing lemma)
outside `WeakCanonical/` — e.g. beside `../../Expressiveness/` — was considered and deferred: the
kernel's current consumers all live under `WeakCanonical/`, so the move would add churn without
removing a cross-front import today.

## Measured import closure

Measured on the day `Segment.lean` landed, by a transitive walk of `import FormalSystem.*` lines
from `Segment.lean`: **141** `FormalSystem.*` modules, of which 12 are under `WeakCanonical/` —
`BackAndForth`, `ChronicleExtraction`, `ColourOrders`, `FrameProperties`,
`GroupModel/BlockDecomposition`, `IntegerModel/GoodStructures`, `KTypeSummary/Basic`,
`MixedSum`, `NEquivalence`, `OrderedSum`, `ReflexiveCanonical`, `TruthLemma`. Neither
`GroupModel/MonoDiscrete.lean` nor `GroupModel/GoodGroupable.lean` is in the closure, and
neither is `GroupModel/RamseyFactorization.lean` (the import runs the other way: it imports the
carrier from here). Hygiene is a preference, not a gate; if a later step needs the anchored
coloured-order lemma and pulls `MonoDiscrete` in, that is recorded here rather than designed
around.

## Dependencies

- **Imports from**: `../NEquivalence.lean`, `../MixedSum.lean`,
  `../GroupModel/BlockDecomposition.lean` (`zFiber`), `../IntegerModel/GoodStructures.lean`
  (`k_equiv_of_iso`), `../../../ForMathlib/Combinatorics/InfiniteRamseyPairs.lean` (the
  Ramsey ingredient); see "Measured import closure" below
- **Imported by**: `../../WeakCanonical.lean` (the sibling aggregator), via `../KTypeSummary.lean`

## Related Documentation

- [WeakCanonical README](../README.md)
- [GroupModel README](../GroupModel/README.md) — where the Ramsey ingredients were first proved
- [`ForMathlib/Combinatorics/`](../../../ForMathlib/Combinatorics/README.md) — infinite Ramsey for pairs

---

*Last verified: 2026-10-07*
