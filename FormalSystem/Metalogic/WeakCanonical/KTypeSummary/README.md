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
| 1′ | the congruence is computable on finite words | `kTypeOfFin`, `kTypeOfFin_eq` (`KTypeFin.lean`: the computable `k`-type of a finite decidable structure is the classical one); `kTypeOf_listSeg_append_congr` (`../../Decidability/RaySummary/Compose.lean`: composition on representatives) | `KTypeFin.lean`, consumer side `../../Decidability/RaySummary/Compose.lean` | **landed** (a computability witness for the alphabet; decides nothing about `⊡`) |
| 2 | the congruence has finite index | `kType_finite` | `Basic.lean` | **landed** |
| 3 | the family `[u]·[v]^ω`, here bi-infinite `(τneg)^(ω*) · τzero · (τpos)^ω` | `SegmentFactorization`, `InFamily` | `Family.lean` | **landed** (the private `ZFactorization` of `../GroupModel/RamseyFactorization.lean`, renamed, with the middle segment's type `τzero`/`zero_type` added) |
| 3′ | a word *is* the concatenation of its factors | `kEquiv_zFiber_segSum` | `Segment.lean` | **landed** (moved from `../GroupModel/RamseyFactorization.lean`, made public) |
| 4 | Ramsey: a monochromatic monotone cutting sequence | `exists_zFactorization`, `family_cover`, `exists_matching_factorization` | `Family.lean` | **landed** (moved, made public; Ramsey applied twice, once per orientation) |
| 5 | saturation: each family member is inside or disjoint from the target | `kEquiv_zFiber_of_matching_segments`, `kTypeOf_zFiber_eq_of_sameTriple` (`Saturation.lean`: the block `k`-type is a function of the family); `family_saturation` (`Universal.lean`: for `k`-type-determined targets) | `Saturation.lean`, `Universal.lean` | **landed** (5a and 5b) |
| 5′ | a finite saturating cover makes the target a finite union of families | `finite_family_triples`, `target_eq_union_of_families` | `Universal.lean` | **landed** (for `k`-type-determined targets only) |
| 6 | conclude decidability | — | — | **out of scope** — the consumer's work |

## Modules

| File | Lines | Description |
|------|-------|-------------|
| `Basic.lean` | 119 | Cluster root: the six-step table, the scope disclaimer, and step 2, `kType_finite` — the alphabet of depth-`k` segment summaries is finite. |
| `Family.lean` | 235 | Steps 3-4: `SegmentFactorization` (the bi-infinite family datum, with the middle segment's type), `exists_zFactorization` (the Ramsey cover, `Nat.exists_strictMono_const_pair_colour` applied once per orientation), `InFamily`, `family_cover` and the unbundled `exists_matching_factorization`. |
| `Saturation.lean` | 148 | Step 5a: `kTypeColouring_eq_of_matching_segments` (matched segment types give equal coloured index orders), the headline `kEquiv_zFiber_of_matching_segments` (matched segment types give `≡ₖ` blocks, by the segment-sum lemma on each side and the mixing lemma), and `kTypeOf_zFiber_eq_of_sameTriple`/`kTypeOf_zFiber_eq_of_inFamily` (the block `k`-type is a function of the family triple). |
| `Segment.lean` | 108 | Step 3′: the segment carrier `segZ` (the half-open coloured segment `[a, b)` of `ℤ`) and `kEquiv_zFiber_segSum` — a coloured `ℤ`-block is `≡ₖ` the `ℤ`-indexed sum of its segments under any monotone covering cutting sequence. |
| `Universal.lean` | 155 | Step 5b: `DeterminedByKType` (a target determined by the block's `k`-type) with its non-vacuity witness `determinedByKType_nfEval` and its sentence-level generalisation `determinedByKType_eval` (any depth-`≤ k` sentence target, via `doets_lemma_1_1`), saturation proper `family_saturation` (each family inside or disjoint from the target), `finite_family_triples`, and `target_eq_union_of_families` (a `k`-type-determined target is the union of the families it contains). Not a decidability result; not about `⊡`. |
| `KTypeFin.lean` | 193 | Step 1′: `decNfEvalNf` (`NfEvalNf` is decidable on a finite decidable structure, by induction on `k`), the computable `kTypeOfFin` with `kTypeOfFin_eq` (it is the classical `kTypeOf`, pointwise), the decidable Tarski satisfaction `decEval`, and the explicit computable instances for a segment of a decidable colouring (`segZFintype`, `segZDecidableEq`, `segZDecidableLT`, `segZDecidablePred`; every `ℤ`-subtype instance is an explicit term, never `inferInstanceAs`, which resolves through the noncomputable `Int.instConditionallyCompleteLinearOrder`) with `kTypeOfFin_segZ`. A computability witness for the summary alphabet only; it composes nothing and decides nothing about `⊡`. |

## Evidence

Two probes in the tracked evidence collection exercise this cluster; both are wired into
`scripts/check-evidence-probes.sh` and compile sorry-free on the standard axiom profile.

- `specs/evidence/seam-gluing-ray-product/ktype-summary-substrate-probe.lean` runs the chain end
  to end on a concrete infinite fibre: an explicit cutting of the even-parity block with its
  segment type equations proved by order isomorphism (never by evaluating `kTypeOf`), the cover
  agreeing with it, the parity triple confirmed degenerate, and the central fact that the
  distinct odd-parity block cut at the odd times lies in the same family — so the two blocks
  have equal `k`-type at every depth — with `family_saturation` and
  `target_eq_union_of_families` instantiated on the normal-form target. It inhabits no
  `Presents` bundle and claims no `k`-type distinctness.
- `specs/evidence/seam-gluing-ray-product/stab-depth-two-probe.lean` is E2, the depth-2
  stratification probe on the smallest fixture whose depth-1 `⊡` value is state-dependent: both
  depth-2 shapes computed directly and through the strata, and the falsifier check positive on
  that fixture (not a proof the falsifier cannot exist — see its header).

Every step of the chain this cluster owns (2, 3, 3′, 4, 5, 5′) is landed; step 6 is out of
scope by design.

## The consumer relation

The substrate is **built here and consumed downstream, never absorbed into the consuming
record**. Its consumer is the decidability side's seam interface
(`Decidability/RaySummary/`), which connects `plusStab_iff_omega` to the family triples of the
two-letter trace: the single-family bundle `Presents` is characterized as seam decidedness, and
the hypothesis-free bridge `plusStab_iff_forall_hit` is a theorem over the realized set `Hit`.
The realizability device beside that interface reads realized triples off a finite labelled
presentation with the computable `hitOf` (`RaySummary/HitOf.lean`, characterized by
`mem_hitOf_iff`), composing segment summaries on representatives (`kTypeOf_listSeg_append_congr`,
`RaySummary/Compose.lean`) with the `k`-types this cluster's `KTypeFin.lean` reads off; a seam's
realized set equals `hitOf` only under the explicit realization hypothesis `Presented`
(`hit_eq_hitOf_of_presented`, `RaySummary/Trace.lean`), discharged for no non-trivial model.
Assembling a decidable `⊡` check on the path-space presentation remains that consumer's work,
not this cluster's. Headline axiom profiles are pinned in
`Tests/BimodalTest/Metalogic/KTypeSummaryAxiomTest.lean` (twenty-seven `#print axioms` rows).

## What this cluster does not give you

- **No decidability result and no complexity bound.** Saturation (`family_saturation`) and the
  finite-family cover (`target_eq_union_of_families`) are proved for targets determined by the
  block's `k`-type — `DeterminedByKType`, whose exhibited instances are the depth-`k` normal
  forms (`determinedByKType_nfEval`) and, through Doets's Lemma 1.1, every depth-`≤ k` sentence
  (`determinedByKType_eval`). Getting from a `⊡` fibre condition to such a target is the seam
  interface's business (`Decidability/RaySummary/`): its single-family bundle `Presents` turns
  out to be seam decidedness (`exists_presents_iff`), its hypothesis-free bridge
  `plusStab_iff_forall_hit` reduces `⊡φ` to a finite conjunction over the realized family
  triples `Hit`, and `Hit` is computed by `hitOf` only on a finite presentation and only under
  the realization hypothesis `Presented` — never for a model outright. "Finite union of
  families" is a finiteness statement (`finite_family_triples`), not a cardinality bound, and
  the CTL⋆ 2EXPTIME lower bound (argued, not formalized) is a sanity ceiling only, never a source of an upper bound.
- **No device discrimination on the probed shapes.** `⊡(Fp)`/`⊡(Pp)` are device-inert on finite
  fixtures (machine-checked in the device-selection probe); nothing here claims otherwise.

## Two carried limits

1. The backward `⊡(Pp)` shape on the real formula is fixed by the asymmetric-fixture probe
   (`specs/evidence/seam-gluing-ray-product/backward-dual-asymmetric-fixture.lean`), not
   re-proved here; no backward Bool-fixture bridge exists.
2. The identification of this chain with the Ramsey core of Büchi complementation was raised
   from a framing to a proof-level reading of cslib's `IsRegular.compl` proof body. The further
   question — whether MSO-over-`⟨ℤ,<⟩` *reduces* to it — is sharpened by the seam interface:
   this cluster supplies the complementation half in full (the seam bridge
   `plusStab_iff_forall_hit` needs no hypothesis), and the realizability half is landed as far
   as a presentation (`hitOf`, `mem_hitOf_iff`, and `hit_eq_hitOf_of_presented` under
   `Presented`); realizing a presentation by a constructed regular model is the residue, held in
   place by the wired probe `quasistate_does_not_determine_hit`. No theorem here depends on
   that question.

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

*Last verified: 2026-10-08*
